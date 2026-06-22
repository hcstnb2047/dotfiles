#!/usr/bin/env python3
import sys, json, os.path, subprocess

try:
    d = json.load(sys.stdin)
except Exception:
    print('MODEL="claude"\nPROJECT="-"\nBRANCH=""\nPCT=0\nTOKENS="0/200k"\nCOST="0.00"')
    sys.exit(0)

model = d.get("model", {}).get("display_name", "claude")
pdir  = d.get("workspace", {}).get("project_dir") or d.get("cwd", "")
proj  = os.path.basename(pdir.rstrip("/\\")) if pdir else "-"

# 現在チェックアウトしている git ブランチ（worktree/仕事リポジトリでも作業対象が分かるように）
cwd = d.get("cwd") or pdir
branch = ""
if cwd:
    try:
        branch = subprocess.run(
            ["git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True, text=True, timeout=1,
        ).stdout.strip()
        if branch == "HEAD":  # detached HEAD: 短縮SHAにフォールバック
            branch = subprocess.run(
                ["git", "-C", cwd, "rev-parse", "--short", "HEAD"],
                capture_output=True, text=True, timeout=1,
            ).stdout.strip()
    except Exception:
        branch = ""
cw    = d.get("context_window", {})
pct   = int(cw.get("used_percentage") or 0)
used  = int(cw.get("total_input_tokens") or 0)
total = int(cw.get("context_window_size") or 200000)
cost  = float((d.get("cost") or {}).get("total_cost_usd") or 0)

def fmt(n):
    if n >= 1_000_000: return f"{n/1_000_000:.1f}M"
    if n >= 1_000:     return f"{n//1000}k"
    return str(n)

tokens = f"{fmt(used)}/{fmt(total)}"

print(f'MODEL="{model}"\nPROJECT="{proj}"\nBRANCH="{branch}"\nPCT={pct}\nTOKENS="{tokens}"\nCOST="{cost:.2f}"')
