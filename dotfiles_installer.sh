#!/bin/sh
# Dotfiles installer
#
#
# Parameters of used (ba)sh built-in commands
# test:
# -eq, -ne, -lt, -le, -gt, -ge: Equality, less than, greater than
#
# read:
# -p prompt:  prompt on standard output, without a trailing newline, before attempting to read any input.
# -n nchars:  returns after reading nchars characters instead of waiting for line completion
# -r:         backslash is considered to be part of the line.



DOTFILES_SOURCE_REPO=https://github.com/rkrim/dotfiles.git
DOTFILES_DEFAULT_DESTINATION=~/Developer/dotfiles


# Check Shell 
if [ ! -n "$BASH" ]; then
  echo "Please use bash to run this script"
  exit 1
fi

# Check Args 
if [ "$#" -gt 1 ]; then
  echo "This script handles a maximum of 1 argument"
  exit 1
fi

# Check Git
if [ ! `command -v git` ]; then
  echo "You must first install git to use this script"
  exit 1
fi

# Check Command Line Tools under macOS
if [[ $(uname -s) =~ "Darwin" && `command -v xcode-select` ]]; then
  while [[ -z $(xcode-select -p 2> /dev/null) ]]; do
    echo "Command Line Tools were not found"
    read -rn 1 -p "Install? (Y or y to confirm, any other key to exit) "
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
    xcode-select --install
    read -rn 1 -p "After installation completion, press any key to continue "
    echo
  done
fi

# Prepare to clone
DOTFILES_DESTINATION=$DOTFILES_DEFAULT_DESTINATION
if [ "$#" -eq 1 ]; then
  DOTFILES_DESTINATION=$1
fi

# Inform user of action and wait for confirmation.
echo "This script will attempt to clone the remote repository to '$DOTFILES_DESTINATION'"
read -rn 1 -p "Continue? (Y or y to confirm, any other key to exit) "
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

git clone $DOTFILES_SOURCE_REPO $DOTFILES_DESTINATION
GIT_EXIT=$?
if [[ $GIT_EXIT -ne 0 ]]; then
  echo "Git clone failed with exit status: $GIT_EXIT"
  exit 1
fi


# Launch install
pushd $DOTFILES_DESTINATION
chmod +x cli_install.sh
. cli_install.sh
popd