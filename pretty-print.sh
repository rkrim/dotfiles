# ~/.pretty-print.sh
# Some utilities to prettify display



### Echo Formatting and Colors #################################################


### Format <ESC_SEQ>[ATTR_1;ATTR_2;..m
### Escape sequence
ESC_SEQ='\e'

### Formatting
ATTR_BOLD='1';ATTR_DIM='2';ATTR_UNDERLINE='4'
ATTR_BLINK='5';ATTR_REVERSE='7';ATTR_HIDE='8'

ATTR_RESET_ALL='0'
ATTR_RESET_BOLD='21';ATTR_RESET_DIM='22';ATTR_RESET_UNDERLINE='24'
ATTR_RESET_BLINK='25';ATTR_RESET_REVERSE='27';ATTR_RESET_HIDE='28'

# 8/16 Colors
FG_COLOR_DEFAULT='39'
FG_COLOR_BLACK='30';FG_COLOR_RED='31';FG_COLOR_GREEN='32'
FG_COLOR_YELLOW='33';FG_COLOR_BLUE='34';FG_COLOR_MAGENTA='35'
FG_COLOR_CYAN='36';FG_COLOR_LIGHT_GRAY='37';FG_COLOR_DARK_GRAY='90'
FG_COLOR_LIGHT_RED='91';FG_COLOR_LIGHT_GREEN='92';FG_COLOR_LIGHT_YELLOW='93'
FG_COLOR_LIGHT_BLUE='94';FG_COLOR_LIGHT_MAGENTA='95';FG_COLOR_LIGHT_CYAN='96'
FG_COLOR_WHITE='97'

BG_COLOR_DEFAULT='49'
BG_COLOR_BLACK='40';BG_COLOR_RED='41';BG_COLOR_GREEN='42'
BG_COLOR_YELLOW='43';BG_COLOR_BLUE='44';BG_COLOR_MAGENTA='45'
BG_COLOR_CYAN='46';BG_COLOR_LIGHT_GRAY='47';BG_COLOR_DARK_GRAY='100'
BG_COLOR_LIGHT_RED='101';BG_COLOR_LIGHT_GREEN='102';BG_COLOR_LIGHT_YELLOW='103'
BG_COLOR_LIGHT_BLUE='104';BG_COLOR_LIGHT_MAGENTA='105';BG_COLOR_LIGHT_CYAN='106'
BG_COLOR_WHITE='107'

# Boolean vars
TRUE=0
FALSE=1

# Check if the argument is a decimal number (currently only >= 0)
is_decimal() {
	if [[ $# != 1 ]]; then
		return $FALSE
	fi
	decimal_regexp='^[0-9]+$'
	[[ $1 =~ $decimal_regexp ]]
}

# Create an echo parsable expression from arguments for setting text attributes
# and colors
txt_attr() {
	ATTR_EXP=""
	while (( "$#" )); do
		if ! is_decimal $1; then
			ATTR_EXP=""
			echo "$ATTR_EXP"
			return $FALSE
		fi
		ATTR_EXP="$ATTR_EXP$1;"
	  shift
	done
	ATTR_EXP="$ESC_SEQ[${ATTR_EXP: : -1}m"
	echo "$ATTR_EXP"
	return $TRUE
}

#
reset_all=$(txt_attr $ATTR_RESET_ALL)
clear_to_eol="$ESC_SEQ[K"
clear_line="\r$clear_to_eol"

function clear_line() {
	echo -en $clear_line
}



### 88/256 Colors
# The format for changing colors is “<ESC_SEQ>[38/48;5;ColorNumberm”
# where 38=Foreground and 48=Background

# By default displays colors in background, pass fg as unique argument to switch
display_256colors() {
	# Foreground=38 Background=48
	if [[ $1 == "fg" ]]; then
		COLOR_POSITION=38
	else
		COLOR_POSITION=48
	fi

	color=$(txt_attr $COLOR_POSITION 5)
	color=${color: : -1}
	for COLOR in {0..256}; do
		echo -en "$color;${COLOR}m ${COLOR}\t${reset_all}"
		# echo -en "\e[${COLOR_POSITION};5;${COLOR}m ${COLOR}\t${reset_all}"
		# Display 10 colors per lines
		if [ $((($COLOR + 1) % 10)) == 0 ]; then
			echo
		fi
	done
	echo
}


# is_brew_package_installed()
# Check if a brew package is already installed
# brew command must be installed
#
# @param Package name
# @return: The versoin number of the package if its installed
function is_brew_package_installed() {
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


# brew_pkg_install()
# Install a Brew package after Checking if already installed
# @param Package name, or package name with installation aruments
function brew_pkg_install() {
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
		installation=`brew install $package_name > "$log_file" 2>&1`
		installtion_status=$?
		clear_line
		if [[ $package_version_status == 0 ]]; then
			echo -en $prefix_line" [$txt_attr_success"" Installation successful $reset_all]\n" | tee -a $log_file
		else
			echo -en $prefix_line" [$txt_attr_fail"" Installation failed $reset_all]\n" | tee -a $log_file
		fi
	fi
}

# brew_batch_install()
# Install a list of Brew packages
# @param an array of brew packages, or list of brew packages with installtion aruments
function brew_batch_install() {
	if [[ $# != 1 ]]; then
		return $FALSE
	fi

	declare -a packages=("${!1}")

	for package in "${packages[@]}"; do
		brew_pkg_install $package
	done
}

### tput colors ################################################################
tput_reset() { tput sgr0; }

tput_fg_black() { tput setaf 0; }
tput_fg_red() { tput setaf 1; }
tput_fg_green() { tput setaf 2; }
tput_fg_yellow() { tput setaf 3; }
tput_fg_blue() { tput setaf 4; }
tput_fg_magenta() { tput setaf 5; }
tput_fg_cyan() { tput setaf 6; }
tput_fg_white() { tput setaf 7; }

tput_bg_black() { tput setab 0; }
tput_bg_red() { tput setab 1; }
tput_bg_green() { tput setab 2; }
tput_bg_yellow() { tput setab 3; }
tput_bg_blue() { tput setab 4; }
tput_bg_magenta() { tput setab 5; }
tput_bg_cyan() { tput setab 6; }
tput_bg_white() { tput setab 7; }
