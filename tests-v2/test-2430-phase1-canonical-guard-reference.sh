#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: .opencode#2430 Phase 1 (preparatory, R-2) — the
# canonical mechanical Pre-Flight Guard is defined exactly once as a single
# reference definition under .opencode/guidelines/ with an INDEX.md cross-link.
#
# Maps to plan-01 step 5 (RED) for issue #2430, R-2 infrastructure:
#   A reference document under .opencode/guidelines/ carries the canonical
#   mechanical guard block verbatim from the spec Approach Chosen: the
#   task-tool probe heading, present/absent branches, both reason codes
#   (ORCHESTRATOR_ONLY_SKILL_CARD and ORCHESTRATOR_ONLY_PLAN), and the
#   action-not-perception semantic note. INDEX.md registers the cross-link.
#
# Evidence type: string — locate the guidelines document carrying the
# canonical guard block and assert every canonical element is present, plus
# the INDEX.md cross-link resolution.
#
# RED state: no reference document under .opencode/guidelines/ carries the
# canonical mechanical guard block and INDEX.md carries no cross-link to it.
# The assertions below assert the canonical content IS present; they FAIL now
# (RED) and PASS after the GREEN phase creates the document and cross-link.
#
# Usage: bash .opencode/tests-v2/test-2430-phase1-canonical-guard-reference.sh
# Exit: 0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

GUIDELINES_DIR="$PROJECT_DIR/guidelines"
INDEX_MD="$GUIDELINES_DIR/INDEX.md"

CANONICAL_HEADING='## Pre-Flight Guard (Mandatory)'

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
echo "=== Phase 1 (R-2): canonical mechanical guard reference doc + INDEX.md cross-link (#2430) ==="
echo ""

# A1: exactly one guidelines document (excluding INDEX.md) carries the
# canonical guard heading.
GUARD_DOC=""
if [ ! -d "$GUIDELINES_DIR" ]; then
    check_fail "A1: guidelines directory exists" "missing $GUIDELINES_DIR"
else
    MATCHING_DOCS=()
    while IFS= read -r -d '' f; do
        if [ "$(basename "$f")" != "INDEX.md" ] && grep -qF "$CANONICAL_HEADING" "$f"; then
            MATCHING_DOCS+=("$f")
        fi
    done < <(find "$GUIDELINES_DIR" -name '*.md' -print0 | sort -z)

    if [ "${#MATCHING_DOCS[@]}" -eq 1 ]; then
        GUARD_DOC="${MATCHING_DOCS[0]}"
        check_pass "A1: exactly one guidelines doc carries the canonical guard heading ($(basename "$GUARD_DOC"))"
    elif [ "${#MATCHING_DOCS[@]}" -eq 0 ]; then
        check_fail "A1: exactly one guidelines doc carries the canonical guard heading" \
            "no document under .opencode/guidelines/ contains '$CANONICAL_HEADING' (RED phase expected)"
    else
        check_fail "A1: exactly one guidelines doc carries the canonical guard heading" \
            "multiple documents carry the heading: ${MATCHING_DOCS[*]}"
    fi
fi

