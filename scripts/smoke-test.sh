#!/usr/bin/env bash
# smoke-test — end-to-end validation of the AI dotfiles harness.
# Checks structure, JSON, frontmatter, executability, shebangs.
# Does NOT run install.sh (non-destructive).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$SCRIPT_DIR")"

GREEN=$'\033[0;32m'
RED=$'\033[0;31m'
CYAN=$'\033[0;36m'
RESET=$'\033[0m'

pass() { printf "  ${GREEN}✓${RESET} %s\n" "$*"; }
fail() { printf "  ${RED}✗${RESET} %s\n" "$*"; }
info() { printf "${CYAN}→${RESET} %s\n" "$*"; }

ERRORS=0

# ── Required directories ────────────────────────────────────────
echo ""
info "Directory structure"
for dir in skills skills/dotai claude opencode/agents rules mcp mcp/templates mcp/available tools hooks scripts completions demo defaults defaults/profiles defaults/claude; do
  if [ -d "$AI_DIR/$dir" ]; then
    pass "$dir/"
  else
    fail "$dir/ missing"
    ERRORS=$((ERRORS + 1))
  fi
done

# ── Required files ──────────────────────────────────────────────
echo ""
info "Required files"
for file in \
  claude/CLAUDE.md \
  opencode/config.json \
  mcp/claude_desktop_config.json \
  marketplace.json \
  .gitignore \
  .env.example \
  README.md \
  defaults/profiles/minimal.json \
  defaults/profiles/rigorous.json \
  defaults/claude/rigorous.md \
  defaults/claude/pragmatic.md \
  defaults/claude/minimal.md \
  justfile \
  scripts/install.sh \
  scripts/uninstall.sh \
  scripts/validate.sh \
  scripts/status.sh \
  tools/repo-outline \
  tools/strip-comments \
  tools/marketplace-check \
  tools/session-save \
  tools/session-load \
  tools/mcp-manage \
  tools/bootstrap \
  tools/token-cost \
  hooks/pre-commit \
  completions/just.bash; do
  if [ -f "$AI_DIR/$file" ]; then
    pass "$file"
  else
    fail "$file missing"
    ERRORS=$((ERRORS + 1))
  fi
done

# ── JSON validity ───────────────────────────────────────────────
echo ""
info "JSON validity"
for file in opencode/config.json mcp/claude_desktop_config.json marketplace.json; do
  if python3 -c "import json; json.load(open('$AI_DIR/$file'))" 2>/dev/null; then
    pass "$file"
  else
    fail "$file invalid JSON"
    ERRORS=$((ERRORS + 1))
  fi
done

# ── Skill frontmatter ───────────────────────────────────────────
echo ""
info "Skill frontmatter"
for scope_dir in "$AI_DIR"/skills/*/; do
  [ -d "$scope_dir" ] || continue
  scope="$(basename "$scope_dir")"

  for skill_dir in "$scope_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    skill_md="${skill_dir}SKILL.md"

  if [ ! -f "$skill_md" ]; then
    fail "$skill_name: missing SKILL.md"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # Check required frontmatter fields
  name_ok=false
  desc_ok=false

  if grep -q '^name:' "$skill_md"; then
    name_ok=true
  fi
  if grep -q '^description:' "$skill_md"; then
    desc_ok=true
  fi

  if $name_ok && $desc_ok; then
    pass "$scope:$skill_name"
  else
    local missing=""
    $name_ok || missing="$missing name"
    $desc_ok || missing="$missing description"
    fail "$scope:$skill_name: missing frontmatter:$missing"
    ERRORS=$((ERRORS + 1))
  fi

  # Validate name matches directory
  fm_name=$(grep '^name:' "$skill_md" | head -1 | sed 's/^name: *//')
  if [ "$fm_name" != "$skill_name" ]; then
    fail "$scope:$skill_name: name in frontmatter ($fm_name) doesn't match directory"
    ERRORS=$((ERRORS + 1))
  fi

  # Validate lowercase-alphanumeric-hyphen
  if ! echo "$skill_name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    fail "$skill_name: invalid name (must be lowercase alphanumeric with single hyphens)"
    ERRORS=$((ERRORS + 1))
  fi
done
done

# ── Executables ─────────────────────────────────────────────────
echo ""
info "Executability"
for script in \
  scripts/install.sh \
  scripts/uninstall.sh \
  scripts/validate.sh \
  scripts/status.sh \
  scripts/smoke-test.sh \
  tools/repo-outline \
  tools/strip-comments \
  tools/marketplace-check \
  tools/session-save \
  tools/session-load \
  tools/mcp-manage \
  tools/bootstrap \
  tools/token-cost \
  hooks/pre-commit; do
  if [ -x "$AI_DIR/$script" ]; then
    pass "$script"
  else
    fail "$script not executable"
    ERRORS=$((ERRORS + 1))
  fi
done

for script in \
  scripts/install.sh \
  scripts/uninstall.sh \
  scripts/validate.sh \
  scripts/status.sh \
  tools/repo-outline \
  hooks/pre-commit \
  tools/session-save \
  tools/session-load; do
  if head -1 "$AI_DIR/$script" 2>/dev/null | grep -qE '^#!(/usr/bin/env |/bin/)'; then
    : # ok
  else
    fail "$script: missing or invalid shebang"
    ERRORS=$((ERRORS + 1))
  fi
done

# Shebang for Python scripts
head -1 "$AI_DIR/tools/strip-comments" | grep -q 'python3' || {
  fail "tools/strip-comments: missing python3 shebang"
  ERRORS=$((ERRORS + 1))
}

# ── Config references ───────────────────────────────────────────
echo ""
info "Config references"

# Check instructions in config.json reference existing rules
for rule in python rust typescript go; do
  rule_file="$AI_DIR/rules/${rule}.md"
  if [ -f "$rule_file" ]; then
    pass "rules/${rule}.md exists"
  else
    fail "rules/${rule}.md missing (referenced in config.json)"
    ERRORS=$((ERRORS + 1))
  fi
done

# ── Summary ─────────────────────────────────────────────────────
echo ""
echo "────────────────────────────────────────────────────────────────"
if [ "$ERRORS" -eq 0 ]; then
  pass "All smoke tests passed."
else
  fail "$ERRORS issue(s) found."
fi
echo ""
exit "$ERRORS"
