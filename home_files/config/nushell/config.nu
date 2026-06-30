## Nushell configuration
## This file is symlinked to ~/.config/nushell/config.nu
##
## Starship prompt integration
## ----------------------------
## Nushell 0.111+ has stricter rules around `source` and parse-time constants,
## so instead of an init.nu file we directly invoke the Starship binary for the
## prompt. This still uses the same `starship.toml` as bash/zsh via env.nu.

# Use Starship for the main prompt (same config as other shells)
$env.PROMPT_COMMAND = { ||
    starship prompt
}

# Disable nushell's built-in right-side prompt (date/time)
$env.PROMPT_COMMAND_RIGHT = { || "" }

# Let Starship's character module control the visible indicator
$env.PROMPT_INDICATOR = { || "" }
$env.PROMPT_INDICATOR_VI_INSERT = { || "" }
$env.PROMPT_INDICATOR_VI_NORMAL = { || "" }

# Optional: simple multiline indicator, Starship still renders the main line
$env.PROMPT_MULTILINE_INDICATOR = { || "::: " }

# Atuin shell history integration
# To regenerate: atuin init nu > ~/.local/share/atuin/init.nu
source ~/.local/share/atuin/init.nu

# Zoxide — replaces cd with smart directory jumping
# To regenerate: zoxide init nushell --cmd cd > ~/.local/share/zoxide/init.nu
source ~/.local/share/zoxide/init.nu
