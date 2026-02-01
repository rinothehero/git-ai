#!/bin/bash
# ==============================================================================
# Git-AI Manager - Configuration Module
# ==============================================================================

# Version
VERSION="2.4.0"

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
REVERSE='\033[7m'
NC='\033[0m'

# Background colors
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

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

# Double-line box characters
DBOX_H="═"
DBOX_V="║"
DBOX_TL="╔"
DBOX_TR="╗"
DBOX_BL="╚"
DBOX_BR="╝"
DBOX_VR="╠"
DBOX_VL="╣"
DBOX_HU="╩"
DBOX_HD="╦"
DBOX_VH="╬"

# Menu configuration
MENU_ITEMS=(
    "1:Stage All:action_stage_all:quick"
    "2:Unstage:action_unstage_all:quick"
    "3:Uncommit:action_uncommit:quick"
    "4:Stash:action_stash_menu:quick"
    "5:Branch:action_switch_branch:quick"
    "6:Push:action_push:quick"
    "7:Log:action_show_log:quick"
    "8:Diff:action_show_diff:quick"
    "9:Discard:action_discard_changes:quick"
    "i:Init AI:action_init:ai"
    "c:AI Commit:action_ai_commit:ai"
    "v:Review:action_ai_review:ai"
    "f:Finish:action_finish:workflow"
    "r:Refresh::system"
    "q:Quit::system"
    "?:Help:show_help:system"
)
