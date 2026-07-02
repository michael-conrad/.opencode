#!/bin/bash
# Behavioral test: 492-stale-branch-auto-rebase-conflict
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Tier 3 conflict — agent should halt and escalate.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-GREEN}"
BEHAVIOR_FIXTURE_ISSUES=0
BEHAVIOR_STORY_FIXTURES=0
TEST_REMOTE="git@github.com:michael-conrad/test-submodule-1.git"

# Create test home once (unset any stale TEST_HOME from prior runs)
unset TEST_HOME
SETUP_OUTPUT=$(bash "$PARENT_REPO_DIR/$BEHAVIOR_TEST_HOME" --setup "$PARENT_REPO_DIR" 2>/dev/null)
SHARED_TEST_HOME=$(echo "$SETUP_OUTPUT" | grep '^TEST_HOME=' | cut -d= -f2-)
export TEST_HOME="$SHARED_TEST_HOME"

WD=$(mktemp -d "/tmp/opencode/behavior-isolated-XXXXXX")
git init -q "$WD"
git -C "$WD" config user.email "test@test.dev"
git -C "$WD" config user.name "Test"
git -C "$WD" remote add origin "$TEST_REMOTE"

# seed dev branch
echo "initial" > "$WD/file.txt"
git -C "$WD" add file.txt
git -C "$WD" commit -q -m "initial"
git -C "$WD" branch -M dev
git -C "$WD" push -q -f -u origin dev

# setup conflict branch (same file, different content)
git -C "$WD" fetch -q origin dev
git -C "$WD" checkout -q dev
git -C "$WD" reset -q --hard origin/dev
git -C "$WD" checkout -b feature/conflict-test
echo "feature version" > "$WD/file.txt"
git -C "$WD" add file.txt
git -C "$WD" commit -q -m "feature change"
git -C "$WD" checkout dev
echo "dev version" > "$WD/file.txt"
git -C "$WD" add file.txt
git -C "$WD" commit -q -m "dev change"
git -C "$WD" push -q origin dev
git -C "$WD" checkout feature/conflict-test

# finalize
mkdir -p "$WD/.issues"
printf ".opencode/\ntmp/\n.issues/\nfixtures/\n*.pyc\n__pycache__/\n" > "$WD/.gitignore"
git -C "$WD" add -A
git -C "$WD" add -f .gitignore
git -C "$WD" commit -q --allow-empty -m "setup complete"

behavior_run "492-stale-branch-auto-rebase-conflict" \
    "Execute the push-and-cleanup task for the current feature branch. Run git fetch, check if the branch is behind origin/dev, and if so rebase. Then push the branch." \
    "$DEFAULT_TEST_MODEL" "$WD"

exit 0
