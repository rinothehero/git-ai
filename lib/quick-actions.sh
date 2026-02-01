#!/bin/bash
# ==============================================================================
# Git-AI Manager - Quick Actions Module
# ==============================================================================

# Stage all changes
action_stage_all() {
    echo -e "\n${GREEN}📦 Staging all changes...${NC}"
    git add -A
    echo -e "${GREEN}✅ Done${NC}"
    sync_context "User staged all changes"
}

# Unstage all files
action_unstage_all() {
    echo -e "\n${YELLOW}📤 Unstaging all files...${NC}"
    git reset HEAD 2>/dev/null
    echo -e "${GREEN}✅ All files unstaged${NC}"
    sync_context "User unstaged all files"
}

# Uncommit last commit (soft reset)
action_uncommit() {
    echo -e "\n${YELLOW}↩️  Uncommit (soft reset)...${NC}"

    local last=$(git log -1 --oneline 2>/dev/null)
    if [ -z "$last" ]; then
        echo -e "${RED}❌ No commits to undo${NC}"
        return 1
    fi

    echo -e "   Target: ${DIM}$last${NC}"
    read -e -r -p "   Proceed? (y/n): " confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        git reset --soft HEAD~1
        echo -e "${GREEN}✅ Commit undone, changes back in staging${NC}"
        sync_context "User undid commit: $last"
    else
        echo -e "${DIM}Cancelled${NC}"
    fi
}

# Discard all local changes
action_discard_changes() {
    echo -e "\n${RED}⚠️  WARNING: All local changes will be deleted!${NC}"
    read -e -r -p "   Type 'yes' to confirm: " confirm

    if [[ "$confirm" == "yes" ]]; then
        git checkout -- . 2>/dev/null
        git clean -fd 2>/dev/null
        echo -e "${GREEN}✅ All changes discarded${NC}"
        sync_context "User discarded all local changes"
    else
        echo -e "${DIM}Cancelled${NC}"
    fi
}

# Switch branch or create new one
action_switch_branch() {
    echo -e "\n${BLUE}⎇ Local branches:${NC}"
    git branch | head -10

    echo -e "\n${CYAN}⎇ Remote branches:${NC}"
    git branch -r | grep -v HEAD | head -10

    echo ""
    read -e -r -p "   Branch name (without origin/): " branch_name
    branch_name=$(trim "$branch_name")

    if [ -z "$branch_name" ]; then
        echo -e "${DIM}Cancelled${NC}"
        return 0
    fi

    branch_name="${branch_name#origin/}"

    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        git checkout "$branch_name" && echo -e "${GREEN}✅ Switched to '$branch_name'${NC}"
        sync_context "User switched to branch '$branch_name'"
    elif git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
        git checkout -b "$branch_name" "origin/$branch_name" && \
            echo -e "${GREEN}✅ Switched to '$branch_name' (from remote)${NC}"
        sync_context "User switched to branch '$branch_name' (from remote)"
    else
        echo -e "${YELLOW}⚠️ Branch '$branch_name' does not exist.${NC}"
        read -e -r -p "   Create new branch? (y/n): " create_new
        if [[ "$create_new" == "y" || "$create_new" == "Y" ]]; then
            git checkout -b "$branch_name" && echo -e "${GREEN}✅ Created '$branch_name'${NC}"
            sync_context "User created branch '$branch_name'"
        else
            echo -e "${DIM}Cancelled${NC}"
        fi
    fi
}

# Show git log
action_show_log() {
    echo -e "\n${CYAN}📜 Git Log (recent 15):${NC}\n"
    git log --oneline --graph --decorate -15
    wait_for_key
}

# Show diff
action_show_diff() {
    local staged=$(git diff --cached 2>/dev/null)
    local unstaged=$(git diff 2>/dev/null)

    if [ -n "$staged" ]; then
        echo -e "\n${GREEN}Staged Diff:${NC}"
        git diff --cached --stat
        echo ""
        read -e -r -p "Show full diff? (y/n): " show
        [[ "$show" == "y" ]] && git diff --cached | head -100
    elif [ -n "$unstaged" ]; then
        echo -e "\n${YELLOW}Unstaged Diff:${NC}"
        git diff --stat
        echo ""
        read -e -r -p "Show full diff? (y/n): " show
        [[ "$show" == "y" ]] && git diff | head -100
    else
        echo -e "${DIM}No changes${NC}"
    fi
    wait_for_key
}

# Push to remote
action_push() {
    local branch=$(git branch --show-current)
    local remote_exists=$(git ls-remote --heads origin "$branch" 2>/dev/null)

    echo -e "\n${CYAN}📤 Push to remote${NC}"
    echo -e "   Branch: ${BOLD}$branch${NC}"

    local unpushed=$(git log origin/"$branch"..HEAD --oneline 2>/dev/null)
    if [ -z "$unpushed" ] && [ -n "$remote_exists" ]; then
        echo -e "   ${DIM}Nothing to push${NC}"
        return 0
    fi

    if [ -n "$unpushed" ]; then
        echo -e "\n   ${GREEN}Commits to push:${NC}"
        echo "$unpushed" | while read line; do echo -e "     ${DIM}•${NC} $line"; done
    fi

    echo ""

    if [ -z "$remote_exists" ]; then
        echo -e "   ${YELLOW}⚠️ Remote branch doesn't exist${NC}"
        read -e -r -p "   Create and push? (y/n): " confirm
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            git push -u origin "$branch" && echo -e "${GREEN}✅ Pushed (upstream set)${NC}"
            sync_context "User pushed new branch '$branch'"
        else
            echo -e "${DIM}Cancelled${NC}"
        fi
    else
        read -e -r -p "   Push? (y/n): " confirm
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            git push && echo -e "${GREEN}✅ Pushed${NC}"
            sync_context "User pushed to '$branch'"
        else
            echo -e "${DIM}Cancelled${NC}"
        fi
    fi
}
