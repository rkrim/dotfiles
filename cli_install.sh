#!/bin/sh





# Include required libraries
source ~/.pretty-print.sh

echo "Install and/or update Homebrew"
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

brew install bash
brew install bash-completion@2
brew install zsh

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
brew install coreutils

brew install binutils
brew install screen
brew install gawk
brew install gzip
brew install rsync
brew install openssh

brew install ed --with-default-names
brew install grep --with-default-names
brew install findutils --with-default-names
brew install gnu-sed --with-default-names
brew install gnu-tar --with-default-names
brew install gnu-which --with-default-names
brew install gnu-indent --with-default-names


echo "Installing developer cli tools"
brew install git --with-blk-sha1 --with-gettext --with-pcre2
brew install git-quick-stats
brew install python
brew install python3
brew install perl --with-dtrace
brew install ocaml --with-flambda --with-x11
brew install node
brew install watchman
brew install ruby
brew install carthage
brew install cocoapods
brew install swiftlint
brew install apktool
brew install boost --c++11

brew install vim --with-override-system-vi
brew install file-formula
brew install macvim --override-system-vim --custom-system-icons

# key commands
brew install binutils
brew install diffutils
brew install ed --default-names
brew install findutils --with-default-names
brew install gawk
brew install gnu-indent --with-default-names
brew install gnu-sed --with-default-names
brew install gnu-tar --with-default-names
brew install gnu-which --with-default-names
brew install gnutls
brew install grep --with-default-names
brew install gzip
brew install screen
brew install watch
brew install wdiff --with-gettext
brew install wget

# Update built-in macOS tools vith the last GNU version
brew install emacs
brew install gpatch
brew install m4
brew install make
brew install nano

# non-GNU tools
brew install file-formula
brew install less
brew install vim --override-system-vi
brew install macvim --override-system-vim --custom-system-icons


# UI Apps (Cask)
brew cask install appcleaner
brew cask install flux
brew cask install keepingyouawake
brew cask install macdown
brew cask install brackets
brew cask install imageoptim
brew cask install lepton
brew cask install opensim
brew cask install iina
brew cask install zeplin

# ScreenSavers
brew cask install aerial



echo "Cleaning up Homebrew"
brew cleanup -s
rm -rf $(brew --cache)

echo "Installation DONE!"
