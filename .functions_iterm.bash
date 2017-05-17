# Bash function for iterm

# Executes an array of key codes sequentially
#
# Arguments:
#   $@ - key codes to process
#
__iterm_key_codes() {
  for code in "$@"; do
    /usr/bin/osascript -e "tell application \"System Events\" to tell process \"iTerm\" to key code ${code}"
  done
}

# Executes an array of keystrokes sequentially
#
# Arguments:
#   $@ - keystrokes to process
#
__iterm_keystrokes() {
  for keystroke in "$@"; do
    /usr/bin/osascript -e "tell application \"System Events\" to tell process \"iTerm\" to keystroke \"${keystroke}\""
  done
}

# Executes a keystroke with a special key down
#
# Arguments:
#   $1 - keystroke to process
#   $2 - key to be depressed
#
__iterm_command_w_down() {
  local cmd_string=$1
  local key_down=$2
  /usr/bin/osascript -e "tell application \"System Events\" to tell process \"iTerm\" to keystroke \"$cmd_string\" using $key_down down"
}

# Programatically presses enter in iterm
#
__iterm_enter() {
  __iterm_key_codes 52
}

# Programatically opens a new tab in iterm
#
__iterm_new_tab() {
  /usr/bin/osascript -e 'tell application "iTerm" to activate'
  __iterm_command_w_down "t" "command"
}

# Programatically splits a tab in iterm
#
iterm_split_tab() {
  __iterm_command_w_down "d" "command"
}

# Executes a set of keystrokes as a single command, and presses enter
#
# Arguments:
#   $@ - command string
#
iterm_run_command() {
  __iterm_keystrokes "$@"
  __iterm_enter
}
