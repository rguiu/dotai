---
name: adr
description: Create an Architecture Decision Record from a decision description.
disable-model-invocation: false
---

# /adr

Generate an Architecture Decision Record (ADR) document. Use when making a significant architectural choice that should be recorded for future contributors.

## Process

1. **Ask for context** — what decision needs to be made? What prompted it?
2. **Research alternatives** — look at existing patterns in the codebase, check if similar decisions were recorded in `docs/adr/` or `.claude/docs/`.
3. **Present options** — list the alternatives considered with pros/cons.
4. **Recommend** — state the chosen option and why.
5. **Write the ADR** — output a markdown document.

## Output format

```markdown
# ADR-{NNN}: {Title}

**Status**: proposed | accepted | deprecated | superseded by ADR-XXX
**Date**: YYYY-MM-DD
**Deciders**: [names]

## Context
[What problem are we solving? What constraints exist?]

## Decision
[The chosen approach, stated clearly]

## Consequences
### Positive
- [What becomes easier, faster, simpler?]

### Negative
- [What trade-offs, costs, or limitations does this introduce?]

## Alternatives considered
### Option A: {Name}
- Pros: ...
- Cons: ...
- Why rejected: ...

### Option B: {Name}
- Pros: ...
- Cons: ...
- Why rejected: ...
```

## Constraints

- ADR number: look in `docs/adr/` or `.claude/docs/adr/` for the highest existing number. If none exist, start at 001.
- Ask: "Should this be committable (shared with the team)?" Yes → `docs/adr/`. No → `.claude/docs/adr/`.
- Do NOT create files unless the user confirms the ADR content first.
- Keep it concise — an ADR is a record, not a blog post.
