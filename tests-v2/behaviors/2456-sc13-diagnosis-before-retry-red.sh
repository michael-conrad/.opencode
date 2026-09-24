#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2456-sc13-diagnosis-before-retry-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-13 (.opencode#2456, plan-06 phase-6 item, RED): a run classified
# non-progressing (off-track or undetermined) by the full semantic check, with
# an identifiable external cause in the run evidence (orphaned run processes,
# provider quota/error output), produces a determination record whose decision
# field is `terminate-with-root-cause` NAMING the diagnosed cause; a
# `continue-new-dispatch` that merely raises a timeout without a recorded
# diagnosis is prohibited (R-9 — SC-8's gate blocks any resume/re-run until
# the diagnosis-bearing determination exists).
#
# EXERCISE SURFACE — the already-enforced SC-6 halt-class path on a
# non-progressing classification: the scenario declares NO verifiable goal
# condition (the 2456-sc6/sc7 undetermined fixture shape) so the classifier
# returns undetermined — a semantically classified NON-PROGRESSING run — and
# the halt+notify routing emits ORCHESTRATOR_DECISION_REQUIRED on stderr and
# MONITOR-HALTED in the poll log. The halt-class path leaves the run process
# running for the orchestrator — the ORPHANED-RUN-PROCESSES external cause the
# SC-13 predicate names. The assertion target is the determination record's
# orchestrator decision AFTER that halt-class notification on the
# non-progressing classification.
#
# SC-13 SINGLE-ASSERTION TARGET: the recorded decision field on the
# determination record after the halt-class non-progressing classification.
# - GATE (green): decision == terminate-with-root-cause AND a root_cause is
#   recorded whose content names the diagnosed external cause identified in
#   the run evidence (orphaned run processes / provider quota / provider
#   error output).
# - PROHIBITED (red #1): decision == continue-new-dispatch — timer-escalation
#   blind continue on a classified non-progressing run (with or without any
#   generic explanation; a decision that is NOT diagnosis-derived).
# - ABSENT (red #2): no orchestrator decision entry at all.
# - NON-DIAGNOSIS (red #3): decision == terminate-with-root-cause but its
#   root_cause does not name an identifiable external cause (generic
#   exit-code seat-of-the-pants text instead of the diagnosis).
#
# RED condition (known gap): helpers.sh's SC-7 entry mechanism records the
# decision AFTER the halt-class notification from the run's exit code ALONE
# — the left-running run completing naturally records continue-new-dispatch
# with no diagnosis, and a failed run records a generic exit-code root cause
# — neither is diagnosis-derived; no diagnosis-before-retry gate exists.
# Expected RED today: the halt-class path is fully exercised
# (MONITOR-HALTED + ORCHESTRATOR_DECISION_REQUIRED present, undetermined
# classification on the record) yet the recorded decision carries
# continue-new-dispatch with no root_cause/ diagnosis content → exit 1.
# If the machinery were entirely absent the record carries no decision →
# exit 1 as well.
#
# GREEN expectation (after the phase-6 fix): the determination record's
# decision is terminate-with-root-cause whose root_cause names the diagnosed
# external cause present in the run evidence → exit 0.
#
# ASSERTION TARGET — harness infrastructure, not model output: this scenario
# is the TDD enforcement test for the SC-13 diagnosis-before-retry
# predicate. It makes NO judgment about whether the classification VALUE is
# correct for the dispatch (the classifier's semantic judgment is exercised,
# not re-judged here); the verdict-bearing assertion is the decision field's
# diagnosis linkage. The §1 exit-0 unconditional paradigm does NOT apply to
# a harness-behavior enforcement test whose assertion target is the harness
# itself (same exception as 2456-sc1..sc7).
#
# PRECONDITION GUARDS (exit 2 = invalid RED, requires diagnosis — never a
# verdict): required are (a) the scenario evidence directory with
# session.yaml, monitor.log, classifier-session.yaml, and determination.yaml
# (SC-3 record writing flows through every monitored run), and (b) the
# halt-class notification path exercised on this run: a MONITOR-HALTED line
# in the poll log AND ORCHESTRATOR_DECISION_REQUIRED in the harness stderr
# capture with the record's final classification non-progressing
# (undetermined or off-track) — without them the orchestrator decision point
# for a non-progressing run was never reached, so the SC-13 assertion
# surface is absent (not a RED verdict).
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   BEHAVIOR_PHASE=RED bash .opencode/tests-v2/behaviors/2456-sc13-diagnosis-before-retry-red.sh
# with the bash tool timeout >= 600000ms per supervision poll (supervised
# run, §14 mandate — launched once detached/setsid, polled every <=300s with
# a full semantic check of the run's SQLite session DB).
#
# Ordered precondition cycle (§4/SC-16): commit → push → fresh fetch/verify
# → run. NEVER --no-verify.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc13-diagnosis-before-retry-red"
# §11 real-domain prompt: the same mechanically light heartbeat protocol loop
# the sc7 fixture uses (fully-specified distinct lines, one write per cycle,
# bounded count, explicit stop — the diagnosis-2 interpretive-load lesson)
# so the run completes naturally inside the monitor budget and the post-run
# block writes the determination record.
SCENARIO_PROMPT="Follow this repository working protocol exactly — it is the entire task. Working protocol (run log): Create a file named run-log.md in the current project root if it does not exist. Then append the following lines to run-log.md in order, exactly one line per work cycle (one write tool call per line — never batch multiple lines into a single write): run 01: cycle logged / run 02: cycle logged / run 03: cycle logged / run 04: cycle logged / run 05: cycle logged / run 06: cycle logged / run 07: cycle logged / run 08: cycle logged. After all eight lines are appended, the protocol loop is complete — stop."

