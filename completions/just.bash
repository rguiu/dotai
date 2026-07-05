# bash/zsh completion for just commands in the AI dotfiles directory.
# Source this file to enable: source ai/completions/just.bash

_just_ai_commands() {
  local words=("install" "uninstall" "validate" "status" "marketplace-check")
  COMPREPLY=($(compgen -W "${words[*]}" -- "${COMP_WORDS[COMP_CWORD]}"))
}

# Only activate if we're in the ai/ directory (or a parent)
_just_ai_trigger() {
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/ai/justfile" ]; then
      _just_ai_commands
      return
    fi
    dir="$(dirname "$dir")"
  done
}

# Register for `just` invocations in any project with an ai/justfile
complete -F _just_ai_trigger just 2>/dev/null || true

# ── Zsh (if detected) ───────────────────────────────────────────
if [ -n "${ZSH_VERSION:-}" ]; then
  # compdef is a zsh builtin
  _just_ai_zsh() {
    local -a commands
    commands=(install uninstall validate status marketplace-check)
    _describe 'command' commands
  }
  compdef _just_ai_zsh just 2>/dev/null || true
fi
