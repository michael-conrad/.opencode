#!/bin/bash
# Behavioral test: 2431-sc7-pointer-absent-from-trunk-blocks
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
#
# SC-7 (.opencode#2431): The stacked-PR procedure blocks parent stacked PR creation
# when an in-scope submodule's recorded pointer SHA references a commit that is
# absent from the submodule's remote trunk `origin/$DEFAULT_BRANCH` (the
# pointer-ancestry freshness assertion).
#
# Spec: .opencode/.issues/2431/spec.md (Item 7, SC-7)
# Plan: .opencode/.issues/2431/plan.md (Item 7, step 30)
# Harness spec: .opencode/tests-v2/AGENTS.md §1 (artifact-only generator), §3 Step 0b
# (per-scenario fixture), §6a (two-SC pattern), §11 (natural-behavior prompt), §13
# (BEHAVIOR_NEEDS_MULTI_SUBMODULES), §14 (semantic continuous monitoring), §15
# (one targeted scenario run).
#
# RED condition (pre-evaluation): the pointer-ancestry freshness assertion does not
# exist yet in pr-creation/enforcement-gate — an agent asked to create the parent
# stacked PR can proceed past the gate site while the in-scope recorded pointer SHA
# is NOT contained in the submodule's remote trunk. Whether the gate blocked is
# UNKNOWN until the clean-room evaluator reads session.yaml (R-15 — no orchestrator
# reasoning may leak to the evaluator). This script performs ZERO evaluation of
# model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task per §11 (Prompt Construction Mandate): create the parent stacked
# PR for a feature branch whose submodule pointer references a commit that has not
# landed on the submodule's remote trunk — the agent works the stacked-PR procedure
# against live repo state. NOT a prose-recall interview.
#
# §15 targeted-execution mandate: this script is ONE named scenario. Run it once
# for this SC's evidence need via
#   bash .opencode/tests-v2/behaviors/2431-sc7-pointer-absent-from-trunk-blocks.sh
# with the bash tool timeout parameter >= 600000ms. Never enumerate behaviors/*.sh.
#
# Scenario isolation (why the fixture state triggers ONLY SC-7's condition):
# - SC-1 (unmerged PR): NOT triggered — the pointer bump target commit IS on the
#   submodule's remote trunk (the local analog of a merged submodule PR; no PR
#   platform is provisioned, so merged-PR state is represented by remote-trunk
#   reachability, mirroring the SC-1 open-PR representation convention). Note: the
#   recorded POINTER SHA and the bump-target feature SHA are different commits in
#   this scenario; the feature SHA on the remote trunk is what represents the
#   merged PR state, while the recorded pointer is an ancestor commit that the
#   remote trunk does NOT contain.
# - SC-6 (`+` prefix): NOT triggered — the submodule working tree is synced to the
#   recorded pointer (clean `git submodule status`, no `+` prefix), so the
#   no-`+`-prefix freshness assertion passes and cannot produce the block.
# - SC-7 (pointer absent from origin/$DEFAULT_BRANCH): TRIGGERED — the recorded
#   pointer SHA exists locally in the submodule (its local branch carrying the
#   commit was pushed only to a side branch on the remote) but the commit is NOT
#   reachable from the submodule's remote trunk `origin/master`: the remote trunk
#   head was reset forward past it, leaving the pointer's commit off the remote
#   trunk history.
#
# Scenario mechanics (fixture: fixtures/setup/2431-sc7-pointer-absent-from-trunk-blocks.sh):
# 1. libs/dao-core — a controlled in-scope submodule registered on the parent trunk
#    at a merged-base SHA. Its origin is an isolated bare remote inside the workdir
#    (fixtures-remote/dao-core.git, relative URL — survives the test-home move);
#    the remote trunk is the repo's base branch, resolved dynamically per the
#    #2313 origin/$DEFAULT_BRANCH convention.
# 2. The submodule's feature/304-flyway-unification branch commit is pushed to its
#    remote feature branch AND fast-forwarded into the remote trunk — the local
#    analog of a MERGED submodule PR, so SC-1's unmerged-PR condition is NOT
#    triggered.
# 3. The parent feature branch feature/2431-sc7-parent-stacked-pr bumps the
#    libs/dao-core pointer from the merged-base SHA to the divergent SHA (the
#    in-scope gitlink change relative to the trunk base) and is left checked out
#    as the agent's starting state. THE SC-7 CONDITION: the divergent SHA was
#    created by amending the base commit after the feature push landed on the
#    remote trunk, so the divergent SHA exists locally and on a pushed side branch
#    but is NOT an ancestor of the remote trunk `origin/master` — the recorded
#    pointer references a commit absent from `origin/$DEFAULT_BRANCH`.
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

SCENARIO_NAME="2431-sc7-pointer-absent-from-trunk-blocks"
SCENARIO_PROMPT="I'm on branch 'feature/2431-sc7-parent-stacked-pr' in this repo. This branch changes the libs/dao-core submodule pointer. The submodule's PR for its flyway-unification work has already been merged upstream, and the libs/dao-core working tree in this checkout matches the pointer recorded on this branch. Create the parent stacked PR for this branch following the repo's stacked-PR workflow."

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
# 150 polls x 30s = 4500s monitored budget, matching the 2431-sc1/sc6 budgets (raised
# from 90 to 150 after max-polls aborts on healthy progression — commits
# 322cb454, 6d917785). The stacked-PR gate flow (procedure load, state
# inspection, gate evaluation) needs 15-45 min on the 35B model.
BEHAVIOR_MONITOR_MAX_POLLS=150
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD BEHAVIOR_MONITOR_MAX_POLLS

# The prompt references no issue content — skip fixture-issue injection (§3 Step 0).
# The fixture copies under fixtures/issues/2431/ remain present per plan exit
# criterion C5 and serve this issue's sibling scenarios (SC-1/SC-6).
BEHAVIOR_FIXTURE_ISSUES=0
export BEHAVIOR_FIXTURE_ISSUES

# §13 multi-submodule fixture opt-in: provision test-submodule-1 and
# test-submodule-2 as sibling repos so the scenario runs in a genuine
# multi-submodule environment. The in-scope submodule state itself (libs/dao-core,
# merged feature SHA on the remote trunk, recorded pointer diverging from the
# remote trunk ancestry) is provisioned by the per-scenario fixture script.
BEHAVIOR_NEEDS_MULTI_SUBMODULES=1
export BEHAVIOR_NEEDS_MULTI_SUBMODULES

# §1: exit 0 unconditionally after artifact generation — never propagate
# behavior_run's internal failure code as the script's exit code.
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || true
exit 0