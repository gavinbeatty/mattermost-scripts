#!/bin/dash
set -eu
set -x
sudo systemctl start mattermost-backup-pg.service
sudo systemctl start mattermost-backup-config.service
sudo systemctl start mattermost-backup-data.service
