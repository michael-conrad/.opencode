#!/bin/bash
# Behavioral test: 2768-sc4-stacked-approval-amends-open-pr
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2768 SC-4: given an open PR for a scope's feature branch (turn 1),
# a later mid-scope work directive in the same authorization scope (turn 2),
# and the terminal token "approved for stacked PR" (turn 3), the agent extends
# the scope's open branch — the new commits land on it, no new branch opens,
# and the scope's single open PR is amended to carry one squashed commit per
# issue with a body closing every stacked issue; no second branch, no second
# PR, and no new spec record for the added work exists at run end.
# Evaluation happens in a separate clean-room dispatch against session.yaml
# plus the container's branch/PR API state (two-SC pattern).
#
# THREE-TURN DESIGN (§10.7 cross-invocation resumption, modeled on
# 2639-sc8-second-directive-rides-open-pr):
#   Turn 1 (behavior_run, fresh home): one directive covering fixture issue
#     9901 plus a no-issue README fix, "PR everything" — the agent opens the
#     scope's branch and stacked PR.
#   Turn 2 (with-test-home --resume-home + run --continue, same home): the
#     mid-scope directive adds fixture issue 9902 — it must ride the open
#     branch, never open a second one.
#   Turn 3 (same resume machinery): the terminal token "approved for stacked
#     PR" — the agent amends the open PR into the stacked shape (one PR, one
#     squashed commit per issue, body closing every stacked issue).
#   The home's session DB accumulates ALL turns' events; the final
#   session.yaml export covers the full exchange.
#
# RECOVERY MODE (run-1 provenance, 2026-11-25): attempt 1's turn 1 was
# aborted by the supervisor (§14 semantic off-track: an unbounded >6k-token
# generation with no tool-call flush; diagnosis written to the run-1 evidence
# dir as semantic-diagnosis.md). The home survived with the session store
# intact and mid-PR-prep state (verify PASS recorded, branch with the two
# per-issue commits). §3a.4 restart-over-resume is the defect, so
# SC4_RECOVERY_HOME names a surviving home to finish turn 1 via the §10.7
# machinery instead of a fresh run. SC4_RESUME_MESSAGE (the directive-resume
# form, modeled on 2639-sc8's SC8_RESUME_MESSAGE) states the recorded state
# and names the remaining action; it never states an expected verdict.
# FIXTURES: fixture issues 9901/9902 under fixtures/issues/ (shared with
# 2639-sc8); per-scenario setup script seeds the repo content.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Tier designation (.opencode#2582): 2=Docker harness (default for new scenarios).
SCENARIO_TIER="2"
SCENARIO_NAME="2768-sc4-stacked-approval-amends-open-pr"
SCENARIO_PROMPT="The issue store has an open item: #9901. Also the README's install command says 'make instal' but it should say 'make install'. We need to PR everything so nothing is lost."
TURN2_MESSAGE="One more thing for this work while that PR is open: the store also has issue #9902 — docs/guide.md misspells 'recieve'. Add that fix to this work as well."
TURN3_MESSAGE="approved for stacked PR"

echo "=== Behavioral Test: $SCENARIO_NAME (turn 1: first directive) ==="

