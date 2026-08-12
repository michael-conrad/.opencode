#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral Enforcement Test: 2264-sc2-parent-trunk-fallback
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Issue: .opencode#2264 — Pre-commit hook uses parent repo's trunk branch name for
# submodule trunk lookup — fails when submodule trunk differs (e.g. SharedPojos uses
# 'main' not 'master').
#
# SC-2: The hook falls back to the parent's trunk (`DEFAULT_BRANCH`) only when the
#       submodule trunk lookup fails, where "lookup fails" is defined exhaustively as:
#       (a) `git -C "$sp" remote show origin` produces no `HEAD branch:` line,
#       (b) the command returns a non-zero exit status,
#       (c) `SUBMODULE_TRUNK` is empty after extraction, or
#       (d) the sed extraction matches zero lines.
#
# Evidence type: SC-2 is string — grep the hook for the exact fallback line and assert
# it fires only when `SUBMODULE_TRUNK` is empty after the extraction.
#
# RED state: The fallback `[ -z "$SUBMODULE_TRUNK" ] && SUBMODULE_TRUNK="$DEFAULT_BRANCH"`
# is absent. The assertions below are RED because the fallback is not present.
#
# Usage: bash .opencode/tests-v2/test-2264-sc2-parent-trunk-fallback.sh
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
echo "=== SC-2: Parent-trunk fallback on submodule trunk lookup failure ==="
echo ""
echo "Target file: $HOOK_FILE"
echo ""

# (a) The hook MUST contain the exact fallback assignment that resolves an empty
#     SUBMODULE_TRUNK to DEFAULT_BRANCH.
if grep -qF '[ -z "$SUBMODULE_TRUNK" ] && SUBMODULE_TRUNK="$DEFAULT_BRANCH"' "$HOOK_FILE" 2>/dev/null; then
    check_pass "SC-2: fallback assignment present"
else
    check_fail "SC-2: fallback assignment present" \
        "fallback '[ -z \"\$SUBMODULE_TRUNK\" ] && SUBMODULE_TRUNK=\"\$DEFAULT_BRANCH\"' not found in $HOOK_FILE"
fi

# (b) The fallback MUST fire only on an empty SUBMODULE_TRUNK (the -z test), not
#     unconditionally. Verify the -z guard is present.
if grep -qF '[ -z "$SUBMODULE_TRUNK" ]' "$HOOK_FILE" 2>/dev/null; then
    check_pass "SC-2: fallback fires only on empty SUBMODULE_TRUNK (-z guard)"
else
    check_fail "SC-2: fallback fires only on empty SUBMODULE_TRUNK (-z guard)" \
        "-z guard not found in $HOOK_FILE"
fi

# (c) The fallback MUST assign DEFAULT_BRANCH (the parent trunk) as the value.
if grep -qF 'SUBMODULE_TRUNK="$DEFAULT_BRANCH"' "$HOOK_FILE" 2>/dev/null; then
    check_pass "SC-2: fallback assigns DEFAULT_BRANCH"
else
    check_fail "SC-2: fallback assigns DEFAULT_BRANCH" \
        "SUBMODULE_TRUNK=\"\$DEFAULT_BRANCH\" assignment not found in $HOOK_FILE"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-2 (parent-trunk fallback) not yet applied."
    echo "The fallback '[ -z \"\$SUBMODULE_TRUNK\" ] && SUBMODULE_TRUNK=\"\$DEFAULT_BRANCH\"'"
    echo "is absent from .opencode/hooks/pre-commit."
    echo ""
    exit 1
fi
exit 0
