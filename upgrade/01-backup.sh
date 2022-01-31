#!/bin/dash
set -eu
set -x
dt="$(date -Iseconds)"
own="$(id -u):$(id -g)"
nginxtar="$HOME/backup/mattermost/$dt-nginx-etc.tar.zst"
(cd / && sudo bsdtar -LH --zstd -cf "$nginxtar" ./etc/nginx && sudo chown "$own" "$nginxtar")
sudo systemctl start mattermost-backup-pg.service
sudo systemctl start mattermost-backup-config.service
sudo systemctl start mattermost-backup-data.service
