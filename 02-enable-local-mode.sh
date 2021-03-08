#!/bin/dash
set -eu
set -x
sudo -u mattermost sed -i -e 's/"EnableLocalMode": false,/"EnableLocalMode": true,/' /opt/mattermost/config/config.json
