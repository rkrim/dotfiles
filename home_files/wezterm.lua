-- Pull in the wezterm API
local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- Window appearance
config.initial_cols = 120
config.initial_rows = 32
config.adjust_window_size_when_changing_font_size = false
config.macos_window_background_blur = 30
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_max_width = 32
config.window_background_opacity = 0.95
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.integrated_title_buttons = { 'Close' }
config.integrated_title_button_alignment = "Right"
config.integrated_title_button_style = "MacOsNative"
-- config.integrated_title_button_style = "Gnome"

-- Font
config.font_size = 16.0
config.font = wezterm.font_with_fallback({
    'MesloLGM Nerd Font',
    'NotoSansM Nerd Font Mono',
})
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.color_scheme = 'Tokyo Night Storm'

-- Cursor and scrollback
config.default_cursor_style = 'SteadyBar'
config.cursor_thickness = 3
config.animation_fps = 120
config.max_fps = 120
config.scrollback_lines = 20000

-- Bell
config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 100,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 100,
}

-- Colors
config.colors = {
  visual_bell = '#1f2335',
  tab_bar = {
    background = '#0b0f17',
    active_tab = {
      bg_color = '#1f2335',
      fg_color = '#c0caf5',
    },
    inactive_tab = {
      bg_color = '#0b0f17',
      fg_color = '#6b7089',
    },
    inactive_tab_hover = {
      bg_color = '#111827',
      fg_color = '#a6accd',
    },
    new_tab = {
      bg_color = '#0b0f17',
      fg_color = '#6b7089',
    },
    new_tab_hover = {
      bg_color = '#111827',
      fg_color = '#a6accd',
      italic = true,
    },
  },
}

-- Keyboard configuration
config.disable_default_key_bindings = false
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true
config.use_dead_keys = true

-- Leader and keymaps
config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 1500 }
config.keys = {
  -- For French keyboard, you need to let macOS handle right Option completely
  { key = 'n', mods = 'OPT', action = wezterm.action.SendString('~'), },
  -- Window management
  { key = 'f', mods = 'CTRL', action = wezterm.action.ToggleFullScreen },
  -- Pane splitting
  { key = 'h', mods = 'LEADER', action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = 'v', mods = 'LEADER', action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }) },
  -- Pane navigation
  { key = 'LeftArrow', mods = 'SUPER', action = wezterm.action.ActivatePaneDirection('Left') },
  { key = 'DownArrow', mods = 'SUPER', action = wezterm.action.ActivatePaneDirection('Down') },
  { key = 'UpArrow', mods = 'SUPER', action = wezterm.action.ActivatePaneDirection('Up') },
  { key = 'RightArrow', mods = 'SUPER', action = wezterm.action.ActivatePaneDirection('Right') },
  -- Tabs
  { key = 'n', mods = 'CTRL', action = wezterm.action.SpawnWindow },
  { key = 't', mods = 'CTRL', action = wezterm.action.SpawnTab('CurrentPaneDomain') },
  { key = 'w', mods = 'CTRL', action = wezterm.action.CloseCurrentPane({ confirm = false }) },
  -- Switch tabs with Option-Number
  { key = '1', mods = 'ALT', action = wezterm.action.ActivateTab(0) },
  { key = '2', mods = 'ALT', action = wezterm.action.ActivateTab(1) },
  { key = '3', mods = 'ALT', action = wezterm.action.ActivateTab(2) },
  { key = '4', mods = 'ALT', action = wezterm.action.ActivateTab(3) },
  { key = '5', mods = 'ALT', action = wezterm.action.ActivateTab(4) },
  { key = '6', mods = 'ALT', action = wezterm.action.ActivateTab(5) },
  { key = '7', mods = 'ALT', action = wezterm.action.ActivateTab(6) },
  { key = '8', mods = 'ALT', action = wezterm.action.ActivateTab(7) },
  { key = '9', mods = 'ALT', action = wezterm.action.ActivateTab(-1) },
}

-- Dynamic right status (workspace, clock)
wezterm.on('update-right-status', function(window, _)
  local date = wezterm.strftime('%a %b %d %H:%M')
  local ws = window:active_workspace()
  window:set_right_status(wezterm.format({
    { Text = ' ' .. ws .. '  ' },
    { Foreground = { AnsiColor = 'Fuchsia' } },
    { Text = date .. ' ' },
  }))
end)

return config
