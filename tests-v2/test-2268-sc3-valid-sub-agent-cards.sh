#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: both sub-agent cards are valid opencode cards
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Issue: .opencode#2268 — Add vision-agent and visual-design-agent sub-agent cards.
#
# SC-3: Both files are valid opencode sub-agent cards (correct frontmatter fields,
#       `mode: subagent`, provider-prefixed model ID).
#
# Evidence type: structural (frontmatter parse).
#
# RED state: `.opencode/agents/vision-agent.md` and
# `.opencode/agents/visual-design-agent.md` do not exist yet — the file
# existence checks and the frontmatter checks all FAIL. This is the expected RED.
#
# Usage: bash .opencode/tests-v2/test-2268-sc3-valid-sub-agent-cards.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

TARGET_FILES=(
    "$PROJECT_DIR/.opencode/agents/vision-agent.md"
    "$PROJECT_DIR/.opencode/agents/visual-design-agent.md"
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
echo "=== SC-3: both sub-agent cards are valid opencode cards ==="
echo ""
echo "Target files:"
for f in "${TARGET_FILES[@]}"; do
    echo "  $f"
done
echo ""

# SC-3: both card files must exist
for f in "${TARGET_FILES[@]}"; do
    if [ -f "$f" ]; then
        check_pass "SC-3: $(basename "$f") exists"
    else
        check_fail "SC-3: $(basename "$f") exists" "file not found (expected RED — file created in GREEN phase)"
    fi
done

# SC-3: each file must contain the required frontmatter fields and values.
# Required fields: description, mode, model, temperature, top_p, top_k, options, permission.
# Required values: mode: subagent, model starts with ollama-cloud/ provider prefix.
for f in "${TARGET_FILES[@]}"; do
    if [ ! -f "$f" ]; then
        continue
    fi
    name="$(basename "$f")"

    # SC-3: frontmatter block must be present (starts with --- and has a closing ---)
    if grep -q '^---$' "$f"; then
        check_pass "SC-3: $name has frontmatter delimiters"
    else
        check_fail "SC-3: $name has frontmatter delimiters" "no '---' delimiter found"
    fi

    # SC-3: required frontmatter fields present
    for field in description mode model temperature top_p top_k options permission; do
        if grep -q "^${field}:" "$f"; then
            check_pass "SC-3: $name has frontmatter field '$field'"
        else
            check_fail "SC-3: $name has frontmatter field '$field'" "field '$field' missing"
        fi
    done

    # SC-3: mode must be subagent
    if grep -q '^mode: subagent$' "$f"; then
        check_pass "SC-3: $name mode is 'subagent'"
    else
        check_fail "SC-3: $name mode is 'subagent'" "mode value is not 'subagent'"
    fi

    # SC-3: model ID must be provider-prefixed with ollama-cloud/
    if grep -q '^model: ollama-cloud/' "$f"; then
        check_pass "SC-3: $name model ID is provider-prefixed (ollama-cloud/)"
    else
        check_fail "SC-3: $name model ID is provider-prefixed (ollama-cloud/)" \
            "model ID does not start with 'ollama-cloud/'"
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-3 (valid sub-agent cards) not yet satisfied."
    echo "The card files do not exist or do not parse as valid opencode sub-agent"
    echo "cards; the content-verification test fails until the GREEN phase"
    echo "creates both cards with valid frontmatter, mode: subagent, and"
    echo "provider-prefixed model IDs."
    echo ""
    exit 1
fi
exit 0
