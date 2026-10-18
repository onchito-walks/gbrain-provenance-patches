#!/usr/bin/env bash
# Apply the gbrain-guardrails patch series onto a clean upstream clone.
#
#   tools/apply-overlay.sh <gbrain-clone> [patches-dir] [base-ref]
#
# Fails loudly on the first conflict instead of leaving a half-applied tree.
set -euo pipefail

REPO=${1:?usage: apply-overlay.sh <gbrain-clone> [patches-dir] [base-ref]}
PATCHES=${2:-"$(cd "$(dirname "$0")/.." && pwd)/patches"}
BASE=${3:-v0.60.178.0}

[ -d "$REPO/.git" ] || { echo "not a git clone: $REPO" >&2; exit 1; }
[ -d "$PATCHES" ]   || { echo "no patches directory: $PATCHES" >&2; exit 1; }

cd "$REPO"

if [ -n "$(git status --porcelain)" ]; then
    echo "working tree is dirty; commit or stash first" >&2
    exit 1
fi

echo "== fetching and checking out $BASE"
git fetch --tags origin
git checkout --detach "$BASE"
git reset --hard "$BASE"

count=$(ls -1 "$PATCHES"/*.patch | wc -l)
echo "== applying $count patch(es) from $PATCHES"
git am --3way --keep-cr "$PATCHES"/*.patch

echo
echo "== applied; resulting head:"
git log --oneline -1
echo
echo "Next: install Bun >= 1.4.0, then 'bun install && bun run build'."
echo "Then run tools/verify-overlay.sh to execute the declared acceptance suites."
