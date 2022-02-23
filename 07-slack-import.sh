#!/bin/dash
set -eu
set -x
test $# -eq 1 || { echo "Must give 1 available import argument" >&2 ; exit 1 ; }
printf %s\\n "$1" | grep -q '^[a-z0-9]\{26\}_[^/]*\.zip$' || { echo "Must give file path taken from \`mmctl --local --strict import list available\` output, e.g., \"yqbzwasqu8nkudtoem9nt96a3e_MYTEAM Slack export Jan 1 2013 - Dec 31 2021.zip.mmetl.zip\"" >&2 ; exit 1 ; }
sudo -u mattermost dash -c 'cd /opt/mattermost && env MMCTL_LOCAL_SOCKET_PATH=/var/run/mattermost/local.socket ./bin/mmctl --local --strict import process "$@"' dash "$@" | tee "$(date -Iseconds)-slack-import.log"
