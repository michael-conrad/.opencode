#!/bin/bash
# Behavioral test: sc19-audit-auto-invocation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-19: Audit fires automatically as part of a consuming skill's Operating
#        Protocol — the developer does NOT need to explicitly request
#        `audit #NNN`. The consuming skill triggers audit on its own.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc19-audit-auto-invocation"

# Create a temporary spec file for the prompt to reference
TMP_SPEC=$(mktemp /tmp/test-spec-sc19-XXXXXX.md)
cat > "$TMP_SPEC" << 'SPECEOF'
# Spec: Add user authentication

## Problem
The application has no user authentication — anyone can access any endpoint.

## Success Criteria
| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | Login endpoint accepts email and password | behavioral | pytest test_login_endpoint |
| SC-2 | Invalid credentials return 401 | behavioral | pytest test_invalid_credentials |
| SC-3 | Valid credentials return JWT token | behavioral | pytest test_valid_credentials_returns_jwt |
| SC-4 | JWT token expires after 24 hours | behavioral | pytest test_jwt_expiry |
SPECEOF

SCENARIO_PROMPT="Create a spec for a new feature that adds user authentication. Use the spec-creation pipeline to produce the spec at $TMP_SPEC. The spec-creation pipeline should automatically trigger the appropriate audit as part of its Operating Protocol — do NOT wait for me to explicitly request 'audit #NNN'."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

rm -f "$TMP_SPEC"
exit 0
