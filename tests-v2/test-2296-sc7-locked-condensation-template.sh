#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: the locked condensation dispatch template
# MUST be specified in reference/skill-card-description-standards.md.
#
# Maps to SC-7 from issue #2296. The locked condensation dispatch template is:
#     You are a sub-agent. Follow the instructions in [<condensation>](<path>). <context-fields>
#
# The `[<condensation>](<path>)` markdown link form is the locked dispatch
# anchor — it names the condensation (the purpose/outcome-as-subject source
# specified by SC-6) as the link text and its path as the link target.
#
# RED phase: the base prompt template currently uses the path-restatement form
# `[<skill>/tasks/<task>.md](.opencode/skills/<skill>/tasks/<task>.md)` — NOT the
# locked condensation form `[<condensation>](<path>)`. This test FAILS (non-zero
# exit) because the locked condensation dispatch template is not yet specified.
# GREEN phase: after the base prompt template is updated to the locked
# condensation dispatch template, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2296-sc7-locked-condensation-template.sh
# Exit: 0 if all checks pass, 1 if any check fails
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

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
echo "=== SC-7 — locked condensation dispatch template (#2296) ==="
echo "Target: .opencode/reference/skill-card-description-standards.md"
echo ""

REFERENCE_FILE="$PROJECT_DIR/.opencode/reference/skill-card-description-standards.md"

if [ ! -f "$REFERENCE_FILE" ]; then
    check_fail "reference file missing: $REFERENCE_FILE"
    echo ""
    echo "=== Results ==="
    echo "PASSED: $PASS_COUNT"
    echo "FAILED: $FAIL_COUNT"
    echo ""
    exit 1
fi

# ---------------------------------------------------------------------------
# SC-7: The locked condensation dispatch template must be specified.
#
# The condensation link `[<condensation>](<path>)` must appear in the base
# prompt template. We assert on the link syntax `[<condensation>](` which is
# the exact locked form — the placeholder link text `<condensation>` with a
# parenthesized `<path>` target.
# ---------------------------------------------------------------------------

# Criterion A: the locked condensation link form `[<condensation>](` is present
if grep -qE '\[<condensation>\]\(' "$REFERENCE_FILE"; then
    check_pass "locked condensation link form '[<condensation>](' present"
else
    check_fail "locked condensation link form '[<condensation>](' not present" \
        "base prompt template uses the path-restatement form '[<skill>/tasks/<task>.md]', not the locked condensation form"
fi

# Criterion B: the full template line (with the context-fields trailer) is present
if grep -qE '\[<condensation>\]\(<path>\).*<context-fields>' "$REFERENCE_FILE"; then
    check_pass "full locked condensation template line present"
else
    check_fail "full locked condensation template line absent" \
        "expected: 'You are a sub-agent. Follow the instructions in [<condensation>](<path>). <context-fields>'"
fi

# Criterion C: the literal placeholder must NOT be left as a path-restatement
# (no `<skill>/tasks/<task>.md` in the base prompt template).
if grep -qE '\[<skill>/tasks/<task>\.md\]\(\.opencode/skills/<skill>/tasks/<task>\.md\)' "$REFERENCE_FILE"; then
    check_fail "base prompt template still uses path-restatement form" \
        "the base prompt template MUST use [<condensation>](<path>), not the path-restatement form"
else
    check_pass "base prompt template uses the locked condensation form"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED expected: the base prompt template currently uses the path-restatement"
    echo "form '[<skill>/tasks/<task>.md]', so the locked condensation dispatch"
    echo "template '[<condensation>](<path>)' is NOT yet specified. Flagged violations:"
    printf '  - %s\n' "${FLAGGED[@]}"
    echo ""
    exit 1
fi
echo "The locked condensation dispatch template is specified (GREEN)."
echo ""
exit 0
