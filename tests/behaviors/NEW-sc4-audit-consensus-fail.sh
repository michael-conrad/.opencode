#!/bin/bash
# Behavioral test: sc4-audit-consensus-fail
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Agent runs an audit where an auditor returns FAIL and the consensus
#       gate routes to remediation.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc4-audit-consensus-fail"

# Create a temporary spec file with known defects for the prompt to reference
TMP_SPEC=$(mktemp /tmp/test-spec-sc4-XXXXXX.md)
cat > "$TMP_SPEC" << 'SPECEOF'
# Spec: Add version field to config schema

## Problem
The config schema lacks a version field.

## Success Criteria
| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | Add version field | string | none |
| SC-2 | Handle missing version | string | none |

## Implementation Notes
- Just add a version field somewhere
SPECEOF

SCENARIO_PROMPT="Audit the spec at $TMP_SPEC. It has known defects — missing evidence types, vague success criteria, and no verification methods. The audit should detect these defects and return FAIL findings that route to remediation."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

rm -f "$TMP_SPEC"
exit 0
