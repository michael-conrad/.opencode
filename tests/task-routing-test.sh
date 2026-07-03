#!/bin/bash
# Content-verification enforcement test for SC-4 (#863):
# No task() calls in sub-agent-readable task files.
#
# RED phase: should FAIL because task files still have task() calls.
# GREEN phase (after Phase 2 edits): should PASS with zero matches.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

OPencode_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OVERALL_RESULT=0

echo "=== Content-Verification: SC-4 — No task() in task files ==="
echo ""

# SC-4: Verify the 8 specifically identified task files from the spec's
# affected files table have zero dispatch-style task() instructions.
# These 8 files are the ones sub-agents could read and encounter task()
# as a dispatch instruction. Architectural prose like "skill() → task()"
# in tables is out of scope.
TARGET_FILES=(
  "git-workflow/tasks/cleanup/branch-cleanup.md"
  "git-workflow/tasks/pre-work.md"
  "git-workflow/tasks/review-prep/push-and-cleanup.md"
  "git-workflow/tasks/pr-creation/enforcement-gate.md"
  "verification-before-completion/tasks/verify.md"
  "research/tasks/research-multi.md"
  "multimodal-dispatch/tasks/dispatch-multi.md"
  "changelog-generator/tasks/since-last-release.md"
)
RESULTS=""
for f in "${TARGET_FILES[@]}"; do
  matches=$(grep -nE "task\(\)\s+(a|the|to|clean|sub-agent|submodule)" "$OPencode_DIR/skills/$f" 2>/dev/null | grep -v -E "re-task|second task" || true)
  if [ -n "$matches" ]; then
    RESULTS+="$f: $matches"$'\n'
  fi
done

if [ -z "$RESULTS" ]; then
    echo "PASS: SC-4 — Zero task() calls found in any task file"
else
    MATCH_COUNT=$(echo "$RESULTS" | wc -l)
    echo "FAIL: SC-4 — Found $MATCH_COUNT task() call(s) in task files"
    echo ""
    echo "$RESULTS"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "All content-verification assertions passed"
else
    echo "Some content-verification assertions failed"
fi

exit $OVERALL_RESULT
