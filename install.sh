#!/usr/bin/env bash
# Bootstrap script — replicates this dotfiles setup on a fresh machine, VM,
# or remote server. Safe to re-run: every step checks before it acts.
#
# Usage: ./install.sh
#
# Maintained by Andrés Becerra with Claude (Anthropic).

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(nvim vim tmux zsh ghostty starship atuin git)

log()  { printf '\033[1;36m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$1"; }

# ----------------------------------------------------------------------------
# 1. Homebrew
# ----------------------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Homebrew not found — installing"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -d /opt/homebrew/bin ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -d /usr/local/bin ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  log "Homebrew already installed"
fi

# ----------------------------------------------------------------------------
# 2. brew bundle (formulae + casks from Brewfile)
# ----------------------------------------------------------------------------
log "Running brew bundle"
if [[ "$(uname -s)" == "Darwin" ]]; then
  brew bundle --file="$DOTFILES_DIR/Brewfile"
else
  warn "Non-macOS detected — skipping cask entries (ghostty, nerd font), installing formulae only"
  grep -v '^cask ' "$DOTFILES_DIR/Brewfile" > /tmp/Brewfile.no-casks
  brew bundle --file=/tmp/Brewfile.no-casks
  rm -f /tmp/Brewfile.no-casks
fi

# ----------------------------------------------------------------------------
# 3. Stow every package
# ----------------------------------------------------------------------------
log "Stowing packages: ${PACKAGES[*]}"
cd "$DOTFILES_DIR"
for pkg in "${PACKAGES[@]}"; do
  if stow -v -t "$HOME" "$pkg" 2>&1 | sed "s/^/  [$pkg] /"; then
    :
  else
    warn "stow failed for '$pkg' — likely a conflicting real file already at the target." \
         "Move it aside and re-run: stow -t \$HOME $pkg"
  fi
done

# ----------------------------------------------------------------------------
# 4. tmux: TPM + plugins
# ----------------------------------------------------------------------------
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  log "Cloning TPM (tmux plugin manager)"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  log "TPM already installed"
fi
log "Installing tmux plugins headlessly"
"$TPM_DIR/bin/install_plugins" || warn "tmux plugin install had issues — run <prefix> + I inside tmux to retry"

# ----------------------------------------------------------------------------
# 5. vim: plugins (vim-plug itself is vendored in vim/.vim/autoload/plug.vim
#    and already stowed above; this just installs what .vimrc declares)
# ----------------------------------------------------------------------------
log "Installing vim plugins headlessly (vim-plug)"
vim +PlugInstall +qall || warn "vim plugin install had issues — open vim and run :PlugInstall to retry"

# ----------------------------------------------------------------------------
# 6. nvim: bootstrap lazy.nvim + sync all plugins
# ----------------------------------------------------------------------------
log "Installing nvim plugins headlessly (lazy.nvim)"
nvim --headless "+Lazy! sync" +qa || warn "nvim plugin sync had issues — open nvim and run :Lazy sync to retry"

# ----------------------------------------------------------------------------
# 7. uv — zsh/.zshrc unconditionally sources ~/.local/bin/env, which only the
#    official installer creates (the Homebrew formula does not)
# ----------------------------------------------------------------------------
if [ ! -f "$HOME/.local/bin/env" ]; then
  log "Installing uv (creates ~/.local/bin/env, sourced unconditionally by .zshrc)"
  curl -LsSf https://astral.sh/uv/install.sh | sh || warn "uv install failed — .zshrc's '. \$HOME/.local/bin/env' line will error until this exists"
else
  log "uv already installed"
fi

# ----------------------------------------------------------------------------
# 8. bun — optional, guarded by a file-existence check in .zshrc so safe to skip
# ----------------------------------------------------------------------------
if [ ! -d "$HOME/.bun" ]; then
  log "Installing bun"
  curl -fsSL https://bun.sh/install | bash || warn "bun install failed — non-fatal, .zshrc guards for its absence"
else
  log "bun already installed"
fi

# ----------------------------------------------------------------------------
# Done
# ----------------------------------------------------------------------------
cat <<'EOF'

==> Bootstrap complete.

Manual follow-ups (intentionally not automated by this script):
  - Set zsh as your default shell, if it isn't already:
      chsh -s "$(command -v zsh)"
  - Anaconda/conda: .zshrc has a guarded conda-init block but does not
    install conda itself — install Anaconda/Miniconda separately if you
    use it, or ignore (the guard means it's a silent no-op without it).
  - Antigravity / Antigravity IDE: .zshrc adds their bin dirs to PATH but
    they're proprietary apps with their own installers — install them
    separately if you use them, or ignore (harmless if the dirs don't exist).
  - git identity and delta are already configured via the stowed `git`
    package (git/.config/git/config) — nothing else to do there.

Open a new shell (or `exec zsh`) to pick up everything.
EOF
