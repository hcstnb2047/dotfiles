#!/usr/bin/env python3
# Claude Code custom status line（2行レイアウト）
#   line1（識別）: model  project ⎇branch  ⇡PR#N <state>  session_name
#   line2（指標）: bar pct%  tokens  $cost  5h/7d rate-limit(↻reset)
# ANSI 着色まで含めてここで完結し、statusline.sh は入力を渡すだけ。
import sys, json, os.path, subprocess, time

DIM = "\033[2m"; CYAN = "\033[36m"; GREEN = "\033[32m"
YELLOW = "\033[33m"; RED = "\033[31m"; R = "\033[0m"


def main():
    try:
        d = json.load(sys.stdin)
    except Exception:
        print("claude  -")
        print("░░░░░░░░░░  0%  0/200k  $0.00")
        return

    model = d.get("model", {}).get("display_name", "claude")
    pdir = d.get("workspace", {}).get("project_dir") or d.get("cwd", "")

    # セッション内で cd した先に追従（PostToolUse:Bash の statusline-track-cwd が書く focus を優先）
    sid = d.get("session_id") or ""
    if sid:
        try:
            with open(f"/tmp/claude-statusline-focus-{sid}") as fh:
                cand = fh.read().strip()
            if cand and os.path.isdir(cand):
                pdir = cand
        except Exception:
            pass

    proj = os.path.basename(pdir.rstrip("/\\")) if pdir else "-"
    cwd = pdir or d.get("cwd")

    # 現在ブランチ（worktree/detached も拾う）
    branch = ""
    if cwd:
        try:
            branch = subprocess.run(
                ["git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD"],
                capture_output=True, text=True, timeout=1).stdout.strip()
            if branch == "HEAD":
                branch = subprocess.run(
                    ["git", "-C", cwd, "rev-parse", "--short", "HEAD"],
                    capture_output=True, text=True, timeout=1).stdout.strip()
        except Exception:
            branch = ""

    # 現在ブランチの PR とレビュー状態（無ければ自動で消える）
    pr_seg = ""
    pr = d.get("pr") or {}
    num = pr.get("number")
    if num:
        icon, col = {
            "approved": ("✓", GREEN),
            "changes_requested": ("✗", RED),
            "pending": ("·", YELLOW),
            "draft": ("✎", DIM),
        }.get(pr.get("review_state") or "", ("", CYAN))
        pr_seg = f"{col}⇡PR#{num}{(' ' + icon) if icon else ''}{R}"

    # セッション名（並列ペイン判別用・長すぎは丸める）
    sess = (d.get("session_name") or "").strip()
    if len(sess) > 24:
        sess = sess[:23] + "…"

    # コンテキスト / トークン / コスト
    cw = d.get("context_window", {})
    pct = int(cw.get("used_percentage") or 0)
    used = int(cw.get("total_input_tokens") or 0)
    total = int(cw.get("context_window_size") or 200000)
    cost = float((d.get("cost") or {}).get("total_cost_usd") or 0)

    def fmt(n):
        if n >= 1_000_000: return f"{n / 1_000_000:.1f}M"
        if n >= 1_000:     return f"{n // 1000}k"
        return str(n)
    tokens = f"{fmt(used)}/{fmt(total)}"

    # プログレスバー（使用率で着色）
    filled = min(pct // 10, 10)
    barcol = RED if pct >= 90 else YELLOW if pct >= 70 else GREEN
    bar = f"{barcol}{'█' * filled}{'░' * (10 - filled)}{R}"

    # レート制限（Pro/Max のみ・API応答後に出現）。↻ はリセットまでの残り
    now = time.time()

    def reset_str(ts):
        if not ts:
            return ""
        dt = ts - now
        if dt <= 0:
            return "now"
        h = dt / 3600
        if h < 1:  return f"{int(dt / 60)}m"
        if h < 48: return f"{h:.1f}h"
        return f"{h / 24:.0f}d"

    def rlpart(label, win):
        if not win:
            return ""
        p = win.get("used_percentage")
        if p is None:
            return ""
        col = RED if p >= 80 else YELLOW if p >= 50 else GREEN
        rs = reset_str(win.get("resets_at"))
        rs = f" ↻{rs}" if rs else ""
        return f"{col}{label}{round(p)}%{rs}{R}"

    rl = d.get("rate_limits") or {}
    rl_seg = "  ".join(s for s in (
        rlpart("5h ", rl.get("five_hour")),
        rlpart("7d ", rl.get("seven_day")),
    ) if s)

    # line1: 識別
    seg1 = [f"{DIM}{model}{R}", proj]
    if branch:
        seg1.append(f"{CYAN}⎇ {branch}{R}")
    if pr_seg:
        seg1.append(pr_seg)
    if sess:
        seg1.append(f"{DIM}❪{sess}❫{R}")
    print("  ".join(seg1))

    # line2: 指標
    seg2 = [bar, f"{pct}%", f"{DIM}{tokens}  ${cost:.2f}{R}"]
    if rl_seg:
        seg2.append(rl_seg)
    print("  ".join(seg2))


main()
