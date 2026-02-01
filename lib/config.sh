#!/bin/bash
# ==============================================================================
# Git-AI Manager - Configuration Module
# ==============================================================================

# Version
VERSION="2.3.0"

# File paths
SESSION_FILE=".git/GEMINI_SESSION_ID"
PARENT_BRANCH_FILE=".git/GIT_AI_PARENT_BRANCH"

# Commands
GEMINI_CMD="${GEMINI_CMD:-gemini}"

# Branch type patterns
TEMP_BRANCH_PATTERN="^(test|temp|debug|exp|experiment)/"
FEATURE_BRANCH_PATTERN="^(feat|feature|fix|hotfix|refactor|chore|docs)/"
MAIN_BRANCH_PATTERN="^(main|master)$"

# ==============================================================================
# Colors & Formatting
# ==============================================================================

# Standard colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[0;37m'

# Bright colors
BRIGHT_RED='\033[1;31m'
BRIGHT_GREEN='\033[1;32m'
BRIGHT_YELLOW='\033[1;33m'
BRIGHT_BLUE='\033[1;34m'
BRIGHT_CYAN='\033[1;36m'
BRIGHT_MAGENTA='\033[1;35m'

# Formatting
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
NC='\033[0m'

# Unicode box drawing characters
BOX_H="─"
BOX_V="│"
BOX_TL="┌"
BOX_TR="┐"
BOX_BL="└"
BOX_BR="┘"
BOX_VR="├"
BOX_VL="┤"
BOX_HU="┴"
BOX_HD="┬"
BOX_VH="┼"
