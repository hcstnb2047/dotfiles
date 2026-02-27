WezTermの設定ファイル（`wezterm/.wezterm.lua`）を読み込み、編集を支援するコマンド。

## 手順

1. `wezterm/.wezterm.lua` を Read して現在の設定を表示する
2. 変更したい箇所をユーザーに確認する
3. `dotfiles.md` の確立済みルールと矛盾しないか確認してから編集する
4. 変更内容のサマリーを表示する
5. 変更内容を見て適切なコミットメッセージを考え、commit & push して完了

## 編集時の注意

- `window_background_opacity` と `win32_system_backdrop` は併用不可（干渉する）
- `config.keys` に新しいキーバインドを追加する際は既存バインドと競合しないか確認する
- マウスレポーティング関連の変更は `F12` バインドと整合性を保つこと
