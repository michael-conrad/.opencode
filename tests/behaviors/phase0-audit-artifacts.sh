#!/bin/bash
# Behavioral Enforcement Test: Audit Artifact Permanence
#
# Verifies that the agent recognizes audit baselines and historical data
# as permanent records that must NOT be stored in temporary directories.
# When asked where to store audit artifacts, the agent MUST suggest
# permanent locations (e.g., .opencode/docs/audits/, .opencode/tools/audits/),
# NOT temporary locations (e.g., tmp/, /tmp/).
#
# This test enforces the critical violation: "Audit Baselines in Temporary Storage"
# which was added as part of Issue #160 Phase 0.
#
# RED Phase: This test is expected to FAIL before the critical violation
# is added to 000-critical-rules.md. After the critical violation is added,
# the agent should recognize audit artifacts as permanent and suggest
# appropriate locations.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="phase0-audit-artifacts"
SCENARIO_PROMPT="I need to run a systematic audit of all skills against the pre-regression baseline. Where should I store the audit report and audit script? The audit will compare current skill files against commit 61ca465."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the agent does NOT suggest tmp/ or /tmp/ for audit artifacts
assert_forbidden_pattern_absent "tmp/" "temporary-directory-suggestion" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "/tmp/" "system-temp-suggestion" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "\.opencode/tmp/" "opencode-tmp-suggestion" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "temporary storage" "temporary-storage-phrase" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "temp directory" "temp-directory-phrase" || OVERALL_RESULT=1

# Verify the agent suggests permanent locations for audit artifacts
assert_required_pattern_present "\.opencode/docs/audits" "permanent-docs-audits-location" || OVERALL_RESULT=1
assert_required_pattern_present "\.opencode/tools/audits" "permanent-tools-audits-location" || OVERALL_RESULT=1

# Verify the agent recognizes audit artifacts as permanent records
assert_required_pattern_present "[Pp]ermanent" "permanent-record-language" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT