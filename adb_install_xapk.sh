#!/usr/bin/env bash
set -euo pipefail

# German for German message locales; English for all others.
locale_messages=${LC_ALL:-${LC_MESSAGES:-${LANG:-C}}}
msg() {
    case "$locale_messages" in
        de|de_*|de.*|de@*|de-*) printf '%s' "$1" ;;
        *) printf '%s' "$2" ;;
    esac
}

if [[ $# -ne 1 ]]; then
    printf '%s: %s <%s.xapk>\n' "$(msg 'Verwendung' 'Usage')" "${0##*/}" "$(msg 'Datei' 'file')" >&2
    exit 1
fi

xapk=$1
if [[ ! -f "$xapk" || ${xapk,,} != *.xapk ]]; then
    printf '%s: %s\n' "$(msg 'Fehler: Keine gültige XAPK-Datei' 'Error: Not a valid XAPK file')" "$xapk" >&2
    exit 1
fi
xapk=$(realpath -- "$xapk")

for cmd in adb 7z; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf '%s\n' "$(msg "Fehler: $cmd ist nicht installiert." "Error: $cmd is not installed.")" >&2
        exit 1
    fi
done

tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT

printf '=== %s ===\n' "$(msg 'XAPK installieren' 'Install XAPK')"
printf '%s: %s\n\n' "$(msg 'Archiv' 'Archive')" "$xapk"

printf '[1/3] %s:\n' "$(msg 'Archivinhalt' 'Archive contents')"
7z l "$xapk"

printf '[2/3] %s:\n' "$(msg 'Archiv entpacken' 'Extracting archive')"
7z x -y "-o$tmp" "$xapk"

mapfile -d '' -t apks < <(find "$tmp" -type f -iname '*.apk' -print0 | sort -z)
if (( ${#apks[@]} == 0 )); then
    printf '%s\n' "$(msg 'Fehler: Keine APK-Dateien im Archiv gefunden.' 'Error: No APK files found in the archive.')" >&2
    exit 1
fi

printf '\n%s (%d):\n' "$(msg 'Gefundene APK-Dateien' 'APK files found')" "${#apks[@]}"
for apk in "${apks[@]}"; do
    printf '  %-55s %12s %s\n' "${apk#"$tmp/"}" "$(stat -c %s -- "$apk")" "$(msg 'Bytes' 'bytes')"
done

if [[ -n $(find "$tmp" -type f -iname '*.obb' -print -quit) ]]; then
    printf '%s\n' "$(msg 'Warnung: Das Archiv enthält OBB-Dateien. Diese werden nicht installiert.' 'Warning: The archive contains OBB files. They will not be installed.')" >&2
fi

printf '\n[3/3] %s:\n' "$(msg 'Installation über ADB' 'Installing via ADB')"
if (( ${#apks[@]} == 1 )); then
    adb install -r "${apks[0]}"
else
    adb install-multiple -r "${apks[@]}"
fi

printf '\n%s\n' "$(msg 'APK-Installation erfolgreich. Temporäre Dateien werden entfernt.' 'APK installation successful. Removing temporary files.')"
