#!/bin/dash
set -eu
set -x
test $# -eq 1 || { echo "Must give 1 mattermost extracted archive dir argument" >&2 ; exit 1 ; }
cd /opt/
q1="$(bash -c 'printf %q "$1"' bash "$1")"
read -p "sudo cp -an $q1/. mattermost/ && sudo rm -r $q1/? [y/N]: " go
test "$go" != y || { sudo dash -c 'cd /opt/ && cp -an "$1/." mattermost/ && rm -r "$1/"' dash "$1" ; }
