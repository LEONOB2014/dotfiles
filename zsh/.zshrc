# Personal zsh config — maintained by Andrés Becerra with Claude (Anthropic)
# Plugins are managed by antidote, sourced from .zsh_plugins.txt (see README)

DISABLE_AUTO_TITLE="true"
DISABLE_UPDATE_TERMINAL_CWD=true
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# Added by Antigravity
export PATH="/Users/andresbecerra/.antigravity/antigravity/bin:$PATH"

. "$HOME/.local/bin/env"

# Added by Antigravity IDE
export PATH="/Users/andresbecerra/.antigravity-ide/antigravity-ide/bin:$PATH"

# bun completions
[ -s "/Users/andresbecerra/.bun/_bun" ] && source "/Users/andresbecerra/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ===== History =====
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS EXTENDED_HISTORY

# ===== Options =====
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS CORRECT INTERACTIVE_COMMENTS
setopt NO_BEEP

# ===== Completion =====
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# ===== Antidote =====
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load

# ===== Prompt =====
eval "$(starship init zsh)"

# ===== Modern tools =====
eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"
eval "$(atuin init zsh)"          # better history search (Ctrl+R)
eval "$(direnv hook zsh)"

# ===== Aliases =====
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first --git'
alias la='eza -la --icons --group-directories-first --git'
alias tree='eza --tree --icons'
alias cat='bat --paging=never'
alias grep='rg'
alias cd='z'                      # zoxide
alias cdi='zi'                    # interactive zoxide
alias lg='lazygit'
alias g='git'
alias ..='cd ..'
alias ...='cd ../..'

# Uncomment to auto-attach Claude Code inside a dedicated tmux session
# alias claude='tmux new-session -A -s claude "claude"'

# ===== Keybindings =====
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

