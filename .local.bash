# Tab-complete for env vars will now expand it to full path
# shopt -s cdable_vars

#---------------------
# General environments
#---------------------
export EDITOR='subl'
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}
export PGDATA=/opt/twitter/var/postgres

# History
export HISTCONTROL=ignoreboth
export HISTFILESIZE=1000000
export HISTSIZE=1000000
export HISTIGNORE='la:man *:bg:fg:history *:which *:'
export PROMPT_COMMAND='history -a'

# Tell ls to be colourful
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Tell grep to highlight matches
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;32'


#-------------------------
# Workspace environments
#-------------------------
export DEVELOPMENT_WS=/Volumes/Development/git
export TWITTER_WS=${HOME}/workspace/source
export DEV_PORTAL_WS=${TWITTER_WS}/dataproducts/foundation/dev-portal


#--------------------------------------------------
# Files we want to source - functions, vars, etc.
#--------------------------------------------------
_SOURCE_FILES=(
  /opt/twitter_mde/etc/bash_profile
  $(brew --prefix)/etc/bash_completion
  ~/.bash/.colors.bash
  ~/.bash/.bash_aliases
  ~/.bash/.functions_iterm.bash
  ~/.bash/.bash_functions
  ~/.bash/.functions_git.bash
  ~/.bash/.functions_twitter.bash
  ~/.bash/.prompt.bash
)

for fname in "${_SOURCE_FILES[@]}"; do
  if [ -f "$fname" ]; then
    . "$fname"
  fi
done

# Source any host-specific bashrc files
if [ -f ~${USER}/${HOSTNAME%%.*}.bashrc ]; then
  . ~${USER}/${HOSTNAME%%.*}.bashrc
fi

export NVM_DIR="$HOME/.nvm"
. "/opt/twitter/opt/nvm/nvm.sh"
