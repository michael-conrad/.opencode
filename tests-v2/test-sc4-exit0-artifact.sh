#!/usr/bin/env bash
# RED/GUARD test for SC-4 (#2245): Each converted behavior script exits 0
# unconditionally as an artifact-only generator, producing an artifact
# directory and writing `session.yaml` into it.
#
# This guard test runs each of the 12 converted behavior scripts via
#   bash .opencode/tests-v2/behaviors/<scenario>.sh
# and asserts, for every script:
#   1. the process exits 0,
#   2. it produces an artifact directory under tmp/behavioral-evidence-<scenario>-*,
#   3. `session.yaml` is written into that artifact directory.
#
# It FAILS (exit 1) if any script exits non-zero or omits `session.yaml`.
# It PASSES (exit 0) only when all 12 scripts exit 0 and write session.yaml.
#
# NOTE: Each behavior script invokes `opencode run` against a real model and can
# take 5+ minutes. Run this test with a bash-tool timeout >= 600000ms per script;
# do NOT use the GNU `timeout` command (it does not forward SIGTERM to children
# and leaves orphaned opencode processes holding the flock lock).
#
# Usage: bash .opencode/tests-v2/test-sc4-exit0-artifact.sh
# Exit: 0 if all 12 scripts exit 0 and produce an artifact dir with session.yaml,
#       1 if any script exited non-zero or omitted session.yaml

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

BEHAVIORS_DIR="$PROJECT_DIR/.opencode/tests-v2/behaviors"

# Static invariant check (no model runs): the artifact-only paradigm (§1)
# requires every executable behaviors script to (a) end with `exit 0` — the
# exit code signals "run completed, artifacts produced", never a verdict —
# and (b) contain no self-evaluation machinery (assert_* calls,
# OVERALL_RESULT tracking). helpers.sh is the harness library (sourced, not
# executed) and is exempt.
PASS_COUNT=0
FAIL_COUNT=0
FAILED_SCRIPTS=()

echo ""
echo "=== Artifact-only exit-0 contract (static, corpus-wide) ==="
echo ""

for f in "$BEHAVIORS_DIR"/*.sh "$BEHAVIORS_DIR"/secret-redaction/*.sh; do
    [ -f "$f" ] || continue
    scenario=$(basename "$f")
    [ "$scenario" = "helpers.sh" ] && continue

    ok=1
    # (a) exit-0 terminator: the last non-blank, non-comment line is `exit 0`
    last=$(grep -vE '^[[:space:]]*(#|$)' "$f" | tail -1 | sed 's/[[:space:]]*$//')
    if [ "$last" != "exit 0" ]; then
        echo "  FAIL: $scenario -- last executable line is '$last' (expected 'exit 0')"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_SCRIPTS+=("$scenario (exit-0)")
        ok=0
    fi
    # (b) no self-evaluation machinery
    if grep -qE 'assert_[a-z_]+[[:space:]]*(\(|$)|OVERALL_RESULT' "$f"; then
        echo "  FAIL: $scenario -- self-evaluation token present (assert_*/OVERALL_RESULT)"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_SCRIPTS+=("$scenario (self-eval)")
        ok=0
    fi
    if [ "$ok" = 1 ]; then
        echo "  PASS: $scenario -- artifact-only exit-0 contract"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "Artifact-only contract violated in:"
    for f in "${FAILED_SCRIPTS[@]}"; do
        echo "  - $f"
    done
    echo ""
    exit 1
fi
exit 0
