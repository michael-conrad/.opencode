#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral Enforcement Test: 2307-sc3-fallback-to-main
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Issue: .opencode#2307 — git-workflow/enforcement/url_validation.sh hardcodes base
# branch 'dev' instead of $DEFAULT_BRANCH.
#
# SC-3: When the remote HEAD branch cannot be determined (e.g. no remote), the base
#       falls back to `main`.
#
# Evidence type: behavioral — the test SOURCES url_validation.sh, DIRECTLY INVOKES
# `construct_compare_url` (as the spec's verification method does) in a repo with NO
# remote configured (so the remote HEAD branch cannot be determined), and asserts the
# produced URL uses `main` as base. This is runtime-output verification of the shell
# function (bash test.sh behavioral testing per the evidence type taxonomy).
#
# RED state: the function runs `set -euo pipefail`. With no remote configured,
# `git remote show origin 2>/dev/null` exits non-zero (128). Because the assignment
# `base="$(git remote show origin ... | sed ...)"` is a command substitution whose
# non-zero exit triggers `set -e`, a DIRECT invocation of `construct_compare_url`
# ABORTS with exit 128 BEFORE reaching the `if [ -z "$base" ]; then base="main"; fi`
# fallback. No URL is produced, so the assertion that the URL uses 'main' as base
# FAILS. The test is RED until the GREEN change makes the fallback reachable under a
# direct `set -euo pipefail` invocation.
#
# NOTE: The test MUST NOT wrap `construct_compare_url` in an `if` condition — doing so
# suppresses `set -e` for that command and masks the abort. The direct invocation is
# required to expose the genuine RED.
#
# Usage: bash .opencode/tests-v2/test-2307-sc3-fallback-to-main.sh
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
echo "=== SC-3: construct_compare_url falls back to 'main' when remote HEAD branch is undeterminable ==="
echo ""
echo "Target file: $URL_VALIDATION_SH"
echo ""

# Set up a work repo with NO remote configured, then invoke construct_compare_url.
# The remote HEAD branch cannot be determined (there is no remote), so SC-3 requires
# the base to fall back to 'main'.
SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

git init -q "$SANDBOX/work"
git -C "$SANDBOX/work" config user.email "test@test.dev"
git -C "$SANDBOX/work" config user.name "Test"
git -C "$SANDBOX/work" commit --allow-empty -q -m "init"

# Confirm the work repo has NO remote configured.
REMOTE_COUNT="$(git -C "$SANDBOX/work" remote 2>/dev/null | wc -l)"
if [ "$REMOTE_COUNT" -eq 0 ]; then
    check_pass "SC-3: sandbox work repo has no remote configured"
else
    check_fail "SC-3: sandbox work repo has no remote configured" \
        "found $REMOTE_COUNT remote(s) (expected 0)"
fi

# DIRECTLY invoke construct_compare_url from within the work repo (no remote) and
# capture the resulting URL. The invocation is NOT wrapped in an `if` guard — doing so
# would suppress `set -e` and mask the RED abort. The capture preserves the function's
# exit code so the abort (exit 128) is observable as the failure.
OUTPUT="$(cd "$SANDBOX/work" && bash -c '
set -euo pipefail
source "$1"
construct_compare_url --owner o --repo r --branch b
echo "rc=$?"
' _ "$URL_VALIDATION_SH" 2>&1)" || true

echo "  (construct_compare_url output: $(echo "$OUTPUT" | tr '\n' ' '))"

URL="$(echo "$OUTPUT" | grep -o 'https://github.com/o/r/compare/[^ ]*\.\.\.b' || true)"
RC="$(echo "$OUTPUT" | grep -o 'rc=[0-9]*' | tail -1 || true)"

if [ "$URL" = "https://github.com/o/r/compare/main...b" ]; then
    check_pass "SC-3: compare URL falls back to 'main' as base when no remote is configured"
else
    check_fail "SC-3: compare URL falls back to 'main' as base when no remote is configured" \
        "got '$URL' (expected 'https://github.com/o/r/compare/main...b' — RED: 'main' fallback unreachable on direct invocation)"
fi

# The function MUST NOT abort before producing the URL (its exit code must be 0).
if [ "$RC" = "rc=0" ]; then
    check_pass "SC-3: construct_compare_url exits 0 (does not abort on missing remote)"
else
    check_fail "SC-3: construct_compare_url exits 0 (does not abort on missing remote)" \
        "got '$RC' (expected 'rc=0' — RED: set -e aborts on failing 'git remote show origin' before 'main' fallback)"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-3 (fallback to 'main' when remote HEAD branch is undeterminable) not yet applied."
    echo "With no remote configured, 'git remote show origin' exits non-zero (128), and under"
    echo "set -euo pipefail the command substitution aborts a direct construct_compare_url"
    echo "invocation before the 'main' fallback assignment is reached. The fallback must be"
    echo "made reachable so the function produces a URL with 'main' as base (exit 0) when"
    echo "no remote is configured."
    echo ""
    exit 1
fi
exit 0
