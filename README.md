# dotfiles

個人開発環境の設定ファイル管理リポジトリ。WSL/Linux と Windows の両環境に対応。

## 構成

```
dotfiles/
├── install.sh          # WSL/Linux セットアップスクリプト
├── install.ps1         # Windows セットアップスクリプト
├── .claude/
│   ├── commands/       # Claude Code カスタムコマンド (.md)
│   ├── statusline.sh   # Claude Code ステータスライン（bash・branch表示対応）
│   ├── statusline.py   # Claude Code ステータスライン（Python・git branch検出）
│   └── README.md       # ステータスライン詳細ドキュメント
├── bin/
│   ├── lv              # life-claude セッション起動スクリプト
│   └── lvn             # life-claude 新規セッション起動スクリプト
├── tmux/
│   ├── .tmux.conf      # tmux 設定（下部バーに project ⎇ branch を常時表示）
│   └── tmux-branch.sh  # status-right 用 git ブランチ取得部品（ツール横断）
├── wezterm/
│   └── .wezterm.lua    # WezTerm 設定
└── zsh/
    └── aliases.zsh     # zsh エイリアス定義
```

## セットアップ

### 前提条件

| ツール | Linux/WSL | Windows |
|--------|-----------|---------|
| git | 必須 | 必須 |
| python3 | 必須（statusline用） | — |
| tmux | 推奨 | — |
| zsh | 推奨 | — |
| WezTerm | — | 必須 |
| Claude Code | 推奨 | 推奨 |

### Linux / WSL

```bash
git clone https://github.com/hcstnb2047/dotfiles.git ~/dotfiles
bash ~/dotfiles/install.sh
source ~/.zshrc
```

`install.sh` が行うこと：

- `zsh/aliases.zsh` を `~/.zshrc` に source 追記
- `.claude/commands/*.md` を `~/.claude/commands/` にシンボリックリンク
- `.claude/statusline.sh` / `statusline.py` を `~/.claude/` にシンボリックリンク
- `~/.claude/settings.json` に `statusLine` 設定を注入（既存設定は保持）
- `tmux/.tmux.conf` を `~/.tmux.conf` にシンボリックリンク
- `bin/` 以下のスクリプトを `~/bin/` にシンボリックリンク

### Windows

管理者権限の PowerShell で実行：

```powershell
git clone https://github.com/hcstnb2047/dotfiles.git $env:USERPROFILE\dotfiles
powershell -ExecutionPolicy Bypass -File $env:USERPROFILE\dotfiles\install.ps1
```

`install.ps1` が行うこと：

- `wezterm/.wezterm.lua` を `~\.wezterm.lua` にシンボリックリンク

## Claude Code ステータスライン

ターミナル下部に以下の形式で表示：

```
Sonnet 4.6  life-claude ⎇ main  ░░░░░░░░░░  9%  18k/200k  $0.45
```

| 項目 | 内容 |
|------|------|
| `Sonnet 4.6` | 使用中のモデル名 |
| `life-claude` | 現在のプロジェクト名 |
| `⎇ main` | 現在チェックアウト中の git ブランチ（非gitなら非表示） |
| `░░░░░░░░░░` | コンテキスト使用率バー（10段階） |
| `9%` | コンテキスト使用率 |
| `18k/200k` | 使用トークン数 / 最大コンテキストサイズ |
| `$0.45` | セッション累計コスト |

`~/.claude/settings.json` の `statusLine` が `~/.claude/statusline.sh`（dotfilesへのシンボリックリンク）を呼び出す構成。

仕組み・各設定値の意味・カスタマイズ・トラブルシュートは [.claude/README.md](.claude/README.md) を参照。

## tmux ステータスバー（ツール横断）

Claude Code のステータスラインは Claude のセッション内でしか出ない。Codex CLI には自前ステータスラインを差し込む仕組みが無いため、**ツールを問わず常時見える git ブランチ／プロジェクトは tmux 下部バー（`status-right`）に出す**。Claude でも Codex でも素のシェルでも同じく見える。

```
 main  …(window)…   life-claude ⎇ feat/foo   2026-06-22 13:08
```

| 項目 | 内容 |
|------|------|
| `life-claude` | カレントペインのディレクトリ名（tmux ネイティブ `#{b:pane_current_path}`） |
| `⎇ feat/foo` | カレントペインの git ブランチ（`tmux/tmux-branch.sh` が返す・非gitなら非表示） |
| `2026-06-22 13:08` | 日時（既存） |

- `pane_current_path` 基準なので、worktree（`life-claude-<task>`）でも仕事の別リポジトリでも、そのペインのリポジトリのブランチが出る。
- `status-interval`（15秒）ごとに再描画＝ブランチ切替も追従。
- `.tmux.conf` は `~/dotfiles/tmux/tmux-branch.sh` を絶対パスで参照する（dotfiles を `~/dotfiles` にクローンしている前提）。
- モデル名・コンテキスト％は各ツールの TUI フッターが出すので、**tmux バー（project+branch）＋ ツールのフッター（model+context）** で Claude のステータスラインと同等の情報量になる。

### ブランチ表示の住み分け

git ブランチを出す面は2つ。**WezTerm ネイティブには意図的に入れていない**。

| 面 | 表示 | 効く範囲 |
|----|------|----------|
| Claude ステータスライン | `⎇ branch` | Claude Code セッション内 |
| tmux 下部バー | `project ⎇ branch` | tmux 内なら何でも（Claude / Codex / 素のシェル） |
| WezTerm | （入れない） | — tmux バーが代替 |

WezTerm に入れない理由：常に WezTerm の中で tmux を回す運用のため、WezTerm からは「tmux クライアント1個」しか見えず、**アクティブな tmux ペインの cwd/ブランチは取得できない**（`pane:get_current_working_dir()` は OSC 7 依存で、zsh は未送出）。ペイン単位の正確なブランチは tmux バーが既に出しているので、WezTerm 版は二重表示＆精度低下になるだけ。tmux を使わず WezTerm 直叩きする運用が増えたら「tmux 外だけ出す」版を検討する。

## 更新の反映

dotfiles を編集・プッシュすると、シンボリックリンク経由で全マシンに即時反映される。`install.sh` の再実行は不要。

```bash
cd ~/dotfiles
# 編集する
git add . && git commit -m "変更内容" && git push
```
