#!/bin/bash
# ==============================================================================
# Git-AI Manager - Installation Script
# ==============================================================================
#
# Usage:
#   ./install.sh              # Install git-ai
#   ./install.sh --uninstall  # Uninstall git-ai
#
# ==============================================================================

set -e

INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ==============================================================================
# Uninstall Function
# ==============================================================================

uninstall_git_ai() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║          🗑️  Git-AI Manager - Uninstaller                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"

    # Check if git-ai is installed
    if [ ! -L "$INSTALL_DIR/git-ai" ] && [ ! -f "$INSTALL_DIR/git-ai" ]; then
        echo -e "${YELLOW}⚠️  git-ai is not installed in $INSTALL_DIR${NC}"
        echo ""

        # Check other common locations
        local found=false
        for dir in /usr/local/bin /usr/bin "$HOME/.local/bin"; do
            if [ -L "$dir/git-ai" ] || [ -f "$dir/git-ai" ]; then
                echo -e "Found git-ai in: ${CYAN}$dir/git-ai${NC}"
                INSTALL_DIR="$dir"
                found=true
                break
            fi
        done

        if [ "$found" = false ]; then
            echo -e "${RED}❌ git-ai not found${NC}"
            exit 1
        fi
    fi

    # Show what will be removed
    echo -e "${BOLD}The following will be removed:${NC}"
    echo -e "  ${RED}✗${NC} $INSTALL_DIR/git-ai"

    if [ -L "$INSTALL_DIR/git-ai" ]; then
        local target=$(readlink "$INSTALL_DIR/git-ai")
        echo -e "    ${DIM}(symlink to: $target)${NC}"
    fi

    echo ""
    read -e -r -p "Continue with uninstallation? (y/n): " confirm

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo -e "${DIM}Cancelled${NC}"
        exit 0
    fi

    # Determine if sudo is needed
    local NEEDS_SUDO=false
    if [ "$INSTALL_DIR" = "/usr/local/bin" ] || [ "$INSTALL_DIR" = "/usr/bin" ]; then
        NEEDS_SUDO=true
    fi

    # Remove git-ai
    echo ""
    echo -e "${BOLD}Removing git-ai...${NC}"

    if [ "$NEEDS_SUDO" = true ]; then
        sudo rm -f "$INSTALL_DIR/git-ai"
    else
        rm -f "$INSTALL_DIR/git-ai"
    fi

    # Verify removal
    if command -v git-ai &> /dev/null; then
        echo -e "${YELLOW}⚠️  git-ai command still found in PATH${NC}"
        echo -e "   Check other installations: ${CYAN}which git-ai${NC}"
    else
        echo -e "  ${GREEN}✓${NC} git-ai removed"
    fi

    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              ✅ Uninstallation Complete!                  ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${DIM}The git-ai repository has not been deleted.${NC}"
    echo -e "${DIM}To reinstall, run: ${CYAN}./install.sh${NC}"
    echo ""

    exit 0
}

# Check for uninstall flag
if [[ "$1" == "--uninstall" || "$1" == "-u" ]]; then
    uninstall_git_ai
fi

# ==============================================================================
# Install
# ==============================================================================

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          🤖 Git-AI Manager - Installer                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

# ==============================================================================
# Check Dependencies
# ==============================================================================

echo -e "${BOLD}Checking dependencies...${NC}"

if ! command -v git &> /dev/null; then
    echo -e "  ${RED}✗${NC} Git ${RED}(not installed)${NC}"
    echo -e "    Install: ${CYAN}sudo apt install git${NC} or ${CYAN}brew install git${NC}"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Git"

if ! command -v python3 &> /dev/null; then
    echo -e "  ${RED}✗${NC} Python 3 ${RED}(not installed)${NC}"
    echo -e "    Install: ${CYAN}sudo apt install python3${NC} or ${CYAN}brew install python3${NC}"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Python 3"

