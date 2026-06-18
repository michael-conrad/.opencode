#!/usr/bin/env bash
# SC-1 through SC-6: Taxonomy reference document existence and content validation
set -euo pipefail

REF_FILE=".opencode/skills/reference/skill-card-change-types.md"
OVERALL_RESULT=0

echo "=== RED Phase: Phase 1 SC-1 through SC-6 ==="
echo ""

# SC-1: Taxonomy reference document exists
echo "SC-1: test -f $REF_FILE"
if test -f "$REF_FILE"; then
  echo "  PASS: File exists"
else
  echo "  FAIL: File does not exist"
  OVERALL_RESULT=1
fi

# SC-2: Document defines all 10 types
echo "SC-2: grep -c '^### Type' == 10"
if test -f "$REF_FILE"; then
  COUNT=$(grep -c "^### Type" "$REF_FILE" 2>/dev/null || echo 0)
  if [ "$COUNT" -eq 10 ]; then
    echo "  PASS: Found $COUNT type sections"
  else
    echo "  FAIL: Found $COUNT type sections, expected 10"
    OVERALL_RESULT=1
  fi
else
  echo "  FAIL: Cannot check SC-2 — file does not exist"
  OVERALL_RESULT=1
fi

# SC-3: Each type has Blast Radius
echo "SC-3: grep -c 'Blast Radius' == 10"
if test -f "$REF_FILE"; then
  COUNT=$(grep -c "Blast Radius" "$REF_FILE" 2>/dev/null || echo 0)
  if [ "$COUNT" -eq 10 ]; then
    echo "  PASS: Found $COUNT Blast Radius sections"
  else
    echo "  FAIL: Found $COUNT Blast Radius sections, expected 10"
    OVERALL_RESULT=1
  fi
else
  echo "  FAIL: Cannot check SC-3 — file does not exist"
  OVERALL_RESULT=1
fi

# SC-4: Each type has Remediation Guidance
echo "SC-4: grep -c 'Remediation Guidance' == 10"
if test -f "$REF_FILE"; then
  COUNT=$(grep -c "Remediation Guidance" "$REF_FILE" 2>/dev/null || echo 0)
  if [ "$COUNT" -eq 10 ]; then
    echo "  PASS: Found $COUNT Remediation Guidance sections"
  else
    echo "  FAIL: Found $COUNT Remediation Guidance sections, expected 10"
    OVERALL_RESULT=1
  fi
else
  echo "  FAIL: Cannot check SC-4 — file does not exist"
  OVERALL_RESULT=1
fi

# SC-5: Each type has Workflow Validation
echo "SC-5: grep -c 'Workflow Validation' == 10"
if test -f "$REF_FILE"; then
  COUNT=$(grep -c "Workflow Validation" "$REF_FILE" 2>/dev/null || echo 0)
  if [ "$COUNT" -eq 10 ]; then
    echo "  PASS: Found $COUNT Workflow Validation sections"
  else
    echo "  FAIL: Found $COUNT Workflow Validation sections, expected 10"
    OVERALL_RESULT=1
  fi
else
  echo "  FAIL: Cannot check SC-5 — file does not exist"
  OVERALL_RESULT=1
fi

# SC-6: Document includes Mandatory Workflow Validation Rule
echo "SC-6: grep -q 'Mandatory Workflow Validation Rule'"
if test -f "$REF_FILE"; then
  if grep -q "Mandatory Workflow Validation Rule" "$REF_FILE" 2>/dev/null; then
    echo "  PASS: Found Mandatory Workflow Validation Rule section"
  else
    echo "  FAIL: Mandatory Workflow Validation Rule section not found"
    OVERALL_RESULT=1
  fi
else
  echo "  FAIL: Cannot check SC-6 — file does not exist"
  OVERALL_RESULT=1
fi

echo ""
echo "=== Overall: $([ "$OVERALL_RESULT" -eq 0 ] && echo 'PASS' || echo 'FAIL') ==="
exit "$OVERALL_RESULT"