# SC-13 monitored run (opt-in flags per spec — fresh invocations without the
# flags are unchanged; backward compat preserved). Same shape as the
# already-enforced 2456-sc6/sc7 undetermined fixture.
BEHAVIOR_SEMANTIC_MONITOR=1
BEHAVIOR_MONITOR_MAX_POLLS=60
BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT=900
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS BEHAVIOR_MONITOR_CLASSIFY_TIMEOUT

# DELIBERATELY NO goal-condition declaration: no BEHAVIOR_EXPECTED_ARTIFACT,
# no BEHAVIOR_EXPECTED_ARTIFACT_GREP, no BEHAVIOR_GOAL_ACTIONS. The empty
# goal_condition makes undetermined the classifier's only
# direction-anchored answer (helpers.sh classifier prompt, undetermined
# definition clause 2) — the semantically classified NON-PROGRESSING
# exercise surface the SC-13 predicate is gated on.

# Harness stderr capture — the durable precondition surface for the
# halt-class notification convention.
mkdir -p "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
harness_stderr_capture="$BEHAVIOR_LOG_DIR/$SCENARIO_NAME/harness-stderr.log"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" 2> "$harness_stderr_capture" || true

# ── Precondition guards ──────────────────────────────────────────────────
artifact_dir="${BEHAVIOR_ARTIFACT_DIR:-}"
monitor_log="$artifact_dir/monitor.log"

if [ -z "$artifact_dir" ] || [ ! -d "$artifact_dir" ]; then
    echo "PRECONDITION-FAIL: no scenario evidence directory produced (BEHAVIOR_ARTIFACT_DIR='${artifact_dir:-unset}') — harness failure, not a RED verdict; harness stderr capture: $harness_stderr_capture" >&2
    exit 2
fi
for required in session.yaml classifier-session.yaml; do
    if [ ! -f "$artifact_dir/$required" ]; then
        echo "PRECONDITION-FAIL: $required missing from $artifact_dir — run produced incomplete evidence; not a RED verdict" >&2
        exit 2
    fi
done
if [ ! -f "$harness_stderr_capture" ]; then
    echo "PRECONDITION-FAIL: harness stderr capture missing at $harness_stderr_capture — the precondition surface is absent; not a RED verdict" >&2
    exit 2
fi
cp "$harness_stderr_capture" "$artifact_dir/harness-stderr.log" 2>/dev/null || true
if [ ! -f "$monitor_log" ]; then
    echo "PRECONDITION-FAIL: monitor.log missing from $artifact_dir — the semantic monitor did not run (SC-1 persistence absent); not a RED verdict" >&2
    exit 2
