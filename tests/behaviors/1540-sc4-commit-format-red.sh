#!/bin/bash
# Content-verification test: sc-4-commit-format
# SC-4: Commit messages follow `#<issue> <title> — <summary>` pattern
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is a content-verification test — it checks file content patterns.
#
# RED phase: expects FAIL because the standardized commit message format
# does not exist in squash-push.md yet
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

SQUASH_PUSH="$PROJECT_ROOT/.opencode/skills/git-workflow/tasks/pr-creation/squash-push.md"

if [ ! -f "$SQUASH_PUSH" ]; then
  echo "FAIL: $SQUASH_PUSH not found"
  exit 1
fi

# Grep for the standardized commit message format: #<issue> <title> — <summary>
if grep -qP '#\d+ .+ — .+' "$SQUASH_PUSH"; then
  echo "PASS: Standardized commit message format found in $SQUASH_PUSH"
  exit 0
else
  echo "FAIL: Standardized commit message format (#<issue> <title> — <summary>) NOT found in $SQUASH_PUSH"
  exit 1
fi
