#!/bin/bash
# tmux status bar 用: 渡したパスの git ブランチを " ⎇ <branch>" で返す（非gitなら空）。
# Claude Code / Codex / 素のシェルを問わず tmux 下部バーに常時表示するための共通部品。
# status-right から #(tmux-branch.sh '#{pane_current_path}') で呼ぶ。
dir="${1:-$PWD}"
[ -d "$dir" ] || exit 0
branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
[ -z "$branch" ] && exit 0
[ "$branch" = "HEAD" ] && branch=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)  # detached
printf ' \xe2\x8e\x87 %s' "$branch"
