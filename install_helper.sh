# ~/.install_helper.sh
# Utilities to manage install and uninstall


# Include required libraries
source ./std.sh
source ./pretty-print.sh


# brew_export_shell_environment
# Attempt to detect the right command path to export brew shell environments
# 
brew_export_shell_environment () {
  # Brew is installed on different path following architecture
  # Check that brew exist in preferred location
  local BREW_CMD_X86_64="/usr/local/bin/brew"
  local BREW_CMD_ARM64="/opt/homebrew/bin/brew"

  if command -v $BREW_CMD_X86_64 &> /dev/null; then
    eval $($BREW_CMD_X86_64 shellenv)
  elif command -v $BREW_CMD_ARM64 &> /dev/null; then
    eval $($BREW_CMD_ARM64 shellenv)
  fi
}

# brew_register_taps()
# Register Homebrew taps
brew_register_taps() {
  if [[ $# -ne 1 || -z "$1" ]]; then
    echo "${FUNCNAME[0]}() :: bad_arguments"
    false
    return $EXIT_FAILURE
  fi

  for tap in "$@"; do
    brew tap "$tap"
  done
}


# is_brew_package_installed()
# Check if a brew package is already installed
# brew command must be installed
# @param1 required, Package name
# @return: The versoin number of the package if its installed
function is_brew_package_installed {
  if [[ $# -ne 1 || -z "$1" ]]; then
    echo "${FUNCNAME[0]}() :: bad_arguments"
    false
    return $EXIT_FAILURE
  fi

  package_tokens=( $1 )
  package_name=${package_tokens[0]}
  brew_command="brew"

  # Check if it's a formula
  result=`$brew_command list --versions $package_name 2> /dev/null`
  if [[ $? == 0 ]]; then
    echo $result | cut -d " " -f2
    true
    return 0
  fi

  # Check if it's a cask
  result=`$brew_command list --cask --versions $package_name 2> /dev/null`
  if [[ $? == 0 ]]; then
    echo $result | cut -d " " -f2
    true
    return 0
  fi

  # If not found in either formulas or casks
  false
  return 1
}


# brew_package_install()
# Install a Brew package after Checking if already installed
# @param1 required, Package name, or package name with installation aruments
function brew_package_install {
  if [[ $# -ne 1 || -z "$1" ]]; then
    echo "${FUNCNAME[0]}() :: bad_arguments"
    return $EXIT_FAILURE
  fi

  brew_command="brew"
  package_name=$1
  log_file="output.file"
  txt_attr_pkg_name=$(txt_attr $FG_COLOR_LIGHT_CYAN $ATTR_BOLD)
  txt_attr_warning=$(txt_attr $FG_COLOR_YELLOW)
  txt_attr_success=$(txt_attr $FG_COLOR_LIGHT_GREEN)
  txt_attr_fail=$(txt_attr $FG_COLOR_LIGHT_RED)

  prefix_line="Package $txt_attr_pkg_name$package_name$reset_all"

  echo -en $prefix_line" [$txt_attr_warning"" Processing $reset_all] :: Checking if already installed..."
  package_version=`is_brew_package_installed "$package_name" 2> /dev/null`
  package_version_status=$?

  clear_line
  if [[ $package_version_status == 0 ]]; then
    echo -en $prefix_line" [$txt_attr_success"" Already Installed $reset_all] :: Version $package_version\n" | tee -a $log_file
  else
    echo -en $prefix_line" [$txt_attr_warning"" Processing $reset_all] :: Not Installed, installing..."
    installation=`$brew_command install $package_name >> "$log_file" 2>&1`
    installtion_status=$?
    clear_line
    if [[ $installtion_status == 0 ]]; then
      echo -en $prefix_line" [$txt_attr_success"" Installation successful $reset_all]" | tee -a $log_file

      package_version=`is_brew_package_installed "$package_name" 2> /dev/null`
      package_version_status=$?

      if [[ $package_version_status == 0 ]]; then
        echo -en " :: Version $package_version\n" | tee -a $log_file
      else
        echo | tee -a $log_file
      fi

    else
      echo -en $prefix_line" [$txt_attr_fail"" Installation failed $reset_all]\n" | tee -a $log_file
    fi
  fi
}


# brew_batch_install()
# Install a list of Brew packages
# @param1 required, an array of brew packages, or list of brew packages with installtion aruments
function brew_batch_install {
  if [[ $# -ne 1 || -z "$1" ]]; then
    echo "${FUNCNAME[0]}() :: bad_arguments"
    return $EXIT_FAILURE
  fi

  declare -a packages=("${!1}")

  for package in "${packages[@]}"; do
    brew_package_install "$package"
  done
}

# mas_batch_install()
# Install a list of mas applications
# @param1 required, an array of mas app identifiers
function mas_batch_install {
  if [[ $# -ne 1 || -z "$1" ]]; then
    echo "${FUNCNAME[0]}() :: bad_arguments"
    return $EXIT_FAILURE
  fi

  declare -a packages=("${!1}")

  for package in "${packages[@]}"; do
    mas install $package
  done
}

# add_acceptable_shell()
# Add a shell path to acceptable login shells (chpass)
# @param1: required, shell path
# @param2: optional, switch parameter, if true: make shell the default one for the current user, default: false
function add_acceptable_shell {
  if [[ $# == 0  || $# > 2 || $1 == "" ]]; then
    echo "${FUNCNAME[0]}() :: bad_arguments"
    return $EXIT_FAILURE
  fi

  shell_path=$1
  make_default_shell=false
  if [[ -n $2 && ($2 == "default" || $2 == "true") ]]; then
    make_default_shell=true
  fi

  if [[ -n $shell_path && ! `cat /etc/shells | grep $shell_path` ]]; then
    echo $shell_path | sudo tee -a /etc/shells

    # Change the current user default shell to the new one
    if $make_default_shell && command -v chsh &> /dev/null; then
      chsh -s $shell_path
    fi
  fi
}


# dotfiles_symlink()
# Create symbolic link for dotfiles found in arg 1, in home folder
# links are prefixed with '.'
# original files will be moved to a backup folder
function dotfiles_symlink {
  if [[ $# -ne 1 || -z "$1" ]]; then
    echo "${FUNCNAME[0]}() :: bad_arguments"
    return $EXIT_FAILURE
  fi

  files_location=$1
  working_directory=`pwd`

  dotfiles_backup=".dotfiles.old"
  dotfiles=($(ls $files_location 2> /dev/null))
  files_count=${#dotfiles[*]}

  if [[ $files_count -eq 0 || ($files_count -eq 1 && ${dotfiles[0]} == "") ]]; then
    echo >&2 "${FUNCNAME[0]}() :: No file found in provided dotfiles folder"
    return $EXIT_FAILURE
  fi

  # Create backup folder
  if [ ! -d ~/$dotfiles_backup ]; then
    if ! mkdir ~/$dotfiles_backup &> /dev/null; then
    echo >&2 "${FUNCNAME[0]}() :: Error: Can't create bakup folder, skipping simlink"
    return $EXIT_FAILURE
    fi
  fi

  files_location_path=$working_directory/$files_location
  link_count=0
  for file in ${dotfiles[@]}; do
    file_path=$files_location_path/$file
    link_name=~/.$file

    # Skip if the link is the same
    if [[ -L $link_name && $(readlink $link_name) == $file_path ]]; then
      continue
    fi

    # Try to move existing file to backup folder, skip current link if it fails
    if [ -e $link_name ]; then
      if ! mv -n $link_name ~/$dotfiles_backup &> /dev/null; then
        continue
      fi
    fi

    # echo "ln -s $file_path $link_name"
    if ln -s $file_path $link_name &> /dev/null; then
      link_count=$((link_count + 1))
    fi
  done

  # Remove backup folder if empty
  if [ -z "$(ls -A ~/$dotfiles_backup 2> /dev/null)" ]; then
    rm -rf ~/$dotfiles_backup
  fi

  if [[ $link_count != $files_count ]]; then
    echo >&2 "${FUNCNAME[0]}() :: Warning: Created '$link_count' links, while expecting '$files_count'"
    return $EXIT_FAILURE
  fi

  return $EXIT_SUCCESS
}


# asdf_plugin_install()
# Install or update an asdf plugin
# @param1 required, Plugin name
function asdf_plugin_install {
  if [[ $# -ne 1 || -z "$1" ]]; then
    echo "${FUNCNAME[0]}() :: bad_arguments"
    return $EXIT_FAILURE
  fi

  if ! command -v asdf &> /dev/null; then
    echo >&2 "${FUNCNAME[0]}() :: asdf is not installed"
    return $EXIT_FAILURE
  fi

  local plugin_name=$1
  local log_file="output.file"
  local txt_attr_pkg_name=$(txt_attr $FG_COLOR_LIGHT_CYAN $ATTR_BOLD)
  local txt_attr_warning=$(txt_attr $FG_COLOR_YELLOW)
  local txt_attr_success=$(txt_attr $FG_COLOR_LIGHT_GREEN)
  local txt_attr_fail=$(txt_attr $FG_COLOR_LIGHT_RED)

  local prefix_line="Plugin $txt_attr_pkg_name$plugin_name$reset_all"

  echo -en $prefix_line" [$txt_attr_warning"" Processing $reset_all] :: Checking if already installed..."
  
  local plugin_list=$(asdf plugin list 2>/dev/null)
  if echo "$plugin_list" | grep -q "^${plugin_name}$" 2>/dev/null; then
    clear_line
    echo -en $prefix_line" [$txt_attr_success"" Already Installed $reset_all] :: Updating..." | tee -a $log_file
    if asdf plugin update "$plugin_name" >> "$log_file" 2>&1; then
      clear_line
      echo -en $prefix_line" [$txt_attr_success"" Updated $reset_all]\n" | tee -a $log_file
    else
      clear_line
      echo -en $prefix_line" [$txt_attr_warning"" Update failed (may already be latest) $reset_all]\n" | tee -a $log_file
    fi
  else
    clear_line
    echo -en $prefix_line" [$txt_attr_warning"" Processing $reset_all] :: Not Installed, installing..."
    if asdf plugin add "$plugin_name" >> "$log_file" 2>&1; then
      clear_line
      echo -en $prefix_line" [$txt_attr_success"" Installation successful $reset_all]\n" | tee -a $log_file
    else
      clear_line
      echo -en $prefix_line" [$txt_attr_fail"" Installation failed $reset_all]\n" | tee -a $log_file
      return $EXIT_FAILURE
    fi
  fi
}

# asdf_batch_install_plugins()
# Install a list of asdf plugins
# @param1 required, an array of asdf plugin names
function asdf_batch_install_plugins {
  if [[ $# -ne 1 || -z "$1" ]]; then
    echo "${FUNCNAME[0]}() :: bad_arguments"
    return $EXIT_FAILURE
  fi

  if ! command -v asdf &> /dev/null; then
    echo >&2 "${FUNCNAME[0]}() :: asdf is not installed"
    return $EXIT_FAILURE
  fi

  declare -a plugins=("${!1}")

  for plugin in "${plugins[@]}"; do
    asdf_plugin_install "$plugin"
  done
}

# asdf_install_version()
# Install a specific version of an asdf-managed tool
# Supports special version strings: "lts", "latest", or specific version numbers
# @param1 required, Plugin name
# @param2 required, Version string (e.g. "latest", "lts", "20", "20.10.0")
# @param3 optional, Set as home default (default: false)
function asdf_install_version {
  if [[ $# -lt 2 || -z "$1" || -z "$2" ]]; then
    echo "${FUNCNAME[0]}() :: bad_arguments"
    return $EXIT_FAILURE
  fi

  if ! command -v asdf &> /dev/null; then
    echo >&2 "${FUNCNAME[0]}() :: asdf is not installed"
    return $EXIT_FAILURE
  fi

  local plugin_name=$1
  local version_spec=$2
  local set_home=${3:-false}
  local log_file="output.file"
  local txt_attr_pkg_name=$(txt_attr $FG_COLOR_LIGHT_CYAN $ATTR_BOLD)
  local txt_attr_warning=$(txt_attr $FG_COLOR_YELLOW)
  local txt_attr_success=$(txt_attr $FG_COLOR_LIGHT_GREEN)
  local txt_attr_fail=$(txt_attr $FG_COLOR_LIGHT_RED)

  local prefix_line="Version $txt_attr_pkg_name$plugin_name $version_spec$reset_all"

  # Check if plugin is installed
  if ! asdf plugin list | grep -q "^${plugin_name}$" 2>/dev/null; then
    echo >&2 "${FUNCNAME[0]}() :: Plugin '$plugin_name' is not installed. Install it first."
    return $EXIT_FAILURE
  fi

  # Determine actual version to install
  local version_to_install=""
  
  # Special handling for Java version patterns (numeric patterns like 8, 11, 17, 21, 25, or "latest")
  if [[ "$plugin_name" == "java" && ("$version_spec" =~ ^[0-9] || "$version_spec" == "latest") ]]; then
    # Resolve Java pattern to actual version
    version_to_install=$(asdf_find_latest_java_version "$version_spec")
    if [[ $? -ne 0 || -z "$version_to_install" ]]; then
      echo >&2 "${FUNCNAME[0]}() :: Failed to find Java version for pattern: $version_spec"
      return $EXIT_FAILURE
    fi
  elif [[ "$version_spec" == "lts" || "$version_spec" == "latest" ]]; then
    # For other plugins, try to use special strings directly
    version_to_install="$version_spec"
  else
    # Check if version is already installed
    if asdf list "$plugin_name" 2>/dev/null | grep -q "^  ${version_spec}$"; then
      clear_line
      echo -en $prefix_line" [$txt_attr_success"" Already Installed $reset_all]\n" | tee -a $log_file
      if [[ "$set_home" == "true" ]]; then
        asdf set "$plugin_name" "$version_spec" --home >> "$log_file" 2>&1
      fi
      return 0
    fi
    version_to_install="$version_spec"
  fi

  echo -en $prefix_line" [$txt_attr_warning"" Processing $reset_all] :: Installing..."
  
  if asdf install "$plugin_name" "$version_to_install" >> "$log_file" 2>&1; then
    clear_line
    # Get the installed version for display purposes
    local installed_version=$(asdf list "$plugin_name" 2>/dev/null | grep -E "^[ *]+${version_spec}|^[ *]+[0-9]" | sed 's/^[ *]*//' | tail -1 | xargs)
    
    # Fallback: if we couldn't find a version, use version_to_install (which is the actual installed version)
    [[ -z "$installed_version" ]] && installed_version="$version_to_install"
    
    if [[ "$set_home" == "true" ]]; then
        # Use the actual installed version (version_to_install) for Java, not the pattern
        asdf set "$plugin_name" "$version_to_install" --home >> "$log_file" 2>&1
        echo -en $prefix_line" [$txt_attr_success"" Installation successful $reset_all] :: Version $installed_version (home default)\n" | tee -a $log_file
      else
        echo -en $prefix_line" [$txt_attr_success"" Installation successful $reset_all] :: Version $installed_version\n" | tee -a $log_file
      fi
  else
    clear_line
    echo -en $prefix_line" [$txt_attr_fail"" Installation failed $reset_all]\n" | tee -a $log_file
    return $EXIT_FAILURE
  fi
}

# asdf_batch_install_versions()
# Install versions for asdf-managed tools
# @param1 required, an associative array or array of "plugin:version" strings
# Format: "plugin:version:home" where home is optional (true/false)
function asdf_batch_install_versions {
  if [[ $# -ne 1 || -z "$1" ]]; then
    echo "${FUNCNAME[0]}() :: bad_arguments"
    return $EXIT_FAILURE
  fi

  if ! command -v asdf &> /dev/null; then
    echo >&2 "${FUNCNAME[0]}() :: asdf is not installed"
    return $EXIT_FAILURE
  fi

  declare -a versions=("${!1}")

  for version_spec in "${versions[@]}"; do
    IFS=':' read -r plugin version set_home <<< "$version_spec"
    if [[ -z "$plugin" || -z "$version" ]]; then
      echo >&2 "${FUNCNAME[0]}() :: Invalid format: '$version_spec'. Expected 'plugin:version' or 'plugin:version:true'"
      continue
    fi

    asdf_install_version "$plugin" "$version" "${set_home:-false}"
  done
}

# asdf_find_latest_java_by_major()
# Find the latest Java version for a specific major version from preferred distributions
# @param1 required, Major version number (e.g., "8", "11", "17", "21")
# @param2 required, All available Java versions (from asdf list all java)
# @param3+ required, Distribution preferences (remaining arguments are distribution names in order)
# @return: The latest matching version string
function asdf_find_latest_java_by_major {
  if [[ $# -lt 3 || -z "$1" || -z "$2" ]]; then
    echo >&2 "${FUNCNAME[0]}() :: bad_arguments"
    return $EXIT_FAILURE
  fi

  local major_version=$1
  local all_versions=$2
  local distro_prefs=("${@:3}")  # Capture arguments starting from position 3 as array
  local version=""

  # Get all versions for this major version
  local matching_versions=$(echo "$all_versions" | grep -E "^[a-z]+-${major_version}\.")
  
  # Try each preferred distribution
  for distro in "${distro_prefs[@]}"; do
    local latest=$(echo "$matching_versions" | grep -E "^${distro}-${major_version}\." | sort -V | tail -1)
    if [[ -n "$latest" ]]; then
      version="$latest"
      break
    fi
  done
  
  # Fallback to any distribution if preferred ones not found
  [[ -z "$version" ]] && version=$(echo "$matching_versions" | sort -V | tail -1)
  
  echo "$version"
}

# asdf_find_latest_java_version()
# Find the latest Java version matching a pattern
# @param1 required, Version pattern (e.g. "8" for Java 8, "latest" for newest)
# @return: The latest matching version string
function asdf_find_latest_java_version {
  if [[ $# -ne 1 || -z "$1" ]]; then
    echo >&2 "${FUNCNAME[0]}() :: bad_arguments"
    return $EXIT_FAILURE
  fi

  local pattern=$1
  local version=""

  # Get all available Java versions
  local all_versions=$(asdf list all java 2>/dev/null)

  if [[ -z "$all_versions" ]]; then
    echo >&2 "${FUNCNAME[0]}() :: Failed to list Java versions"
    return $EXIT_FAILURE
  fi

  # Distribution preference order (first is most preferred)
  local distro_prefs=("temurin" "zulu" "corretto" "adoptopenjdk")
  
  case "$pattern" in
    [0-9]*)
      # Extract just the number part in case user passes something like "8.0" -> "8"
      local major_version=$(echo "$pattern" | sed 's/^\([0-9]*\).*/\1/')
      version=$(asdf_find_latest_java_by_major "$major_version" "$all_versions" "${distro_prefs[@]}")
      ;;
    "latest")
      # Find the absolute latest version (highest major version number)
      # First, find the highest major version across ALL distributions
      local all_non_jre=$(echo "$all_versions" | grep -E "^[a-z]+-[0-9]+\." | grep -v "jre")
      local max_major=$(echo "$all_non_jre" | sed 's/^[^-]*-\([0-9]*\)\..*/\1/' | sort -n | tail -1)
      
      if [[ -n "$max_major" ]]; then
        # Use the existing function to find latest version for the highest major
        version=$(asdf_find_latest_java_by_major "$max_major" "$all_versions" "${distro_prefs[@]}")
      fi
      ;;
    *)
      # Try to match the pattern directly
      version=$(echo "$all_versions" | grep -E "^.*-${pattern}\." | sort -V | tail -1)
      ;;
  esac

  if [[ -z "$version" ]]; then
    echo >&2 "${FUNCNAME[0]}() :: No version found matching pattern: $pattern"
    return $EXIT_FAILURE
  fi

  echo "$version"
}
