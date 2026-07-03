#!/bin/bash
# Content-verification test (RED phase): spec1061 SC-8 - verification consistency contract
# Checks that the verification consistency contract does NOT exist yet and the
# generation pattern is NOT present in files (RED = should fail because GREEN
# hasn't added it)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../../.."

OVERALL_RESULT=0
echo "SC-8: Verification consistency contract created"

# SC-8 requires verification-consistency-contract.yaml at 
ARTIFACT=".opencode/.issues/1061/verification-consistency-contract.yaml"
if [ -f "$ARTIFACT" ]; then
    echo "  FAIL: $ARTIFACT already exists (GREEN would be no-op)" >&2
    OVERALL_RESULT=1
else
    echo "  PASS: $ARTIFACT does NOT exist (RED confirmed)"
fi

# Check verification consistency pattern is not in write.md
WRITE_MD=".opencode/skills/spec-creation/tasks/write.md"
if grep -q "verification-consistency-contract\|verification.consistency.*contract" "$WRITE_MD" 2>/dev/null; then
    echo "  FAIL: verification consistency contract pattern already in write.md" >&2
    OVERALL_RESULT=1
fi

# Check it's not in approval-gate SKILL.md either (pre-approval gate validation)
APPROVAL_MD=".opencode/skills/approval-gate/SKILL.md"
if grep -q "verification-consistency-contract\|verification.consistency.*contract" "$APPROVAL_MD" 2>/dev/null; then
    echo "  FAIL: verification consistency contract pattern already in approval-gate SKILL.md" >&2
    OVERALL_RESULT=1
fi

exit $OVERALL_RESULT