if ! command -v gemini &> /dev/null; then
    echo -e "  ${YELLOW}⚠${NC} Gemini CLI ${YELLOW}(not found)${NC}"
    echo -e "    Install: ${CYAN}npm install -g @google/gemini-cli${NC}"
    echo -e "    ${YELLOW}Note: git-ai will not work without Gemini CLI${NC}"
    echo ""
else
    echo -e "  ${GREEN}✓${NC} Gemini CLI"
fi

echo ""

# ==============================================================================
# Installation
# ==============================================================================

echo -e "${BOLD}Installing git-ai...${NC}"

# Check if running from git-ai directory
if [ ! -f "$SCRIPT_DIR/git-ai" ] || [ ! -d "$SCRIPT_DIR/lib" ]; then
    echo -e "${RED}❌ Error: Must run from git-ai directory${NC}"
    echo -e "   Expected files:"
    echo -e "     - git-ai (main script)"
    echo -e "     - lib/ (module directory)"
    exit 1
fi

# Determine installation method
if [ "$INSTALL_DIR" = "/usr/local/bin" ] || [ "$INSTALL_DIR" = "/usr/bin" ]; then
    NEEDS_SUDO=true
else
    NEEDS_SUDO=false
fi

# Create install directory
if [ "$NEEDS_SUDO" = true ]; then
    echo -e "  Creating symlink in ${CYAN}$INSTALL_DIR${NC} (requires sudo)..."
    sudo ln -sf "$SCRIPT_DIR/git-ai" "$INSTALL_DIR/git-ai"
else
    echo -e "  Creating symlink in ${CYAN}$INSTALL_DIR${NC}..."
    mkdir -p "$INSTALL_DIR"
    ln -sf "$SCRIPT_DIR/git-ai" "$INSTALL_DIR/git-ai"
fi

# Make executable
chmod +x "$SCRIPT_DIR/git-ai"
chmod +x "$SCRIPT_DIR/lib/"*.sh

echo -e "  ${GREEN}✓${NC} Symlink created: ${CYAN}$INSTALL_DIR/git-ai${NC} → ${CYAN}$SCRIPT_DIR/git-ai${NC}"

# ==============================================================================
# Verify Installation
# ==============================================================================

echo ""
echo -e "${BOLD}Verifying installation...${NC}"

if command -v git-ai &> /dev/null; then
    VERSION=$(git-ai version 2>/dev/null || echo "unknown")
    echo -e "  ${GREEN}✓${NC} git-ai command available (${VERSION})"

    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                 ✅ Installation Complete!                 ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Usage:${NC}"
    echo -e "  ${CYAN}cd your-project${NC}"
    echo -e "  ${CYAN}git-ai${NC}              ${DIM}# Interactive mode${NC}"
    echo -e "  ${CYAN}git-ai init${NC}         ${DIM}# Initialize AI session${NC}"
    echo -e "  ${CYAN}git-ai commit${NC}       ${DIM}# AI-assisted commit${NC}"
    echo -e "  ${CYAN}git-ai review${NC}       ${DIM}# AI code review${NC}"
    echo ""

else
    echo -e "  ${YELLOW}⚠${NC} git-ai not in PATH"
    echo ""
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║              ⚠️  Manual PATH Setup Required               ║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [ "$INSTALL_DIR" = "$HOME/.local/bin" ]; then
        echo -e "Add this to your ${CYAN}~/.bashrc${NC} or ${CYAN}~/.zshrc${NC}:"
        echo -e "  ${CYAN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
        echo ""
        echo -e "Then run: ${CYAN}source ~/.bashrc${NC} (or restart terminal)"
    else
        echo -e "Installation directory: ${CYAN}$INSTALL_DIR${NC}"
        echo -e "Ensure ${CYAN}$INSTALL_DIR${NC} is in your PATH"
    fi
    echo ""
fi

# ==============================================================================
# Uninstall Instructions
# ==============================================================================

echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${DIM}To uninstall: ${NC}${CYAN}./install.sh --uninstall${NC} ${DIM}or${NC} ${CYAN}rm $INSTALL_DIR/git-ai${NC}"
echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
