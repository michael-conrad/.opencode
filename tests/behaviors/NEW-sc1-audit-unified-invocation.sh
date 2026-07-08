#!/bin/bash
# Behavioral test: sc1-audit-unified-invocation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Agent dispatches the `audit` skill with `--task spec-audit` when asked
#       to run a spec audit on a spec file.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc1-audit-unified-invocation"

# Create a temporary spec file for the prompt to reference
TMP_SPEC=$(mktemp /tmp/test-spec-sc1-XXXXXX.md)
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

SCENARIO_PROMPT="Run a spec audit on the spec at $TMP_SPEC to verify it has proper success criteria. Use the audit skill with spec-audit task."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

rm -f "$TMP_SPEC"
exit 0
