#!/bin/dash
set -eu
set -x
test $# -eq 1 || { echo "Must give 1 mattermost extracted archive dir argument" >&2 ; exit 1 ; }
/usr/bin/printf %q\  sudo chown -hR mattermost:mattermost "$1" && echo
read -p 'Execute? [y/N]: ' go
test "$go" != y || sudo chown -hR mattermost:mattermost "$1"
