#!/bin/dash
set -eu
set -x
test $# -eq 2 || { echo "Must give team name and zip archive arguments" >&2 ; exit 1 ; }
type mmetl >/dev/null 2>/dev/null || { echo "Must install mmetl in PATH" >&2 ; exit 1; }
type zip >/dev/null 2>/dev/null || { echo "Must install zip in PATH" >&2 ; exit 1; }
case "$2" in
    /*) true ;;
    *) echo "Must give an absolute path to the zip archive" >&2 ; exit 1 ;;
esac
mkdir "$2.mmetl" || { echo "Found pre-existing $2.mmetl/ directory meaning not safe to use it as a transform destination" >&2 ; exit 1 ; }
mmetl transform slack --team "$1" --file "$2" --output "$2.mmetl/mattermost_import.jsonl" | tee "$(date -Iseconds)-slack-transform.log"
(cd "$2.mmetl" && mkdir -p bulk-export-attachments && zip -r "../$(basename "$2").mmetl.zip" bulk-export-attachments mattermost_import.jsonl)
chmod g+r "$2.mmetl.zip"
/usr/bin/printf %q\  sudo chgrp mattermost "$2.mmetl.zip" && echo
read -p 'Execute? [y/N]: ' go
test "$go" != y || sudo chgrp mattermost "$2.mmetl.zip"
