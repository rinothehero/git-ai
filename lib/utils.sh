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
