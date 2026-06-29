#!/bin/bash
# Claude Code custom status line（2行）。描画は statusline.py に一本化し、
# ここは Python 検出と入力受け渡しだけを担う。
#   line1: model  project ⎇branch  ⇡PR#N <state>  session_name
#   line2: bar pct%  tokens  $cost  5h/7d rate-limit(↻reset)

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
    printf "claude  -\n░░░░░░░░░░  0%%  0/200k  \$0.00\n"
    exit 0
fi

printf '%s' "$input" | "$PYTHON" "$(dirname "$0")/statusline.py"
