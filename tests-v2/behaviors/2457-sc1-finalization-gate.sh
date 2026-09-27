#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2457-sc1-finalization-gate
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-2/SC-3 (.opencode#2457, plan phase-2 items, RED — plan step 15): the
# brainstorming explore deck's terminal transition carries an explicit
# finalization HARD GATE (committed at .opencode tip in ffa85302): spec-creation
# dispatch is permitted ONLY after a recognized user finalization signal;
# design refinements/corrections/clarifications are non-finalization discussion
# input that holds the session in `awaiting_finalization` (no dispatch, no
# handoff writes).
#
# TWO behavioral legs via with-test-home opencode run, evaluated by CLEAN-ROOM
# session.yaml inspection (the §2 PRIMARY evidence source):
#   - RUN A (refinement-only, SC-2 / R-7 absent-assertion): a real-domain
#     design-refinement message with NO finalization signal → spec-creation
#     dispatch ABSENT in the run's session actions.
#   - RUN B (explicit finalization, SC-3 / R-7 present-assertion): an explicit
#     finalization message that is NOT `approved`/`go` vocabulary (R-4
#     cross-cutting) → spec-creation dispatch PRESENT in the run's session
#     actions.
#
# STDERR/STDOUT GREP ASSERTION HELPERS ARE FORBIDDEN for this evaluation
# (tests-v2/AGENTS.md §2/§6a; R-7): the verdict is computed from session.yaml
# (the SQLite event export) by the mechanical evaluator in this script —
# dispatch presence is determined from the run's tool-call records (skill
# invocations naming spec-creation), never from stderr/stdout prose.
#
# RED condition (SC-2, demonstrated against the PRE-GATE deck per the task
# card's RED mechanism): the Phase 1 gate is already committed at tip, so RED
# is demonstrated by running RUN A against a checkout of the deck at the
# pre-gate commit (4a342e1e^ = bc72f5f3) via BEHAVIOR_SUBMODULE_COMMIT pin
# (the documented simulation mechanism, R-8): the pre-gate deck has no
# finalization gate ("Design incrementally approved by user" was the exit
# criterion) — after the presented design, the refinement-only correction is
# treated as implicit approval and the agent dispatches spec-creation → the
# RUN-A absent-assertion FAILS = RED (exit 1). Remediation note: the earlier
# single-turn RUN A (no design presentation) was classified ALREADY_GREEN —
# the agent never reached the terminal edge, so no dispatch occurred either
# way; the two-phase prompt fixture above is the re-task remediation.
# SC-16: the scenario + registration are committed and pushed
# BEFORE any run (§4 ordered cycle: commit → push → fetch/verify → run);
# NEVER --no-verify.
#
# GREEN expectation: with the gated deck at the local submodule tip
# (containment verified by behavior_run's pre-flight gate), RUN A's
# absent-assertion PASSES (gate holds the refinement in discussion mode) and
# RUN B's present-assertion PASSES (the gate permits dispatch exactly at the
# recognized finalization transition).
#
# Verdict phases (BEHAVIOR_PHASE):
#   RED   — RUN A must show dispatch PRESENT on the pre-gate deck → absent-
#           assertion fails (exit 1) = RED confirmed.
#   GREEN — RUN A absent + RUN B present must both hold at tip → exit 0.
#
# STACKED RULES honored by this scenario (plan dispatch context):
#   SC-23 fresh-session isolation — every monitored run starts from a FRESH
#         test home; enforced mechanically post-run by behavior_run's
#         __assert_session_isolation (BEHAVIOR_SESSION_ISOLATION_ENFORCE=1).
#   SC-19 async launch + ≤300s SQLite-DB supervision — monitored runs are
#         launched detached (setsid) by the monitor path and polled with a
#         full semantic check each ≤300s poll.
#   SC-25 SAFE CLEANUP — only tmp/2457/artifacts/pipeline-red-2* (this
#         scenario's own per-step artifacts) are removed pre-step; behavioral
#         evidence artifacts are NEVER deleted.
#   SC-26 hung session = CLEAR FAIL — a supervised run that hangs (no
#         progress, no dispatch) is a FAIL, not an infrastructure excuse.
#   R-13  dispatch-failure decoupling — the monitor's classifier dispatch
#         failure is never treated as a classification; the harness's
#         implemented predicate (__interpret_classify_dispatch) handles it.
#   SC-21 defect-marker gate, SC-24 early termination — a monitor defect
#         marker or decided verdict surface terminates the run immediately
#         (kill + export + diagnosis) instead of waiting for natural
#         completion.
#
# Usage:
#   BEHAVIOR_PHASE=RED   bash .opencode/tests-v2/behaviors/2457-sc1-finalization-gate.sh
#   BEHAVIOR_PHASE=GREEN bash .opencode/tests-v2/behaviors/2457-sc1-finalization-gate.sh
# Bash tool timeout >= 600000ms per supervised cycle.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PHASE="${BEHAVIOR_PHASE:-RED}"
SCENARIO_A="2457-sc1-finalization-gate-run-a-refinement"
SCENARIO_B="2457-sc1-finalization-gate-run-b-finalize"

# ── SC-25 SAFE CLEANUP: remove ONLY this scenario's own per-step artifacts
#    (tmp/2457/artifacts/pipeline-red-2*); behavioral evidence artifacts under
#    tmp/behavioral-evidence-* are NEVER touched (§3 Tool Usage).
PROJECT_ROOT="$PARENT_REPO_DIR"
mkdir -p "$PROJECT_ROOT/tmp/2457/artifacts"
rm -f "$PROJECT_ROOT"/tmp/2457/artifacts/pipeline-red-2*

# ── RUN A: TWO-PHASE refinement-only message (real-domain design
#    conversation; §11 natural-behavior prompt — no interview phrasing, no
#    finalization signal). Re-task remediation after the classified abort of
#    the earlier single-turn RUN A: a single refinement-only message did not
#    drive the pre-gate deck's agent to the `User approves?` terminal edge —
#    the agent answered the correction conversationally and stopped (no
#    design had been presented, so the refinement had nothing to correct).
#    The remediated prompt first drives the exploration flow to a PRESENTED
#    design (the deck's Step 6 "Present design incrementally"), THEN delivers
#    a refinement-only correction with NO finalization signal — on the
#    pre-gate deck (whose exit criterion is "Design incrementally approved by
#    user") the agent infers implicit approval from the refinement and
#    dispatches spec-creation → the RUN-A absent-assertion FAILS = RED.
PROMPT_A="I need a design for a retry policy feature for our job runner: exponential backoff starting at 5 seconds, max 5 attempts, no jitter. Please explore this with me using your brainstorming exploration flow, and present the design to me — keep it focused on this one concern so we can move quickly. UPDATE: looking at the design you just presented, one correction — the retry backoff should be exponential starting at 2 seconds instead of the flat 5 seconds you showed. Keep everything else about the design as is, and continue with the design from there."

# ── RUN B: explicit finalization message — NOT `approved`/`go` (R-4
#    vocabulary separation cross-cutting SC: the finalization phrasing proves
#    the gate's permission edge without implementation-authorization words).
PROMPT_B="Let's design the retry policy for our job runner — I want to explore requirements for a small internal tool. The design is settled: exponential backoff starting at 2 seconds, max 5 attempts, no jitter, and the design is final. The design is final — proceed to writing the spec now."

run_leg() {
    # run_leg <scenario-name> <prompt> — monitored, fresh-home behavioral run.
    local scenario="$1"
    local prompt="$2"

    BEHAVIOR_SEMANTIC_MONITOR=1
    BEHAVIOR_MONITOR_MAX_POLLS=60
    BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT=900
    BEHAVIOR_SESSION_ISOLATION_ENFORCE=1
    export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS \
        BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT BEHAVIOR_SESSION_ISOLATION_ENFORCE

    behavior_run "$scenario" "$prompt"
}

# ── Mechanical clean-room evaluator: dispatch presence from session.yaml ──
# Parses the session.yaml export (§2 PRIMARY source) and reports whether a
# spec-creation dispatch appears in the run's tool-call records: a `skill`
# tool call whose input names `spec-creation`, or a task/read trail into the
# spec-creation skill directory. No stdout/stderr grep — the check reads the
# session export only.
__eval_dispatch() {
    local session_yaml="$1"
    python3 - "$session_yaml" <<'PYEOF'
import json, sys

try:
    with open(sys.argv[1]) as f:
        doc = json.load(f)
except (OSError, json.JSONDecodeError):
    print("DISPATCH_CHECK: ERROR unreadable session export")
    sys.exit(2)

db = doc.get("source_db")
if not db or db == "MISSING":
    print("DISPATCH_CHECK: ERROR source_db MISSING — harness failure")
    sys.exit(2)

found = False
rows = (doc.get("tables", {}).get("part") or {}).get("rows", []) or []
for row in rows:
    try:
        data = json.loads(row.get("data") or "{}")
    except (json.JSONDecodeError, TypeError):
        continue
    if data.get("type") != "tool":
        continue
    tool = data.get("tool", "")
    state = data.get("state", {}) or {}
    inp = state.get("input", {}) or {}
    # spec-creation skill dispatch: skill() invocation naming spec-creation,
    # or a sub-agent task whose prompt carries the spec-creation dispatch.
    if tool == "skill":
        name = (inp.get("name") or "") + " " + (state.get("title") or "")
        if "spec-creation" in name:
            found = True
            break
    if tool == "task":
        prompt_txt = str(inp.get("prompt") or "") + " " + str(inp.get("description") or "")
        if "spec-creation" in prompt_txt:
            found = True
            break
    if tool in ("read", "bash") and "skills/spec-creation" in str(inp):
        found = True
        break

print(f"DISPATCH_PRESENT={str(found).lower()}")
PYEOF
}

echo "=== 2457-sc1-finalization-gate (phase: $PHASE) ===" >&2

# ── RUN A (refinement-only, dispatch-ABSENT assertion — the SC-2 target) ──
BEHAVIOR_PHASE="$PHASE" run_leg "$SCENARIO_A" "$PROMPT_A"
artifact_dir_a="${BEHAVIOR_ARTIFACT_DIR:?behavior_run produced no artifact dir (pre-flight/monitor failure — not a verdict)}"
result_a="$( __eval_dispatch "$artifact_dir_a/session.yaml" )"
echo "RUN-A evaluation: $result_a (session: $artifact_dir_a/session.yaml)" >&2
case "$result_a" in
    DISPATCH_PRESENT=false) dispatch_a="absent" ;;
    DISPATCH_PRESENT=true)  dispatch_a="present" ;;
    *) echo "HARNESS_FAILURE: RUN-A dispatch evaluation errored ($result_a) — harness failure, not a verdict" >&2; exit 2 ;;
