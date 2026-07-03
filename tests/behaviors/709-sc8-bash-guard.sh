#!/bin/bash
# Behavioral test: 709-sc8-bash-guard
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: PEP 723 bash guard (SC-8 from #709)
#
# Verifies that an agent generating a PEP 723 script includes the
# polyglot bash guard on line 2. The test prompts the agent to create
# a new PEP 723 tool script and asserts the bash guard is present.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pep723-bash-guard"

SCENARIO_PROMPT="Create a new PEP 723 Python script at .opencode/tools/test_guard.py that prints 'hello' when run. Include the shebang, bash guard, and PEP 723 metadata."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-8: Agent MUST include the polyglot bash guard on line 2
assert_stderr_pattern_present '"exec" "uv" "run"' "agent includes bash guard in generated script" || OVERALL_RESULT=1

# SC-8: Agent MUST NOT use the old broken guard
assert_stderr_pattern_absent '""":":"' "agent does not use old broken guard" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
