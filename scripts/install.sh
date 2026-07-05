#!/usr/bin/env bash
# install.sh — deploy harness. OpenCode → ~/.config/opencode/, Claude → repo parent .claude/.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$SCRIPT_DIR")"
CLAUDE_PARENT="$HOME"  # Claude global config lives at ~/.claude/

RESET=$'\033[0m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' DIM=$'\033[2m'

info() { printf "${CYAN}→${RESET} %s\n" "$*"; }
ok()   { printf "${GREEN}✓${RESET} %s\n" "$*"; }
warn() { printf "${YELLOW}⚠${RESET} %s\n" "$*"; }

SKIPPED=0

link_file() {
  local src="$1" dest="$2" label="$3"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    if [ "$(readlink "$dest")" = "$src" ]; then info "Already: $label"; return; fi
    warn "Skipping: $label"
    SKIPPED=$((SKIPPED+1)); return
  fi
  if [ -e "$dest" ]; then
    warn "Skipping: $label (exists)"
    SKIPPED=$((SKIPPED+1)); return
  fi
  ln -s "$src" "$dest"
  ok "Linked: $label"
}

echo ""
info "Deploying..."

# ── OpenCode skills → ~/.config/opencode/skills/dotai-<name>/ ──
for scope_dir in "$AI_DIR"/skills/*/; do
  [ -d "$scope_dir" ] || continue
  for skill_dir in "$scope_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    name="$(basename "$skill_dir")"
    odir="$HOME/.config/opencode/skills/dotai-$name"
    rm -rf "$odir"
    mkdir -p "$odir"
    sed "s/^name: .*/name: dotai-$name/" "$skill_dir/SKILL.md" > "$odir/SKILL.md"
    ok "/dotai-$name"
  done
done

# ── OpenCode agents → ~/.config/opencode/agents/dotai-* ─────────
for agent_src in "$AI_DIR"/opencode/agents/*.md; do
  [ -f "$agent_src" ] || continue
  base="$(basename "$agent_src")"
  link_file "$agent_src" "$HOME/.config/opencode/agents/dotai-$base" "agent:dotai-$base"
done

# ── OpenCode rules ──────────────────────────────────────────────
link_file "$AI_DIR/rules" "$HOME/.config/opencode/rules" ".opencode/rules/"

# ── OpenCode config ─────────────────────────────────────────────
link_file "$AI_DIR/opencode/config.json" "$HOME/.config/opencode/opencode.json" ".opencode/opencode.json"

# ── Claude Code (hierarchical — repo parent) ────────────────────
link_file "$AI_DIR/claude/CLAUDE.md" "$CLAUDE_PARENT/.claude/CLAUDE.md" ".claude/CLAUDE.md"

for scope_dir in "$AI_DIR"/skills/*/; do
  [ -d "$scope_dir" ] || continue
  scope="$(basename "$scope_dir")"
  for skill_dir in "$scope_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    name="$(basename "$skill_dir")"
    cdest="$CLAUDE_PARENT/.claude/skills/$scope/$name"
    mkdir -p "$(dirname "$cdest")"
    if [ ! -e "$cdest" ]; then
      ln -s "$skill_dir" "$cdest"
      ok "Claude: /$scope:$name"
    fi
  done
done

link_file "$AI_DIR/mcp/claude_desktop_config.json" "$CLAUDE_PARENT/.claude/claude_desktop_config.json" ".claude/mcp"

# ── Tools ──────────────────────────────────────────────────────
mkdir -p "$HOME/.local/bin"
for tool in "$AI_DIR"/tools/*; do
  [ -f "$tool" ] || continue
  n="$(basename "$tool")"
  link_file "$tool" "$HOME/.local/bin/$n" "$n"
done

# ── Git hook ───────────────────────────────────────────────────
[ -d "$AI_DIR/.git" ] && link_file "$AI_DIR/hooks/pre-commit" "$AI_DIR/.git/hooks/pre-commit" "pre-commit"

echo ""
[ "$SKIPPED" -eq 0 ] && ok "Done." || warn "Done. $SKIPPED skipped."
echo ""