fi
if [ ! -f "$artifact_dir/determination.yaml" ]; then
    echo "PRECONDITION-FAIL: determination.yaml missing from $artifact_dir — the SC-3 determination record was not written for this monitored run; harness gap, not a RED verdict" >&2
    exit 2
fi

# Precondition (b): the halt-class notification path was exercised AND the
# record's final classification is a non-progressing value — the
# classified-non-progressing trigger state SC-13 is gated on.
halt_class="$(grep -oE 'MONITOR-HALTED polls=[0-9]+ halt_class=[a-z-]+' "$monitor_log" | tail -1 || true)"
if [ -z "$halt_class" ]; then
    echo "PRECONDITION-FAIL: no MONITOR-HALTED line in $monitor_log — monitoring was never halted on a halt-class classification, so the orchestrator decision point for a non-progressing run was never reached; classifications present: $(grep -c '^CLASSIFY\[' "$monitor_log" || true); not a RED verdict" >&2
    exit 2
fi
if ! grep -q "ORCHESTRATOR_DECISION_REQUIRED" "$artifact_dir/harness-stderr.log"; then
    echo "PRECONDITION-FAIL: ORCHESTRATOR_DECISION_REQUIRED absent from the harness stderr capture ($artifact_dir/harness-stderr.log) despite halt_class='${halt_class}' — the SC-6 halt+notify routing did not fire, so the orchestrator decision point was never reached; not a RED verdict" >&2
    exit 2
fi
final_classification="$(grep -E '^  classification: ' "$artifact_dir/determination.yaml" | head -1 | sed 's/^  classification: //' || true)"
case "$final_classification" in
    undetermined|off-track) ;; # the SC-13 non-progressing trigger states
    "progressing-directionally")
        echo "PRECONDITION-FAIL: final classification on $artifact_dir/determination.yaml is 'progressing-directionally' — the run classified as progressing, so the SC-13 non-progressing assertion surface was never reached; not a RED verdict (infra/trigger-state fixture problem, needs diagnosis)" >&2
        exit 2
        ;;
    *)
        echo "PRECONDITION-FAIL: final classification '${final_classification}' unparseable on $artifact_dir/determination.yaml — record-schema defect needs diagnosis; not a RED verdict" >&2
        exit 2
        ;;
esac

# ── Identifiable-external-cause evidence scan (the SC-13 predicate's second
#    gate condition). The SC-13 fixture surface: the halt-class path leaves
#    the run process running (orphaned run processes) and the run evidence
#    may additionally carry provider quota/error output. This scan records
#    which identifiable external causes exist in this run's evidence so the
#    decision-verdict logic can require the root_cause to NAME the diagnosed
#    cause.
externalcause_orphans=0
externalcause_provider=0
# Orphaned/left-running run processes: the monitor's halt-class state leaves
# the run process for the orchestrator — visible in the poll log's halt
# annotation or in the determination record's run provenance.
if grep -qiE 'left[ -]running|orphan' "$monitor_log" "$artifact_dir/determination.yaml" 2>/dev/null; then
    externalcause_orphans=1
fi
# Provider quota/error output in the run's captured evidence.
if grep -qiE 'spending limit|quota|rate.?limit|provider.*error|inference providers' \
    "$artifact_dir/stdout.log" "$artifact_dir/stderr.log" \
    "$artifact_dir/harness-stderr.log" "$monitor_log" 2>/dev/null; then
    externalcause_provider=1
fi
{
    echo "# SC-13 identifiable-external-cause evidence scan (assertion input)"
    echo "externalcause_orphans: ${externalcause_orphans}"
    echo "externalcause_provider: ${externalcause_provider}"
} > "$artifact_dir/external-cause-scan.yaml"

# ── Verdict: the SC-13 single assertion — the recorded decision field must
#    be diagnosis-derived. Pull the FIRST recorded orchestrator decision
#    entry after the halt-class notification.
decision_section="$(sed -n '/^[[:space:]]*orchestrator_decisions:/,$p' "$artifact_dir/determination.yaml")"
decision_value="$(printf '%s' "$decision_section" | grep -oE 'continue-new-dispatch|terminate-with-root-cause' | head -1 || true)"
root_cause="$(printf '%s' "$decision_section" | grep -E '^      root_cause: .+' | head -1 | sed 's/^      root_cause: //' || true)"

