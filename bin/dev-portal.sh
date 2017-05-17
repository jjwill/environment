#!/bin/bash
#
# Script to do a few things related to developing for
# Twitter dev portal from the CLI

# Make assumptions on the location of the workspace if not provided
WORKSPACE=${TWITTER_WS:-${HOME}/workspace/source}

DEV_PORTAL_SCRIPTS=${WORKSPACE}/dataproducts/foundation/common/scripts/
PORTAL_PATH=${WORKSPACE}/dataproducts/foundation/dev-portal

# We could be more robust but this works for now
if [[ ! -d "$PORTAL_PATH" ]]; then
  echo -e "\nCannot determine the path to the source."
  echo "Ensure it is in ${HOME}/workspace/source, or "
  echo "set the env variable \$TWITTER_WS."
  exit 1
fi

print_description() {
  echo -e "\nScript to do a few things related to developing for "
  echo "Twitter dev portal from the CLI"
}

print_usage() {
cat <<EOF

Usage: $0 <api|web|stop|test|lint> [options]

Commands:
  api      Starts dev portal api with staging1 acl
  web      Starts up the webserver
  stop     Nothing
  test     Nothing
  lint     Nothing

Options:
  -h       Print this help text and exit

EOF
}

start_api() {
  echo -e "\nStarting the dev-portal API..."
  cd ${WORKSPACE}
  bash ${DEV_PORTAL_SCRIPTS}/start-dev-portal-with-staging1-acl.sh
}

start_webserver() {
  echo -e "\nStarting the dev-portal web server..."
  cd ${PORTAL_PATH}/web
  npm run dev &
}

run_tests() {
  echo -e "\nRunning tests for dev-portal..."
  cd ${PORTAL_PATH}/web
  npm run test
}

run_linter() {
  echo -e "\nRunning linter for dev-portal..."
  cd ${PORTAL_PATH}/web
  npm run lint
}

# Not sure why this was needed, jasonw commented that it was required
fix_tar_permission() {
  sudo find -x /opt/twitter -user 501 -exec chown -hv 502 {} +
}

#- Main ----------------------------------------------------------------------

# Parse the CLI
while (( "$#" )); do
  opt=${1:-}
  value=${2:-}
  # Make sure to shift here and any option that uses the $value
  shift
  case $opt in
    -h)
      print_description;
      print_usage;
      exit 0 ;;
    api | web | stop | test | lint)
      COMMAND=$opt;
      shift ;;
    * ) # Invalid flag
      echo "Error - Invalid option: $opt"
      print_usage
      exit 192
      ;;
  esac
done

case "$COMMAND" in
  api)
    start_api
    ;;
  web)
    start_webserver
    ;;
  stop)
    echo "Not sure yet"
    ;;
  test)
    run_tests
    ;;
  lint)
    run_linter
    ;;
  *)
    echo "Error - Invalid or missing command: $COMMAND"
    print_usage
    exit 1
    ;;
esac
