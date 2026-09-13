#!/usr/bin/env bash
# test-install-module-binding.sh — unit test for the installer's "did
# ua_apollo actually bind to the Apollo?" gate (scripts/install.sh).
#
# install.sh only runs main() when executed directly, so sourcing it here
# just loads the functions.  The helpers are exercised against a fake
# sysfs layout in a temp dir.

set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Give the sourced script an installer flag on "$@": sourcing must not
# parse it (an earlier sed-based sourcing ran the installer's arg loop,
# so `--help` produced a passing test with zero assertions).
set -- --skip-init
# shellcheck source=scripts/install.sh
source "$PROJECT_DIR/scripts/install.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/drivers/ua_apollo" "$tmp_dir/drivers/vfio-pci"
ln -s "$tmp_dir/drivers/ua_apollo" "$tmp_dir/bound"
ln -s "$tmp_dir/drivers/vfio-pci" "$tmp_dir/other"

failures=0
check() {
    local desc="$1"; shift
    if "$@"; then
        echo "PASS: $desc"
    else
        echo "FAIL: $desc"
        failures=$((failures + 1))
    fi
}
not() { ! "$@"; }

check "sourcing install.sh ignores positional args" \
    test "$SKIP_INIT" = "0"

check "missing driver link reports no driver" \
    test "$(apollo_bound_driver "$tmp_dir/unbound")" = ""
check "empty link path (lspci found nothing) reports no driver" \
    test "$(apollo_bound_driver "")" = ""
check "ua_apollo link reports ua_apollo" \
    test "$(apollo_bound_driver "$tmp_dir/bound")" = "ua_apollo"
check "other driver link reports that driver" \
    test "$(apollo_bound_driver "$tmp_dir/other")" = "vfio-pci"

check "apollo_driver_bound rejects missing link" \
    not apollo_driver_bound "$tmp_dir/unbound"
check "apollo_driver_bound rejects a device owned by another driver" \
    not apollo_driver_bound "$tmp_dir/other"
check "apollo_driver_bound accepts ua_apollo" \
    apollo_driver_bound "$tmp_dir/bound"

if [ "$failures" -ne 0 ]; then
    echo "$failures check(s) failed"
    exit 1
fi
echo "PASS: installer distinguishes bound, unbound and foreign-driver devices"
