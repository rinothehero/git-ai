#!/bin/bash
# ==============================================================================
# Git-AI Manager - Branch Utilities Module
# ==============================================================================

# Get branch type based on naming pattern
get_branch_type() {
    local branch="$1"

    if [[ "$branch" =~ $TEMP_BRANCH_PATTERN ]]; then
        echo "temporary"
    elif [[ "$branch" =~ $FEATURE_BRANCH_PATTERN ]]; then
        echo "feature"
    elif [[ "$branch" =~ $MAIN_BRANCH_PATTERN ]]; then
        echo "main"
    else
        echo "unknown"
    fi
}

# Get main branch name (main or master)
get_main_branch() {
    git branch --list main master 2>/dev/null | head -n 1 | tr -d '* ' | xargs
}

# Get parent branch from file or fallback to main
get_parent_branch() {
    if [ -f "$PARENT_BRANCH_FILE" ]; then
        cat "$PARENT_BRANCH_FILE"
    else
        get_main_branch
    fi
}

# Save parent branch to file
save_parent_branch() {
    echo "$1" > "$PARENT_BRANCH_FILE"
}

# Delete branch with optional remote deletion
delete_branch_with_remote() {
    local branch="$1"
    local force="${2:-false}"

    # Delete local
    if [ "$force" == "true" ]; then
        git branch -D "$branch" 2>/dev/null
    else
        git branch -d "$branch" 2>/dev/null
    fi
    echo -e "${GREEN}✅ 로컬 브랜치 삭제됨${NC}"

    # Check and offer remote deletion
    local remote_exists=$(git ls-remote --heads origin "$branch" 2>/dev/null)
    if [ -n "$remote_exists" ]; then
        echo ""
        read -e -r -p "   원격 브랜치(origin/$branch)도 삭제할까요? (y/n): " del_remote
        if [[ "$del_remote" == "y" || "$del_remote" == "Y" ]]; then
            if git push origin --delete "$branch" 2>/dev/null; then
                echo -e "${GREEN}✅ 원격 브랜치도 삭제됨${NC}"
            else
                echo -e "${RED}❌ 원격 브랜치 삭제 실패${NC}"
            fi
        fi
    fi
}
