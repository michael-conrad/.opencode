#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral Enforcement Test: 2264-sc4-shared-trunk-submodule
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Issue: .opencode#2264 — Pre-commit hook uses parent repo's trunk branch name for
# submodule trunk lookup — fails when submodule trunk differs (e.g. SharedPojos uses
# 'main' not 'master').
#
# SC-4: A submodule sharing the parent's trunk (e.g. `master`) continues to pass the
#       stale-pointer check without regression.
#
# Evidence type: SC-4 is behavioral — it executes the pre-commit Gate 2 stale-pointer
# check against a real submodule sharing the parent's trunk and asserts the hook allows
# the commit when the staged pointer is at the shared trunk tip.
#
# RED state: This test establishes a baseline — the shared-trunk submodule passes both
# before and after the change. The assertions below are GREEN in both states (no
# regression). The test guards against a regression where the per-submodule lookup
# breaks the common shared-trunk case.
#
# Usage: bash .opencode/tests-v2/test-2264-sc4-shared-trunk-submodule.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (regression).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

HOOK_FILE="$PROJECT_DIR/.opencode/hooks/pre-commit"

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    local label="$1"
    echo "  PASS: $label"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    local label="$1"
    local detail="$2"
    echo "  FAIL: $label — $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo ""
echo "=== SC-4: Shared-trunk submodule (master) no regression ==="
echo ""
echo "Target file: $HOOK_FILE"
echo ""

# ---------------------------------------------------------------------------
# SC-4 (behavioral): Execute the pre-commit Gate 2 stale-pointer check against a
# real submodule sharing the parent's trunk (`master`). The staged pointer is at the
# shared trunk tip. The hook MUST allow the commit (no regression).
# ---------------------------------------------------------------------------

TMP_ROOT="$(mktemp -d "$PROJECT_DIR/tmp/2264-sc4-XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

# --- Set up bare remotes with shared trunk (master) ---
git init -q --bare "$TMP_ROOT/parent-remote.git"
git init -q --bare "$TMP_ROOT/subB-remote.git"

# --- Submodule repo: trunk=master (shared with parent) ---
git init -q "$TMP_ROOT/subB"
git -C "$TMP_ROOT/subB" config user.email "test@test.dev"
git -C "$TMP_ROOT/subB" config user.name "Test"
git -C "$TMP_ROOT/subB" checkout -q -b master
echo "subB master content" > "$TMP_ROOT/subB/f.txt"
git -C "$TMP_ROOT/subB" add f.txt
git -C "$TMP_ROOT/subB" commit -qm "subB master trunk"
git -C "$TMP_ROOT/subB" remote add origin "$TMP_ROOT/subB-remote.git"
git -C "$TMP_ROOT/subB" push -q -u origin master
git --git-dir="$TMP_ROOT/subB-remote.git" symbolic-ref HEAD refs/heads/master

# --- Parent repo: trunk=master ---
git init -q "$TMP_ROOT/parent"
git -C "$TMP_ROOT/parent" config user.email "test@test.dev"
git -C "$TMP_ROOT/parent" config user.name "Test"
git -C "$TMP_ROOT/parent" checkout -q -b master
echo "parent master content" > "$TMP_ROOT/parent/p.txt"
git -C "$TMP_ROOT/parent" add p.txt
git -C "$TMP_ROOT/parent" commit -qm "parent master trunk"
git -C "$TMP_ROOT/parent" remote add origin "$TMP_ROOT/parent-remote.git"
git -C "$TMP_ROOT/parent" push -q -u origin master
git --git-dir="$TMP_ROOT/parent-remote.git" symbolic-ref HEAD refs/heads/master

# Add the submodule at its own trunk tip (origin/master)
git -C "$TMP_ROOT/parent" -c protocol.file.allow=always submodule add -q "$TMP_ROOT/subB" subB 2>/dev/null || true
git -C "$TMP_ROOT/parent" add .gitmodules subB 2>/dev/null || true
git -C "$TMP_ROOT/parent" commit -qm "add subB submodule" 2>/dev/null || true

# Create a feature branch (Gate 1 blocks direct trunk commits)
git -C "$TMP_ROOT/parent" checkout -q -b feature/2264-sc4

# Stage the submodule pointer at its own trunk tip (origin/master)
git -C "$TMP_ROOT/parent" add subB 2>/dev/null || true

# --- Verify the setup: submodule trunk=master, parent trunk=master (shared) ---
PARENT_TRUNK="$(git -C "$TMP_ROOT/parent" remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')"
SUBMODULE_TRUNK="$(git -C "$TMP_ROOT/parent/subB" remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')"
STAGED_SHA="$(git -C "$TMP_ROOT/parent" ls-files -s subB | awk '{print $2}')"
SUBMODULE_TRUNK_TIP="$(git -C "$TMP_ROOT/parent/subB" rev-parse "origin/$SUBMODULE_TRUNK" 2>/dev/null || true)"

if [ "$PARENT_TRUNK" = "master" ] && [ "$SUBMODULE_TRUNK" = "master" ]; then
    check_pass "SC-4: setup — parent trunk=master, submodule trunk=master (shared trunk)"
else
    check_fail "SC-4: setup — parent trunk=master, submodule trunk=master (shared trunk)" \
        "parent trunk='$PARENT_TRUNK', submodule trunk='$SUBMODULE_TRUNK'"
fi

if [ "$STAGED_SHA" = "$SUBMODULE_TRUNK_TIP" ]; then
    check_pass "SC-4: setup — staged pointer is at the shared trunk tip (origin/master)"
else
    check_fail "SC-4: setup — staged pointer is at the shared trunk tip (origin/master)" \
        "staged='$STAGED_SHA', trunk tip='$SUBMODULE_TRUNK_TIP'"
fi

# --- Run the actual pre-commit hook Gate 2 stale-pointer check ---
set +e
(cd "$TMP_ROOT/parent" && bash "$HOOK_FILE") > "$TMP_ROOT/hook.out" 2>&1
HOOK_EXIT=$?
set -e

if [ "$HOOK_EXIT" -eq 0 ]; then
    check_pass "SC-4: hook allows the commit when the staged pointer is at the shared trunk tip (no regression)"
else
    check_fail "SC-4: hook allows the commit when the staged pointer is at the shared trunk tip (no regression)" \
        "hook exited $HOOK_EXIT (blocked). Output: $(tr '\n' ' ' < "$TMP_ROOT/hook.out")"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "REGRESSION: SC-4 (shared-trunk submodule no regression) failed."
    echo "The per-submodule lookup broke the common shared-trunk case."
    echo ""
    exit 1
fi
exit 0
