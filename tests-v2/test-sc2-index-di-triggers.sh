#!/usr/bin/env bash
# RED test for SC-2 (#2243): `.opencode/guidelines/INDEX.md` SHALL be updated to
# include DI-related trigger patterns (`dependency injection`, `di`, `inject`,
# `container`) in the row for the guideline carrying the DI content.
#
# 2026-09-03 #2429 SC-8 consumer sweep: the DI content moved from
# `080-code-standards.md` to `082-python-standards.md` — the asserted row is
# re-pointed to the `082-python-standards.md` INDEX row.
#
# This test asserts the `082-python-standards.md` row in INDEX.md contains the DI
# trigger patterns. They are currently ABSENT (the INDEX.md update has not
# happened yet), so this test MUST FAIL (RED phase).
#
# SC-2 is structural evidence — a content-verification (grep) check is the
# appropriate evidence type per the spec's declared type.
#
# Usage: bash .opencode/tests-v2/test-sc2-index-di-triggers.sh
# Exit: 0 if the 082-python-standards.md row contains all DI trigger patterns, 1 otherwise.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

INDEX_FILE="$PROJECT_DIR/.opencode/guidelines/INDEX.md"

# SC-2: The `082-python-standards.md` row must contain the DI-related trigger
# patterns (dependency injection, di, inject, container). The row is the INDEX.md
# line whose first cell references `082-python-standards.md`.
ROW=$(grep -E '^\| `082-python-standards\.md` \|' "$INDEX_FILE" | head -n1 || true)

PASS_COUNT=0
FAIL_COUNT=0

echo ""
echo "=== SC-2 (#2243): INDEX.md 082-python-standards.md row contains DI trigger patterns ==="
echo ""

if [ -z "$ROW" ]; then
    echo "  FAIL: no 082-python-standards.md row found in INDEX.md"
    FAIL_COUNT=$((FAIL_COUNT + 1))
else
    echo "  Row: $ROW"
    for pattern in "dependency injection" "di" "inject" "container"; do
        # SC-2: trigger pattern present in the 082-python-standards.md row.
        if echo "$ROW" | grep -qi "$pattern"; then
            echo "  PASS: row contains \"$pattern\""
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo "  FAIL: row does NOT contain \"$pattern\""
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    done
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: DI trigger patterns not yet present in the 082-python-standards.md row."
    echo ""
    exit 1
fi
exit 0
