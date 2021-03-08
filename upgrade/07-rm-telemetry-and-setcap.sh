#!/bin/dash
set -eu
set -x
sudo sed -i 's#api.segment.io#xx.example.com#gI' /opt/mattermost/bin/mattermost /opt/mattermost/bin/mmctl
sudo sed -i 's#securityupdatecheck.mattermost.com#xxxxxxxxxxxxxxxxxxxxxx.example.com#gI' /opt/mattermost/bin/mattermost /opt/mattermost/bin/mmctl
sudo setcap cap_net_bind_service=+ep /opt/mattermost/bin/mattermost
