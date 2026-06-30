#!/usr/bin/env bash
# RED phase: content-verification test for SC-3 (provenance frontmatter)
# Verifies that all SKILL.md files have a `provenance:` line in their YAML frontmatter.
# This test MUST FAIL now (RED) and PASS after GREEN implementation.
set -euo pipefail

OVERALL_RESULT=0

echo "=== RED Phase: Content-Verification Test (SC-3) ==="
echo "Verifying provenance frontmatter in all SKILL.md files (expecting FAIL — RED)"
echo ""

# SC-3: All SKILL.md files must have provenance frontmatter
COUNT=$(grep -l '^provenance:' .opencode/skills/*/SKILL.md .opencode/skills/issue-operations/platforms/*/SKILL.md 2>/dev/null | wc -l)
TOTAL=42

echo "  Files with provenance: $COUNT / $TOTAL"
if [ "$COUNT" -eq "$TOTAL" ]; then
  echo "  PASS: All $TOTAL SKILL.md files have provenance frontmatter"
else
  echo "  FAIL: Only $COUNT of $TOTAL SKILL.md files have provenance frontmatter"
  OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
  echo "=== RESULT: ALL PASS — GREEN confirmed ==="
else
  echo "=== RESULT: FAIL — RED confirmed (provenance not yet implemented in all files) ==="
fi
exit $OVERALL_RESULT
