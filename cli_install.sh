#!/usr/bin/env bash



# Include required libraries
source ./pretty-print.sh
source ./install_helper.sh

txt_attr_success=$(txt_attr $FG_COLOR_LIGHT_GREEN)
echo -en $txt_attr_success"Install and/or update Homebrew$reset_all\n"

if [ -f "`which brew`" ]; then
  echo "Already installed, updating"
  brew update;brew upgrade
else
  echo "Not installed, installing"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi


echo "Installing Shells"

OLD_BASH=`command -v bash`
OLD_ZSH=`command -v zsh`

shells=("bash" "bash-completion@2" "zsh")
brew_batch_install shells[@]
exit

NEW_BASH=`command -v bash`
NEW_ZSH=`command -v zsh`

if [[ -n $NEW_BASH && $NEW_BASH != $OLD_BASH ]]; then
  # Add the new installed bash to chpass acceptable shells
  echo $NEW_BASH | sudo tee -a /etc/shells

  # Change the current user default shell to the new bash
  if [ `command -v chsh` ]; then
    chsh -s $NEW_BASH
  fi
fi

if [[ -n $NEW_ZSH && $NEW_ZSH != $OLD_ZSH ]]; then
  # Add the new installed zsh to chpass acceptable shells
  echo $NEW_ZSH | sudo tee -a /etc/shells
fi


echo "Installing cli tools"
cli_tools=(
  "coreutils"
  "binutils"
  "screen"
  "gawk"
  "gzip"
  "rsync"
  "openssh"
  "ed --with-default-names"
  "grep --with-default-names"
  "findutils --with-default-names"
  "gnu-sed --with-default-names"
  "gnu-tar --with-default-names"
  "gnu-which --with-default-names"
  "gnu-indent --with-default-names"
)

echo "Installing developer cli tools"
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
  "gnutls3"
  "watch"
  "wdiff --with-gettext"
  "wget"
)

# Update built-in macOS tools vith the last GNU version
built_in=(
  "emacs"
  "gpatch"
  "m4"
  "make"
  "nano"
)

# non-GNU tools
non_gnu=(
  "less"
  "mplayer --with-libcaca --with-libdvdnav --with-libdvdread"
)

# UI Apps (Cask)
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

# ScreenSavers (Cask)
screensavers=("aerial")

echo "Cleaning up Homebrew"
brew cleanup -s
rm -rf $(brew --cache)

echo "Installation DONE!"
