#!/bin/bash
# Behavioral test: sc6-audit-multi-type
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: Agent runs both spec-audit and plan-fidelity checks in a single
#       invocation when asked to audit both a spec and its associated plan.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc6-audit-multi-type"

# Create temporary spec and plan files for the prompt to reference
TMP_SPEC=$(mktemp /tmp/test-spec-sc6-XXXXXX.md)
TMP_PLAN=$(mktemp /tmp/test-plan-sc6-XXXXXX.md)
cat > "$TMP_SPEC" << 'SPECEOF'
# Spec: Add version field to config schema

## Problem
The config schema lacks a version field, making it impossible to detect schema drift.

## Success Criteria
| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | Config schema has a `version` field of type `string` | behavioral | pytest test_config_version_exists |
| SC-2 | Missing version field raises `ConfigVersionError` | behavioral | pytest test_config_version_missing |
| SC-3 | Version field is optional with default `1.0.0` | behavioral | pytest test_config_version_default |
SPECEOF

cat > "$TMP_PLAN" << 'PLANEOF'
# Plan: Add version field to config schema

## Phase 1: Schema update
Add `version: str = "1.0.0"` field to ConfigSchema class in src/config/schema.py.

## Phase 2: Validation
Add ConfigVersionError exception in src/config/exceptions.py.
Add validation logic in src/config/validator.py that checks version field.

## Phase 3: Tests
Write pytest tests in tests/test_config.py:
- test_config_version_exists
- test_config_version_missing
- test_config_version_default
PLANEOF

SCENARIO_PROMPT="Run both a spec audit and a plan fidelity check on the spec at $TMP_SPEC and its associated plan at $TMP_PLAN. Verify the spec has proper success criteria and the plan faithfully implements each SC."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

rm -f "$TMP_SPEC" "$TMP_PLAN"
exit 0
