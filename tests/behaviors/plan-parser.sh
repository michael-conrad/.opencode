#!/bin/bash
# Phase 3 — RED test for Parser: plan plan --problem with gripper YAML.
#
# Verifies that plan plan --problem produces engine dispatch + action list.
# MUST FAIL (exit non-zero) in RED phase because _action_plan doesn't
# generate a plan yet — it only builds the problem and prints info.
#
# SC-1: plan plan --problem gripper.yaml with valid gripper problem
#       → stderr shows engine dispatch + stdout has `- [ ] N.` action list
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="plan-parser-red"
OVERALL_RESULT=0

echo "=== RED Phase Test: Parser (SC-1) ==="

# ============================================================
# Create test fixtures
# ============================================================
TEST_DIR=$(mktemp -d "$PARENT_REPO_DIR/tmp/plan-parser-test-XXXXXX")
trap 'rm -rf "$TEST_DIR"' EXIT

# Create a gripper YAML problem file
cat > "$TEST_DIR/gripper.yaml" << 'YAMLEOF'
domain: gripper
types:
  - name: location
  - name: ball
  - name: robot
objects:
  - name: room-a
    type: location
  - name: room-b
    type: location
  - name: ball1
    type: ball
  - name: robot1
    type: robot
fluents:
  - name: at-ball
    params:
      - name: b
        type: ball
      - name: l
        type: location
  - name: at-robot
    params:
      - name: r
        type: robot
      - name: l
        type: location
  - name: free
    params:
      - name: r
        type: robot
actions:
  - name: move
    params:
      - name: r
        type: robot
      - name: from
        type: location
      - name: to
        type: location
    preconditions:
      - at-robot(r, from)
    effects:
      - at-robot(r, to)
      - not at-robot(r, from)
  - name: pick
    params:
      - name: r
        type: robot
      - name: b
        type: ball
      - name: l
        type: location
    preconditions:
      - at-robot(r, l)
      - at-ball(b, l)
      - free(r)
    effects:
      - not at-ball(b, l)
      - not free(r)
  - name: drop
    params:
      - name: r
        type: robot
      - name: b
        type: ball
      - name: l
        type: location
    preconditions:
      - at-robot(r, l)
      - not free(r)
    effects:
      - at-ball(b, l)
      - free(r)
init:
  - at-robot(robot1, room-a)
  - at-ball(ball1, room-a)
  - free(robot1)
goals:
  - at-ball(ball1, room-b)
YAMLEOF

echo ""
echo "Fixture setup complete."
echo "  Problem file: $TEST_DIR/gripper.yaml"

# ============================================================
# SC-1: plan plan --problem produces engine dispatch + action list
# ============================================================
echo ""
echo "--- SC-1: plan plan --problem gripper.yaml ---"

# Run the plan command
PLAN_STDOUT="$TEST_DIR/stdout.log"
PLAN_STDERR="$TEST_DIR/stderr.log"
PLAN_EXIT=0

cd "$PARENT_REPO_DIR"
uv run --script .opencode/tools/plan plan --problem "$TEST_DIR/gripper.yaml" > "$PLAN_STDOUT" 2> "$PLAN_STDERR" || PLAN_EXIT=$?

echo "  Exit code: $PLAN_EXIT"
echo "  stdout:"
sed 's/^/    /' "$PLAN_STDOUT"
echo "  stderr:"
sed 's/^/    /' "$PLAN_STDERR"

# Check SC-1: stderr shows engine dispatch
SC1_ENGINE=0
if grep -qE "engine|planner|solver|dispatch" "$PLAN_STDERR" 2>/dev/null; then
    echo "  PASS: stderr shows engine dispatch"
    SC1_ENGINE=0
else
    echo "  FAIL: stderr does NOT show engine dispatch (expected RED behavior)"
    SC1_ENGINE=1
    OVERALL_RESULT=1
fi

# Check SC-1: stdout has action list with `- [ ] N.` format
SC1_ACTIONS=0
if grep -qE '^- \[ \] [0-9]+\.' "$PLAN_STDOUT" 2>/dev/null; then
    echo "  PASS: stdout has action list"
    SC1_ACTIONS=0
else
    echo "  FAIL: stdout does NOT have action list (expected RED behavior)"
    SC1_ACTIONS=1
    OVERALL_RESULT=1
fi

# ============================================================
# Report
# ============================================================
echo ""
echo "=== RED Phase Results ==="
echo "SC-1 engine dispatch: $([ "$SC1_ENGINE" -eq 0 ] && echo "PASS" || echo "FAIL (expected RED)")"
echo "SC-1 action list:    $([ "$SC1_ACTIONS" -eq 0 ] && echo "PASS" || echo "FAIL (expected RED)")"

# SC results (for orchestrator reporting)
mkdir -p "${BEHAVIOR_LOG_DIR:-$PARENT_REPO_DIR/tmp}"
cat > "${BEHAVIOR_LOG_DIR:-$PARENT_REPO_DIR/tmp}/plan-parser-red-sc-results.txt" << EOF
SC-1-engine: $([ "$SC1_ENGINE" -eq 0 ] && echo "PASS" || echo "FAIL")
SC-1-actions: $([ "$SC1_ACTIONS" -eq 0 ] && echo "PASS" || echo "FAIL")
EOF

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME (SC-1)"
else
    echo "FAIL: $SCENARIO_NAME (SC-1) — expected RED behavior"
fi

exit $OVERALL_RESULT
