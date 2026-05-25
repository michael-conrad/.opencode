#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# TDD test: Pre-commit Gate 4 — Submodule-pointer-only commit blocker
#
# Dual-phase TDD: This test functions as both RED and GREEN:
#   RED phase   (Gate 4 absent):  commits proceed unblocked → assertions FAIL → exit 1
#   GREEN phase (Gate 4 present): commits blocked by hook   → assertions PASS → exit 0
#
# Covers: SC-1 (feature branch block), SC-2 (mixed commit allow),
#         SC-5 (pair-* branch block), SC-6 (no .gitmodules pass-through)
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
TEST_TMPDIR=$(mktemp -d "$PROJECT_DIR/tmp/gate4-tdd-XXXXXX")
cleanup() { rm -rf "$TEST_TMPDIR"; }
trap cleanup EXIT

echo "=== TDD: Pre-commit Gate 4 Test ==="
echo ""

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

# === Test 3: Mixed commit (submodule pointer + regular file) ===
echo ""
echo "--- Test 3: Mixed commit (submodule pointer + regular file) ---"
git -C "$PARENT_DIR" reset --hard HEAD~1 > /dev/null 2>&1 || true
git -C "$PARENT_DIR" checkout -q -b feature/test-gate4-mixed

echo "updated3" > "$PARENT_DIR/mysubmodule/file.txt"
git -C "$PARENT_DIR/mysubmodule" add -A
git -C "$PARENT_DIR/mysubmodule" commit -q -m "update3"
git -C "$PARENT_DIR" add mysubmodule

echo "regular content" > "$PARENT_DIR/newfile.txt"
git -C "$PARENT_DIR" add newfile.txt

set +e
git -C "$PARENT_DIR" commit -m "test: mixed commit with submodule pointer + new file" > /dev/null 2>&1
EXIT_3=$?
set -e

if [ "$EXIT_3" -ne 0 ]; then
    echo "  ✗ FAIL: Mixed commit was BLOCKED (exit $EXIT_3)"
    echo "    Gate 4 should allow mixed commits with non-submodule files."
    echo "    Expected: commit allowed (exit 0)"
    OVERALL_RESULT=1
else
    echo "  ✓ PASS: Mixed commit was ALLOWED (exit $EXIT_3)"
fi

# === Test 4: No .gitmodules repo (single-repo pass-through) ===
echo ""
echo "--- Test 4: Commit in repo without .gitmodules ---"
NOMOD_DIR="$TEST_TMPDIR/nomod"
mkdir -p "$NOMOD_DIR"
git init -q "$NOMOD_DIR"
git -C "$NOMOD_DIR" config user.email "test@test.dev"
git -C "$NOMOD_DIR" config user.name "Test"
echo "standalone file" > "$NOMOD_DIR/readme.txt"
git -C "$NOMOD_DIR" checkout -q -b feature/test-gate4-nomod
git -C "$NOMOD_DIR" add -A

# Install same hook (Gate 4 will early-exit because .gitmodules is absent)
cp "$PROJECT_DIR/.opencode/hooks/pre-commit" "$NOMOD_DIR/.git/hooks/pre-commit"
chmod +x "$NOMOD_DIR/.git/hooks/pre-commit"

set +e
git -C "$NOMOD_DIR" commit -m "test: no .gitmodules" > /dev/null 2>&1
EXIT_4=$?
set -e

if [ "$EXIT_4" -ne 0 ]; then
    echo "  ✗ FAIL: Commit was BLOCKED in repo without .gitmodules (exit $EXIT_4)"
    echo "    Gate 4 should not fire when .gitmodules is absent."
    echo "    Expected: commit allowed (exit 0)"
    OVERALL_RESULT=1
else
    echo "  ✓ PASS: Commit allowed in repo without .gitmodules (exit $EXIT_4)"
fi

# === Result ===
echo ""
echo "=== TDD Result ==="
if [ "$OVERALL_RESULT" -ne 0 ]; then
    echo "  RED (exit $OVERALL_RESULT): One or more assertions failed"
    echo "  Gate 4 not fully implemented."
    exit $OVERALL_RESULT
else
    echo "  GREEN (exit 0): All assertions passed"
    echo "  Gate 4 works correctly."
    exit 0
fi
