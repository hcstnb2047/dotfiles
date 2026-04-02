# dotfiles 編集用 Claude Code 起動
dotfiles() {
  claude /mnt/c/Users/yooct/dotfiles
}

# 端末サイズ再取得（Termius キーボード dismiss 後のズレ修正）
alias r='resize 2>/dev/null; tmux refresh-client 2>/dev/null; true'
