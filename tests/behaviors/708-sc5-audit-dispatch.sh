#!/bin/bash
# Behavioral test: 708-sc5-audit-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (opencode/deepseek-v4-flash-free)
#
# Behavioral Enforcement Test: SC-5 from #708 — audit dispatch uses auditor-* types
#
# Verifies that when given an adversarial audit task, the orchestrator:
# 1. Loads the audit skill (visible in stderr)
# 2. References auditor-specific dispatch types in response (not "general")
#
# Uses a real audit scenario (not a prose-recall prompt) and checks
# stderr for behavioral evidence of correct routing.
#
# Behavioral TDD cycle:
#   RED:   Behavioral test expects agent to use auditor-* dispatch (test fails)
#   GREEN: Skill routing changes make agent follow the rule
#   REFACTOR: Content-verification also passes
#
# Co-authored with AI: OpenCode (deepseek-v4-flash-free)

set -euo pipefail

BEHAVIOR_TIMEOUT=300

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="708-sc5-audit-dispatch"

# Create a real spec file for the audit scenario
TMP_SPEC_DIR="$PROJECT_DIR/tmp"
mkdir -p "$TMP_SPEC_DIR"
TMP_SPEC="$TMP_SPEC_DIR/test-spec-708-sc5.md"

cat > "$TMP_SPEC" << 'SPEC'
---
number: 7085
title: "[SPEC] Fix session timeout handling"
status: "1.0 DRAFT"
labels: [spec]
---

# Fix Session Timeout Handling

## Problem Statement

Users experience intermittent session timeouts during peak usage hours,
causing data loss and frequent re-login requirements.

## Root Cause

The session management service uses a fixed 5-minute timeout with no
refresh mechanism. During peak load, request processing delays exceed
the timeout window, causing premature session termination.

## Fix Approach

Implement a sliding window timeout that resets on each authenticated
request, with a minimum 10-minute absolute timeout as a safety bound.
SPEC

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo ""

SCENARIO_PROMPT="Perform an adversarial audit of the spec at $TMP_SPEC"

behavior_run_pool "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

echo ""
echo "--- Assertions ---"

# SC-5: Orchestrator loads audit skill (stderr evidence)
assert_stderr_pattern_present_all_models \
    'Skill "audit"' \
    "audit skill loaded in stderr" \
    || OVERALL_RESULT=1

# SC-5: Response references auditor dispatch (not "general" for auditors)
# The agent should mention auditor-specific types or cross-validation
assert_required_pattern_present_all_models \
    "auditor" \
    "auditor dispatch mention in response" \
    || OVERALL_RESULT=1

# SC-5: Response does NOT say it would use "general" for auditor dispatch
# (checking the specific pattern that would indicate routing failure)
assert_forbidden_pattern_absent_all_models \
    "general.*auditor\|auditor.*general" \
    "general used for auditor dispatch" \
    || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
