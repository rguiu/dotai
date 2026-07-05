# AI Dotfiles

Terminal-native configuration for Claude Code & OpenCode

<!-- end_slide -->

## Problem

```
❌ Inconsistent AI behavior across projects
❌ Duplicated rules in every Cursor rule file
❌ No way to carry your standards across tools
❌ Secret keys scattered across config files
❌ "Wait, did I add the linter step?"
```

<!-- end_slide -->

## Solution

One source of truth for *your* engineering standards.

```bash
ai/
├── skills/dotai/     # 8 namespaced slash commands
├── rules/             # Language-specific conventions
├── claude/CLAUDE.md   # Global rules (single source)
├── opencode/          # Config + subagents
├── mcp/               # Server configs (active + optional)
├── tools/             # 9 token-efficiency + maintenance
├── hooks/             # Pre-commit secrets guard
├── defaults/          # Profile templates
└── justfile           # 14 commands
```

<!-- end_slide -->

## Install

```bash
# First time: configure
just init
#    → Saves profile, tools, languages to ~/.dotai/config.json

# Then deploy
just install
# What it does:
# ✓ OpenCode skills → ~/.config/opencode/skills/dotai-*/
# ✓ Claude skills → .claude/skills/dotai/<name>/
# ✓ Agents → ~/.config/opencode/agents/dotai-*.md
# ✓ Rules → ~/.config/opencode/rules/
# ✓ AGENTS.md → ~/.config/opencode/AGENTS.md (shared with CLAUDE.md)
# ✓ Tools → ~/.local/bin/
# ✓ SessionStart hook → ~/.claude/settings.json (merged)
# ✓ Preserves all existing files
```

<!-- end_slide -->

## Verify

```bash
just validate
```
```
→ Validating AI dotfiles from: ~/dotfiles/ai

✓ ~/.claude/CLAUDE.md → ~/dotfiles/ai/claude/CLAUDE.md
✓ ~/.claude/skills → ~/dotfiles/ai/skills
✓ ~/.config/opencode/rules → ~/dotfiles/ai/rules
✓ ~/.config/opencode/agents → ~/dotfiles/ai/opencode/agents
✓ python3 available
✓ npx available
✓ $HOME/.local/bin is on PATH
✓ ANTHROPIC_API_KEY is set

✓ All checks passed.
```

<!-- end_slide -->

## Just Commands

```
just init               Interactive setup wizard
just install            Deploy all symlinks
just uninstall          Remove all symlinks
just validate           Health check everything
just status             Show linked/missing state
just smoke-test         Harness integrity check
just marketplace-check  Check deps (read-only)
just session-save       Capture session state
just session-load foo   Resume saved session
just mcp-list           List available MCP servers
just mcp-status         Show active/inactive + prereqs
just mcp-add gmail      Add server (checks env vars)
just mcp-remove gmail   Remove server
```

<!-- end_slide -->

## Skills (8 slash commands)

| OpenCode | Claude Code | Auto? | Does |
|---|---|---|---|
| | | | |
| `/dotai-adr` | `/dotai:adr` | ✓ | Architecture Decision Records |
| `/dotai-doctor` | `/dotai:doctor` | ✓ | Diagnose harness issues |
| `/dotai-onboard` | `/dotai:onboard` | ✓ | Document new projects |
| `/dotai-pr-review` | `/dotai:pr-review` | Manual | PR description from git diff |
| `/dotai-debug` | `/dotai:debug` | Manual | Systematic debugging |
| `/dotai-handoff` | `/dotai:handoff` | Manual | Session state capture |
| `/dotai-readme-gen` | `/dotai:readme-gen` | Manual | Generate README |

Skills are loaded contextually by description, not manual typing.

<!-- end_slide -->

## MCP — Conditional Servers

```bash
just mcp-list
```
```
→ Available MCP servers

  gmail               Read, search, and manage Gmail messages
  slack               Read and post Slack messages
  brave-search        Web search via Brave Search API
  linear              Manage Linear issues and projects
  jira                Manage Jira issues and sprints
  notion              Read, create, update Notion pages
  sqlite              Query local SQLite databases
  puppeteer           Browser automation and screenshots
  google-maps         Geocoding, directions, places
```

<!-- end_slide -->

## MCP — Conditional Add

```bash
just mcp-add brave-search
```
```
→ Adding MCP server: brave-search
✓ Added brave-search to claude_desktop_config.json
  Backup saved: ...bak.20260703_143000
  Run 'just install' to deploy.

  Setup notes: Get a free API key at brave.com/search/api/
               Free tier: 2,000 queries/month.
```

If `BRAVE_API_KEY` not set:

```
✗ Missing env var: BRAVE_API_KEY
  To skip checks: mcp-manage add --force brave-search
```

<!-- end_slide -->

## MCP — Status Check

```bash
just mcp-status
```
```
→ MCP server status

  ✓ github             GitHub integration          [active]
  ✓ filesystem         Local filesystem access     [active]
  ✓ memory             Key-value memory store      [active]
  · gmail              Gmail messages              [inactive] [missing env]
  · slack              Slack messaging             [inactive]
  ✓ brave-search       Web search                  [active]
  · linear             Linear issue tracking       [inactive] [missing env]
```

<!-- end_slide -->

## Token Efficiency

```
Tools (→ ~/.local/bin/):

  repo-outline      Directory tree + function signatures
                    ~10x smaller than reading every file

  strip-comments    Remove comments from source
                    ~20-40% token reduction

Behavioral rules (in CLAUDE.md):

  → Use repo-outline before reading files
  → Reference by path, don't paste already-read code
  → Pipe large code through strip-comments
  → Summarize tool output, don't repeat verbatim
  → OpenCode pruning enabled (drops old outputs)
```

