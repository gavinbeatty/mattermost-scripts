#!/bin/dash
set -eu
set -x
if ! sudo -u mattermost env MMCTL_LOCAL_SOCKET_PATH=/var/run/mattermost/local.socket /opt/mattermost/bin/mmctl --local --strict system version >/dev/null 2>/dev/null ; then
    echo "Local mode must be enabled, which requires a mattermost restart:"
    read -p "sudo -u mattermost sed -i -e 's/\"EnableLocalMode\": false,/\"EnableLocalMode\": true,/' /opt/mattermost/config/config.json && sudo systemctl restart mattermost.service? [y/N]: " go
    test "$go" != y || sudo -u mattermost sed -i -e 's/"EnableLocalMode": false,/"EnableLocalMode": true,/' /opt/mattermost/config/config.json && sudo systemctl restart mattermost.service
fi
