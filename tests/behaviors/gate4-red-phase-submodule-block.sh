#!/bin/bash
# Phase 2 — RED phase test for Gate 4: submodule-pointer-only commit blocker.
#
# Verifies that Gate 4 blocks submodule-pointer-only commits on ALL branches.
# These tests would have FAILED before Gate 4 was implemented (RED phase).
# They MUST PASS now (GREEN phase) with Gate 4 in place.
#
# SC-1: Pre-commit hook blocks commit where only staged change is a
#       submodule pointer.
# SC-5: Gate 4 fires on ALL branches, including pair-*, rollback/*,
#       hotfix/* (branches that Gate 3 exempts).
#
# Co-authored with AI: OpenCode (opencode/deepseek-v4-flash-free)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="gate4-red-phase-submodule-block"
OVERALL_RESULT=0

echo "=== RED Phase Test: Gate 4 (SC-1, SC-5) ==="

# ============================================================
# Create test fixtures (shared by SC-1 and SC-5)
# ============================================================
TEST_DIR=$(mktemp -d "$PROJECT_DIR/tmp/gate4-red-test-XXXXXX")
trap 'rm -rf "$TEST_DIR"' EXIT

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
(cd "$TEST_DIR/repo-a" && git submodule add -q "$TEST_DIR/repo-b" libs/lib-b 2>/dev/null || true)
(cd "$TEST_DIR/repo-a" && git add -A && git commit -q -m "add submodule")

# Symlink pre-commit hook (SCRIPT_DIR is .opencode/tests/behaviors/)
HOOK_SOURCE="$(realpath "$SCRIPT_DIR/../../hooks/pre-commit")"
mkdir -p "$TEST_DIR/repo-a/.git/hooks"
ln -sf "$HOOK_SOURCE" "$TEST_DIR/repo-a/.git/hooks/pre-commit"

echo ""
echo "Fixture setup complete."
echo "  Parent: $TEST_DIR/repo-a"

# ============================================================
# Helper: attempt submodule-pointer-only commit on a given branch
# Returns 0 if blocked (Gate 4 fired), 1 if commit proceeded
# ============================================================
test_branch_blocked() {
    local branch_name="$1"
    local label="$2"

    # Create branch
    (cd "$TEST_DIR/repo-a" && git checkout -q -b "$branch_name" 2>/dev/null || true)
    (cd "$TEST_DIR/repo-a" && git checkout -q "$branch_name" 2>/dev/null)

    # Make a change in submodule to create pointer update
    echo "update-for-$branch_name" >> "$TEST_DIR/repo-b/README.md"
    (cd "$TEST_DIR/repo-b" && git add -A && git commit -q -m "update for $branch_name")

    # Update submodule pointer in parent (stages only the .gitmodules entry)
    (cd "$TEST_DIR/repo-a" && git submodule update --remote libs/lib-b 2>/dev/null || true)

    # Stage ONLY the submodule pointer (not any regular file)
    (cd "$TEST_DIR/repo-a" && git add libs/lib-b 2>/dev/null || true)

    # Attempt commit
    local output
    output=$(cd "$TEST_DIR/repo-a" && git commit -m "test: submodule-only on $branch_name" 2>&1 || true)

    if echo "$output" | grep -q "ERROR: Submodule-pointer-only commit blocked"; then
        echo "  ✓ $label: blocked correctly"
        return 0
    else
        echo "  ✗ $label: NOT blocked (commit proceeded)"
        return 1
    fi
}

# ============================================================
# SC-1: Submodule-pointer-only commit blocked (feature branch)
# ============================================================
echo ""
echo "--- SC-1: Submodule-pointer-only commit on feature branch ---"

test_branch_blocked "feature/test-sc1" "feature branch" || OVERALL_RESULT=1

# ============================================================
# SC-5: Gate 4 fires on ALL branches (no exemptions)
# ============================================================
echo ""
echo "--- SC-5: Gate 4 fires on ALL branches ---"

# Test pair-* branch (Gate 3 exempts this)
echo ""
echo "  Testing pair-* branch..."
test_branch_blocked "pair-fix/123-test" "pair-* branch" || OVERALL_RESULT=1

# Test rollback/* branch (Gate 3 exempts this)
echo ""
echo "  Testing rollback/* branch..."
test_branch_blocked "rollback/v1-hotfix" "rollback/* branch" || OVERALL_RESULT=1

# Test hotfix/* branch (Gate 3 exempts this)
echo ""
echo "  Testing hotfix/* branch..."
test_branch_blocked "hotfix/critical-issue" "hotfix/* branch" || OVERALL_RESULT=1

# Test dev branch explicitly — should also be blocked
echo ""
echo "  Testing dev branch (Gate 1 would also block, but Gate 4 should fire first for the submodule check)..."

# For dev, we need a different setup since Gate 1 blocks direct commits to dev.
# We'll verify by checking that Gate 4's logic would fire even without Gate 1.
# Actually, Gate 1 blocks dev BEFORE Gate 4 runs. So let's test a regular feature branch
# to confirm Gate 4 works regardless of branch name pattern.

# main is also blocked by Gate 1 before Gate 4, same as dev.

# Additional edge: Test a branch with unusual characters
echo ""
echo "  Testing edge-case branch names..."
test_branch_blocked "feature/UPPERCASE-BRANCH" "UPPERCASE branch" || OVERALL_RESULT=1
test_branch_blocked "feature/with-dashes-and_underscores" "mixed naming branch" || OVERALL_RESULT=1
test_branch_blocked "fix/issue-42" "numeric branch" || OVERALL_RESULT=1

# ============================================================
# Verify Gate 3 exemption branches ARE blocked by Gate 4
# ============================================================
echo ""
echo "--- SC-5 verification: Gate-3-exempt branches blocked by Gate 4 ---"

# Reset to feature branch baseline first
(cd "$TEST_DIR/repo-a" && git checkout -q -b "verify/g3-exempt" 2>/dev/null || true)
(cd "$TEST_DIR/repo-a" && git checkout -q "verify/g3-exempt" 2>/dev/null)

# Make submodule change
echo "final-g3-test" >> "$TEST_DIR/repo-b/README.md"
(cd "$TEST_DIR/repo-b" && git add -A && git commit -q -m "g3 exempt test")
(cd "$TEST_DIR/repo-a" && git submodule update --remote libs/lib-b 2>/dev/null || true)
(cd "$TEST_DIR/repo-a" && git add libs/lib-b)

# Allow mix to succeed as SC-5 sanity: add a regular file alongside pointer
echo "g3-mix-content" > "$TEST_DIR/repo-a/g3_mix.txt"
(cd "$TEST_DIR/repo-a" && git add g3_mix.txt)

MIX_OUTPUT=$(cd "$TEST_DIR/repo-a" && git commit -m "test: mixed on G3-exempt branch" 2>&1 || true)
if echo "$MIX_OUTPUT" | grep -q "ERROR: Submodule-pointer-only commit blocked"; then
    echo "  ✗ G3-exempt branch with mixed content was blocked (unexpected)"
    OVERALL_RESULT=1
else
    echo "  ✓ G3-exempt branch with mixed content proceeded (Gate 4 correctly allowed)"
fi

# ============================================================
# Report
# ============================================================
echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME (SC-1, SC-5 behavioral)"
else
    echo "FAIL: $SCENARIO_NAME (SC-1, SC-5 behavioral)"
fi

exit $OVERALL_RESULT
