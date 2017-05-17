# Bash functions, sourced in ~/.bashrc, ~/.local.bash, or somewhere...
#
# Stored in shell's memory so best used to modularize shell scripts.
#

# Mounts an image (sparseimage, sparsebundle, etc) with OSX's hdiutil
#
# Arguments:
#   $1 - Path to image file/dir
#
_mount_image () {
  if [ -d $1 ]; then
    hdiutil detach $1 &> /dev/null
    if [[ $? != 0 ]]; then
      echo "Cannot detach $1"
    fi
  fi
  hdiutil attach $2
}

# Common commands for django apps. Makes assumptions on directory
# structure
#
# Globals:
#   DJANGO_PORT - Default port to use, if not found will use 8090
# Arguments:
#   $1 - Repo's server path (where manage.py is located)
#   $2 - Command: only "start" supported now
#
_django_extra() {
  local directory=$1
  local cmd=$2

  local port=${DJANGO_PORT:-8090}

  cd $directory

  if [ "$cmd" == "start" ]; then
    echo -e '\nStarting server on port ' $port
    python manage.py runserver 0.0.0.0:${port} &
  fi
}

# Works off a single repo name. The following must be true, where $1=repo_name:
#
#   * There is virtualenv named `${repo_name}.ve/`
#   * There is a `server` directory with the manage.py file in it
#
# Globals:
#   BASH_ARGV - Used to parse the cli args, not the args passed to this fn
#   PYTHONPATH - Extended with server dir
#   DEVELOPMENT_WS - Path of development repos
# Arguments:
#   $1 - Repo name
#   $2 - Command: only support "start" now
#
_django_common() {
  local repo=${1:?"A repo name is required"}
  local cmd=$2

  # The activate_ve fn will catch incorrect paths
  cd ${DEVELOPMENT_WS}/${repo}
  activate_ve ${repo}.ve

  # Update PYTHONPATH, eases a few things
  export PYTHONPATH="${server_dir}:${PYTHONPATH}"

  # The original args passed to function that calls this
  if [ ! -z ${cmd} ]; then
    _django_extra ${DEVELOPMENT_WS}/${repo}/server ${cmd}
  fi
}

# Activates an app with osascript
#
# Arguments:
#   $1 - App name
#   $2 - If present will add a $2 seconds delay (useful with some apps
#        that take too long to load)
#
_activate_app() {
  local app=$1
  local delay=${2:-0}
  /usr/bin/osascript -e "delay ${delay}" -e "tell application \"${app}\" to activate"
}

# Create a file from a single path name. If its parent directory is not
# there this will prompt the user to automatically create it (unless the
# 2nd arg is false)
#   * param 1 <path>:   Path of file (required)
#   * param 2 <prompt_user>: Prompt or just create (default: "true")
create_file () {
  path=${1:?"A path is required"}
  prompt_user=${2:-"true"}

  if [ ! -e $path ]; then
    # Try to touch the file first an if it fails create the dir
    touch $path &> /dev/null
    if [ $? != 0 ]; then
      directory=`dirname $path`
      if [ "$prompt_user" == "true" ]; then
        echo -e "\nThe directory (${directory}) does not exist!"
        PS3="Create and open file or cancel? "
        select opt in Create Cancel; do
          case "$opt" in
            "Create") mkdir -p $directory && touch $path ;;
            "Cancel") return 1;;
            *)        echo "Invalid option" ;;
          esac
        break
        done
      fi
    fi
  fi
}

# Simple function to test if an element is in an array. Usage:
#
#  arr=(1 2 3 4 5)
#  contains_element 1 "${arr[@]}"
#  if [ "$?" == 0 ]; then
#    // success
#  else
#    // failure
#  fi
contains_element () {
  local query=$1
  local ele
  # "${@:2}" is an array of all the items passed in after the first
  for ele in "${@:2}"; do
    # Order is important here if there are *'s.
    #   e.g. "SEURAT_*" == "SEURAT_V7.1.0.7" --> false
    #        "SEURAT_V7.1.0.7" == "SEURAT_*" --> true
    [[ $query == $ele || $ele == $query ]] && return 0;
  done

  return 1
}

# Makes directories (creating intermediate directories as needed) and
# changes dir to newly created location
#
# Arguments:
#   $1 - path
#
mkgo() {
  if [ ! -d $1 ]; then
    mkdir -p $1
  fi
  cd $1
}

# 'cat's a file with line numbers
#
# Arguments:
#   $1 - filename
#
catln() {
  local filename=$1
  awk '{printf "%d\t%s\n", NR, $0}' < $filename
}

# Recursively removes all .pyc files
#
# Arguments:
#   "-override" - optionally override the maximum 1,000 subdirectory limit
#
rm_pyc() {
  local override=${1:-""}
  local total=`find ./ -type d | wc -l`
  echo -e "\nTotal subdirectories: $total"
  if [[ $total -ge 1000 && $override != "-override" ]]; then
    echo "To run this command on more than 1,000 subdirectories"
    echo "you will need to pass in the '-override' flag."
    echo "Exiting"
    return 1
  fi

  find . -name '*.pyc' -delete
  echo -e "\nAll '.pyc' files removed."
}

