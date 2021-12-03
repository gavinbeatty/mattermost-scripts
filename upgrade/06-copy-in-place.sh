#!/bin/dash
set -eu
set -x
test $# -eq 1 || { echo "Must give 1 mattermost extracted archive dir argument" >&2 ; exit 1 ; }
cd /opt/
/usr/bin/printf %q\  sudo cp -an "$1/." mattermost/ && echo
/usr/bin/printf %q\  sudo rm -r "$1/" && echo
read -p 'Execute? [y/N]: ' go
test "$go" != y || { sudo dash -c 'cd /opt/ && cp -an "$1/." mattermost/ && rm -r "$1/"' dash "$1" ; }