<!-- end_slide -->

## Subagents (OpenCode)

```
/agent reviewer
```
Read-only diff review. Cannot write files.
Focuses on: correctness, security, conventions, simplicity.

```
/agent planner
```
Plan-only. Analyzes, designs, proposes. Never writes code.
Outputs structured plans with Mermaid diagrams.

```
/agent test-writer
```
Test-only. Can read code, can only write to test files.
If a test reveals a production bug, reports it — doesn't fix it.

<!-- end_slide -->

## GRILL ME Protocol

Before writing *any* code, the AI asks:

1. **What** exactly? Bug fix, feature, refactor?
2. **Constraints**? Performance, OS, deadlines?
3. **Edge cases**? Empty input, network failure, concurrency?
4. **Data schema**? Validation rules, external dependencies?
5. **Existing code**? Patterns to reuse, testing framework?
6. **Done** means what? Tests? Docs? Migration scripts?

If ambiguous, it presents concrete options **before** coding.
No guessing. No assumptions.

<!-- end_slide -->

## Git Safety

```
Pre-commit hook (auto-installed):
  ✗ Blocks commits with API keys
    (Anthropic, OpenAI, GitHub, AWS, JWT patterns)
  ✗ Blocks invalid JSON configs
  → sk-... found in src/config.ts — commit blocked!

Workflow rules (CLAUDE.md):
  → Never commit/push unless explicitly asked
  → Always run lint + tests before declaring done
  → Conventional commits: type(scope): description
  → Worktrees for parallel work
  → Never force-push
```

<!-- end_slide -->

## Project Onboarding

```bash
# First time in a repo, Claude Code asks:
"New project detected. Full or partial overview?"

# Then generates .claude/docs/:

.claude/docs/
├── README.md              # Index + quick start
├── architecture.md        # Mermaid diagrams
├── modules.md             # Key modules with descriptions
├── data-flow.md           # How data moves
├── dependencies.md        # External services
├── configuration.md       # Env vars and flags
└── decisions/             # Architecture Decision Records
```

Also available as `/dotai:onboard` slash command.

<!-- end_slide -->

## Session Handoff

```bash
# Before closing terminal
just session-save my-feature

# Resume later (same or different machine)
just session-load my-feature | pbcopy
```

Captures:
- Git branch, status, recent commits
- Tmux scrollback (last 100 lines)
- Working directory, Python venv, shell

Paste into any AI agent to resume where you left off.

<!-- end_slide -->

## Language Rules

```bash
# Loaded automatically by OpenCode for every session

rules/python.md      pathlib, type hints, pytest, ruff, async
rules/rust.md        Result/Option, clippy, no unwrap, tokio
rules/typescript.md  strict mode, ESM, interfaces over types
rules/go.md          error wrapping, stdlib-first, table tests
```

The AI sees these on top of your global CLAUDE.md rules.
Project-level AGENTS.md overrides on top of that.

<!-- end_slide -->

## Smoke Test

```bash
just smoke-test
```
```
→ Directory structure
  ✓ skills/  ✓ rules/  ✓ opencode/agents/  ✓ mcp/  ✓ tools/

→ JSON validity
  ✓ opencode/config.json  ✓ marketplace.json

→ Skill frontmatter
  ✓ adr (name + description)
  ✓ debug (name + description)
  ✓ onboard (name + description)
  ✓ pr-review (name + description)
  ✓ readme-gen (name + description)

→ Executability
  ✓ scripts/install.sh  ✓ tools/repo-outline  ✓ hooks/pre-commit

✓ All smoke tests passed.
```

Non-destructive. No install required.

<!-- end_slide -->

## Summary

| Layer | Provides |
|-------|----------|
| `just init` | Interactive wizard (profile, languages, MCPs) |
| `CLAUDE.md` | Engineering standards, workflow, GRILL ME |
| `skills/dotai/` | 8 namespaced slash commands |
| `rules/` | 4 language-specific conventions |
| `agents/` | 3 specialized subagents |
| `mcp/` | 3 core + 10 conditional servers |
| `tools/` | 9 tools (outline, strip, sessions, MCP, token-cost) |
| `hooks/` | Pre-commit secrets guard + SessionStart |
| `defaults/` | 3 profiles — rigorous, pragmatic, minimal |
| `justfile` | 14 commands, 1 entrypoint |
| `smoke-test` | Harness integrity verification |

**One repo. Two AI tools. Zero conflicts.**

<!-- end_slide -->

## `just init` — Setup

```bash
just init
```
```
  DotAI — Setup

  Which AI tools?
    1  Claude Code  2  OpenCode  3  Both
  Choice [2]:

  Workflow style
    1  Rigorous — full gates, GRILL ME, 8 skills, 4 languages
    2  Pragmatic — balanced, 3 skills, 2 languages
    3  Minimal — essentials only
  Choice [1]:

  Languages (press Enter for all)
    > python typescript rust go

  Saved to ~/.dotai/config.json

  Next: just install
```

<!-- end_slide -->

<!-- end_slide -->

## Get Started

```bash
just init          # configure (profile, tools, languages)
just install       # deploy to ~/.config/opencode/
just validate      # verify
just status        # inspect
just smoke-test    # full integrity check
just token-cost    # ~$0.01/session (Sonnet)
```

**Fork first** — this repo runs on your machine via AI tools.
<!-- end_slide -->