# Greps all *js files recursively
#
# Arguments:
#   $1 - pattern
#   ${@:2} - all other grep arguments (Default: passes in current dir)
#
jsgrep() {
  # Get total non-flag arguments
  local N=0
  for arg; do
    # -* indicates all args starting w/ a dash
    if [[ $arg != -* ]]; then
      N=$((N+1))
    fi
  done

  # In the case where there is no directory to grep recursively
  # in we add the current directory
  if [[ $N == 1 ]]; then
    set "$@" ./
  fi

  grep -r "$@" --include=*js
}

# Greps all *py files recursively
#
# Arguments:
#   $1 - pattern
#   $2 - directory to start (Default: current dir)
#
pygrep() {
  # Get total non-flag arguments
  local N=0
  for arg; do
    # -* indicates all args starting w/ a dash
    if [[ $arg != -* ]]; then
      N=$((N+1))
    fi
  done

  # In the case where there is no directory to grep recursively
  # in we add the current directory
  if [[ $N == 1 ]]; then
    set "$@" ./
  fi

  grep -r "$@" --include=*py
}

# Better than scp since you can pick up where you left off
rsync-ssh () {
  # -a  Archive mode (equivalent to -rlptgoD)
  # -v  Verbose
  # -z  Compress files during xfer
  # -P  Partial (awesome)
  echo Running rsync -avz -P -e ssh $1 $2 ...
  rsync -avz -P -e ssh $1 $2
}

# Prints the IP address over a VPN
get_vpn_ip() {
  ifconfig | grep "172." | awk '{split($0,n," "); print n[2]}'
}

# Moved to functions so I can import to scripts
postgresql_start() {
  pg_ctl -D $PGDATA -l ${PGDATA}/server.log start
}

postgresql_stop() {
  pg_ctl -D $PGDATA -l ${PGDATA}/server.log stop
}

# Activates a virtual env. It first looks in the $PWD for the virtualenv, then
# in the $HOME if not found.
#
# Usage:
#   activate_ve <name of virtualenv>
#
activate_ve () {
  ve_dir=$1

  if [ ! -d $ve_dir ]; then
    ve_dir=$HOME/virtualenvs/$1
  fi

  if [ -d $ve_dir ]; then
    source $ve_dir/bin/activate
  else
    echo -e "No virtualenv was found in these paths:\n $1\n $ve_dir"
  fi
}

# Mounts all sparsebundles
mount_dev() {
  _mount_image /Volumes/Development /images/Development.sparsebundle
}

# Initilizes the Amazon EC2 instances and sets up a couple aliases
ec2() {
  export EC2_HOME=~/.ec2
  export PATH=$PATH:$EC2_HOME/bin
  export EC2_PRIVATE_KEY=`ls $EC2_HOME/pk-*.pem`
  export EC2_CERT=`ls $EC2_HOME/cert-*.pem`
  export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home/

  export EC2_KEYPAIR=~/.ec2/id_rsa-olopoly-keypair
  export EC2_AMI_ID='ami-579f693e'
  export EC2_USER_ID='449781665406'
}

# Open a file in emacs
#
# Arguments:
#   $1 - file path
#   ${@:2} - All other args to pass to emacs
#
em() {
  # First create or touch the file. If they cancel, just return
  create_file $1 || return
  if [ -d "/Applications/Emacs.app/Contents/MacOS" ]; then
    # Open the file
    /usr/bin/open -a /Applications/Emacs.app "$@"
    _activate_app "Emacs.app"
  else
    /usr/bin/emacs $1
  fi
}

# Open intellij with all args passed to app
#
# Arguments:
#   $@ - Args to pass to app
#
intellij() {
  /usr/bin/open -a "/Applications/IntelliJ IDEA 12.app" "$@"
  _activate_app "IntelliJ IDEA 12.app"
}

# Open sublime with all args passed to app
#
# NOTE: Using subl is probably better
#
# Arguments:
#   $@ - Args to pass to app
#
sublime() {
  /usr/bin/open -a "/Applications/Sublime Text.app/Contents/MacOS/Sublime Text" "$@"
  _activate_app "Sublime Text"
}

# Open gitk with all args passed to app
#
# Arguments:
#   $@ - Args to pass to app
#
gitk () {
  # http://effectif.com/git/making-gitk-look-good-on-mac
  /usr/bin/wish `brew --repository`/bin/gitk "$@" &
  _activate_app "Wish" 1
}

# Open a man page with sublime
#
# Arguments:
#   $@ - Args to pass to app
#
sman() {
  MANWIDTH=80 MANPAGER='col -bx' /usr/bin/man "$1" | subl &
  # If you don't have access to subl (/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl)
  #open -f -a /Applications/Sublime\ Text.app/Contents/MacOS/Sublime\ Text
}

# Function to access the badged django repository
badged() {
  _django_common badged "$@"
}

# Function to access the dci dir
dcic() {
  cd $DEVELOPMENT_WS/dci-client/
}

dcis() {
  cd $DEVELOPMENT_WS/dci-server/
}
