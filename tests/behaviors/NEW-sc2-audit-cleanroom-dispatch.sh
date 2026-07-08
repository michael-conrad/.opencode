#!/bin/bash
# Behavioral test: sc2-audit-cleanroom-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: Agent dispatches an audit sub-agent WITHOUT passing verifier context
#       or preloaded findings — clean-room dispatch.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc2-audit-cleanroom-dispatch"

# Create a temporary spec and plan file for the prompt to reference
TMP_SPEC=$(mktemp /tmp/test-spec-sc2-XXXXXX.md)
TMP_PLAN=$(mktemp /tmp/test-plan-sc2-XXXXXX.md)
cat > "$TMP_SPEC" << 'SPECEOF'
# Spec: Add version field to config schema

## Problem
The config schema lacks a version field, making it impossible to detect schema drift.

## Success Criteria
| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | Config schema has a `version` field of type `string` | behavioral | pytest test_config_version_exists |
| SC-2 | Missing version field raises `ConfigVersionError` | behavioral | pytest test_config_version_missing |
SPECEOF

cat > "$TMP_PLAN" << 'PLANEOF'
# Plan: Add version field to config schema

## Phase 1: Schema update
Add `version: str = "1.0.0"` field to ConfigSchema class.

## Phase 2: Validation
Add ConfigVersionError exception and validation logic.

## Phase 3: Tests
Write pytest tests for version field presence and error handling.
PLANEOF

SCENARIO_PROMPT="Audit the plan at $TMP_PLAN for fidelity against its spec at $TMP_SPEC. Do not include any prior verification results or cached findings — dispatch a clean audit sub-agent that discovers the scope independently."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

rm -f "$TMP_SPEC" "$TMP_PLAN"
exit 0
