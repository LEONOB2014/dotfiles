# Homebrew bundle for Andrés Becerra's dotfiles.
# Installed by ./install.sh via `brew bundle --file=Brewfile`.
# Run standalone with: brew bundle --file=Brewfile

# ===== Stow itself =====
brew "stow"

# ===== Editors =====
brew "neovim"
brew "vim"

# ===== Multiplexer / shell / prompt =====
brew "tmux"
brew "antidote"
brew "starship"

# ===== Modern CLI replacements (aliased in zsh/.zshrc) =====
brew "eza"        # ls
brew "bat"        # cat
brew "ripgrep"    # grep (rg)
brew "fd"
brew "zoxide"     # cd
brew "fzf"

# ===== git tooling =====
brew "git-delta"  # `delta`, wired in as git's diff pager
brew "lazygit"
brew "gh"

# ===== Shell history / env / misc CLI =====
brew "atuin"
brew "direnv"     # eval'd unconditionally in .zshrc
brew "jq"
brew "yq"
brew "tealdeer"   # `tldr`

# ===== Runtime needed by Mason (nvim LSP/formatter/linter installer) =====
# ts_ls, html, cssls, tailwindcss, svelte, graphql, emmet_ls, prismals are
# npm-based; Mason needs a system node/npm to bootstrap them.
brew "node"

# ===== Terminal + font =====
cask "ghostty"
cask "font-jetbrains-mono-nerd-font"

# ===== Optional: only if you use local Postgres client tools =====
# .zshrc unconditionally adds this to PATH; harmless if not installed
# (the PATH entry is just unused), so it's safe to skip by commenting out.
brew "postgresql@16"
