# Various extras for the bash prompt:
#   - git stuff
#   - active virtualenv
#   - status of last command
#
# To use just source in .bashrc (or equivalent)

#----------------------
# Git prompt variables
#----------------------

# You can also have the prompt show the 'dirty' status of your repo, i.e. if you
# have uncommited changes, and whether your branch differs from upstream HEAD:
#
# * = unstaged changes
# + = staged changes
# $ = stashed changes
# % = untracked files
# u-1 = behind upstream by 1 commit
# u+2 = ahead of upstream by 2 commits
# u= = same as upstream

# To enable showing the dirty (unstaged/staged) state
export GIT_PS1_SHOWDIRTYSTATE=1
# To enable showing the stashed state
export GIT_PS1_SHOWSTASHSTATE=1
# To enable showing the untracked state
export GIT_PS1_SHOWUNTRACKEDFILES=1
# To enable showing the upstream state. To not show the number of commits ahead
# or behind remove the "verbose" flag.
export GIT_PS1_SHOWUPSTREAM="auto verbose"

# Return the prompt symbol to use, colorized based on the return value of the
# previous command.
function set_prompt_symbol () {
  if [ $1 -eq 0 ]; then
      PROMPT_SYMBOL=">"
  else
      PROMPT_SYMBOL="\[${TPUT_RED1}\]☹\[${TPUT_NC}\]"
  fi
}

# Determine active Python virtualenv details.
function set_virtualenv () {
  if [ -z "$VIRTUAL_ENV" ]; then
      PYTHON_VIRTUALENV=""
  else
      PYTHON_VIRTUALENV="\[${TPUT_CADETBLUE}\]VE: `basename $VIRTUAL_ENV`\[${TPUT_NC}\]"
  fi
}

# Use the git bash-completion functions to set the current branch
function set_git () {
  GIT_PROMPT_STRING=$(__git_ps1 "(%s)")
}

# Set the tab title to either TAB_TITLE or the GIT_PROMPT_STRING
#
#   TAB_TITLE - Can be a string or function
#   GIT_PROMPT_STRING - Set in the `set_git` method
#
function set_tab_title () {
  local tab_title=${TAB_TITLE:-${GIT_PROMPT_STRING:-''}}
  echo -ne "\033]0;${tab_title}\007"
}

# Set the full bash prompt.
function set_bash_prompt () {
  # Set the PROMPT_SYMBOL variable. We do this first so we don't lose the
  # return value of the last command.
  set_prompt_symbol $?

  # Set the PYTHON_VIRTUALENV variable
  set_virtualenv

  # Set the GIT_PROMPT_STRING variable
  set_git

  # Set the tab title to the git branch
  set_tab_title "$GIT_PROMPT_STRING"

  # FIXME!
  # This is a little lame but you need to let bash know what not to print so
  # ${TPUT_RED} really needs to be \[${TPUT_RED}\]
  if [ "${PYTHON_VIRTUALENV}" == "" ]; then
    PS1="
\[${TPUT_DEEPPINK3}\]${GIT_PROMPT_STRING}\[${TPUT_NC}\]
[\[${TPUT_GREY66}\]\h: \[${TPUT_CORNFLOWERBLUE}\]\w\[${TPUT_NC}\]]
[\[${TPUT_RED3}\]\!\[${TPUT_NC}\]] ${PROMPT_SYMBOL} "
  else
    PS1="
${PYTHON_VIRTUALENV}
\[${TPUT_DEEPPINK3}\]${GIT_PROMPT_STRING}\[${TPUT_NC}\]
[\[${TPUT_GREY66}\]\h: \[${TPUT_CORNFLOWERBLUE}\]\w\[${TPUT_NC}\]]
[\[${TPUT_RED3}\]\!\[${TPUT_NC}\]] ${PROMPT_SYMBOL} "
  fi
}

# Tell bash to execute this function just before displaying its prompt.
PROMPT_COMMAND=set_bash_prompt
