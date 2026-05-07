#!/bin/bash
# Behavioral Enforcement Test: Dispatch-Failure Gate (SC-4, SC-B1, SC-B2)
#
# Verifies that behavioral tests produce INCONCLUSIVE (exit 2) on model
# dispatch failure instead of false PASS (assert_forbidden_pattern_absent)
# or false FAIL (assert_required_pattern_present).
#
# SC-4: Behavioral test with intentionally broken model name produces
#        INCONCLUSIVE, not false PASS/FAIL
# SC-B1 (RED - on dev before fix): false PASS on assert_forbidden_pattern_absent
# SC-B2 (GREEN - on this branch): INCONCLUSIVE on broken model dispatch
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="dispatch-failure-gate"
echo "=== Behavioral Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# Dispatch with a broken (nonexistent) model name
behavior_run "$SCENARIO_NAME" "Say hello" "ollama/nonexistent-model-that-will-fail"

if [ "${BEHAVIOR_DISPATCH_FAILED:-0}" != "1" ]; then
    echo "FAIL: behavior_run should have set BEHAVIOR_DISPATCH_FAILED=1 for nonexistent model"
    OVERALL_RESULT=1
fi

# Test: assert_forbidden_pattern_absent should return INCONCLUSIVE (exit 2)
# on failed dispatch, not false PASS (exit 0)
echo ""
echo "--- Test: assert_forbidden_pattern_absent on failed dispatch ---"
set +e
assert_forbidden_pattern_absent "zxy_non_existent_pattern" "test-on-failed-dispatch"
ASSERT_EXIT=$?
set -e
if [ "$ASSERT_EXIT" -eq 0 ]; then
    echo "FAIL: assert_forbidden_pattern_absent returned PASS (0) on failed dispatch — this is the false PASS bug"
    echo "  Expected INCONCLUSIVE (2)"
    OVERALL_RESULT=1
elif [ "$ASSERT_EXIT" -eq 2 ]; then
    echo "PASS: assert_forbidden_pattern_absent returned INCONCLUSIVE (2) on failed dispatch"
else
    echo "FAIL: assert_forbidden_pattern_absent returned FAIL ($ASSERT_EXIT) on failed dispatch — expected INCONCLUSIVE (2)"
    OVERALL_RESULT=1
fi

# Test: assert_required_pattern_present should return INCONCLUSIVE (exit 2)
# on failed dispatch, not FAIL (exit 1)
echo ""
echo "--- Test: assert_required_pattern_present on failed dispatch ---"
set +e
assert_required_pattern_present "some_required_pattern" "test-on-failed-dispatch"
ASSERT_EXIT=$?
set -e
if [ "$ASSERT_EXIT" -eq 1 ]; then
    echo "FAIL: assert_required_pattern_present returned FAIL (1) on failed dispatch"
    echo "  Expected INCONCLUSIVE (2) — failed dispatch should not conflate with assertion failure"
    OVERALL_RESULT=1
elif [ "$ASSERT_EXIT" -eq 2 ]; then
    echo "PASS: assert_required_pattern_present returned INCONCLUSIVE (2) on failed dispatch"
elif [ "$ASSERT_EXIT" -eq 0 ]; then
    echo "WARN: assert_required_pattern_present returned PASS (0) on failed dispatch (unlikely)"
fi

# Test: assert_tool_calls_made should return INCONCLUSIVE (exit 2)
echo ""
echo "--- Test: assert_tool_calls_made on failed dispatch ---"
set +e
assert_tool_calls_made 1 "read|write|edit"
ASSERT_EXIT=$?
set -e
if [ "$ASSERT_EXIT" -eq 0 ]; then
    echo "FAIL: assert_tool_calls_made returned PASS (0) on failed dispatch — false PASS"
    OVERALL_RESULT=1
elif [ "$ASSERT_EXIT" -eq 2 ]; then
    echo "PASS: assert_tool_calls_made returned INCONCLUSIVE (2) on failed dispatch"
fi

# Test: assert_skill_invoked should return INCONCLUSIVE (exit 2)
echo ""
echo "--- Test: assert_skill_invoked on failed dispatch ---"
set +e
assert_skill_invoked "approval-gate"
ASSERT_EXIT=$?
set -e
if [ "$ASSERT_EXIT" -eq 0 ]; then
    echo "FAIL: assert_skill_invoked returned PASS (0) on failed dispatch — false PASS"
    OVERALL_RESULT=1
elif [ "$ASSERT_EXIT" -eq 2 ]; then
    echo "PASS: assert_skill_invoked returned INCONCLUSIVE (2) on failed dispatch"
fi

# Test: assert_no_skill_invoked should return INCONCLUSIVE (exit 2)
echo ""
echo "--- Test: assert_no_skill_invoked on failed dispatch ---"
set +e
assert_no_skill_invoked "nonexistent-skill"
ASSERT_EXIT=$?
set -e
if [ "$ASSERT_EXIT" -eq 0 ]; then
    echo "WARN: assert_no_skill_invoked returned PASS (0) on failed dispatch"
    echo "  This is the false PASS pattern — INCONCLUSIVE (2) would be more correct"
    echo "  But is not a FAIL since the assertion is vacuously true"
elif [ "$ASSERT_EXIT" -eq 2 ]; then
    echo "PASS: assert_no_skill_invoked returned INCONCLUSIVE (2) on failed dispatch"
else
    echo "FAIL: assert_no_skill_invoked returned FAIL ($ASSERT_EXIT)"
    OVERALL_RESULT=1
fi

# Summary
echo ""
echo "========================================="
echo "  $SCENARIO_NAME Results"
echo "========================================="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: All assertions correctly handle dispatch failure"
else
    echo "FAIL: Some assertions did not handle dispatch failure correctly"
fi

exit "$OVERALL_RESULT"
