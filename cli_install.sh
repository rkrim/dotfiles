#!/usr/bin/env bash

# Include required libraries
source ./pretty-print.sh
source ./install_helper.sh




# add_acceptable_shell()
# Add a shell path to acceptable login shells (chpass)
# @param1: required, shell path
# @param2: optional, switch parameter, if true: make shell the default one for the current user, default: false
function add_acceptable_shell {
  if [[ $# == 0  || $# > 2 || $1 == "" ]]; then
		return $FALSE
	fi

  shell_path=$1
  make_default_shell=$2

  if [[ -n $shell_path && ! `cat /etc/shells | grep $shell_path` ]]; then
    echo $shell_path | sudo tee -a /etc/shells

    # Change the current user default shell to the new one
    if [[ -n $make_default_shell && ($make_default_shell == "true" || $make_default_shell == $TRUE ) && `command -v chsh` ]]; then
      chsh -s $shell_path
    fi
  fi
}


### INSTALL ###

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

shells=("bash" "bash-completion@2" "zsh")
brew_batch_install shells[@]

add_acceptable_shell `command -v bash` true
add_acceptable_shell `command -v zsh`

exit



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
