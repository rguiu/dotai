# AI Dotfiles

Your personal AI tooling, explained from scratch

<!-- end_slide -->

## What is this about?

You use AI coding tools like **Claude Code** or **OpenCode**.

They're great, but out of the box they know nothing about:
- Your coding standards
- Your preferred patterns
- Your project's architecture
- Your workflow habits

**AI dotfiles fix that.** Same idea as `.zshrc` or `.gitconfig`,
but for your AI agents.

<!-- end_slide -->

## The core idea

```
AI tools read configuration files from your system.

┌─────────────────────────────────────────┐
│  ~/.claude/           Claude Code       │
│  ~/.config/opencode/  OpenCode          │
└─────────────────────────────────────────┘

We put our configs in a git repo...

┌─────────────────────────────────────────┐
│  ~/dotfiles/ai/       Our source        │
└─────────────────────────────────────────┘

...and symlink them to where the tools expect.
```

<!-- end_slide -->

## What can you configure?

Four main things AI tools let you customize:

| Concept | What it is | Example |
|---------|------------|---------|
| **Rules** | How the AI should behave | "Always run tests before saying you're done" |
| **Skills** | Reusable commands you teach it | `/dotai:pr-review` → generate a PR description |
| **MCP** | Data sources the AI can access | Connect to GitHub, Slack, databases |
| **Agents** | Specialized AI personalities | A reviewer that only reads, never writes |

Let's look at each one.

<!-- end_slide -->

## Pick your starting point

Don't want to configure everything from scratch?

```bash
just init
```

Interactive wizard:
1. Which AI tools?
2. **Rigorous**, **Pragmatic**, or **Minimal**?
3. Which languages?
4. Optional MCP servers?

Saves to `~/.dotai/config.json`. Run `just install` to deploy.

<!-- end_slide -->

# Rules

Teach the AI your standards

<!-- end_slide -->

## Rules — The Foundation

Rules are **instructions you give the AI about how to work**.

They're markdown files. The AI reads them at the start
of every session.

```markdown
# CLAUDE.md

1. Never commit unless I explicitly ask
2. Always run the linter after making changes
3. If unsure between two approaches, present both
4. Write tests for new code — no exceptions
```

Two levels:
- **Global** (`~/.claude/CLAUDE.md`) — applies everywhere
- **Project** (`./CLAUDE.md`) — applies in this repo only

The AI merges both. Project overrides global on conflicts.

<!-- end_slide -->

## Rules — What we ship

Our rules cover:

```
ai/claude/CLAUDE.md          Global engineering standards
ai/rules/python.md           Python-specific conventions
ai/rules/rust.md             Rust-specific conventions
ai/rules/typescript.md       TypeScript/JS conventions
ai/rules/go.md               Go conventions
```

