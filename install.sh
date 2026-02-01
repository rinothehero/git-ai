#!/bin/bash
# ==============================================================================
# Git-AI Manager - Installation Script
# ==============================================================================

set -e

REPO_URL="https://raw.githubusercontent.com/YOUR_USERNAME/git-ai/main/git-ai"
INSTALL_DIR="${HOME}/.local/bin"
SCRIPT_NAME="git-ai"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          🤖 Git-AI Manager - Installer                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check dependencies
echo -e "${CYAN}Checking dependencies...${NC}"

if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed${NC}"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Git"

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed${NC}"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Python 3"

if ! command -v gemini &> /dev/null; then
    echo -e "${YELLOW}⚠️  Gemini CLI not found${NC}"
    echo -e "    Install with: ${CYAN}npm install -g @google/gemini-cli${NC}"
    echo ""
fi

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download script
echo -e "\n${CYAN}Downloading git-ai...${NC}"

if command -v curl &> /dev/null; then
    curl -fsSL "$REPO_URL" -o "${INSTALL_DIR}/${SCRIPT_NAME}"
elif command -v wget &> /dev/null; then
    wget -q "$REPO_URL" -O "${INSTALL_DIR}/${SCRIPT_NAME}"
else
    echo -e "${RED}❌ Neither curl nor wget found${NC}"
    exit 1
fi

# Make executable
chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"

echo -e "${GREEN}✅ Installed to ${INSTALL_DIR}/${SCRIPT_NAME}${NC}"

# Check if in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "\n${YELLOW}⚠️  ${INSTALL_DIR} is not in your PATH${NC}"
    echo -e "    Add this to your shell profile (~/.bashrc or ~/.zshrc):"
    echo -e "    ${CYAN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    echo ""
fi

# Verify installation
if command -v git-ai &> /dev/null; then
    echo -e "\n${GREEN}✅ Installation complete!${NC}"
    echo -e "   Run ${CYAN}git-ai${NC} in any git repository to start."
else
    echo -e "\n${GREEN}✅ Downloaded successfully!${NC}"
    echo -e "   After updating PATH, run ${CYAN}git-ai${NC} in any git repository."
fi

echo ""
