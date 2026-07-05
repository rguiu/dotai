#!/usr/bin/env bash
# direnv-setup.sh — install the dotai direnv layer in a parent directory.
#
# Creates <target>/.envrc.dotai (loads the harness .env via dotenv_if_exists)
# and appends a managed `source_env .envrc.dotai` block to <target>/.envrc,
# leaving any existing user content untouched. Projects below <target> then
# inherit the keys with a one-line `.envrc` containing `source_up`.
#
# Target dir resolution (first match wins):
#   1. $1 argument
#   2. $DOTAI_ENVRC_DIR
#   3. $HOME (covers every project below your home dir)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$SCRIPT_DIR")"
DEFAULT_TARGET="$HOME"

TARGET="${1:-${DOTAI_ENVRC_DIR:-$DEFAULT_TARGET}}"

RESET=$'\033[0m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' DIM=$'\033[2m'
info() { printf "${CYAN}→${RESET} %s\n" "$*"; }
ok()   { printf "${GREEN}✓${RESET} %s\n" "$*"; }
warn() { printf "${YELLOW}⚠${RESET} %s\n" "$*"; }

BEGIN_MARK="# >>> dotai direnv >>>"
END_MARK="# <<< dotai direnv <<<"

[ -d "$TARGET" ] || { warn "Target dir does not exist: $TARGET"; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"

echo ""
info "dotai direnv layer → $TARGET"

# ── .envrc.dotai (the dotai layer) ──────────────────────────────
DOTAI_ENVRC="$TARGET/.envrc.dotai"
cat > "$DOTAI_ENVRC" <<EOF
# dotai — direnv layer (managed by scripts/direnv-setup.sh).
# Loads AI dotfiles secrets from the harness .env. Do not put raw keys here;
# edit the .env below instead. Sourced from .envrc via \`source_env\`.
dotenv_if_exists "$AI_DIR/.env"
EOF
ok "wrote .envrc.dotai"

# ── .envrc (append managed block, non-destructive) ──────────────
USER_ENVRC="$TARGET/.envrc"
if [ -f "$USER_ENVRC" ] && grep -qF "$BEGIN_MARK" "$USER_ENVRC"; then
  info ".envrc already sources the dotai layer"
else
  {
    printf '\n%s\n' "$BEGIN_MARK"
    printf 'source_env .envrc.dotai\n'
    printf '%s\n' "$END_MARK"
  } >> "$USER_ENVRC"
  ok "appended source block to .envrc"
fi

# ── allow ───────────────────────────────────────────────────────
if command -v direnv >/dev/null 2>&1; then
  direnv allow "$TARGET" && ok "direnv allow $TARGET"
else
  warn "direnv not found. Install: brew install direnv"
  warn "Then add to your shell rc: eval \"\$(direnv hook zsh)\""
fi

echo ""
info "Per project, run inside the repo:"
printf "  ${DIM}just direnv-project${RESET}   ${DIM}# or: echo source_up > .envrc && direnv allow${RESET}\n"
echo ""
