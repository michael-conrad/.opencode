#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral Enforcement Test: 2264-sc1-per-submodule-trunk-lookup
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Issue: .opencode#2264 — Pre-commit hook uses parent repo's trunk branch name for
# submodule trunk lookup — fails when submodule trunk differs (e.g. SharedPojos uses
# 'main' not 'master').
#
# SC-1: `.opencode/hooks/pre-commit` Gate 2 uses a per-submodule trunk lookup (each
#       submodule's own `HEAD branch:` from `git -C "$sp" remote show origin`) instead
#       of the parent repo's `DEFAULT_BRANCH` for the submodule `REMOTE_SHA` rev-parse.
#
# Evidence type: SC-1 is string — grep the hook for `SUBMODULE_TRUNK` and assert line
# 54 does not use `origin/$DEFAULT_BRANCH`.
#
# RED state: Line 54 currently uses `REMOTE_SHA=$(git -C "$sp" rev-parse
# "origin/$DEFAULT_BRANCH" 2>/dev/null || true)` — deriving the submodule SHA from the
# parent's trunk. The assertions below are RED because the per-submodule `SUBMODULE_TRUNK`
# extraction is absent.
#
# Usage: bash .opencode/tests-v2/test-2264-sc1-per-submodule-trunk-lookup.sh
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
echo "=== SC-1: Gate 2 uses per-submodule trunk lookup (not parent DEFAULT_BRANCH) ==="
echo ""
echo "Target file: $HOOK_FILE"
echo ""

# (a) The hook MUST derive the submodule REMOTE_SHA from a per-submodule
#     SUBMODULE_TRUNK variable extracted from `git -C "$sp" remote show origin`.
if grep -qF "SUBMODULE_TRUNK=\$(git -C \"\$sp\" remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')" "$HOOK_FILE" 2>/dev/null; then
    check_pass "SC-1: line 54 extracts SUBMODULE_TRUNK from the submodule's own HEAD branch"
else
    check_fail "SC-1: line 54 extracts SUBMODULE_TRUNK from the submodule's own HEAD branch" \
        "per-submodule SUBMODULE_TRUNK extraction not found in $HOOK_FILE"
fi

# (b) The hook MUST use SUBMODULE_TRUNK (not DEFAULT_BRANCH) for the submodule
#     REMOTE_SHA rev-parse.
if grep -qF 'REMOTE_SHA=$(git -C "$sp" rev-parse "origin/$SUBMODULE_TRUNK" 2>/dev/null || true)' "$HOOK_FILE" 2>/dev/null; then
    check_pass "SC-1: line 54 uses SUBMODULE_TRUNK for the REMOTE_SHA rev-parse"
else
    check_fail "SC-1: line 54 uses SUBMODULE_TRUNK for the REMOTE_SHA rev-parse" \
        "origin/\$SUBMODULE_TRUNK rev-parse not found in $HOOK_FILE"
fi

# (c) The hook MUST NOT use the parent's DEFAULT_BRANCH for the submodule REMOTE_SHA
#     rev-parse (the bug being fixed).
if grep -qF 'REMOTE_SHA=$(git -C "$sp" rev-parse "origin/$DEFAULT_BRANCH" 2>/dev/null || true)' "$HOOK_FILE" 2>/dev/null; then
    check_fail "SC-1: line 54 does NOT use origin/\$DEFAULT_BRANCH for the submodule rev-parse" \
        "found 'origin/\$DEFAULT_BRANCH' submodule rev-parse in $HOOK_FILE"
else
    check_pass "SC-1: line 54 does NOT use origin/\$DEFAULT_BRANCH for the submodule rev-parse"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-1 (per-submodule trunk lookup) not yet applied."
    echo "Line 54 of .opencode/hooks/pre-commit still derives the submodule REMOTE_SHA"
    echo "from the parent's DEFAULT_BRANCH, causing false-positive stale-pointer blocks"
    echo "when a submodule's trunk differs from the parent's."
    echo ""
    exit 1
fi
exit 0
