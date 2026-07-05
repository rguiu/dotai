#!/usr/bin/env bash
# uninstall.sh — remove harness files.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$SCRIPT_DIR")"
CLPAR="$HOME"

RESET=$'\033[0m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m'

info() { printf "${CYAN}→${RESET} %s\n" "$*"; }
ok()   { printf "${GREEN}✓${RESET} %s\n" "$*"; }
warn() { printf "${YELLOW}⚠${RESET} %s\n" "$*"; }

DRY=false; [ "${1:-}" = "--dry-run" ] && DRY=true

REMOVED=0

remove() {
  local path="$1" label="$2"
  if [ -L "$path" ]; then
    if $DRY; then info "Would remove: $label"; else rm "$path"; ok "Removed: $label"; fi
    REMOVED=$((REMOVED+1))
  elif [ -d "$path" ] && [ ! -L "$path" ]; then
    if $DRY; then info "Would remove dir: $label"; else rm -rf "$path"; ok "Removed dir: $label"; fi
    REMOVED=$((REMOVED+1))
  fi
}

echo ""; info "Uninstalling"

# OpenCode skills
for sd in "$AI_DIR"/skills/*/; do
  [ -d "$sd" ] || continue
  for sk in "$sd"/*/; do
    [ -d "$sk" ] || continue
    n="$(basename "$sk")"
    remove "$HOME/.config/opencode/skills/dotai-$n" "/dotai-$n"
  done
done

# OpenCode agents
for a in "$AI_DIR"/opencode/agents/*.md; do
  [ -f "$a" ] || continue
  b="$(basename "$a")"
  remove "$HOME/.config/opencode/agents/dotai-$b" "agent:dotai-$b"
done

# OpenCode configs
remove "$HOME/.config/opencode/rules" "rules/"
remove "$HOME/.config/opencode/opencode.json" "opencode.json"

# Claude Code
remove "$CLPAR/.claude/CLAUDE.md" ".claude/CLAUDE.md"
remove "$CLPAR/.claude/claude_desktop_config.json" "mcp"
for sd in "$AI_DIR"/skills/*/; do
  [ -d "$sd" ] || continue
  sc="$(basename "$sd")"
  for sk in "$sd"/*/; do
    [ -d "$sk" ] || continue
    n="$(basename "$sk")"
    remove "$CLPAR/.claude/skills/$sc/$n" "/$sc:$n"
  done
done
rmdir "$CLPAR/.claude/skills/dotai" 2>/dev/null || true
rmdir "$CLPAR/.claude/skills" 2>/dev/null || true
rmdir "$CLPAR/.claude" 2>/dev/null || true

# Tools
for t in "$AI_DIR"/tools/*; do
  [ -f "$t" ] || continue
  remove "$HOME/.local/bin/$(basename "$t")" "$(basename "$t")"
done

# Git hook
remove "$AI_DIR/.git/hooks/pre-commit" "pre-commit" 2>/dev/null || true

# direnv layer — strip managed block from .envrc, remove .envrc.dotai
DIRENV_TARGET="${DOTAI_ENVRC_DIR:-$CLPAR}"
if [ -f "$DIRENV_TARGET/.envrc" ] && grep -qF "# >>> dotai direnv >>>" "$DIRENV_TARGET/.envrc" 2>/dev/null; then
  if $DRY; then
    info "Would strip dotai block from $DIRENV_TARGET/.envrc"
  else
    sed -i '' '/# >>> dotai direnv >>>/,/# <<< dotai direnv <<</d' "$DIRENV_TARGET/.envrc"
    # drop a trailing blank line left behind, if any
    [ -s "$DIRENV_TARGET/.envrc" ] || rm -f "$DIRENV_TARGET/.envrc"
    ok "Stripped dotai block from .envrc"
  fi
  REMOVED=$((REMOVED+1))
fi
remove "$DIRENV_TARGET/.envrc.dotai" ".envrc.dotai"

echo ""; ok "Done. $REMOVED removed."
echo ""
