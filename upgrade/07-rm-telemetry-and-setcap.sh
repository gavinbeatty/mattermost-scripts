#!/bin/dash
set -eu
set -x
# Found via
# - https://docs.mattermost.com/manage/telemetry.html
# - https://handbook.mattermost.com/operations/research-and-development/engineering/data-engineering
sizes="$(sudo -u mattermost du -b /opt/mattermost/bin/mattermost /opt/mattermost/bin/mmctl)"
sudo -u mattermost cp -a /opt/mattermost/bin/mattermost /opt/mattermost/bin/mattermost.07.bak
sudo -u mattermost cp -a /opt/mattermost/bin/mmctl /opt/mattermost/bin/mmctl.07.bak
sudo -u mattermost sed -i 's#amazonaws\.com#x.example.com#gI' /opt/mattermost/bin/mattermost /opt/mattermost/bin/mmctl
sudo -u mattermost sed -i 's#api\.segment\.io#xx.example.com#gI' /opt/mattermost/bin/mattermost /opt/mattermost/bin/mmctl
sudo -u mattermost sed -i 's#ingest\.sentry\.io#xxxx.example.com#gI' /opt/mattermost/bin/mattermost /opt/mattermost/bin/mmctl
sudo -u mattermost sed -i 's#app\.stitchdata\.com#xxxxxx.example.com#gI' /opt/mattermost/bin/mattermost /opt/mattermost/bin/mmctl
sudo -u mattermost sed -i 's#cdn\.rudderlabs\.com#xxxxxx.example.com#gI' /opt/mattermost/bin/mattermost /opt/mattermost/bin/mmctl
sudo -u mattermost sed -i 's#analytics\.google\.com#xxxxxxxx.example.com#gI' /opt/mattermost/bin/mattermost /opt/mattermost/bin/mmctl
sudo -u mattermost sed -i 's#pdat\.matterlytics\.com#xxxxxxxxx.example.com#gI' /opt/mattermost/bin/mattermost /opt/mattermost/bin/mmctl
sudo -u mattermost sed -i 's#securityupdatecheck\.mattermost\.com#xxxxxxxxxxxxxxxxxxxxxx.example.com#gI' /opt/mattermost/bin/mattermost /opt/mattermost/bin/mmctl
newsizes="$(sudo -u mattermost du -b /opt/mattermost/bin/mattermost /opt/mattermost/bin/mmctl)"
if test "$sizes" != "$newsizes" ; then
    printf %s\\n "File sizes (in bytes) should not change after telemetry work" "Before:" "$sizes" "After:" "$newsizes" "Restoring originals" >&2
    sudo -u mattermost mv /opt/mattermost/bin/mattermost.07.bak /opt/mattermost/bin/mattermost
    sudo -u mattermost mv /opt/mattermost/bin/mmctl.07.bak /opt/mattermost/bin/mmctl
    exit 1
fi
sudo setcap cap_net_bind_service=+ep /opt/mattermost/bin/mattermost
