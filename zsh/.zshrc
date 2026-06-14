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
alias lv='cd /home/tnb/life-claude && CLAUDE_CODE_NO_FLICKER=1 claude --resume'
alias lvn='cd /home/tnb/life-claude && CLAUDE_CODE_NO_FLICKER=1 claude'

# tmux セッション選択（fzf）
ta() {
  local session
  session=$(tmux ls -F "#{session_last_attached} #{session_name}: #{session_windows} windows" 2>/dev/null | sort -rn | sed 's/^[0-9]* //' | fzf --height=10 --prompt="attach> " | cut -d: -f1)
  if [ -n "$session" ]; then
    if [ -n "$TMUX" ]; then
      tmux switch-client -t "$session"
    else
      tmux attach -t "$session"
    fi
  fi
}

# life-data path
export LIFE_DATA="/home/tnb/life-data"

# dotfiles aliases
[ -f "$HOME/dotfiles/zsh/aliases.zsh" ] && source "$HOME/dotfiles/zsh/aliases.zsh"

# SSH接続時のtmux（スマートアタッチ・2026-06-15）:
#   デタッチ済みセッションがあれば再接続（切断からの復帰）、無ければ新規作成（独立並列のため）
#   → 同時に複数ターミナルを開けば各々が独立セッション。再接続は既存を使い回すので無限増殖しない
# ガード: 対話シェルのみ・tmux外のみ・SSH接続時のみ・tmux存在時のみ（cron/Bashツール暴発防止）
if [[ $- == *i* ]] && [ -z "$TMUX" ] && [ -n "$SSH_CONNECTION" ] && command -v tmux >/dev/null 2>&1; then
  _detached=$(tmux ls -F '#{session_attached} #{session_name}' 2>/dev/null | awk '$1==0{print $2; exit}')
  if [ -n "$_detached" ]; then
    exec tmux attach -t "$_detached"
  else
    exec tmux new-session
  fi
fi

# ntn (Notion CLI): このサーバーはOSキーチェーン無しのためファイルベース認証
export NOTION_KEYRING=0

# browser MCP は通常セッションでは自動起動しない（メモリ節約・2026-06-14）。UI作業時のみ:
alias claudeui='claude --mcp-config ~/.claude/browser-mcp.json'
