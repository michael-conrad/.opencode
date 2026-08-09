#!/bin/bash
# Structural test: 2257-sc4-capability-split
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-4 (structural): The correct issue-level vs repo-level capability split is
# synthesized from the SC-2 + SC-3 empirical results. Verification: the derived
# split (which label operations work at issue level, which only at repo level)
# is recorded as a structural artifact from the verified empirical outcomes.
#
# RED state: The capability-split artifact does not exist yet — the split has not
# been recorded. This assertion FAILS until the artifact is created (GREEN).
#
# Verified empirical results (from SC-2 + SC-3):
#   SC-2: issue-level label mutation WORKING (POST/PUT/DELETE apply labels with readback)
#   SC-3: repo-level label CRUD WORKING
# Derived split: BOTH issue-level label mutation AND repo-level label CRUD are WORKING.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ARTIFACT="$SCRIPT_DIR/2257-capability-split.yaml"

FAILURES=0

if [ ! -f "$ARTIFACT" ]; then
    echo "FAIL: capability-split artifact missing: $ARTIFACT" >&2
    FAILURES=$((FAILURES + 1))
else
    # SC-4: issue-level label mutation recorded as WORKING (from SC-2)
    if ! grep -q "issue_level_label_mutation: WORKING" "$ARTIFACT"; then
        echo "FAIL: issue-level label mutation not recorded as WORKING" >&2
        FAILURES=$((FAILURES + 1))
    fi
    # SC-4: repo-level label CRUD recorded as WORKING (from SC-3)
    if ! grep -q "repo_level_label_crud: WORKING" "$ARTIFACT"; then
        echo "FAIL: repo-level label CRUD not recorded as WORKING" >&2
        FAILURES=$((FAILURES + 1))
    fi
fi

if [ "$FAILURES" -gt 0 ]; then
    echo "RED: SC-4 capability-split assertion FAILED ($FAILURES failures)" >&2
    exit 1
fi

echo "PASS: SC-4 capability-split artifact records the verified split" >&2
exit 0
