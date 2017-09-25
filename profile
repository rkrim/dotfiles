# ~/.profile:
# Sourced by the command interpreter for login shells.



### Updating path
# home binanries
if [ -d "$HOME/bin" ]; then
  export PATH="$HOME/bin:$PATH"
fi

# coreutils
if [ -d "$(brew --prefix coreutils)/libexec" ]; then
  export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
  export MANPATH="$(brew --prefix coreutils)/libexec/gnuman:$MANPATH"
fi

# Android development
ANDROID_HOME=~/Developer/Library/Android/sdk
if [ -d $ANDROID_HOME ]; then
  ANDROID_TOOLS=$ANDROID_HOME/tools
  ANDROID_PLATFORM_TOOLS=$ANDROID_HOME/platform-tools
  ANDROID_NDK=$ANDROID_HOME/ndk-bundle
  export PATH="$PATH:$ANDROID_TOOLS:$ANDROID_PLATFORM_TOOLS:$ANDROID_NDK"
fi
