#!/bin/bash
# ==============================================================================
# Git-AI Manager - Session Management Module
# ==============================================================================

# Get current session ID
get_session_id() {
    if [ -f "$SESSION_FILE" ]; then
        local sid=$(cat "$SESSION_FILE" 2>/dev/null)
        if [[ "$sid" =~ ^[0-9]+$ ]]; then
            echo "$sid"
        else
            rm -f "$SESSION_FILE"
            echo ""
        fi
    else
        echo ""
    fi
}

# Sync context to AI (background, no output)
sync_context() {
    local message="$1"
    local sid=$(get_session_id)

    if [ -n "$sid" ]; then
        ($GEMINI_CMD --resume "$sid" --prompt "[CONTEXT UPDATE] $message. Reply only: 'Noted.'" > /dev/null 2>&1 &)
    fi
}
