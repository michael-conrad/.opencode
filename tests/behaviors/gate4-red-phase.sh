#!/bin/bash
# Phase 2 — RED test for Gate 4: submodule-pointer-only commit blocker.
#
# Verifies absence of Gate 4 blocking behavior.
# MUST FAIL (exit non-zero) in RED phase because Gate 4 doesn't exist yet.
#
# SC-1: Pre-commit hook blocks commit where only staged change is a submodule pointer
# SC-5: Gate 4 fires on ALL branches, including pair-*, rollback/*, hotfix/*
#
# Co-authored with AI: deepseek-v4-flash (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="gate4-red-phase"
OVERALL_RESULT=0

echo "=== RED Phase Test: Gate 4 (SC-1, SC-5) ==="

# ============================================================
# Create test fixtures
# ============================================================
TEST_DIR=$(mktemp -d "$PROJECT_DIR/tmp/gate4-test-XXXXXX")
trap 'rm -rf "$TEST_DIR"' EXIT

# Create submodule repo (repo-b)
mkdir -p "$TEST_DIR/repo-b"
(cd "$TEST_DIR/repo-b" && git init -q && git config user.email "test@test.dev" && git config user.name "Test")
echo "submodule-content" > "$TEST_DIR/repo-b/README.md"
(cd "$TEST_DIR/repo-b" && git add -A && git commit -q -m "init submodule")

# Create parent repo (repo-a) with submodule
mkdir -p "$TEST_DIR/repo-a"
(cd "$TEST_DIR/repo-a" && git init -q && git config user.email "test@test.dev" && git config user.name "Test")
echo "parent-content" > "$TEST_DIR/repo-a/README.md"
(cd "$TEST_DIR/repo-a" && git add README.md && git commit -q -m "init parent")
(cd "$TEST_DIR/repo-a" && git submodule add -q "$TEST_DIR/repo-b" libs/lib-b 2>/dev/null || true)
(cd "$TEST_DIR/repo-a" && git add -A && git commit -q -m "add submodule")

# Symlink the pre-commit hook into repo-a
HOOK_SOURCE="$(realpath "$SCRIPT_DIR/../../hooks/pre-commit")"
mkdir -p "$TEST_DIR/repo-a/.git/hooks"
ln -sf "$HOOK_SOURCE" "$TEST_DIR/repo-a/.git/hooks/pre-commit"

echo ""
echo "Fixture setup complete."

# ============================================================
# Helper: attempt submodule-pointer-only commit on given branch
# Returns 0 if commit was BLOCKED by Gate 4, 1 if it proceeded
# ============================================================
test_submodule_pointer_commit() {
    local branch_name="$1"
    local branch_desc="$2"

    echo ""
    echo "--- Branch: $branch_name ($branch_desc) ---"

    # Create a new submodule commit
    local repo_b_sha
    echo "updated-content-$(date +%s)" >> "$TEST_DIR/repo-b/README.md"
    (cd "$TEST_DIR/repo-b" && git add -A && git commit -q -m "update submodule")

    # Create branch in parent repo
    (cd "$TEST_DIR/repo-a" && git checkout -q -b "$branch_name" 2>/dev/null || true)

    # Update submodule pointer (only staged change)
    (cd "$TEST_DIR/repo-a" && git submodule update --remote libs/lib-b 2>/dev/null || true)

    # Stage only the submodule pointer change
    local staged
    staged=$(cd "$TEST_DIR/repo-a" && git diff --cached --name-only 2>/dev/null || true)
    if [ -z "$staged" ]; then
        # Nothing cached yet, add the submodule update
        (cd "$TEST_DIR/repo-a" && git add libs/lib-b 2>/dev/null || true)
    fi

    # Attempt commit
    local commit_output
    commit_output=$(cd "$TEST_DIR/repo-a" && git commit -m "test: submodule pointer update" 2>&1 || true)

    # Check if Gate 4 blocked it
    if echo "$commit_output" | grep -qE "submodule.pointer.*blocked|Gate 4"; then
        echo "  RESULT: commit blocked by Gate 4 (SC-1 PASS behavior)"
        return 0
    else
        echo "  RESULT: commit proceeded unblocked (Gate 4 absent — expected RED behavior)"
        # Print commit output for diagnostics
        echo "  Commit output: $(echo "$commit_output" | head -3)"
        return 1
    fi
}

# ============================================================
# SC-1: Submodule-pointer-only commit on feature branch
# ============================================================
echo ""
echo "--- SC-1: Submodule-pointer-only commit on feature branch ---"

if test_submodule_pointer_commit "feature/test-gate4" "feature branch"; then
    echo "PASS: SC-1 — commit blocked (Gate 4 present)"
    SC1_RESULT=0
else
    echo "FAIL: SC-1 — commit proceeded unblocked (Gate 4 absent)"
    SC1_RESULT=1
    OVERALL_RESULT=1
fi

# ============================================================
# SC-5: Submodule-pointer-only commit on ALL branch types
# ============================================================
echo ""
echo "--- SC-5: Gate 4 fires on ALL branches ---"

# Go back to a clean state for each test
(cd "$TEST_DIR/repo-a" && git checkout -q -b master-temp 2>/dev/null || true)
(cd "$TEST_DIR/repo-a" && git checkout -q master-temp 2>/dev/null || true)

SC5_RESULT=0

for branch_pair in "pair-feature/123:pair- branch" "rollback/hotfix-456:rollback/* branch" "hotfix/urgent-789:hotfix/* branch"; do
    branch_name="${branch_pair%%:*}"
    branch_desc="${branch_pair##*:}"

    if test_submodule_pointer_commit "$branch_name" "$branch_desc"; then
        echo "  PASS: SC-5 — commit blocked on $branch_name"
    else
        echo "  FAIL: SC-5 — commit proceeded unblocked on $branch_name"
        SC5_RESULT=1
        OVERALL_RESULT=1
    fi
done

# ============================================================
# Report
# ============================================================
echo ""
echo "=== RED Phase Results ==="
echo "SC-1: $([ "$SC1_RESULT" -eq 0 ] && echo "PASS (Gate 4 present)" || echo "FAIL (Gate 4 absent — expected RED)")"
echo "SC-5: $([ "$SC5_RESULT" -eq 0 ] && echo "PASS (Gate 4 fires on all branches)" || echo "FAIL (Gate 4 absent on some branches — expected RED)")"

# SC results (for orchestrator reporting)
mkdir -p "${BEHAVIOR_LOG_DIR:-$PROJECT_DIR/tmp}"
cat > "${BEHAVIOR_LOG_DIR:-$PROJECT_DIR/tmp}/gate4-red-sc-results.txt" << EOF
SC-1: $([ "$SC1_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL")
SC-5: $([ "$SC5_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL")
EOF

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME (SC-1, SC-5)"
else
    echo "FAIL: $SCENARIO_NAME (SC-1, SC-5) — expected RED behavior"
fi

exit $OVERALL_RESULT
