## Nushell environment configuration
## This file is symlinked to ~/.config/nushell/env.nu
##
## It wires Nushell to use the same Starship configuration as bash/zsh/etc.

# Path to the shared Starship configuration (reuse the same file as bash/zsh)
$env.STARSHIP_CONFIG = ($env.HOME | path join ".config" "starship" "starship.toml")

# Explicitly tell Starship which shell is running
$env.STARSHIP_SHELL = "nu"

# Atuin shell history — session UUID (must be set before config.nu sources init.nu)
if not (which atuin | is-empty) {
    $env.ATUIN_SESSION = (atuin uuid)
}

