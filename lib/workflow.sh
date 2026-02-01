#!/bin/bash
# ==============================================================================
# Git-AI Manager - Workflow Management Module
# ==============================================================================

# Finish branch workflow (merge or delete)
action_finish() {
    local branch=$(git branch --show-current)
    local branch_type=$(get_branch_type "$branch")
    local main_branch=$(get_main_branch)

    # Can't finish on main
    if [ "$branch_type" == "main" ]; then
        show_error_box "CANNOT FINISH" "Cannot finish workflow on main branch" "Create a feature or test branch first\nUse [5] Branch to create a new branch"
        sleep 1.5
        return 1
    fi

    # Handle uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}⚠️ Uncommitted changes detected:${NC}"
        echo ""
        git status --short | head -15
        echo ""

        echo -e "  How to handle?"
        echo -e "    ${GREEN}1)${NC} 📋 Stash"
        echo -e "    ${RED}2)${NC} 🗑️  Discard ${DIM}(irreversible)${NC}"
        echo -e "    ${DIM}3)${NC} Cancel"
        echo ""

        read -e -r -p "  Select (1/2/3): " choice

        case "$choice" in
            1)
                local stash_name="git-ai-finish-$(date +%Y%m%d-%H%M%S)"
                git add -A
                git stash push -m "$stash_name"
                echo -e "${GREEN}✅ Stashed: '$stash_name'${NC}"
                ;;
            2)
                read -e -r -p "   ${RED}Type 'yes' to confirm:${NC} " confirm
                if [[ "$confirm" == "yes" ]]; then
                    git checkout -- . 2>/dev/null
                    git clean -fd 2>/dev/null
                    echo -e "${GREEN}✅ Changes discarded${NC}"
                else
                    echo -e "${DIM}Cancelled${NC}"
                    return 1
                fi
                ;;
            *)
                echo -e "${DIM}Cancelled${NC}"
                return 1
                ;;
        esac
        echo ""
    fi

    echo ""
    print_divider
    echo -e "  ${BOLD}📍 Branch:${NC} $branch"
    echo -e "  ${BOLD}📂 Type:${NC} $branch_type"
    print_divider

    # -------------------------------------------------------------------------
    # Temporary Branch (test/temp/debug/exp)
    # -------------------------------------------------------------------------
    if [ "$branch_type" == "temporary" ]; then
        local parent=$(get_parent_branch)

        echo -e "\n  ${YELLOW}🧪 Temporary/Test branch${NC}"
        echo -e "  ${DIM}Parent: $parent${NC}"
        echo ""

        echo -e "  ${CYAN}Commits on this branch:${NC}"
        git log "$parent"..HEAD --oneline 2>/dev/null | while read line; do
            echo -e "    ${DIM}•${NC} $line"
        done
        echo ""

        echo -e "  ${BOLD}Test result?${NC}"
        echo -e "    ${GREEN}1)${NC} ✅ Success"
        echo -e "    ${RED}2)${NC} ❌ Failed"
        echo -e "    ${YELLOW}3)${NC} 🤔 Postpone"
        echo ""

        read -e -r -p "  Select (1/2/3): " result

        case "$result" in
            1)
                # Success - ask merge or discard
                echo ""
                echo -e "  ${BOLD}What to do with successful changes?${NC}"
                echo -e "    ${GREEN}1)${NC} 🔀 Merge to '$parent'"
                echo -e "    ${YELLOW}2)${NC} 🗑️  Discard (just verified)"
                echo ""

                read -e -r -p "  Select (1/2): " merge_choice

                if [[ "$merge_choice" == "1" ]]; then
                    read -e -r -p "  Merge message (default: Merge test '$branch'): " msg
                    msg=${msg:-"Merge test branch '$branch'"}

                    sync_context "Test '$branch' succeeded. Merging to '$parent'."

                    echo -e "\n${CYAN}🔀 Merging to '$parent'...${NC}"
                    git checkout "$parent"

                    if git merge --no-ff "$branch" -m "$msg" 2>/dev/null; then
                        echo -e "${GREEN}✅ Merged!${NC}"
                        echo -e "${RED}🗑️  Deleting '$branch'...${NC}"
                        delete_branch_with_remote "$branch" "false"
                    else
                        echo -e "${RED}❌ Merge failed (conflict?)${NC}"
                        git checkout "$branch"
                        return 1
                    fi
                else
                    sync_context "Test '$branch' succeeded but discarded."
                    echo -e "\n${CYAN}↩️  Returning to '$parent'...${NC}"
                    git checkout "$parent"
                    echo -e "${RED}🗑️  Deleting '$branch'...${NC}"
                    delete_branch_with_remote "$branch" "true"
                fi
                ;;
            2)
                # Failed - just delete
                sync_context "Test '$branch' failed. Deleting."
                echo -e "\n${CYAN}↩️  Returning to '$parent'...${NC}"
                git checkout "$parent"
                echo -e "${RED}🗑️  Deleting '$branch'...${NC}"
                delete_branch_with_remote "$branch" "true"
                ;;
            3)
                echo -e "${YELLOW}Branch preserved. Run finish again later.${NC}"
                return 0
                ;;
            *)
                echo -e "${DIM}Cancelled${NC}"
                return 0
                ;;
        esac

        echo -e "${GREEN}✅ Done! Continue on '$parent'.${NC}"
        rm -f "$PARENT_BRANCH_FILE"

    # -------------------------------------------------------------------------
    # Feature Branch (feat/fix/...)
    # -------------------------------------------------------------------------
    elif [ "$branch_type" == "feature" ]; then
        echo -e "\n  ${GREEN}🚀 Feature branch${NC}"
        echo ""

        echo -e "  ${CYAN}Commits on this branch:${NC}"
        git log "$main_branch"..HEAD --oneline 2>/dev/null | while read line; do
            echo -e "    ${DIM}•${NC} $line"
        done
        echo ""

        echo -e "  ${BOLD}Feature status?${NC}"
        echo -e "    ${GREEN}1)${NC} ✅ Complete - ready to merge"
        echo -e "    ${RED}2)${NC} ❌ Incomplete - more work needed"
        echo -e "    ${YELLOW}3)${NC} 🗑️  Discard - no longer needed"
        echo ""

        read -e -r -p "  Select (1/2/3): " choice

        case "$choice" in
            1)
                read -e -r -p "  Merge message (default: Merge '$branch'): " msg
                msg=${msg:-"Merge branch '$branch'"}

                sync_context "Feature '$branch' complete. Merging to '$main_branch'."

                echo -e "\n${CYAN}🔀 Merging to '$main_branch'...${NC}"
                git checkout "$main_branch"
                git merge --no-ff "$branch" -m "$msg"

                read -e -r -p "  Delete local branch? (y/n): " del
                if [[ "$del" == "y" || "$del" == "Y" ]]; then
                    delete_branch_with_remote "$branch" "false"
                fi

                echo -e "${GREEN}✅ Merged!${NC}"
                ;;
            2)
                echo -e "${YELLOW}Continue working. Run finish when ready.${NC}"
                sync_context "Feature '$branch' incomplete."
                ;;
            3)
                read -e -r -p "  ${RED}Type 'yes' to confirm discard:${NC} " confirm
                if [[ "$confirm" == "yes" ]]; then
                    sync_context "Feature '$branch' discarded."
                    git checkout "$main_branch"
                    delete_branch_with_remote "$branch" "true"
                else
                    echo -e "${DIM}Cancelled${NC}"
                fi
                ;;
            *)
                echo -e "${DIM}Cancelled${NC}"
                ;;
        esac

    # -------------------------------------------------------------------------
    # Unknown Branch Type
    # -------------------------------------------------------------------------
    else
        echo -e "\n  ${YELLOW}⚠️ Unknown branch type${NC}"
        echo -e "  ${DIM}Tip: Use prefixes like feat/, test/, temp/ for auto-detection${NC}"
        echo ""
        echo -e "  How to handle?"
        echo -e "    ${GREEN}1)${NC} Treat as feature (merge to main)"
        echo -e "    ${YELLOW}2)${NC} Treat as temporary (delete)"
        echo -e "    ${DIM}3)${NC} Cancel"
        echo ""

        read -e -r -p "  Select (1/2/3): " choice

        case "$choice" in
            1)
                sync_context "Unknown branch '$branch' treated as feature."
                git checkout "$main_branch"
                git merge --no-ff "$branch" -m "Merge branch '$branch'"
                echo -e "${GREEN}✅ Merged!${NC}"

                read -e -r -p "  Delete branch? (y/n): " del
                [[ "$del" == "y" || "$del" == "Y" ]] && delete_branch_with_remote "$branch" "false"
                ;;
            2)
                sync_context "Unknown branch '$branch' discarded."
                git checkout "$main_branch"
                delete_branch_with_remote "$branch" "true"
                ;;
            *)
                echo -e "${DIM}Cancelled${NC}"
                ;;
        esac
    fi
}
