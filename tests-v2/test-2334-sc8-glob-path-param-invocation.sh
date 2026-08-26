#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: 2334-sc8-glob-path-param-invocation
# Maps to SC-8 from issue #2334. This is the SECONDARY content-verification
# companion to the PRIMARY behavioral scenario
# `.opencode/tests-v2/behaviors/2334-sc8-glob-path-param-invocation.sh`.
#
# SC-8: A registered behavioral enforcement test demonstrates via stderr assertions
# that an agent instructed to enumerate files under .opencode/ emits a working
# path-parameter invocation action instead of concluding nonexistence from a
# silent-empty result.
#
# This standalone check asserts (structural) that the behavioral scenario exists,
# registers in the harness, and asks the agent to enumerate real files (not a
# prose-recall interview). The behavioral PASS is decided by clean-room evaluation
# of the session.yaml artifact produced by behaviors/<scenario>.sh — file presence
# here is supplementary only.
#
# Usage: bash .opencode/tests-v2/test-2334-sc8-glob-path-param-invocation.sh
# Exit: 0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SCENARIO="$PROJECT_DIR/.opencode/tests-v2/behaviors/2334-sc8-glob-path-param-invocation.sh"
ENFORCEMENT="$PROJECT_DIR/.opencode/tests-v2/test-enforcement.sh"

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
echo "=== SC-8 behavioral scenario registration (#2334) ==="
echo ""
echo "Scenario file: $SCENARIO"
echo "Harness:       $ENFORCEMENT"
echo ""

# (a) The behavioral scenario script exists and is a real-domain task.
if [ -f "$SCENARIO" ]; then
    check_pass "SC-8: behavioral scenario script exists"
else
    check_fail "SC-8: behavioral scenario script exists" "missing $SCENARIO"
fi

# (b) The prompt is a real-domain enumeration task, not a prose-recall interview.
if grep -q 'SCENARIO_PROMPT="Enumerate the markdown files' "$SCENARIO" 2>/dev/null; then
    check_pass "SC-8: scenario is a real-domain file-enumeration task"
else
    check_fail "SC-8: scenario is a real-domain file-enumeration task" \
        "SCENARIO_PROMPT does not name a real file-enumeration task"
fi

# (c) The scenario invokes behavior_run (artifact-only generator paradigm).
if grep -q 'behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"' "$SCENARIO" 2>/dev/null; then
    check_pass "SC-8: scenario calls behavior_run (artifact-only generator)"
else
    check_fail "SC-8: scenario calls behavior_run (artifact-only generator)" \
        "behavior_run invocation missing"
fi

# (d) The scenario is registered in test-enforcement.sh.
if grep -q '2334-sc8-glob-path-param-invocation' "$ENFORCEMENT" 2>/dev/null; then
    check_pass "SC-8: scenario registered in test-enforcement.sh"
else
    check_fail "SC-8: scenario registered in test-enforcement.sh" \
        "no 2334-sc8 registration in $ENFORCEMENT"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