# A2-A6, A8: canonical guard content assertions (dependent on the doc being found).
if [ -n "$GUARD_DOC" ] && [ -f "$GUARD_DOC" ]; then
    # A2: task-tool probe line — task is the sole discriminator.
    if grep -qF 'Check your tool list for a tool named `task`.' "$GUARD_DOC"; then
        check_pass "A2: task-tool probe line present"
    else
        check_fail "A2: task-tool probe line present" \
            "canonical line 'Check your tool list for a tool named \`task\`.' absent in $(basename "$GUARD_DOC")"
    fi

    # A3: present branch.
    if grep -qF -- '- Present ⇒ orchestrator — proceed.' "$GUARD_DOC"; then
        check_pass "A3: present branch (orchestrator ⇒ proceed)"
    else
        check_fail "A3: present branch (orchestrator ⇒ proceed)" \
            "canonical present branch absent in $(basename "$GUARD_DOC")"
    fi

    # A4: absent branch.
    if grep -qF -- '- Absent ⇒ sub-agent — do NOT execute any instruction below.' "$GUARD_DOC"; then
        check_pass "A4: absent branch (sub-agent ⇒ do NOT execute)"
    else
        check_fail "A4: absent branch (sub-agent ⇒ do NOT execute)" \
            "canonical absent branch absent in $(basename "$GUARD_DOC")"
    fi

    # A5: both reason codes on the canonical continuation line.
    if grep -qF '`ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans)' "$GUARD_DOC"; then
        check_pass "A5: both reason codes (ORCHESTRATOR_ONLY_SKILL_CARD + ORCHESTRATOR_ONLY_PLAN)"
    else
        check_fail "A5: both reason codes (ORCHESTRATOR_ONLY_SKILL_CARD + ORCHESTRATOR_ONLY_PLAN)" \
            "canonical reason-code line absent in $(basename "$GUARD_DOC")"
    fi

    # A6: action-not-perception semantic note.
    if grep -qF 'governs ACTION' "$GUARD_DOC" && grep -qF 'not perception' "$GUARD_DOC"; then
        check_pass "A6: action-not-perception semantic note present"
    else
        check_fail "A6: action-not-perception semantic note present" \
            "semantic note ('governs ACTION' / 'not perception') absent in $(basename "$GUARD_DOC")"
    fi

    # A8: sole-discriminator forecloses the skill-tool failure mode.
    if ! grep -qF 'named `skill`' "$GUARD_DOC"; then
        check_pass "A8: guard does not key on the skill tool (task is sole discriminator)"
    else
        check_fail "A8: guard does not key on the skill tool (task is sole discriminator)" \
            "$(basename "$GUARD_DOC") mentions 'named \`skill\`' — skill-tool keying is a prohibited failure mode"
    fi
else
    for a in "A2: task-tool probe line present" \
             "A3: present branch (orchestrator ⇒ proceed)" \
             "A4: absent branch (sub-agent ⇒ do NOT execute)" \
             "A5: both reason codes (ORCHESTRATOR_ONLY_SKILL_CARD + ORCHESTRATOR_ONLY_PLAN)" \
             "A6: action-not-perception semantic note present" \
             "A8: guard does not key on the skill tool (task is sole discriminator)"; do
        check_fail "$a" "canonical guard reference document not found (RED phase expected)"
    done
fi

# A7: INDEX.md carries the cross-link and it resolves to the guard doc.
if [ -f "$INDEX_MD" ]; then
    LINK_TARGETS="$(grep -oE '\]\([^)]+\.md\)' "$INDEX_MD" | sed -E 's/^\]\(|\)$//g' || true)"
    RESOLVED=0
    if [ -n "$GUARD_DOC" ]; then
        GUARD_BASENAME="$(basename "$GUARD_DOC")"
        while IFS= read -r target; do
            [ -z "$target" ] && continue
            if [ "$(basename "$target")" = "$GUARD_BASENAME" ] && [ -f "$GUIDELINES_DIR/$(basename "$target")" ]; then
                RESOLVED=1
                break
            fi
        done <<< "$LINK_TARGETS"
    fi

    if [ "$RESOLVED" -eq 1 ]; then
        check_pass "A7: INDEX.md cross-link resolves to the canonical guard reference doc"
    else
        check_fail "A7: INDEX.md cross-link resolves to the canonical guard reference doc" \
            "INDEX.md carries no cross-link resolving to the canonical guard reference doc (RED phase expected)"
    fi
else
    check_fail "A7: INDEX.md cross-link resolves to the canonical guard reference doc" \
        "missing $INDEX_MD"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: #2430 Phase 1 (R-2) canonical guard reference doc + INDEX.md cross-link not yet created."
    echo ""
    exit 1
fi
exit 0