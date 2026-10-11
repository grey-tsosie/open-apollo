#!/usr/bin/env bash
# Exercise the macOS collector with command fixtures, never real hardware.
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir "$test_dir/bin"
cat > "$test_dir/bin/fixture" <<'FIXTURE'
#!/usr/bin/env bash
if [[ "${0##*/}" == "${TEST_FAILED_QUERY:-}" ]]; then
    echo "fixture ${0##*/} failure" >&2
    exit 1
fi
case "${0##*/}" in
    uname) echo "${TEST_PLATFORM:-Darwin}" ;;
    ioreg) [[ ${TEST_IOREG_FAIL:-0} == 0 ]] || { echo "fixture ioreg failure" >&2; exit 1; }; printf '"IOAudioEngineNumInputChannels" = 16\n"Universal Audio Apollo" = "test-device"\n' ;;
    csrutil) echo 'System Integrity Protection status: enabled.' ;;
    sw_vers) echo 'ProductVersion: fixture' ;;
    system_profiler) echo '{"fixture": "Apollo"}' ;;
    ls) echo "fixture installed kexts" ;;
    kextstat) echo 'com.uaudio.driver' ;;
    systemextensionsctl) echo 'fixture extension' ;;
    *) echo "unexpected command: $0" >&2; exit 1 ;;
esac
FIXTURE
chmod +x "$test_dir/bin/fixture"
for cmd in uname ioreg csrutil sw_vers system_profiler kextstat systemextensionsctl ls; do
    ln -s fixture "$test_dir/bin/$cmd"
done
PATH="$test_dir/bin:$PATH" bash "$PROJECT_DIR/tools/contribute/macos/capture-nosip.sh" \
    "$test_dir/capture with spaces" <<< '' > "$test_dir/output"
[[ -s "$test_dir/capture with spaces/audio.json" ]]
grep -q 'Universal Audio Apollo' "$test_dir/capture with spaces/highlight-ua-lines.txt"
grep -q '16' "$test_dir/capture with spaces/highlight-channels.txt"
tar tzf "$test_dir/capture with spaces.tar.gz" > "$test_dir/archive"
grep -q 'capture with spaces/ioreg-audioengine.txt' "$test_dir/archive"
grep -q 'Hardware and SIP were not changed' "$test_dir/output"
if TEST_PLATFORM=Linux PATH="$test_dir/bin:$PATH" bash \
    "$PROJECT_DIR/tools/contribute/macos/capture-nosip.sh" "$test_dir/rejected" \
    > "$test_dir/rejected-output" 2>&1; then
    echo 'FAIL: Linux execution accepted'; exit 1
fi
[[ ! -e "$test_dir/rejected" ]]
if TEST_IOREG_FAIL=1 PATH="$test_dir/bin:$PATH" bash \
    "$PROJECT_DIR/tools/contribute/macos/capture-nosip.sh" "$test_dir/incomplete" \
    <<< '' > "$test_dir/incomplete-output" 2>&1; then
    echo 'FAIL: failed identity capture reported success'; exit 1
fi
grep -q 'fixture ioreg failure' "$test_dir/incomplete/ioreg-full.txt"
grep -q 'Capture is incomplete' "$test_dir/incomplete-output"
for query in kextstat systemextensionsctl; do
    if TEST_FAILED_QUERY="$query" PATH="$test_dir/bin:$PATH" bash \
        "$PROJECT_DIR/tools/contribute/macos/capture-nosip.sh" "$test_dir/$query" \
        <<< '' > "$test_dir/$query-output" 2>&1; then
        echo "FAIL: failed $query reported success"; exit 1
    fi
    report=kextstat.txt
    [[ $query != systemextensionsctl ]] || report=systemextensions.txt
    grep -q "fixture $query failure" "$test_dir/$query/$report"
    grep -q 'Capture is incomplete' "$test_dir/$query-output"
done
echo 'PASS: no-SIP collector writes identity reports and archive; rejects non-macOS'
