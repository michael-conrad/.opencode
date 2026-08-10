#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-8, SC-9 — audit role-card frontmatter
# name fields and `# Task:` headings match filenames.
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-11-audit-role-card-naming — SC-8, SC-9 (string),
#        `.opencode/skills/audit/tasks/*-role.md` and subdirectory role files.
#
# SC-8 (string): Every audit role-card frontmatter `name:` field SHALL match its
#   filename (Investigator/Validator/Evaluator/Arbiter), with zero
#   `-generator`/`-knowledge-supporter`/`-path-provider` mismatches.
#   The authoritative on-disk count of defective role-card files is 40:
#   28 flat role files in tasks/ (24 with stale pre-rename role names —
#   generator/knowledge-supporter/path-provider — plus 4 with empty `name` field:
#   concern-separation-investigator, concern-separation-validator,
#   plan-fidelity-investigator, behavioral-sc-evaluator) and 12 subdirectory role
#   files (closure-verification/*, coherence-extraction/*, spec-summary/* — 4 each)
#   all with empty `name` field. plan-fidelity-validator.md carries
#   `name: plan-fidelity-knowledge-supporter` (stale, not empty) and is counted in
#   the 24 stale.
#
# SC-9 (string): Every audit role-card `# Task:` heading SHALL match its filename
#   (Investigator/Validator/Evaluator/Arbiter).
#
# RED state: The role-card files carry stale pre-rename role names
#   (generator/knowledge-supporter/path-provider) in their frontmatter `name` and
#   `# Task:` heading, or lack the frontmatter `name` entirely (empty name). The
#   assertions below FAIL on this content. GREEN repairs every frontmatter `name`
#   and `# Task:` heading to match the filename.
#
# Evidence type: SC-8 and SC-9 are `string` SCs. This content-verification test
#   greps each role-card file for its frontmatter name and `# Task:` heading and
#   compares against the basename. It is the primary gate for these content-only
#   SCs (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc8-sc9-audit-role-card-naming.sh
# Exit:  0 if all role-card names/headings match their filenames (GREEN),
#        1 if any mismatch (expected RED on SC-8/SC-9).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

TASKS_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"

PASS_COUNT=0
FAIL_COUNT=0
NAME_MISMATCHES=0
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
echo "=== SC-8, SC-9 — audit role-card frontmatter name + Task heading vs filename (Spec .opencode#2254) ==="
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
    check_fail "SC-8/SC-9: role-card file enumeration" \
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
# SC-8 (string): every role-card frontmatter `name:` == basename.
# SC-9 (string): every role-card `# Task:` heading == basename.
#
# A file's basename is its filename without the directory and without the `.md`
# extension. For subdirectory role files (e.g. closure-verification/arbiter.md),
# the basename is the bare role name (`arbiter`), so the expected frontmatter
# name and heading are the bare role name, matching the file's own name field.
# ---------------------------------------------------------------------------
for f in $ROLE_FILES; do
    bn="$(basename "$f" .md)"
    rel="$(realpath --relative-to="$TASKS_DIR" "$f")"

    # Frontmatter `name:` field. Only the first `name:` line inside the leading
    # frontmatter block counts. The frontmatter block is delimited by the first
    # two `---` lines; the `name:` field appears within it. Some role-card files
    # currently lack a frontmatter `name:` field entirely (empty name).
    NAME_LINE=$(grep -m1 '^name:' "$f" 2>/dev/null || true)
    NAME_VAL=""
    if [ -n "$NAME_LINE" ]; then
        NAME_VAL=$(printf '%s' "$NAME_LINE" | sed 's/^name:[[:space:]]*//')
    fi

    # `# Task:` heading — the first level-1 Task heading in the file.
    HEADING_LINE=$(grep -m1 '^# Task:' "$f" 2>/dev/null || true)
    HEADING_VAL=""
    if [ -n "$HEADING_LINE" ]; then
        HEADING_VAL=$(printf '%s' "$HEADING_LINE" | sed 's/^# Task:[[:space:]]*//')
    fi

    # SC-8: frontmatter name == basename.
    if [ "$NAME_VAL" = "$bn" ]; then
        check_pass "SC-8: $rel frontmatter name matches basename"
    else
        check_fail "SC-8: $rel frontmatter name matches basename" \
            "expected name='$bn', got name='$NAME_VAL'"
        NAME_MISMATCHES=$((NAME_MISMATCHES + 1))
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
echo "NAME_MISMATCHES: $NAME_MISMATCHES"
echo "HEADING_MISMATCHES: $HEADING_MISMATCHES"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-8/SC-9 (audit role-card naming) not yet implemented."
    echo "Role-card frontmatter name fields and/or '# Task:' headings still diverge"
    echo "from their filenames (stale generator/knowledge-supporter/path-provider"
    echo "pre-rename names, or missing frontmatter name fields)."
    echo "GREEN repairs every role-card frontmatter name and '# Task:' heading to"
    echo "match its filename."
    echo ""
    exit 1
fi
echo "SC-8 and SC-9 are GREEN — every audit role-card frontmatter name field and"
echo "'# Task:' heading matches its filename."
echo ""
exit 0
