#!/bin/bash
# ==============================================================================
# Git-AI Manager - AI Actions Module
# ==============================================================================

# Initialize AI session with project context
action_init() {
    echo -e "\n${CYAN}🔍 Collecting project context...${NC}"

    local files=$(git ls-files | head -n 30)
    local logs=$(git log -n 5 --pretty=format:'%s' 2>/dev/null)
    local readme=""
    [ -f "README.md" ] && readme=$(head -c 1000 README.md)

    local prompt="System Context:
[Files]: $files
[Logs]: $logs
[Readme]: $readme

ROLE: You are the Tech Lead & Git Maintainer of this project.

RULES:
1. Understand the project structure and tech stack
2. All git messages follow Conventional Commits (type(scope): description)
3. Respond in the same language as the user
4. Be concise and actionable

Confirm you understood the project with a brief summary (2-3 sentences) in Korean."

    echo -e "${CYAN}🤖 Initializing AI session...${NC}\n"

    local response=$($GEMINI_CMD --prompt "$prompt" 2>&1)

    # Extract session ID from session list (most recent)
    local sid=$($GEMINI_CMD --list-sessions 2>&1 | grep '^\s*[0-9]\+\.' | tail -1 | grep -oE '\[[0-9a-f-]{36}\]' | tr -d '[]')

    if [ -n "$sid" ]; then
        echo "$sid" > "$SESSION_FILE"
        echo -e "${GREEN}✅ Session created${NC}"
        echo -e "${DIM}Session ID: ${sid:0:8}...${NC}\n"
        # Show AI response (filter out debug lines)
        echo "$response" | grep -v "^Loaded cached credentials" | grep -v "^Hook registry"
    else
        show_error_box "SESSION FAILED" "Failed to create AI session" "Check if Gemini CLI is installed: gemini --version\nAuthenticate if needed: gemini auth\nCheck network connection"
        echo -e "\n${DIM}Raw output:${NC}"
        echo "$response"
        sleep 1
        return 1
    fi
}