The global rules include:
- GRILL ME protocol (ask questions before coding)
- Quality gates (lint + test before done)
- Git discipline (never push unprompted)
- Token efficiency (use repo-outline, don't paste redundantly)

<!-- end_slide -->

# Skills

Reusable commands the AI can run

<!-- end_slide -->

## Skills — "Slash Commands" for AI

A skill is a **named folder with instructions**.
The AI sees it as a command you can invoke.

```
ai/skills/dotai:pr-review/
└── SKILL.md

┌──────────────────────────────────────┐
│ ---                                  │
│ name: pr-review                      │
│ description: Generate a PR desc...   │
│ ---                                  │
│                                      │
│ # /dotai:pr-review                         │
│                                      │
│ 1. Run `git diff origin/main...`     │
│ 2. Run `git log base..HEAD --oneline`│
│ 3. Generate a structured description │
└──────────────────────────────────────┘
```

You type `/dotai:pr-review` and the AI follows the
instructions in `SKILL.md`.

<!-- end_slide -->

## Skills — Why they matter

Without skills:
```
You: "Write a PR description"
AI:  "Sure, what should I include?"
You: "The diff, commit history, related issues..."
AI:  "Okay, let me look..."
     (5 rounds of back and forth)
```

With skills:
```
You: "/dotai:pr-review"
AI:  (Reads SKILL.md → knows exactly what to do)
     (Runs git diff, git log, formats output)
     → Produces the PR description in one shot
```

Skills encode **your workflow** so the AI
doesn't need to be told every time.

<!-- end_slide -->

## Skills — What we ship

| OpenCode | Claude Code | Description |
|---|---|---|
| `/dotai-adr` | `/dotai:adr` | Architecture Decision Records |
| `/dotai-doctor` | `/dotai:doctor` | Diagnose harness issues |
| `/dotai-onboard` | `/dotai:onboard` | Document new projects |
| `/dotai-pr-review` | `/dotai:pr-review` | PR description from git diff |
| `/dotai-debug` | `/dotai:debug` | Systematic debugging |
| `/dotai-handoff` | `/dotai:handoff` | Session state capture |
| `/dotai-readme-gen` | `/dotai:readme-gen` | Generate README |

Skills load contextually — the AI reads the `description` and picks the right one.
You don't type them. The AI suggests them when relevant.

<!-- end_slide -->

## Skills vs Rules — The Difference

People often confuse these:

| | Rules | Skills |
|---|-------|--------|
| **When** | Every session, automatically | When you invoke the command |
| **What** | "Always do X, never do Y" | "When I say /dotai:pr-review, do steps 1-5" |
| **Format** | One markdown file | Folder with SKILL.md |
| **Example** | "Never commit unprompted" | "/dotai:pr-review → git diff + format output" |

Think: rules are **laws**, skills are **functions**.

<!-- end_slide -->

# MCP

Connect the AI to external tools

<!-- end_slide -->

## MCP — Model Context Protocol

MCP is a **standard way for AI tools to talk to external services**.

Without MCP, the AI can only:
- Read/write local files
- Run shell commands

With MCP, the AI can:
- Query your database
- Search your GitHub repos
- Read your Gmail
- Post to Slack

MCP is a **protocol**, not a specific tool.
It's like USB for AI — a standard connector.

<!-- end_slide -->

## MCP — How it works

```
┌──────────┐     MCP Protocol      ┌──────────────────┐
│          │◄──────────────────────►│  MCP Server      │
│ AI Agent │    (JSON messages)     │  (npm package)   │
│          │                        │                  │
│  "What   │  "list my repos"  ───►│  Calls GitHub API │
│   repos  │◄─── [repo1, repo2] ───│  Returns results  │
│   do I   │                        │                  │
│   have?" │                        └──────────────────┘
└──────────┘
```

The MCP server is just an npm package that
translates between the AI and the external API.

<!-- end_slide -->

## MCP — Example Config

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "{env:GITHUB_TOKEN}"
      }
    }
  }
}
```

Translation:
- Run `npx -y @anthropic-ai/mcp-server-github`
- Pass `GITHUB_TOKEN` from your environment variables
- The AI can now talk to GitHub

`{env:GITHUB_TOKEN}` is a placeholder — never put real keys here.

<!-- end_slide -->

## MCP — Conditional Servers

Not every project needs every service.

```bash
just mcp-list       # See what's available
just mcp-status     # See what's active + what's missing
just mcp-add slack  # Add Slack (checks if SLACK_BOT_TOKEN is set)
```

```
→ MCP server status

  ✓ github        [active]    Working fine
  ✓ memory        [active]    Working fine
  · gmail         [inactive]  [missing env: GMAIL_CLIENT_ID]
  · slack         [inactive]  [missing env: SLACK_BOT_TOKEN]
  · linear        [inactive]
```

**Active** means configured + env vars set = the AI can use it.
**Inactive** means not configured or missing credentials.

<!-- end_slide -->

## MCP — What we ship

**Always on (core):**
- `github` — repos, issues, PRs
- `filesystem` — read/write local files
- `memory` — persistent key-value store

**Optional (add when needed):**
- `gmail`, `slack`, `brave-search`, `linear`
- `jira`, `notion`, `sqlite`, `puppeteer`
- `google-maps`, `postgres` (+ any you create)

Each optional server has setup notes and a list
of required environment variables.

<!-- end_slide -->

# Agents

Specialized AI personalities

<!-- end_slide -->

## Agents — Different Roles

By default, the AI does everything: reads, writes, plans, tests.

Agents are **specialized sub-personalities** with
limited permissions.

```
┌─────────────┐
│ Default AI  │  Can do anything
└──────┬──────┘
       │
   ┌───┴───────────┐
   │               │
