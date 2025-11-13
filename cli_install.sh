#!/usr/bin/env bash

# Include required libraries
source ./std.sh
source ./pretty-print.sh
source ./install_helper.sh
source ./home_files/shellenv


### ENVIRONMENT DETECTION ###
txt_attr_name=$(txt_attr $FG_COLOR_LIGHT_GREEN)
print_title "Environment: $txt_attr_name $ENV_OS_NAME $ENV_OS_VERSION ($ENV_OS_BUILD_VERSION) | $ENV_ARCH_NAME""$reset_all\n"


### INSTALL ###
echo
print_title "Install and/or update Homebrew:\n"

brew_export_shell_environment

if command -v brew &> /dev/null; then
  echo "Already installed, updating"
  brew update;brew upgrade
else
  echo "Not installed, installing"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

  if brew_export_shell_environment && ! command -v brew &> /dev/null; then
    echo "Brew not installed, aborting."
    exit $EXIT_FAILURE
  fi
fi


### NOGO APPS/TOOLS & WHY ###
# "atom"              // Using alternative: VSCode
# "brackets"          // Using alternative: VSCode
# "brave-browser"     // Using alternative: Zen
# "cakebrew"          // Disabled: Discontinued upstream
# "cheatsheet"        // Using alternative: Keyclu
# "dash3"             // No more available in repo
# "diff-so-fancy"     // Using alternative: git-delta
# "dozer"             // Using alternative: Hidden Bar - from mas as this is not native Apple Silicon
# "flux"              // Using alternative: macOS Night Shift
# "google-chrome"     // Using alternative: Zen
# "impactor"          // Disabled: Discontinued upstream
# "jd-gui"            // Unidentified developer (signature), no permission
# "openssh"           // OpenSSH does not support 'UseKeychain' option introduced in macOS 10.12.2+
#                     // To use this version, add "IgnoreUnknown UseKeychain" in config file before using it.
# "quicklookapk"      // Disabled: Discontinued upstream
# "realm-studio"      // Deprecated legacy software since acquisition by MongoDB
# "slack"             // Installed via mas
# "swiftlint"         // Requires Xcode App
# "tftpserver"        // No more available in repo
# "the-unarchiver"		// Using mas
# "vagrant"           // On demand
# "vagrant-manager"   // Runs with Vagrant
# "warp"							// Not yet usable (too early alpha stage)


echo
print_title "Register Brew Taps:\n"
taps=(
  "cirruslabs/cli"
  "slp/krunkit"
)
brew_register_taps taps[@]


echo
print_title "Install Shells:\n"
shells=(
  "bash"
  "bash-completion@2"
  "bash-preexec"          # Bash pre-execution hook for Zsh-like 'precmd' functionality
  "zsh"
)
brew_batch_install shells[@]


echo
print_title "Install cli tools\n"
cli_tools=(
  "1password-cli"
  "aria2"           # Download utility
  "atuin"           # A modern, easy-to-use shell history manager
  "autoconf"
  "bat"             # Cat with syntax highlighting and Git integration
  "binutils"
  "carapace"        # A shell autocomplete library
  "coreutils"
  "curl"            # Get a file from HTTP(s)/FTP servers
  "dav1d"           # AV1 decoder
  "ed"
  "exiftool"        # Read and write EXIF metadata
  "eza"             # ls replacement
  "fd"              # Simple, fast and user-friendly alternative to find
  "ffmpeg"          # Audio/Video converter and manipulator
  "findutils"
  "fzf"             # Command-line fuzzy finder written in Go
  "gawk"
  "gnu-indent"
  "gnu-sed"
  "gnu-tar"
  "gnu-which"
  "gnupg"
  "graphviz"
  "grep"
  "gzip"
  "krunkit"         # Start macOS Hypervisor framework virtual machines using the libkrun platform
  "librsvg"         # SVG rendering library
  "mailsy"          # Generate temporary email address
  "mas"
  "media-info"      # Display information about media files
  "mpv"             # Media player
  "neofetch"        # Customisable system info script
  "neovim"          # Vim-fork focused on extensibility and agility
  "rclone"          # Rsync for cloud storage
  "rg"              # Search tool, rg stands for ripgrep
  "rsync"           # Remote file synchronization tool (fast incremental file transfer)
  "rsyncy"          # Status/progress bar for rsync
  "screen"
  "spicetify-cli"   # Take control of the Spotify client
  "sshs"              # Graphical command-line client for SSH
  "starship"        # Cross-shell prompt for astronauts
  "cirruslabs/cli/tart"
  "tlrc"            # Official tldr , Simplified and community-driven man pages
  "tmux"            # Terminal multiplexer
  "tpm"             # Plugin manager for tmux
  "tree"
  "vitorgalvao/tiny-scripts/cask-repair"
  "wifi-password"   # Show recorded WiFi password
  "yt-dlp"          # Audio/Video downloader
  "zoxide"
)
brew_batch_install cli_tools[@]


