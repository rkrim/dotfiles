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
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

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
  "mas"
  #"openssh" does not support macOS 10.12.2+ UseKeychain option
  "rsync"
  "screen"
  "tmux"
  "vitorgalvao/tiny-scripts/cask-repair"
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
  "dex2jar"
  "diffutils"
  "file-formula"
  "git"
  "git-quick-stats"
  "gnutls"
  "mitmproxy"
  "node"
  "nvm"
  "ocaml"
  "perl"
  "python"
  "ruby"
  "sonar-scanner"
  "sonar-completion"
  "tig"
  "vim"
  "watch"
  "watchman"
  "wdiff"
  "wget"
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
  "atom"
  "brackets"
  "charles"
  "cakebrew"
  "dbeaver-community"
  "deezer"
  "firefox"
  "flux"
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
  "realm-studio"
  # "tftpserver"
)
brew_batch_install unidentified[@] cask


echo
print_title "Install Cask packages with user action required\n"
action_required=(
  "java"                                # Requires Password
  "AdoptOpenJDK/openjdk/adoptopenjdk8"  # Requires Password
  "virtualbox"                          # Requires Password
  "virtualbox-extension-pack"
  "sonarqube"                           # Requires Java 11+
  "swiftlint"                           # Requires Xcode App
)
brew_batch_install action_required[@] cask


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
pip install --user powerline-gitstatus
pip install --user powerline-status
