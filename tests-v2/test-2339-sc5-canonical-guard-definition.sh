#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: .opencode#2339 SC-5 — the four skill card
# requirements documentation documents define a single canonical guard
# definition that is consistent across all four.
#
# Maps to SC-5 from issue #2339:
#   The skill card requirements documentation (skill-card-schema.md,
#   skill-card-description-standards.md, skill-card-spec.md,
#   routing-only-template.md) defines a single canonical guard definition
#   consistent across all reference documents.
#
# Evidence type: string — grep the four reference documents for the canonical
# guard definition marker (## Canonical Guard Definition) and assert it is
# present in all four with an identical guard block (single source of truth).
#
# RED state: none of the four documents contained the canonical guard
# definition section. The assertions below assert it IS present in all four
# and that the guard block is byte-identical; they FAIL now (RED) and PASS
# after the GREEN phase adds the canonical definition to all four.
#
# Usage: bash .opencode/tests-v2/test-2339-sc5-canonical-guard-definition.sh
# Exit: 0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

DOCS=(
    "$PROJECT_DIR/reference/skill-card-schema.md"
    "$PROJECT_DIR/reference/skill-card-description-standards.md"
    "$PROJECT_DIR/skills/skill-creator/reference/skill-card-spec.md"
    "$PROJECT_DIR/skills/skill-creator/reference/routing-only-template.md"
)

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
echo "=== SC-5: canonical guard definition present and consistent in four reference docs (#2339) ==="
echo ""

# Extract the canonical guard definition block: from the "## Canonical Guard
# Definition" heading through the first closing fenced code block.
extract_canonical_block() {
    local doc="$1"
    awk '/^## Canonical Guard Definition/{flag=1} flag{print} flag && /^```$/{exit}' "$doc"
}

BLOCKS=()
for doc in "${DOCS[@]}"; do
    name="$(basename "$doc")"
    if [ ! -f "$doc" ]; then
        check_fail "SC-5: $name exists" "missing $doc"
        continue
    fi

    if grep -q '^## Canonical Guard Definition' "$doc"; then
        check_pass "SC-5: $name contains the canonical guard definition section"
    else
        check_fail "SC-5: $name contains the canonical guard definition section" \
            "canonical guard definition heading absent in $name (RED phase expected)"
    fi

    block="$(extract_canonical_block "$doc")"
    if [ -z "$block" ]; then
        check_fail "SC-5: $name canonical guard block non-empty" \
            "canonical guard definition block empty/missing in $name"
    fi
    BLOCKS+=("$block")
done

# Assert a single consistent canonical definition across all four documents:
# every extracted block must be byte-identical.
if [ "$FAIL_COUNT" -eq 0 ]; then
    first="${BLOCKS[0]}"
    consistent=1
    for block in "${BLOCKS[@]}"; do
        if [ "$block" != "$first" ]; then
            consistent=0
            break
        fi
    done

    if [ "$consistent" -eq 1 ]; then
        check_pass "SC-5: canonical guard definition is identical across all four documents"
    else
        check_fail "SC-5: canonical guard definition is identical across all four documents" \
            "canonical guard definition blocks differ across documents (inconsistent)"
    fi
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-5 (#2339) canonical guard definition not yet added/consistent in the four reference docs."
    echo ""
    exit 1
fi
exit 0