echo
print_title "Install developer cli tools\n"
developer_tools=(
  "ack"
  "android-commandlinetools"      # Android command line tools
  "ansifilter"                    # Strip or convert ANSI codes into HTML, (La)Tex, RTF, or BBCode
  "asdf"                          # Extendable version manager
  "boost"
  "carthage"
  "chisel"
  "cocoapods"
  "composer"
  "dex2jar"
  "diffutils"
  "docker"                          # Pack, ship and run any application as a lightweight container
  "file-formula"
  "gh"                              # GitHub command-line tool
  "git"
  "git-delta"                       # A viewer for git and diff output
	"git-extras"                      # Small git utilities
  "git-filter-repo"                 # Rewrite git repository history
  "git-lfs"
  "git-quick-stats"
  "gnutls"
  "grc"                           # Colorize logfiles and command output
  "httpie"
  "ios-deploy"                # CLI to Install and debug iPhone apps
  "jq"
  "mitmproxy"
  "ocaml"
  "gradle"
  "podman"                    # Tool for managing OCI containers and pods
  "perl"
  "ruby"
  "sonar-scanner"
  "swift-format"              # Formatting technology for Swift source code
  "swiftlint"                 # Tool to enforce Swift style and conventions
  "svn"
  "tig"
  "tuist"                     # Manage Xcode projects
  "vim"
  "watch"
  "watchman"
  "wdiff"
  "wget"
  "xcbeautify"                # Little beautifier tool for xcodebuild
  "xcode-build-server"        # Build server for integrating Xcode with sourcekit-lsp
  "xcodegen"                  # Generate Xcode project from a spec file
  "xcodes"                    # Manage multiple versions of Xcode
  "yazi"                      # Modern, lightweight, and fast terminal file manager
)
brew_batch_install developer_tools[@]


echo
print_title "Update built-in macOS tools to last GNU version\n"
built_in_update=(
  "emacs"
  "gpatch"
  "m4"
  "make"
  "nano"
)
brew_batch_install built_in_update[@]


echo
print_title "Update non-GNU commands\n"
non_gnu=(
  "less"
)
brew_batch_install non_gnu[@]


echo
print_title "Install Image Tools\n"
image_tools=(
  "fftw"
  "graphicsmagick"
  "imagemagick"
)
brew_batch_install image_tools[@]


echo
print_title "Install Browsers (Cask)\n"
cask_browsers=(
  "alex313031-thorium"        # Chromium based web browser (Performance & Privacy Focus)
  "arc"                       # Chromium based web browser (The Browser Company)
  "blisk"                     # Chromium based web browser (Developer-oriented browser)
  "chatgpt-atlas"             # OpenAI's Web Browser with ChatGPT built
  "firefox"                   # Mozilla Web Browser
  "helium-browser"            # Chromium-based web browser (Privacy Focus)
  "microsoft-edge"            # Microsoft Web Browser
  "opera"                     # Opera Web Browser
  "responsively"              # Responsive web development Browser (Electron based)
  "thebrowsercompany-dia"     # Chromium based web browser (AI Focused, The Browser Company)
  "tor-browser"               # Web Browser focusing on Security
  "zen"                       # Zen Browser
)
brew_batch_install cask_browsers[@]


echo
print_title "Install AI Apps (Cask)\n"
ai_apps=(
  "anythingllm"               # Chat with any LLM
  "jan"                       # Offline AI chat tool
  "lm-studio"                 # Discover, download, and run local LLMs
  "ollama-app"                # Discover, download, and run local LLMs
  "onlook"                    # Open-Source AI-First Design tool
  "opcode"                    # Claude Code desktop companion
  "github-copilot-for-xcode"  # GitHub Copilot for Xcode
  "trae"                      # AI code editor
  "void"                      # Open-Source AI code editor
)
brew_batch_install ai_apps[@]


