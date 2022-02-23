#!/bin/dash
set -eu
set -x
test $# -eq 1 || { echo "Must give team name argument" >&2 ; exit 1 ; }
sudo -u mattermost env MMCTL_LOCAL_SOCKET_PATH=/var/run/mattermost/local.socket /opt/mattermost/bin/mmctl --local --strict channel list "$1" | grep -v 'off-topic\|town-sq\|^[}]' | sudo -u mattermost xargs -rd\\n dash -c 't="$1" ; shift ; /usr/bin/printf %q\  env MMCTL_LOCAL_SOCKET_PATH=/var/run/mattermost/local.socket /opt/mattermost/bin/mmctl --local --strict channel delete $(printf %s:%s\  "$t" "$@") --confirm && echo' dash "$1"
read -p 'Execute? [y/N]: ' go
test "$go" != y || sudo -u mattermost env MMCTL_LOCAL_SOCKET_PATH=/var/run/mattermost/local.socket /opt/mattermost/bin/mmctl --local --strict channel list "$1" | grep -v 'off-topic\|town-sq\|^[}]' | sudo -u mattermost xargs -rd\\n dash -c 't="$1" ; shift ; env MMCTL_LOCAL_SOCKET_PATH=/var/run/mattermost/local.socket /opt/mattermost/bin/mmctl --local --strict channel delete $(printf %s:%s\  "$t" "$@") --confirm' dash "$1"
