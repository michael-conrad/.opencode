#!/usr/bin/env bash
# RED/GUARD test for SC-3 (#2245): Each converted behavior script preserves its
# pre-conversion contract — the `behavior_run` invocation arguments unchanged and
# the mandatory cross-reference header intact.
#
# Pre-conversion baseline: the 12 call-site scripts called `behavior_run` with
# one of two argument shapes, followed by the mandatory 3-line cross-reference
# header. The SC-2 conversion removed the inline `assert_semantic` call/comment
# but MUST NOT have altered the `behavior_run` invocation args or the header.
#
# This guard test passes (exit 0) when every script still carries its exact
# pre-conversion `behavior_run` args and mandatory header. It FAILS (exit 1) only
# if a conversion dropped or altered an arg or a header element.
#
# Usage: bash .opencode/tests-v2/test-sc3-contract-preserved.sh
# Exit: 0 if all 12 scripts preserve their contract, 1 if any dropped an element

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

# scenario -> expected behavior_run invocation line (pre-conversion contract).
# 8 scripts used the 2-arg form; 4 (dead-branch fixtures) used the 5-arg form
# with the trailing "general" agent selector.
declare -A EXPECTED_RUN=(
    ["2219-sc10-non-pointer-guard"]='behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" "" "" "general"'
    ["2219-sc11-existing-cleanup"]='behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"'
    ["2219-sc15-decline-submodule-pr"]='behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"'
    ["2219-sc16-stale-pointer-block"]='behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"'
    ["2219-sc19-release-pr-prework"]='behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"'
    ["2219-sc3-prework-ordering"]='behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"'
    ["2219-sc6-dead-branch-detection"]='behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" "" "" "general"'
    ["2219-sc7-submodule-pr-verification"]='behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" "" "" "general"'
    ["2219-sc8-dead-branch-deletion"]='behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" "" "" "general"'
    ["2219-sc9-dirty-pointer"]='behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" "" "" "general"'
    ["2239-sc8-check-pr-routing"]='behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"'
    ["skill-deck-completeness"]='behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"'
)

# Mandatory cross-reference header (from tests-v2/AGENTS.md §1). Line 1 is the
# shebang; lines 2-4 are the header contract that MUST appear verbatim.
HEADER_LINES=(
    '# Behavioral test: <scenario>'
    '# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.'
    '# This script is an artifact-only generator — it does NOT evaluate model output.'
)

SCENARIOS=(
    "2219-sc10-non-pointer-guard"
    "2219-sc11-existing-cleanup"
    "2219-sc15-decline-submodule-pr"
    "2219-sc16-stale-pointer-block"
    "2219-sc19-release-pr-prework"
    "2219-sc3-prework-ordering"
    "2219-sc6-dead-branch-detection"
    "2219-sc7-submodule-pr-verification"
    "2219-sc8-dead-branch-deletion"
    "2219-sc9-dirty-pointer"
    "2239-sc8-check-pr-routing"
    "skill-deck-completeness"
)

PASS_COUNT=0
FAIL_COUNT=0
FAILED_SCRIPTS=()

echo ""
echo "=== SC-3 (#2245): pre-conversion contract preserved in 12 behavior scripts ==="
echo ""

for scenario in "${SCENARIOS[@]}"; do
    script="$PROJECT_DIR/.opencode/tests-v2/behaviors/${scenario}.sh"
    if [ ! -f "$script" ]; then
        echo "  FAIL: $scenario -- script not found: $script"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_SCRIPTS+=("$scenario (missing script)")
        continue
    fi

    failures=()

    # 1. behavior_run invocation args unchanged
    expected_run="${EXPECTED_RUN[$scenario]}"
    actual_run=$(grep -E '^behavior_run ' "$script" | head -n1 || true)
    if [ -z "$actual_run" ]; then
        failures+=("behavior_run invocation MISSING (expected: $expected_run)")
    elif [ "$actual_run" != "$expected_run" ]; then
        failures+=("behavior_run args CHANGED (expected: [$expected_run] actual: [$actual_run])")
    fi

    # 2. mandatory cross-reference header intact
    if [ "$(head -n1 "$script")" != "#!/bin/bash" ]; then
        failures+=("line 1 is not the shebang #!/bin/bash")
    fi
    if [ "$(sed -n '2p' "$script")" != "${HEADER_LINES[0]/<scenario>/$scenario}" ]; then
        failures+=("line 2 missing/changed: Behavioral test header")
    fi
    if [ "$(sed -n '3p' "$script")" != "${HEADER_LINES[1]}" ]; then
        failures+=("line 3 missing/changed: AGENTS.md cross-reference header")
    fi
    if [ "$(sed -n '4p' "$script")" != "${HEADER_LINES[2]}" ]; then
        failures+=("line 4 missing/changed: artifact-only generator header")
    fi

    if [ "${#failures[@]}" -gt 0 ]; then
        echo "  FAIL: $scenario"
        for f in "${failures[@]}"; do
            echo "         - $f"
        done
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_SCRIPTS+=("$scenario")
    else
        echo "  PASS: $scenario -- behavior_run args + mandatory header intact"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "Contract regression detected in:"
    for f in "${FAILED_SCRIPTS[@]}"; do
        echo "  - $f"
    done
    echo ""
    exit 1
fi
exit 0