echo
print_title "Install Applications (Cask)\n"
ui_apps=(
  "android-studio"
  "angry-ip-scanner"
  "anydesk"
  "appcleaner"
  "asset-catalog-tinkerer"
  "atuin-desktop"             # A modern, easy-to-use shell history manager
  "balenaetcher"              # Flash OS images to SD cards and USB drives
  "beeper"                    # Universal chat app powered by Matrix
  "blobsaver"                 # GUI for automatically saving SHSH blobs
	"bluesnooze"                # Prevents sleeping computer from connecting to Bluetooth accessories
  "calibre"                   # E-book reader and manager
  "charles"                   # Web debugging Proxy application
  "clickup"                   # Productivity platform for tasks, docs, goals, and chat
  "coconutbattery"            # Battery status and monitoring
  "cursor"                    # Write, edit, and chat about your code with AI
  "dbeaver-community"
  "dbngin"
  "deezer"                    # Music streaming service
  "devcleaner"                # Xcode cache cleaner
  "devtoys"                   # Common development utilities
  "discord"                   # Chat and messaging app
  "easyfind"                  # Find files and folders quickly
	"figma"
  "flixtools"
  "fork"
  "ghostty"                   # Modern, lightweight, and fast terminal emulator
  "gitbutler"                 # Git client for simultaneous branches
  "gitup-app"                 # Git interface focused on visual interaction
  "hammerspoon"               # macOS automation tool
  "handbrake-app"             # Open-source video transcoder
  "hiddenbar"                 # Customizable menu bar for macOS
  "iina"                      # Media player
  "imageoptim"                # Image optimizer to a smaller size
  "intellij-idea-ce"
	"ios-app-signer"            # Signing iOS apps with a developer account
  "iterm2"
  "itsycal"                   # Menu bar calendar
  "jdownloader"               # Download manager
  "jordanbaird-ice"           # Menu bar manager
  "keepingyouawake"
  "keka"                      # File archiver
	"keycastr"
  "keyclu"
  "kid3"                      # Audio tagger focusing on efficiency
  "latest"                    # Shows latest app updates
  "localsend"                 # Open-source cross-platform alternative to AirDrop
  "logseq"                    # Open-source & Privacy-first platform for knowledge sharing and management
  "lulu"                      # Open-source firewall to block unknown outgoing connections
	"maccy"
  "maciasl"
  "messenger"                 # Facebook Messenger
  "miro"                      # Realtime collaborative whiteboard app
  "mist"                      # Utility to downloads macOS firmwares and installers
  "monitorcontrol"
  "ngrok"                     # Reverse proxy, secure introspectable tunnels to localhost
  "notion"
	"obsidian"
  "onyx"                      # System maintenance and more
  "openmtp"                   # Android file transfer
  "oversight"                 # Monitors computer mic and webcam
  "pearcleaner"               # Remove apps & leftover files
	"pinentry-mac"
  "podman-desktop"            # Desktop interface for Podman
  "postman"                   # API platform for building and using APIs
	"proxyman"
  "raindropio"                # All-in-one bookmark manager
  "rapidapi"                  # HTTP client that helps testing and describing APIs
  "raycast"                   # Spotlight replacement
  "react-native-debugger"
  "rectangle"
  "rocket"                    # Emoji picker
	"sloth"
  "signal"
  "silentknight"
  "sloth"
	"sourcetree"
  "spacedrive"                # Open-source cross-platform file explorer
  "spotify"
  "tempbox"                   # Disposable email client
  "thorium"                   # Epub reader
  "thunderbird"               # Email client
  "transmission"              # BitTorrent client
  "transnomino"               # Batch rename utility
  "Upscayl"                   # AI image upscaler
  "utm"                       # Virtual machines
  "visual-studio-code"        # Microsoft VS Code
  "vlc"
  "wezterm"                   # GPU-accelerated cross-platform terminal emulator and multiplexer
  "whatsapp"                  # WhatsApp Messenger
  "whisky"                    # Wine wrapper for macOS
  "wwdc"
	"xattred"
  "xcodes-app"                # CLI to Manage multiple versions of Xcode
  "zed"                       # Multiplayer code editor
  "zeplin"
)
brew_batch_install ui_apps[@]


echo
print_title "Install QuickLook Plugin (Cask)\n"
ql_plugins=(
  "qlcolorcode"
  "qlgradle"
  "qlmarkdown"
  "qlstephen"
  "quicklook-json"
  "provisionql"
	"syntax-highlight"          # Syntax highlighting for QuickLook
)
brew_batch_install ql_plugins[@]


echo
print_title "Install ScreenSavers (Cask)\n"
screensavers=(
  "aerial"    # Apple TV Aerial screensaver
  "fliqlo"    # Flip clock screensaver
)
brew_batch_install screensavers[@]


