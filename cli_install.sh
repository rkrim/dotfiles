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

shells=("bash" "bash-completion@2" "zsh")
brew_batch_install shells[@]

add_acceptable_shell `command -v bash` default
add_acceptable_shell `command -v zsh`


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
)
brew_batch_install cli_tools[@]


echo
print_title "Install developer cli tools\n"
developer_tools=(
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
  "ocaml"
  "perl"
  "python"
  "python3"
  "ruby"
  "sonar-scanner"
  # "sonarqube"   # Requires Java 8+ from cask
  # "swiftlint"   # Requires Xcode App
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
  "mplayer"
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
print_title "Install UI Apps (Cask)\n"
ui_apps=(
  "android-file-transfer"
  "android-sdk"
  "appcleaner"
  "atom"
  "brackets"
  "cakebrew"
  "flux"
  "handbrake"
  "iina"
  "imageoptim"
  "jd-gui"
  "keepingyouawake"
  "macdown"
  "opensim"
  "slack"
  # "virtualbox" # Install fails
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
)
brew_batch_install ql_plugins[@] cask


echo
print_title "Install ScreenSavers (Cask)\n"
screensavers=("aerial")
brew_batch_install screensavers[@] cask


echo
print_title "Cleaning up Homebrew\n"
brew cleanup -s
rm -rf $(brew --cache)

echo
print_title "Installation DONE!\n"

echo
print_title "Dotfiles installation\n"
dotfiles_symlink "home_files"
