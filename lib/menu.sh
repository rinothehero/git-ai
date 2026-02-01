#!/bin/bash
# ==============================================================================
# Git-AI Manager - Menu & Main Loop Module
# ==============================================================================

# Menu items configuration
declare -a MENU_KEYS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "i" "c" "v" "f" "r" "q" "?")
declare -A MENU_LABELS=(
    ["1"]="Stage All"
    ["2"]="Unstage"
    ["3"]="Uncommit"
    ["4"]="Stash 📋"
    ["5"]="Branch"
    ["6"]="Push"
    ["7"]="Log"
    ["8"]="Diff"
    ["9"]="Discard"
    ["i"]="Init AI"
    ["c"]="AI Commit"
    ["v"]="Review"
    ["f"]="Finish"
    ["r"]="Refresh"
    ["q"]="Quit"
    ["?"]="Help"
)

declare -A MENU_CATEGORIES=(
    ["1"]="quick"
    ["2"]="quick"
    ["3"]="quick"
    ["4"]="tools"
    ["5"]="tools"
    ["6"]="tools"
    ["7"]="tools"
    ["8"]="tools"
    ["9"]="danger"
    ["i"]="ai"
    ["c"]="ai"
    ["v"]="ai"
    ["f"]="workflow"
    ["r"]="system"
    ["q"]="system"
    ["?"]="system"
)

