#!/bin/bash
# RED phase: content-verification test for issue #1602
# Verifies that `type: domain` and `type: tool` still exist in SKILL.md files
# (plan and solve have invalid types that must be removed in GREEN phase)
# This test MUST FAIL now (RED) and PASS after GREEN implementation
set -euo pipefail

OVERALL_RESULT=0
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "=== RED Phase: Frontmatter Type Validation ==="
echo "Verifying invalid type values exist (expecting FAIL — RED)"
echo ""

# SC-3: type: domain or type: tool matches exist in SKILL.md files
echo "--- SC-3: Invalid type values exist in SKILL.md files ---"
MATCHES=$(grep -n 'type: domain\|type: tool' "$PROJECT_DIR"/.opencode/skills/*/SKILL.md "$PROJECT_DIR"/.opencode/skills/issue-operations/platforms/*/SKILL.md 2>/dev/null || echo "NOT_FOUND")

if [ "$MATCHES" = "NOT_FOUND" ]; then
    echo "  FAIL: No invalid type values found (expected RED — should exist)"
    echo "  RESULT: PASS (unexpected — invalid types already removed)"
else
    echo "  FOUND invalid type values:"
    echo "$MATCHES" | while IFS= read -r line; do echo "    $line"; done
    echo "  RESULT: FAIL (expected RED — invalid types still present)"
    OVERALL_RESULT=1
fi

# SC-6: plan/SKILL.md has type: domain (invalid)
echo ""
echo "--- SC-6: plan/SKILL.md has type: domain (invalid) ---"
PLAN_TYPE=$(grep -n 'type: domain' "$PROJECT_DIR/.opencode/skills/plan/SKILL.md" 2>/dev/null || echo "NOT_FOUND")

if [ "$PLAN_TYPE" = "NOT_FOUND" ]; then
    echo "  NOT FOUND: type: domain in plan/SKILL.md"
    echo "  RESULT: PASS (unexpected for RED — already fixed)"
else
    echo "  FOUND: $PLAN_TYPE"
    echo "  RESULT: FAIL (expected RED — invalid type still present)"
    OVERALL_RESULT=1
fi

# Write artifact output
ARTIFACT_DIR="$PROJECT_DIR/tmp/1602/artifacts"
mkdir -p "$ARTIFACT_DIR"
cat > "$ARTIFACT_DIR/red-phase-test-output.log" << EOF
=== RED Phase Test: Frontmatter Type Validation ===
SC-3 (Invalid type values exist):
  grep output:
$(echo "$MATCHES" | sed 's/^/    /')

SC-6 (plan/SKILL.md has type: domain):
  grep output: $PLAN_TYPE

OVERALL: $([ "$OVERALL_RESULT" -eq 0 ] && echo "PASS (unexpected for RED)" || echo "FAIL (expected RED — invalid types still present)")
EOF

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: frontmatter-type (all SCs pass — unexpected for RED phase)"
else
    echo "FAIL: frontmatter-type (expected RED behavior — invalid types still present)"
fi

exit $OVERALL_RESULT
