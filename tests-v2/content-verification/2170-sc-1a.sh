#!/usr/bin/env bash
# SC-1a: branch-cleanup.md must contain an explicit statement that submodule
#         pointer commits only happen alongside real code changes on a feature
#         branch, never during cleanup.
set -euo pipefail

TARGET="${PROJECT_ROOT:-/home/muksihs/git/opencode-config}/.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md"

if ! grep -q "submodule pointer.*real code change\|submodule pointer.*alongside.*feature branch\|submodule pointer commit.*only.*feature branch\|submodule pointer.*never.*cleanup" "$TARGET" 2>/dev/null; then
    echo "FAIL: SC-1a — branch-cleanup.md does not contain the required submodule pointer lifecycle statement."
    exit 1
fi

echo "PASS: SC-1a — submodule pointer lifecycle statement found."
exit 0
