local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ドメイン設定
config.default_domain = 'WSL:Ubuntu'

-- 半透明設定
-- win32_system_backdrop はwindow_background_opacityの動的変更と干渉するため無効化
config.window_background_opacity = 0.8
-- config.win32_system_backdrop = 'Acrylic'

-- フォーカス離脱時の暗転を無効化
config.inactive_pane_hsb = {
  saturation = 1.0,
  brightness = 1.0,
}

-- フロントエンド（ちらつき対策）
config.front_end = 'OpenGL'

-- フォント設定
config.font = wezterm.font_with_fallback {
  { family = 'JetBrains Mono', weight = 'Regular' },
  { family = 'Cascadia Code',  weight = 'Regular' },
  -- 日本語: BIZ UDGothic (ユニバーサルデザイン、視認性最優先)
  { family = 'BIZ UDGothic',   weight = 'Regular' },
  -- フォールバック
  { family = 'Noto Sans JP',   weight = 'Regular' },
}
config.font_size = 12.0
config.line_height = 1.2

-- カラースキーム (macOS Catalina 深海ブルー系カスタム)
config.colors = {
  foreground            = '#cdd6f4',
  background            = '#0d1b2a',
  cursor_bg             = '#64b5f6',
  cursor_border         = '#64b5f6',
  cursor_fg             = '#0d1b2a',
  selection_bg          = '#1e4976',
  selection_fg          = '#cdd6f4',

  ansi = {
    '#1a2a3a',  -- black
    '#ef5350',  -- red
    '#26c6da',  -- green  → シアン系
    '#42a5f5',  -- yellow → 青系
    '#1565c0',  -- blue   → ディープブルー
    '#7986cb',  -- magenta → インディゴ
    '#00acc1',  -- cyan
    '#b0bec5',  -- white
  },
  brights = {
    '#37474f',  -- bright black
    '#ff7043',  -- bright red
    '#4dd0e1',  -- bright green → 明るいシアン
    '#64b5f6',  -- bright yellow → 明るい青
    '#1e88e5',  -- bright blue
    '#9fa8da',  -- bright magenta
    '#26c6da',  -- bright cyan
    '#eceff1',  -- bright white
  },

  tab_bar = {
    background        = '#0a1628',
    active_tab        = { bg_color = '#1565c0', fg_color = '#eceff1' },
    inactive_tab      = { bg_color = '#0d1b2a', fg_color = '#546e7a' },
    inactive_tab_hover = { bg_color = '#1a2a3a', fg_color = '#90a4ae' },
    new_tab           = { bg_color = '#0a1628', fg_color = '#546e7a' },
    new_tab_hover     = { bg_color = '#1a2a3a', fg_color = '#90a4ae' },
  },
}

-- ウィンドウ設定
config.window_decorations = 'TITLE|RESIZE'  -- タイトルバー + リサイズ有効
config.window_padding = {
  left = 8,
  right = 8,
  top = 4,
  bottom = 4,
}
config.initial_cols = 160
config.initial_rows = 40

-- タブバー設定
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true

-- スクロールバック
config.scrollback_lines = 10000

-- カーソル
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500

-- パフォーマンス
config.animation_fps = 60
config.max_fps = 60

-- キーバインド
config.keys = {
  -- amical (音声入力) が Ctrl+V でクリップボードからペーストするため
  { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
  -- タブ操作
  { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = false } },
  -- ペイン分割
  { key = 'd', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'e', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  -- フォントサイズ調整
  { key = 'u', mods = 'CTRL|SHIFT', action = wezterm.action.IncreaseFontSize },
  { key = 'd', mods = 'CTRL',       action = wezterm.action.DecreaseFontSize },
  -- マウスレポートを全モード無効化
  { key = 'F12', mods = '', action = wezterm.action.SendString(
    '\x1b[?1000l\x1b[?1002l\x1b[?1003l\x1b[?1006l\x1b[?1015l'
  ) },
}

-- フォーカスアウト時の透明度 (フォーカス: 0.35 / 非フォーカス: 0.15)
wezterm.on('window-focus-changed', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if window:is_focused() then
    overrides.window_background_opacity = 0.8
  else
    overrides.window_background_opacity = 0.75
  end
  window:set_config_overrides(overrides)
end)

return config
