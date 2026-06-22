#!/bin/bash
# Claude Code custom status line
# Format: model  project [branch]  bar  pct%  tokens  $cost

# Python インタプリタ検出（python3 が PATH に無い環境=Windows Git Bash 等に対応）
PYTHON=""
for p in python3 python; do
    "$p" --version &>/dev/null 2>&1 && PYTHON="$p" && break
done
# uv 管理の Python フォールバック（https://docs.astral.sh/uv/）
if [ -z "$PYTHON" ]; then
    _uv=$(command -v uv 2>/dev/null)
    [ -n "$_uv" ] && PYTHON=$("$_uv" python find 2>/dev/null)
fi

input=$(cat)

if [ -z "$PYTHON" ]; then
    printf "claude  -  ░░░░░░░░░░  0%%  0/200k  \$0.00\n"
    exit 0
fi

# echo はバックスラッシュを解釈するため printf を使う
eval "$(printf '%s\n' "$input" | "$PYTHON" "$(dirname "$0")/statusline.py")"

# Progress bar (10 chars)
filled=$(( PCT / 10 ))
[ "$filled" -gt 10 ] && filled=10
empty=$(( 10 - filled ))
bar=""
# pure bash（seq 非依存）
for (( i=0; i<filled; i++ )); do bar="${bar}█"; done
for (( i=0; i<empty;  i++ )); do bar="${bar}░"; done

dim="\033[2m"
cyan="\033[36m"
r="\033[0m"

# ブランチ（git管理下のときだけ表示）
branchseg=""
[ -n "$BRANCH" ] && branchseg=" ${cyan}⎇ ${BRANCH}${r}"

printf "${dim}%s${r}  %s${branchseg}  %s  %s%%  ${dim}%s  \$%s${r}\n" \
  "$MODEL" "$PROJECT" "$bar" "$PCT" "$TOKENS" "$COST"
