#!/bin/dash
set -eu
set -x
(test $# -eq 1 && printf %s\\n "$1" | grep -q '\.mmetl\.zip$') || { echo "Must give 1 zip archive argument created by 05-slack-transform.sh (ending in .mmetl.zip)" >&2 ; exit 1 ; }
sudo -u mattermost dash -c 'cd /opt/mattermost && ./bin/mmctl --local --strict import upload "$@" && ./bin/mmctl --local --strict import list available' dash "$@" | tee "$(date -Iseconds)-slack-upload.log"
