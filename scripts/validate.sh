#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$SCRIPT_DIR")"
ENV_EXAMPLE="$AI_DIR/.env.example"

RESET=$'\033[0m' GREEN=$'\033[0;32m' RED=$'\033[0;31m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m'

pass() { printf "${GREEN}✓${RESET} %s\n" "$*"; }
fail() { printf "${RED}✗${RESET} %s\n" "$*"; }
warn() { printf "${YELLOW}⚠${RESET} %s\n" "$*"; }
info() { printf "${CYAN}→${RESET} %s\n" "$*"; }

ERRORS=0 WARNINGS=0

check_link() {
  local src="$1" dest="$2" label="$3"
  if [ -L "$dest" ]; then
    [ "$(readlink "$dest")" = "$src" ] && pass "$label" || { fail "$label → $(readlink "$dest")"; ERRORS=$((ERRORS+1)); }
  elif [ -e "$dest" ]; then
    warn "$label (unmanaged)"; WARNINGS=$((WARNINGS+1))
  else
    fail "$label missing"; ERRORS=$((ERRORS+1))
  fi
}

check_json() {
  python3 -c "import json; json.load(open('$1'))" 2>/dev/null && pass "$(basename "$1") valid" || { fail "$(basename "$1") invalid"; ERRORS=$((ERRORS+1)); }
}

check_exec() {
  [ -x "$1" ] && pass "$(basename "$1")" || { fail "$(basename "$1") not exec"; ERRORS=$((ERRORS+1)); }
}

check_cmd() {
  command -v "$1" &>/dev/null && pass "$1" || { fail "$1"; ERRORS=$((ERRORS+1)); }
}

echo ""
info "Validating"

# ── OpenCode skills ─────────────────────────────────────────────
echo ""; info "Skills"
for sd in "$AI_DIR"/skills/*/; do
  [ -d "$sd" ] || continue
  for sk in "$sd"/*/; do
    [ -d "$sk" ] || continue
    n="$(basename "$sk")"
    [ -f "$HOME/.config/opencode/skills/dotai-$n/SKILL.md" ] && pass "/dotai-$n" || { fail "/dotai-$n"; ERRORS=$((ERRORS+1)); }
  done
done

# ── Agents ──────────────────────────────────────────────────────
echo ""; info "Agents"
for a in "$AI_DIR"/opencode/agents/*.md; do
  [ -f "$a" ] || continue
  b="$(basename "$a")"
  check_link "$a" "$HOME/.config/opencode/agents/dotai-$b" "agent:dotai-$b"
done

# ── Configs ─────────────────────────────────────────────────────
echo ""; info "Configs"
check_link "$AI_DIR/rules" "$HOME/.config/opencode/rules" "rules/"
check_link "$AI_DIR/opencode/config.json" "$HOME/.config/opencode/opencode.json" "opencode.json"

# ── Claude Code ─────────────────────────────────────────────────
CLPAR="$HOME"
echo ""; info "Claude Code"
check_link "$AI_DIR/claude/CLAUDE.md" "$CLPAR/.claude/CLAUDE.md" ".claude/CLAUDE.md"
for sd in "$AI_DIR"/skills/*/; do
  [ -d "$sd" ] || continue
  sc="$(basename "$sd")"
  for sk in "$sd"/*/; do
    [ -d "$sk" ] || continue
    n="$(basename "$sk")"
    check_link "$sk" "$CLPAR/.claude/skills/$sc/$n" "/$sc:$n"
  done
done
check_link "$AI_DIR/mcp/claude_desktop_config.json" "$CLPAR/.claude/claude_desktop_config.json" "mcp"

# ── Tools ──────────────────────────────────────────────────────
echo ""; info "Tools"
for t in "$AI_DIR"/tools/*; do
  [ -f "$t" ] || continue
  n="$(basename "$t")"
  check_link "$t" "$HOME/.local/bin/$n" "$n"
  check_exec "$t"
done

# ── Deps ────────────────────────────────────────────────────────
echo ""; info "Deps"
command -v tree &>/dev/null && pass "tree"
check_cmd python3; check_cmd npx; check_cmd git

# ── PATH ────────────────────────────────────────────────────────
echo ""; info "PATH"
echo "$PATH" | tr ':' '\n' | grep -qxF "$HOME/.local/bin" && pass "\$HOME/.local/bin" || { warn "not on PATH"; WARNINGS=$((WARNINGS+1)); }

# ── Config files ────────────────────────────────────────────────
echo ""; info "Config files"
check_json "$AI_DIR/opencode/config.json"
check_json "$AI_DIR/mcp/claude_desktop_config.json"
check_json "$AI_DIR/marketplace.json"

# ── Env ─────────────────────────────────────────────────────────
echo ""; info "Env vars"
if [ -f "$ENV_EXAMPLE" ]; then
  while IFS= read -r line; do
    [[ "$line" =~ ^# ]] && continue; [[ -z "$line" ]] && continue
    v="${line%%=*}"; [[ "$v" =~ ^[A-Z] ]] || continue
    [ -n "${!v:-}" ] && pass "$v" || { warn "$v"; WARNINGS=$((WARNINGS+1)); }
  done < "$ENV_EXAMPLE"
fi

echo ""; echo "────────────────────────────────────────────────────────────────"
[ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ] && pass "All good."
[ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -gt 0 ] && warn "$WARNINGS warnings."
[ "$ERRORS" -gt 0 ] && fail "$ERRORS errors, $WARNINGS warnings."
echo ""; exit "$ERRORS"
