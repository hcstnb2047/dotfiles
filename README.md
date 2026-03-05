# dotfiles

個人開発環境の設定ファイル管理リポジトリ。WSL/Linux と Windows の両環境に対応。

## 構成

```
dotfiles/
├── install.sh          # WSL/Linux セットアップスクリプト
├── install.ps1         # Windows セットアップスクリプト
├── .claude/
│   ├── commands/       # Claude Code カスタムコマンド (.md)
│   ├── statusline.sh   # Claude Code ステータスライン（bash）
│   └── statusline.py   # Claude Code ステータスライン（Python）
├── bin/
│   ├── lv              # life-claude セッション起動スクリプト
│   └── lvn             # life-claude 新規セッション起動スクリプト
├── tmux/
│   └── .tmux.conf      # tmux 設定
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
Sonnet 4.6  life-claude  ░░░░░░░░░░  9%  18k/200k  $0.45
```

| 項目 | 内容 |
|------|------|
| `Sonnet 4.6` | 使用中のモデル名 |
| `life-claude` | 現在のプロジェクト名 |
| `░░░░░░░░░░` | コンテキスト使用率バー（10段階） |
| `9%` | コンテキスト使用率 |
| `18k/200k` | 使用トークン数 / 最大コンテキストサイズ |
| `$0.45` | セッション累計コスト |

`~/.claude/settings.json` の `statusLine` が `~/.claude/statusline.sh`（dotfilesへのシンボリックリンク）を呼び出す構成。

## 更新の反映

dotfiles を編集・プッシュすると、シンボリックリンク経由で全マシンに即時反映される。`install.sh` の再実行は不要。

```bash
cd ~/dotfiles
# 編集する
git add . && git commit -m "変更内容" && git push
```
