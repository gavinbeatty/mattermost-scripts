#!/bin/dash
set -eu
set -x
test $# -eq 1 || { echo "Must give team name argument" >&2 ; exit 1 ; }
sudo -u mattermost /opt/mattermost/bin/mmctl --local --strict channel list "$1" | grep -v 'off-topic\|town-sq\|^[}]' | sudo -u mattermost xargs -rd\\n bash -c 'us=$(/opt/mattermost/bin/mmctl --local --strict user list | awk "{if(/channelexport|github|doodle|pressup|simplepoll|slackimport|surveybot/){}else{print \$2}}") && for i in "$@" ; do printf %q\  /opt/mattermost/bin/mmctl --local --strict channel users add "$1:$i" $us && echo ; done' bash "$1"
read -p 'Execute? [y/N]: ' go
test "$go" != y || sudo -u mattermost /opt/mattermost/bin/mmctl --local --strict channel list "$1" | grep -v 'off-topic\|town-sq\|^[}]' | sudo -u mattermost xargs -rd\\n dash -c 'us=$(/opt/mattermost/bin/mmctl --local --strict user list | awk "{if(/channelexport|github|doodle|pressup|simplepoll|slackimport|surveybot/){}else{print \$2}}") && for i in "$@" ; do /opt/mattermost/bin/mmctl --local --strict channel users add "$1:$i" $us ; done' dash "$1"
