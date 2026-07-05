---
name: readme-gen
description: Parse the current project directory structure and generate a consistent architectural README outline.
disable-model-invocation: true
---

# /readme-gen

Generate a README.md for the current project. Do NOT create or modify any files unless the user explicitly asks.

## What to do

1. Scan the project root for package manifests (`package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `Makefile`, etc.) to identify the tech stack.
2. Read the top-level directory listing to understand project structure.
3. If an existing `README.md` exists, analyze it for gaps.
4. Look for CI/CD configs (`.github/workflows/`, `.gitlab-ci.yml`) to include build/test badges and pipeline info.

## Output format

Produce a markdown block with:

- **Project name** (derived from directory or package manifest)
- **Stack** — languages, frameworks, key dependencies
- **Quick start** — install deps, run locally, run tests
- **Project structure** — annotated directory tree (3 levels max)
- **Commands** — build, lint, test, dev server
- **Contributing** — setup quirks, conventions, PR flow

## Constraints

- Never guess URLs or external links.
- If something is ambiguous, flag it with `[TODO: clarify]`.
- Keep the output scannable — prefer lists and short blocks over prose.
