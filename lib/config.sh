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

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'
