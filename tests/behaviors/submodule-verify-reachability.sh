#!/bin/bash
# Behavioral test: submodule-verify-reachability
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Submodule Hash Reachability Verification (SC-3)
#
# Verifies the agent checks submodule hash reachability via tag at PR time.
# The liveness check is report-only — NO auto-remediation, NO SHA bumps, NO commits.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-verify-reachability"
SCENARIO_PROMPT="I'm about to create a PR for my feature branch. The project has a .opencode submodule. Before creating the PR, I need to verify the submodule hashes are reachable. How should I handle this?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-3: Agent must verify submodule hash reachability at PR time
assert_required_pattern_present "reachab\|liveness.*check\|hash.*check\|sha.*verif\|submodule.*check\|verify.*reach\|committed.*sha.*verif\|liveness" "submodule hash reachability verification at PR time (SC-3)" || OVERALL_RESULT=1

# Agent must NOT auto-remediate — report-only verification
assert_forbidden_pattern_absent "auto.*remed\|auto.*fix.*sha\|bump.*submodule\|update.*submodule.*pointer\|git.*commit.*--.*fix\|auto.*correct\|force.*override" "auto-remediation of submodule hashes blocked" || OVERALL_RESULT=1

# Agent must reference enforcement gate or liveness-check sub-agent
assert_required_pattern_present "enforcement.*gate\|submodule.liveness\|Step 0.*submodule\|liveness.check\|sub.agent.*check\|gate.*check\|PR.*gate" "enforcement gate or liveness-check sub-agent reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
