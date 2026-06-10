#!/bin/bash
# Content-verification test (RED phase): spec1061 SC-1 - dependency-ordering solve contract
# Checks that the dependency-ordering solve contract generation pattern is NOT yet
# present in spec-creation/tasks/write.md (RED = should fail because GREEN hasn't added it)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../../.."

OVERALL_RESULT=0
WRITE_MD=".opencode/skills/spec-creation/tasks/write.md"

echo "SC-1: Dependency-ordering solve contract"

# The GREEN phase will add a solve contract generation step referencing
# dependency-ordering-verification. Check that this pattern does NOT exist yet.
if grep -q "dependency-ordering-verification" "$WRITE_MD" 2>/dev/null; then
    echo "  FAIL: dependency-ordering-verification already referenced in write.md (GREEN would be no-op)" >&2
    OVERALL_RESULT=1
else
    echo "  PASS: dependency-ordering-verification NOT yet in write.md (RED confirmed)"
fi

# Also check for the broader pattern of solve contract references in Step 5 area
if grep -q "solve.*contract\|contract.*solve" "$WRITE_MD" 2>/dev/null; then
    :
    # This may exist in other contexts; only flag exact pattern
fi

exit $OVERALL_RESULT