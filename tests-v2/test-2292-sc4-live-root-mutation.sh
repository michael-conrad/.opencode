#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: no live-root git-mutation patterns in the harness
# Maps to SC-4 from issue #2292: a content-verification enforcement test SHALL
# assert the harness contains no git-mutating operation that can target the live
# project root (no `-C "$PROJECT_DIR"` mutation, no `${TEST_PROJECT:-$project_root}`
# fallback, no unguarded bare git mutation).
#
# RED phase: the live-root mutation patterns are present in the harness source —
# this test FAILS.
# GREEN phase: after the SC-1/2/3 harness fixes remove the fallback, add the
# live-root guard, and relocate remote wiring, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2292-sc4-live-root-mutation.sh
# Exit: 0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

HELPERS_FILE="$PROJECT_DIR/.opencode/tests-v2/behaviors/helpers.sh"
WITH_TEST_HOME_FILE="$PROJECT_DIR/.opencode/tests-v2/with-test-home"

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
    echo "  FAIL: $label -- $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo ""
echo "=== No live-root git-mutation patterns -- SC-4 (#2292) ==="
echo ""
echo "Target files: $HELPERS_FILE"
echo "              $WITH_TEST_HOME_FILE"
echo ""

# ---------------------------------------------------------------------------
# SC-4: The harness SHALL contain no git-mutating operation that can target the
# live project root. Three forbidden pattern classes:
#   (a) `${TEST_PROJECT:-$project_root}` fallback — an unset $TEST_PROJECT must
#       never resolve to the live repo for a git-mutating operation.
#   (b) `git -C "$PROJECT_DIR"` / `-C "$PARENT_REPO_DIR"` / `-C "$project_root"`
#       followed by a mutating subcommand (remote, push, add, commit, reset,
#       checkout, branch, merge, rebase, rm, clean, restore, switch, tag, stash).
#   (c) an unguarded bare `git <mutating-subcommand>` (no -C) that could run with
#       CWD in the live repo.
# ---------------------------------------------------------------------------

# (a) No ${TEST_PROJECT:-$project_root} fallback in the harness.
if grep -rnF -- '${TEST_PROJECT:-$project_root}' "$HELPERS_FILE" "$WITH_TEST_HOME_FILE" 2>/dev/null; then
    check_fail "SC-4: no TEST_PROJECT fallback to project_root" \
        "found '${TEST_PROJECT:-\$project_root}' in the harness"
else
    check_pass "SC-4: no TEST_PROJECT fallback to project_root"
fi

# (b) No mutating `git -C "$PROJECT_DIR"` / `-C "$PARENT_REPO_DIR"` / `-C "$project_root"`.
MUTATING_SUBCOMMANDS='remote|push|add |commit|reset|checkout|branch|merge|rebase|rm |clean|restore|switch|tag|stash'
LIVE_ROOT_MUTATION=$(grep -nE "git -C \"\\\$(PARENT_REPO_DIR|PROJECT_DIR|project_root)\" ($MUTATING_SUBCOMMANDS)" \
    "$HELPERS_FILE" "$WITH_TEST_HOME_FILE" 2>/dev/null || true)
if [ -n "$LIVE_ROOT_MUTATION" ]; then
    check_fail "SC-4: no mutating git -C targeting a live-root variable" \
        "found: $LIVE_ROOT_MUTATION"
else
    check_pass "SC-4: no mutating git -C targeting a live-root variable"
fi

# (c) No unguarded bare `git <mutating-subcommand>` (no -C) in the harness.
BARE_MUTATION=$(grep -nE "^\s*git ($MUTATING_SUBCOMMANDS)" \
    "$HELPERS_FILE" "$WITH_TEST_HOME_FILE" 2>/dev/null || true)
if [ -n "$BARE_MUTATION" ]; then
    check_fail "SC-4: no unguarded bare git mutation" \
        "found: $BARE_MUTATION"
else
    check_pass "SC-4: no unguarded bare git mutation"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
