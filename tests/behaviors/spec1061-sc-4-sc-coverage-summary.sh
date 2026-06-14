#!/bin/bash
# Content-verification test (RED phase): spec1061 SC-4 - SC coverage summary YAML generated
# Checks that the SC coverage summary YAML file at artifacts/sc-summary.yaml does
# NOT exist (RED = should fail because GREEN hasn't generated it)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../../.."

OVERALL_RESULT=0
echo "SC-4: SC coverage summary YAML generated"

# SC-4 requires sc-summary.yaml at .issues/{issue-N}/sc-summary.yaml
# Check the artifact does NOT exist yet (RED phase)
ARTIFACT=".opencode/.issues/1061/sc-summary.yaml"
if [ -f "$ARTIFACT" ]; then
    echo "  FAIL: $ARTIFACT already exists (GREEN would be no-op)" >&2
    OVERALL_RESULT=1
else
    echo "  PASS: $ARTIFACT does NOT exist (RED confirmed)"
fi

# Also check the generation pattern is not yet in write.md
WRITE_MD=".opencode/skills/spec-creation/tasks/write.md"
if grep -q "sc-summary\|sc_coverage\|SC coverage summary" "$WRITE_MD" 2>/dev/null; then
    echo "  FAIL: SC coverage YAML generation pattern already in write.md" >&2
    OVERALL_RESULT=1
fi

exit $OVERALL_RESULT