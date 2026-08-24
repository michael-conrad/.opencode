#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral Enforcement Test: 2307-sc2-base-override
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Issue: .opencode#2307 — git-workflow/enforcement/url_validation.sh hardcodes base
# branch 'dev' instead of $DEFAULT_BRANCH.
#
# SC-2: An explicit `--base` argument overrides the dynamically resolved default branch.
#
# Evidence type: behavioral — the test SOURCES url_validation.sh, sets up a controlled
# git remote whose HEAD branch is `master`, INVOKES `construct_compare_url --base dev`,
# and asserts the produced URL uses `dev` as base (NOT the remote HEAD branch `master`).
# This is runtime-output verification of the shell function (bash test.sh behavioral
# testing per the evidence type taxonomy).
#
# RED state: if the `--base` override were removed (or ignored), the function would
# resolve the base dynamically to the remote HEAD branch `master`, producing
# `https://github.com/o/r/compare/master...b`. The assertion that the URL uses 'dev'
# as base would FAIL. The test is RED until the `--base) base="$2"` assignment is
# preserved so the explicit override wins over dynamic resolution.
#
# Usage: bash .opencode/tests-v2/test-2307-sc2-base-override.sh
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
echo "=== SC-2: explicit --base override wins over dynamic resolution ==="
echo ""
echo "Target file: $URL_VALIDATION_SH"
echo ""

# Set up a controlled git remote whose HEAD branch is `master`, so that WITHOUT the
# --base override the function would resolve the base to `master`. The explicit
# `--base dev` must override this dynamic resolution and produce a URL with 'dev'
# as base.
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

# Verify the sandbox remote HEAD branch resolves to master (the dynamic default).
HEAD_BRANCH="$(git -C "$SANDBOX/work" remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')"
if [ "$HEAD_BRANCH" = "master" ]; then
    check_pass "SC-2: sandbox remote HEAD branch resolves to 'master' (dynamic default)"
else
    check_fail "SC-2: sandbox remote HEAD branch resolves to 'master' (dynamic default)" \
        "got '$HEAD_BRANCH' (expected 'master')"
fi

# Invoke construct_compare_url with an explicit --base dev and capture the URL.
URL="$(cd "$SANDBOX/work" && bash -c '
set -euo pipefail
source "$1"
construct_compare_url --owner o --repo r --branch b --base dev
' _ "$URL_VALIDATION_SH" 2>&1)" || true

if [ "$URL" = "https://github.com/o/r/compare/dev...b" ]; then
    check_pass "SC-2: explicit --base 'dev' overrides dynamic resolution, URL uses 'dev' as base"
else
    check_fail "SC-2: explicit --base 'dev' overrides dynamic resolution, URL uses 'dev' as base" \
        "got '$URL' (expected 'https://github.com/o/r/compare/dev...b' — RED: --base override ignored, base resolved to 'master')"
fi

# The base MUST NOT be the dynamically resolved remote HEAD branch (master).
if [ "$URL" = "https://github.com/o/r/compare/master...b" ]; then
    check_fail "SC-2: --base override does NOT fall through to dynamic resolution" \
        "got '$URL' — base resolved to 'master' instead of the explicit 'dev' (RED)"
else
    check_pass "SC-2: --base override does NOT fall through to dynamic resolution"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-2 (explicit --base override) not yet applied."
    echo "The --base) base=\"\$2\" assignment must be preserved so the explicit override"
    echo "wins over the dynamically resolved remote HEAD branch."
    echo ""
    exit 1
fi
exit 0