# Show interactive menu with navigation
show_menu() {
    local selected="${1:-0}"
    local sid=$(get_session_id)
    local status="${RED}○${NC}"
    [ -n "$sid" ] && status="${GREEN}●${NC}"

    echo -e "  ${BOX_TL}${BOX_H} ${BOLD}Quick Actions${NC} ${BOX_H}${BOX_HD}${BOX_H} ${BOLD}AI Actions${NC} $status ${BOX_H}${BOX_HD}${BOX_H} ${BOLD}Workflow${NC} ${BOX_H}${BOX_TR}"

    # Row 1
    local row1_items=("1" "4" "7" "i" "v" "f")
    echo -n "  ${BOX_V} "
    for idx in "${!row1_items[@]}"; do
        local key="${row1_items[$idx]}"
        local label="${MENU_LABELS[$key]}"
        local display="[$key] $label"

        if [ "$selected" -eq "$((idx))" ]; then
            echo -ne "${REVERSE}${BOLD} $display ${NC}"
        else
            echo -ne "${BOLD}$key${NC} $label"
        fi

        # Add separators
        if [ "$idx" -eq 0 ]; then
            echo -n "   ${BOX_V} "
        elif [ "$idx" -eq 2 ]; then
            echo -n "   ${BOX_V} "
        elif [ "$idx" -eq 3 ]; then
            echo -n "   "
        elif [ "$idx" -eq 4 ]; then
            echo -n "   ${BOX_V} "
        elif [ "$idx" -lt 5 ]; then
            echo -n "   "
        fi
    done
    echo -e "  ${BOX_V}"

    # Row 2
    local row2_items=("2" "5" "8" "c" "" "")
    echo -n "  ${BOX_V} "
    for idx in "${!row2_items[@]}"; do
        local key="${row2_items[$idx]}"
        if [ -z "$key" ]; then
            [ "$idx" -eq 4 ] && echo -n "           "
            [ "$idx" -eq 5 ] && echo -n "           "
            continue
        fi
        local label="${MENU_LABELS[$key]}"
        local display="[$key] $label"

        if [ "$selected" -eq "$((6 + idx))" ]; then
            echo -ne "${REVERSE}${BOLD} $display ${NC}"
        else
            echo -ne "${BOLD}$key${NC} $label"
        fi

        # Add separators
        if [ "$idx" -eq 0 ]; then
            echo -n "      ${BOX_V} "
        elif [ "$idx" -eq 2 ]; then
            echo -n "    ${BOX_V} "
        elif [ "$idx" -lt 3 ]; then
            echo -n "      "
        fi
    done
    echo -e " ${BOX_V}"

    # Row 3
    local row3_items=("3" "6" "9" "" "" "")
    echo -n "  ${BOX_V} "
    for idx in "${!row3_items[@]}"; do
        local key="${row3_items[$idx]}"
        if [ -z "$key" ]; then
            [ "$idx" -eq 3 ] && echo -n "           "
            [ "$idx" -eq 4 ] && echo -n "           "
            [ "$idx" -eq 5 ] && echo -n "           "
            continue
        fi
        local label="${MENU_LABELS[$key]}"
        local display="[$key] $label"

        # Highlight dangerous actions
        if [ "$key" == "9" ]; then
            if [ "$selected" -eq "$((12 + idx))" ]; then
                echo -ne "${REVERSE}${BOLD} $display ${NC}"
            else
                echo -ne "${BOLD}$key${NC} ${RED}$label${NC}"
            fi
        else
            if [ "$selected" -eq "$((12 + idx))" ]; then
                echo -ne "${REVERSE}${BOLD} $display ${NC}"
            else
                echo -ne "${BOLD}$key${NC} $label"
            fi
        fi

        # Add separators
        if [ "$idx" -eq 0 ]; then
            echo -n "     ${BOX_V} "
        elif [ "$idx" -eq 2 ]; then
            echo -n "  ${BOX_V} "
        elif [ "$idx" -lt 2 ]; then
            echo -n "       "
        fi
    done
    echo -e " ${BOX_V}"

    echo -e "  ${BOX_VR}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_VL}"

    # Bottom row: System actions
    echo -n "  ${BOX_V} "
    local bottom_items=("r" "q" "?")
    for idx in "${!bottom_items[@]}"; do
        local key="${bottom_items[$idx]}"
        local label="${MENU_LABELS[$key]}"
        local display="[$key] $label"

        if [ "$selected" -eq "$((18 + idx))" ]; then
            echo -ne "${REVERSE}${BOLD} $display ${NC}"
        else
            echo -ne "${BOLD}$key${NC} $label"
        fi

        [ "$idx" -lt 2 ] && echo -n "     "
    done
    echo -e "                                             ${BOX_V}"

    echo -e "  ${BOX_BL}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_BR}"

    echo -e "\n  ${DIM}Use arrow keys to navigate, Enter to select, or type the key directly${NC}"
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

# Map selection index to key
get_key_from_index() {
    local idx=$1
    local keys=("1" "4" "7" "i" "v" "f" "2" "5" "8" "c" "" "" "3" "6" "9" "" "" "" "r" "q" "?")
    echo "${keys[$idx]}"
}

# Main interactive loop
main_loop() {
    local selected=0
    local total_items=21  # Total navigable positions

    while true; do
        show_status
        show_menu "$selected"

        # Read input (arrow keys or direct key)
        local input=$(read_arrow_key)

        case "$input" in
            "up")
                # Move up in grid
                if [ "$selected" -ge 6 ]; then
                    selected=$((selected - 6))
                fi
                continue
                ;;
            "down")
                # Move down in grid
                if [ "$selected" -lt 15 ]; then
                    selected=$((selected + 6))
                    [ "$selected" -gt 20 ] && selected=18
                fi
                continue
                ;;
            "left")
                # Move left
                if [ "$selected" -gt 0 ]; then
                    selected=$((selected - 1))
                    # Skip empty cells
                    while [ "$selected" -ge 0 ]; do
                        local key=$(get_key_from_index "$selected")
                        [ -n "$key" ] && break
                        selected=$((selected - 1))
                    done
                    [ "$selected" -lt 0 ] && selected=0
                fi
                continue
                ;;
            "right")
                # Move right
                if [ "$selected" -lt 20 ]; then
                    selected=$((selected + 1))
                    # Skip empty cells
                    while [ "$selected" -le 20 ]; do
                        local key=$(get_key_from_index "$selected")
                        [ -n "$key" ] && break
                        selected=$((selected + 1))
                    done
                    [ "$selected" -gt 20 ] && selected=20
                fi
                continue
                ;;
            "enter")
                # Execute selected item
                local choice=$(get_key_from_index "$selected")
                ;;
            *)
                # Direct key input
                choice="$input"
                ;;
        esac

        # Trim and validate choice
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
            r|R) selected=0; continue ;;
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

        # Reset selection after action
        selected=0
    done
}
