#!/usr/bin/env bash
# RED/GUARD test for SC-4 (#2245): Each converted behavior script exits 0
# unconditionally as an artifact-only generator, producing an artifact
# directory and writing `session.yaml` into it.
#
# This guard test runs each of the 12 converted behavior scripts via
#   bash .opencode/tests-v2/behaviors/<scenario>.sh
# and asserts, for every script:
#   1. the process exits 0,
#   2. it produces an artifact directory under tmp/behavioral-evidence-<scenario>-*,
#   3. `session.yaml` is written into that artifact directory.
#
# It FAILS (exit 1) if any script exits non-zero or omits `session.yaml`.
# It PASSES (exit 0) only when all 12 scripts exit 0 and write session.yaml.
#
# NOTE: Each behavior script invokes `opencode run` against a real model and can
# take 5+ minutes. Run this test with a bash-tool timeout >= 600000ms per script;
# do NOT use the GNU `timeout` command (it does not forward SIGTERM to children
# and leaves orphaned opencode processes holding the flock lock).
#
# Usage: bash .opencode/tests-v2/test-sc4-exit0-artifact.sh
# Exit: 0 if all 12 scripts exit 0 and produce an artifact dir with session.yaml,
#       1 if any script exited non-zero or omitted session.yaml

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

BEHAVIORS_DIR="$PROJECT_DIR/.opencode/tests-v2/behaviors"
ARTIFACT_ROOT="$PROJECT_DIR/tmp"

ALL_SCENARIOS=(
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

# Optional scoping: set SC4_SCENARIO to run a single scenario (e.g. RED-phase
# per-scenario diagnosis). Defaults to all 12 when unset.
if [ -n "${SC4_SCENARIO:-}" ]; then
    SCENARIOS=( "$SC4_SCENARIO" )
else
    SCENARIOS=( "${ALL_SCENARIOS[@]}" )
fi

mkdir -p "$ARTIFACT_ROOT"

# Snapshot the set of artifact directories that exist for a scenario BEFORE a
# run, so we can detect the freshly-created directory afterward.
snapshot_artifact_dirs() {
    local scenario="$1"
    ls -d "$ARTIFACT_ROOT"/behavioral-evidence-${scenario}-* 2>/dev/null || true
}

PASS_COUNT=0
FAIL_COUNT=0
FAILED_SCRIPTS=()

echo ""
echo "=== SC-4 (#2245): artifact-only exit-0 generation in 12 behavior scripts ==="
echo ""

for scenario in "${SCENARIOS[@]}"; do
    script="$BEHAVIORS_DIR/${scenario}.sh"
    if [ ! -f "$script" ]; then
        echo "  FAIL: $scenario -- script not found: $script"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_SCRIPTS+=("$scenario (missing script)")
        continue
    fi

    failures=()

    # 1. Snapshot pre-existing artifact dirs for this scenario
    local_before=$(snapshot_artifact_dirs "$scenario")

    # 2. Run the converted script; capture its exit code WITHOUT aborting on
    #    non-zero (set -e is bypassed via `|| true`).
    script_output=""
    set +e
    script_output=$(bash "$script" 2>&1)
    run_exit=$?
    set -e

    if [ "$run_exit" -ne 0 ]; then
        failures+=("process exited $run_exit (expected 0)")
    fi

    # 3. Detect the freshly-created artifact dir for this scenario
    new_artifact_dir=""
    while IFS= read -r dir; do
        case "$local_before" in
            *"$dir"*) ;;
            *) new_artifact_dir="$dir" ;;
        esac
    done <<< "$(snapshot_artifact_dirs "$scenario")"

    if [ -z "$new_artifact_dir" ]; then
        # No new dir created. Accept a pre-existing dir only if it carries
        # session.yaml AND the script exited 0 — otherwise this is a regression.
        if [ "$run_exit" -eq 0 ]; then
            existing_with_session=""
            for dir in $local_before; do
                if [ -f "$dir/session.yaml" ]; then
                    existing_with_session="$dir"
                    break
                fi
            done
            if [ -n "$existing_with_session" ]; then
                new_artifact_dir="$existing_with_session"
            fi
        fi
    fi

    if [ -z "$new_artifact_dir" ]; then
        failures+=("no artifact directory produced under $ARTIFACT_ROOT/behavioral-evidence-${scenario}-*")
    elif [ ! -f "$new_artifact_dir/session.yaml" ]; then
        failures+=("artifact dir $new_artifact_dir omits session.yaml")
    fi

    # 4. Record failing evidence to a per-scenario log for auditor consumption
    if [ "${#failures[@]}" -gt 0 ]; then
        evidence_dir="$PROJECT_DIR/.opencode/tests-v2/tmp/sc4-evidence-${scenario}"
        mkdir -p "$evidence_dir"
        {
            echo "scenario: $scenario"
            echo "exit_code: $run_exit"
            echo "artifact_dir: ${new_artifact_dir:-NONE}"
            echo "session_yaml_present: $([ -n "$new_artifact_dir" ] && [ -f "$new_artifact_dir/session.yaml" ] && echo yes || echo no)"
            echo "--- script output (last 100 lines) ---"
            printf '%s\n' "$script_output" | tail -n 100
        } > "$evidence_dir/failure.log"

        echo "  FAIL: $scenario"
        for f in "${failures[@]}"; do
            echo "         - $f"
        done
        echo "         evidence: $evidence_dir/failure.log"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_SCRIPTS+=("$scenario")
    else
        echo "  PASS: $scenario -- exit 0, artifact dir ${new_artifact_dir##*/}, session.yaml present"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "SC-4 regression detected in:"
    for f in "${FAILED_SCRIPTS[@]}"; do
        echo "  - $f"
    done
    echo ""
    exit 1
fi
exit 0
