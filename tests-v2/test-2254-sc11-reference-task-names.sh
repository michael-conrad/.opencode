#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-11 — stale reference-doc task names
# updated to actual task names.
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-15-reference-task-names — SC-11 (string),
#        `.opencode/reference/skill-card-description-standards.md`.
#
# SC-11 (string): Stale reference-doc task names (inspect/decompose/write/check/
#   file) in reference/skill-card-description-standards.md SHALL be updated to
#   actual task names (analyze/create/validate/revise).
#
# RED state: The reference doc's "Single skill, multiple task cards" example
#   table and the §7 Workflows example still reference the stale pre-rename
#   spec-creation task names (inspect, decompose, write, check, file) and the
#   non-existent task-card files (inspect.md, decompose.md). The assertions below
#   FAIL on this content. GREEN updates the stale names to the actual task names
#   (analyze, create, validate, revise) and the real task-card files
#   (analyze.md, create.md, validate.md, revise.md).
#
# Evidence type: SC-11 is a `string` SC. This content-verification test greps
#   reference/skill-card-description-standards.md for the stale task names and
#   the actual task names. It is the primary gate for this content-only SC (no
#   runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc11-reference-task-names.sh
# Exit:  0 if stale names are absent and actual names are present (GREEN),
#        1 if any stale name remains or an actual name is missing (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

REF_FILE="$PROJECT_DIR/.opencode/reference/skill-card-description-standards.md"

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
echo "=== SC-11 — stale reference-doc task names updated to actual task names (Spec .opencode#2254) ==="
echo ""
echo "Target file: $REF_FILE"
echo ""

if [ ! -f "$REF_FILE" ]; then
    check_fail "SC-11: target file exists" "reference/skill-card-description-standards.md not found"
    echo ""
    echo "=== Results ==="
    echo "PASSED: $PASS_COUNT"
    echo "FAILED: $FAIL_COUNT"
    echo ""
    exit 1
fi

# ---------------------------------------------------------------------------
# SC-11 (string): stale reference-doc task names (inspect/decompose/write/check/
#   file) are ABSENT, and actual task names (analyze/create/validate/revise) are
#   PRESENT, in reference/skill-card-description-standards.md.
#
# The stale names are the pre-rename spec-creation task names. They appear in
# two places: the "Single skill, multiple task cards" example table (line ~238)
# and the §7 Workflows example (lines ~257-265). The actual task names are the
# real spec-creation task cards (analyze/create/validate/revise).
#
# We assert absence of the stale names in the task-name contexts and presence of
# the actual names. To avoid false positives from unrelated prose (e.g., the
# word "file" or "check" appearing as ordinary English), we match the stale
# names only where they appear as spec-creation task references: the
# `spec-creation` with tasks: ...` example and the `spec-creation/tasks/*.md`
# task-card links.
# ---------------------------------------------------------------------------

# --- Stale task names must be ABSENT in the task-name example table ---
STALE_TABLE_LINE=$(grep -n 'spec-creation` with tasks:' "$REF_FILE" || true)
if [ -n "$STALE_TABLE_LINE" ]; then
    if printf '%s' "$STALE_TABLE_LINE" | grep -qE 'inspect|decompose|write|check|file'; then
        check_fail "SC-11: stale task names absent from example table" \
            "found stale name in: $STALE_TABLE_LINE"
    else
        check_pass "SC-11: stale task names absent from example table"
    fi
else
    check_fail "SC-11: example table present" \
        "no 'spec-creation\` with tasks:' line found in $REF_FILE"
fi

# --- Stale task-card links must be ABSENT ---
for stale in inspect decompose; do
    if grep -q "spec-creation/tasks/$stale\.md" "$REF_FILE"; then
        check_fail "SC-11: stale task-card link absent" \
            "found spec-creation/tasks/$stale.md in $REF_FILE"
    else
        check_pass "SC-11: stale task-card link absent (spec-creation/tasks/$stale.md)"
    fi
done

# --- Actual task names must be PRESENT in the example table ---
ACTUAL_TABLE_LINE=$(grep -n 'spec-creation` with tasks:' "$REF_FILE" || true)
if [ -n "$ACTUAL_TABLE_LINE" ]; then
    if printf '%s' "$ACTUAL_TABLE_LINE" | grep -qE 'analyze|create|validate|revise'; then
        check_pass "SC-11: actual task names present in example table"
    else
        check_fail "SC-11: actual task names present in example table" \
            "no analyze/create/validate/revise in: $ACTUAL_TABLE_LINE"
    fi
fi

# --- Actual task-card links must be PRESENT ---
for actual in analyze create validate revise; do
    if grep -q "spec-creation/tasks/$actual\.md" "$REF_FILE"; then
        check_pass "SC-11: actual task-card link present (spec-creation/tasks/$actual.md)"
    else
        check_fail "SC-11: actual task-card link present" \
            "spec-creation/tasks/$actual.md not found in $REF_FILE"
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-11 (reference task names) not yet implemented."
    echo "reference/skill-card-description-standards.md still references the stale"
    echo "pre-rename spec-creation task names (inspect/decompose/write/check/file)"
    echo "and the non-existent task-card files (inspect.md, decompose.md)."
    echo "GREEN updates the stale names to the actual task names"
    echo "(analyze/create/validate/revise) and the real task-card files."
    echo ""
    exit 1
fi
echo "SC-11 is GREEN — reference/skill-card-description-standards.md uses the"
echo "actual spec-creation task names (analyze/create/validate/revise) and the"
echo "real task-card files, with zero stale pre-rename names."
echo ""
exit 0