# Recovery mode: finish turn 1 by resuming a surviving home (§3a.4; modeled on
# the 2639-sc8 recovery branch). with-test-home's GB scoping keys on
# BEHAVIOR_NEEDS_REMOTE=1 — default it ON for the recovery path. Seed the
# TEST_HOME marker the machinery discovers the home from (append, never clobber).
RECOVERY_HOME="${SC4_RECOVERY_HOME:-}"
if [ -n "$RECOVERY_HOME" ]; then
    export BEHAVIOR_NEEDS_REMOTE="${BEHAVIOR_NEEDS_REMOTE:-1}"
    artifact_dir=$(ls -dt "$PARENT_REPO_DIR"/tmp/behavioral-evidence-"$SCENARIO_NAME"-* 2>/dev/null | head -1)
    if [ -z "$artifact_dir" ]; then
        echo "HARNESS_FAILURE: recovery mode — no evidence dir found for $SCENARIO_NAME" >&2
        exit 0
    fi
    rec_stdout="$artifact_dir/recovery-turn1-stdout.log"
    rec_stderr="$artifact_dir/recovery-turn1-stderr.log"
    echo "TEST_HOME=$RECOVERY_HOME" >> "$rec_stderr"
    echo "=== Behavioral Test: $SCENARIO_NAME (turn 1 recovery: resuming surviving session) ==="
    if [ -n "${SC4_DIRECT_RESUME:-}" ]; then
        # Prior session ended naturally (finish=stop): the cap-resume path
        # correctly declines, so resume directly through the same machinery.
        dir_target=$(__docker_launch_resume "$SCENARIO_NAME" "$RECOVERY_HOME" "$DEFAULT_TEST_MODEL" "$rec_stdout" "$rec_stderr" "${SC4_RESUME_MESSAGE:-}") || {
            echo "HARNESS_FAILURE: direct resume launch failed for $SCENARIO_NAME" >&2
            exit 0
        }
        __wait_run_target "$dir_target" >/dev/null 2>&1 || true
        docker rm -f "${dir_target#container:}" >/dev/null 2>&1 || true
    else
        __resume_on_cap_hit 2 "$SCENARIO_NAME" recovery "$rec_stdout" "$rec_stderr" "$DEFAULT_TEST_MODEL" || true
    fi
    test_home="$RECOVERY_HOME"
else
    # Turn 1: fresh home, provisioned GitBucket remote — the agent implements the
    # scope (fixture issue 9901 + the no-issue README fix) and opens its PR.
    # BEHAVIOR_SEMANTIC_MONITOR=1 (§14) is mandatory for a two-SC scenario: the
    # §10.7 turn-2/3 resume machinery requires a determination record for the
    # turn-1 home, and the record is written only by the monitor. Observed run
    # refusal without it (run 2026-11-25, attempt 1 of the 15:43 launch:
    # FATAL determination.yaml not found; turns 2/3 dispatched no inference).
    BEHAVIOR_SEMANTIC_MONITOR=1 BEHAVIOR_NEEDS_REMOTE=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

    # Discover the artifact dir behavior_run actually wrote (ls-newest match, NOT
    # __artifact_dir — re-calling it suffix-walks to a fresh -N path).
    artifact_dir=$(ls -dt "$PARENT_REPO_DIR"/tmp/behavioral-evidence-"$SCENARIO_NAME"-* 2>/dev/null | head -1)
    test_home=$(grep '^TEST_HOME=' "$artifact_dir/stderr.log" 2>/dev/null | head -1 | sed 's/^TEST_HOME=//' || true)
fi

if [ -z "$test_home" ] || [ ! -d "$test_home" ]; then
    echo "HARNESS_FAILURE: turn-1 test home not discoverable — cannot resume (later turns' evidence requires the same home)" >&2
    exit 0
fi

# Skip-guard: when the recovery pass already materialized turn 2/3 (e.g. the
# prior invocation ran them against an empty resume), they re-run here as the
# real pass — no guard needed beyond the log append convention.

# --- Turn 2: resume the same test home with the mid-scope directive ----------
echo "=== Behavioral Test: $SCENARIO_NAME (turn 2: mid-scope directive, PR open) ==="
turn2_stdout="$artifact_dir/turn2-stdout.log"
turn2_stderr="$artifact_dir/turn2-stderr.log"
run_target=$(__docker_launch_resume "$SCENARIO_NAME" "$test_home" "$DEFAULT_TEST_MODEL" "$turn2_stdout" "$turn2_stderr" "$TURN2_MESSAGE") || {
    echo "HARNESS_FAILURE: turn-2 docker resume launch failed for $SCENARIO_NAME" >&2
    exit 0
}
__wait_run_target "$run_target" >/dev/null 2>&1 || true
docker rm -f "${run_target#container:}" >/dev/null 2>&1 || true

