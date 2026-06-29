#!/bin/bash
# Content-verification test: 1540-sc5-pr-body-red
# SC-5: PR body includes all 6 required sections
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is a content-verification test — it checks file content patterns.
#
# RED phase: expects FAIL because the spec-card-mapped commits table section
# does not exist in create-pr.md yet
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

TARGET_FILE="$PROJECT_ROOT/.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md"

if [ ! -f "$TARGET_FILE" ]; then
  echo "FAIL: $TARGET_FILE not found"
  exit 1
fi

OVERALL_RESULT=0

# Section 1: Summary
if grep -q '\*\*Summary:\*\*' "$TARGET_FILE"; then
  echo "PASS: Summary section found"
else
  echo "FAIL: Summary section NOT found"
  OVERALL_RESULT=1
fi

# Section 2: Outcome
if grep -q '\*\*Outcome:\*\*' "$TARGET_FILE"; then
  echo "PASS: Outcome section found"
else
  echo "FAIL: Outcome section NOT found"
  OVERALL_RESULT=1
fi

# Section 3: VbC results table (Per-SC Evidence)
if grep -q 'Per-SC Evidence' "$TARGET_FILE"; then
  echo "PASS: Per-SC Evidence table found"
else
  echo "FAIL: Per-SC Evidence table NOT found"
  OVERALL_RESULT=1
fi

# Section 4: Adversarial auditor results (Dual-Auditor Cross-Validation)
if grep -q 'Dual-Auditor Cross-Validation' "$TARGET_FILE"; then
  echo "PASS: Dual-Auditor Cross-Validation table found"
else
  echo "FAIL: Dual-Auditor Cross-Validation table NOT found"
  OVERALL_RESULT=1
fi

# Section 5: Spec-card-mapped commits table
if grep -q 'Spec-card-mapped commits\|Spec.*Card.*Commit\|Commit.*Spec.*Card' "$TARGET_FILE"; then
  echo "PASS: Spec-card-mapped commits table found"
else
  echo "FAIL: Spec-card-mapped commits table NOT found"
  OVERALL_RESULT=1
fi

# Section 6: AI byline (Co-authored with AI)
if grep -q 'Co-authored with AI:' "$TARGET_FILE"; then
  echo "PASS: AI byline section found"
else
  echo "FAIL: AI byline section NOT found"
  OVERALL_RESULT=1
fi

if [ "$OVERALL_RESULT" -ne 0 ]; then
  echo "RED FAIL: One or more required PR body sections are missing from $TARGET_FILE"
  exit 1
fi

echo "RED PASS: All 6 required PR body sections found in $TARGET_FILE"
exit 0
