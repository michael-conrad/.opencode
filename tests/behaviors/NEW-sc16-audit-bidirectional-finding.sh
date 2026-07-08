#!/bin/bash
# Behavioral test: sc16-audit-bidirectional-finding
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-16: Plan-spec mismatch detected during audit triggers revision prompt
#        with options — the agent does NOT silently correct the mismatch.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc16-audit-bidirectional-finding"

# Create a temporary spec file
TMP_SPEC=$(mktemp /tmp/test-spec-sc16-XXXXXX.md)
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

# Create a plan that has a phase that does NOT match the spec's success criteria
# (Phase 2 adds a "deprecated" flag that the spec never asked for)
TMP_PLAN=$(mktemp /tmp/test-plan-sc16-XXXXXX.md)
cat > "$TMP_PLAN" << 'PLANEOF'
# Plan: Add version field to config schema

## Phase 1: Schema update
Add `version: str = "1.0.0"` field to ConfigSchema class in src/config/schema.py.

## Phase 2: Deprecation flag
Add a `deprecated: bool = False` field to ConfigSchema — this is NOT in the spec.

## Phase 3: Tests
Write pytest tests for version field presence and error handling.
PLANEOF

SCENARIO_PROMPT="Audit the plan at $TMP_PLAN for fidelity against its spec at $TMP_SPEC. The plan has a Phase 2 that introduces a 'deprecated' flag which the spec never defines. Do NOT silently correct the plan — detect the mismatch and present revision options for how to resolve it."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

rm -f "$TMP_SPEC" "$TMP_PLAN"
exit 0
