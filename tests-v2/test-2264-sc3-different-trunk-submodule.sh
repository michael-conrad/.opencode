#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral Enforcement Test: 2264-sc3-different-trunk-submodule
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Issue: .opencode#2264 — Pre-commit hook uses parent repo's trunk branch name for
# submodule trunk lookup — fails when submodule trunk differs (e.g. SharedPojos uses
# 'main' not 'master').
#
# SC-3: A submodule whose trunk differs from the parent's trunk (e.g. SharedPojos
#       trunk=`main`, parent trunk=`master`) is no longer falsely flagged as stale when
#       its staged pointer is at its own trunk tip.
#
# Evidence type: SC-3 is behavioral — it executes the pre-commit Gate 2 stale-pointer
# check against a real submodule with a known-different trunk and asserts the hook
# allows the commit when the staged pointer is at the submodule's actual trunk tip.
#
# RED state: The hook derives the submodule REMOTE_SHA from the parent's DEFAULT_BRANCH
# (origin/master). The submodule's trunk is `main`; it also has a non-trunk `master`
# branch whose tip differs from the trunk tip. The staged pointer is at the submodule's
# own trunk tip (origin/main). The old hook compares the staged pointer against
# origin/master (the non-trunk branch tip), sees a mismatch, and falsely BLOCKS. The
# assertions below are RED because the hook blocks the commit.
#
# Usage: bash .opencode/tests-v2/test-2264-sc3-different-trunk-submodule.sh
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
echo "=== SC-3: Different-trunk submodule (trunk=main, parent=master) not falsely flagged ==="
echo ""
echo "Target file: $HOOK_FILE"
echo ""

# ---------------------------------------------------------------------------
# SC-3 (behavioral): Execute the pre-commit Gate 2 stale-pointer check against a
# real submodule whose trunk differs from the parent's trunk. The submodule's trunk
# is `main`; it also has a non-trunk `master` branch (matching the parent trunk name)
# whose tip differs from the trunk tip. The staged pointer is at the submodule's own
# trunk tip (origin/main). The hook MUST allow the commit.
#
# RED-now: the hook derives REMOTE_SHA from origin/$DEFAULT_BRANCH (origin/master),
# which is the submodule's non-trunk branch tip — a mismatch with the staged trunk
# tip → false BLOCK.
# ---------------------------------------------------------------------------

TMP_ROOT="$(mktemp -d "$PROJECT_DIR/tmp/2264-sc3-XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

# --- Set up bare remotes with distinct trunks ---
git init -q --bare "$TMP_ROOT/parent-remote.git"
git init -q --bare "$TMP_ROOT/subA-remote.git"

# --- Submodule repo: trunk=main, plus a non-trunk master branch ---
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
# Set the submodule remote HEAD to main (its trunk)
git --git-dir="$TMP_ROOT/subA-remote.git" symbolic-ref HEAD refs/heads/main

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

# Add the submodule at its own trunk tip (origin/main)
git -C "$TMP_ROOT/parent" -c protocol.file.allow=always submodule add -q "$TMP_ROOT/subA" subA 2>/dev/null || true
git -C "$TMP_ROOT/parent" add .gitmodules subA 2>/dev/null || true
git -C "$TMP_ROOT/parent" commit -qm "add subA submodule" 2>/dev/null || true

# Create a feature branch (Gate 1 blocks direct trunk commits)
git -C "$TMP_ROOT/parent" checkout -q -b feature/2264-sc3

# Stage the submodule pointer at its own trunk tip (origin/main)
git -C "$TMP_ROOT/parent" add subA 2>/dev/null || true

# --- Verify the setup: submodule trunk=main, parent trunk=master ---
PARENT_TRUNK="$(git -C "$TMP_ROOT/parent" remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')"
SUBMODULE_TRUNK="$(git -C "$TMP_ROOT/parent/subA" remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')"
STAGED_SHA="$(git -C "$TMP_ROOT/parent" ls-files -s subA | awk '{print $2}')"
SUBMODULE_TRUNK_TIP="$(git -C "$TMP_ROOT/parent/subA" rev-parse "origin/$SUBMODULE_TRUNK" 2>/dev/null || true)"

if [ "$PARENT_TRUNK" = "master" ] && [ "$SUBMODULE_TRUNK" = "main" ]; then
    check_pass "SC-3: setup — parent trunk=master, submodule trunk=main (known-different trunks)"
else
    check_fail "SC-3: setup — parent trunk=master, submodule trunk=main (known-different trunks)" \
        "parent trunk='$PARENT_TRUNK', submodule trunk='$SUBMODULE_TRUNK'"
fi

if [ "$STAGED_SHA" = "$SUBMODULE_TRUNK_TIP" ]; then
    check_pass "SC-3: setup — staged pointer is at the submodule's own trunk tip (origin/main)"
else
    check_fail "SC-3: setup — staged pointer is at the submodule's own trunk tip (origin/main)" \
        "staged='$STAGED_SHA', trunk tip='$SUBMODULE_TRUNK_TIP'"
fi

# --- Run the actual pre-commit hook Gate 2 stale-pointer check ---
# The hook runs from the parent repo working directory. Gate 1 blocks direct trunk
# commits, so we are on a feature branch. Gate 2 iterates submodules and blocks if
# the staged pointer != the submodule's remote trunk tip.
set +e
(cd "$TMP_ROOT/parent" && bash "$HOOK_FILE") > "$TMP_ROOT/hook.out" 2>&1
HOOK_EXIT=$?
set -e

if [ "$HOOK_EXIT" -eq 0 ]; then
    check_pass "SC-3: hook allows the commit when the staged pointer is at the submodule's own trunk tip"
else
    check_fail "SC-3: hook allows the commit when the staged pointer is at the submodule's own trunk tip" \
        "hook exited $HOOK_EXIT (blocked). Output: $(tr '\n' ' ' < "$TMP_ROOT/hook.out")"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-3 (different-trunk submodule not falsely flagged) not yet fixed."
    echo "The hook derives the submodule REMOTE_SHA from the parent's DEFAULT_BRANCH"
    echo "(origin/master), which is the submodule's non-trunk branch tip — a mismatch"
    echo "with the staged trunk tip → false BLOCK."
    echo ""
    exit 1
fi
exit 0
