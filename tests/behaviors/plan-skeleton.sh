#!/bin/bash
# RED Phase test for Phase 1 (Skeleton) of the plan tool.
#
# Tests two scenarios:
#   SC-10: `uv run .opencode/tools/plan --help` exits 0 with usage text
#   SC-11: `uv run --script tools/plan plan --problem <yaml>` exits 0
#
# In RED phase both MUST FAIL because .opencode/tools/plan doesn't exist yet.
# In GREEN phase (after tool creation) both MUST PASS.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="plan-skeleton"
OVERALL_RESULT=0

echo "=== RED Phase Test: $SCENARIO_NAME (Phase 1 Skeleton) ==="
echo ""

# ============================================================
# Create test YAML problem file
# ============================================================
mkdir -p "$PROJECT_DIR/tmp"
TEST_YAML="$PROJECT_DIR/tmp/plan-skeleton-test-problem.yaml"

cat > "$TEST_YAML" << 'YAML'
domain: gripper
problem: gripper-simple
objects:
  rooms: [rooma, roomb]
  balls: [ball1, ball2]
  grippers: [left, right]
init:
  - "(at ball1 rooma)"
  - "(at ball2 rooma)"
  - "(at left rooma)"
  - "(at right rooma)"
  - "(free left)"
  - "(free right)"
goal:
  - "(at ball1 roomb)"
  - "(at ball2 roomb)"
YAML

echo "Test problem file: $TEST_YAML"
echo ""

# ============================================================
# SC-10: --help exits 0 with usage text
# ============================================================
echo "--- SC-10: uv run .opencode/tools/plan --help exits 0 ---"

SC10_OUTPUT=""
SC10_EXIT=0
SC10_OUTPUT=$(cd "$PROJECT_DIR" && uv run .opencode/tools/plan --help 2>&1) || SC10_EXIT=$?

if [ "$SC10_EXIT" -eq 0 ]; then
    echo "  PASS: --help exited 0"
    echo "  Usage text: $(echo "$SC10_OUTPUT" | head -5)"
    SC10_RESULT=0
else
    echo "  FAIL: --help exited $SC10_EXIT (expected RED — tool does not exist yet)"
    echo "  Output: $(echo "$SC10_OUTPUT" | head -3)"
    SC10_RESULT=1
    OVERALL_RESULT=1
fi

echo ""

# ============================================================
# SC-11: plan --problem <yaml> exits 0
# ============================================================
echo "--- SC-11: uv run --script .opencode/tools/plan plan --problem <yaml> exits 0 ---"

SC11_OUTPUT=""
SC11_EXIT=0
SC11_OUTPUT=$(cd "$PROJECT_DIR" && uv run --script .opencode/tools/plan plan --problem "$TEST_YAML" 2>&1) || SC11_EXIT=$?

if [ "$SC11_EXIT" -eq 0 ]; then
    echo "  PASS: plan --problem exited 0"
    echo "  Output: $(echo "$SC11_OUTPUT" | head -5)"
    SC11_RESULT=0
else
    echo "  FAIL: plan --problem exited $SC11_EXIT (expected RED — tool does not exist yet)"
    echo "  Output: $(echo "$SC11_OUTPUT" | head -3)"
    SC11_RESULT=1
    OVERALL_RESULT=1
fi

echo ""

# ============================================================
# SC-5: state init creates YAML state file
# ============================================================
echo "--- SC-5: plan state init <dir> exits 1 (not implemented / RED) ---"

TEST_STATE_DIR="$PROJECT_DIR/tmp/plan-skeleton-test-state"
rm -rf "$TEST_STATE_DIR"
mkdir -p "$TEST_STATE_DIR"

SC5_OUTPUT=""
SC5_EXIT=0
SC5_OUTPUT=$(cd "$PROJECT_DIR" && uv run .opencode/tools/plan state init "$TEST_STATE_DIR" 2>&1) || SC5_EXIT=$?

if [ "$SC5_EXIT" -eq 0 ]; then
    echo "  UNEXPECTED PASS: state init exited 0 (implementation exists?)"
    echo "  Output: $(echo "$SC5_OUTPUT" | head -3)"
    SC5_RESULT=0
else
    echo "  FAIL: state init exited $SC5_EXIT (expected RED — state not implemented yet)"
    echo "  Output: $(echo "$SC5_OUTPUT" | head -3)"
    SC5_RESULT=1
    OVERALL_RESULT=1
fi

echo ""

# ============================================================
# SC-6: state update writes to state file
# ============================================================
echo "--- SC-6: plan state update <dir> --var-name FOO --var-value bar exits 1 (not implemented / RED) ---"

SC6_OUTPUT=""
SC6_EXIT=0
SC6_OUTPUT=$(cd "$PROJECT_DIR" && uv run .opencode/tools/plan state update "$TEST_STATE_DIR" --var-name FOO --var-value bar 2>&1) || SC6_EXIT=$?

if [ "$SC6_EXIT" -eq 0 ]; then
    echo "  UNEXPECTED PASS: state update exited 0 (implementation exists?)"
    echo "  Output: $(echo "$SC6_OUTPUT" | head -3)"
    SC6_RESULT=0
else
    echo "  FAIL: state update exited $SC6_EXIT (expected RED — state not implemented yet)"
    echo "  Output: $(echo "$SC6_OUTPUT" | head -3)"
    SC6_RESULT=1
    OVERALL_RESULT=1
fi

echo ""

# ============================================================
# Write results for orchestrator
# ============================================================
mkdir -p "$PROJECT_DIR/tmp"
cat > "$PROJECT_DIR/tmp/plan-skeleton-red-results.txt" << EOF
SC-10: $([ "$SC10_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL")
SC-11: $([ "$SC11_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL")
SC-5: $([ "$SC5_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL")
SC-6: $([ "$SC6_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL")
PHASE: RED
EOF

# ============================================================
# Summary
# ============================================================
echo "=== RED Phase Results ==="
echo "SC-10 (--help exits 0): $([ "$SC10_RESULT" -eq 0 ] && echo 'PASS' || echo 'FAIL')"
echo "SC-11 (plan --problem exits 0): $([ "$SC11_RESULT" -eq 0 ] && echo 'PASS' || echo 'FAIL')"
echo "SC-5 (state init exits != 0): $([ "$SC5_RESULT" -eq 0 ] && echo 'PASS' || echo 'FAIL')"
echo "SC-6 (state update exits != 0): $([ "$SC6_RESULT" -eq 0 ] && echo 'PASS' || echo 'FAIL')"
echo ""

if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME — unexpected: both SCs passed (tool already exists?)"
else
    echo "FAIL: $SCENARIO_NAME — expected RED behavior (tool does not exist yet)"
fi

exit $OVERALL_RESULT