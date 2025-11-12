#!/usr/bin/env bash
# Dotfiles installer
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
EXIT_FAILURE=1

# Color definitions
# Check if terminal supports colors
if [ -t 1 ] && command -v tput > /dev/null 2>&1; then
  COLOR_RESET=$(tput sgr0)
  COLOR_BOLD=$(tput bold)
  COLOR_RED=$(tput setaf 1)
  COLOR_GREEN=$(tput setaf 2)
  COLOR_YELLOW=$(tput setaf 3)
  COLOR_BLUE=$(tput setaf 4)
  COLOR_CYAN=$(tput setaf 6)
else
  COLOR_RESET=""
  COLOR_BOLD=""
  COLOR_RED=""
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_BLUE=""
  COLOR_CYAN=""
fi

# Helper functions for colored output
print_error() {
  echo "${COLOR_RED}${COLOR_BOLD}Error:${COLOR_RESET} $1"
}

print_warning() {
  echo "${COLOR_YELLOW}${COLOR_BOLD}Warning:${COLOR_RESET} $1"
}

print_success() {
  echo "${COLOR_GREEN}$1${COLOR_RESET}"
}

print_info() {
  echo "${COLOR_BOLD}$1${COLOR_RESET}"
}

print_title() {
  echo "${COLOR_BOLD}$1${COLOR_RESET}"
}

# Cleanup function for interrupted operations
cleanup() {
  echo
  echo
  print_warning "Installation interrupted. Cleaning up..."
  # Only cleanup if we're in the middle of cloning
  if [ -n "$CLEANUP_ON_INTERRUPT" ] && [ -d "$DOTFILES_DESTINATION" ] && [ ! -f "$DOTFILES_DESTINATION/.git/config" ]; then
    print_info "Removing incomplete clone..."
    rm -rf "$DOTFILES_DESTINATION"
  fi
  exit $EXIT_FAILURE
}

# Set trap for cleanup on interrupt
trap cleanup INT TERM

# Capture script path and arguments for potential restart
SCRIPT_PATH="$0"
SCRIPT_ARGS=("$@")

# Function to restart the script
restart_script() {
  echo
  print_info "Repository updated. The installation scripts may have changed."
  print_info "Restarting the installer using the local version..."
  echo
  
  # Use the local version from the cloned repository
  LOCAL_SCRIPT="$DOTFILES_DESTINATION/dotfiles_installer.sh"
  
  if [ ! -f "$LOCAL_SCRIPT" ]; then
    print_error "Local installer script not found at: $LOCAL_SCRIPT"
    exit $EXIT_FAILURE
  fi
  
  # Make sure it's executable
  chmod +x "$LOCAL_SCRIPT" 2>/dev/null
  
  for i in {5..1}; do
    printf "\r${COLOR_CYAN}Restarting in %d seconds... (Press Ctrl+C to cancel)${COLOR_RESET}" "$i"
    sleep 1
  done
  printf "\r${COLOR_RESET}"
  # Clear screen
  if [ -t 1 ] && command -v clear > /dev/null 2>&1; then
    clear
  fi
  # Restart using the local version with the same arguments
  exec "$LOCAL_SCRIPT" "${SCRIPT_ARGS[@]}"
}

# Print header
print_title "=========================================="
print_title "  Dotfiles Installation Script"
print_title "=========================================="
echo

# Check Shell 
print_info "Checking bash..."
if ! command -v bash > /dev/null 2>&1; then
  print_error "Bash is not installed. Please install bash first."
  exit $EXIT_FAILURE
elif test "${BASH_VERSION+set}" != "set" || ! (eval '[[ -n "${BASH_VERSION}" ]]' 2>/dev/null); then
  print_error "Please use bash to run this script"
  exit $EXIT_FAILURE
else
  print_success "✓ Bash is installed and running"
  echo
fi

# Check Args 
if [ "$#" -gt 1 ]; then
  print_error "This script handles a maximum of 1 argument"
  echo "Usage: $0 [destination_path]"
  exit $EXIT_FAILURE
fi

# Check Git
if [ ! `command -v git` ]; then
  print_error "Git is not installed"
  echo "Please install git first to use this script"
  exit $EXIT_FAILURE
