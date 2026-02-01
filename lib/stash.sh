#!/bin/bash
# ==============================================================================
# Git-AI Manager - Stash Management Module
# ==============================================================================

# Interactive stash management menu
action_stash_menu() {
    echo -e "\n${BLUE}📋 Stash Management${NC}"

    local stash_list=$(git stash list 2>/dev/null)
    local stash_count=0

    if [ -n "$stash_list" ]; then
        echo -e "\n${CYAN}Current stashes:${NC}"
        local idx=0
        while IFS= read -r line; do
            echo -e "   ${DIM}$idx)${NC} $line"
            ((idx++))
        done <<< "$stash_list"
        stash_count=$idx
    else
        echo -e "\n   ${DIM}No stashes${NC}"
    fi

    echo ""
    echo -e "  ${BOLD}1)${NC} 💾 Save"
    echo -e "  ${BOLD}2)${NC} 📤 Pop (restore & delete)"
    echo -e "  ${BOLD}3)${NC} 👀 Apply (restore & keep)"
    echo -e "  ${BOLD}4)${NC} 🗑️  Drop (delete one)"
    echo -e "  ${BOLD}5)${NC} 🧹 Clear All"
    echo -e "  ${DIM}0)${NC} Cancel"
    echo ""

    read -e -r -p "  Select: " choice
    choice=$(trim "$choice")

    case "$choice" in
        1)
            read -e -r -p "   Stash message (optional): " msg
            msg=$(trim "$msg")
            local result
            if [ -n "$msg" ]; then
                result=$(git stash push -m "$msg" 2>&1)
            else
                result=$(git stash push 2>&1)
            fi

            if [[ "$result" == *"No local changes"* ]]; then
                echo -e "${YELLOW}⚠️ Nothing to stash${NC}"
            else
                echo -e "${GREEN}✅ Stashed${NC}"
                sync_context "User stashed changes: '$msg'"
            fi
            ;;
        2)
            [ $stash_count -eq 0 ] && { echo -e "${YELLOW}⚠️ No stashes${NC}"; return 0; }
            read -e -r -p "   Stash number (default: 0): " num
            num=$(trim "$num"); num=${num:-0}
            [[ ! "$num" =~ ^[0-9]+$ ]] && { echo -e "${RED}❌ Invalid number${NC}"; return 1; }

            if git stash pop "stash@{$num}" 2>/dev/null; then
                echo -e "${GREEN}✅ Stash restored and deleted${NC}"
            else
                echo -e "${RED}❌ Failed (conflict?)${NC}"
            fi
            ;;
        3)
            [ $stash_count -eq 0 ] && { echo -e "${YELLOW}⚠️ No stashes${NC}"; return 0; }
            read -e -r -p "   Stash number (default: 0): " num
            num=$(trim "$num"); num=${num:-0}
            [[ ! "$num" =~ ^[0-9]+$ ]] && { echo -e "${RED}❌ Invalid number${NC}"; return 1; }

            if git stash apply "stash@{$num}" 2>/dev/null; then
                echo -e "${GREEN}✅ Stash applied (kept)${NC}"
            else
                echo -e "${RED}❌ Failed (conflict?)${NC}"
            fi
            ;;
        4)
            [ $stash_count -eq 0 ] && { echo -e "${YELLOW}⚠️ No stashes${NC}"; return 0; }
            read -e -r -p "   Stash number to delete: " num
            num=$(trim "$num")
            [ -z "$num" ] && { echo -e "${DIM}Cancelled${NC}"; return 0; }
            [[ ! "$num" =~ ^[0-9]+$ ]] && { echo -e "${RED}❌ Invalid number${NC}"; return 1; }
            [ "$num" -ge "$stash_count" ] && { echo -e "${RED}❌ Invalid stash number${NC}"; return 1; }

            read -e -r -p "   Delete stash@{$num}? (y/n): " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                git stash drop "stash@{$num}"
                echo -e "${GREEN}✅ Deleted${NC}"
            else
                echo -e "${DIM}Cancelled${NC}"
            fi
            ;;
        5)
            [ $stash_count -eq 0 ] && { echo -e "${YELLOW}⚠️ No stashes${NC}"; return 0; }
            echo -e "   ${RED}⚠️ All $stash_count stash(es) will be deleted!${NC}"
            read -e -r -p "   Type 'yes' to confirm: " confirm
            if [[ "$confirm" == "yes" ]]; then
                git stash clear
                echo -e "${GREEN}✅ All stashes cleared${NC}"
            else
                echo -e "${DIM}Cancelled${NC}"
            fi
            ;;
        *)
            echo -e "${DIM}Cancelled${NC}"
            ;;
    esac
}
