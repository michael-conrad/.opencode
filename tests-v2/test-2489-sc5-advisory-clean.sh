#!/usr/bin/env bash
# Issue #2489 SC-5 RED: advisory text must contain no stale-pointer-gate or
# SKIP-hatch wording. PASS requires ZERO matches; any match fails the test.
# Currently matches exist -> this test FAILS (RED for the clean-advisory state).

set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FILE="$ROOT/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md"
OUT="${1:-$ROOT/../tmp/2489/artifacts/step26-red-test-output.log}"

if [ ! -f "$FILE" ]; then
  echo "FAIL: advisory file not found: $FILE"
  exit 2
fi

PATTERN='stale.pointer|SKIP_STALE_POINTER_CHECK|Gate 2|override hatch|skip hatch'

mkdir -p "$(dirname "$OUT")"
matches=$(grep -n -i -E "$PATTERN" "$FILE" | tee "$OUT")
rc=$?

if [ "$rc" -eq 1 ] || [ -z "$matches" ]; then
  echo "PASS: no stale-pointer-gate / SKIP-hatch wording in advisory"
  exit 0
fi

echo "FAIL (RED expected): stale-pointer-gate / SKIP-hatch wording still present:"
echo "$matches"
exit 1
