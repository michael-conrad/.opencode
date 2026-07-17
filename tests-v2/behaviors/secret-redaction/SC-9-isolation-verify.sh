#!/bin/bash
# Structural verification: SC-9-isolation-verify
# Verifies that with-test-home creates an isolated environment where the
# SQLite DB project.worktree points to the test project, not production.
#
# This is a structural test (file content check), not a behavioral test.
# It runs with-test-home --setup, then queries the SQLite DB.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run setup and capture output
SETUP_OUTPUT=$(bash "$SCRIPT_DIR/../../with-test-home" --setup 2>&1)
echo "$SETUP_OUTPUT"

# Extract TEST_HOME from setup output
TEST_HOME=$(echo "$SETUP_OUTPUT" | grep '^TEST_HOME=' | cut -d= -f2-)
if [ -z "$TEST_HOME" ]; then
    echo "FAIL: could not extract TEST_HOME from setup output"
    exit 1
fi

# Find the SQLite DB
DB_PATH="$TEST_HOME/.local/share/opencode/opencode.db"
if [ ! -f "$DB_PATH" ]; then
    echo "FAIL: SQLite DB not found at $DB_PATH"
    exit 1
fi

# Query project.worktree
WORKTREE=$(sqlite3 "$DB_PATH" "SELECT worktree FROM project;" 2>/dev/null || echo "")
if [ -z "$WORKTREE" ]; then
    echo "FAIL: no project.worktree found in DB"
    exit 1
fi

echo "Project worktree: $WORKTREE"

# Verify it contains tmp/test-home- (test project path)
if echo "$WORKTREE" | grep -q 'tmp/test-home-'; then
    echo "PASS: worktree contains test home path"
else
    echo "FAIL: worktree does not contain test home path"
    echo "  Expected: *tmp/test-home-*"
    echo "  Got: $WORKTREE"
    exit 1
fi

# Verify it does NOT contain the production project path
PRODUCTION_PATH="/home/muksihs/git/opencode-config"
if echo "$WORKTREE" | grep -q "$PRODUCTION_PATH" && ! echo "$WORKTREE" | grep -q 'tmp/test-home-'; then
    echo "FAIL: worktree contains production path without test home"
    echo "  Got: $WORKTREE"
    exit 1
fi

echo "PASS: isolation verified"
exit 0
