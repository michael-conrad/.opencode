#!/bin/bash
# Behavioral test: sc14-audit-cross-validate-evidence-type-gate
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-14: Cross-validate rejects structural evidence for behavioral SCs with
#        EVIDENCE_TYPE_MISMATCH — file existence is not behavioral evidence.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc14-audit-cross-validate-evidence-type-gate"

# Create a temporary spec file with behavioral SCs
TMP_SPEC=$(mktemp /tmp/test-spec-sc14-XXXXXX.md)
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

# Create a mock evidence directory with only structural evidence (file existence)
TMP_EVIDENCE=$(mktemp -d /tmp/test-evidence-sc14-XXXXXX)
echo "file exists" > "$TMP_EVIDENCE/config_schema.py"
echo "file exists" > "$TMP_EVIDENCE/test_config.py"

SCENARIO_PROMPT="Cross-validate the audit results for the spec at $TMP_SPEC. The auditor submitted structural evidence only — file existence checks at $TMP_EVIDENCE — for behavioral SCs (SC-1, SC-2, SC-3). Reject this with EVIDENCE_TYPE_MISMATCH: behavioral SCs require behavioral evidence (test execution), not file existence."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

rm -f "$TMP_SPEC"
rm -rf "$TMP_EVIDENCE"
exit 0
