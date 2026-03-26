# Workflow Tips: VS Code + Claude Code

## Your setup

You have three things working together:

- **VS Code** — where you edit files and see your project
- **Claude Code** — an AI assistant inside VS Code that can read, edit, and run commands for you
- **Git/GitHub** — tracks your changes and syncs with your teammate

## How to think about it

```
You (VS Code)  ←→  Claude Code (assistant)  ←→  Git/GitHub (shared code)
       ↕                                              ↕
  Local files                                   Your teammate
```

## Day-to-day workflow

### Starting your day

1. Open VS Code in your project folder
2. Pull the latest changes: `git pull origin main`
3. Make a new branch for what you're working on: `git checkout -b feature/your-task`

### While working

- Edit files in VS Code, ask Claude Code when you need help
- Save often (Ctrl+S), commit often — don't wait until everything is done

### Committing your work

You can do this in the VS Code terminal or ask Claude Code:

```bash
git add .
git commit -m "what you did and why"
git push origin feature/your-task
```

Or just tell Claude Code: "commit my changes and push."

### When you're done with a task

1. Push your branch
2. Open a Pull Request on GitHub
3. Tell your teammate to review it

## Useful habits

- **Keep your terminal open in VS Code** (Ctrl+`) — you can see what Claude Code runs
- **Use the file explorer** (left sidebar) to keep track of what files exist
- **Use source control tab** (left sidebar, branch icon) to see what changed before committing
- **One task per branch** — don't mix unrelated changes
- **Talk to Claude Code like a teammate** — "I want to convert this Stata script to Python, where should I start?"

