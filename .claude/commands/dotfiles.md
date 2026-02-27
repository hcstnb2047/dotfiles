dotfilesの編集を支援するコマンド。以下のルールを必ず守ること。

## dotfilesの構成

リポジトリルートからの相対パス:

| ファイル | 用途 |
|---------|------|
| `wezterm/.wezterm.lua` | WezTerm設定（Windows側に配置） |
| `zsh/aliases.zsh` | zshエイリアス定義 |
| `install.ps1` | Windowsセットアップスクリプト |
| `install.sh` | WSL/Linuxセットアップスクリプト |

編集時は必ずファイルを Read してから変更すること。

## 確立済みのルール

### WezTerm
- 背景透過度: フォーカス時 `0.8` / 非フォーカス時 `0.75`（`window-focus-changed`イベントで制御）
- バックドロップ: 無効（`win32_system_backdrop`は`window_background_opacity`と干渉するためコメントアウト）
- フォント順: JetBrains Mono → Cascadia Code → BIZ UDGothic → Noto Sans JP
- カラースキーム: macOS Catalina 深海ブルー系カスタム（`background = '#0d1b2a'`）
- フォーカスアウト時の暗転は無効（`inactive_pane_hsb` で `saturation=1.0, brightness=1.0`）
- フロントエンド: `OpenGL`（ちらつき対策）
- スクロールバック: `10000`行
- `Ctrl+V`: クリップボードペースト（音声入力Amical対応）
- `F12`: マウスレポーティング全モード無効化（Claude Code使用後のスクロール復旧用）

### zsh
- エイリアスは `zsh/aliases.zsh` に追記する

### git
- **作業後は必ず commit & push すること。コミットメッセージは変更内容を見て適宜考える**

## 手順

1. 編集対象のファイルを Read して現在の設定を確認する
2. ユーザーに何を変更したいか聞く（未指定の場合）
3. 上記ルールと矛盾しないか確認してから編集する
4. 編集後に変更内容のサマリーを表示する
5. コミット・pushして完了
