#!/usr/bin/env python3
import sys, json

try:
    d = json.load(sys.stdin)
except Exception:
    print('MODEL="claude"\nPROJECT="-"\nPCT=0\nTOKENS="0/200k"\nCOST="0.00"')
    sys.exit(0)

model = d.get("model", {}).get("display_name", "claude")
pdir  = d.get("workspace", {}).get("project_dir") or d.get("cwd", "")
proj  = pdir.rstrip("/").split("/")[-1] if pdir else "-"
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

print(f'MODEL="{model}"\nPROJECT="{proj}"\nPCT={pct}\nTOKENS="{tokens}"\nCOST="{cost:.2f}"')
