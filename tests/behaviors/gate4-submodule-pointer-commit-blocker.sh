#!/bin/bash
# Phase 1 — Regression test for Gate 4: submodule-pointer-only commit blocker.
#
# Verifies existing behavior before RED/GREEN phases.
# Must PASS in all phases (regression invariant).
#
# SC-2: Pre-commit hook allows commit where staged changes include
#       any non-submodule-pointer file.
# SC-6: Gate 4 does NOT fire on repos without .gitmodules.
#
# Co-authored with AI: OpenCode (opencode/deepseek-v4-flash-free)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="gate4-submodule-pointer-blocker"
OVERALL_RESULT=0

echo "=== Regression Test: Gate 4 (SC-2, SC-6) ==="

# ============================================================
# Create test fixtures
# ============================================================
TEST_DIR=$(mktemp -d "$PROJECT_DIR/tmp/gate4-test-XXXXXX")
trap 'rm -rf "$TEST_DIR"' EXIT

# We need two test repos:
#   repo-a — the "parent" repo
#   repo-b — the "submodule" repo
#
# Structure:
#   $TEST_DIR/repo-b/       (bare-ish, submodule source)
#   $TEST_DIR/repo-a/       (parent, clones repo-b as submodule)

# --- Create submodule repo (repo-b) ---
mkdir -p "$TEST_DIR/repo-b"
(cd "$TEST_DIR/repo-b" && git init -q && git config user.email "test@test.dev" && git config user.name "Test")
echo "submodule-content" > "$TEST_DIR/repo-b/README.md"
(cd "$TEST_DIR/repo-b" && git add -A && git commit -q -m "init submodule")

# --- Create parent repo (repo-a) with submodule ---
mkdir -p "$TEST_DIR/repo-a"
(cd "$TEST_DIR/repo-a" && git init -q && git config user.email "test@test.dev" && git config user.name "Test")
echo "parent-content" > "$TEST_DIR/repo-a/README.md"
(cd "$TEST_DIR/repo-a" && git add README.md && git commit -q -m "init parent")

# Add repo-b as submodule in repo-a (relative path for portability)
(cd "$TEST_DIR/repo-a" && git submodule add -q "$TEST_DIR/repo-b" libs/lib-b 2>/dev/null || true)
(cd "$TEST_DIR/repo-a" && git add -A && git commit -q -m "add submodule")

# Symlink the pre-commit hook into repo-a (SCRIPT_DIR is .opencode/tests/behaviors/)
HOOK_SOURCE="$(realpath "$SCRIPT_DIR/../../hooks/pre-commit")"
mkdir -p "$TEST_DIR/repo-a/.git/hooks"
ln -sf "$HOOK_SOURCE" "$TEST_DIR/repo-a/.git/hooks/pre-commit"

echo ""
echo "Fixture setup complete."
echo "  Parent: $TEST_DIR/repo-a"
echo "  Submodule: $TEST_DIR/repo-b"

# ============================================================
# SC-2: Non-submodule file alongside submodule pointer → allowed
# ============================================================
echo ""
echo "--- SC-2: Mixed commit (submodule pointer + regular file) ---"

# Make a change in the submodule to create a pointer update
echo "updated-content" >> "$TEST_DIR/repo-b/README.md"
(cd "$TEST_DIR/repo-b" && git add -A && git commit -q -m "update submodule")

# In parent, update submodule pointer AND add a regular file
(cd "$TEST_DIR/repo-a" && git submodule update --remote libs/lib-b 2>/dev/null || true)
echo "regular-file-content" > "$TEST_DIR/repo-a/regular.txt"
(cd "$TEST_DIR/repo-a" && git add -A)

# Attempt commit — should succeed (mixed content bypasses Gate 4)
SC2_OUTPUT=$(cd "$TEST_DIR/repo-a" && git commit -m "test: mixed commit" 2>&1 || true)

if echo "$SC2_OUTPUT" | grep -q "ERROR: Submodule-pointer-only commit blocked"; then
    echo "FAIL: SC-2 — Gate 4 BLOCKED a mixed-content commit (submodule pointer + regular file)"
    OVERALL_RESULT=1
else
    echo "PASS: SC-2 — mixed-content commit proceeded (Gate 4 correctly allowed)"
fi

# ============================================================
# SC-6: No .gitmodules → Gate 4 skips
# ============================================================
echo ""
echo "--- SC-6: Repo without .gitmodules ---"

TEST_DIR2=$(mktemp -d "$PROJECT_DIR/tmp/gate4-test-nomod-XXXXXX")
trap 'rm -rf "$TEST_DIR2"' EXIT

mkdir -p "$TEST_DIR2/repo-nomod"
(cd "$TEST_DIR2/repo-nomod" && git init -q && git config user.email "test@test.dev" && git config user.name "Test")
echo "standalone-content" > "$TEST_DIR2/repo-nomod/README.md"
(cd "$TEST_DIR2/repo-nomod" && git add README.md && git commit -q -m "init standalone")

# Confirm no .gitmodules
if [ -f "$TEST_DIR2/repo-nomod/.gitmodules" ]; then
    echo "FAIL: SC-6 — test setup error: .gitmodules exists in standalone repo"
    OVERALL_RESULT=1
else
    HOOK_SOURCE2="$(realpath "$SCRIPT_DIR/../../hooks/pre-commit")"
    mkdir -p "$TEST_DIR2/repo-nomod/.git/hooks"
    ln -sf "$HOOK_SOURCE2" "$TEST_DIR2/repo-nomod/.git/hooks/pre-commit"
    echo "new-file" > "$TEST_DIR2/repo-nomod/new_file.txt"
    (cd "$TEST_DIR2/repo-nomod" && git add -A)

    SC6_OUTPUT=$(cd "$TEST_DIR2/repo-nomod" && git commit -m "test: standalone commit" 2>&1 || true)

    if echo "$SC6_OUTPUT" | grep -q "ERROR: Submodule-pointer-only commit blocked"; then
        echo "FAIL: SC-6 — Gate 4 FIRED on repo without .gitmodules"
        OVERALL_RESULT=1
    else
        echo "PASS: SC-6 — commit proceeded on repo without .gitmodules"
    fi
fi

# ============================================================
# Report
# ============================================================
echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME (SC-2, SC-6 regression)"
else
    echo "FAIL: $SCENARIO_NAME (SC-2, SC-6 regression)"
fi

exit $OVERALL_RESULT
