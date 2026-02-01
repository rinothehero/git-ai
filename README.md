# 🤖 Git-AI Manager

AI-powered Git workflow automation using Google Gemini CLI.

![Version](https://img.shields.io/badge/version-2.3.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Bash](https://img.shields.io/badge/bash-5.0+-orange)

## ✨ Features

- **AI-Assisted Commits** - Analyzes your changes and suggests appropriate commit messages following Conventional Commits
- **Smart Branch Management** - Auto-detects branch types (feature/test/temp) and handles workflows accordingly
- **Code Review** - Get AI-powered code review for bugs, security, performance issues
- **Visual Git Graph** - See your repository structure at a glance
- **Stash Management** - Full stash submenu with save/pop/apply/drop/clear
- **Context Persistence** - AI remembers your project context across sessions

## 📦 Installation

### Quick Install (curl)

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/git-ai/main/install.sh | bash
```

### Manual Install

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/git-ai.git

# Make executable and add to PATH
chmod +x git-ai/git-ai
sudo ln -s $(pwd)/git-ai/git-ai /usr/local/bin/git-ai

# Or copy to your bin directory
cp git-ai/git-ai ~/.local/bin/
```

## 🔧 Requirements

- **Git** (2.0+)
- **Gemini CLI** - [Installation Guide](https://github.com/google-gemini/gemini-cli)
- **Python 3** (for JSON parsing)
- **Bash** (5.0+)

### Installing Gemini CLI

```bash
npm install -g @anthropic-ai/gemini-cli
# or
brew install gemini-cli
```

## 🚀 Usage

### Interactive Mode (Recommended)

```bash
cd your-project
git-ai
```

### CLI Commands

```bash
git-ai init      # Initialize AI session with project context
git-ai commit    # AI-assisted commit
git-ai review    # AI code review
git-ai finish    # Complete branch workflow
git-ai status    # Show status (non-interactive)
git-ai help      # Show help
```

## 📖 Workflow Guide

### Branch Naming Convention

Git-AI automatically detects branch types based on prefixes:

| Prefix | Type | Finish Behavior |
|--------|------|-----------------|
| `test/`, `temp/`, `debug/`, `exp/` | Temporary | Ask success/fail → merge or delete |
| `feat/`, `fix/`, `refactor/`, `docs/` | Feature | Merge to main with `--no-ff` |
| `main`, `master` | Main | Cannot finish |

### Typical Workflow

```
1. Start on main
   └── git-ai → 'c' (AI Commit)
       └── AI suggests: "This looks experimental, create test/xxx?"
           └── Accept → creates test/xxx branch
           
2. Work on test/xxx
   └── Make changes, commit with AI
   
3. Finish testing
   └── git-ai → 'f' (Finish)
       └── "Test result?" → Success
           └── "Merge to main?" → Yes
               └── Merged & branch deleted
```

## ⌨️ Key Bindings

### Quick Actions

| Key | Action | Git Command |
|-----|--------|-------------|
| `1` | Stage All | `git add -A` |
| `2` | Unstage | `git reset HEAD` |
| `3` | Uncommit | `git reset --soft HEAD~1` |
| `4` | Stash Menu | Submenu |
| `5` | Switch Branch | `git checkout` |
| `6` | Push | `git push` |
| `7` | Show Log | `git log --graph` |
| `8` | Show Diff | `git diff` |
| `9` | Discard All | `git checkout -- . && git clean -fd` |

### AI Actions

| Key | Action | Description |
|-----|--------|-------------|
| `i` | Init AI | Load project context into Gemini |
| `v` | Review | AI code review of staged/unstaged changes |
| `c` | Commit | AI analyzes and suggests commit/branch |

### Workflow

| Key | Action | Description |
|-----|--------|-------------|
| `f` | Finish | Complete branch workflow |
| `r` | Refresh | Refresh display |
| `q` | Quit | Exit |
| `?` | Help | Show help |

## 🎨 Screenshots

```
╔══════════════════════════════════════════════════════════════╗
║          🤖 Git-AI Manager v2.3.0                            ║
╚══════════════════════════════════════════════════════════════╝

  ● Session #8  │  ⎇ feat/new-feature  │  ⚙ Feature

  ┌─ Git Graph ─────────────────────────────────────────────────────────┐
  │ ● abc1234 (HEAD -> feat/new-feature) feat: add new feature
  │ ● def5678 (main) fix: previous bug fix
  │ ● ghi9012 (origin/main) initial commit
  │  ⋮
  └──────────────────────────────────────────────────────────────────────┘

  Changes
  ▶ Staged (2): src/main.py src/utils.py 

  Quick Actions                          AI Actions ●              Workflow
  ─────────────────────────────────────────────────────────────────────────────
   1 Stage All    4 Stash 📋   7 Log       i Init AI       v Review       f Finish
   2 Unstage     5 Branch     8 Diff      c AI Commit
   3 Uncommit    6 Push       9 Discard
  ─────────────────────────────────────────────────────────────────────────────
   r Refresh     q Quit       ? Help

  Select: 
```

## ⚙️ Configuration

Git-AI stores session data in your `.git` directory:

- `.git/GEMINI_SESSION_ID` - Current AI session ID
- `.git/GIT_AI_PARENT_BRANCH` - Parent branch for temp branches

### Environment Variables

```bash
# Custom Gemini command (default: gemini)
export GEMINI_CMD="gemini"
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feat/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feat/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Gemini CLI](https://github.com/google-gemini/gemini-cli) - AI backend
- [Conventional Commits](https://www.conventionalcommits.org/) - Commit message standard

---

Made with ❤️ and 🤖
