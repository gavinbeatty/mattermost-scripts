#!/bin/dash
set -eu
test $# -eq 2 || { echo "Must give user-emails.txt and exclude-user-emails.txt arguments (format \"\$username \$email\" per-line, e.g., \"gavin public@gavinbeatty.com\")" >&2 ; exit 1; }
ues="$(cat "$1")"
xues="$(cat "$2")"
e=0
while test $# -gt 0 ; do
    printf %s\\n "$ues" "$xues" | awk -v u="$1" '{if($1==u){print $0}}' | dash -c 'while read u e ; do set -x ; sudo -u mattermost /opt/mattermost/bin/mmctl --local --strict user email "$u" "$e" && sudo -u mattermost /opt/mattermost/bin/mmctl --local --strict user reset_password "$e" ; set +x ; done' dash
    e=1
    shift
done
test $e -eq 0 || exit
echo "$ues" | dash -c 'while read u e ; do /usr/bin/printf %q\  sudo -u mattermost /opt/mattermost/bin/mmctl --local --strict user email "$u" "$e" && echo && /usr/bin/printf %q\  sudo -u mattermost /opt/mattermost/bin/mmctl --local --strict user reset_password "$e" && echo ; done' dash
read -p 'Execute? [y/N]: ' go
test "$go" != y || { echo "$ues" | dash -c 'while read u e ; do sudo -u mattermost /opt/mattermost/bin/mmctl --local --strict user email "$u" "$e" && sudo -u mattermost /opt/mattermost/bin/mmctl --local --strict user reset_password "$e" ; done' dash ; }
