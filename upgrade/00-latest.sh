#!/bin/sh
cd /
echo Installed:
installed="$(sudo -u mattermost /opt/mattermost/bin/mattermost version 2>/dev/null | sed -n 's/^[A-Z]/  &/p')"
printf %s\\n "$installed"
echo Latest:
deployhtml="$(curl -fsSL https://mattermost.com/deploy/)"
deployver="$(printf %s\\n "$deployhtml" | sed -n 's/^\s*\(<[^<]*class="release-text-left-latest"\)/  \1/p' | sed -e 's/.*>\s*\(.*\)\s*<.*/\1/')"
printf "  Deploy version: %s\\n" "$deployver"
deploydate="$(printf %s\\n "$deployhtml" | sed -n 's/^\s*\(<[^<]*class="release-text-left-date"\)/  \1/p' | sed -e 's/.*>\s*\(.*\)\s*<.*/\1/')"
printf "  Deploy date: %s\\n" "$deploydate"
vahtmlsubset="$(curl -fsSL https://docs.mattermost.com/upgrade/version-archive.html | grep '<code\b.*\bhttps://releases\.mattermost\.com/[^d/][^/]*/mattermost-team-' -A1)"
archiveurl="$(printf %s\\n "$vahtmlsubset" | sed -n '1s#.*\b\(https://releases\.mattermost\.com/[^d/][^/]*/mattermost-team-[^"<>]*linux-amd64\.\(tar\.\|t\)\(gz\|bz2\|xz\|zst\)\).*#\1#p')"
printf "  Archive URL: %s\\n" "$archiveurl"
archiveurlver="$(printf %s\\n "$archiveurl" | sed -e 's#.*\bhttps://releases\.mattermost\.com/\([^d/][^/]*\).*#\1#')"
printf "  Archive URL version: %s\\n" "$archiveurlver"
archivesum="$(printf %s\\n "$vahtmlsubset" | sed -En '2s#.*[^0-9a-fA-F]([0-9a-fA-F]{64})[^0-9a-fA-F].*#\1#p')"
printf "  Archive SHA-256: %s\\n" "$archivesum"
if test -z "$deployver" ; then
    echo Could not extract latest deploy version. >&2 ; exit 1
fi
if test -z "$deploydate" ; then
    echo Could not extract latest deploy date. >&2 ; exit 1
fi
if test -z "$archiveurl" ; then
    echo Could not extract latest archive URL. >&2 ; exit 1
fi
if test -z "$archiveurlver" ; then
    echo Could not extract latest archive URL version. >&2 ; exit 1
fi
if test -z "$archivesum" ; then
    echo Could not extract latest archive SHA-256. >&2 ; exit 1
fi


installedent="$(printf %s\\n "$installed" | sed -n 's/^\s*Build Enterprise Ready:\s*//p')"
installedver="$(printf %s\\n "$installed" | sed -n '1s/^.*:\s*//p')"
if test -z "$installedent" || test -z "$installedver" ; then
    echo Could not extract installed version info. >&2 ; exit 1
fi
if test "$deployver" != "$archiveurlver" && test "$deployver.0" != "$archiveurlver" ; then
    echo "Warning: Mismatch between latest deploy version '$deployver' and latest archive URL version '$archiveurlver'." >&2
fi
if test "$installedent" = false && test "$installedver" = "$archiveurlver" ; then
    echo Up to date. ; exit 0
fi
archive="$(basename "$archiveurl")"
echo =======
if ! (cd ~/dl && echo "SHA256 ($archive) = $archivesum" | sha256sum -c --strict >/dev/null 2>/dev/null) ; then
    (cd ~/dl && curl -fsSLO "$archiveurl" && echo DOWNLOADED: ~/dl/"$archive")
    if ! (cd ~/dl && echo "SHA256 ($archive) = $archivesum" | sha256sum -c --strict >/dev/null 2>/dev/null) ; then
        echo "Downloaded ~/dl/$archive from $archiveurl does not match SHA-256 $archivesum" >&2 ; exit 1
    fi
fi
echo LATEST: ~/dl/"$archive"
echo =======