# AI code review
action_ai_review() {
    local sid=$(get_session_id)

    if [ -z "$sid" ]; then
        show_error_box "NO SESSION" "No active AI session" "Use [i] Init AI to create a session first"
        sleep 1
        return 1
    fi

    local diff=$(git diff --cached 2>/dev/null)
    [ -z "$diff" ] && diff=$(git diff 2>/dev/null)

    if [ -z "$diff" ]; then
        show_warning "No changes to review" 1
        return 1
    fi

    local query="Please review this code change:

\`\`\`diff
$diff
\`\`\`

Review for:
1. 🐛 Bugs & Errors
2. 🔒 Security Issues
3. ⚡ Performance
4. 📝 Code Quality
5. 💡 Suggestions

Be concise. Use Korean."

    echo -e "\n${CYAN}🤖 AI is reviewing changes...${NC}\n"
    print_divider

    $GEMINI_CMD --resume "$sid" --prompt "$query"

    print_divider
    sync_context "User requested code review"
}

# AI-assisted commit
action_ai_commit() {
    local sid=$(get_session_id)

    if [ -z "$sid" ]; then
        show_error_box "NO SESSION" "No active AI session" "Use [i] Init AI to create a session first"
        sleep 1
        return 1
    fi

    local staged=$(git diff --cached --name-only 2>/dev/null)
    if [ -z "$staged" ]; then
        show_warning "No staged changes - use [1] Stage All first" 1
        return 1
    fi

    local branch=$(git branch --show-current)
    local branch_type=$(get_branch_type "$branch")
    local diff=$(git diff --cached)

    echo -e "\n${CYAN}🤖 Session #$sid is analyzing changes...${NC}"

    local query="Analyze this staged change:

Branch: $branch (type: $branch_type)

\`\`\`diff
$diff
\`\`\`

Decide:
- If experimental/test code → suggest creating test/ branch
- If feature implementation → commit on current branch
- If on main with feature code → suggest feat/ branch

OUTPUT JSON ONLY:
{
  \"analysis\": \"Brief analysis in Korean (1 sentence)\",
  \"action\": \"commit\" or \"branch\",
  \"branch_name\": \"prefix/name if action is branch\",
  \"commit_message\": \"conventional commit message in English\"
}"

    local response=$($GEMINI_CMD --resume "$sid" --prompt "$query" 2>/dev/null)

    local parsed=$(python3 -c "
import sys, json, re
try:
    raw = sys.stdin.read()
    raw = re.sub(r'\`\`\`json|\`\`\`', '', raw).strip()
    data = json.loads(raw)
    print(json.dumps(data))
except:
    print('PARSE_ERROR')
" <<< "$response")

    if [[ "$parsed" == "PARSE_ERROR" ]]; then
        show_error_box "PARSE ERROR" "Failed to parse AI response" "AI returned invalid JSON format\nTry again or check your session"
        echo -e "\n${DIM}Raw response:${NC}\n$response"
        sleep 1.5
        return 1
    fi

    local analysis=$(echo "$parsed" | python3 -c "import sys,json; print(json.load(sys.stdin).get('analysis',''))")
    local action=$(echo "$parsed" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','commit'))")
    local ai_branch=$(echo "$parsed" | python3 -c "import sys,json; print(json.load(sys.stdin).get('branch_name',''))")
    local ai_msg=$(echo "$parsed" | python3 -c "import sys,json; print(json.load(sys.stdin).get('commit_message',''))")

    echo ""
    print_divider
    echo -e "  ${BOLD}🧐 Analysis:${NC} $analysis"
    echo -e "  ${BOLD}📝 Message:${NC} ${CYAN}$ai_msg${NC}"

    if [ "$action" == "branch" ]; then
        echo -e "  ${BOLD}🌿 Suggest:${NC} ${GREEN}[New Branch]${NC} → $ai_branch"
        echo -e "  ${DIM}   (from '$branch')${NC}"
    else
        echo -e "  ${BOLD}🚀 Suggest:${NC} ${GREEN}[Commit on current branch]${NC}"
    fi
    print_divider
    echo ""

    # Confirmation loop with retry options
    while true; do
        read -e -r -p "👉 Execute? (y/n): " confirm

        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            if [ "$action" == "branch" ]; then
                save_parent_branch "$branch"
                git checkout -b "$ai_branch" 2>/dev/null || git checkout "$ai_branch"
                echo -e "${GREEN}✅ Branch '$ai_branch' created (parent: $branch)${NC}"
            fi
            git commit -m "$ai_msg"
            echo -e "${GREEN}✅ Committed${NC}"

            # Offer push
            echo ""
            read -e -r -p "📤 Push to remote? (y/n): " push_confirm
            if [[ "$push_confirm" == "y" || "$push_confirm" == "Y" ]]; then
                local push_branch=$(git branch --show-current)
                local remote_exists=$(git ls-remote --heads origin "$push_branch" 2>/dev/null)

                if [ -z "$remote_exists" ]; then
                    git push -u origin "$push_branch"
                else
                    git push
                fi
                echo -e "${GREEN}✅ Pushed${NC}"
            fi
            break
        else
            # Offer alternatives
            echo ""
            echo -e "  ${BOLD}Alternative options:${NC}"
            echo -e "    ${YELLOW}1)${NC} 🧪 temp/ branch"
            echo -e "    ${YELLOW}2)${NC} 🔬 test/ branch"
            echo -e "    ${YELLOW}3)${NC} 🚀 feat/ branch"
            echo -e "    ${YELLOW}4)${NC} 🔧 fix/ branch"
            echo -e "    ${YELLOW}5)${NC} 📝 Commit on current branch"
            echo -e "    ${DIM}6)${NC} ✏️  Custom input"
            echo -e "    ${DIM}0)${NC} Cancel"
            echo ""

            read -e -r -p "  Select: " retry

            case "$retry" in
                1) local prefix="temp" ;;
                2) local prefix="test" ;;
                3) local prefix="feat" ;;
                4) local prefix="fix" ;;
                5)
                    action="commit"
                    echo ""
                    print_divider
                    echo -e "  ${BOLD}🚀 Suggest:${NC} ${GREEN}[Commit on current branch]${NC}"
                    echo -e "  ${BOLD}📝 Message:${NC} ${CYAN}$ai_msg${NC}"
                    print_divider
                    echo ""
                    continue
                    ;;
                6)
                    read -e -r -p "  Branch name (e.g. temp/my-test): " custom
                    if [ -n "$custom" ]; then
                        action="branch"
                        ai_branch="$custom"
                        echo ""
                        print_divider
                        echo -e "  ${BOLD}🌿 Suggest:${NC} ${GREEN}[New Branch]${NC} → $ai_branch"
                        echo -e "  ${BOLD}📝 Message:${NC} ${CYAN}$ai_msg${NC}"
                        print_divider
                        echo ""
                    fi
                    continue
                    ;;
                0|*)
                    echo -e "${DIM}Cancelled${NC}"
                    break
                    ;;
            esac

            # Re-ask AI with new prefix
            echo -e "\n${CYAN}🤖 Re-suggesting with '$prefix/' prefix...${NC}"

            local retry_query="User rejected. Re-suggest with '$prefix/' prefix.
OUTPUT JSON ONLY:
{
  \"analysis\": \"Brief acknowledgment in Korean\",
  \"action\": \"branch\",
  \"branch_name\": \"$prefix/descriptive-name\",
  \"commit_message\": \"conventional commit message\"
}"

            response=$($GEMINI_CMD --resume "$sid" --prompt "$retry_query" 2>/dev/null)

            parsed=$(python3 -c "
import sys, json, re
try:
    raw = sys.stdin.read()
    raw = re.sub(r'\`\`\`json|\`\`\`', '', raw).strip()
    data = json.loads(raw)
    print(json.dumps(data))
except:
    print('PARSE_ERROR')
" <<< "$response")

            if [[ "$parsed" == "PARSE_ERROR" ]]; then
                show_warning "Failed to parse AI response - cancelling" 1
                break
            fi

            analysis=$(echo "$parsed" | python3 -c "import sys,json; print(json.load(sys.stdin).get('analysis',''))")
            action=$(echo "$parsed" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','branch'))")
            ai_branch=$(echo "$parsed" | python3 -c "import sys,json; print(json.load(sys.stdin).get('branch_name',''))")
            ai_msg=$(echo "$parsed" | python3 -c "import sys,json; print(json.load(sys.stdin).get('commit_message',''))")

            echo ""
            print_divider
            echo -e "  ${BOLD}🧐 Analysis:${NC} $analysis"
            echo -e "  ${BOLD}📝 Message:${NC} ${CYAN}$ai_msg${NC}"
            echo -e "  ${BOLD}🌿 Suggest:${NC} ${GREEN}[New Branch]${NC} → $ai_branch"
            echo -e "  ${DIM}   (from '$branch')${NC}"
            print_divider
            echo ""
        fi
    done
}
