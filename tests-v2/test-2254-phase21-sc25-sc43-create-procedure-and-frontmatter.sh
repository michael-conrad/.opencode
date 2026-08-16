#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 21 — SC-25, SC-43
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 21 — create.md Procedure numbered-checkbox conversion
#        (SC-25) + audit role-card YAML frontmatter removal (SC-43).
#
# SC-25 (string): `.opencode/skills/spec-creation/tasks/create.md` Procedure
#   sub-steps (Step 3, 3.1, 3.2, 6, 7) SHALL use numbered-checkbox format
#   (`- [ ] N.`); no plain numbered lists (`N.`) remain in the Procedure
#   section.
# SC-43 (string): the 48 audit role cards (the `*-arbiter.md`,
#   `*-evaluator.md`, `*-investigator.md`, `*-validator.md` files in
#   `.opencode/skills/audit/tasks/`) SHALL have NO YAML frontmatter — none
#   start with `---`.
#
# RED state: create.md's Procedure section still uses plain numbered lists in
#   Steps 3, 3.1, 3.2, 6, 7 (e.g. `1. Create a minimal remote issue...`), and
#   all 48 audit role cards still start with `---`. The assertions below FAIL
#   on this content.
# GREEN converts those five sub-steps to numbered-checkbox lists and removes
#   the YAML frontmatter from all 48 audit role cards.
#
# Evidence type: Both SCs are `string` SCs. This content-verification test
#   greps the target files for plain numbered lists and YAML frontmatter. It
#   is the primary gate for these content-only SCs (no runtime behavior is
#   changed).
#
# Usage: bash .opencode/tests-v2/test-2254-phase21-sc25-sc43-create-procedure-and-frontmatter.sh
# Exit:  0 if all targets conform (GREEN), 1 if any target is non-conformant (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

CREATE_TASK="$PROJECT_DIR/.opencode/skills/spec-creation/tasks/create.md"
AUDIT_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"

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
echo "=== Phase 21 — SC-25 create.md Procedure numbered-checkbox; SC-43 audit role-card frontmatter removal (Spec .opencode#2254) ==="
echo ""
echo "Target (SC-25): $CREATE_TASK"
echo "Target (SC-43): $AUDIT_DIR"
echo ""

# ---------------------------------------------------------------------------
# SC-25 (string): create.md Procedure sub-steps (Step 3, 3.1, 3.2, 6, 7) use
#   numbered-checkbox format; no plain numbered lists remain in the Procedure
#   section.
# ---------------------------------------------------------------------------
echo "--- SC-25: create.md Procedure uses numbered-checkbox, no plain numbered lists ---"

if [ ! -f "$CREATE_TASK" ]; then
    check_fail "SC-25: create.md exists" "spec-creation/tasks/create.md not found"
else
    # Extract the Procedure section (from `## Procedure` to the next `## `).
    PROCEDURE_SECTION="$(awk '/^## Procedure/{flag=1; next} /^## /{if (flag) exit} flag' "$CREATE_TASK")"

    if [ -z "$PROCEDURE_SECTION" ]; then
        check_fail "SC-25: Procedure section extracted" "no '## Procedure' heading found in create.md"
    else
        # (a1) No plain numbered list lines (`N. `) may remain in the Procedure section.
        PLAIN_LIST_LINES="$(printf '%s\n' "$PROCEDURE_SECTION" | grep -nE '^[0-9]+\. ' || true)"
        if [ -z "$PLAIN_LIST_LINES" ]; then
            check_pass "SC-25: no plain numbered lists remain in create.md Procedure section"
        else
            check_fail "SC-25: no plain numbered lists remain in create.md Procedure section" \
                "found plain numbered list line(s): $(printf '%s' "$PLAIN_LIST_LINES" | tr '\n' ';')"
        fi

        # (a2) Each of the five targeted sub-steps uses numbered-checkbox markers.
        #      Extract each `### Step N:` subsection and require `- [ ] N.`.
        step_section() {
            local heading="$1"
            awk -v h="$heading" 'index($0, h)==1{flag=1; next} /^### /{if (flag) exit} flag' "$CREATE_TASK"
        }

        for step in "### Step 3:" "### Step 3.1:" "### Step 3.2:" "### Step 6:" "### Step 7:"; do
            local_section="$(step_section "$step")"
            if [ -z "$local_section" ]; then
                check_fail "SC-25: $step uses numbered-checkbox lists" \
                    "no subsection found for '$step' in create.md"
            elif [[ "$local_section" =~ '- [ ] '[0-9]+\. ]]; then
                check_pass "SC-25: $step uses numbered-checkbox lists (- [ ] N.)"
            else
                check_fail "SC-25: $step uses numbered-checkbox lists" \
                    "no '- [ ] N.' marker in the '$step' subsection"
            fi
        done
    fi
fi

echo ""

# ---------------------------------------------------------------------------
# SC-43 (string): the 48 audit role cards have NO YAML frontmatter — none
#   start with `---`.
# ---------------------------------------------------------------------------
echo "--- SC-43: 48 audit role cards have no YAML frontmatter ---"

ROLE_CARDS=("$AUDIT_DIR"/*-arbiter.md "$AUDIT_DIR"/*-evaluator.md "$AUDIT_DIR"/*-investigator.md "$AUDIT_DIR"/*-validator.md)
ROLE_CARD_COUNT=0
WITH_FRONTMATTER=0

for f in "${ROLE_CARDS[@]}"; do
    [ -e "$f" ] || continue
    ROLE_CARD_COUNT=$((ROLE_CARD_COUNT + 1))
    if head -1 "$f" | grep -qE '^---$'; then
        echo "  FAIL: SC-43: $(basename "$f") has YAML frontmatter (starts with '---')" >&2
        WITH_FRONTMATTER=$((WITH_FRONTMATTER + 1))
    fi
done

if [ "$ROLE_CARD_COUNT" -ne 48 ]; then
    check_fail "SC-43: exactly 48 audit role cards enumerated" \
        "found $ROLE_CARD_COUNT role cards (expected 48)"
else
    check_pass "SC-43: exactly 48 audit role cards enumerated"
fi

if [ "$WITH_FRONTMATTER" -eq 0 ]; then
    check_pass "SC-43: all 48 audit role cards have no YAML frontmatter"
else
    check_fail "SC-43: all 48 audit role cards have no YAML frontmatter" \
        "$WITH_FRONTMATTER of $ROLE_CARD_COUNT role cards still start with '---'"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-25, SC-43 not yet implemented."
    echo "create.md's Procedure section still uses plain numbered lists in Steps"
    echo "3, 3.1, 3.2, 6, 7, and the 48 audit role cards still carry YAML"
    echo "frontmatter."
    echo "GREEN converts the five create.md sub-steps to numbered-checkbox lists"
    echo "and removes the YAML frontmatter from all 48 audit role cards."
    echo ""
    exit 1
fi
echo "SC-25, SC-43 are GREEN — create.md's Procedure sub-steps use numbered-"
echo "checkbox lists with no plain numbered lists remaining, and all 48 audit"
echo "role cards have no YAML frontmatter."
echo ""
exit 0
