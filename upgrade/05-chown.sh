#!/bin/dash
set -eu
set -x
test $# -eq 1 || { echo "Must give 1 mattermost extracted archive dir argument" >&2 ; exit 1 ; }
read -p "sudo chown -hR mattermost:mattermost $(bash -c 'printf %q\  "$@"' bash "$1")? [y/N]: " go
test "$go" != y || sudo chown -hR mattermost:mattermost "$1"
