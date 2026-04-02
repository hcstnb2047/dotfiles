# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Distinguish local vs remote environment
if [[ -n "$SSH_CONNECTION" ]]; then
  _env_label="%F{173}[remote]%f"
else
  _env_label="%F{74}[local]%f"
fi
PROMPT="${_env_label} ${PROMPT}"

# Set terminal title to reflect environment
_zsh_set_title() {
  if [[ -n "$SSH_CONNECTION" ]]; then
    print -Pn "\e]0;[REMOTE] %m\a"
  else
    print -Pn "\e]0;[LOCAL] %m\a"
  fi
}
precmd_functions+=(_zsh_set_title)

# bun completions
[ -s "/home/tnb/.bun/_bun" ] && source "/home/tnb/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH=~/.npm-global/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Created by `pipx` on 2025-05-30 10:04:04
export PATH="$PATH:/home/tnb/.local/bin"

alias zj='zellij'
alias zja='zellij attach'
alias zjls='zellij list-sessions'
alias zjn='zellij --session'

alias cursor='~/apps/Cursor.AppImage'
export PATH="$HOME/bin:$PATH"

# LifeVault aliases (legacy — life-claude に移行済み、/daily スキル使用)
# alias daily='python3 /home/tnb/LifeVault/scripts/daily_cli.py'

# ターミナル状態リセット（マウスレポーティング残留の解除）
alias fix-term='printf "\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1015l\e[?1004l"'
export PATH="/usr/local/bin:$PATH"

# ntfy.sh Push通知 (Claude Code → スマホ)
export NTFY_TOPIC="claude-tnb-38107469"

alias ollama-chat='docker exec -it local-llm-ollama-1 ollama run qwen2.5-coder:7b'

# life-claude 環境への遷移
alias lv='cd /home/tnb/life-claude && claude --resume'
alias lvn='cd /home/tnb/life-claude && claude'

# life-data path
export LIFE_DATA="/home/tnb/life-data"

# dotfiles aliases
[ -f "$HOME/dotfiles/zsh/aliases.zsh" ] && source "$HOME/dotfiles/zsh/aliases.zsh"

# Auto-attach tmux on SSH (for scrollback support)
# 既存セッションがあれば grouped session で接続（各接続が独立したビューを持つ）
if [ -z "$TMUX" ]; then
  if tmux has-session 2>/dev/null; then
    exec tmux new-session -t main
  else
    exec tmux new-session -s main
  fi
fi
