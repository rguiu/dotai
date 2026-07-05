---
name: debug
description: Systematic debugging workflow — reproduce, isolate, hypothesize, fix, verify.
disable-model-invocation: true
---

# /debug

Walk through a systematic debugging process. Use when the user reports a bug, unexpected behavior, or failing tests.

## Process

### 1. Reproduce
- Ask: "Can you reproduce it consistently? What are the exact steps?"
- If a test exists, run it. If not, write a minimal reproduction first.
- Record the exact error message, stack trace, or unexpected output.

### 2. Isolate
- Narrow the scope: which file, function, or code path is the likely culprit?
- Use `git bisect`-like thinking: when did this start? Check `git log` for recent changes to the suspect files.
- Add targeted logging or breakpoints if helpful. Remove them after.

### 3. Hypothesize
- State the hypothesis clearly: "I think X is happening because Y."
- List alternative hypotheses if applicable.
- Do NOT change code yet — just explain the theory.

### 4. Fix
- Make the minimal change that tests the hypothesis. One change at a time.
- If the hypothesis is wrong, revert and try the next one.
- Never make multiple independent changes in one debugging pass.

### 5. Verify
- Confirm the original reproduction steps now pass.
- Run the full test suite for the affected area.
- Add a regression test that would have caught this bug.

## Output

After fixing, summarize:
- **Root cause** (1 sentence)
- **Fix** (1 sentence, with file:line)
- **Regression test** (file:line of the new test)
- **Prevention** (what could have caught this earlier — missing test, lint rule, type system gap?)

## Constraints

- Never skip the reproduction step. If you can't reproduce, you're guessing.
- Do NOT refactor adjacent code during the fix.
- If stuck after 2 hypotheses, present findings and ask for input before continuing.
