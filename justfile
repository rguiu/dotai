# justfile — task runner for AI dotfiles.
# Run `just --list` to see all commands.

set positional-arguments := true

# Install: symlink all configs, tools, rules, and agents
install:
    bash {{justfile_directory()}}/scripts/install.sh

# Init: interactive wizard — pick profile, languages, MCP servers
init:
    bash {{justfile_directory()}}/tools/bootstrap

# Uninstall: remove all symlinks (--restore to recover backups)
uninstall *args:
    bash {{justfile_directory()}}/scripts/uninstall.sh {{args}}

# Validate: check symlinks, configs, tools, env vars
validate:
    bash {{justfile_directory()}}/scripts/validate.sh

# direnv: install the dotai layer in a parent dir (keys shared via source_up)
direnv-setup *args:
    bash {{justfile_directory()}}/scripts/direnv-setup.sh {{args}}

# direnv: enable the current project to inherit parent keys via source_up
direnv-project:
    printf 'source_up\n' > .envrc && direnv allow

# Status: show linked/missing state for everything
status:
    bash {{justfile_directory()}}/scripts/status.sh

# Check marketplace dependencies for outdated versions (read-only)
marketplace-check:
    bash {{justfile_directory()}}/tools/marketplace-check

# Smoke test: non-destructive harness integrity check (dirs, JSON, skills, shebangs)
smoke-test:
    bash {{justfile_directory()}}/scripts/smoke-test.sh

# Save current session state (git, tmux, env) for later restore
session-save *args:
    bash {{justfile_directory()}}/tools/session-save {{args}}

# Load a saved session and print resume prompt
session-load *args:
    bash {{justfile_directory()}}/tools/session-load {{args}}

# MCP: list available optional servers
mcp-list:
    bash {{justfile_directory()}}/tools/mcp-manage list

# MCP: show active/inactive status and prerequisites
mcp-status:
    bash {{justfile_directory()}}/tools/mcp-manage status

# MCP: add a server (checks env vars and binaries)
mcp-add *args:
    bash {{justfile_directory()}}/tools/mcp-manage add {{args}}

# MCP: remove a server from config
mcp-remove *args:
    bash {{justfile_directory()}}/tools/mcp-manage remove {{args}}

# Token cost: estimate tokens consumed by rules, skills, and configs per session
token-cost:
    bash {{justfile_directory()}}/tools/token-cost
