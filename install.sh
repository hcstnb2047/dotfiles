#!/bin/bash
# dotfiles install script for WSL/Linux

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC="$HOME/.zshrc"
SOURCE_LINE="[ -f \"$DOTFILES/zsh/aliases.zsh\" ] && source \"$DOTFILES/zsh/aliases.zsh\""

# zsh aliases
if ! grep -qF "$DOTFILES/zsh/aliases.zsh" "$ZSHRC" 2>/dev/null; then
  echo "$SOURCE_LINE" >> "$ZSHRC"
  echo "Added aliases to $ZSHRC"
else
  echo "Already in $ZSHRC, skipping"
fi

echo ""
echo "Done. Run 'source ~/.zshrc' or restart your shell to apply."
