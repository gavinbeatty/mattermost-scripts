# mattermost-scripts

Requirements:

- mattermost installed to /opt/mattermost
- installed version also has mmctl
- configured with local mode enabled, and using path /run/mattermost/local.socket,
  because systemd sandboxing doesn't like /var/tmp/mattermost_local.socket,
  and RuntimeDirectory=mattermost (meaning /run/mattermost) is ready-made for such things

````
"EnableLocalMode": true,
"LocalModeSocketLocation": "/run/mattermost/local.socket",
````

