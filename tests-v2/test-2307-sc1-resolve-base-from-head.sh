#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral Enforcement Test: 2307-sc1-resolve-base-from-head
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Issue: .opencode#2307 — git-workflow/enforcement/url_validation.sh hardcodes base
# branch 'dev' instead of $DEFAULT_BRANCH.
#
# SC-1: `construct_compare_url()` resolves the base from the remote HEAD branch
#       (e.g. `master`) instead of the hardcoded `dev`, producing a compare URL with
#       the resolved default branch as base.
#
# Evidence type: behavioral — the test SOURCES url_validation.sh, sets up a controlled
# git remote whose HEAD branch is `master`, INVOKES `construct_compare_url`, and asserts
# the produced URL uses `master` as base. This is runtime-output verification of the
# shell function (bash test.sh behavioral testing per the evidence type taxonomy).
#
# RED state: line 18 currently hardcodes `local base="dev"`. Invoking
# `construct_compare_url --owner o --repo r --branch b` in a repo whose remote HEAD
# branch is `master` produces `https://github.com/o/r/compare/dev...b` (base 'dev'),
# so the assertion that the URL uses 'master' as base FAILS. The test is RED until
# the GREEN change replaces the hardcoded default with dynamic `$DEFAULT_BRANCH`
# resolution.
#
# Usage: bash .opencode/tests-v2/test-2307-sc1-resolve-base-from-head.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

URL_VALIDATION_SH="$PROJECT_DIR/skills/git-workflow/enforcement/url_validation.sh"

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
echo "=== SC-1: construct_compare_url resolves base from remote HEAD branch, not 'dev' ==="
echo ""
echo "Target file: $URL_VALIDATION_SH"
echo ""

# Set up a controlled git remote whose HEAD branch is `master`, then invoke
# construct_compare_url and assert the produced URL uses `master` as base.
SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

git init --bare -b master "$SANDBOX/remote.git" >/dev/null 2>&1
git init -q "$SANDBOX/work"
git -C "$SANDBOX/work" config user.email "test@test.dev"
git -C "$SANDBOX/work" config user.name "Test"
git -C "$SANDBOX/work" commit --allow-empty -q -m "init"
git -C "$SANDBOX/work" branch -M master
git -C "$SANDBOX/work" remote add origin "$SANDBOX/remote.git"
git -C "$SANDBOX/remote.git" symbolic-ref HEAD refs/heads/master
git -C "$SANDBOX/work" push -q -u origin master

# Verify the sandbox remote HEAD branch resolves to master.
HEAD_BRANCH="$(git -C "$SANDBOX/work" remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')"
if [ "$HEAD_BRANCH" = "master" ]; then
    check_pass "SC-1: sandbox remote HEAD branch resolves to 'master'"
else
    check_fail "SC-1: sandbox remote HEAD branch resolves to 'master'" \
        "got '$HEAD_BRANCH' (expected 'master')"
fi

# Invoke construct_compare_url from within the work repo and capture the URL.
URL="$(cd "$SANDBOX/work" && bash -c '
set -euo pipefail
source "$1"
construct_compare_url --owner o --repo r --branch b
' _ "$URL_VALIDATION_SH" 2>&1)" || true

if [ "$URL" = "https://github.com/o/r/compare/master...b" ]; then
    check_pass "SC-1: compare URL uses resolved default branch 'master' as base"
else
    check_fail "SC-1: compare URL uses resolved default branch 'master' as base" \
        "got '$URL' (expected 'https://github.com/o/r/compare/master...b' — RED: base hardcoded to 'dev')"
fi

# The base must NOT be the hardcoded 'dev'.
if [ "$URL" = "https://github.com/o/r/compare/dev...b" ]; then
    check_fail "SC-1: compare URL does NOT use hardcoded 'dev' as base" \
        "got '$URL' — base is still hardcoded to 'dev' (RED)"
else
    check_pass "SC-1: compare URL does NOT use hardcoded 'dev' as base"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-1 (resolve base from remote HEAD branch) not yet applied."
    echo "Line 18 of .opencode/skills/git-workflow/enforcement/url_validation.sh still"
    echo "hardcodes 'local base=\"dev\"', so the compare URL targets the non-existent 'dev'"
    echo "branch instead of the remote HEAD branch (master)."
    echo ""
    exit 1
fi
exit 0
