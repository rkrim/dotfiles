#!/usr/bin/env bash

# Include required libraries
source ./pretty-print.sh
source ./install_helper.sh


### INSTALL ###
print_title "Install and/or update Homebrew:\n"

if [ `command -v brew` ]; then
  echo "Already installed, updating"
  brew update;brew upgrade
else
  echo "Not installed, installing"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

  if [ ! `command -v brew` ]; then
    echo "Brew not installed, aborting."
    exit 1
  fi
fi


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
  "binutils"
  "coreutils"
  "ed"
  "findutils"
  "gawk"
  "gnu-indent"
  "gnu-sed"
  "gnu-tar"
  "gnu-which"
  "grep"
  "gzip"
  "librsvg"
  "mas"
  "rsync"
  "screen"
  "tmux"
  "vitorgalvao/tiny-scripts/cask-repair"
# OpenSSH does not support 'UseKeychain' option introduced in macOS 10.12.2+
# To use this version, add "IgnoreUnknown UseKeychain" in config file before using it.
# "openssh"
)
brew_batch_install cli_tools[@]


echo
print_title "Install developer cli tools\n"
developer_tools=(
  "ack"
  "apktool"
  "boost"
  "carthage"
  "chisel"
  "cocoapods"
  "composer"
  "dex2jar"
  "diffutils"
  "file-formula"
  "git"
  "git-lfs"
  "git-quick-stats"
  "gnutls"
  "mitmproxy"
  "node"
  "nvm"
  "ocaml"
  "openjdk"
  "openjdk@8"
  "openjdk@11"
  "gradle"  # Requires Java
  "perl"
  "python"
  "ruby"
  "sonarqube" # Requires Java
  "sonar-scanner"
  "sonar-completion"
  "svn"
  "tig"
  "vim"
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
  "android-file-transfer"
  "android-sdk"
  "android-studio"
  "appcleaner"
  "asset-catalog-tinkerer"
  "charles"
  "cakebrew"
  "dbeaver-community"
  "deezer"
  "firefox"
  "fork"
  "google-chrome"
  "handbrake"
  "iina"
  "intellij-idea-ce"
  "imageoptim"
  "iterm2"
  "keepingyouawake"
  "macdown"
  "opera"
  "openemu"
  "opensim"
  "pusher"
  "react-native-debugger"
  "rectangle"
  "sequel-pro"
  "slack"
  "sourcetree"
  "spotify"
  "transmission"
  "typora"
  "visual-studio-code"
  "vlc"
  "wwdc"
  "zeplin"
# "atom"
# "brackets"
# "flux"
# "vagrant"
# "vagrant-manager"
)
brew_batch_install ui_apps[@] cask


echo
print_title "Install QuickLook Plugin (Cask)\n"
ql_plugins=(
  "qlcolorcode"
  "qlstephen"
  "qlmarkdown"
  "quicklook-json"
  "provisionql"
  "quicklookapk"
)
brew_batch_install ql_plugins[@] cask


echo
print_title "Install ScreenSavers (Cask)\n"
screensavers=(
  "aerial"
)
brew_batch_install screensavers[@] cask


echo
print_title "Install Fonts (Cask)\n"
fonts=(
  "homebrew/cask-fonts/font-menlo-for-powerline"
  "homebrew/cask-fonts/font-roboto-mono-for-powerline"
)
brew_batch_install fonts[@] cask


echo
print_title "Install packages from 'Unidentified Developer' (Cask)\n"
echo "Requires open authorization in 'System Preferences > Security & Privacy > General'"
unidentified=(
  "angry-ip-scanner"
  "balenaetcher"
  "jd-gui"
  "oclint"
# "realm-studio"
# "tftpserver"
)
brew_batch_install unidentified[@] cask

echo
print_title "Install Cask packages with user action required\n"
action_required=(
  "virtualbox"                  # Requires Password
  "virtualbox-extension-pack"
  #"swiftlint"                  # Requires Xcode App
)
brew_batch_install action_required[@]


echo
print_title "Drivers and other Hardware apps (Cask)\n"
drivers=(
  "homebrew/cask-drivers/logitech-options"
)
brew_batch_install drivers[@] cask


echo
print_title "Cleaning up Homebrew\n"
brew cleanup -s
rm -rf $(brew --cache)


echo
print_title "Brew packages installation DONE!\n"


echo
print_title "Update user default Shell (Requires Password):\n"
add_acceptable_shell `command -v bash` default
add_acceptable_shell `command -v zsh`


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
exit