fi

# Check Command Line Tools under macOS
if [[ $(uname -s) =~ "Darwin" && `command -v xcode-select` ]]; then
  print_info "Checking Command Line Tools..."
  while [[ -z $(xcode-select -p 2> /dev/null) ]]; do
    print_warning "Command Line Tools were not found"
    read -rn 1 -p "Install? (Y or y to confirm, any other key to exit) "
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      print_error "Installation cancelled. Command Line Tools are required."
      exit $EXIT_FAILURE
    fi
    print_info "Installing Command Line Tools..."
    xcode-select --install
    read -rn 1 -p "After installation completion, press any key to continue "
    echo
  done
  print_success "✓ Command Line Tools verified"
  echo
fi

# Prepare to clone
DOTFILES_DESTINATION=$DOTFILES_DEFAULT_DESTINATION
if [ "$#" -eq 1 ]; then
  DOTFILES_DESTINATION=$1
fi

# Expand ~ to home directory
DOTFILES_DESTINATION="${DOTFILES_DESTINATION/#\~/$HOME}"

# Validate destination path format
if [[ "$DOTFILES_DESTINATION" =~ ^[^/] ]]; then
  print_error "Invalid destination path format: '$DOTFILES_DESTINATION'"
  echo "Please provide an absolute path or a path starting with ~/"
  exit $EXIT_FAILURE
fi

# Check if destination already exists
if [ -d "$DOTFILES_DESTINATION" ]; then
  # Check if it's already a git repository
  if [ -d "$DOTFILES_DESTINATION/.git" ]; then
    print_warning "Directory '$DOTFILES_DESTINATION' already exists and appears to be a git repository."
    read -rn 1 -p "Update repository? (Y/y to update, N/n to continue without updating, any other key to exit) "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo
      print_info "Updating existing repository..."
      pushd "$DOTFILES_DESTINATION" > /dev/null
      # Get the current commit before update
      OLD_COMMIT=$(git rev-parse HEAD 2>/dev/null)
      # Determine the current branch (default to main)
      CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
      # Fetch latest changes
      git fetch origin
      FETCH_EXIT=$?
      if [[ $FETCH_EXIT -ne 0 ]]; then
        popd > /dev/null
        print_error "Failed to fetch from remote repository."
        exit $EXIT_FAILURE
      fi
      # Reset to match remote state exactly (discarding local changes)
      git reset --hard "origin/$CURRENT_BRANCH" 2>/dev/null || git reset --hard "origin/main" 2>/dev/null
      RESET_EXIT=$?
      # Get the new commit after reset
      NEW_COMMIT=$(git rev-parse HEAD 2>/dev/null)
      popd > /dev/null
      if [[ $RESET_EXIT -ne 0 ]]; then
        print_error "Failed to update repository. Please resolve conflicts manually."
        exit $EXIT_FAILURE
      fi
      # Check if repository was actually updated
      if [[ "$OLD_COMMIT" != "$NEW_COMMIT" ]]; then
        print_success "✓ Repository updated successfully"
        # Restart the script to use the latest version
        restart_script
      else
        print_success "✓ Repository is already up to date"
        echo
        SKIP_CLONE=true
      fi
    elif [[ $REPLY =~ ^[Nn]$ ]]; then
      print_info "Continuing with existing repository without updating..."
      echo
      SKIP_CLONE=true
    else
      echo "${COLOR_RED}Installation cancelled.${COLOR_RESET}"
      exit $EXIT_FAILURE
    fi
  else
    print_warning "Directory '$DOTFILES_DESTINATION' already exists."
    read -rn 1 -p "Continue anyway? (Y or y to continue, any other key to exit) "
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "${COLOR_RED}Installation cancelled.${COLOR_RESET}"
      exit $EXIT_FAILURE
    fi
  fi
fi

