# ~/.install_helper.sh
# Utilities to manage install and uninstall


# Include required libraries
source ./pretty-print.sh


# is_brew_package_installed()
# Check if a brew package is already installed
# brew command must be installed
# @param Package name
# @return: The versoin number of the package if its installed
function is_brew_package_installed {
	if [[ $# != 1  || $1 == "" ]]; then
		return $FALSE
	fi

	package_tokens=( $1 )
	package_name=${package_tokens[0]}
  result=`brew list --versions $package_name`
	if [[ $? == 0 ]]; then
    echo $result | cut -d " " -f2
    return $TRUE
	else
    return $FALSE
	fi
}


# brew_package_install()
# Install a Brew package after Checking if already installed
# @param Package name, or package name with installation aruments
function brew_package_install {
	if [[ $# != 1  || $1 == "" ]]; then
		return $FALSE
	fi
	package_name=$1
	log_file="output.file"
  txt_attr_pkg_name=$(txt_attr $FG_COLOR_LIGHT_CYAN $ATTR_BOLD)
	txt_attr_warning=$(txt_attr $FG_COLOR_YELLOW)
	txt_attr_success=$(txt_attr $FG_COLOR_LIGHT_GREEN)
	txt_attr_fail=$(txt_attr $FG_COLOR_LIGHT_RED)

	prefix_line="Package $txt_attr_pkg_name$package_name$reset_all"

	echo -en $prefix_line" [$txt_attr_warning"" Processing $reset_all] :: Checking if already installed..."
	package_version=`is_brew_package_installed "$package_name"`
	package_version_status=$?

	clear_line
	if [[ $package_version_status == 0 ]]; then
		echo -en $prefix_line" [$txt_attr_success"" Already Installed $reset_all] :: Version $package_version\n" | tee -a $log_file
	else
		echo -en $prefix_line" [$txt_attr_warning"" Processing $reset_all] :: Not Installed, installing..."
		installation=`brew install $package_name >> "$log_file" 2>&1`
		installtion_status=$?
		clear_line
		if [[ $installtion_status == 0 ]]; then
			echo -en $prefix_line" [$txt_attr_success"" Installation successful $reset_all]" | tee -a $log_file

      package_version=`is_brew_package_installed "$package_name"`
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
# @param an array of brew packages, or list of brew packages with installtion aruments
function brew_batch_install {
	if [[ $# != 1 ]]; then
		return $FALSE
	fi

	declare -a packages=("${!1}")

	for package in "${packages[@]}"; do
		brew_package_install $package
	done
}
