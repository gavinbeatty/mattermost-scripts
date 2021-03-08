#!/bin/dash
set -eu
set -x
cd /opt
xs="$(sudo find mattermost/ mattermost/client/ -mindepth 1 -maxdepth 1 \
    \! \( -type d \( -path mattermost/client -o -path mattermost/client/plugins -o -path mattermost/config -o -path mattermost/logs -o -path mattermost/plugins -o -path mattermost/data \) -prune \) \
    | sort)"
test -n "$xs" || { echo "error: nothing to delete" >&2 ; exit 1 ; }
printf %s\\n "$xs" | sed -e 's,^,/opt/,'
read -p 'sudo rm -r? [y/N]: ' go
test "$go" != y || printf %s\\n "$xs" | sudo xargs -rd\\n rm -r
