#!/bin/bash
# ==============================================================================
# Git-AI Manager - Status Display Module
# ==============================================================================

# Display git status and repository information
show_status() {
    print_header

    local branch=$(git branch --show-current 2>/dev/null)
    local branch_type=$(get_branch_type "$branch")
    local sid=$(get_session_id)
    local parent=$(get_parent_branch)

    # Header line: Session | Branch | Type
    local session_display=""
    if [ -n "$sid" ]; then
        local short_sid="${sid:0:8}"
        session_display="${GREEN}●${NC} Session ${DIM}#${short_sid}${NC}"
    else
        session_display="${RED}○${NC} ${DIM}No Session${NC}"
    fi

    local type_display=""
    case "$branch_type" in
        "temporary") type_display="${YELLOW}⚗ Temp${NC}" ;;
        "feature")   type_display="${GREEN}⚙ Feature${NC}" ;;
        "main")      type_display="${CYAN}★ Main${NC}" ;;
        *)           type_display="${DIM}? Unknown${NC}" ;;
    esac

    echo -e "  $session_display  ${DIM}│${NC}  ${BLUE}⎇${NC} ${BOLD}$branch${NC}  ${DIM}│${NC}  $type_display"
    [ "$branch_type" == "temporary" ] && echo -e "  ${DIM}└─ Parent: $parent${NC}"

    echo ""

    # Git Graph
    echo -e "  ${BOLD}${CYAN}┌─ Git Graph ─────────────────────────────────────────────────────────┐${NC}"

    git log --graph --all -10 \
        --color=always \
        --pretty=format:'%C(yellow)%h%C(reset)%C(auto)%d%C(reset) %s' \
        2>/dev/null | \
    sed "s/\*/●/g; s/^/  \x1b[0;36m│\x1b[0m /"

    echo ""
    echo -e "  ${CYAN}│${NC}  ${DIM}⋮${NC}"
    echo -e "  ${BOLD}${CYAN}└──────────────────────────────────────────────────────────────────────┘${NC}"

    echo ""

    # File status (compact)
    local staged=$(git diff --cached --name-only 2>/dev/null)
    local unstaged=$(git diff --name-only 2>/dev/null)
    local untracked=$(git ls-files --others --exclude-standard 2>/dev/null | head -5)

    if [ -n "$staged" ] || [ -n "$unstaged" ] || [ -n "$untracked" ]; then
        if [ -n "$staged" ]; then
            local cnt=$(echo "$staged" | wc -l | tr -d ' ')
            echo -e "  ${GREEN}▶ Staged${NC} ${DIM}($cnt files)${NC}"
            echo "$staged" | head -3 | while read -r file; do
                echo -e "    ${DIM}•${NC} $file"
            done
            [ "$cnt" -gt 3 ] && echo -e "    ${DIM}+$((cnt-3)) more files${NC}"
        fi

        if [ -n "$unstaged" ]; then
            local cnt=$(echo "$unstaged" | wc -l | tr -d ' ')
            echo -e "  ${YELLOW}▷ Modified${NC} ${DIM}($cnt files)${NC}"
            echo "$unstaged" | head -3 | while read -r file; do
                echo -e "    ${DIM}•${NC} $file"
            done
            [ "$cnt" -gt 3 ] && echo -e "    ${DIM}+$((cnt-3)) more files${NC}"
        fi

        if [ -n "$untracked" ]; then
            local cnt=$(echo "$untracked" | wc -l | tr -d ' ')
            echo -e "  ${RED}▸ Untracked${NC} ${DIM}($cnt files)${NC}"
            echo "$untracked" | head -3 | while read -r file; do
                echo -e "    ${DIM}•${NC} $file"
            done
            [ "$cnt" -gt 3 ] && echo -e "    ${DIM}+$((cnt-3)) more files${NC}"
        fi
    else
        echo -e "  ${GREEN}✓${NC} Working tree clean"
    fi

    echo ""
}
