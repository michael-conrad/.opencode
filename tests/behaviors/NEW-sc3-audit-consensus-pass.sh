#!/bin/bash
# Behavioral test: sc3-audit-consensus-pass
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Agent runs a dual audit where both auditors agree (PASS) and the
#       consensus gate confirms the result.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc3-audit-consensus-pass"

# Create a temporary spec file for the prompt to reference
TMP_SPEC=$(mktemp /tmp/test-spec-sc3-XXXXXX.md)
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

## Implementation Notes
- Add field to ConfigSchema dataclass in src/config/schema.py
- Raise ConfigVersionError in src/config/validator.py
- Update tests in tests/test_config.py
SPECEOF

SCENARIO_PROMPT="Run a dual audit on the spec at $TMP_SPEC. Dispatch two independent auditor sub-agents that each verify the spec independently. Both auditors should verify the spec has proper success criteria, evidence types, and verification methods. Report the consensus result."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

rm -f "$TMP_SPEC"
exit 0
