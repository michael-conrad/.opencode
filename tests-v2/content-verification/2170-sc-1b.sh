#!/usr/bin/env bash
# SC-1b: pre-work.md No-Op Branch Guard cross-references branch-cleanup.md's
#         dirty pointer rule instead of repeating the deadlock.
set -euo pipefail

TARGET="${PROJECT_ROOT:-/home/muksihs/git/opencode-config}/.opencode/skills/git-workflow-branch/tasks/pre-work.md"

# Assert pre-work.md contains a cross-reference to branch-cleanup.md for the
# dirty pointer / submodule-only-PR lifecycle rule.
if ! grep -q "branch-cleanup\.md.*dirty pointer\|branch-cleanup\.md.*submodule.*pointer\|branch-cleanup\.md.*submodule-only\|Read.*branch-cleanup.*pointer\|Read.*branch-cleanup.*submodule" "$TARGET" 2>/dev/null; then
    echo "FAIL: SC-1b — pre-work.md does not cross-reference branch-cleanup.md for the dirty pointer rule."
    exit 1
fi

echo "PASS: SC-1b — pre-work.md cross-references branch-cleanup.md for the dirty pointer rule."
exit 0
