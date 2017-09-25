#!/bin/sh
# Dotfiles installer

DOTFILES_SOURCE=https://github.com/TwiterZX/dotfiles.git
DOTFILES_DESTINATION=~/coucou/dotfiles


if [ ! -f "`which git`" ]; then
  echo "You must first install git to use this installer"
  exit
else
  echo "git found"
fi
exit
git clone $DOTFILES_SOURCE $DOTFILES_DESTINATION
