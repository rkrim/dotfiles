# ~/.bash_profile:
# Sourced by the command interpreter for login shells.


# Source ~/.profile if exist (not automatically sourced if .bash_profile exist)
if [ -r ~/.profile ]; then
  source ~/.profile
fi

# Source ~/.bashrc if exist (not automatically sourced in non-login shells)
if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi
