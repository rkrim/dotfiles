# ~/.install_helper.sh
# Utilities to manage install and uninstall


# Include required libraries
source ./pretty-print.sh


# is_brew_package_installed()
# Check if a brew package is already installed
# brew command must be installed
# @param1 required, Package name
# @param2 optional, cask flag, default false
# @return: The versoin number of the package if its installed
function is_brew_package_installed {
  if [[ $# == 0  || $# > 2 || $1 == "" ]]; then
    return $FALSE
  fi

  package_tokens=( $1 )
  package_name=${package_tokens[0]}
  brew_command="brew"
  if [[ $2 == "cask" || $2 == "true" || $2 == $TRUE ]]; then
    brew_command="brew cask"
  fi

  result=`$brew_command list --versions $package_name 2> /dev/null`
  if [[ $? == 0 ]]; then
    echo $result | cut -d " " -f2
    return $TRUE
  else
    return $FALSE
  fi
}


# brew_package_install()
# Install a Brew package after Checking if already installed
# @param1 required, Package name, or package name with installation aruments
# @param2 optional, cask flag, default false
function brew_package_install {
  if [[ $# == 0  || $# > 2 || $1 == "" ]]; then
    return $FALSE
  fi

  brew_command="brew"
  if [[ $2 == "cask" || $2 == "true" || $2 == $TRUE ]]; then
    brew_command="brew cask"
  fi

  package_name=$1
  log_file="output.file"
  txt_attr_pkg_name=$(txt_attr $FG_COLOR_LIGHT_CYAN $ATTR_BOLD)
  txt_attr_warning=$(txt_attr $FG_COLOR_YELLOW)
  txt_attr_success=$(txt_attr $FG_COLOR_LIGHT_GREEN)
  txt_attr_fail=$(txt_attr $FG_COLOR_LIGHT_RED)

  prefix_line="Package $txt_attr_pkg_name$package_name$reset_all"

  echo -en $prefix_line" [$txt_attr_warning"" Processing $reset_all] :: Checking if already installed..."
  package_version=`is_brew_package_installed "$package_name" $2 2> /dev/null`
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

      package_version=`is_brew_package_installed "$package_name" $2 2> /dev/null`
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
# @param2 optional, cask flag, default false
function brew_batch_install {
  if [[ $# == 0  || $# > 2 || $1 == "" ]]; then
    return $FALSE
  fi

  declare -a packages=("${!1}")

  for package in "${packages[@]}"; do
    brew_package_install "$package" $2
  done
}

# mas_batch_install()
# Install a list of mas applications
# @param1 required, an array of mas app identifiers
function mas_batch_install {
  if [[ $# != 1 || $1 == "" ]]; then
    return $FALSE
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
    return $FALSE
  fi

  shell_path=$1
  make_default_shell=$2

  if [[ -n $shell_path && ! `cat /etc/shells | grep $shell_path` ]]; then
    echo $shell_path | sudo tee -a /etc/shells

    # Change the current user default shell to the new one
    if [[ -n $make_default_shell && ($make_default_shell == "default" || $make_default_shell == "true" || $make_default_shell == $TRUE ) && `command -v chsh` ]]; then
      chsh -s $shell_path
    fi
  fi
}


# dotfiles_symlink()
# Create symbolic link for dotfiles found in arg 1, in home folder
# links are prefixed with '.'
# original files will be moved to a backup folder
function dotfiles_symlink {
  if [[ $# != 1 || $1 == "" ]]; then
    echo "Bad argument: Expected dotfiles location"
    return 1
  fi

  files_location=$1
  working_directory=`pwd`

  dotfiles_backup=".dotfiles.old"
  dotfiles=($(ls $files_location 2> /dev/null))
  files_count=${#dotfiles[*]}

  if [[ $files_count -eq 0 || ($files_count -eq 1 && ${dotfiles[0]} == "") ]]; then
    echo >&2 "No file found in provided dotfiles folder"
    return 1
  fi

  # Create backup folder
  if [ ! -d ~/$dotfiles_backup ]; then
    mkdir ~/$dotfiles_backup 2> /dev/null
    if [ $? != 0 ]; then
      echo >&2 "Error: Can't create bakup folder, skipping simlink"
      return 1
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
      mv -n $link_name ~/$dotfiles_backup 2> /dev/null
      if [ $? != 0 ]; then
        continue
      fi
    fi

    # echo "ln -s $file_path $link_name"
    ln -s $file_path $link_name 2> /dev/null

    if [ $? == 0 ]; then
      link_count=$((link_count + 1))
    fi
  done

  # Remove backup folder if empty
  if [ -z "$(ls -A ~/$dotfiles_backup 2> /dev/null)" ]; then
    rm -rf ~/$dotfiles_backup
  fi

  if [[ $link_count != $files_count ]]; then
    echo >&2 "Warning: Created '$link_count' links, while expecting '$files_count'"
    return 1
  fi

  return 0
}
