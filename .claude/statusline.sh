#!/bin/bash
# Claude Code custom status line
# Format: model  project  bar  pct%  tokens  $cost

input=$(cat)
eval "$(echo "$input" | python3 "$(dirname "$0")/statusline.py")"

# Progress bar (10 chars)
filled=$(( PCT / 10 ))
[ "$filled" -gt 10 ] && filled=10
empty=$(( 10 - filled ))
bar=""
for i in $(seq 1 $filled 2>/dev/null); do bar="${bar}█"; done
for i in $(seq 1 $empty 2>/dev/null); do bar="${bar}░"; done

dim="\033[2m"
r="\033[0m"

printf "${dim}%s${r}  %s  %s  %s%%  ${dim}%s  \$%s${r}\n" \
  "$MODEL" "$PROJECT" "$bar" "$PCT" "$TOKENS" "$COST"