echo
print_title "Install Fonts (Cask)\n"
fonts=(
  "font-noto-nerd-font"                 # NotoMono Nerd Font + Mono/Propo
  "font-roboto-mono-nerd-font"          # RobotoMono Nerd Font (default) + Mono/Propo
  "font-dejavu-sans-mono-nerd-font"     # DejaVuSansM Nerd Font + Mono/Propo
  "font-hack-nerd-font"                 # Hack Nerd Font + Mono/Propo
  "font-geist-mono-nerd-font"           # GeistMono Nerd Font + Mono/Propo
  "font-fira-mono-nerd-font"            # FiraMono Nerd Font + Mono/Propo
  "font-meslo-lg-nerd-font"             # MesloLGL Nerd Font / MesloLGLDZ Nerd Font / MesloLGM Nerd Font / MesloLGMDZ Nerd Font / MesloLGS Nerd Font / MesloLGSDZ Nerd Font (+ Mono/Propo)
  "font-lilex-nerd-font"                # Lilex Nerd Font + Mono/Propo
  "font-ubuntu-mono-nerd-font"          # UbuntuMono Nerd Font + Mono/Propo
)
brew_batch_install fonts[@]


echo
print_title "Install packages from 'Unidentified Developer' (Cask)\n"
echo "Requires open authorization in 'System Preferences > Security & Privacy > General'"
unidentified=(
  "oclint"
)
brew_batch_install unidentified[@]


echo
print_title "Install Cask packages with user action required\n"
action_required=(
  "karabiner-elements"          # Requires Password | Keyboard customizer for macOS 
  "sdformatter"                 # Requires Password | Formatter for SD cards
  "sf-symbols"                  # Requires Password | Apple SF Symbols app
)
brew_batch_install action_required[@]


echo
print_title "Drivers and other Hardware apps (Cask)\n"
drivers=(
  "logi-options+"              # Logitech Options+
)
brew_batch_install drivers[@]


### ARCH TARGET APPS/TOOLS ###
echo
print_title "Install x86_64 arch tools & apps:\n"
arch_x86_64_only=(
	"clementine"
	"sequel-pro"
	"sketch-toolbox"
	"virtualbox"                  # Requires Password
  "virtualbox-extension-pack"
	"apktool"
  "sonarqube"                   # Requires Java
  "sonar-scanner"               # Runs with sonarqube
  "sonar-completion"            # Runs with sonarqube  
)
arch_rosetta_compat=(
	"android-file-transfer"
	"caption"
	"charles"
	"gas-mask"
	"geektool"
	"macdown"
  "mkvtoolnix-app"            # Create, alter and inspect Matroska files (MKV)
  "mkvtools"                  # Create and edit Matroska files (MKV)
	"openemu"
	"opensim"
	"pusher"
  "stremio"                   # Media streaming client
)

if [ "$ENV_ARCH_NAME" == "$ENV_ARCH_X86_64" ]; then
  echo
  print_title "Install x86_64 arch tools & apps:\n"
  brew_batch_install arch_x86_64_only[@]

  # If arch is emulated
  if [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
    echo
    print_title "Install Rosetta apps:\n"
    brew_batch_install arch_rosetta_compat[@]
  fi
fi


echo
print_title "Cleanup\n"
echo "Cleanup in progress..."
cleanup_output=$(brew cleanup -s 2>&1)
echo "Cleanup finished"
echo "$cleanup_output" | grep "^==>" | tail -1
rm -rf $(brew --cache) 2>/dev/null


echo
print_title "Brew packages installation DONE!\n"


echo
print_title "Dotfiles installation\n"
dotfiles_symlink "home_files"


echo
print_title "Update user default Shell (Requires Password):\n"
add_acceptable_shell `command -v bash` default
add_acceptable_shell `command -v zsh`


if command -v asdf &> /dev/null; then
  mkdir -p "$HOME/.asdf"
  _init_asdf

  # Install asdf plugins
  echo
  print_title "Install asdf plugins\n"
  asdf_plugins=( "nodejs" "pnpm" "java" "yarn" "python" )
  asdf_batch_install_plugins asdf_plugins[@]

  # Install asdf tool versions (tool:version:set_home[true/false])
  echo
  print_title "Install asdf tool versions\n"
  asdf_versions=(
    "nodejs:lts:true"           # Install Node.js LTS and set as global
    "nodejs:latest:false"       # Install Node.js latest
    "pnpm:latest:true"          # Install pnpm latest and set as global (requires Node.js)
    "yarn:latest:true"          # Install yarn latest and set as global (requires Node.js)
    "java:8:false"              # Install latest Java 8 (reference version)
    "java:17:false"             # Install latest Java 17
    "java:21:true"              # Install latest Java 21 LTS and set as global
    "java:latest:false"         # Install latest Java version
    "python:latest:true"        # Install Python latest and set as global
  )
  asdf_batch_install_versions asdf_versions[@]
fi


echo
print_title "Install Mac AppStore Apps\n"
./mas_installer.sh
