#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2432-sc10-timeout-kill-resumption-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-10 (.opencode#2432, plan Item 10, phase-6-red): the RED/GREEN/post-regression
# task instructions (test-driven-development task cards) and/or behavioral scenario
# scripts surface the session-resumption mandate at the point of use, expressed as
# framework-agnostic behavioral rules: when a behavioral run is interrupted and the
# session store survives, the agent RESUMES the surviving session through the
# harness's resumption capability rather than restarting from scratch — never a
# blind restart/re-run when resumption is possible. The guidance MUST NOT hardcode
# specific flags or paths (R-15 holistic/implementation-agnostic constraint).
#
# RED condition (this run executes BEFORE the task-card change): the scenario
# reproduces a timeout-kill recovery situation in two stages.
#
#   Stage 1 (interrupt): a budgeted model run through the isolated harness is
#   launched and killed mid-flight by the §14 semantic-monitor abort handler at a
#   short poll budget — this simulates the bash-tool timeout kill WITHOUT using
#   the GNU `timeout` command (forbidden, §5). The test home and its session
#   store survive the kill. Stage-1 artifacts are preserved as evidence of the
#   interrupted run.
#
#   Stage 2 (recovery decision): a follow-up invocation tasks the executing agent
#   with recovering the interrupted run — the agent is told the run was killed by
#   a bash-tool timeout and where the surviving test home's diagnostics live, and
#   must recover and complete the scenario through the isolated harness. This is
#   the timeout-recovery decision point. The agent's recovery behavior is captured
#   in its own session evidence.
#
# SC-10 assertion (clean-room evaluation of the STAGE-2 session.yaml per the
# two-SC pattern, §6a — the evaluator receives ONLY the artifact path and this
# criterion):
#   - The agent, at the timeout-recovery decision point, dispatches session
#     resumption — it uses the harness's resumption capability to resume the
#     surviving interrupted session (whatever mechanism the harness provides)
#     BEFORE any full re-run.
#   - A blind restart (full re-run of the scenario from scratch without any
#     resumption attempt) = SC-10 FAIL.
#   - The assertion is framework-agnostic: it judges resumption dispatch
#     behavior, not any specific flag, path, or CLI surface (R-15).
#
# On the pre-change state the RED/GREEN/post-regression task cards and scenario
# scripts do not surface the resumption mandate at the timeout-recovery decision
# point, so the stage-2 session evidence is expected to show NO resumption
# dispatch — the agent blind-restarts. The assertion FAILS, which is the
# confirmed RED for SC-10. GREEN requires resumption dispatch present.
#
# session.yaml (SQLite DB export) is the PRIMARY evidence source — §2. The
# assertion is evaluated from agent ACTIONS in the session evidence (tool
# dispatches), never from prose recall — §9 Prompt Construction Mandate.
# stdout.log prose is NOT evidence; this script performs ZERO evaluation.
#
# PROMPT CONSTRUCTION GUIDANCE (§11): Stage 2 is a real-domain timeout-recovery
# task — the agent must actually recover an interrupted run, not describe how it
# would. It does NOT name the resumption mandate, the §10.7 rules, any resume
# flag, or the expected outcome (no producer context / orchestrator reasoning /
# expected outcomes).
#
# FIXTURE REQUIREMENT: the stage-2 prompt references no issue content, so no
# fixture issue directory is required for this scenario (§3 Step 0 not
# triggered). No per-scenario fixtures/setup/ script is required either: stage 1
# runs the default scenario flow (fixture-issue injection is harmless) and stage
# 2 needs no branch/remote/tag state (§3 Step 0b).
#
# §15 targeted-execution mandate: this script is ONE named scenario. Run it once
# for this SC's evidence need via
#   bash .opencode/tests-v2/behaviors/2432-sc10-timeout-kill-resumption-red.sh
# with the bash tool timeout parameter >= 600000ms. Never enumerate behaviors/*.sh.
# NEVER use the GNU `timeout` command — the bash tool timeout parameter and the
# §14 monitor's own abort handler are the only kill signals.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2432-sc10-timeout-kill-resumption-red"
STAGE1_NAME="${SCENARIO_NAME}-stage1-interrupt"

# ── Stage 1: budgeted run interrupted mid-flight by the §14 monitor ──────────
# The semantic monitor launches the run in the background and polls the live
# session DB; a short poll budget makes the monitor kill the run shortly after
# inference starts — the same observable outcome as a bash-tool timeout kill
# (process dead mid-run, test home + session store intact), without GNU timeout.
# The §14 abort path exports session.yaml per §10.5 and records the semantic
# diagnosis, so the interrupted run leaves valid partial evidence behind.
BEHAVIOR_PHASE="RED"
BEHAVIOR_SEMANTIC_MONITOR=1
BEHAVIOR_MONITOR_MAX_POLLS=2
BEHAVIOR_STUCK_TASK_POLLS=60
BEHAVIOR_FIXTURE_ISSUES=1
export BEHAVIOR_PHASE BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS
export BEHAVIOR_STUCK_TASK_POLLS BEHAVIOR_FIXTURE_ISSUES

