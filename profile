# ~/.profile:
# Sourced by the command interpreter for login shells.


### Updating Path

# home binanries
if [ -d "$HOME/bin" ]; then
  export PATH="$HOME/bin:$PATH"
fi
export PATH="/usr/local/sbin:$PATH"

# Brew packages
BREW_PATH=`brew --prefix`
if [ -d "$BREW_PATH" ]; then

  # Coreutils
  if [[ -d "$BREW_PATH/opt/coreutils" ]]; then
    export PATH="$BREW_PATH/opt/coreutils/libexec/gnubin:$PATH"
    export MANPATH="$BREW_PATH/opt/coreutils/libexec/gnuman:$MANPATH"
  fi

  # Python
  if [[ -d "$BREW_PATH/opt/python/libexec/bin" ]]; then
    export PATH="$BREW_PATH/opt/python/libexec/bin:$PATH"

    PYTHON_BASE=`python -m site --user-base`
    if [[ -d "$PYTHON_BASE/bin" ]]; then
      export PATH="$PATH:$PYTHON_BASE/bin"
    fi
  fi

  # Node 8
  if [[ -d "$BREW_PATH/opt/node@8" ]]; then
    export PATH="$BREW_PATH/opt/node@8/bin:$PATH"
  fi

fi


# Android development
export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"
export ANDROID_HOME=$ANDROID_SDK_ROOT
if [ -d $ANDROID_HOME ]; then
  export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/ndk-bundle"
fi
