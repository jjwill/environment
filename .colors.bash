# A bash file for coloring stuff. It consists of:
#
#   - List of COLOR_<name> shell variables
#   - Functions using tput named by lowercase colors
#

# ------------------------------------------------------------
# Color definitions (taken from Color Bash Prompt HowTo).
# Some colors might look different of some terminals.
# For example, I see 'Bold Red' as 'orange' on my screen,
# hence the 'Green' 'BRed' 'Red' sequence I often use in my prompt.
# ------------------------------------------------------------

# Normal Colors
export COLOR_BLACK='\e[0;30m'        # Black
export COLOR_RED='\e[0;31m'          # Red
export COLOR_GREEN='\e[0;32m'        # Green
export COLOR_YELLOW='\e[0;33m'       # Yellow
export COLOR_BLUE='\e[0;34m'         # Blue
export COLOR_PURPLE='\e[0;35m'       # Purple
export COLOR_CYAN='\e[0;36m'         # Cyan
export COLOR_WHITE='\e[0;37m'        # White

# Bold
export COLOR_BBLACK='\e[1;30m'       # Black
export COLOR_BRED='\e[1;31m'         # Red
export COLOR_BGREEN='\e[1;32m'       # Green
export COLOR_BYELLOW='\e[1;33m'      # Yellow
export COLOR_BBLUE='\e[1;34m'        # Blue
export COLOR_BPURPLE='\e[1;35m'      # Purple
export COLOR_BCYAN='\e[1;36m'        # Cyan
export COLOR_BWHITE='\e[1;37m'       # White

# Background
export COLOR_ON_BLACK='\e[40m'       # Black
export COLOR_ON_RED='\e[41m'         # Red
export COLOR_ON_GREEN='\e[42m'       # Green
export COLOR_ON_YELLOW='\e[43m'      # Yellow
export COLOR_ON_BLUE='\e[44m'        # Blue
export COLOR_ON_PURPLE='\e[45m'      # Purple
export COLOR_ON_CYAN='\e[46m'        # Cyan
export COLOR_ON_WHITE='\e[47m'       # White

export COLOR_NC="\e[m"               # Color Reset

# See: http://bitmote.com/index.php?post/2012/11/19/Using-ANSI-Color-Codes-to-Colorize-Your-Bash-Prompt-on-Linux
export COLOR_GBLUE='\033[38;5;24m'
export COLOR_GBLACK='\033[38;5;244m'

# Prompt colors
export PNC="\[\e[0m\]"
export PPURPLE="\[$COLOR_PURPLE\]"
export COLOR_RED_PROMPT="\[$COLOR_RED\]"
export PGBLACK="\[$COLOR_GBLACK\]"
export PGBLUE="\[$COLOR_GBLUE\]"


# ------------------------------------------------------------
# tput funcitonality, 256 colors
# ------------------------------------------------------------

. ~/.bash/.colors_tput.bash

# Prints a string in the specified color, ending in a newline
#
# Positional args:
# color - Number representing color
# args - All items to print
#
function __tput_color_print() {
  local color=$(tput setaf $1)
  local nc=$(tput sgr0)
  # Works when only 8 colors
  # local nc=$(tput setaf 9)
  printf "$color%b$nc\n" "${*:2}"
}

function error_text() {
  # Not sure why the newline isn't added in the call to `red`
  # Add a newline in the beginning to emphasize
  printf "\n$(tput bold) `red $*`\n"
}

# Common colors
black() { __tput_color_print 0 "$*" ; }
red() { __tput_color_print 9 "$*" ; }
green() { __tput_color_print 2 "$*" ; }
yellow() { __tput_color_print 11 "$*" ; }
blue() { __tput_color_print 12 "$*" ; }
purple() { __tput_color_print 5 "$*" ; }
teal() { __tput_color_print 6 "$*" ; }
white() { __tput_color_print 15 "$*" ; }
orange() { __tput_color_print 172 "$*" ; }

# Just a function to see all the colors
function tput_print_all() {
  for fg_color in {0..255}; do
    set_foreground=$(tput setaf $fg_color)
    set_background=$(tput setab 0)
    echo -n $set_background$set_foreground
    # You could loop through all bg colors too
    # printf ' F:%s B:%s' $fg_color $bg_color
    printf ' F:%s ' $fg_color
    echo -n $(tput sgr0)
  done
}

# Prints all tput colors to their hex value
function tput_all_to_hex() {
  for i in $(seq 0 15); do
    dec=$((${i}%256))   ### input must be a number in range 0-255.
    if [ "$dec" -lt "16" ]; then
      bas=$(( dec%16 ))
      mul=128
      [ "$bas" -eq "7" ] && mul=192
      [ "$bas" -eq "8" ] && bas=7
      [ "$bas" -gt "8" ] && mul=255
      a="$((  (bas&1)    *mul ))"
      b="$(( ((bas&2)>>1)*mul ))"
      c="$(( ((bas&4)>>2)*mul ))"
      printf 'dec= %3s basic= #%02x%02x%02x\n' "$dec" "$a" "$b" "$c"
    elif [ "$dec" -gt 15 ] && [ "$dec" -lt 232 ]; then
      b=$(( (dec-16)%6  )); b=$(( b==0?0: b*40 + 55 ))
      g=$(( (dec-16)/6%6)); g=$(( g==0?0: g*40 + 55 ))
      r=$(( (dec-16)/36 )); r=$(( r==0?0: r*40 + 55 ))
      printf 'dec= %3s color= #%02x%02x%02x\n' "$dec" "$r" "$g" "$b"
    else
      gray=$(( (dec-232)*10+8 ))
      printf 'dec= %3s  gray= #%02x%02x%02x\n' "$dec" "$gray" "$gray" "$gray"
    fi
  done
}

