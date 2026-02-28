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

# Claude Code skills (.claude/commands/)
CLAUDE_COMMANDS="$HOME/.claude/commands"
mkdir -p "$CLAUDE_COMMANDS"
for src in "$DOTFILES/.claude/commands/"*.md; do
  name="$(basename "$src")"
  dest="$CLAUDE_COMMANDS/$name"
  if [ -L "$dest" ]; then
    echo "Symlink already exists: $dest, skipping"
  else
    ln -sf "$src" "$dest"
    echo "Linked $name -> $dest"
  fi
done

# ~/bin/ scripts
mkdir -p "$HOME/bin"
for src in "$DOTFILES/bin/"*; do
  name="$(basename "$src")"
  dest="$HOME/bin/$name"
  if [ -L "$dest" ]; then
    echo "Symlink already exists: $dest, skipping"
  else
    ln -sf "$src" "$dest"
    chmod +x "$src"
    echo "Linked $name -> $dest"
  fi
done

# tmux config
TMUX_SRC="$DOTFILES/tmux/.tmux.conf"
TMUX_DEST="$HOME/.tmux.conf"
if [ -L "$TMUX_DEST" ]; then
  echo "Symlink already exists: $TMUX_DEST, skipping"
else
  ln -sf "$TMUX_SRC" "$TMUX_DEST"
  echo "Linked .tmux.conf -> $TMUX_DEST"
fi

echo ""
echo "Done. Run 'source ~/.zshrc' or restart your shell to apply."
