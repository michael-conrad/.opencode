#!/bin/bash
# Content-verification test (RED phase): spec1061 SC-2 - solve utility invoked during spec-creation
# Checks that the `solve` utility invocation pattern after Step 5.5 is NOT yet
# present in spec-creation/tasks/write.md (RED = should fail because GREEN hasn't added it)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../../.."

OVERALL_RESULT=0
WRITE_MD=".opencode/skills/spec-creation/tasks/write.md"

echo "SC-2: solve utility invoked during spec-creation"

# The GREEN phase will add solve utility invocation after Step 5.5 that produces
# ./tmp/{issue-N}/artifacts/constraints-contract.yaml. Check this pattern is ABSENT.
if grep -q "solve.*check\|solve.*state\|constraints-contract" "$WRITE_MD" 2>/dev/null; then
    echo "  FAIL: solve utility invocation pattern already found in write.md (GREEN would be no-op)" >&2
    OVERALL_RESULT=1
else
    echo "  PASS: solve invocation pattern NOT yet in write.md (RED confirmed)"
fi

# Also check that the broader constraints-contract path is not referenced
if grep -q "tmp/.*\{issue-N\}.*/artifacts/constraints" "$WRITE_MD" 2>/dev/null; then
    echo "  FAIL: constraints-contract path already referenced in write.md" >&2
    OVERALL_RESULT=1
fi

exit $OVERALL_RESULT