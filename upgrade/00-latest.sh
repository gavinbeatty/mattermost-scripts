#!/bin/sh
cd /
echo Running:
# fmt.Sprintf("  Server version %v.%v.%v.%v", model.CurrentVersion, model.BuildNumber, c.App.ClientConfigHash(), c.App.Srv().License() != nil)
running="$(sudo -u mattermost /opt/mattermost/bin/mmctl --local --strict system version 2>/dev/null | sed -n 's/^[A-Z]/  &/p')"
runningvers="$(printf %s\\n "$running" | sed -e 's/^\s*Server version \(.*\)\.[a-f0-9]\{32\}\..*/\1/')"
runningdots="$(printf %s\\n "$runningvers" | tr -d 'a-zA-Z0-9\n' | wc -c)"
runningver="$(printf %s\\n "$runningvers" | awk -F. "{print $(seq 1 $((runningdots/2)) | xargs -rd\\n printf '$%d "." ') \$$((runningdots/2 + 1))}")"
if test -z "$runningver" ; then
    echo "Could not extract running version info from '$running'." >&2 ; exit 1
fi
printf "  Running version: %s\\n" "$runningver"
runningent="$(printf %s\\n "$running" | sed -e 's/^.*\.[a-f0-9]\{32\}\.\(true\|false\)$/\1/')"
case "$runningent" in
    true|false) true ;;
    *) echo "Could not extract running enterprise info from '$running'." >&2 ; exit 1 ;;
esac
printf "  Running enterprise: %s\\n" "$runningent"
echo Latest:
deployhtml="$(curl -fsSL https://mattermost.com/deploy/)"
deployver="$(printf %s\\n "$deployhtml" | sed -n 's/^\s*\(<[^<]*class="release-text-left-latest"\)/  \1/p' | sed -e 's/.*>\s*\(.*\)\s*<.*/\1/')"
printf "  Deploy version: %s\\n" "$deployver"
runningvermajor="${runningver%%.*}"
deploydate="$(printf %s\\n "$deployhtml" | sed -n 's/^\s*\(<[^<]*class="release-text-left-date"\)/  \1/p' | sed -e 's/.*>\s*\(.*\)\s*<.*/\1/')"
printf "  Deploy date: %s\\n" "$deploydate"
vahtml="$(curl -fsSL https://docs.mattermost.com/upgrade/version-archive.html)"
vahtmlsubset="$(printf %s\\n "$vahtml" | grep '<code\b.*\bhttps://releases\.mattermost\.com/[^d/][^/]*/mattermost-team-'"$runningvermajor" -A1)"
archiveurl="$(printf %s\\n "$vahtmlsubset" | sed -n '1s#.*\b\(https://releases\.mattermost\.com/[^d/][^/]*/mattermost-team-[^"<>]*linux-amd64\.\(tar\.\|t\)\(gz\|bz2\|xz\|zst\)\).*#\1#p')"
archiveurlver="$(printf %s\\n "$archiveurl" | sed -e 's#.*\bhttps://releases\.mattermost\.com/\([^d/][^/]*\).*#\1#')"
archivesum="$(printf %s\\n "$vahtmlsubset" | sed -En '2s#.*[^0-9a-fA-F]([0-9a-fA-F]{64})[^0-9a-fA-F].*#\1#p')"
majorupgradevahtmlsubset="$(printf %s\\n "$vahtml" | grep '<code\b.*\bhttps://releases\.mattermost\.com/[^d/][^/]*/mattermost-team-' -A1)"
majorupgradearchiveurl="$(printf %s\\n "$majorupgradevahtmlsubset" | sed -n '1s#.*\b\(https://releases\.mattermost\.com/[^d/][^/]*/mattermost-team-[^"<>]*linux-amd64\.\(tar\.\|t\)\(gz\|bz2\|xz\|zst\)\).*#\1#p')"
if test "$majorupgradearchiveurl" != "$archiveurl" ; then
    majorupgradearchiveurlver="$(printf %s\\n "$majorupgradearchiveurl" | sed -e 's#.*\bhttps://releases\.mattermost\.com/\([^d/][^/]*\).*#\1#')"
    majorupgradearchivesum="$(printf %s\\n "$majorupgradevahtmlsubset" | sed -En '2s#.*[^0-9a-fA-F]([0-9a-fA-F]{64})[^0-9a-fA-F].*#\1#p')"
    if test "${1:-}" = major ; then
        archiveurl="$majorupgradearchiveurl"
        archiveurlver="$majorupgradearchiveurlver"
        archivesum="$majorupgradearchivesum"
        printf "  Archive URL: %s\\n" "$archiveurl"
        printf "  Archive URL version: %s\\n" "$archiveurlver"
        printf "  Archive SHA-256: %s\\n" "$archivesum"
    else
        printf "  Archive URL: %s\\n" "$archiveurl"
        printf "  Archive URL version: %s\\n" "$archiveurlver"
        printf "  Archive SHA-256: %s\\n" "$archivesum"
        printf "  Major Upgrade Archive URL: %s\\n" "$majorupgradearchiveurl"
        printf "  Major Upgrade Archive URL version: %s\\n" "$majorupgradearchiveurlver"
        printf "  Major Upgrade Archive SHA-256: %s\\n" "$majorupgradearchivesum"
    fi
else
    printf "  Archive URL: %s\\n" "$archiveurl"
    printf "  Archive URL version: %s\\n" "$archiveurlver"
    printf "  Archive SHA-256: %s\\n" "$archivesum"
fi
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


if test "$deployver" != "$archiveurlver" && test "$deployver.0" != "$archiveurlver" ; then
    echo "Warning: Mismatch between latest deploy version '$deployver' and latest archive URL version '$archiveurlver'." >&2
fi
if test "$runningent" = false && test "$runningver" = "$archiveurlver" ; then
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
