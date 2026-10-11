#!/usr/bin/env bash
#
# capture-nosip.sh — Apollo device data capture on macOS without changing SIP.
#
# Run this FIRST, before considering DTrace. It needs no SIP change, no kernel
# tracing, and makes no network calls. Everything here is standard macOS
# introspection of data the OS already publishes about the connected device.
#
# Collects IORegistry and CoreAudio identity/channel data for any Thunderbolt
# Apollo model. Routing tables and DSP payloads require capture.sh and
# apollo-selectors.d; this collector cannot establish them.
#
# No hardware or system changes, installs, or uploads. Output is local and must
# be reviewed before sharing because it can include hardware identifiers.
#
# Usage:  ./capture-nosip.sh [outdir]
#
set -uo pipefail

OUT="${1:-./apollo-capture-$(date +%Y%m%d-%H%M%S)}"

grn() { printf '\033[32m%s\033[0m\n' "$*"; }
ylw() { printf '\033[33m%s\033[0m\n' "$*"; }
hdr() { printf '\n\033[1m== %s ==\033[0m\n' "$*"; }

if [[ "$(uname -s)" != "Darwin" ]]; then
    printf '\033[31mThis script is for macOS. Run it on the Mac with the Apollo attached.\033[0m\n'
    exit 1
fi

mkdir -p "$OUT" || exit 1
hdr "Apollo device capture (no SIP changes required)"
echo "output: $OUT"
echo
echo "Before continuing, make sure:"
echo "  - the Apollo is connected via Thunderbolt and powered on"
echo "  - UA Console (or UA Connect) is running and shows the device"
echo "  - audio is playing through it, so the engine is active"
echo
read -rp "Press Enter to capture, Ctrl+C to cancel..."

FAILED=0
run() {  # run <outfile> <description> <cmd...>
    local f="$OUT/$1"; local desc="$2"; shift 2
    printf '  %-42s' "$desc"
    if "$@" >"$f" 2>&1; then
        if [[ -s "$f" ]]; then grn "ok ($(wc -l <"$f" | tr -d ' ') lines)"; else ylw "empty"; fi
    else
        ylw "failed (kept stderr)"
        FAILED=1
    fi
}

hdr "System"
run system-version.txt      "macOS version"            sw_vers
run uname.txt               "kernel / arch"            uname -a
run sip-status.txt          "SIP status (informational)" csrutil status

hdr "Thunderbolt topology"
# Gives vendor/device IDs, link speed, and the device tree as macOS sees it.
run thunderbolt.json        "SPThunderboltDataType (json)"  system_profiler -json SPThunderboltDataType
run thunderbolt.txt         "SPThunderboltDataType (text)"  system_profiler SPThunderboltDataType

hdr "Audio device inventory"
# SPAudioDataType reports per-device input/output channel counts as CoreAudio
# sees them. This is the headline number for gap 2.
run audio.json              "SPAudioDataType (json)"    system_profiler -json SPAudioDataType
run audio.txt               "SPAudioDataType (text)"    system_profiler SPAudioDataType

hdr "IORegistry — the authoritative channel counts"
# The x4's 24/22 came from IOAudioEngine properties. Dump broadly: UA's engine
# class naming varies by driver version, so capture several angles rather than
# guessing one class name.
run ioreg-full.txt          "full ioreg tree (-l -w0)"        ioreg -l -w0
run ioreg-audioengine.txt   "IOAudioEngine subtree"           ioreg -l -w0 -r -c IOAudioEngine
run ioreg-audiodevice.txt   "IOAudioDevice subtree"           ioreg -l -w0 -r -c IOAudioDevice

# Targeted greps over the full dump — cheap, and makes the useful lines obvious
# without needing to open a 100k-line file.
hdr "Extracted highlights"
if [[ -s "$OUT/ioreg-full.txt" ]]; then
    grep -iE "UAD|Universal Audio|Apollo|Twin" "$OUT/ioreg-full.txt" \
        > "$OUT/highlight-ua-lines.txt" 2>/dev/null || true
    grep -iE "Number of (Input|Output) Channels|IOAudio.*Channel|SampleRate|ChannelCount|NumChannels" \
        "$OUT/ioreg-full.txt" > "$OUT/highlight-channels.txt" 2>/dev/null || true
    printf '  %-42s' "UA/Apollo lines"
    grn "$(wc -l <"$OUT/highlight-ua-lines.txt" 2>/dev/null | tr -d ' ') lines"
    printf '  %-42s' "channel-count lines"
    grn "$(wc -l <"$OUT/highlight-channels.txt" 2>/dev/null | tr -d ' ') lines"
fi

hdr "UA driver presence"
run kextstat.txt            "loaded kexts"              kextstat
run kexts-installed.txt     "installed kexts"           ls -la /Library/Extensions /System/Library/Extensions
run systemextensions.txt   "system extensions"         systemextensionsctl list

hdr "Packaging"
TARBALL="$OUT.tar.gz"
tar czf "$TARBALL" -C "$(dirname "$OUT")" "$(basename "$OUT")" 2>/dev/null \
    && grn "archive: $TARBALL" || { ylw "tar failed; the directory is still there"; FAILED=1; }

cat <<EOF

$(hdr "Done")
Captured to: $OUT
Archive:     $TARBALL

Files were written only to the output directory and archive.
Nothing was uploaded. Hardware and SIP were not changed.

REVIEW BEFORE SHARING. ioreg-full.txt is a whole-system dump and can include
device serial numbers and, depending on what is attached, other hardware
identifiers. The two highlight-*.txt files plus thunderbolt.json and audio.json
are usually all that is actually needed.

Most useful files to look at first:
  highlight-channels.txt   <- the channel counts (gap 2)
  highlight-ua-lines.txt   <- device identification
  thunderbolt.json         <- vendor/device IDs, link speed
  audio.json               <- CoreAudio's view of in/out channel counts

EOF

if [[ $FAILED -ne 0 ]]; then
    ylw "Capture is incomplete; inspect the retained command errors before sharing."
    exit 1
fi
