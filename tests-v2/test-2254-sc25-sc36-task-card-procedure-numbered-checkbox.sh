#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-25, SC-36 — task-card Procedure
# sections use numbered-checkbox lists; the reference specifies the numbered-
# checkbox Procedure format, the clean-room unit mandate, and the
# dispatch-contract completeness requirement.
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-21-numbered-checkbox-task-card-procedure.
#
# SC-36 (string): reference/task-card-structure-standards.md SHALL specify the
#   task-card Procedure as numbered-checkbox lists (`- [ ] N.`) and SHALL state
#   the clean-room unit mandate (task cards are for non-task-capable
#   sub-agents; a procedure requiring internal sub-agent dispatch MUST be
#   split) and the dispatch-contract completeness requirement (the workflow
#   Context must supply every parameter in the task card's Dispatch Contract
#   and Entry Criteria).
# SC-25 (string): Every task card Procedure section in spec-creation and audit
#   SHALL use numbered checkbox lists (`- [ ] N.`).
#
# RED state: The reference doc's Procedure section uses plain numbered steps
#   (`1.` / `2.` / `3.`) with no clean-room unit or dispatch-contract
#   completeness mandates; spec-creation and audit task-card Procedure
#   sections use `### Step N:` prose headings (or plain numbered steps) with no
#   numbered-checkbox (`- [ ] N.`) markers. The assertions below FAIL on this
#   content.
# GREEN converts the reference doc Procedure section to numbered-checkbox lists
#   with the two mandates and converts every spec-creation/audit task-card
#   Procedure to numbered-checkbox lists.
#
# Evidence type: Both SCs are `string` SCs. This content-verification test greps
#   the target files for numbered-checkbox procedure steps and the reference
#   mandates. It is the primary gate for these content-only SCs (no runtime
#   behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc25-sc36-task-card-procedure-numbered-checkbox.sh
# Exit:  0 if all targets conform (GREEN), 1 if any target is non-conformant (RED).

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
echo "=== SC-25 / SC-36 — task-card Procedures use numbered-checkbox lists; reference specifies the mandates (Spec .opencode#2254) ==="
echo ""

REFERENCE="$PROJECT_DIR/.opencode/reference/task-card-structure-standards.md"

# ---------------------------------------------------------------------------
# SC-36 (string): reference/task-card-structure-standards.md SHALL specify the
#   task-card Procedure as numbered-checkbox lists and SHALL state the
#   clean-room unit mandate and the dispatch-contract completeness requirement.
# ---------------------------------------------------------------------------
echo "Target (SC-36): $REFERENCE"

if [ ! -f "$REFERENCE" ]; then
    check_fail "SC-36: target file exists" "task-card-structure-standards.md not found"
else
    # The Procedure section is the `### Procedure` subsection of §1 Canonical
    # Sections, running from `### Procedure` to the next `### ` heading.
    PROCEDURE_SECTION="$(awk '/^### Procedure/{flag=1; next} /^### /{if (flag) exit} flag' "$REFERENCE")"
    if [ -z "$PROCEDURE_SECTION" ]; then
        check_fail "SC-36: Procedure section extracted" "no '### Procedure' heading found"
    else
        # Numbered-checkbox procedure step marker `- [ ] N.` must be present.
        if [[ "$PROCEDURE_SECTION" =~ '- [ ] '[0-9]+\. ]]; then
            check_pass "SC-36: Procedure section uses numbered-checkbox markers (- [ ] N.)"
        else
            check_fail "SC-36: Procedure section uses numbered-checkbox markers" \
                "no '- [ ] N.' marker in the Procedure section"
        fi
    fi
    # Clean-room unit mandate must be stated somewhere in the document.
    if grep -qi "non-task-capable" "$REFERENCE" && grep -qi "internal sub-agent dispatch\|internal dispatch\|sub-agent dispatch" "$REFERENCE"; then
        check_pass "SC-36: clean-room unit mandate stated (task cards for non-task-capable sub-agents; internal dispatch MUST be split)"
    else
        check_fail "SC-36: clean-room unit mandate stated" \
            "no 'non-task-capable' and 'internal sub-agent dispatch' language in the reference"
    fi
    # Dispatch-contract completeness requirement must be stated somewhere in the document.
    if grep -qi "dispatch contract" "$REFERENCE" && grep -qi "context must supply every parameter\|workflow context.*supply.*parameter\|dispatch-contract completeness" "$REFERENCE"; then
        check_pass "SC-36: dispatch-contract completeness requirement stated (workflow Context supplies every Dispatch Contract/Entry Criteria parameter)"
    else
        check_fail "SC-36: dispatch-contract completeness requirement stated" \
            "no dispatch-contract completeness language in the reference"
    fi
fi

echo ""

# ---------------------------------------------------------------------------
# SC-25 (string): Every task card Procedure section in spec-creation and audit
#   SHALL use numbered checkbox lists (`- [ ] N.`).
# ---------------------------------------------------------------------------
NON_CONFORMANT=0
for skill_dir in spec-creation audit; do
    dir="$PROJECT_DIR/.opencode/skills/$skill_dir/tasks"
    if [ ! -d "$dir" ]; then
        check_fail "SC-25: $skill_dir/tasks dir exists" "tasks directory not found"
        NON_CONFORMANT=$((NON_CONFORMANT + 1))
        continue
    fi
    for f in "$dir"/*.md; do
        [ -e "$f" ] || continue
        name="$(basename "$f")"
        # Extract the Procedure section (from `## Procedure` to the next `## `).
        section="$(awk '/^## Procedure/{flag=1; next} /^## /{if (flag) exit} flag' "$f")"
        # A non-conformant card: Procedure section present but no numbered-checkbox
        # `- [ ] N.` step marker at all.
        if [ -n "$section" ] && ! [[ "$section" =~ '- [ ] '[0-9]+\. ]]; then
            check_fail "SC-25: $skill_dir/$name Procedure uses numbered-checkbox lists" \
                "no '- [ ] N.' marker in the Procedure section"
            NON_CONFORMANT=$((NON_CONFORMANT + 1))
        fi
    done
done

if [ "$NON_CONFORMANT" -eq 0 ]; then
    check_pass "SC-25: all task-card Procedures in spec-creation and audit use numbered-checkbox lists"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-25, SC-36 not yet implemented."
    echo "The reference doc Procedure section still uses plain numbered steps"
    echo "with no clean-room unit or dispatch-contract completeness mandates,"
    echo "and spec-creation/audit task-card Procedure sections use '### Step N:'"
    echo "prose headings (or plain numbered steps) with no numbered-checkbox"
    echo "markers."
    echo "GREEN converts the reference doc and every task-card Procedure to"
    echo "numbered-checkbox lists and adds the two mandates."
    echo ""
    exit 1
fi
echo "SC-25, SC-36 are GREEN — the reference doc specifies the numbered-checkbox"
echo "Procedure with the clean-room unit and dispatch-contract completeness"
echo "mandates, and every spec-creation/audit task-card Procedure uses"
echo "numbered-checkbox lists."
echo ""
exit 0
