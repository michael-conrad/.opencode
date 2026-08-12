#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral Enforcement Test: 2264-sc6-two-submodule-verification
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Issue: .opencode#2264 — Pre-commit hook uses parent repo's trunk branch name for
# submodule trunk lookup — fails when submodule trunk differs (e.g. SharedPojos uses
# 'main' not 'master').
#
# SC-6: The stale-pointer check is verified against at least 2 submodules with
#       known-different trunks (`SharedPojos` uses `main`, `Patents` uses `master`).
#
# Evidence type: SC-6 is behavioral — it executes the pre-commit Gate 2 stale-pointer
# check against both a different-trunk submodule (trunk=`main`) and a shared-trunk
# submodule (`master`) and asserts both pass without false positives.
#
# RED state: The hook derives the submodule REMOTE_SHA from the parent's DEFAULT_BRANCH
# (origin/master). The different-trunk submodule's trunk is `main`; it also has a
# non-trunk `master` branch whose tip differs from the trunk tip. The staged pointer is
# at the submodule's own trunk tip (origin/main). The old hook compares the staged
# pointer against origin/master (the non-trunk branch tip), sees a mismatch, and falsely
# BLOCKS. The assertions below are RED because the hook blocks the different-trunk
# submodule.
#
# Usage: bash .opencode/tests-v2/test-2264-sc6-two-submodule-verification.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

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
echo "=== SC-6: Two-submodule verification (different-trunk + shared-trunk) ==="
echo ""
echo "Target file: $HOOK_FILE"
echo ""

# ---------------------------------------------------------------------------
# SC-6 (behavioral): Execute the pre-commit Gate 2 stale-pointer check against BOTH
# a different-trunk submodule (trunk=`main`, parent=`master`) and a shared-trunk
# submodule (`master`). Both staged pointers are at their own trunk tips. The hook
# MUST allow the commit (no false positives).
#
# RED-now: the hook derives REMOTE_SHA from origin/$DEFAULT_BRANCH (origin/master),
# which is the different-trunk submodule's non-trunk branch tip — a mismatch with the
# staged trunk tip → false BLOCK.
# ---------------------------------------------------------------------------

TMP_ROOT="$(mktemp -d "$PROJECT_DIR/tmp/2264-sc6-XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

# --- Set up bare remotes with distinct trunks ---
git init -q --bare "$TMP_ROOT/parent-remote.git"
git init -q --bare "$TMP_ROOT/subA-remote.git"
git init -q --bare "$TMP_ROOT/subB-remote.git"

# --- Submodule A: trunk=main, plus a non-trunk master branch ---
git init -q "$TMP_ROOT/subA"
git -C "$TMP_ROOT/subA" config user.email "test@test.dev"
git -C "$TMP_ROOT/subA" config user.name "Test"
git -C "$TMP_ROOT/subA" checkout -q -b main
echo "subA main content" > "$TMP_ROOT/subA/f.txt"
git -C "$TMP_ROOT/subA" add f.txt
git -C "$TMP_ROOT/subA" commit -qm "subA main trunk"
git -C "$TMP_ROOT/subA" remote add origin "$TMP_ROOT/subA-remote.git"
git -C "$TMP_ROOT/subA" push -q -u origin main
# Non-trunk master branch (matching parent trunk name) with a different tip
git -C "$TMP_ROOT/subA" checkout -q -b master
echo "subA non-trunk master" > "$TMP_ROOT/subA/stale.txt"
git -C "$TMP_ROOT/subA" add stale.txt
git -C "$TMP_ROOT/subA" commit -qm "subA non-trunk master branch"
git -C "$TMP_ROOT/subA" push -q origin master
git -C "$TMP_ROOT/subA" checkout -q main
git --git-dir="$TMP_ROOT/subA-remote.git" symbolic-ref HEAD refs/heads/main

# --- Submodule B: trunk=master (shared with parent) ---
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

# Add both submodules at their own trunk tips
git -C "$TMP_ROOT/parent" -c protocol.file.allow=always submodule add -q "$TMP_ROOT/subA" subA 2>/dev/null || true
git -C "$TMP_ROOT/parent" -c protocol.file.allow=always submodule add -q "$TMP_ROOT/subB" subB 2>/dev/null || true
git -C "$TMP_ROOT/parent" add .gitmodules subA subB 2>/dev/null || true
git -C "$TMP_ROOT/parent" commit -qm "add subA and subB submodules" 2>/dev/null || true

# Create a feature branch (Gate 1 blocks direct trunk commits)
git -C "$TMP_ROOT/parent" checkout -q -b feature/2264-sc6

# Stage both submodule pointers at their own trunk tips
git -C "$TMP_ROOT/parent" add subA subB 2>/dev/null || true

# --- Verify the setup: subA trunk=main, subB trunk=master, parent trunk=master ---
PARENT_TRUNK="$(git -C "$TMP_ROOT/parent" remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')"
SUBA_TRUNK="$(git -C "$TMP_ROOT/parent/subA" remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')"
SUBB_TRUNK="$(git -C "$TMP_ROOT/parent/subB" remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')"
SUBA_STAGED="$(git -C "$TMP_ROOT/parent" ls-files -s subA | awk '{print $2}')"
SUBB_STAGED="$(git -C "$TMP_ROOT/parent" ls-files -s subB | awk '{print $2}')"
SUBA_TIP="$(git -C "$TMP_ROOT/parent/subA" rev-parse "origin/$SUBA_TRUNK" 2>/dev/null || true)"
SUBB_TIP="$(git -C "$TMP_ROOT/parent/subB" rev-parse "origin/$SUBB_TRUNK" 2>/dev/null || true)"

if [ "$PARENT_TRUNK" = "master" ] && [ "$SUBA_TRUNK" = "main" ] && [ "$SUBB_TRUNK" = "master" ]; then
    check_pass "SC-6: setup — parent trunk=master, subA trunk=main, subB trunk=master (known-different trunks)"
else
    check_fail "SC-6: setup — parent trunk=master, subA trunk=main, subB trunk=master (known-different trunks)" \
        "parent='$PARENT_TRUNK', subA='$SUBA_TRUNK', subB='$SUBB_TRUNK'"
fi

if [ "$SUBA_STAGED" = "$SUBA_TIP" ] && [ "$SUBB_STAGED" = "$SUBB_TIP" ]; then
    check_pass "SC-6: setup — both staged pointers are at their own trunk tips"
else
    check_fail "SC-6: setup — both staged pointers are at their own trunk tips" \
        "subA staged='$SUBA_STAGED' tip='$SUBA_TIP'; subB staged='$SUBB_STAGED' tip='$SUBB_TIP'"
fi

# --- Run the actual pre-commit hook Gate 2 stale-pointer check ---
set +e
(cd "$TMP_ROOT/parent" && bash "$HOOK_FILE") > "$TMP_ROOT/hook.out" 2>&1
HOOK_EXIT=$?
set -e

if [ "$HOOK_EXIT" -eq 0 ]; then
    check_pass "SC-6: hook allows the commit — both submodules pass without false positives"
else
    check_fail "SC-6: hook allows the commit — both submodules pass without false positives" \
        "hook exited $HOOK_EXIT (blocked). Output: $(tr '\n' ' ' < "$TMP_ROOT/hook.out")"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-6 (two-submodule verification) not yet fixed."
    echo "The hook derives the submodule REMOTE_SHA from the parent's DEFAULT_BRANCH"
    echo "(origin/master), which is the different-trunk submodule's non-trunk branch tip"
    echo "— a mismatch with the staged trunk tip → false BLOCK."
    echo ""
    exit 1
fi
exit 0
