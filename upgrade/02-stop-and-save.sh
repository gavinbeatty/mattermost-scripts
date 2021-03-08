#!/bin/dash
set -eu
set -x
sudo systemctl stop mattermost.service
if test -d /opt/mattermost ; then sudo cp -ra /opt/mattermost "/opt/mattermost-back-$(date +%Y%m%d)/" ; fi
