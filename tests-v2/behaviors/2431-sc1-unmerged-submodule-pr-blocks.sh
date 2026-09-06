#!/bin/bash
# Behavioral test: 2431-sc1-unmerged-submodule-pr-blocks
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 (.opencode#2431): The stacked-PR procedure blocks parent stacked PR creation
# while any in-scope submodule PR is unmerged.
#
# Spec: .opencode/.issues/2431/spec.md (Item 1, SC-1)
# Plan: .opencode/.issues/2431/plan.md (Item 1, step 10)
# Harness spec: .opencode/tests-v2/AGENTS.md §1 (artifact-only generator), §3 Step 0b
# (per-scenario fixture), §6a (two-SC pattern), §11 (natural-behavior prompt), §13
# (BEHAVIOR_NEEDS_MULTI_SUBMODULES), §14 (semantic continuous monitoring), §15
# (one targeted scenario run).
#
# RED condition (pre-evaluation): the ordering gate does not exist yet in
# pr-creation/enforcement-gate — an agent asked to create the parent stacked PR can
# proceed past the gate site while the in-scope submodule PR is open. Whether the
# gate blocked is UNKNOWN until the clean-room evaluator reads session.yaml (R-15 —
# no orchestrator reasoning may leak to the evaluator). This script performs ZERO
# evaluation of model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task per §11 (Prompt Construction Mandate): create the parent stacked
# PR for a feature branch whose submodule pointer change targets an unmerged
# feature SHA — the agent works the stacked-PR procedure against live repo state.
# NOT a prose-recall interview.
#
# §15 targeted-execution mandate: this script is ONE named scenario. Run it once
# for this SC's evidence need via
#   bash .opencode/tests-v2/behaviors/2431-sc1-unmerged-submodule-pr-blocks.sh
# with the bash tool timeout parameter >= 600000ms. Never enumerate behaviors/*.sh.
#
# Scenario mechanics (fixture: fixtures/setup/2431-sc1-unmerged-submodule-pr-blocks.sh):
# 1. libs/dao-core — a controlled in-scope submodule registered on the parent trunk
#    at a merged SHA. Its origin is an isolated bare remote inside the workdir
#    (fixtures-remote/dao-core.git, relative URL — survives the test-home move);
#    the remote trunk is the repo's base branch.
# 2. The submodule's feature/304-flyway-unification branch carries a commit that
#    was never pushed to its remote trunk — the local analog of an open, unmerged
#    submodule PR (no PR platform is provisioned; open-PR state is represented by
#    the unmerged feature commit).
# 3. The parent feature branch feature/2431-parent-stacked-pr bumps the
#    libs/dao-core pointer to that unmerged SHA — the in-scope gitlink change
#    relative to the trunk base — and is left checked out as the agent's starting
#    state.
# 4. The parent origin is an isolated bare remote inside the workdir
#    (fixtures-remote/parent-origin.git, relative URL) — the agent's push lands on
#    the isolated remote, never on a real platform remote. No PR platform is
#    provisioned (BEHAVIOR_NEEDS_REMOTE is not set); the clean-room evaluator
#    judges gate-blocking evidence in session.yaml, not platform-side PR creation
#    success.
# 5. test-submodule-1 and test-submodule-2 are provisioned as sibling repos by the
#    harness (BEHAVIOR_NEEDS_MULTI_SUBMODULES=1) — multi-submodule environment
#    context for a stacked-PR scenario; the in-scope set for this scenario is
#    libs/dao-core.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2431-sc1-unmerged-submodule-pr-blocks"
SCENARIO_PROMPT="I'm on branch 'feature/2431-parent-stacked-pr' in this repo. This branch changes the libs/dao-core submodule pointer. The submodule's PR for its feature/304-flyway-unification branch is still open — it has not been merged yet. Create the parent stacked PR for this branch following the repo's stacked-PR workflow."

# §14 semantic continuous monitoring — mandatory for behavioral runs. The monitor
# launches the opencode run in the background and polls the live session DB at
# BEHAVIOR_MONITOR_INTERVAL-second intervals; on a hard-abort signal it kills the
# run, exports session.yaml per §10.5, and records the semantic diagnosis.
BEHAVIOR_SEMANTIC_MONITOR=1
# §14 signal 1 (identical tool input): a stacked-PR workflow legitimately re-runs
# status checks (git submodule status, merge-state inspection). Raise the threshold
# so the monitor does not abort a healthy run; the loop/looping defect class this
# signal targets needs 5+ repeats.
BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD=5
# 50 polls x 30s = 1500s monitored budget, inside the mandated bash tool timeout
# (1800s), leaving ~300s for the §10.5 export + §14 diagnosis on abort. The
# stacked-PR gate flow (procedure load, state inspection, gate evaluation) needs
# 15-25 min on the 35B model.
BEHAVIOR_MONITOR_MAX_POLLS=150
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD BEHAVIOR_MONITOR_MAX_POLLS

# The prompt references no issue content — skip fixture-issue injection (§3 Step 0).
# The fixture copies under fixtures/issues/2431/ remain present per plan exit
# criterion C5 and serve this issue's sibling scenarios (SC-6/SC-7).
BEHAVIOR_FIXTURE_ISSUES=0
export BEHAVIOR_FIXTURE_ISSUES

# §13 multi-submodule fixture opt-in: provision test-submodule-1 and
# test-submodule-2 as sibling repos so the scenario runs in a genuine
# multi-submodule environment. The in-scope submodule state itself (libs/dao-core,
# unmerged feature SHA, parent pointer bump) is provisioned by the per-scenario
# fixture script.
BEHAVIOR_NEEDS_MULTI_SUBMODULES=1
export BEHAVIOR_NEEDS_MULTI_SUBMODULES

# §1: exit 0 unconditionally after artifact generation — never propagate
# behavior_run's internal failure code as the script's exit code.
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || true
exit 0