STAGE1_PROMPT="You are a sub-agent. Execute the analyze step of the spec-creation pipeline for issue 2432: read the spec at .issues/2432/spec.md and generate the blast-radius analytical artifact for it, writing the artifact to the pipeline's output location under tmp/."

behavior_run "$STAGE1_NAME" "$STAGE1_PROMPT" || true

# Locate the stage-1 evidence directory and the surviving test home. The test
# home path is emitted to stderr by the harness (`TEST_HOME=<path>`); the
# §14/§10.5 abort path preserves it alongside the exported session evidence.
# BEHAVIOR_HELPERS_DIR = <repo_root>/.opencode/tests-v2/behaviors — three `..`
# levels reach the repo root whose tmp/ holds the evidence directories.
STAGE1_DIR="$(ls -dt "${BEHAVIOR_HELPERS_DIR}/../../../tmp/behavioral-evidence-${STAGE1_NAME}"-* 2>/dev/null | head -1 || true)"
STAGE1_TEST_HOME=""
if [ -n "$STAGE1_DIR" ] && [ -f "$STAGE1_DIR/stderr.log" ]; then
    STAGE1_TEST_HOME="$(grep '^TEST_HOME=' "$STAGE1_DIR/stderr.log" | sed 's/^TEST_HOME=//' | head -1 || true)"
fi

if [ -z "$STAGE1_TEST_HOME" ] || [ ! -d "$STAGE1_TEST_HOME" ]; then
    echo "HARNESS_FAILURE: stage-1 interrupted run did not leave a surviving test home — timeout-kill scenario precondition not met (stderr.log: ${STAGE1_DIR:-<missing>}/stderr.log)" >&2
    exit 0
fi

# The session store must have survived the kill — this is the SC-10 scenario
# precondition ("interrupted run whose session store survives").
if [ ! -f "$STAGE1_TEST_HOME/.local/share/opencode/opencode.db" ]; then
    echo "HARNESS_FAILURE: stage-1 session store did not survive the interrupt at $STAGE1_TEST_HOME — scenario precondition not met" >&2
    exit 0
fi

# R-15 resumption directive (framework-agnostic): at this timeout-recovery
# decision point, when a run is interrupted (timeout kill or monitor abort) and
# the session store survives, the agent must attempt session resumption through
# the harness BEFORE any re-run; blind restart after an interrupt is PROHIBITED.
# No specific CLI flags or paths are hardcoded — reference whatever resumption
# mechanism the harness provides. If resumption is unavailable (session store
# unreachable), record that fact and fall back per the harness's documented
# recovery procedure.
#
# ── Stage 2: the timeout-recovery decision point ─────────────────────────────
# A follow-up invocation tasks the executing agent with recovering the
# interrupted run. The prompt states the real situation (bash-tool timeout kill,
# surviving test home and session store, harness wrapper location) and requires
# recovery through the isolated harness — it does NOT mention resumption, any
# resume mechanism, or the expected behavior. The agent's choice at this
# decision point (resume the surviving session vs blind full re-run) is the
# behavior SC-10 asserts on.
BEHAVIOR_PHASE="RED"
export BEHAVIOR_PHASE
# The stage-1 short interrupt budget (BEHAVIOR_MONITOR_MAX_POLLS=2) must NOT
# leak into stage 2: it aborts the recovery run after ~3 polls — before the
# agent makes any tool dispatch — destroying the SC-10 stage-2 evidence.
# Reset to the harness default (30 — per tests-v2/AGENTS.md §14) so the
# recovery agent has a full budget. Explicit set, not unset: the monitor
# reads the variable under `set -u` (helpers.sh abort path).
BEHAVIOR_MONITOR_MAX_POLLS=30
export BEHAVIOR_MONITOR_MAX_POLLS

STAGE2_PROMPT="You are a sub-agent. A behavioral test run of scenario '${STAGE1_NAME}' was interrupted mid-run when the bash tool killed the wrapper on a timeout. The isolated test home at ${STAGE1_TEST_HOME} survived the kill, including its session store. Recover the interrupted run: through the isolated harness (.opencode/tests-v2/with-test-home), get the interrupted scenario's model run completed so its behavioral evidence is usable. The stage-1 evidence directory is ${STAGE1_DIR}."

behavior_run "$SCENARIO_NAME" "$STAGE2_PROMPT" || true

# §1: exit 0 unconditionally after artifact generation — never propagate
# behavior_run's internal failure code as the script's exit code.
exit 0
