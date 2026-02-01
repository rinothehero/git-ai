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
        local short_sid="${sid:0:6}"
        session_display="${GREEN}●${NC} ${DIM}#${short_sid}${NC}"
    else
        session_display="${RED}○${NC}"
    fi

    local type_display=""
    case "$branch_type" in
        "temporary") type_display="${YELLOW}⚗${NC}" ;;
        "feature")   type_display="${GREEN}⚙${NC}" ;;
        "main")      type_display="${CYAN}★${NC}" ;;
        *)           type_display="${DIM}?${NC}" ;;
    esac

    echo -e "$session_display ${DIM}│${NC} ${BLUE}⎇${NC}${BOLD}$branch${NC} ${DIM}│${NC} $type_display"

    echo ""

    # Git Graph (compact with truncated messages)
    local term_width=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}
    local max_msg_len=$((term_width - 15))  # Reserve space for graph + hash
    [ "$max_msg_len" -lt 20 ] && max_msg_len=20

    echo -e "${DIM}┌ Graph ───────────────────────────┐${NC}"
    git log --graph --all -5 \
        --color=always \
        --pretty=format:'%C(yellow)%h%C(reset)%C(auto)%d%C(reset) %s' \
        2>/dev/null | \
    sed "s/\*/●/g" | \
    while IFS= read -r line; do
        # Truncate commit message if too long
        if [ "${#line}" -gt "$term_width" ]; then
            echo "${line:0:$((term_width-3))}..."
        else
            echo "$line"
        fi
    done | \
    sed "s/^/${DIM}│${NC} /" | head -5
    echo -e "${DIM}└──────────────────────────────────┘${NC}"
    echo ""

    # File status (compact)
    local staged=$(git diff --cached --name-only 2>/dev/null)
    local unstaged=$(git diff --name-only 2>/dev/null)
    local untracked=$(git ls-files --others --exclude-standard 2>/dev/null | head -5)

    if [ -n "$staged" ] || [ -n "$unstaged" ] || [ -n "$untracked" ]; then
        if [ -n "$staged" ]; then
            local cnt=$(echo "$staged" | wc -l | tr -d ' ')
            local files=$(echo "$staged" | head -2 | tr '\n' ' ')
            echo -e "${GREEN}▶${NC} Staged($cnt): ${DIM}${files}${NC}$([ "$cnt" -gt 2 ] && echo "...")"
        fi

        if [ -n "$unstaged" ]; then
            local cnt=$(echo "$unstaged" | wc -l | tr -d ' ')
            local files=$(echo "$unstaged" | head -2 | tr '\n' ' ')
            echo -e "${YELLOW}▷${NC} Modified($cnt): ${DIM}${files}${NC}$([ "$cnt" -gt 2 ] && echo "...")"
        fi

        if [ -n "$untracked" ]; then
            local cnt=$(echo "$untracked" | wc -l | tr -d ' ')
            local files=$(echo "$untracked" | head -2 | tr '\n' ' ')
            echo -e "${RED}▸${NC} Untracked($cnt): ${DIM}${files}${NC}$([ "$cnt" -gt 2 ] && echo "...")"
        fi
    else
        echo -e "${GREEN}✓${NC} Working tree clean"
    fi

    echo ""
}
