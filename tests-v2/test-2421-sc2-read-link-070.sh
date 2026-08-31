#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: SC-2 — 075-docs-verification.md contains a
# Read [Text](path) link to the 070-environment.md live-registry directive.
#
# Maps to SC-2 from issue #2421: 075-docs-verification.md SHALL contain a
# Read [Text](path) link to the 070 directive (the live-registry verification
# of dependency versions), using the canonical Read-link pattern — not a
# "See file" citation — and without duplicating directive text.
#
# RED phase: 075-docs-verification.md does NOT yet contain a Read-link to the
# 070 directive — this test FAILS (exit 1).
# GREEN phase: after the Read-link is added, this test PASSES (exit 0).
#
# Usage: bash .opencode/tests-v2/test-2421-sc2-read-link-070.sh
# Exit: 0 if all checks pass (GREEN), 1 if any check fails (expected RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

GUIDELINE_FILE="$PROJECT_DIR/guidelines/075-docs-verification.md"

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
echo "=== SC-2: 075-docs-verification.md Read-link to 070 directive (#2421) ==="
echo ""
echo "Target file: $GUIDELINE_FILE"
echo ""

# SC-2: 075-docs-verification.md MUST contain a Read [Text](path) link to the
# 070-environment.md directive, using the canonical Read-link pattern (not a
# "See file" citation). The link is absent now, so this FAILS (RED).
if grep -qE 'Read \[[^]]+\]\([^)]*070-environment\.md\)' "$GUIDELINE_FILE"; then
    check_pass "SC-2: 075-docs-verification.md contains a Read-link to 070-environment.md"
else
    check_fail "SC-2: 075-docs-verification.md contains a Read-link to 070-environment.md" \
        "Read [Text](path) link to 070-environment.md absent in $GUIDELINE_FILE (RED phase expected)"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-2 (#2421) 070-environment.md Read-link not yet added."
    echo "075-docs-verification.md lacks the Read [Text](path) link to the 070 directive."
    echo ""
    exit 1
fi
exit 0
