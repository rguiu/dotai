#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$SCRIPT_DIR")"

RESET=$'\033[0m' GREEN=$'\033[0;32m' RED=$'\033[0;31m' YELLOW=$'\033[0;33m' DIM=$'\033[2m'

row() {
  local dest="$1" src="$2" label="$3" icon status
  if [ -L "$dest" ]; then
    if [ "$(readlink "$dest")" = "$src" ]; then icon="${GREEN}✓${RESET}"; status="${GREEN}linked${RESET}"
    else icon="${YELLOW}!${RESET}"; status="${YELLOW}→ $(readlink "$dest")${RESET}"; fi
  elif [ -e "$dest" ]; then icon="${YELLOW}·${RESET}"; status="${YELLOW}preserved${RESET}"
  else icon="${RED}✗${RESET}"; status="${RED}missing${RESET}"; fi
  printf "  %b  %-45s %b\n" "$icon" "${DIM}$label${RESET}" "$status"
}

echo ""
echo "  DotAI Status"
echo "  ${DIM}──────────────────────────────────────────${RESET}"
echo ""

# OpenCode skills
echo "  ${DIM}OpenCode skills${RESET}"
for sd in "$AI_DIR"/skills/*/; do [ -d "$sd" ] || continue
  for sk in "$sd"/*/; do [ -d "$sk" ] || continue
    n="$(basename "$sk")"
    row "$HOME/.config/opencode/skills/dotai-$n/SKILL.md" "$sk/SKILL.md" "/dotai-$n"
  done
done

# Claude Code skills
echo ""
echo "  ${DIM}Claude skills${RESET}"
for sd in "$AI_DIR"/skills/*/; do [ -d "$sd" ] || continue
  sc="$(basename "$sd")"
  for sk in "$sd"/*/; do [ -d "$sk" ] || continue
    n="$(basename "$sk")"
    DIR="$HOME"
    row "$DIR/.claude/skills/$sc/$n" "$sk" "/$sc:$n"
  done
done

# Agents
echo ""
echo "  ${DIM}Agents${RESET}"
for a in "$AI_DIR"/opencode/agents/*.md; do [ -f "$a" ] || continue
  b="$(basename "$a")"
  row "$HOME/.config/opencode/agents/dotai-$b" "$a" "dotai-$b"
done

# Configs
echo ""
echo "  ${DIM}Configs${RESET}"
row "$HOME/.config/opencode/AGENTS.md" "$AI_DIR/claude/CLAUDE.md" "AGENTS.md"
row "$HOME/.config/opencode/opencode.json" "$AI_DIR/opencode/config.json" "opencode.json"
row "$HOME/.config/opencode/rules" "$AI_DIR/rules" "rules/"

# Tools
echo ""
echo "  ${DIM}Tools${RESET}"
for t in "$AI_DIR"/tools/*; do [ -f "$t" ] || continue
  n="$(basename "$t")"
  row "$HOME/.local/bin/$n" "$t" "$n"
done

echo ""
