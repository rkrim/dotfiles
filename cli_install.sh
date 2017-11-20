#!/usr/bin/env bash

# Include required libraries
source ./pretty-print.sh
source ./install_helper.sh


### INSTALL ###
print_title "Install and/or update Homebrew:\n"

if [ -f "`which brew`" ]; then
  echo "Already installed, updating"
  brew update;brew upgrade
else
  echo "Not installed, installing"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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
  "coreutils"
  "binutils"
  "screen"
  "gawk"
  "gzip"
  "rsync"
  #"openssh" does not support macOS 10.12.2+ UseKeychain option
  "ed --with-default-names"
  "grep --with-default-names"
  "findutils --with-default-names"
  "gnu-sed --with-default-names"
  "gnu-tar --with-default-names"
  "gnu-which --with-default-names"
  "gnu-indent --with-default-names"
)
brew_batch_install cli_tools[@]


echo
print_title "Install developer cli tools\n"
developer_tools=(
  "git --with-blk-sha1 --with-gettext --with-pcre2"
  "git-quick-stats"
  "node"
  "python"
  "python3"
  "perl --with-dtrace"
  "watchman"
  "ruby"
  "ocaml --with-flambda --with-x11"
  "carthage"
  "cocoapods"
  "swiftlint"
  "apktool"
  "dex2jar"
  "boost --c++11"
  "file-formula"
  "vim --with-override-system-vi"
  "macvim --override-system-vim --custom-system-icons"
  "diffutils"
  "gnutls"
  "watch"
  "wdiff --with-gettext"
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
  "mplayer --with-libcaca --with-libdvdnav --with-libdvdread"
)
brew_batch_install non_gnu[@]

echo
print_title "Install Image Tools\n"
image_tools=(
  "fftw --with-mpi --with-openmp"
  "imagemagick --with-fftw --with-fontconfig --with-ghostscript --with-hdri --with-liblqr --with-librsvg --with-libwmf --with-opencl --with-webp"
  "graphicsmagick --with-ghostscript --with-webp --with-libwmf"
)
brew_batch_install image_tools[@]

echo
print_title "Install UI Apps (Cask)\n"
ui_apps=(
  "appcleaner"
  "flux"
  "keepingyouawake"
  "macdown"
  "brackets"
  "imageoptim"
  "opensim"
  "jd-gui"
  "iina"
  "zeplin"
  "handbrake"
)
brew_batch_install ui_apps[@] cask


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
