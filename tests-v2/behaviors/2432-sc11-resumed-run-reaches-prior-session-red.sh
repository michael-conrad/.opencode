#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2432-sc11-resumed-run-reaches-prior-session-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-11 (.opencode#2432, plan Item 11, phase-6-red): the harness's resumption
# capability contract — a test home that SURVIVES across invocations and exposes
# prior session state, such that resuming after an interrupted run picks up the
# surviving session instead of provisioning a fresh test home. Implementation-
# agnostic: no language, storage engine, or CLI surface is mandated.
#
# Scenario (three stages, §14 semantic-monitor abort provides the interrupt):
#
#   Stage 1 (interrupt): a budgeted model run through the isolated harness is
#   killed mid-flight by the §14 semantic-monitor abort handler at a short poll
#   budget (BEHAVIOR_MONITOR_MAX_POLLS=2) — the same observable outcome as a
#   bash-tool timeout kill (process dead mid-run, test home + session store
#   intact) WITHOUT the GNU `timeout` command (forbidden, §5). The §14 abort
#   path exports session.yaml per §10.5.
#
#   Stage 2 (resumption attempt, FOLLOW-UP invocation): a separate harness
#   invocation tasks the executing agent with resuming the interrupted run
#   through the harness's resumption capability. The prompt states the real
#   situation (interrupted run, surviving test home and session store, their
#   paths) and requires resumption through the isolated harness — it does NOT
#   name any resume flag, mechanism, or expected outcome.
#
#   Stage 3 (reachability facts): after stage 2, this script records the
#   REACHABILITY FACTS the clean-room evaluator needs — the prior (stage-1)
#   test home path and its stage-1 session id (aggregate_id from the stage-1
#   DB), and the stage-2 (resumption) test home path and session id — into a
#   prior-session-facts.yaml artifact alongside the stage-2 session evidence.
#   The evaluator (SC-12 style clean-room sub-agent, §6a two-SC pattern) reads
#   ONLY these facts + stage-2 session.yaml and judges:
#     - Did the stage-2 (resumed) run reach the PRIOR invocation's session
#       state — i.e. run inside the prior test home (or a mechanism exposing
#       its session store), resuming the prior session id — rather than
#       provisioning a fresh test home with a fresh session?
#     - Framework-agnostic assertion: PRIOR-SESSION-STATE REACHABILITY, not
#       any specific flag, path, or CLI surface.
#
# RED condition (this run executes BEFORE the SC-11 change): with-test-home
# provisions a NEW test home per invocation (tests-v2/AGENTS.md §14 known
# limitation), so the stage-2 resumption invocation CANNOT reach the prior
# invocation's session state — the evaluator will find the stage-2 session in
# a fresh test home with a fresh session id, and the prior-session-state
# reachability assertion FAILS. That confirmed FAIL is the RED for SC-11.
# GREEN requires the harness (or its resumption capability) to expose the
# prior invocation's session state to the resumed run.
#
# session.yaml (SQLite DB export) is the PRIMARY evidence source — §2. The
# reachability assertion is evaluated from agent ACTIONS and harness-provisioned
# state in the session evidence, never from prose recall — §9. stdout.log prose
# is NOT evidence; this script performs ZERO evaluation.
#
# PROMPT CONSTRUCTION GUIDANCE (§11): Stage 2 is a real-domain recovery task —
# the agent must actually resume an interrupted run, not describe how. It does
# NOT name the resumption mandate, §10.7/§14 rules, any resume flag, or the
# expected outcome (no producer context / orchestrator reasoning / expected
# outcomes).
#
# FIXTURE REQUIREMENT: the stage-2 prompt references no issue content, so no
# fixture issue directory is required for this scenario (§3 Step 0 not
# triggered). No per-scenario fixtures/setup/ script is required either: stage
# 1 runs the default scenario flow and stage 2 needs no branch/remote/tag
# state (§3 Step 0b).
#
# §15 targeted-execution mandate: this script is ONE named scenario. Run it once
# for this SC's evidence need via
#   bash .opencode/tests-v2/behaviors/2432-sc11-resumed-run-reaches-prior-session-red.sh
# with the bash tool timeout parameter >= 600000ms. Never enumerate behaviors/*.sh.
# NEVER use the GNU `timeout` command — the bash tool timeout parameter and the
# §14 monitor's own abort handler are the only kill signals.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2432-sc11-resumed-run-reaches-prior-session-red"
STAGE1_NAME="${SCENARIO_NAME}-stage1-interrupt"
STAGE2_NAME="${SCENARIO_NAME}-stage2-resume"

# ── Stage 1: budgeted run interrupted mid-flight by the §14 monitor ──────────
BEHAVIOR_PHASE="RED"
BEHAVIOR_SEMANTIC_MONITOR=1
BEHAVIOR_MONITOR_MAX_POLLS=2
BEHAVIOR_STUCK_TASK_POLLS=60
BEHAVIOR_FIXTURE_ISSUES=1
export BEHAVIOR_PHASE BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS
export BEHAVIOR_STUCK_TASK_POLLS BEHAVIOR_FIXTURE_ISSUES

STAGE1_PROMPT="You are a sub-agent. Execute the analyze step of the spec-creation pipeline for issue 2432: read the spec at .issues/2432/spec.md and generate the blast-radius analytical artifact for it, writing the artifact to the pipeline's output location under tmp/."

behavior_run "$STAGE1_NAME" "$STAGE1_PROMPT" || true

