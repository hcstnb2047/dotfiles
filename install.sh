#!/bin/bash
# dotfiles install script for WSL/Linux

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC="$HOME/.zshrc"

# zshrc symlink
if [ -L "$ZSHRC" ]; then
  echo "Symlink already exists: $ZSHRC, skipping"
elif [ -f "$ZSHRC" ]; then
  mv "$ZSHRC" "$ZSHRC.bak"
  echo "Backed up existing $ZSHRC to $ZSHRC.bak"
  ln -sf "$DOTFILES/zsh/.zshrc" "$ZSHRC"
  echo "Linked .zshrc -> $ZSHRC"
else
  ln -sf "$DOTFILES/zsh/.zshrc" "$ZSHRC"
  echo "Linked .zshrc -> $ZSHRC"
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

# Claude Code statusline scripts (~/.claude/statusline.sh, statusline.py)
mkdir -p "$HOME/.claude"
for src in "$DOTFILES/.claude/statusline.sh" "$DOTFILES/.claude/statusline.py"; do
  name="$(basename "$src")"
  dest="$HOME/.claude/$name"
  if [ -L "$dest" ]; then
    echo "Symlink already exists: $dest, skipping"
  else
    ln -sf "$src" "$dest"
    chmod +x "$src"
    echo "Linked $name -> $dest"
  fi
done

# Claude Code global settings.json: statusLine entry
SETTINGS="$HOME/.claude/settings.json"
if [ -f "$SETTINGS" ] && python3 -c "import json,sys; d=json.load(open('$SETTINGS')); sys.exit(0 if 'statusLine' in d else 1)" 2>/dev/null; then
  echo "settings.json already has statusLine, skipping"
elif [ -f "$SETTINGS" ]; then
  python3 -c "
import json
with open('$SETTINGS') as f: d = json.load(f)
d['statusLine'] = {'type': 'command', 'command': 'bash ~/.claude/statusline.sh'}
with open('$SETTINGS', 'w') as f: json.dump(d, f, indent=2, ensure_ascii=False)
print('Added statusLine to settings.json')
"
else
  echo '{"statusLine":{"type":"command","command":"bash ~/.claude/statusline.sh"}}' > "$SETTINGS"
  echo "Created settings.json with statusLine"
fi

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
