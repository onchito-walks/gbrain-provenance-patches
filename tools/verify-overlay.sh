#!/usr/bin/env bash
# Run the declared acceptance suites against an overlay checkout and print an
# explicit planned/executed/passed accounting line.
#
#   tools/verify-overlay.sh <gbrain-clone>
#
# A run that plans zero suites is a FAILURE, not a pass.
set -uo pipefail

REPO=${1:?usage: verify-overlay.sh <gbrain-clone>}
cd "$REPO"

if ! command -v bun >/dev/null 2>&1; then
    echo "bun not found on PATH — upstream >= v0.60.178.0 requires bun >= 1.4.0" >&2
    exit 1
fi

BUN_VER=$(bun --version)
echo "== bun $BUN_VER"
case "$BUN_VER" in
    0.*|1.[0-3].*) echo "bun $BUN_VER is too old; the overlay needs >= 1.4.0" >&2; exit 1 ;;
esac

# Declared acceptance suites. Keep this list in sync with the overlay registry;
# it is intentionally narrow — the changed surface, not the whole corpus.
SUITES=(
    "test/multi-source-drift.test.ts"
    "test/multi-source-drift-coverage.test.ts"
)

echo "== building"
if ! bun run build; then
    echo "ACCEPTANCE: build failed" >&2
    exit 1
fi

planned=${#SUITES[@]}
executed=0
passed=0
failed_ids=()

for s in "${SUITES[@]}"; do
    if [ ! -e "$s" ]; then
        echo "!! declared suite missing: $s" >&2
        failed_ids+=("$s(missing)")
        continue
    fi
    echo "== suite $s"
    executed=$((executed + 1))
    if bun test "$s"; then
        passed=$((passed + 1))
    else
        failed_ids+=("$s")
    fi
done

echo
echo "ACCEPTANCE {\"planned\":$planned,\"executed\":$executed,\"passed\":$passed}"

if [ "$planned" -eq 0 ]; then
    echo "ACCEPTANCE: planned zero suites — FAILURE, not a pass" >&2
    exit 1
fi

if [ "${#failed_ids[@]}" -gt 0 ]; then
    echo "ACCEPTANCE: failed suites: ${failed_ids[*]}" >&2
    exit 1
fi

if [ "$passed" -ne "$planned" ]; then
    echo "ACCEPTANCE: $passed of $planned planned suites passed" >&2
    exit 1
fi

echo "ACCEPTANCE: all $planned declared suite(s) passed"
