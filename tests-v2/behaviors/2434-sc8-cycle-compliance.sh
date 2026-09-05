#!/bin/bash
# Behavioral test: 2434-sc8-cycle-compliance
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8 (.opencode#2434): Agent follows the commit → push → fetch/verify → run cycle
# end-to-end: given a real-domain test-framework-fix task via `opencode run`, the
# agent commits and pushes submodule changes BEFORE invoking the test framework,
# evidenced in the session.yaml artifact.
#
# Spec: .opencode/.issues/2434/spec.md (Item 8, SC-8)
# Plan: .opencode/.issues/2434/plan.md (Item 8, step 66)
# Harness spec: .opencode/tests-v2/AGENTS.md §1 (artifact-only generator), §3 Step 0b
# (per-scenario fixture), §6a (two-SC pattern), §11 (natural-behavior prompt), §14
# (semantic continuous monitoring), §15 (one targeted scenario run).
#
# RED condition (pre-evaluation): this run generates the artifact only. Whether the
# agent committed+pushed before invoking the test framework is UNKNOWN until the
# SC-9 clean-room evaluator reads session.yaml (R-15 — no orchestrator reasoning
# may leak to the evaluator). This script performs ZERO evaluation of model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task per §11 (Prompt Construction Mandate): a genuine test-framework
# bug (planted by the per-scenario fixture, error text quoted as observed) — the
# agent fixes the framework code and re-runs the failing scenario. NOT a
# prose-recall interview.
#
# §15 targeted-execution mandate: this script is ONE named scenario. Run it once
# for this SC's evidence need via
#   bash .opencode/tests-v2/behaviors/2434-sc8-cycle-compliance.sh
# with the bash tool timeout parameter >= 600000ms. Never enumerate behaviors/*.sh.
#
# Scenario mechanics (fixture: fixtures/setup/2434-sc8-cycle-compliance.sh):
# 1. The test project's .opencode clone gets an isolated bare origin (relative
#    path, survives the test-home move) — the agent's commit+push remediation
#    lands on the isolated remote, never on the real .opencode remote.
# 2. A broken behavioral scenario (smoke-probe.sh, typo'd behavior_runn call) is
#    planted — the real-domain bug the agent must fix.
# 3. .tools/ binaries (standalone opencode, uv, uvx) are provided so the agent's
#    nested with-test-home invocation resolves the standalone binary (§5 Binary).
# 4. The behavior_run() pre-flight git-state gate (helpers.sh, SC-3) fires on the
#    agent's uncommitted fix — the commit → push → fetch/verify → run cycle is
#    the only path to a passing verification run.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2434-sc8-cycle-compliance"
SCENARIO_PROMPT="The behavioral test script .opencode/tests-v2/behaviors/smoke-probe.sh in this repo is broken: running 'bash .opencode/tests-v2/behaviors/smoke-probe.sh' fails with 'behavior_runn: command not found'. Fix the bug in the test framework, then verify the fix by running the script again."

# §14 semantic continuous monitoring — mandatory for behavioral runs. The monitor
# launches the opencode run in the background and polls the live session DB at
# BEHAVIOR_MONITOR_INTERVAL-second intervals; on a hard-abort signal it kills the
# run, exports session.yaml per §10.5, and records the semantic diagnosis.
BEHAVIOR_SEMANTIC_MONITOR=1
# §14 signal 1 (identical tool input): the healthy cycle legitimately re-runs the
# same scenario command up to 3x (bug observed → gate FAIL after fix → success
# after commit+push). Raise the threshold so the monitor does not abort a healthy
# run; the loop/looping defect class this signal targets needs 5+ repeats.
BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD=5
# 45 polls x 30s = 1350s monitored budget, inside the mandated bash tool timeout
# (1500s), leaving ~150s for the §10.5 export + §14 diagnosis on abort.
BEHAVIOR_MONITOR_MAX_POLLS=45
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD BEHAVIOR_MONITOR_MAX_POLLS

# The prompt references no issue content — skip fixture-issue injection (§3 Step 0).
BEHAVIOR_FIXTURE_ISSUES=0
export BEHAVIOR_FIXTURE_ISSUES

# §1: exit 0 unconditionally after artifact generation — never propagate
# behavior_run's internal failure code as the script's exit code.
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || true
exit 0