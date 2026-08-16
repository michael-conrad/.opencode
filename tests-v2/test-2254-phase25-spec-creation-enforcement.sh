#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# RED enforcement test for Spec .opencode#2254 Phase 25 — spec-creation
# SC-38 / SC-39 link repair and skills/ prefix.
#
# SC-38 (string): spec-creation/SKILL.md SHALL have no broken links to
#   non-existent files. Specifically, the backtick reference to
#   `docs/specs/how-to-write-good-spec-ai-agents.md` (Plan Audit Code Deep
#   Dive section, line 151) SHALL be removed (deleted or replaced with a
#   valid resolvable reference).
#
# SC-39 (string): spec-creation/tasks/create.md lines 96, 145 and
#   spec-creation/tasks/revise.md line 47 SHALL carry the `skills/` prefix
#   on their issue-operations task-file references, so they resolve to
#   `.opencode/skills/issue-operations-core/tasks/creation.md` and
#   `.opencode/skills/issue-operations/platforms/local/tasks/push-artifacts.md`,
#   not to `.opencode/issue-operations-core/tasks/creation.md`.
#
# RED: The broken reference and missing `skills/` prefixes still exist in
#   the current code. All assertions FAIL (exit 1).
#
# GREEN: SC-38 removes or repoints the broken link; SC-39 adds `skills/`
#   prefix to all three task-file references. All assertions PASS (exit 0).
#
# Evidence type: string — grep/pattern matching is sufficient for these
#   content-verification assertions.
#
# Usage: bash .opencode/tests-v2/test-2254-phase25-spec-creation-enforcement.sh
# Exit:  0 if all repairs are applied (GREEN), 1 otherwise (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_MD="$PROJECT_DIR/.opencode/skills/spec-creation/SKILL.md"
CREATE_MD="$PROJECT_DIR/.opencode/skills/spec-creation/tasks/create.md"
REVISE_MD="$PROJECT_DIR/.opencode/skills/spec-creation/tasks/revise.md"
ARTIFACT_DIR="$PROJECT_DIR/tmp/2254/phase25-red"
mkdir -p "$ARTIFACT_DIR"

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
echo "=== Phase 25 — spec-creation SC-38/SC-39 enforcement (Spec .opencode#2254) ==="
echo ""
echo "Target files:"
echo "  $SKILL_MD"
echo "  $CREATE_MD"
echo "  $REVISE_MD"
echo ""

# ============================================================
# SC-38: Broken link to docs/specs/how-to-write-good-spec-ai-agents.md
# ============================================================
echo "[SC-38] Broken link: spec-creation/SKILL.md references"
echo "        non-existent docs/specs/how-to-write-good-spec-ai-agents.md"
echo ""

BROKEN_REF="docs/specs/how-to-write-good-spec-ai-agents.md"

if grep -Fnq "$BROKEN_REF" "$SKILL_MD"; then
    BROKEN_LINE=$(grep -Fn "$BROKEN_REF" "$SKILL_MD" | head -1 | cut -d: -f1)
    check_fail "SC-38: Broken link present at $SKILL_MD line $BROKEN_LINE" \
        "Reference \`$BROKEN_REF\` still exists (RED — must be removed or repointed)"
else
    check_pass "SC-38: No broken reference to $BROKEN_REF in $SKILL_MD"
fi

# ============================================================
# SC-39: Missing `skills/` prefix on issue-operations references
# ============================================================
echo ""
echo "[SC-39] Missing 'skills/' prefix: issue-operations task-file references"
echo "        in create.md and revise.md"
echo ""

# Expected GREEN state: references that SHOULD have skills/ prefix
# After repair, the references will contain "skills/issue-operations-core/tasks/creation.md"
# and "skills/issue-operations/platforms/local/tasks/push-artifacts.md"

# --- create.md line 96: issue-operations-core/tasks/creation.md ---
if grep -Eq '\(issue-operations-core/tasks/creation\.md\)' "$CREATE_MD"; then
    MATCH_LINE=$(grep -n 'issue-operations-core/tasks/creation\.md' "$CREATE_MD" | head -1 | cut -d: -f1)
    if grep -Eq '\(skills/issue-operations-core/tasks/creation\.md\)' "$CREATE_MD"; then
        check_pass "SC-39: create.md has skills/ prefix on issue-operations-core/tasks/creation.md (line $MATCH_LINE)"
    else
        check_fail "SC-39: create.md missing skills/ prefix on issue-operations-core/tasks/creation.md (line $MATCH_LINE)" \
            "Found bare reference at line $MATCH_LINE. Expected: skills/issue-operations-core/tasks/creation.md"
    fi
fi

# --- create.md line 145: issue-operations/platforms/local/tasks/push-artifacts.md ---
if grep -Eq '\(issue-operations/platforms/local/tasks/push-artifacts\.md\)' "$CREATE_MD"; then
    MATCH_LINE=$(grep -n 'issue-operations/platforms/local/tasks/push-artifacts\.md' "$CREATE_MD" | head -1 | cut -d: -f1)
    if grep -Eq '\(skills/issue-operations/platforms/local/tasks/push-artifacts\.md\)' "$CREATE_MD"; then
        check_pass "SC-39: create.md has skills/ prefix on issue-operations/platforms/local/tasks/push-artifacts.md (line $MATCH_LINE)"
    else
        check_fail "SC-39: create.md missing skills/ prefix on issue-operations/platforms/local/tasks/push-artifacts.md (line $MATCH_LINE)" \
            "Found bare reference at line $MATCH_LINE. Expected: skills/issue-operations/platforms/local/tasks/push-artifacts.md"
    fi
fi

# --- revise.md line 47: issue-operations-core/tasks/creation.md ---
if grep -Eq '\(issue-operations-core/tasks/creation\.md\)' "$REVISE_MD"; then
    MATCH_LINE=$(grep -n 'issue-operations-core/tasks/creation\.md' "$REVISE_MD" | head -1 | cut -d: -f1)
    if grep -Eq '\(skills/issue-operations-core/tasks/creation\.md\)' "$REVISE_MD"; then
        check_pass "SC-39: revise.md has skills/ prefix on issue-operations-core/tasks/creation.md (line $MATCH_LINE)"
    else
        check_fail "SC-39: revise.md missing skills/ prefix on issue-operations-core/tasks/creation.md (line $MATCH_LINE)" \
            "Found bare reference at line $MATCH_LINE. Expected: skills/issue-operations-core/tasks/creation.md"
    fi
fi

# ============================================================
# Summary
# ============================================================
echo ""
echo "=== Results: $PASS_COUNT PASS, $FAIL_COUNT FAIL ==="

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