┌──▼──────┐  ┌─────▼──────┐
│Reviewer │  │ Test Writer│
│         │  │            │
│ Read ✓  │  │ Read    ✓  │
│ Write ✗ │  │ Write   ✓  │
│ Edit  ✗ │  │ Edit    ✗  │ (only test files)
└─────────┘  └────────────┘
```

This prevents the AI from accidentally breaking
production code while writing tests.

<!-- end_slide -->

## Agents — What we ship

```
/agent reviewer
```
Read-only. Reviews your diff.
Checks: correctness, security, conventions, simplicity.
Suggests changes but never makes them.

```
/agent planner
```
Plan-only. Designs the architecture.
Outputs structured plans with Mermaid diagrams.
Hands off to a build agent for implementation.

```
/agent test-writer
```
Test-only. Writes tests but can't touch production code.
If a test reveals a real bug, it reports it — doesn't fix it.

<!-- end_slide -->

## Putting it all together

```
One repo. Two tools. Four layers.

┌──────────────────────────────────────────────┐
│  Rules       How the AI behaves             │
│  (always active, every session)             │
├──────────────────────────────────────────────┤
│  Skills      Reusable slash commands         │
│  (invoked with /command)                    │
├──────────────────────────────────────────────┤
│  MCP         External data sources           │
│  (GitHub, Slack, databases, email)          │
├──────────────────────────────────────────────┤
│  Agents      Specialized sub-personalities   │
│  (reviewer, planner, test-writer)           │
└──────────────────────────────────────────────┘
```

<!-- end_slide -->

## Does it work with my tools?

**Yes.** Both Claude Code and OpenCode **merge**
global + project-local configs.

```
Global      Project        Result
~/.claude/  +  .claude/  =  Both available
```

Project files add to global — they don't replace.
If both define the same thing, project wins.

Your personal standards are always there.
Project-specific rules layer on top.

<!-- end_slide -->

## Getting Started

```bash
# 1. Fork the repo (security — you control updates)
# 2. Configure
just init
# 3. Deploy
just install      # skills → ~/.config/opencode/, tools → ~/.local/bin/
just validate     # check everything works
# 4. Start using — describe what you need, skills load automatically.
```

Skills deploy to `~/.config/opencode/skills/dotai-*/`.
Existing files are never overwritten. `dotai-` prefix avoids conflicts.

<!-- end_slide -->

## Extending — Your Own Skill

```bash
mkdir -p ai/skills/deploy/SKILL.md
```

```markdown
---
name: deploy
description: Deploy the current branch to staging.
---

# /deploy

1. Run `just lint && just test`
2. Confirm with user: "Deploy to staging?"
3. Run `git push origin HEAD:staging`
4. Report the CI/CD URL
```

Just like that — a new `/deploy` command.
No reinstall needed. The AI picks it up automatically.

<!-- end_slide -->

## Extending — Your Own MCP Server

```bash
cp ai/mcp/available/slack.json ai/mcp/available/my-service.json
# Edit the JSON with your service details

just mcp-add my-service
just install
```

That's the pattern. Copy, edit, add, install.

<!-- end_slide -->

## Summary

| Question | Answer |
|----------|--------|
| Why? | Carry your standards everywhere |
| How to start? | Fork → `just init` → `just install` |
| Safe for projects? | Yes — `dotai-` prefix, never overwrites |
| Works with Claude Code? | Yes — scoped skills + SessionStart hook |
| Works with OpenCode? | Yes — prefixed skills at `~/.config/opencode/` |
| Handles secrets? | `.env` file (gitignored), Keychain, or 1Password |
| Easy to undo? | `just uninstall` removes everything |
| Easy to verify? | `just validate` / `just smoke-test` |

<!-- end_slide -->

## Next Steps

```bash
# Configure and deploy
just init && just install && just validate

# Full docs
cat README.md

# Cost per session
just token-cost

# Full technical walkthrough
presenterm demo/presenterm.md
```

Your standards. Your tools. Your rules.
<!-- end_slide -->
