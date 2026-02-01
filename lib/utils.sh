#!/bin/bash
# ==============================================================================
# Git-AI Manager - Utility Functions Module
# ==============================================================================

# Trim whitespace
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

# Print header
print_header() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}          ${BOLD}🤖 Git-AI Manager${NC} ${DIM}v${VERSION}${NC}                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Print divider
print_divider() {
    echo -e "${DIM}──────────────────────────────────────────────────────────────────${NC}"
}

# Show success notification with auto-delay
show_success() {
    local message="$1"
    local delay="${2:-1.5}"
    echo -e "${GREEN}✓${NC} $message"
    sleep "$delay"
}

# Show notification (info)
show_notification() {
    local message="$1"
    local delay="${2:-1}"
    echo -e "${CYAN}ℹ${NC} $message"
    sleep "$delay"
}

# Show warning notification
show_warning() {
    local message="$1"
    local delay="${2:-1.5}"
    echo -e "${YELLOW}⚠${NC} $message"
    sleep "$delay"
}

# Auto refresh (short delay before returning to main menu)
auto_refresh() {
    local delay="${1:-0.8}"
    sleep "$delay"
}

# Wait for any key (non-blocking option)
wait_for_key() {
    local message="${1:-Press any key to continue...}"
    echo ""
    read -n 1 -s -r -p "$message"
    echo ""
}

# Show error box with message
show_error_box() {
    local title="${1:-ERROR}"
    local message="${2:-An error occurred}"
    local tips="${3:-}"

    echo ""
    echo -e "${RED}${DBOX_TL}${DBOX_H} $title ${DBOX_H}$(printf '═%.0s' {1..50})${DBOX_TR}${NC}"
    echo -e "${RED}${DBOX_V}${NC} ${BOLD}${message}${NC}"

    if [ -n "$tips" ]; then
        echo -e "${RED}${DBOX_V}${NC}"
        echo -e "${RED}${DBOX_V}${NC} ${DIM}Tip:${NC}"
        while IFS= read -r tip_line; do
            echo -e "${RED}${DBOX_V}${NC}  • $tip_line"
        done <<< "$tips"
    fi

    echo -e "${RED}${DBOX_BL}$(printf '═%.0s' {1..60})${DBOX_BR}${NC}"
    echo ""
}

# Show info box
show_info_box() {
    local title="${1:-INFO}"
    local content="${2}"

    echo ""
    echo -e "${CYAN}${DBOX_TL}${DBOX_H} $title ${DBOX_H}$(printf '═%.0s' {1..50})${DBOX_TR}${NC}"

    while IFS= read -r line; do
        echo -e "${CYAN}${DBOX_V}${NC} $line"
    done <<< "$content"

    echo -e "${CYAN}${DBOX_BL}$(printf '═%.0s' {1..60})${DBOX_BR}${NC}"
    echo ""
}

# Spinner animation (background job support)
spinner() {
    local pid=$1
    local message="${2:-Processing...}"
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local delay=0.1

    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r${CYAN}%s${NC} %s" "${spinstr:0:1}" "$message"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\r%*s\r" $((${#message} + 5)) ""
}

# Get short session ID (first 8 chars)
get_short_session_id() {
    local sid=$(get_session_id)
    if [ -n "$sid" ]; then
        echo "${sid:0:8}"
    fi
}

# Read arrow key input
read_arrow_key() {
    local key
    IFS= read -rsn1 key 2>/dev/null

    if [[ $key == $'\x1b' ]]; then
        # Read the rest of escape sequence with longer timeout
        IFS= read -rsn2 -t 0.3 key 2>/dev/null
        case $key in
            '[A') echo "up" ;;
            '[B') echo "down" ;;
            '[C') echo "right" ;;
            '[D') echo "left" ;;
            *)
                # Incomplete escape sequence - ignore it
                echo ""
                ;;
        esac
    elif [[ $key == "" ]]; then
        echo "enter"
    else
        echo "$key"
    fi
}
