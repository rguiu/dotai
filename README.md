# dotai

Global configuration harness for Claude Code and OpenCode. A standalone repo you clone anywhere; it deploys via symlinks to `~/.claude/` and `~/.config/opencode/`. Coexists with project-local configs — both tools **merge** global and local layers (project wins on name collisions).

## Install

**Fork first** (recommended). This repo runs code on your machine via AI tools — someone gaining commit access to upstream means your AI config is compromised, and your AI has shell access. Forking puts you in control: you review every diff before it lands, no surprise updates. Same discipline you'd apply to any code that runs on your machine.

```bash
git clone https://github.com/YOU/dotai.git ~/dotai
cd ~/dotai
just init      # interactive wizard (profile, languages, MCPs)
just install   # deploy all symlinks
just validate  # verify everything is healthy
```

**Direct clone** (if you're evaluating or trust the source):

```bash
git clone https://github.com/rguiu/dotai.git ~/dotai
cd ~/dotai
just init && just install && just validate
```

If you skip the wizard, run scripts directly:

```bash
bash scripts/install.sh
bash scripts/uninstall.sh   # remove all dotai files
```

Requires [`just`](https://github.com/casey/just) (`brew install just`).

## Commands

```bash
just init               interactive wizard
just install            deploy all symlinks
just uninstall          remove all symlinks
just validate           health check
just status             show linked/missing state
just direnv-setup       install shared-keys direnv layer in a parent dir
just direnv-project     enable current project to inherit keys via source_up
just smoke-test         non-destructive harness integrity check
just token-cost         estimate token consumption per session
just marketplace-check  check deps for updates (read-only)
just session-save       capture current state
just session-load foo   resume a saved session
just mcp-list           list available MCP servers
just mcp-status         show active/inactive + prerequisites
just mcp-add <server>   add server (checks env vars)
just mcp-remove <srv>   remove server
```

Tab-completion:

```bash
source completions/just.bash   # bash or zsh
```

## Structure

```
├── skills/dotai/                # Namespaced skills → invoked as /dotai:xxx
│   ├── readme-gen/             # /dotai:readme-gen — generate README.md from project scan
│   ├── pr-review/              # /dotai:pr-review — generate PR description from git diff
│   ├── debug/                  # /dotai:debug — systematic debugging workflow
│   ├── adr/                    # /dotai:adr — architecture decision records
│   ├── handoff/                # /dotai:handoff — session state capture for handoffs
│   ├── onboard/                # /dotai:onboard — document new projects with diagrams
│   └── doctor/                # /dotai:doctor — diagnose and fix harness issues
├── claude/CLAUDE.md            # → ~/.claude/CLAUDE.md (global rules — single source of truth)
├── opencode/
│   ├── config.json             # → ~/.config/opencode/opencode.json (prefs, permissions)
│   │                           #   ~/.config/opencode/AGENTS.md → claude/CLAUDE.md (shared)
│   └── agents/                 # → ~/.config/opencode/agents/ (custom subagents)
│       ├── reviewer.md         #   read-only diff reviewer
│       ├── planner.md          #   plan-only design agent
│       └── test-writer.md      #   test-only agent
├── rules/                      # → ~/.config/opencode/rules/ (language-specific rules)
│   ├── python.md
│   ├── rust.md
│   ├── typescript.md
│   └── go.md
├── mcp/
│   ├── claude_desktop_config.json  # → ~/Library/Application Support/Claude/ (active MCP servers)
│   ├── templates/              # Copy-into-project MCP boilerplate
│   └── available/              # Optional MCP servers (conditionally added)
├── tools/                      # → ~/.local/bin/ (token-efficiency + maintenance scripts)
│   ├── token-cost              # Estimate tokens consumed per session
│   ├── bootstrap                 # Interactive setup wizard
│   ├── repo-outline            # Compact structural index of a codebase
│   ├── strip-comments          # Strip comments from source files
│   ├── marketplace-check       # Report outdated marketplace dependencies (read-only)
│   ├── session-save            # Capture session state to JSON
│   ├── session-load            # Print resume prompt from saved session
│   └── mcp-manage              # Conditionally add/remove MCP servers
├── hooks/                      # Git hooks (installed by install.sh)
│   └── pre-commit              # Block commits with secrets or invalid JSON
 ├── completions/                # Shell completions
│   └── just.bash               # bash/zsh tab-completion for just commands
├── demo/                       # Terminal presentations (presenterm)
│   ├── beginner.md             # Concepts-first walkthrough
│   └── presenterm.md           # Full feature walkthrough
├── defaults/                   # Vanilla profiles and rule templates
│   ├── profiles/               #   rigorous, pragmatic, minimal
│   └── claude/                 #   CLAUDE.md per profile
├── marketplace.json            # External MCPs, skills, plugins I depend on
└── scripts/
    ├── install.sh
    ├── uninstall.sh
    ├── validate.sh
    ├── status.sh
    └── smoke-test.sh
```

## How merging works

Both Claude Code and OpenCode **merge** global + project-local configs — they don't overwrite:

| Layer | Claude Code | OpenCode |
|---|---|---|
| Global | `~/.claude/skills/`, `~/.claude/CLAUDE.md` | `~/.config/opencode/skills/`, `~/.config/opencode/AGENTS.md`, `~/.config/opencode/rules/` |
| Project | `.claude/skills/`, `CLAUDE.md` | `.opencode/skills/`, `AGENTS.md`, `opencode.json` |
| Result | **Combined** — both available | **Combined** — non-conflicting keys preserved |

OpenCode also reads `~/.claude/skills/` as a fallback, so a single skill dir works in both tools. `~/.config/opencode/AGENTS.md` symlinks to the same `CLAUDE.md` — one source of truth for global rules.

## Skills

Skills are loaded by the AI when context matches — describe what you need (e.g. "create an architecture decision record"). The AI picks the right skill from the `description` field. `dotai-` prefix avoids conflicts with existing skills.

| OpenCode | Claude Code | Auto? | Description |
|---|---|---|---|
| `/dotai-adr` | `/dotai:adr` | Auto | Architecture Decision Records |
| `/dotai-debug` | `/dotai:debug` | Manual | Systematic debugging workflow |
| `/dotai-doctor` | `/dotai:doctor` | Auto | Diagnose harness issues |
| `/dotai-onboard` | `/dotai:onboard` | Auto | Document new projects with diagrams |
| `/dotai-handoff` | `/dotai:handoff` | Manual | Session state capture |
| `/dotai-pr-review` | `/dotai:pr-review` | Manual | Generate PR description from git diff |
| `/dotai-readme-gen` | `/dotai:readme-gen` | Manual | Generate README from project scan |

"Auto" means the AI can invoke it proactively. "Manual" means you type the command or describe the task.

### Adding a new skill

```bash
mkdir -p skills/dotai/my-skill
cat > skills/dotai/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: What this skill does.
disable-model-invocation: true
---

# /dotai:my-skill
Instructions for the AI agent here.
EOF
```

## Rules

Language-specific conventions loaded by OpenCode from `~/.config/opencode/rules/`. Edit the `instructions` field in `opencode/config.json` to add or remove files.

## Agents

Custom OpenCode subagents in `opencode/agents/`. Invoked with `/agent <name>` or configured as defaults.

| Agent | Purpose |
|---|---|
| `reviewer` | Read-only diff review — correctness, security, conventions |
| `planner` | Design and plan — no code changes, just architecture |
| `test-writer` | Write and run tests — cannot modify production code |

## MCP server management

Conditionally add/remove MCP servers. Prerequisites (env vars, binaries) are checked before adding.

```bash
just mcp-list              # show all available servers
just mcp-status            # show active/inactive + prerequisites met
just mcp-add gmail         # add server (checks env vars)
just mcp-add gmail --force # skip prerequisite checks
just mcp-remove gmail      # remove server
```

After adding/removing, run `just install` to deploy the updated config.

Optional servers available: `gmail`, `slack`, `brave-search`, `linear`, `jira`, `notion`, `sqlite`, `puppeteer`, `google-maps`, `postgres`.

Each server config lives in `mcp/available/<name>.json` with its description, env var requirements, and setup notes.

## Adding a new MCP server (manual)

Add an entry to `mcp/claude_desktop_config.json` under `mcpServers`. Use `{env:VAR}` for secrets. Then run `install.sh` again to re-link.

## Tools

Token-efficiency and maintenance utilities symlinked to `~/.local/bin/`.

### `repo-outline`

Compact structural index of a codebase — directory tree + function/class signatures.

```bash
repo-outline              # current directory
repo-outline /path/to/repo
MAX_DEPTH=2 repo-outline  # shallower tree
```

### `strip-comments`

Strip comments from source. Reduces context size ~20-40%.

```bash
strip-comments file.py                  # infers language from extension
strip-comments --lang=python file.py    # explicit language
cat file.js | strip-comments            # stdin
```

### `marketplace-check`

Check installed MCP servers, skills, and plugins against `marketplace.json`. **Read-only — never installs or updates anything.**

```bash
marketplace-check
```

### `session-save` / `session-load`

Capture and restore terminal session state for context handoffs.

```bash
session-save                    # auto-named: session-20260703-143000
session-save my-fix            # named session
session-load my-fix            # print resume prompt (stdout)
session-load my-fix | pbcopy   # macOS: copy to clipboard
```

Sessions are stored as JSON in `~/.claude/sessions/`.

### Shell completions

Tab-completion for `just` commands:

```bash
source completions/just.bash   # bash or zsh
```

Add to your `.zshrc` / `.bashrc` for persistence.

### `token-cost`

Estimate context tokens consumed per session by rules, skills, configs. Shows what's always in context vs. on-demand.

```bash
just token-cost
```

Uses `tiktoken` for accurate counts if available (`pip install tiktoken`), falls back to char-based estimate otherwise.

Example output:
```
  Global rules
    CLAUDE.md                823 tokens
  Language rules
    rules/python.md           142 tokens
    ...
  Total (always on)         1240 tokens  every session base cost
                             ~$0.004 (Sonnet)
```

### Smoke test

Non-destructive harness integrity check. Validates directory structure, JSON configs, skill frontmatter, executables, and shebangs. Does NOT run `install.sh`.

```bash
just smoke-test
```

## Git hooks

`pre-commit` blocks commits containing API keys, tokens, or invalid JSON. Installed automatically if this repo has a `.git/` directory. Re-run `install.sh` after `git init`.

## Bootstrapping a new project

Run `/init` inside OpenCode (or Claude Code if supported). It scans your repo and generates an informed `AGENTS.md` / `CLAUDE.md`. Commit the result.

## Demo

Terminal walkthroughs:

```bash
brew install presenterm
presenterm demo/beginner.md    # concepts-first
presenterm demo/presenterm.md  # full feature walkthrough
```

Both are plain markdown — readable without `presenterm`.

## `bootstrap` — fresh setup wizard

For brand-new users or resetting to defaults. Interactive prompts:

1. Which AI tools? (Claude Code, OpenCode, both)
2. Workflow style: **Rigorous** (full gates), **Pragmatic** (balanced), **Minimal** (fast)
3. Which languages?
4. Which optional MCP servers?

Generates your `CLAUDE.md`, `rules/` selection, MCP config, and OpenCode config from profile templates in `defaults/`. Backs up existing files with `.pre-init` suffix.

```bash
just init
```

## Secrets

Never put tokens in `.zshrc` — they're readable by any process on your machine.

**Recommended (pick one):**

```bash
# Option A: .env file (simplest, gitignored)
cp .env.example .env
# Fill in your keys. .env is gitignored, never committed.

# Option B: macOS Keychain
security add-generic-password -a "$USER" -s 'github-token' -w 'ghp_...'
# Then in .zshrc (no raw token):
export GITHUB_TOKEN=$(security find-generic-password -w -s 'github-token')

# Option C: 1Password CLI
export GITHUB_TOKEN=$(op read 'op://private/github/token')

# Option D: direnv + source_up (share one set of keys across all projects)
brew install direnv
# Add to .zshrc: eval "$(direnv hook zsh)"
cp .env.example .env      # fill in your keys (gitignored)
just direnv-setup         # writes .envrc.dotai + a source block in a parent .envrc
# Then, inside any project that should inherit the keys:
just direnv-project       # drops `source_up` into ./.envrc and allows it
```

`just direnv-setup` installs the keys **once** in a parent directory (default:
your projects root, override with `just direnv-setup ~/some/dir`). It creates
`.envrc.dotai` (which loads this repo's `.env`) and appends a small
`source_env .envrc.dotai` block to that dir's `.envrc` — your own keys in that
`.envrc` are left untouched. Every project below it inherits the keys with a
one-line `.envrc` containing `source_up`, so you never copy keys per project.

Pre-commit hook catches accidental commits of API key patterns.
