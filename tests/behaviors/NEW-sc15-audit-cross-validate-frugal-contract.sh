#!/bin/bash
# Behavioral test: sc15-audit-cross-validate-frugal-contract
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-15: Cross-validate returns a frugal result contract containing only
#        status, finding_summary, and artifact_path — no full evidence bodies.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc15-audit-cross-validate-frugal-contract"

# Create a temporary spec file
TMP_SPEC=$(mktemp /tmp/test-spec-sc15-XXXXXX.md)
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

# Create a mock evidence directory with behavioral test artifacts
TMP_EVIDENCE=$(mktemp -d /tmp/test-evidence-sc15-XXXXXX)
cat > "$TMP_EVIDENCE/pytest-output.log" << 'EVLOG'
test_config_version_exists PASSED
test_config_version_missing PASSED
EVLOG

SCENARIO_PROMPT="Run cross-validate on the dual audit results for spec at $TMP_SPEC. Evidence artifacts are at $TMP_EVIDENCE. Return only the essential routing data: status (PASS/FAIL), finding_summary (1-3 sentences), and artifact_path. Do NOT include full evidence bodies, raw logs, or verbose output in the result contract."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

rm -f "$TMP_SPEC"
rm -rf "$TMP_EVIDENCE"
exit 0
