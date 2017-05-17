# Separate file for alias

# builtin overrides -----------------------------------------------------------
if echo $HOSTTYPE | grep 86 2>&1 > /dev/null; then
  if echo $SHELL | grep bash 2>&1 > /dev/null; then # aliases are bash only
    if [ -f /usr/bin/dircolors ]; then
      #eval `dircolors --sh ~/DIR_COLORS`
      alias ll='ls -lF --color=tty'
      alias l.='ls .[a-zA-Z]* --color=tty'
      alias ls='ls --color=tty'
      alias la='ls -al --color=tty'
      alias lh='ls -lh --color=tty'
      alias lo='ls -og --color=tty'
    else
        alias ll='ls -lF'
        alias l.='ls .[a-zA-Z]*'
        alias ls='ls -p'
        alias la='ls -al'
        alias lh='ls -lh'
    fi
  else
    if echo $SHELL | grep bash 2>&1 > /dev/null; then # aliases are bash only
      alias ll='ls -lF'
      alias l.='ls .[a-zA-Z]*'
      alias ls='ls -p'
      alias la='ls -al'
      alias lh='ls -lh'
    fi
  fi
fi

# General ---------------------------------------------------------------------
alias go='. ~/.bash_profile'

alias grepp='ps aux | grep'
alias flushdns='dscacheutil -flushcache;sudo killall -HUP mDNSResponder'

alias tf='tail -F'
alias dfh='df -h'
alias tart='tar -tzf'
alias tarc='tar -czf'
alias tarx='tar -xzf'
alias tara='tar -rzf'

# deletes all empty folders recursively
alias rmempties='find -depth -type d -empty -exec rmdir {} \;'
alias rmzeros='find . -type f -size 0 -exec rm {} \;'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias exitr='exit'
alias ced='cd'
alias cde='cd'
