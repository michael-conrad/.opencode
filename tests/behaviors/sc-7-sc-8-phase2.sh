#!/usr/bin/env bash
# RED phase: verify spec-creation/SKILL.md and writing-plans/SKILL.md
# do NOT contain the taxonomy cross-reference yet.

set -euo pipefail
OVERALL_RESULT=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../" && pwd)"

# SC-7 RED: spec-creation/SKILL.md must NOT contain taxonomy reference
if grep -q "skill-card-change-types" "$REPO_ROOT/skills/spec-creation/SKILL.md" 2>/dev/null; then
  echo "FAIL: SC-7 already implemented (RED baseline broken)"
  OVERALL_RESULT=1
else
  echo "PASS: SC-7 RED confirmed"
fi

# SC-8 RED: writing-plans/SKILL.md must NOT contain taxonomy reference
if grep -q "skill-card-change-types" "$REPO_ROOT/skills/writing-plans/SKILL.md" 2>/dev/null; then
  echo "FAIL: SC-8 already implemented (RED baseline broken)"
  OVERALL_RESULT=1
else
  echo "PASS: SC-8 RED confirmed"
fi

if [ "$OVERALL_RESULT" -eq 0 ]; then
  echo "All Phase 2 SCs confirmed RED"
else
  echo "One or more Phase 2 SCs already implemented — RED baseline broken"
fi

exit "$OVERALL_RESULT"