PHASE="${BEHAVIOR_PHASE:-RED}"

# Identifiable external cause named in the root cause? An external cause is
# "named" when the root-cause text references the orphaned-run-processes
# condition, the provider/quota condition, or any other cause derived from
# THIS run's evidence — a generic exit-code restatement names nothing.
cause_named=0
if [ -n "$root_cause" ]; then
    case "$root_cause" in
        *orphan*|*left-running*|*left\ running*|*quota*|*spending\ limit*|*rate\ limit*|*provider*) cause_named=1 ;;
    esac
    if [ "$externalcause_provider" = "1" ] \
        && printf '%s' "$root_cause" | grep -qiE 'spending limit|quota|rate.?limit|inference providers'; then
        cause_named=1
    fi
fi

if [ "$PHASE" = "GREEN" ]; then
    if [ -n "$decision_value" ] && [ "$decision_value" = "terminate-with-root-cause" ] \
        && [ -n "$root_cause" ] && [ "$cause_named" = "1" ]; then
        echo "GREEN: the determination record carries diagnosis-derived decision 'terminate-with-root-cause' naming the diagnosed external cause (${halt_class}; undetermined classification; evidence scan orphans=${externalcause_orphans} provider=${externalcause_provider}) — root_cause: '${root_cause}' in $artifact_dir/determination.yaml" >&2
        exit 0
    fi
    echo "GREEN NOT SATISFIED (RED confirmed in GREEN phase): the halt-class non-progressing decision point was exercised (${halt_class}; undetermined classification) but the determination record ($artifact_dir/determination.yaml) does NOT carry a diagnosis-derived terminate-with-root-cause decision — decision='${decision_value:-none}', root_cause='${root_cause:-none}', cause_named=${cause_named}" >&2
    exit 1
fi

# RED phase: the predicate must hold on the recorded decision.
if [ -n "$decision_value" ] && [ "$decision_value" = "terminate-with-root-cause" ] \
    && [ -n "$root_cause" ] && [ "$cause_named" = "1" ]; then
    echo "RED ABORT — ALREADY_GREEN: the determination record already carries the SC-13 predicate ('terminate-with-root-cause' naming the diagnosed external cause — root_cause: '${root_cause}') — the expected-failing behavior is already implemented, so a failing RED test cannot be validly produced" >&2
    exit 3
fi

if [ -z "$decision_value" ]; then
    echo "RED CONFIRMED: the halt-class non-progressing decision point was reached (${halt_class}; classification='${final_classification}'; ORCHESTRATOR_DECISION_REQUIRED present) but $artifact_dir/determination.yaml carries NO orchestrator decision entry at all — the decision-record write path is absent (SC-13 predicate absent: no terminate-with-root-cause naming a diagnosed cause can be produced)" >&2
    exit 1
fi

if [ "$decision_value" = "continue-new-dispatch" ]; then
    echo "RED CONFIRMED: the halt-class non-progressing decision point was reached (${halt_class}; classification='${final_classification}'; ORCHESTRATOR_DECISION_REQUIRED present; evidence scan orphans=${externalcause_orphans} provider=${externalcause_provider}) but the recorded orchestrator decision is 'continue-new-dispatch' with root_cause='${root_cause:-none}' — a blind timer-escalation continue on a classified non-progressing run WITHOUT a recorded diagnosis (the prohibited pattern SC-13/R-9 closes: helpers.sh records the decision from the run's exit code alone; no diagnosis-before-retry gate exists — a failed/left-running run is answered with continue-new-dispatch rather than a diagnosis naming the identified external cause)" >&2
    exit 1
fi

echo "RED CONFIRMED: the halt-class non-progressing decision point was reached (${halt_class}; classification='${final_classification}') and the record carries decision='terminate-with-root-cause' but its root_cause ('${root_cause}') does NOT name an identifiable external cause present in this run's evidence (orphans=${externalcause_orphans} provider=${externalcause_provider}) — a generic exit-code restatement instead of the diagnosed cause (SC-13 predicate unmet: the root cause is not diagnosis-derived)" >&2
exit 1
