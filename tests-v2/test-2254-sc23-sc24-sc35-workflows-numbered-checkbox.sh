#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-23, SC-24, SC-35 — Workflows
# sections use numbered-checkbox lists with execution-mode sub-bullets.
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-20-numbered-checkbox-workflows-format.
#
# SC-23 (string): spec-creation/SKILL.md Workflows section SHALL use numbered
#   checkbox lists (`- [ ] N.`) with sub-bullets for the prompt string, the
#   passed parameters/context, and an execution-mode indicator (inline vs
#   sub-agent dispatch).
# SC-24 (string): audit/SKILL.md Workflows section SHALL use numbered
#   checkbox lists (`- [ ] N.`) with sub-bullets for the prompt string, the
#   passed parameters/context, and an execution-mode indicator (inline vs
#   sub-agent dispatch).
# SC-35 (string): reference/skill-card-description-standards.md §7 SHALL
#   specify the Workflows section as numbered-checkbox lists (`- [ ] N.`) with
#   sub-bullets for the prompt string, the passed parameters/context, and an
#   execution-mode indicator (inline vs sub-agent dispatch), replacing the
#   current plain numbered-list format.
#
# RED state: All three Workflows sections use the OLD plain numbered-list
#   format with `1.` / `2.` / `3.` list markers and only Context/Returns
#   sub-bullets — no numbered checkbox (`- [ ] N.`) markers and no
#   execution-mode sub-bullet. The assertions below FAIL on this content.
# GREEN converts each Workflows section to numbered-checkbox lists with
#   sub-bullets for the prompt string, the passed parameters/context, and an
#   execution-mode indicator.
#
# Evidence type: All three SCs are `string` SCs. This content-verification
#   test greps the target files for numbered-checkbox workflow steps and
#   execution-mode sub-bullets. It is the primary gate for these content-only
#   SCs (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc23-sc24-sc35-workflows-numbered-checkbox.sh
# Exit:  0 if all three targets use numbered-checkbox with execution-mode
#        sub-bullets (GREEN), 1 if any target still uses the old plain
#        numbered-list format (RED).

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
echo "=== SC-23 / SC-24 / SC-35 — Workflows sections use numbered-checkbox with execution-mode sub-bullets (Spec .opencode#2254) ==="
echo ""

# Extract a Workflows section (from `## Workflows` to the next `## ` heading).
extract_workflows() {
    local file="$1"
    awk '/^## Workflows/{flag=1; next} /^## /{if (flag) exit} flag' "$file"
}

# ---------------------------------------------------------------------------
# SC-35 (string): reference/skill-card-description-standards.md §7 SHALL
#   specify the Workflows section as numbered-checkbox lists (`- [ ] N.`)
#   with sub-bullets for the prompt string, the passed parameters/context,
#   and an execution-mode indicator, replacing the current plain
#   numbered-list format. §7 is "7. Workflows Section with Sub-Bullet
#   Dispatch Contracts"; its body contains the canonical Workflows code
#   example, which must use numbered-checkbox markers.
# ---------------------------------------------------------------------------
REFERENCE="$PROJECT_DIR/.opencode/reference/skill-card-description-standards.md"
echo "Target (SC-35): $REFERENCE"

if [ ! -f "$REFERENCE" ]; then
    check_fail "SC-35: target file exists" "skill-card-description-standards.md not found"
else
    # §7 is a heading 7 section; capture its body up to the next numbered
    # top-level section (## 8.). Its body contains a nested `## Workflows`
    # example code block, so we must NOT stop at any `## ` heading — only at
    # the next numbered top-level section.
    REF_SECTION="$(awk '/^## 7\. Workflows Section/{flag=1; next} /^## [0-9]+\./{if (flag) exit} flag' "$REFERENCE")"
    if [ -z "$REF_SECTION" ]; then
        check_fail "SC-35: §7 Workflows Section body extracted" "no §7 'Workflows Section' heading found"
    else
        # Numbered-checkbox workflow step marker `- [ ] N.` must be present.
        if echo "$REF_SECTION" | grep -qE '^- \[ \] [0-9]+\.'; then
            check_pass "SC-35: §7 example uses numbered-checkbox markers (- [ ] N.)"
        else
            check_fail "SC-35: §7 example uses numbered-checkbox markers" \
                "no '- [ ] N.' marker in §7 Workflows Section body"
        fi
        # Execution-mode sub-bullet must be specified.
        if echo "$REF_SECTION" | grep -qi "execution mode\|execution-mode"; then
            check_pass "SC-35: §7 specifies an execution-mode sub-bullet"
        else
            check_fail "SC-35: §7 specifies an execution-mode sub-bullet" \
                "no 'execution mode' language in §7"
        fi
        # Prompt sub-bullet must be specified.
        if echo "$REF_SECTION" | grep -qi "prompt"; then
            check_pass "SC-35: §7 specifies a prompt sub-bullet"
        else
            check_fail "SC-35: §7 specifies a prompt sub-bullet" "no prompt language in §7"
        fi
        # Parameters/context sub-bullet must be specified.
        if echo "$REF_SECTION" | grep -qi "context"; then
            check_pass "SC-35: §7 specifies a context sub-bullet"
        else
            check_fail "SC-35: §7 specifies a context sub-bullet" "no context language in §7"
        fi
    fi
