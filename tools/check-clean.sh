#!/usr/bin/env bash
# Prove the published tree carries no credentials or machine-specific paths.
#
#   tools/check-clean.sh [tree]
#
# Exits non-zero and prints every offending line. Run this before publishing any
# change to this repository.
set -uo pipefail

TREE=${1:-"$(cd "$(dirname "$0")/.." && pwd)"}
cd "$TREE"

fail=0

scan() {
    local label=$1 pattern=$2
    local hits
    hits=$(grep -rInE --exclude-dir=.git "$pattern" . 2>/dev/null || true)
    if [ -n "$hits" ]; then
        echo "FAIL [$label]"
        printf '%s\n' "$hits" | head -20
        fail=1
    else
        echo "ok   [$label]"
    fi
}

# Absolute host paths — a published tree must not name anyone's machine.
scan "absolute home paths" '/home/[a-z][a-z0-9_-]+/|/Users/[A-Za-z][A-Za-z0-9_-]*/'
scan "absolute srv/mnt paths" '/(srv|mnt|opt)/(minio|data|storage)/'
# Mesh-VPN ranges this overlay's authors used. Narrow on purpose, so upstream
# documentation IPs (100.101.102.103 and friends) do not trip it.
scan "private vpn ipv4" '\b(10\.250\.[0-9]{1,3}\.[0-9]{1,3}|100\.(97|113)\.[0-9]{1,3}\.[0-9]{1,3})\b'
# Credential shapes: long and unbroken, so upstream's masked fixtures do not trip it.
scan "api keys" '(^|[^A-Za-z0-9_-])sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}|gho_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}'
scan "private keys" 'BEGIN (RSA|OPENSSH|EC|PGP) PRIVATE KEY'
scan "bearer literals" 'Bearer [A-Za-z0-9._-]{24,}'
# Personal names / handles that should have been genericised. Assembled from
# fragments so this scanner does not match its own source.
NAMES="ray""mond|ram""on|del""gado|onch""ito"
REPOS="hermes-""moncho|gbrain-""operations|hermes-""native"
scan "personal names" "\b($NAMES)\b"
scan "private repo names" "$REPOS"

echo
if [ "$fail" -eq 0 ]; then
    echo "CLEAN: no credentials, host paths or personal identifiers found"
else
    echo "DIRTY: fix the findings above before publishing" >&2
fi
exit "$fail"
