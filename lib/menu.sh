#!/bin/bash
# ==============================================================================
# Git-AI Manager - Menu & Main Loop Module
# ==============================================================================

# Show interactive menu
show_menu() {
    local sid=$(get_session_id)
    local status="${RED}○${NC}"
    [ -n "$sid" ] && status="${GREEN}●${NC}"

    echo -e "  ${BOLD}Quick Actions${NC}                          ${BOLD}AI Actions${NC} $status              ${BOLD}Workflow${NC}"
    echo -e "  ${DIM}─────────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "   ${BOLD}1${NC} Stage All    ${BOLD}4${NC} Stash 📋   ${BOLD}7${NC} Log       ${BOLD}i${NC} Init AI       ${BOLD}v${NC} Review       ${BOLD}f${NC} Finish"
    echo -e "   ${BOLD}2${NC} Unstage     ${BOLD}5${NC} Branch     ${BOLD}8${NC} Diff      ${BOLD}c${NC} AI Commit"
    echo -e "   ${BOLD}3${NC} Uncommit    ${BOLD}6${NC} Push       ${BOLD}9${NC} ${RED}Discard${NC}"
    echo -e "  ${DIM}─────────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "   ${BOLD}r${NC} Refresh     ${BOLD}q${NC} Quit       ${BOLD}?${NC} Help"
    echo ""
}

# Show help menu
show_help() {
    echo -e "\n${BOLD}Git-AI Manager v${VERSION}${NC}\n"
    echo -e "${CYAN}Quick Actions:${NC}"
    echo -e "  1  Stage All      - git add -A"
    echo -e "  2  Unstage        - git reset HEAD"
    echo -e "  3  Uncommit       - git reset --soft HEAD~1"
    echo -e "  4  Stash          - Stash management submenu"
    echo -e "  5  Branch         - Switch/create branches"
    echo -e "  6  Push           - Push to remote"
    echo -e "  7  Log            - Show git log graph"
    echo -e "  8  Diff           - Show changes"
    echo -e "  9  Discard        - Discard all changes"
    echo ""
    echo -e "${CYAN}AI Actions:${NC}"
    echo -e "  i  Init AI        - Initialize Gemini session with project context"
    echo -e "  v  Review         - AI code review of changes"
    echo -e "  c  Commit         - AI analyzes changes and suggests commit/branch"
    echo ""
    echo -e "${CYAN}Workflow:${NC}"
    echo -e "  f  Finish         - Complete branch workflow (merge/delete)"
    echo ""
    echo -e "${CYAN}Branch Naming:${NC}"
    echo -e "  Temporary: test/, temp/, debug/, exp/"
    echo -e "  Feature:   feat/, fix/, refactor/, docs/"
    echo ""
    read -e -r -p "Press Enter to continue..."
}

# Main interactive loop
main_loop() {
    while true; do
        show_status
        show_menu

        read -e -r -p "  Select: " choice
        choice=$(trim "$choice")

        [ -z "$choice" ] && continue

        case "$choice" in
            1) action_stage_all ;;
            2) action_unstage_all ;;
            3) action_uncommit ;;
            4) action_stash_menu ;;
            5) action_switch_branch ;;
            6) action_push ;;
            7) action_show_log ;;
            8) action_show_diff ;;
            9) action_discard_changes ;;
            i|I) action_init ;;
            v|V) action_ai_review ;;
            c|C) action_ai_commit ;;
            f|F) action_finish ;;
            r|R) continue ;;
            q|Q) echo -e "\n${DIM}Goodbye! 👋${NC}\n"; exit 0 ;;
            \?|h|H) show_help ;;
            *) echo -e "${YELLOW}Invalid: '$choice'${NC}"; sleep 0.3 ;;
        esac

        if [[ ! "$choice" =~ ^[7rRqQ\?hH]$ ]]; then
            echo ""
            read -e -r -p "Press Enter to continue..."
        fi
    done
}
