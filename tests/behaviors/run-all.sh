#!/bin/bash
# Run all behavioral enforcement tests with exit code tracking.
# Reports PASS (0), FAIL (1), and INCONCLUSIVE (2) separately.
#
# Usage:
#   bash .opencode/tests/behaviors/run-all.sh [--list]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

LIST_ONLY=false
if [ "${1:-}" = "--list" ]; then
    LIST_ONLY=true
fi

RESULTS_DIR="${BEHAVIOR_LOG_DIR:-$PROJECT_DIR/tmp/behavior-runall-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$RESULTS_DIR"

PASS_COUNT=0
FAIL_COUNT=0
INCONCLUSIVE_COUNT=0
declare -a FAILED_NAMES
declare -a INCONCLUSIVE_NAMES

for script in "$SCRIPT_DIR"/*.sh; do
    name="$(basename "$script")"
    [ "$name" = "helpers.sh" ] && continue
    [ "$name" = "run-all.sh" ] && continue
    [ "$name" = "template.sh" ] && continue

    if $LIST_ONLY; then
        echo "$name"
        continue
    fi

    echo ""
    echo "=== $name ==="

    set +e
    bash "$script" > "$RESULTS_DIR/$name.stdout" 2> "$RESULTS_DIR/$name.stderr"
    exit_code=$?
    set -e

    if [ "$exit_code" -eq 0 ]; then
        echo "  RESULT: PASS"
        PASS_COUNT=$((PASS_COUNT + 1))
    elif [ "$exit_code" -eq 2 ]; then
        echo "  RESULT: INCONCLUSIVE"
        INCONCLUSIVE_COUNT=$((INCONCLUSIVE_COUNT + 1))
        INCONCLUSIVE_NAMES+=("$name")
    else
        echo "  RESULT: FAIL (exit $exit_code)"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_NAMES+=("$name")
    fi
done

if $LIST_ONLY; then
    exit 0
fi

echo ""
echo "========================================="
echo "  Behavioral Test Results Summary"
echo "========================================="
echo "  PASS:         $PASS_COUNT"
echo "  FAIL:         $FAIL_COUNT"
echo "  INCONCLUSIVE: $INCONCLUSIVE_COUNT"
echo "  TOTAL:        $((PASS_COUNT + FAIL_COUNT + INCONCLUSIVE_COUNT))"
echo "========================================="

if [ "${#FAILED_NAMES[@]}" -gt 0 ]; then
    echo ""
    echo "FAILED tests:"
    for name in "${FAILED_NAMES[@]}"; do
        echo "  - $name"
    done
fi

if [ "${#INCONCLUSIVE_NAMES[@]}" -gt 0 ]; then
    echo ""
    echo "INCONCLUSIVE tests (model dispatch failed):"
    for name in "${INCONCLUSIVE_NAMES[@]}"; do
        echo "  - $name"
    done
fi

# Exit codes: 0 = all pass, 1 = any fail, 2 = inconclusive only
if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
if [ "$INCONCLUSIVE_COUNT" -gt 0 ] && [ "$FAIL_COUNT" -eq 0 ]; then
    exit 2
fi
exit 0