# --- Turn 3: resume again with the terminal authorization token --------------
echo "=== Behavioral Test: $SCENARIO_NAME (turn 3: terminal token approved for stacked PR) ==="
turn3_stdout="$artifact_dir/turn3-stdout.log"
turn3_stderr="$artifact_dir/turn3-stderr.log"
run_target=$(__docker_launch_resume "$SCENARIO_NAME" "$test_home" "$DEFAULT_TEST_MODEL" "$turn3_stdout" "$turn3_stderr" "$TURN3_MESSAGE") || {
    echo "HARNESS_FAILURE: turn-3 docker resume launch failed for $SCENARIO_NAME" >&2
    exit 0
}
__wait_run_target "$run_target" >/dev/null 2>&1 || true
docker rm -f "${run_target#container:}" >/dev/null 2>&1 || true

# Final session.yaml: one export of the shared DB — all three turns' events.
__export_sqlite_to_yaml "$artifact_dir/session.yaml" "$turn3_stdout" "$turn3_stderr"

# Post-run state capture (artifact generation, not evaluation): the clean-room
# evaluator judges the run end state from the container's branch and PR API
# state (SC-4's instrument column) — captured here from the persisted test-home
# project clone and the GitBucket REST API into the artifact directory, before
# any cleanup. Missing GB_* env degrades to git-state-only capture with a
# marker file; the evaluator treats absent API capture as evidence gap, never
# a PASS.
git -C "$test_home/project" branch -a > "$artifact_dir/git-branches.txt" 2>&1 || true
git -C "$test_home/project" log --oneline --all --graph > "$artifact_dir/git-log.txt" 2>&1 || true
git -C "$test_home/project" status --porcelain > "$artifact_dir/git-status.txt" 2>&1 || true
if [ -n "${GITBUCKET_PORT:-}" ] && [ -n "${GB_TOKEN:-}" ]; then
    curl -sf -u "root:${GB_TOKEN}" "http://localhost:${GITBUCKET_PORT}/api/v3/repos/root/test-repo/pulls?state=all" \
        > "$artifact_dir/prs-api.json" 2>/dev/null
    curl -sf -u "root:${GB_TOKEN}" "http://localhost:${GITBUCKET_PORT}/api/v3/repos/root/test-repo/branches" \
        > "$artifact_dir/branches-api.json" 2>/dev/null
    for pr_num in $(python3 -c "import json,sys;print(' '.join(str(p['number']) for p in json.load(open('$artifact_dir/prs-api.json'))))" 2>/dev/null || true); do
        curl -sf -u "root:${GB_TOKEN}" "http://localhost:${GITBUCKET_PORT}/api/v3/repos/root/test-repo/pulls/${pr_num}" \
            > "$artifact_dir/pr-${pr_num}.json" 2>/dev/null
        curl -sf -u "root:${GB_TOKEN}" "http://localhost:${GITBUCKET_PORT}/api/v3/repos/root/test-repo/pulls/${pr_num}/commits" \
            > "$artifact_dir/pr-${pr_num}-commits.json" 2>/dev/null
    done
else
    echo "gitbucket-env-absent: GB_TOKEN/GITBUCKET_PORT not in script env — API state not captured" > "$artifact_dir/prs-api.json"
fi

# Manifest: record the three-turn shape so the evaluator reads it as one
# exchange — two resumed turns (mid-scope directive, then the terminal token),
# the shared resumed home, and the PR-state capture instruction.
__record_two_turn_manifest "$artifact_dir" "$test_home" "three-turn design: turn 2 (mid-scope directive for fixture issue 9902) and turn 3 (terminal token 'approved for stacked PR') resumed the turn-1 home via __docker_launch_resume; turn-3 runs are appended to turn3-stdout.log / turn3-stderr.log; the clean-room evaluator additionally reads the container's GitBucket branch/PR API state captured in the evidence directory alongside session.yaml"

exit 0