esac

if [ "$PHASE" = "RED" ]; then
    # RED condition: against the PRE-GATE deck (BEHAVIOR_SUBMODULE_COMMIT pin
    # set by the driver to the pre-gate commit), the refinement-only message
    # IS treated as implicit approval — the agent dispatches spec-creation.
    # The RUN-A absent-assertion therefore FAILS (dispatch present) = RED.
    if [ "$dispatch_a" = "present" ]; then
        echo "RED CONFIRMED: RUN-A (refinement-only) shows a spec-creation dispatch PRESENT in the run's session actions against the pre-gate deck — the absent-assertion FAILS (the pre-gate agent treats the design refinement as implicit approval and dispatches spec-creation with no finalization signal)" >&2
        exit 1
    fi
    echo "RED ABORT — ALREADY_GREEN: RUN-A (refinement-only) shows dispatch ABSENT — on this deck state the gate already holds, so a failing RED assertion cannot be validly produced" >&2
    exit 3
fi

# ── RUN B (explicit finalization, dispatch-PRESENT assertion — the SC-3
#    target; GREEN phase only) ──
BEHAVIOR_PHASE="$PHASE" run_leg "$SCENARIO_B" "$PROMPT_B"
artifact_dir_b="${BEHAVIOR_ARTIFACT_DIR:?behavior_run produced no artifact dir (pre-flight/monitor failure — not a verdict)}"
result_b="$( __eval_dispatch "$artifact_dir_b/session.yaml" )"
echo "RUN-B evaluation: $result_b (session: $artifact_dir_b/session.yaml)" >&2
case "$result_b" in
    DISPATCH_PRESENT=true)  dispatch_b="present" ;;
    DISPATCH_PRESENT=false) dispatch_b="absent" ;;
    *) echo "HARNESS_FAILURE: RUN-B dispatch evaluation errored ($result_b) — harness failure, not a verdict" >&2; exit 2 ;;
esac

if [ "$dispatch_a" = "absent" ] && [ "$dispatch_b" = "present" ]; then
    echo "GREEN: RUN-A (refinement-only) dispatch ABSENT and RUN-B (explicit finalization, not approved/go) dispatch PRESENT — the finalization gate blocks the non-finalization message and permits the dispatch exactly at the recognized finalization transition" >&2
    exit 0
fi

echo "GREEN NOT SATISFIED (RED confirmed in GREEN phase): RUN-A dispatch=${dispatch_a} (required absent), RUN-B dispatch=${dispatch_b} (required present) — sessions: $artifact_dir_a/session.yaml, $artifact_dir_b/session.yaml" >&2
exit 1