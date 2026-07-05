---
name: pr-review
description: Generate a pull request description from the current git diff, commit history, and branch context.
disable-model-invocation: true
---

# /pr-review

Generate a complete, well-structured PR description from the current branch state.

## What to do

1. **Diff analysis** — run `git diff origin/main...HEAD` (or the configured base branch). If the branch doesn't exist remotely yet, use `git log --oneline -20` to find a reasonable base.
2. **Commit summary** — run `git log base..HEAD --oneline` to list all commits in the branch.
3. **Changed files** — run `git diff --stat base..HEAD` for scope overview.
4. **Check for issues** — scan commit messages for issue/ticket references (e.g. `fixes #42`, `PROJ-123`).

## Output format

```markdown
## Summary
[1-2 sentences describing the change and why]

## Changes
- [Bulleted list of key changes, grouped by subsystem if applicable]

## Testing
- [How was this tested? What test cases should reviewers consider?]
- [Any manual testing steps]

## Screenshots / Evidence
[If relevant — otherwise omit]

## Related issues
[Auto-linked from commit references if found]

## Checklist
- [ ] Tests pass
- [ ] Lint passes
- [ ] No new warnings
```

## Constraints

- Base branch: try `origin/main`, `origin/master`, then `origin/develop`. Ask if unsure.
- If there are no commits (empty branch), say so and suggest pushing first.
- Include concrete file paths and function names from the diff.
- Do NOT create or modify any files unless explicitly asked.
