#!/usr/bin/env bash

# Include required libraries
source ./std.sh
source ./pretty-print.sh
source ./install_helper.sh


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
# "cheatsheet"        // Using alternative: Keyclu
# "dash3"             // No more available in repo
# "dozer"             // Using alternative: Hidden Bar - from mas as this is not native Apple Silicon
# "flux"              // Using alternative: macOS Night Shift
# "jd-gui"            // Unidentified developer (signature), no permission
# "openssh"           // OpenSSH does not support 'UseKeychain' option introduced in macOS 10.12.2+
#                     // To use this version, add "IgnoreUnknown UseKeychain" in config file before using it.
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
  "localsend/localsend"
)
brew_register_taps taps[@]


echo
print_title "Install Shells:\n"
shells=(
  "bash"
  "bash-completion@2"
  "zsh"
)
brew_batch_install shells[@]


echo
print_title "Install cli tools\n"
cli_tools=(
  "1password-cli"
  "autoconf"
  "binutils"
  "coreutils"
  "curl"            # Get a file from HTTP(s)/FTP servers
  "ed"
  "findutils"
  "fzf"
  "gawk"
  "gnu-indent"
  "gnu-sed"
  "gnu-tar"
  "gnu-which"
  "gnupg"
  "graphviz"
  "grep"
  "gzip"
  "librsvg"
  "mailsy"          # Generate temporary email address
  "mas"
  "rsync"
  "screen"
  "spicetify-cli"   # Take control of the Spotify client
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
  "android-commandlinetools"
  "boost"
  "carthage"
  "chisel"
  "cocoapods"
  "composer"
	"diff-so-fancy"
  "dex2jar"
  "diffutils"
  "file-formula"
  "gh"
  "git"
	"git-extras"
  "git-lfs"
  "git-quick-stats"
  "gnutls"
  "httpie"
  "jq"
  "mitmproxy"
  "node"
  "nvm"
  "ocaml"
  "openjdk"
  "openjdk@11"
  "openjdk@17"
  "gradle"
  "perl"
  "pnpm"
  "python"
  "ruby"
  "sonar-scanner"
  "svn"
  "tig"
  "vim"
  "volta"
  "watch"
  "watchman"
  "wdiff"
  "wget"
  "yarn"
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
print_title "Install Applications (Cask)\n"
ui_apps=(
  "alex313031-thorium"
  "android-studio"
  "angry-ip-scanner"
  "anydesk"
  "appcleaner"
  "asset-catalog-tinkerer"
	"Bluesnooze"
  "brave-browser"
  "cakebrew"
  "dbeaver-community"
  "dbngin"
	"figma"
  "firefox"
  "flixtools"
  "fork"
  "google-chrome"
  "handbrake"
  "iina"
  "imageoptim"
  "intellij-idea-ce"
	"ios-app-signer"
  "iterm2"
  "keepingyouawake"
	"keycastr"
  "keyclu"
  "localsend"               # Open-source cross-platform alternative to AirDrop
	"maccy"
  "maciasl"
  "monitorcontrol"
  "ngrok"
  "notion"
	"obsidian"
  "opera"
  "paw"
	"pinentry-mac"
	"proxyman"
  "react-native-debugger"
  "rectangle"
	"sloth"
  "signal"
  "silentknight"
  "sloth"
	"sourcetree"
  "spotify"
  "transmission"
  "transnomino"             # Batch rename utility
  "typora"
  "visual-studio-code"      # Microsoft VS Code
  "vscodium"                # VSCode without MS branding/telemetry/licensing
  "vlc"
  "wwdc"
	"xattred"
  "zeplin"
)
brew_batch_install ui_apps[@]


echo
print_title "Install QuickLook Plugin (Cask)\n"
ql_plugins=(
  "qlcolorcode"
  "qlstephen"
  "qlmarkdown"
  "quicklook-json"
  "provisionql"
	"syntax-highlight"
  "quicklookapk"
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
  "font-noto-nerd-font"
  "font-roboto-mono-nerd-font"    # Use as default
  "font-dejavu-sans-mono-nerd-font"
  "font-commit-mono-nerd-font"
  "font-hack-nerd-font"
  "font-geist-mono-nerd-font"
  "font-fira-mono-nerd-font"
  "font-meslo-lg-nerd-font"
  "font-lilex-nerd-font"
  "font-ubuntu-nerd-font"
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
  "microsoft-edge"              # Requires Password
  "sdformatter"                 # Requires Password
)
brew_batch_install action_required[@]


echo
print_title "Drivers and other Hardware apps (Cask)\n"
drivers=()
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
  "sonarqube"         # Requires Java
  "sonar-scanner"     # Runs with sonarqube
  "sonar-completion"  # Runs with sonarqube  
  "homebrew/cask-drivers/logitech-options"
)
arch_rosetta_compat=(
	"android-file-transfer"
	"balenaetcher"
	"caption"
	"charles"
	"deezer"
	"gas-mask"
	"geektool"
	"imageoptim"
	"impactor"
	"macdown"
	"openemu"
	"opensim"
	"pusher"
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


# Registering different Java versions, v18 available but not yet supported by some tools like Gradle
echo
print_title "Java Virtual Machines registration (Version 11, 17)\n"
JAVA_PATH_11=$(brew --prefix openjdk@11 2> /dev/null)
JAVA_PATH_17=$(brew --prefix openjdk@17 2> /dev/null)
JVM_HOME="/Library/Java/JavaVirtualMachines"
JDK_NAME="openjdk.jdk"

[[ -d "$JAVA_PATH_11" ]] && sudo ln -sfn "$JAVA_PATH_11/libexec/$JDK_NAME" "$JVM_HOME/openjdk@11.jdk"
[[ -d "$JAVA_PATH_17" ]] && sudo ln -sfn "$JAVA_PATH_17/libexec/$JDK_NAME" "$JVM_HOME/openjdk@17.jdk"


echo
print_title "Cleanup\n"
brew cleanup -s
rm -rf $(brew --cache)


echo
print_title "Brew packages installation DONE!\n"


echo
print_title "Dotfiles installation\n"
dotfiles_symlink "home_files"


echo
print_title "Bash Powerline installation\n"
# Zsh is default shell in macOS 10.15+
# Needs bash_profile under bash
bash;source ~/.bash_profile
pip install --user powerline-gitstatus
pip install --user powerline-status


echo
print_title "Update user default Shell (Requires Password):\n"
add_acceptable_shell `command -v bash` default
add_acceptable_shell `command -v zsh`


echo
print_title "Install Mac AppStore Apps\n"
./mas_installer.sh