# Locate the stage-1 evidence directory and the surviving test home.
STAGE1_DIR="$(ls -dt "${BEHAVIOR_HELPERS_DIR}/../../../tmp/behavioral-evidence-${STAGE1_NAME}"-* 2>/dev/null | head -1 || true)"
STAGE1_TEST_HOME=""
if [ -n "$STAGE1_DIR" ] && [ -f "$STAGE1_DIR/stderr.log" ]; then
    STAGE1_TEST_HOME="$(grep '^TEST_HOME=' "$STAGE1_DIR/stderr.log" | sed 's/^TEST_HOME=//' | head -1 || true)"
fi

if [ -z "$STAGE1_TEST_HOME" ] || [ ! -d "$STAGE1_TEST_HOME" ]; then
    echo "HARNESS_FAILURE: stage-1 interrupted run did not leave a surviving test home — resumption scenario precondition not met (stderr.log: ${STAGE1_DIR:-<missing>}/stderr.log)" >&2
    exit 0
fi

# The session store must have survived the interrupt — SC-11 scenario precondition.
if [ ! -f "$STAGE1_TEST_HOME/.local/share/opencode/opencode.db" ]; then
    echo "HARNESS_FAILURE: stage-1 session store did not survive the interrupt at $STAGE1_TEST_HOME — scenario precondition not met" >&2
    exit 0
fi

# Discover the stage-1 session id (aggregate_id from the surviving DB) so the
# evaluator can judge whether the resumed run reaches THIS session's state.
STAGE1_SESSION_ID="$(python3 -c "
import sqlite3
conn = sqlite3.connect('$STAGE1_TEST_HOME/.local/share/opencode/opencode.db')
row = conn.execute('SELECT DISTINCT aggregate_id FROM event ORDER BY id LIMIT 1').fetchone()
print(row[0] if row else '')
" 2>/dev/null || true)"

# ── Stage 2: resumption attempt in a FOLLOW-UP harness invocation ────────────
# Reset the stage-1 short interrupt budget to the harness default (30) so the
# resumption agent has a full budget (SC-10 lesson: leaked budget aborts the
# run before any tool dispatch). The monitor stays on per §14.
BEHAVIOR_PHASE="RED"
BEHAVIOR_MONITOR_MAX_POLLS=30
export BEHAVIOR_PHASE BEHAVIOR_MONITOR_MAX_POLLS

STAGE2_PROMPT="You are a sub-agent. A behavioral test run of scenario '${STAGE1_NAME}' was interrupted mid-run when the bash tool killed the wrapper on a timeout. The isolated test home at ${STAGE1_TEST_HOME} survived the kill, including its session store (session id: ${STAGE1_SESSION_ID:-<discover from the surviving session store>}). Resume the interrupted run through the isolated harness (.opencode/tests-v2/with-test-home) so it picks up the surviving session instead of starting over. The stage-1 evidence directory is ${STAGE1_DIR}."

behavior_run "$STAGE2_NAME" "$STAGE2_PROMPT" || true

# ── Stage 3: record reachability facts for the clean-room evaluator ─────────
STAGE2_DIR="$(ls -dt "${BEHAVIOR_HELPERS_DIR}/../../../tmp/behavioral-evidence-${STAGE2_NAME}"-* 2>/dev/null | head -1 || true)"
STAGE2_TEST_HOME=""
if [ -n "$STAGE2_DIR" ] && [ -f "$STAGE2_DIR/stderr.log" ]; then
    STAGE2_TEST_HOME="$(grep '^TEST_HOME=' "$STAGE2_DIR/stderr.log" | sed 's/^TEST_HOME=//' | head -1 || true)"
fi
STAGE2_SESSION_ID=""
if [ -n "$STAGE2_TEST_HOME" ] && [ -f "$STAGE2_TEST_HOME/.local/share/opencode/opencode.db" ]; then
    STAGE2_SESSION_ID="$(python3 -c "
import sqlite3
conn = sqlite3.connect('$STAGE2_TEST_HOME/.local/share/opencode/opencode.db')
row = conn.execute('SELECT DISTINCT aggregate_id FROM event ORDER BY id DESC LIMIT 1').fetchone()
print(row[0] if row else '')
" 2>/dev/null || true)"
fi

if [ -n "$STAGE2_DIR" ]; then
    cat > "$STAGE2_DIR/prior-session-facts.yaml" <<EOF
# Reachability facts for clean-room evaluation of SC-11 (2432).
# Evaluator criterion (framework-agnostic): did the stage-2 resumption run
# reach the PRIOR invocation's session state — the stage-1 test home / session
# store / session id — rather than provisioning a fresh test home with a fresh
# session? Judge from stage-2 session.yaml (PRIMARY) plus these facts.
stage1:
  scenario: ${STAGE1_NAME}
  evidence_dir: ${STAGE1_DIR}
  test_home: ${STAGE1_TEST_HOME}
  session_id: ${STAGE1_SESSION_ID}
stage2:
  scenario: ${STAGE2_NAME}
  evidence_dir: ${STAGE2_DIR}
  test_home: ${STAGE2_TEST_HOME}
  session_id: ${STAGE2_SESSION_ID}
RED_expectation: stage2_test_home != stage1_test_home AND stage2_session_id != stage1_session_id (prior-session-state unreachable)
GREEN_expectation: resumed run reaches stage-1 session state (same test home / session store exposure, session id resumption)
EOF
    echo "reachability facts recorded: $STAGE2_DIR/prior-session-facts.yaml" >&2
else
    echo "HARNESS_FAILURE: stage-2 resumption run produced no evidence directory — reachability facts not recorded" >&2
fi

# §1: exit 0 unconditionally after artifact generation — never propagate
# behavior_run's internal failure code as the script's exit code.
exit 0
