#!/bin/dash
set -eu
set -x
test $# -eq 1 || { echo "Must give 1 mattermost archive argument" >&2 ; exit 1 ; }
date="$(date +%Y%m%d)"
sudo install -dm0755 /opt
sudo tar -xvf "$1" --transform='s,^[^/]\+,\0-upgrade-'"$date," -C /opt/
