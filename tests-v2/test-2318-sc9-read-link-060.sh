#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: .opencode#2318 SC-9 — rule text uses Read-Link for
# the 060-tool-usage.md cross-reference.
#
# Maps to SC-9 from issue #2318:
#   Every cross-reference from the rule to other guidance uses the Read-Link
#   Cross-Reference Rule (Read [Text](path)).
#
# The rule text lives at .opencode/AGENTS.md:329-333 (the "Multi-Module Checkout —
# Root-Repo-Only Build Tooling" and "Submodule Toolchain Preservation" block).
# It currently has a Read-Link to 085-project-local-tools.md but NOT to
# 060-tool-usage.md. SC-9 requires the 060-tool-usage.md cross-reference to use
# the Read [Text](path) format.
#
# Evidence type: string — grep for the Read-Link form of the 060-tool-usage.md
# reference within the rule text block.
#
# RED state: the rule text block (lines 329-333) does NOT contain a Read-Link to
# 060-tool-usage.md. The assertion below asserts the Read-Link IS present; it
# FAILS now (RED) and PASSES after the GREEN phase adds the Read-Link.
#
# AGENTS.md is a regular tracked file in the .opencode repo (not the .issues/
# worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2318-sc9-read-link-060.sh
# Exit: 0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

AGENTS_MD="$PROJECT_DIR/AGENTS.md"

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
echo "=== SC-9: rule text Read-Link to 060-tool-usage.md (#2318) ==="
echo ""
echo "Target file: $AGENTS_MD"
echo "Rule text block: lines 329-333 (Multi-Module Checkout / Submodule Toolchain Preservation)"
echo ""

# SC-9: The rule text block (lines 329-333) MUST contain a Read-Link cross-reference
# to 060-tool-usage.md in the form 'Read [060-tool-usage.md](guidelines/060-tool-usage.md)'.
# The block currently lacks any 060-tool-usage.md reference, so this FAILS (RED).
RULE_BLOCK="$(sed -n '329,333p' "$AGENTS_MD")"

if grep -qF 'Read [060-tool-usage.md](guidelines/060-tool-usage.md)' <<<"$RULE_BLOCK"; then
    check_pass "SC-9: rule text block contains Read-Link to 060-tool-usage.md"
else
    check_fail "SC-9: rule text block contains Read-Link to 060-tool-usage.md" \
        "060-tool-usage.md Read-Link absent in rule text block (RED phase expected)"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-9 (#2318) 060-tool-usage.md Read-Link not yet added."
    echo "The rule text block at AGENTS.md:329-333 lacks the Read [060-tool-usage.md](guidelines/060-tool-usage.md) reference."
    echo ""
    exit 1
fi
exit 0
