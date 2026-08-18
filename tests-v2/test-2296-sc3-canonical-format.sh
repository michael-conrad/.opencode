#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: playwright-cli and completion-core MUST use the
# canonical numbered-checkbox sub-bullets dispatch format (no legacy Trigger
# Dispatch Table / Invocation sections).
#
# Maps to SC-3 from issue #2296. The canonical dispatch format (see
# spec-creation/SKILL.md) consists of numbered checkbox items, each followed by
# the three sub-bullets: `**Context passed:**`, `**Returns:**`,
# `**Execution mode:**`. The legacy table format uses a `## Trigger Dispatch
# Table` markdown table plus a `## Invocation` section instead.
#
# RED phase: playwright-cli and completion-core currently use the legacy table
# format. This test FAILS (non-zero exit) because both skills still contain the
# `## Trigger Dispatch Table` / `## Invocation` sections.
# GREEN phase: after conversion to the canonical numbered-checkbox sub-bullets
# format, this test PASSES (no legacy sections remain).
#
# Usage: bash .opencode/tests-v2/test-2296-sc3-canonical-format.sh
# Exit: 0 if all checks pass, 1 if any check fails
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILLS_DIR="$PROJECT_DIR/.opencode/skills"

TARGETS=(
    "playwright-cli"
    "completion-core"
)

PASS_COUNT=0
FAIL_COUNT=0
declare -a FLAGGED=()

check_fail() {
    local detail="$1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    FLAGGED+=("$detail")
    echo "  FAIL: $detail" >&2
}

check_pass() {
    local detail="$1"
    PASS_COUNT=$((PASS_COUNT + 1))
    echo "  PASS: $detail"
}

echo ""
echo "=== SC-3 — canonical numbered-checkbox sub-bullets dispatch format (#2296) ==="
echo "Targets: $SKILLS_DIR/{playwright-cli,completion-core}/SKILL.md"
echo ""

# ---------------------------------------------------------------------------
# Criterion A: No legacy `## Trigger Dispatch Table` section.
# Criterion B: No legacy `## Invocation` section.
# Criterion C: Canonical numbered-checkbox items present, each with the three
#              sub-bullets `**Context passed:**`, `**Returns:**`,
#              `**Execution mode:**`.
# ---------------------------------------------------------------------------

for skill in "${TARGETS[@]}"; do
    file="$SKILLS_DIR/$skill/SKILL.md"
    if [ ! -f "$file" ]; then
        check_fail "$skill/SKILL.md — file missing"
        continue
    fi

    echo "--- $skill ---"

    # Criterion A: no legacy Trigger Dispatch Table section
    if grep -qE '^## Trigger Dispatch Table' "$file"; then
        check_fail "$skill — legacy '## Trigger Dispatch Table' section present"
    else
        check_pass "$skill — no legacy '## Trigger Dispatch Table' section"
    fi

    # Criterion B: no legacy Invocation section
    if grep -qE '^## Invocation' "$file"; then
        check_fail "$skill — legacy '## Invocation' section present"
    else
        check_pass "$skill — no legacy '## Invocation' section"
    fi

    # Criterion C: canonical numbered-checkbox items with the three sub-bullets
    # A canonical dispatch item is a line starting with `- [ ] N.` (N a digit).
    item_count="$(grep -cE '^\- \[ \] [0-9]' "$file" || true)"
    if [ "${item_count:-0}" -lt 1 ]; then
        check_fail "$skill — no canonical numbered-checkbox dispatch items found"
    else
        check_pass "$skill — $item_count canonical numbered-checkbox item(s) present"
    fi

    for sub in "Context passed" "Returns" "Execution mode"; do
        if grep -qE "^\*\*${sub}:\*\*" "$file"; then
            check_pass "$skill — sub-bullet '**${sub}:**' present"
        else
            check_fail "$skill — missing canonical sub-bullet '**${sub}:**'"
        fi
    done

    echo ""
done

echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED expected: playwright-cli and completion-core use the legacy table"
    echo "dispatch format and SC-3 (GREEN) must convert them to the canonical"
    echo "numbered-checkbox sub-bullets format. Flagged violations:"
    printf '  - %s\n' "${FLAGGED[@]}"
    echo ""
    exit 1
fi
echo "Both playwright-cli and completion-core use the canonical format (GREEN)."
echo ""
exit 0
