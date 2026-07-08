#!/bin/bash
# Behavioral test: sc5-audit-consensus-disagree
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: Agent runs a dual audit where auditors disagree on findings and
#       revision options are presented.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc5-audit-consensus-disagree"

# Create a temporary spec file with ambiguous criteria that could trigger disagreement
TMP_SPEC=$(mktemp /tmp/test-spec-sc5-XXXXXX.md)
cat > "$TMP_SPEC" << 'SPECEOF'
# Spec: Add version field to config schema

## Problem
The config schema lacks a version field, making it impossible to detect schema drift.

## Success Criteria
| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | Config schema has a `version` field | string | grep for version in schema.py |
| SC-2 | Missing version raises error | behavioral | pytest test_config_version_missing |
| SC-3 | Version field is optional | string | grep for default value |

## Implementation Notes
- Add field to ConfigSchema dataclass in src/config/schema.py
- Raise ConfigVersionError in src/config/validator.py
- Update tests in tests/test_config.py
SPECEOF

SCENARIO_PROMPT="Run a dual audit on the spec at $TMP_SPEC. Dispatch two independent auditor sub-agents. The spec has mixed evidence types — some SCs use string evidence where behavioral would be more appropriate. The auditors may disagree on whether string evidence is sufficient. If they disagree, present revision options for resolving the disagreement."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

rm -f "$TMP_SPEC"
exit 0
