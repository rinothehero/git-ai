#!/bin/bash
# ==============================================================================
# Git-AI Manager - Menu & Main Loop Module
# ==============================================================================

# Get menu label for key
get_menu_label() {
    case "$1" in
        "1") echo "Stage All" ;;
        "2") echo "Unstage" ;;
        "3") echo "Uncommit" ;;
        "4") echo "Stash 📋" ;;
        "5") echo "Branch" ;;
        "6") echo "Push" ;;
        "7") echo "Log" ;;
        "8") echo "Diff" ;;
        "9") echo "Discard" ;;
        "i") echo "Init AI" ;;
        "c") echo "AI Commit" ;;
        "v") echo "Review" ;;
        "f") echo "Finish" ;;
        "r") echo "Refresh" ;;
        "q") echo "Quit" ;;
        "?") echo "Help" ;;
        *) echo "" ;;
    esac
}

# Show interactive menu
show_menu() {
    local sid=$(get_session_id)
    local ai_status="${RED}○${NC}"
    [ -n "$sid" ] && ai_status="${GREEN}●${NC}"

    echo -e "${BOLD}Quick${NC}                    ${BOLD}AI${NC} $ai_status       ${BOLD}More${NC}"
    echo -e "${DIM}────────────────────────────────────${NC}"
    echo -e "${BOLD}1${NC}Stage ${BOLD}4${NC}Stash ${BOLD}7${NC}Log  ${BOLD}i${NC}Init ${BOLD}v${NC}Review ${BOLD}f${NC}Finish"
    echo -e "${BOLD}2${NC}Unst  ${BOLD}5${NC}Branch ${BOLD}8${NC}Diff ${BOLD}c${NC}Commit         ${BOLD}r${NC}Refresh"
    echo -e "${BOLD}3${NC}Uncom ${BOLD}6${NC}Push  ${BOLD}9${NC}${RED}Del${NC}                ${BOLD}q${NC}Quit"
    echo ""
}

# Show help menu
show_help() {
    clear
    echo -e "\n${BOLD}${CYAN}${DBOX_TL}${DBOX_H}${DBOX_H}${DBOX_H} Git-AI Manager v${VERSION} ${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_TR}${NC}\n"

    echo -e "${CYAN}${DBOX_VR}${DBOX_H} QUICK ACTIONS${NC}"
    echo -e "${CYAN}${DBOX_V}${NC}  ${BOLD}[1]${NC} Stage All      ${DIM}│${NC} git add -A"
    echo -e "${CYAN}${DBOX_V}${NC}  ${BOLD}[2]${NC} Unstage        ${DIM}│${NC} git reset HEAD"
    echo -e "${CYAN}${DBOX_V}${NC}  ${BOLD}[3]${NC} Uncommit       ${DIM}│${NC} git reset --soft HEAD~1"
    echo ""

    echo -e "${CYAN}${DBOX_VR}${DBOX_H} TOOLS${NC}"
    echo -e "${CYAN}${DBOX_V}${NC}  ${BOLD}[4]${NC} Stash          ${DIM}│${NC} Stash management submenu"
    echo -e "${CYAN}${DBOX_V}${NC}  ${BOLD}[5]${NC} Branch         ${DIM}│${NC} Switch/create branches"
    echo -e "${CYAN}${DBOX_V}${NC}  ${BOLD}[6]${NC} Push           ${DIM}│${NC} Push to remote"
    echo -e "${CYAN}${DBOX_V}${NC}  ${BOLD}[7]${NC} Log            ${DIM}│${NC} Show git log graph"
    echo -e "${CYAN}${DBOX_V}${NC}  ${BOLD}[8]${NC} Diff           ${DIM}│${NC} Show changes"
    echo -e "${CYAN}${DBOX_V}${NC}  ${BOLD}[9]${NC} ${RED}Discard${NC}        ${DIM}│${NC} ${RED}Discard all changes (destructive)${NC}"
    echo ""

    echo -e "${CYAN}${DBOX_VR}${DBOX_H} AI ACTIONS${NC} ${DIM}(Requires active session)${NC}"
    echo -e "${CYAN}${DBOX_V}${NC}  ${BOLD}[i]${NC} Init AI        ${DIM}│${NC} Initialize Gemini with project context"
    echo -e "${CYAN}${DBOX_V}${NC}  ${BOLD}[v]${NC} Review         ${DIM}│${NC} AI code review of changes"
    echo -e "${CYAN}${DBOX_V}${NC}  ${BOLD}[c]${NC} AI Commit      ${DIM}│${NC} AI analyzes and suggests commit message"
    echo ""

    echo -e "${CYAN}${DBOX_VR}${DBOX_H} WORKFLOW${NC}"
    echo -e "${CYAN}${DBOX_V}${NC}  ${BOLD}[f]${NC} Finish         ${DIM}│${NC} Complete branch workflow (merge/delete)"
    echo ""

    echo -e "${CYAN}${DBOX_VR}${DBOX_H} BRANCH NAMING CONVENTIONS${NC}"
    echo -e "${CYAN}${DBOX_V}${NC}  ${YELLOW}Temporary:${NC}  test/, temp/, debug/, exp/"
    echo -e "${CYAN}${DBOX_V}${NC}  ${GREEN}Feature:${NC}    feat/, fix/, refactor/, docs/, chore/"
    echo -e "${CYAN}${DBOX_V}${NC}  ${CYAN}Main:${NC}       main, master"
    echo ""

    echo -e "${CYAN}${DBOX_BL}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_H}${DBOX_BR}${NC}"

    wait_for_key
}

# Main interactive loop
main_loop() {
    while true; do
        show_status
        show_menu

        # Read input directly
        local choice
        read -e -r -p "  Select: " choice
        choice=$(trim "$choice")

        [ -z "$choice" ] && continue

        # Execute action
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
            *)
                show_warning "Invalid selection: '$choice'" 0.5
                ;;
        esac

        # Auto-refresh for most actions
        if [[ ! "$choice" =~ ^[78rRqQ\?hH]$ ]]; then
            auto_refresh
        fi
    done
}
