dotfilesの編集を支援するスキル。以下のルールを必ず守ること。

## dotfilesの構成

- WezTermの設定: `/mnt/c/Users/yooct/dotfiles/wezterm/.wezterm.lua`
- zshエイリアス: `/mnt/c/Users/yooct/dotfiles/zsh/aliases.zsh`
- Windowsインストール用: `/mnt/c/Users/yooct/dotfiles/install.ps1`
- WSL/Linuxインストール用: `/mnt/c/Users/yooct/dotfiles/install.sh`

## 確立済みのルール

### WezTerm
- 背景透過度: フォーカス時 `0.35` / 非フォーカス時 `0.15`（`focus-changed`イベントで制御）
- バックドロップ: `Mica`（Windows 11）
- フォント順: JetBrains Mono → Cascadia Code → BIZ UDGothic → Noto Sans JP
- カラースキーム: macOS Catalina 深海ブルー系カスタム（`background = '#0d1b2a'`）
- フォーカスアウト時の暗転は無効（`inactive_pane_hsb` で `saturation=1.0, brightness=1.0`）
- フロントエンド: `OpenGL`（ちらつき対策）

### zsh
- エイリアスは `zsh/aliases.zsh` に追記する
- `dotfiles()` 関数で `claude /mnt/c/Users/yooct/dotfiles` を起動

### git
- **作業後は必ず `git push` すること**

## 手順

1. 編集対象のファイルを読み込んで現在の設定を確認する
2. ユーザーに何を変更したいか聞く
3. 上記ルールと矛盾しないか確認してから編集する
4. 編集後に変更内容のサマリーを表示する
5. コミット・pushして完了
