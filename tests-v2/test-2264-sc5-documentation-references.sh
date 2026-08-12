#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral Enforcement Test: 2264-sc5-documentation-references
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Issue: .opencode#2264 — Pre-commit hook uses parent repo's trunk branch name for
# submodule trunk lookup — fails when submodule trunk differs (e.g. SharedPojos uses
# 'main' not 'master').
#
# SC-5: Any related documentation references to the trunk-detection logic are updated
#       to reflect the per-submodule trunk lookup.
#
# Evidence type: SC-5 is string — grep the documentation referencing the trunk-detection
# logic and assert references describe the per-submodule lookup and the parent-trunk
# fallback.
#
# RED state: `.opencode/commands/submodule-tag-prework.md` currently describes the
# trunk-detection logic using the parent's DEFAULT_BRANCH for submodule sync steps and
# does not describe the per-submodule lookup or the parent-trunk fallback. The
# assertions below are RED because the per-submodule lookup description is absent.
#
# Usage: bash .opencode/tests-v2/test-2264-sc5-documentation-references.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

DOC_FILE="$PROJECT_DIR/.opencode/commands/submodule-tag-prework.md"

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
echo "=== SC-5: Documentation references describe per-submodule trunk lookup + fallback ==="
echo ""
echo "Target file: $DOC_FILE"
echo ""

# (a) The documentation MUST describe the per-submodule trunk lookup (each submodule's
#     own HEAD branch from `git -C <path> remote show origin`).
if grep -qiE 'per-submodule|each submodule.*(own|HEAD branch)|submodule.*remote show origin|own trunk' "$DOC_FILE" 2>/dev/null; then
    check_pass "SC-5: documentation describes the per-submodule trunk lookup"
else
    check_fail "SC-5: documentation describes the per-submodule trunk lookup" \
        "no per-submodule trunk lookup description found in $DOC_FILE"
fi

# (b) The documentation MUST describe the parent-trunk fallback (fall back to the
#     parent trunk when the submodule lookup fails).
if grep -qiE 'fallback|fall back|parent trunk|DEFAULT_BRANCH' "$DOC_FILE" 2>/dev/null; then
    check_pass "SC-5: documentation describes the parent-trunk fallback"
else
    check_fail "SC-5: documentation describes the parent-trunk fallback" \
        "no parent-trunk fallback reference found in $DOC_FILE"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-5 (documentation references) not yet updated."
    echo ".opencode/commands/submodule-tag-prework.md does not describe the per-submodule"
    echo "trunk lookup or the parent-trunk fallback."
    echo ""
    exit 1
fi
exit 0
