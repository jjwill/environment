# Bash functions specifically for twitter

_get_workspace() {
  local default=${HOME}/workspace/source/dataproducts/foundation/dev-portal
  local portal_path=${DEV_PORTAL_WS:-$default}

  # We could be more robust but this works for now
  if [[ ! -d "$portal_path" ]]; then
    echo -e "\nCannot determine the path to the dev-portal dir."
    echo "Ensure it is in $default,"
    echo " or set the env variable \$DEV_PORTAL_WS"
    return 1
  fi

  echo $portal_path
}

# Function to cd to dev-portal location and optionally run a
# command
#
# Globals:
#   DEV_PORTAL_WS - Workspace for the dev-portal
# Arguments:
#   $1 - Repo's server path (where manage.py is located)
#   $2 - Command (options)
#
dev-portal() {
  local cmd=$1
  local portal_path=$(_get_workspace)

  [[ $? == 1 ]] && return 1;

  cd ${portal_path}/web

  if [ ! -z "$cmd" ]; then
    local script=${HOME}/bin/dev-portal.sh
    if [ ! -e "${script}" ]; then
      echo -e "\nCannot find dev-portal script, should be here: "
      echo "  $script"
      return 1
    fi
    bash "$script" "$@"
  fi
}

# Function that will start the API server, split the iterm
# window, then start the web server.
dev-portal-full() {
  # Run the dev-portal function above
  iterm_run_command "dev-portal api"
  iterm_split_tab
  iterm_run_command "dev-portal"
  iterm_run_command "npm run dev &"
}