# Validate parent directory exists and is writable
if [ -z "$SKIP_CLONE" ]; then
  PARENT_DIR=$(dirname "$DOTFILES_DESTINATION")
  if [ ! -d "$PARENT_DIR" ]; then
    print_warning "Parent directory '$PARENT_DIR' does not exist."
    read -rn 1 -p "Create it? (Y or y to create, any other key to exit) "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      mkdir -p "$PARENT_DIR"
      if [ $? -ne 0 ]; then
        print_error "Failed to create parent directory."
        exit $EXIT_FAILURE
      fi
      print_success "✓ Created parent directory"
      echo
    else
      echo "${COLOR_RED}Installation cancelled.${COLOR_RESET}"
      exit $EXIT_FAILURE
    fi
  elif [ ! -w "$PARENT_DIR" ]; then
    print_error "No write permission for parent directory '$PARENT_DIR'"
    exit $EXIT_FAILURE
  fi
fi

# Inform user of action and wait for confirmation.
if [ -z "$SKIP_CLONE" ]; then
  echo "This script will clone the remote repository to:"
  echo "  $DOTFILES_DESTINATION"
  echo "  Repository: $DOTFILES_SOURCE_REPO"
  read -rn 1 -p "Continue? (Y or y to confirm, any other key to exit) "
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "${COLOR_RED}Installation cancelled.${COLOR_RESET}"
      exit $EXIT_FAILURE
  fi

  # Check if repository is reachable (quick connectivity check)
  echo
  print_info "Checking repository accessibility..."
  if git ls-remote --heads "$DOTFILES_SOURCE_REPO" > /dev/null 2>&1; then
    print_success "✓ Repository is accessible"
    echo
  else
    print_warning "Could not verify repository accessibility, proceeding anyway..."
    echo
  fi

  # Clone repository
  echo
  print_info "Cloning repository..."
  CLEANUP_ON_INTERRUPT=true
  git clone "$DOTFILES_SOURCE_REPO" "$DOTFILES_DESTINATION"
  GIT_EXIT=$?
  CLEANUP_ON_INTERRUPT=""
  if [[ $GIT_EXIT -ne 0 ]]; then
    print_error "Git clone failed with exit status: $GIT_EXIT"
    echo "Possible causes:"
    echo "  - Network connectivity issues"
    echo "  - Repository URL is incorrect"
    echo "  - Insufficient disk space"
    echo "  - Permission issues"
    exit $EXIT_FAILURE
  fi
  print_success "✓ Git clone completed successfully"
  echo
fi

# Verify cli_install.sh exists and make it executable
print_info "Preparing installation script..."
pushd "$DOTFILES_DESTINATION" > /dev/null
if [ ! -f "cli_install.sh" ]; then
  print_error "cli_install.sh not found in cloned repository."
  echo "The repository may be incomplete or the file structure has changed."
  popd > /dev/null
  exit $EXIT_FAILURE
fi
chmod +x cli_install.sh
popd > /dev/null
print_success "✓ Made cli_install.sh executable"
echo

# Ask user if they want to proceed with installation
echo
echo "Repository cloned successfully to: $DOTFILES_DESTINATION"
echo "The installation script 'cli_install.sh' is now executable."
echo "You can review or modify the scripts before proceeding."
echo
echo "The installation will:"
echo "  - Install Homebrew and packages"
echo "  - Set up dotfiles symlinks"
echo "  - Configure your shell environment"
echo
read -rn 1 -p "Start installation now? (Y or y to start, any other key to exit) "
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Installation cancelled."
  echo "You can run 'cli_install.sh' manually from '$DOTFILES_DESTINATION' when ready."
  exit 0
fi

# Launch install
echo
print_title "Starting installation..."
print_title "=========================================="
echo
pushd "$DOTFILES_DESTINATION" > /dev/null
INSTALL_EXIT=0
. cli_install.sh || INSTALL_EXIT=$?
popd > /dev/null

# Final summary
echo
print_title "=========================================="
if [ $INSTALL_EXIT -eq 0 ]; then
  print_success "✓ Installation completed successfully!"
  echo "Your dotfiles are now set up at: $DOTFILES_DESTINATION"
else
  print_warning "⚠ Installation completed with errors (exit code: $INSTALL_EXIT)"
  echo "Please review the output above for details."
fi
print_title "=========================================="
exit $INSTALL_EXIT