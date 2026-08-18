#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-2 — task card Purpose statement
# quality audit across .opencode/skills/*/tasks/*.md.
#
# Issue: .opencode#2296 — Purpose statement quality (SC-2).
#
# Audit criteria for a task card Purpose statement:
#   (1) condensable           — short enough to be condensed into a concise
#                               dispatch anchor (single, focused statement;
#                               no run-on multi-clause/paragraph detail).
#   (2) outcome-as-subject    — the purpose names the OUTCOME as the subject,
#                               not the mechanism/process used to achieve it
#                               (the subject is the deliverable/result, not
#                               "Evaluator role... reads...writes...").
#   (3) distinctive-from-siblings — no two sibling task cards within the same
#                               skill share a nearly identical purpose.
#
# RED state: purpose statements failing the audit exist today. This test MUST
#   exit non-zero (RED) so SC-2 (GREEN) corrects them.
#
# Usage: bash .opencode/tests-v2/test-2296-sc2-purpose-audit.sh
# Exit:  0 if every audited Purpose section passes all three criteria (GREEN),
#        1 otherwise (RED — flagged purposes remain).
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

TARGET_ROOT="$PROJECT_DIR/.opencode/skills"

PASS_COUNT=0
FAIL_COUNT=0
declare -a FLAGGED=()

check_fail() {
    local detail="$1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    FLAGGED+=("$detail")
    echo "  FLAG: $detail" >&2
}

# ---------------------------------------------------------------------------
# Extract the Purpose section of a task card. Returns the raw section text.
# ---------------------------------------------------------------------------
purpose_section() {
    local f="$1"
    awk '/^## Purpose/{flag=1; next} /^## /{if (flag) exit} flag' "$f"
}

# ---------------------------------------------------------------------------
# Normalize a purpose for sibling distinctiveness comparison: lowercase,
# strip role nouns (arbiter/evaluator/validator/investigator), strip the
# "role for the X chain" suffix, and collapse whitespace.
# ---------------------------------------------------------------------------
normalize_purpose() {
    local s="$1"
    s="$(printf '%s' "$s" | tr '[:upper:]' '[:lower:]')"
    s="$(printf '%s' "$s" | sed -E \
        -e 's/arbiter role for the [a-z-]+ chain\.//' \
        -e 's/evaluator role for the [a-z-]+ chain\.//' \
        -e 's/validator role for the [a-z-]+ chain\.//' \
        -e 's/investigator role for the [a-z-]+ chain\.//' \
        -e 's/this role//g' \
        -e 's/[^a-z0-9]+/ /g')"
    s="$(printf '%s' "$s" | sed -E 's/^ +//; s/ +$//')"
    printf '%s' "$s"
}

echo ""
echo "=== SC-2 — task card Purpose statement quality audit (.opencode#2296) ==="
echo "Target: $TARGET_ROOT/*/tasks/*.md"
echo "Criteria: (1) condensable (2) outcome-as-subject (3) distinctive-from-siblings"
echo ""

# Collect each task card's skill, basename, and purpose.
declare -a SKILLS
declare -a FILES
declare -a RELS
declare -a PURPOSES
declare -a NORMED
index=0

for f in "$TARGET_ROOT"/*/tasks/*.md; do
    [ -e "$f" ] || continue
    rel="${f#"$TARGET_ROOT"/}"
    skill="${rel%%/*}"
    base="$(basename "$rel")"
    purp="$(purpose_section "$f")"
    # skip empty purpose (no audit target)
    [ -z "$purp" ] && continue
    SKILLS[$index]="$skill"
    FILES[$index]="$rel"
    RELS[$index]="$rel"
    PURPOSES[$index]="$purp"
    NORMED[$index]="$(normalize_purpose "$purp")"
    index=$((index + 1))
done

count="$index"

echo ""
echo "--- Criterion (1): condensable (single concise dispatch anchor, <= 60 words) ---"
for ((i=0; i<count; i++)); do
    rel="${RELS[$i]}"
    purp="${PURPOSES[$i]}"
    wc="$(printf '%s' "$purp" | wc -w)"
    if [ "$wc" -gt 60 ]; then
        check_fail "(1) condensable — $rel is $wc words (must be condensable to a concise dispatch anchor)"
    fi
done

echo ""
echo "--- Criterion (2): outcome-as-subject (subject is the outcome, not the role/mechanism) ---"
for ((i=0; i<count; i++)); do
    rel="${RELS[$i]}"
    purp="${PURPOSES[$i]}"
    # first word (leading clause subject) that names the mechanism/process
    trimmed="$(printf '%s' "$purp" | awk 'NF{sub(/^[ \t]+/,""); print; exit}')"
    first="$(printf '%s' "$trimmed" | tr -d '[:space:]' | cut -c1-40)"
    case "$trimmed" in
        "Evaluator role"*|"Investigator role"*|"Validator role"*|"Arbiter role"*)
            check_fail "(2) outcome-as-subject — $rel : subject is a role ('$first'), not the outcome"
            ;;
        *)
            ;;
    esac
done

echo ""
echo "--- Criterion (3): distinctive from siblings (no near-identical sibling purposes) ---"
declare -A SEEN_SKILL_NORM
for ((i=0; i<count; i++)); do
    skill="${SKILLS[$i]}"
    rel="${RELS[$i]}"
    norm="${NORMED[$i]}"
    [ -z "$norm" ] && continue
    key="${skill}::${norm}"
    if [ -n "${SEEN_SKILL_NORM[$key]:-}" ]; then
        check_fail "(3) distinctive-from-siblings — $rel duplicates purpose in sibling $skill (see ${SEEN_SKILL_NORM[$key]})"
    else
        SEEN_SKILL_NORM[$key]="$rel"
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED expected: purpose statements failing the audit exist and SC-2 (GREEN)"
    echo "must correct them to be condensable, outcome-as-subject, and distinctive"
    echo "from siblings. Flagged purposes:"
    printf '  - %s\n' "${FLAGGED[@]}"
    echo ""
    exit 1
fi
echo "Every task card Purpose satisfies all three audit criteria (GREEN)."
echo ""
exit 0
