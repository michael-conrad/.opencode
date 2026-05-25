#!/bin/bash
# RED phase: Pre-commit Gate 4 — Submodule-pointer-only commit blocker
#
# RED: This test FAILS because Gate 4 does not exist yet.
#      After GREEN (adding Gate 4 to hooks/pre-commit), this test PASSES.
#
# TDD: Exit 0 = GREEN (Gate 4 exists and blocks submodule-pointer-only commits)
#      Exit 1 = RED  (Gate 4 missing — commits sail through unblocked)
#
# Co-authored with AI: OpenCode (deepseek-v4-flash-free)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

OVERALL_RESULT=0
TEST_TMPDIR=$(mktemp -d "$PROJECT_DIR/tmp/gate4-red-XXXXXX")
GATE4_FOUND=0
cleanup() { rm -rf "$TEST_TMPDIR"; }
trap cleanup EXIT

echo "=== RED: Pre-commit Gate 4 TDD Test ==="
echo ""

# --- Check pre-condition: Gate 4 does not exist yet ---
if grep -q 'Gate 4\|GATE 4\|Gate4\|GATE4\|# Gate 4' "$PROJECT_DIR/.opencode/hooks/pre-commit" 2>/dev/null; then
    echo "WARNING: Gate 4 already exists in hooks/pre-commit!"
    echo "This test expects RED (no Gate 4). If Gate 4 was already added,"
    echo "delete it or revert the change before running this test in RED."
    GATE4_FOUND=1
fi

# --- Setup: Create test parent repo with submodule ---
echo "--- Creating test environment ---"
PARENT_DIR="$TEST_TMPDIR/parent"
SUBMODULE_DIR="$TEST_TMPDIR/submodule"

# Submodule repo
mkdir -p "$SUBMODULE_DIR"
git init -q "$SUBMODULE_DIR"
git -C "$SUBMODULE_DIR" config user.email "test@test.dev"
git -C "$SUBMODULE_DIR" config user.name "Test"
echo "submodule-file" > "$SUBMODULE_DIR/file.txt"
git -C "$SUBMODULE_DIR" add -A
git -C "$SUBMODULE_DIR" commit -q -m "submodule init"

# Parent repo with submodule
mkdir -p "$PARENT_DIR"
git init -q "$PARENT_DIR"
git -C "$PARENT_DIR" config user.email "test@test.dev"
git -C "$PARENT_DIR" config user.name "Test"
git -C "$PARENT_DIR" submodule add "$SUBMODULE_DIR" mysubmodule
git -C "$PARENT_DIR" add -A
git -C "$PARENT_DIR" commit -q -m "parent init"
git -C "$PARENT_DIR" checkout -q -b feature/test-gate4

# Install the pre-commit hook
cp "$PROJECT_DIR/.opencode/hooks/pre-commit" "$PARENT_DIR/.git/hooks/pre-commit"
chmod +x "$PARENT_DIR/.git/hooks/pre-commit"
echo "  Hook installed from hooks/pre-commit"
echo ""

# === Test 1: Submodule-pointer-only commit (feature branch) ===
echo "--- Test 1: Submodule-pointer-only commit on feature branch ---"
echo "updated" > "$PARENT_DIR/mysubmodule/file.txt"
git -C "$PARENT_DIR/mysubmodule" add -A
git -C "$PARENT_DIR/mysubmodule" commit -q -m "update"
git -C "$PARENT_DIR" add mysubmodule

set +e
git -C "$PARENT_DIR" commit -m "test: submodule pointer only" > /dev/null 2>&1
EXIT_1=$?
set -e

if [ "$EXIT_1" -eq 0 ]; then
    echo "  ✗ FAIL (RED): Submodule-pointer-only commit was ALLOWED (exit 0)"
    echo "    Gate 4 should block this but does not exist yet."
    echo "    Expected: commit blocked (exit 1)"
    OVERALL_RESULT=1
else
    echo "  ✓ PASS (GREEN): Submodule-pointer-only commit was BLOCKED (exit $EXIT_1)"
fi

# === Test 2: Submodule-pointer-only commit (pair-* branch) ===
echo ""
echo "--- Test 2: Submodule-pointer-only commit on pair-* branch ---"
git -C "$PARENT_DIR" reset --hard HEAD~1 > /dev/null 2>&1 || true
git -C "$PARENT_DIR" checkout -q -b pair-test/gate4-check

echo "updated2" > "$PARENT_DIR/mysubmodule/file.txt"
git -C "$PARENT_DIR/mysubmodule" add -A
git -C "$PARENT_DIR/mysubmodule" commit -q -m "update2"
git -C "$PARENT_DIR" add mysubmodule

set +e
git -C "$PARENT_DIR" commit -m "test: pair branch submodule pointer" > /dev/null 2>&1
EXIT_2=$?
set -e

if [ "$EXIT_2" -eq 0 ]; then
    echo "  ✗ FAIL (RED): Submodule-pointer-only commit was ALLOWED on pair-* branch (exit 0)"
    echo "    Gate 4 should block ALL branches, including pair-*."
    echo "    Expected: commit blocked (exit 1)"
    OVERALL_RESULT=1
else
    echo "  ✓ PASS (GREEN): Submodule-pointer-only commit was BLOCKED on pair-* (exit $EXIT_2)"
fi

# === Result ===
echo ""
echo "=== TDD Result ==="
if [ "$GATE4_FOUND" -eq 1 ]; then
    echo "Gate 4 already exists — this test is moot."
    echo "Revert hooks/pre-commit to run RED phase."
    exit 0
fi

if [ "$OVERALL_RESULT" -ne 0 ]; then
    echo "  RED (exit $OVERALL_RESULT): Gate 4 not implemented"
    echo "  Proceed to GREEN: add Gate 4 to hooks/pre-commit"
    exit $OVERALL_RESULT
else
    echo "  UNEXPECTED PASS: All commits were blocked — Gate 4 is already working"
    echo "  (Test may have reached GREEN state without GREEN implementation)"
    exit 0
fi
