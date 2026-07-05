---
name: doctor
description: Diagnose and fix issues in the AI dotfiles harness — broken symlinks, missing tools, upstream updates.
disable-model-invocation: false
---

# /dotai:doctor

Run a full health check on the AI dotfiles harness. Identify what's broken and suggest fixes.

## Phase 1: Diagnose

### 1.1 Harness integrity
- Run `just smoke-test`. If it fails, report which checks failed.
- Run `just validate`. Report errors vs warnings separately.

### 1.2 Symlink health
- Check `~/.claude/skills/dotai/` exists and all symlinks resolve.
- Check `~/.config/opencode/` symlinks resolve (AGENTS.md, opencode.json, rules, agents).
- Check tools in `~/.local/bin/` resolve.
- Report any broken symlinks with the exact path.

### 1.3 Git state
- Run `git status --short` in the dotfiles repo. Report uncommitted changes.
- Run `git remote -v` to confirm origin is set.
- Run `git fetch origin --dry-run 2>/dev/null || true` and check for new commits:
  - `git log HEAD..origin/HEAD --oneline` — new upstream commits available.
- If upstream commits exist, list them with dates and suggest review.

### 1.4 Tool availability
- Check each tool symlinked to `~/.local/bin/` exists and is executable.
- Verify `~/.local/bin` is on `$PATH`.
- Check `just` is installed.
- Check `npx` and `python3` are available.

### 1.5 Environment
- Check key env vars from `.env.example`: `ANTHROPIC_API_KEY`, `GITHUB_TOKEN`.
- List which are set and which are missing.
- For optional MCP servers in `mcp/available/`, check their required env vars.

## Phase 2: Fix

For each issue found, offer to fix or provide the exact command:

| Issue | Fix |
|---|---|
| Broken symlink | `just install` to re-link |
| Missing tool | `brew install <tool>` or `npm install -g <pkg>` |
| Outdated harness | `git pull` (if no local changes) or `git stash && git pull && git stash pop` |
| Missing env var | Set in `.env` or `export VAR=value` |
| Invalid JSON | Fix syntax error at reported path |
| Uncommitted changes | `git diff` to review, `git add -A && git commit` |

## Output format

```markdown
## DotAI Health Report

### Critical (broken — must fix)
- [ ] ...

### Warnings (should fix)
- [ ] ...

### Upstream
- 🔄 N new commits available since last pull:
  - [sha] message (date)
- Review with: git log HEAD..origin/HEAD -p

### Environment
- ✅ Variable    ❌ Missing

### Recommendation
[Summary: what to fix first, risk level]
```

## Constraints

- Do NOT run `git pull` or modify files without asking first.
- Do NOT modify the user's `.env` file — suggest, don't write secrets.
- If smoke-test passes, say "Harness is healthy" and skip Phase 2.
- If upstream has >5 new commits, flag it for careful review.
