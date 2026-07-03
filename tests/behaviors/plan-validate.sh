#!/bin/bash
# Phase 6 — RED/GREEN test for Validate: validate --problem --plan with valid/invalid YAML.
#
# SC-2: validate --problem p.yaml --plan plan.yaml with valid plan → exit 0 + "valid"
# SC-3: validate with invalid plan (missing goal) → exit 1 + "invalid"
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="plan-validate"
OVERALL_RESULT=0

echo "=== Phase Test: $SCENARIO_NAME (Phase 6 Validate) ==="

# ============================================================
# Create test fixtures
# ============================================================
TEST_DIR=$(mktemp -d "$PARENT_REPO_DIR/tmp/plan-validate-test-XXXXXX")
trap 'rm -rf "$TEST_DIR"' EXIT

# Problem YAML (gripper)
cat > "$TEST_DIR/problem.yaml" << 'YAMLEOF'
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

# Valid plan: pick ball1 from room-a, move to room-b, drop
cat > "$TEST_DIR/valid-plan.yaml" << 'YAMLEOF'
actions:
  - name: pick
    parameters: [robot1, ball1, room-a]
  - name: move
    parameters: [robot1, room-a, room-b]
  - name: drop
    parameters: [robot1, ball1, room-b]
YAMLEOF

# Invalid plan: only pick, no drop → goal unsatisfied
cat > "$TEST_DIR/invalid-plan.yaml" << 'YAMLEOF'
actions:
  - name: pick
    parameters: [robot1, ball1, room-a]
  - name: move
    parameters: [robot1, room-a, room-b]
YAMLEOF

echo "  Fixtures: $TEST_DIR/problem.yaml, valid-plan.yaml, invalid-plan.yaml"
echo ""

# ============================================================
# SC-2: Valid plan → exit 0 + "valid"
# ============================================================
echo "--- SC-2: validate --problem p.yaml --plan valid-plan.yaml ---"

SC2_OUTPUT=""
SC2_EXIT=0
SC2_OUTPUT=$(cd "$PARENT_REPO_DIR" && uv run .opencode/tools/plan validate --problem "$TEST_DIR/problem.yaml" --plan "$TEST_DIR/valid-plan.yaml" 2>&1) || SC2_EXIT=$?

FIRST_LINE=$(echo "$SC2_OUTPUT" | head -1)
if [ "$SC2_EXIT" -eq 0 ] && [ "$FIRST_LINE" = "valid" ]; then
    echo "  PASS: exit 0, stdout='$FIRST_LINE'"
    SC2_RESULT=0
else
    echo "  FAIL: exit=$SC2_EXIT, output='$FIRST_LINE' (expected 'valid')"
    SC2_RESULT=1
    OVERALL_RESULT=1
fi

echo ""

# ============================================================
# SC-3: Invalid plan → exit 1 + "invalid"
# ============================================================
echo "--- SC-3: validate --problem p.yaml --plan invalid-plan.yaml ---"

SC3_OUTPUT=""
SC3_EXIT=0
SC3_OUTPUT=$(cd "$PARENT_REPO_DIR" && uv run .opencode/tools/plan validate --problem "$TEST_DIR/problem.yaml" --plan "$TEST_DIR/invalid-plan.yaml" 2>&1) || SC3_EXIT=$?

FIRST_LINE=$(echo "$SC3_OUTPUT" | head -1)
if [ "$SC3_EXIT" -eq 1 ] && echo "$FIRST_LINE" | grep -q "invalid"; then
    echo "  PASS: exit 1, stdout='$FIRST_LINE'"
    SC3_RESULT=0
else
    echo "  FAIL: exit=$SC3_EXIT, output='$FIRST_LINE' (expected 'invalid' + exit 1)"
    SC3_RESULT=1
    OVERALL_RESULT=1
fi

echo ""

# ============================================================
# Write results
# ============================================================
mkdir -p "$PARENT_REPO_DIR/tmp"
cat > "$PARENT_REPO_DIR/tmp/plan-validate-results.txt" << EOF
SC-2: $([ "$SC2_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL")
SC-3: $([ "$SC3_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL")
EOF

# ============================================================
# Summary
# ============================================================
echo "=== Phase 6 Validate Results ==="
echo "SC-2 (valid plan → exit 0 + valid): $([ "$SC2_RESULT" -eq 0 ] && echo 'PASS' || echo 'FAIL')"
echo "SC-3 (invalid plan → exit 1 + invalid): $([ "$SC3_RESULT" -eq 0 ] && echo 'PASS' || echo 'FAIL')"
echo ""

if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME — both SCs verified (GREEN phase)"
else
    echo "FAIL: $SCENARIO_NAME — SCs not passing"
fi

exit $OVERALL_RESULT