fi

echo ""

# ---------------------------------------------------------------------------
# SC-23 (string): spec-creation/SKILL.md Workflows section SHALL use
#   numbered-checkbox lists (`- [ ] N.`) with sub-bullets for the prompt
#   string, the passed parameters/context, and an execution-mode indicator.
# ---------------------------------------------------------------------------
SPEC_CREATION="$PROJECT_DIR/.opencode/skills/spec-creation/SKILL.md"
echo "Target (SC-23): $SPEC_CREATION"

if [ ! -f "$SPEC_CREATION" ]; then
    check_fail "SC-23: target file exists" "spec-creation/SKILL.md not found"
else
    WORKFLOWS="$(extract_workflows "$SPEC_CREATION")"
    if [ -z "$WORKFLOWS" ]; then
        check_fail "SC-23: Workflows section extracted" "no '## Workflows' heading found"
    else
        if echo "$WORKFLOWS" | grep -qE '^- \[ \] [0-9]+\.'; then
            check_pass "SC-23: Workflows uses numbered-checkbox markers (- [ ] N.)"
        else
            check_fail "SC-23: Workflows uses numbered-checkbox markers" \
                "no '- [ ] N.' marker in spec-creation Workflows section"
        fi
        if echo "$WORKFLOWS" | grep -qi "execution mode\|execution-mode"; then
            check_pass "SC-23: Workflows has an execution-mode sub-bullet"
        else
            check_fail "SC-23: Workflows has an execution-mode sub-bullet" \
                "no 'execution mode' language in spec-creation Workflows section"
        fi
        if echo "$WORKFLOWS" | grep -qi "prompt"; then
            check_pass "SC-23: Workflows has a prompt sub-bullet"
        else
            check_fail "SC-23: Workflows has a prompt sub-bullet" \
                "no prompt language in spec-creation Workflows section"
        fi
        if echo "$WORKFLOWS" | grep -qi "context passed\|passed.*context\|context"; then
            check_pass "SC-23: Workflows has a parameters/context sub-bullet"
        else
            check_fail "SC-23: Workflows has a parameters/context sub-bullet" \
                "no context language in spec-creation Workflows section"
        fi
    fi
fi

echo ""

# ---------------------------------------------------------------------------
# SC-24 (string): audit/SKILL.md Workflows section SHALL use numbered-checkbox
#   lists (`- [ ] N.`) with sub-bullets for the prompt string, the passed
#   parameters/context, and an execution-mode indicator.
# ---------------------------------------------------------------------------
AUDIT="$PROJECT_DIR/.opencode/skills/audit/SKILL.md"
echo "Target (SC-24): $AUDIT"

if [ ! -f "$AUDIT" ]; then
    check_fail "SC-24: target file exists" "audit/SKILL.md not found"
else
    WORKFLOWS="$(extract_workflows "$AUDIT")"
    if [ -z "$WORKFLOWS" ]; then
        check_fail "SC-24: Workflows section extracted" "no '## Workflows' heading found"
    else
        if echo "$WORKFLOWS" | grep -qE '^- \[ \] [0-9]+\.'; then
            check_pass "SC-24: Workflows uses numbered-checkbox markers (- [ ] N.)"
        else
            check_fail "SC-24: Workflows uses numbered-checkbox markers" \
                "no '- [ ] N.' marker in audit Workflows section"
        fi
        if echo "$WORKFLOWS" | grep -qi "execution mode\|execution-mode"; then
            check_pass "SC-24: Workflows has an execution-mode sub-bullet"
        else
            check_fail "SC-24: Workflows has an execution-mode sub-bullet" \
                "no 'execution mode' language in audit Workflows section"
        fi
        if echo "$WORKFLOWS" | grep -qi "prompt"; then
            check_pass "SC-24: Workflows has a prompt sub-bullet"
        else
            check_fail "SC-24: Workflows has a prompt sub-bullet" \
                "no prompt language in audit Workflows section"
        fi
        if echo "$WORKFLOWS" | grep -qi "context passed\|passed.*context\|context"; then
            check_pass "SC-24: Workflows has a parameters/context sub-bullet"
        else
            check_fail "SC-24: Workflows has a parameters/context sub-bullet" \
                "no context language in audit Workflows section"
        fi
    fi
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-23, SC-24, SC-35 not yet implemented."
    echo "All three Workflows sections still use the old plain numbered-list"
    echo "format (1. / 2. / 3.) with only Context/Returns sub-bullets — no"
    echo "numbered-checkbox markers and no execution-mode sub-bullet."
    echo "GREEN converts each Workflows section to numbered-checkbox lists with"
    echo "sub-bullets for the prompt string, the passed parameters/context, and"
    echo "an execution-mode indicator."
    echo ""
    exit 1
fi
echo "SC-23, SC-24, SC-35 are GREEN — the reference §7 and both main SKILL.md"
echo "Workflows sections use numbered-checkbox lists with execution-mode"
echo "sub-bullets (prompt string, passed parameters/context, execution-mode"
echo "indicator)."
echo ""
exit 0
