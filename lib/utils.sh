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
