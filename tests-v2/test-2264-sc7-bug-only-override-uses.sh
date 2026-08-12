#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral Enforcement Test: 2264-sc7-bug-only-override-uses
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Issue: .opencode#2264 — Pre-commit hook uses parent repo's trunk branch name for
# submodule trunk lookup — fails when submodule trunk differs (e.g. SharedPojos uses
# 'main' not 'master').
#
# SC-7: Every `SKIP_STALE_POINTER_CHECK=1` invocation in the `.opencode` repository is
#       either (a) absent from all files, or (b) if present, accompanied in the same
#       file by a comment that names a non-bug rationale (release capture of an
#       un-merged branch tip or deliberate override) and does not reference the
#       false-positive bug described in this spec's Problem section.
#
# Evidence type: SC-7 is string — grep -r for `SKIP_STALE_POINTER_CHECK=1` across the
# `.opencode` repository and assert no invocation is attributable solely to this bug.
#
# RED state: The enumeration of `SKIP_STALE_POINTER_CHECK=1` invocations is not yet
# verified. The assertions below are RED if any invocation is attributable solely to
# the false-positive trunk-mismatch bug.
#
# Usage: bash .opencode/tests-v2/test-2264-sc7-bug-only-override-uses.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

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
echo "=== SC-7: No SKIP_STALE_POINTER_CHECK=1 invocation attributable solely to this bug ==="
echo ""
echo "Search scope: $PROJECT_DIR/.opencode (excluding .issues/, tmp/, .git/)"
echo ""

# ---------------------------------------------------------------------------
# SC-7 (string): grep -r for `SKIP_STALE_POINTER_CHECK=1` across the `.opencode`
# repository. Assert no invocation is attributable solely to the false-positive
# trunk-mismatch bug. Attribution is determined by checking each occurrence's
# adjacent comment for a reference to the false-positive trunk-mismatch bug.
#
# The hook's own definition of the override (lines 34-35, 66) is the guard's
# documented deliberate-action path — it is NOT an invocation attributable to the bug.
# ---------------------------------------------------------------------------

# Enumerate all SKIP_STALE_POINTER_CHECK=1 invocations in the repository, excluding
# the hook's own definition, this enforcement test file, .issues/, tmp/, and .git/.
INVOCATIONS="$(grep -rn "SKIP_STALE_POINTER_CHECK=1" "$PROJECT_DIR/.opencode" \
    --include="*.sh" --include="*.md" --include="*.ts" --include="*.py" 2>/dev/null \
    | grep -v "/.git/" | grep -v "/tmp/" | grep -v "/.issues/" \
    | grep -v "hooks/pre-commit" \
    | grep -v "test-2264-sc7-bug-only-override-uses.sh" || true)"

if [ -z "$INVOCATIONS" ]; then
    check_pass "SC-7: no SKIP_STALE_POINTER_CHECK=1 invocation exists in the .opencode repository (criterion a: absent)"
else
    # Check each invocation's adjacent comment for a reference to the false-positive
    # trunk-mismatch bug. If any references the bug, it is attributable solely to it.
    BUG_ATTRIBUTED=0
    while IFS= read -r line; do
        file="${line%%:*}"
        if grep -qiE 'false.?positive|trunk.?mismatch|trunk differs|different trunk|SharedPojos|stale.?pointer.*bug' "$file" 2>/dev/null; then
            echo "  BUG-ATTRIBUTED: $line (file references the false-positive trunk-mismatch bug)" >&2
            BUG_ATTRIBUTED=1
        fi
    done <<< "$INVOCATIONS"

    if [ "$BUG_ATTRIBUTED" -eq 0 ]; then
        check_pass "SC-7: SKIP_STALE_POINTER_CHECK=1 invocations present but none attributable solely to this bug"
    else
        check_fail "SC-7: no SKIP_STALE_POINTER_CHECK=1 invocation attributable solely to this bug" \
            "found invocation(s) referencing the false-positive trunk-mismatch bug"
    fi
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-7 (bug-only override uses) not yet remediated."
    echo "A SKIP_STALE_POINTER_CHECK=1 invocation remains attributable solely to the"
    echo "false-positive trunk-mismatch bug."
    echo ""
    exit 1
fi
exit 0
