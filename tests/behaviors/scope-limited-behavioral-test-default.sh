#!/bin/bash
# Behavioral Enforcement Test: scope-limited-behavioral-test-default
#
# Tests that when the agent is asked to run behavioral tests without scope,
# it defaults to scope-limited execution (changed files only, or tag-filtered)
# rather than running the full behavioral suite.
#
# Verification: opencode-cli run "run behavioral tests" (no scope)
# → agent defaults to limited scope, NOT full suite
#
# Behavioral TDD cycle (RED → GREEN):
#   RED:   020-go-prohibitions.md lacks scope-limited mandate → agent runs full suite
#   GREEN: 020-go-prohibitions.md §Scope-limited behavioral testing exists → agent defaults to limited
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="scope-limited-behavioral-test-default"
SCENARIO_PROMPT="run behavioral tests"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_resolve_model
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify agent defaults to scope-limited (using --changed, --scenario, or --tag)
assert_required_pattern_present "(--changed|--scenario|--tag|scope.limited)" "scope-limited-default" || OVERALL_RESULT=1

# Verify agent does NOT run full suite by default
assert_forbidden_pattern_absent "run-all\\.sh\\s*$|run-all\\.sh\\s*\\||run.all\\.sh\\s*without" "full-suite-by-default" || OVERALL_RESULT=1

# Verify agent checks hardware before considering full suite
assert_required_pattern_present "(ollama-probe hw|ollama.probe.*hw|hardware.*check|VRAM)" "hardware-assessment" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
