#!/usr/bin/env bash
# SC-2: check-pr.md Phase 3 must explicitly state that merge verification
#         (Phase 2) satisfies the authorization requirement for issue closure.
set -euo pipefail

TARGET="${PROJECT_ROOT:-/home/muksihs/git/opencode-config}/.opencode/skills/git-workflow-cleanup/tasks/check-pr.md"

if ! grep -q "merge verification.*authorization.*issue closure\|Phase 2.*satisfies.*authorization\|merge verification.*satisfies.*closure\|Phase 2.*authorization.*issue closure\|merge verification.*authorization.*close" "$TARGET" 2>/dev/null; then
    echo "FAIL: SC-2 — check-pr.md Phase 3 does not state that merge verification (Phase 2) satisfies the authorization requirement for issue closure."
    exit 1
fi

echo "PASS: SC-2 — merge verification authorization statement found in check-pr.md Phase 3."
exit 0
