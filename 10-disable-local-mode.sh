#!/bin/dash
set -eu
set -x
sudo -u mattermost sed -i -e 's/"EnableLocalMode": true,/"EnableLocalMode": false,/' /opt/mattermost/config/config.json
