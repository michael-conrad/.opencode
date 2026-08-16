#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-9 — audit role-card `# Task:`
# headings match filenames.
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-11-audit-role-card-naming — SC-9 (string),
#        `.opencode/skills/audit/tasks/*-role.md` and subdirectory role files.
#
# SC-9 (string): Every audit role-card `# Task:` heading SHALL match its
#   filename (Investigator/Validator/Evaluator/Arbiter).
#
# SC-8 (frontmatter `name:` field matches basename) was removed from the active
#   SC set per the spec changelog, and SC-43 removed the YAML frontmatter from
#   all audit role cards. The SC-8 frontmatter assertion is therefore no longer
#   active and is NOT asserted here. SC-9 remains active and is fully asserted.
#
# RED state: The role-card files carry stale `# Task:` headings that do not
#   match their filenames. The assertion below FAILS on this content.
#   GREEN repairs every `# Task:` heading to match the filename.
#
# Evidence type: SC-9 is a `string` SC. This content-verification test greps
#   each role-card file for its `# Task:` heading and compares against the
#   basename. It is the primary gate for this content-only SC (no runtime
#   behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc8-sc9-audit-role-card-naming.sh
# Exit:  0 if all role-card headings match their filenames (GREEN),
#        1 if any mismatch (expected RED on SC-9).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

TASKS_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"

PASS_COUNT=0
FAIL_COUNT=0
HEADING_MISMATCHES=0

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
echo "=== SC-9 — audit role-card Task heading vs filename (Spec .opencode#2254) ==="
echo ""
echo "Target dir: $TASKS_DIR"
echo ""

# ---------------------------------------------------------------------------
# Enumerate the audit role-card files. A role-card file is any file whose
# basename ends in one of the four DiMo role names:
#   -arbiter, -evaluator, -investigator, -validator
# This includes flat files in tasks/ and the four per-role files inside each of
# the closure-verification/, coherence-extraction/, and spec-summary/ subdirs.
# ---------------------------------------------------------------------------
ROLE_FILES=""
for role in arbiter evaluator investigator validator; do
    for f in "$TASKS_DIR"/*-"$role".md "$TASKS_DIR"/*/"$role".md; do
        [ -f "$f" ] && ROLE_FILES="$ROLE_FILES $f"
    done
done

if [ -z "$ROLE_FILES" ]; then
    check_fail "SC-9: role-card file enumeration" \
        "no audit role-card files found under $TASKS_DIR"
    echo ""
    echo "=== Results ==="
    echo "PASSED: $PASS_COUNT"
    echo "FAILED: $FAIL_COUNT"
    echo ""
    exit 1
fi

echo "Found $(echo "$ROLE_FILES" | wc -w) role-card files."
echo ""

# ---------------------------------------------------------------------------
# SC-9 (string): every role-card `# Task:` heading == basename.
#
# A file's basename is its filename without the directory and without the `.md`
# extension. For subdirectory role files (e.g. closure-verification/arbiter.md),
# the basename is the bare role name (`arbiter`), so the expected heading is the
# bare role name, matching the file's own name.
#
# SC-8 (frontmatter `name:` field) is no longer active and is not asserted.
# ---------------------------------------------------------------------------
for f in $ROLE_FILES; do
    bn="$(basename "$f" .md)"
    rel="$(realpath --relative-to="$TASKS_DIR" "$f")"

    # `# Task:` heading — the first level-1 Task heading in the file.
    HEADING_LINE=$(grep -m1 '^# Task:' "$f" 2>/dev/null || true)
    HEADING_VAL=""
    if [ -n "$HEADING_LINE" ]; then
        HEADING_VAL=$(printf '%s' "$HEADING_LINE" | sed 's/^# Task:[[:space:]]*//')
    fi

    # SC-9: `# Task:` heading == basename.
    if [ "$HEADING_VAL" = "$bn" ]; then
        check_pass "SC-9: $rel Task heading matches basename"
    else
        check_fail "SC-9: $rel Task heading matches basename" \
            "expected heading='$bn', got heading='$HEADING_VAL'"
        HEADING_MISMATCHES=$((HEADING_MISMATCHES + 1))
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo "HEADING_MISMATCHES: $HEADING_MISMATCHES"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-9 (audit role-card naming) not yet implemented."
    echo "Role-card '# Task:' headings still diverge from their filenames."
    echo "GREEN repairs every role-card '# Task:' heading to match its filename."
    echo ""
    exit 1
fi
echo "SC-9 is GREEN — every audit role-card '# Task:' heading matches its filename."
echo ""
exit 0
