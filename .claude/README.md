# .claude/ — Claude Code 設定

Claude Code（CLI）のグローバル設定（`~/.claude/`）のうち、dotfiles で管理する分。

```
.claude/
├── commands/       # カスタムスラッシュコマンド (.md)
├── statusline.sh   # ステータスライン本体（bash・整形/描画担当）
├── statusline.py   # ステータスライン入力パーサ（Python・JSON→変数）
└── README.md       # このファイル
```

install 方法（`install.sh` が `~/.claude/` へ symlink）は親リポジトリの [README.md](../README.md) を参照。

---

## ステータスライン

ターミナル最下部に、現在のセッション状態を1行で表示する。

```
Sonnet 4.6  life-claude  ████░░░░░░  37%  74k/200k  $1.23
```

| 表示 | 意味 |
|------|------|
| `Sonnet 4.6` | 使用中モデルの表示名（薄色） |
| `life-claude` | カレントプロジェクト名（ディレクトリ末尾） |
| `████░░░░░░` | コンテキスト使用率バー（10段階・`█`=使用 / `░`=空き） |
| `37%` | コンテキスト使用率 |
| `74k/200k` | 使用トークン数 / 最大コンテキストサイズ（薄色） |
| `$1.23` | セッション累計コスト USD（薄色） |

### 仕組み

Claude Code はステータスライン用コマンドに、セッション状態を **JSON で標準入力に流し込む**。本構成は2ファイルに分担：

```
Claude Code ──(JSON via stdin)──▶ statusline.sh ──pipe──▶ statusline.py
                                       │                       │
                                       │            JSONを解析しシェル変数を出力
                                       │            (MODEL= PROJECT= PCT= ...)
                                       ◀── eval で取り込み ────┘
                                       │
                                       └─ バー生成・色付け・printf で1行描画
```

- **statusline.py** … JSON パース専任。壊れた入力でも安全なデフォルトを返す（`MODEL="claude"` 等）。
- **statusline.sh** … py の出力を `eval` で変数化し、バー描画・ANSI 色付け・整形を行う。

分けている理由：JSON パースは Python が堅牢、整形・ANSI 制御は bash が手軽なため。

### 設定（settings.json）

`~/.claude/settings.json` の `statusLine` で呼び出す。`install.sh` が未設定時に自動注入する。

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline.sh"
  }
}
```

| キー | 意味 |
|------|------|
| `type` | `command` = 外部コマンドの標準出力をステータスラインに使う |
| `command` | 実行するコマンド。stdin に状態JSON が渡され、stdout の1行が表示される |

---

## 各設定値の意味

### statusline.py が読み取る入力JSONのフィールド

Claude Code が渡す JSON のうち、参照しているキー：

| JSONパス | 用途 | 欠損時のフォールバック |
|----------|------|------------------------|
| `model.display_name` | モデル名 | `"claude"` |
| `workspace.project_dir`（無ければ `cwd`） | プロジェクト名の元 | `"-"` |
| `context_window.used_percentage` | 使用率 % | `0` |
| `context_window.total_input_tokens` | 使用トークン数 | `0` |
| `context_window.context_window_size` | 最大コンテキスト | `200000` |
| `cost.total_cost_usd` | 累計コスト | `0` |

`fmt()` でトークン数を短縮表記（`1000→1k` / `1000000→1.0M`）にしている。

### statusline.sh が出力する変数

py が `KEY="value"` 形式で出力 → sh が `eval` で取り込む。

| 変数 | 中身 | 例 |
|------|------|-----|
| `MODEL` | モデル表示名 | `Sonnet 4.6` |
| `PROJECT` | プロジェクト名 | `life-claude` |
| `PCT` | 使用率（整数） | `37` |
| `TOKENS` | 使用/最大トークン | `74k/200k` |
| `COST` | コスト（小数2桁） | `1.23` |

### 描画パラメータ（statusline.sh 内で変更可能）

| 箇所 | 現在値 | 変えると |
|------|--------|----------|
| バー長 | `10`（`PCT / 10` で塗り数を算出） | 段階の粗さが変わる。長くするなら除数も合わせて調整 |
| 塗り/空き文字 | `█` / `░` | バーの見た目 |
| `dim`（`\033[2m`） | 薄色 ANSI | モデル名・トークン・コストの装飾 |
| `printf` フォーマット | 並び順・区切り | 表示項目の順番や区切り（現在は半角スペース2個） |

---

## カスタマイズ例

**バーを20段階に**（`statusline.sh`）：

```bash
filled=$(( PCT / 5 ))      # 100% ÷ 20段 = 5
[ "$filled" -gt 20 ] && filled=20
empty=$(( 20 - filled ))
```

**コスト表示を消す**：`printf` 末尾の `\$%s` と引数 `"$COST"` を削除。

**色を変える**：`dim="\033[2m"` を任意の ANSI に（例 シアン `\033[36m`）。

---

## トラブルシュート

| 症状 | 確認 |
|------|------|
| 何も出ない | `echo '{}' \| bash ~/.claude/statusline.sh` で出力を確認。settings.json に `statusLine` があるか |
| `python3: command not found` | python3 を入れる（このスクリプトの必須依存） |
| 編集が反映されない | `~/.claude/statusline.sh` が dotfiles への **symlink** か確認（`ls -l`）。実体コピーだと dotfiles 編集が効かない → `bash ~/dotfiles/install.sh` で貼り直す |
| 数値がずれる | Claude Code 側の JSON スキーマ変更の可能性。`statusline.py` の参照キーを実際の入力JSONと突き合わせる |
