# ~/.pretty-print.sh
# Utilities to prettify display

# Include required libraries
source ./std.sh


### Echo Formatting and Colors #################################################

### Format <ESC_SEQ>[ATTR_1;ATTR_2;..m
### Escape sequence
ESC_SEQ='\033' # More portable than '\e'

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


# Create an echo parsable expression from arguments for setting text attributes
# and colors
txt_attr() {
  ATTR_EXP=""
  while (( "$#" )); do
    if ! is_positive_number $1; then
      ATTR_EXP=""
      echo "$ATTR_EXP"
    fi
    ATTR_EXP="$ATTR_EXP$1;"
    shift
  done
  ATTR_EXP="$ESC_SEQ[${ATTR_EXP:0:${#ATTR_EXP}-1}m"
  echo -e "$ATTR_EXP"
}

#
reset_all=$(txt_attr $ATTR_RESET_ALL)
clear_to_eol="$ESC_SEQ[K"
clear_line="\r$clear_to_eol"

function clear_line() {
  echo -en $clear_line
}

function print_title() {
  bullet=$(txt_attr $FG_COLOR_GREEN)
  title=$(txt_attr $FG_COLOR_WHITE $ATTR_BOLD)
  echo -en "$bullet###$reset_all $title$1$reset_all"
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
  for COLOR_SEC in {0..256}; do
    echo -en "$color;${COLOR_SEC}m ${COLOR_SEC}\t${reset_all}"
    # echo -en "\e[${COLOR_POSITION};5;${COLOR_SEC}m ${COLOR_SEC}\t${reset_all}"

    # Display 10 colors per lines then brake
    if [ $((($COLOR_SEC + 1) % 10)) == 0 ]; then
      echo
    fi
  done
  echo
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
