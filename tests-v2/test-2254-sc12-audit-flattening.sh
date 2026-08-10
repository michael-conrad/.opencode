#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-12 — audit task flattening
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-12-audit-flattening — SC-12 (string),
#        `.opencode/skills/audit/tasks/`.
#
# SC-12 (string): The three subdirectory audit tasks (closure-verification/,
#   coherence-extraction/, spec-summary/) SHALL be flattened to flat role files
#   and their stub index files (closure-verification.md, coherence-extraction.md,
#   spec-summary.md) SHALL be removed.
#
# RED state: the three audit task sets exist as subdirectories (each containing
#   arbiter/evaluator/investigator/validator role files) and their stub index
#   files remain. Assertions (a) and (b) FAIL (subdirectories + stubs present)
#   and (c) FAIL (flat role files absent). GREEN flattens the 12 subdirectory
#   role files to flat `{task}-{role}.md` files and removes the stub index files.
#
# Evidence type: SC-12 is a `string` SC. This content-verification test checks
#   the file structure (subdirectories present/absent, flat files present/absent)
#   and is the primary gate for this content-only SC.
#
# Usage: bash .opencode/tests-v2/test-2254-sc12-audit-flattening.sh
# Exit:  0 if the checks pass (GREEN), 1 if they fail (expected RED on SC-12).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

TASKS_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"

SUBDIRS="closure-verification coherence-extraction spec-summary"
STUBS="closure-verification.md coherence-extraction.md spec-summary.md"
FLAT_ROLES="closure-verification-arbiter.md closure-verification-evaluator.md closure-verification-investigator.md closure-verification-validator.md coherence-extraction-arbiter.md coherence-extraction-evaluator.md coherence-extraction-investigator.md coherence-extraction-validator.md spec-summary-arbiter.md spec-summary-evaluator.md spec-summary-investigator.md spec-summary-validator.md"

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
echo "=== SC-12 — audit task flattening (Spec .opencode#2254) ==="
echo ""
echo "Target dir: $TASKS_DIR"
echo ""

# ---------------------------------------------------------------------------
# SC-12 (string): The three subdirectory audit tasks SHALL be flattened to
#   flat role files and their stub index files SHALL be removed.
#
# (a) The three subdirectories are NOT present as directories.
# ---------------------------------------------------------------------------
echo "--- SC-12 (a): subdirectories are absent ---"

for subdir in $SUBDIRS; do
    if [ -d "$TASKS_DIR/$subdir" ]; then
        check_fail "SC-12: subdirectory '$subdir' is present" \
            "$TASKS_DIR/$subdir is still a directory (must be flattened to flat role files)"
    else
        check_pass "SC-12: subdirectory '$subdir' is absent (flattened)"
    fi
done

# ---------------------------------------------------------------------------
# SC-12 (b): The stub index files are absent.
# ---------------------------------------------------------------------------
echo "--- SC-12 (b): stub index files are absent ---"

for stub in $STUBS; do
    if [ -e "$TASKS_DIR/$stub" ]; then
        check_fail "SC-12: stub index file '$stub' is present" \
            "$TASKS_DIR/$stub exists but must be removed"
    else
        check_pass "SC-12: stub index file '$stub' is absent"
    fi
done

# ---------------------------------------------------------------------------
# SC-12 (c): The 12 flat role files exist.
# ---------------------------------------------------------------------------
echo "--- SC-12 (c): flat role files are present ---"

for role in $FLAT_ROLES; do
    if [ -f "$TASKS_DIR/$role" ]; then
        check_pass "SC-12: flat role file '$role' present"
    else
        check_fail "SC-12: flat role file '$role' present" \
            "$TASKS_DIR/$role not found (must be created by flattening the subdirectory role files)"
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-12 (audit flattening) not yet implemented."
    echo "The three subdirectory audit task sets remain and their stub index"
    echo "files are still present. GREEN flattens the 12 subdirectory role files"
    echo "to flat '{task}-{role}.md' files and removes the stub index files."
    echo ""
    exit 1
fi
echo "SC-12 is GREEN — the three subdirectory audit tasks are flattened to flat"
echo "role files and their stub index files are removed."
echo ""
exit 0
