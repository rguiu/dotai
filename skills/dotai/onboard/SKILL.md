---
name: onboard
description: Document a new project — architecture overview, mermaid diagrams, organized docs in .claude/docs/.
disable-model-invocation: false
---

# /onboard

Generate structured, well-organized documentation for a project you're seeing for the first time.

## Process

### 1. Ask scope
- Full overview or partial/targeted?
- If targeted: which subsystem, directory, or concern?

### 2. Scan
- Package manifests, build files, CI configs
- Entry points (`main`, `index`, `app`)
- Directory structure (3 levels deep)
- Configuration files, env templates

### 3. Document (write to `.claude/docs/`)

Generate these files as appropriate:

```
.claude/docs/
├── README.md              # Index + quick start
├── architecture.md        # High-level design + Mermaid diagrams
├── modules.md             # Key modules/classes with descriptions
├── data-flow.md           # How data moves through the system
├── dependencies.md        # External services, APIs, databases
├── configuration.md       # Env vars, config files, feature flags
└── decisions/             # Architecture Decision Records (if needed)
```

### 4. Diagram

Include Mermaid diagrams where they add clarity:
- `graph TD` for architecture/components
- `sequenceDiagram` for request flows
- `flowchart` for state machines or pipelines
- `classDiagram` for key domain models
- `erDiagram` for database schemas

## Output

After generating, report:
```
Documents created: N
Diagrams: N
Location: .claude/docs/
```

## Constraints

- Do NOT create files until the user confirms the scope.
- Prefer depth over breadth — better one well-documented subsystem than ten shallow overviews.
- Reference existing README/AGENTS.md rather than duplicating.
- Keep files scannable: short paragraphs, lists, tables, diagrams.
- Never invent facts — mark unknowns with `[TODO: verify]`.
