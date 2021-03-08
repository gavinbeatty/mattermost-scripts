#!/bin/dash
set -eu
set -x
test $# -eq 1 || { echo "Must give admin username argument, e.g., admingavin" >&2 ; exit 1 ; }
sudo -u mattermost /opt/mattermost/bin/mmctl --local --strict user list | awk -v adminu="$1" '{if($2!=adminu){print $2}}' | sudo -u mattermost xargs -rd\\n bash -c 'for i in "$@" ; do printf %q\  /opt/mattermost/bin/mmctl --local --strict user delete "$i" --confirm && echo ; done' bash
read -p 'Execute? [y/N]: ' go
test "$go" != y || sudo -u mattermost /opt/mattermost/bin/mmctl --local --strict user list | awk -v adminu="$1" '{if($2!=adminu){print $2}}' | sudo -u mattermost xargs -rd\\n dash -c 'for i in "$@" ; do /opt/mattermost/bin/mmctl --local --strict user delete "$i" --confirm ; done' dash
