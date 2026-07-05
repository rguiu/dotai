---
name: handoff
description: Capture current terminal session state (git, tmux, env) into a portable markdown block for seamless session handoffs.
disable-model-invocation: true
---

# /handoff

Compress the current session into a structured handoff that can be pasted into a new AI agent window on any machine. Use when closing a terminal, switching machines, or handing work to a fresh session.

## What to capture

1. **Git state** — run `git status --short`, `git diff --stat`, `git log --oneline -5`. Include the current branch.
2. **Tmux context** — if running inside tmux, capture the last 100 lines of the current pane's scrollback. Run `tmux capture-pane -p -S -100 2>/dev/null || true`.
3. **Working directory** — current `pwd` and its relationship to the git root.
4. **Environment** — key env vars: `OPENCODE_MODEL`, Python venv status, Node version, any container status.

## Output format

```markdown
## Session Handoff — {YYYY-MM-DD HH:MM}

**Project**: {repo name} ({branch})
**Directory**: {pwd}
**Key env**: {relevant vars or "—"}

### Active work
- [Current task description inferred from context]
- [Remaining steps]

### Git state
```
{git status --short}
```

### Uncommitted changes
```
{git diff --stat}
```

### Recent commits
```
{git log --oneline -5}
```

### Terminal context (last 100 lines)
```
{tmux scrollback if available}
```

### Next steps
- [ ] {immediate action 1}
- [ ] {immediate action 2}
```

## Constraints

- If no tmux is running, omit that section — don't fabricate it.
- If there are no uncommitted changes, say "Working tree clean."
- Keep the handoff under 200 lines total. Truncate long diffs and scrollback.
- Do NOT create or modify files unless the user explicitly asks to save the handoff.
