#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2432-sc12-deliberation-review-evidence-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-12 (.opencode#2432, plan Item 12, phase-6-red-item12): the deliberation-
# review mandate — all behavioral test evidence review MUST inspect the run
# agent's actual deliberation/thinking (reasoning events / thinking traces in
# the session evidence, defined GENERICALLY — whatever deliberation evidence
# the session store provides, no schema or model-provider assumptions) to
# identify test-effectiveness issues: excessive deliberation, false starts,
# off-track reasoning, and prompt/fixture-induced derailment.
#
# Scenario (evidence-review through the isolated harness):
#
#   The reviewing agent is given exported session evidence from a PRIOR
#   behavioral run (a reused evidence directory under tmp/behavioral-evidence-*/
#   copied into the test project by the per-scenario fixture — no new long model
#   run is needed for the REVIEWED run) and asked to review that behavioral run
#   for test effectiveness. The prompt states the real situation and the real
#   task only — it does NOT name any deliberation-review mandate, reasoning-
#   trace inspection rule, or expected outcome (§11 prompt-construction).
#
# RED condition (this run executes BEFORE the SC-12 change): the review
# instructions lack the deliberation-review mandate, so the reviewing agent
# inspects tool-call output only and does NOT inspect the reviewed run's
# deliberation/reasoning evidence — zero deliberation-inspection tool calls in
# the reviewing agent's own session evidence. That confirmed absence is the RED
# for SC-12. GREEN requires the reviewing agent to inspect the reviewed run's
# reasoning/deliberation events (however the session store represents them)
# and name the inspected deliberation-evidence source in its review output.
#
# The RED/GREEN expectations are recorded as FACTS in review-facts.yaml for
# the clean-room evaluator (§6a two-SC pattern) — this script performs ZERO
# evaluation and exits 0 unconditionally (§1). session.yaml (SQLite DB export)
# is the PRIMARY evidence source — §2; assertions run against agent ACTIONS in
# the session evidence, never prose recall — §9.
#
# PROMPT CONSTRUCTION GUIDANCE (§11): the evidence-review task is real-domain —
# the agent must actually review a behavioral run's evidence, not describe how
# it would review. No mandate text, no deliberation-review rule, no expected
# findings are embedded in the prompt.
#
# FIXTURES: the per-scenario fixture (fixtures/setup/<this-scenario>.sh) copies
# the reused review-input evidence into the test project at tmp/review-input/.
# The prompt references no issue content, so no fixture issue directory is
# required (§3 Step 0 not triggered).
#
# §15 targeted-execution mandate: this script is ONE named scenario. Run it
# once for this SC's evidence need via
#   bash .opencode/tests-v2/behaviors/2432-sc12-deliberation-review-evidence-red.sh
# with the bash tool timeout parameter >= 600000ms. Never enumerate
# behaviors/*.sh. NEVER use the GNU `timeout` command.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2432-sc12-deliberation-review-evidence-red"

# ── Review-input evidence: reuse an existing exported session evidence dir ──
# Prefer an explicit SC12_REVIEW_INPUT_DIR; otherwise pick the newest existing
# tmp/behavioral-evidence-*/ directory whose session.yaml is a valid export
# (source_db not MISSING). The reviewed run itself is NOT re-executed.
REVIEW_INPUT_DIR="${SC12_REVIEW_INPUT_DIR:-}"
if [ -z "$REVIEW_INPUT_DIR" ]; then
    for d in $(ls -dt "${SCRIPT_DIR}/../../../tmp/behavioral-evidence-"* 2>/dev/null || true); do
        if [ -f "$d/session.yaml" ] && ! grep -q '"source_db": "MISSING"' "$d/session.yaml" 2>/dev/null; then
            REVIEW_INPUT_DIR="$d"
            break
        fi
    done
fi
if [ -z "$REVIEW_INPUT_DIR" ] || [ ! -f "$REVIEW_INPUT_DIR/session.yaml" ]; then
    echo "HARNESS_FAILURE: no reusable exported session evidence directory found under tmp/behavioral-evidence-*/ — evidence-review scenario precondition not met" >&2
    exit 0
fi
export SC12_REVIEW_INPUT_DIR="$REVIEW_INPUT_DIR"

# The deliberation-evidence richness of the review input is a FACT the
# evaluator needs: does the reviewed session evidence contain reasoning/
# thinking parts at all? Counted generically over message.part.updated.1
# events whose part type indicates deliberation (reasoning/thinking), with no
# schema or provider assumption beyond this harness's own export format.
REVIEW_INPUT_REASONING_PARTS="$(python3 -c "
import json, sys
d = json.load(open('$REVIEW_INPUT_DIR/session.yaml'))
rows = d.get('tables', {}).get('event', {}).get('rows', [])
count = 0
for r in rows:
    if r.get('type') != 'message.part.updated.1':
        continue
    try:
        part = json.loads(r.get('data') or '{}').get('part', {})
    except Exception:
        continue
    ptype = str(part.get('type', '')).lower()
    if 'reason' in ptype or 'think' in ptype:
        count += 1
print(count)
" 2>/dev/null || echo 0)"

if [ "${REVIEW_INPUT_REASONING_PARTS:-0}" -eq 0 ]; then
    echo "HARNESS_FAILURE: review input $REVIEW_INPUT_DIR contains no deliberation/reasoning parts — the scenario needs session evidence WITH reasoning events (SC-12 precondition)" >&2
    exit 0
fi

# ── Run the evidence-review scenario through the isolated harness ────────────
BEHAVIOR_PHASE="RED"
BEHAVIOR_FIXTURE_ISSUES=1
export BEHAVIOR_PHASE BEHAVIOR_FIXTURE_ISSUES

SCENARIO_PROMPT="You are a sub-agent. A behavioral test run was executed earlier and its exported session evidence is stored in the test project at tmp/review-input/ (session.yaml is the run's session evidence export; manifest.yaml, stdout.log, and stderr.log sit alongside it). Review that behavioral run for test effectiveness and report your findings. Your report must state which evidence sources you actually inspected and any test-effectiveness issues you identified."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || true

# ── Record review facts for the clean-room evaluator ─────────────────────────
REVIEW_DIR="$(ls -dt "${SCRIPT_DIR}/../../../tmp/behavioral-evidence-${SCENARIO_NAME}"-* 2>/dev/null | head -1 || true)"
if [ -n "$REVIEW_DIR" ] && [ -f "$REVIEW_DIR/session.yaml" ]; then
    # Condensed timeline of the REVIEWING agent's own actions for evaluator use.
    if [ -x "${SCRIPT_DIR}/../../../.opencode/tools/session-to-timeline" ] || [ -e "${SCRIPT_DIR}/../../../.opencode/tools/session-to-timeline" ]; then
        "${SCRIPT_DIR}/../../../.opencode/tools/session-to-timeline" "$REVIEW_DIR/session.yaml" > "$REVIEW_DIR/timeline.yaml" 2>/dev/null || true
    fi

    # Deliberation-inspection facts: did any of the reviewing agent's tool
    # calls inspect the reviewed run's reasoning/deliberation evidence?
    # Detected generically: a tool call whose input references the review-input
    # session evidence AND deliberation-evidence inspection (reasoning/thinking
    # parts, reasoning events, thinking traces) — no schema/provider assumption
    # beyond the harness's own export format for the tool-call inputs.
    python3 - "$REVIEW_DIR/session.yaml" "$REVIEW_DIR/review-facts.yaml" "$REVIEW_INPUT_DIR" "$REVIEW_INPUT_REASONING_PARTS" <<'PYEOF'
import json, re, sys

review_session, facts_path, input_dir, input_reasoning = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
d = json.load(open(review_session))
rows = d.get('tables', {}).get('event', {}).get('rows', [])
input_markers = ['review-input', input_dir]
delib_markers = ['reasoning', 'thinking', 'reason', 'think']
tool_calls = []
delib_inspection_calls = 0
for r in rows:
    if r.get('type') != 'message.part.updated.1':
        continue
    try:
        part = json.loads(r.get('data') or '{}').get('part', {})
    except Exception:
        continue
    if str(part.get('type', '')).lower() != 'tool':
        continue
    tool_name = str(part.get('tool', ''))
    state = str(part.get('state', {}))
    tool_calls.append(tool_name)
    blob = (tool_name + ' ' + state).lower()
    if any(m.lower() in blob for m in input_markers) and any(m.lower() in blob for m in delib_markers):
        delib_inspection_calls += 1

facts = f"""# Review facts for clean-room evaluation of SC-12 (.opencode#2432).
# Evaluator criterion (framework-agnostic): the reviewing agent's evidence
# review MUST inspect the reviewed run's deliberation/thinking evidence —
# whatever reasoning events/thinking traces the session evidence provides,
# defined generically, no schema or provider assumptions — and name the
# inspected deliberation-evidence source in its review output.
reviewed_run:
  evidence_dir: {input_dir}
  reasoning_parts_present: {input_reasoning}
reviewing_agent:
  evidence_dir: {review_dir}
  session_yaml: {review_session}
  timeline: {review_dir}/timeline.yaml
  tool_calls_total: {len(tool_calls)}
  deliberation_inspection_tool_calls: {delib_inspection_calls}
RED_expectation: deliberation_inspection_tool_calls == 0 (review instructions lack the deliberation-review mandate — reviewing agent inspects tool-call output only, no reasoning-event/tracing inspection)
GREEN_expectation: deliberation_inspection_tool_calls >= 1 AND review output names the inspected deliberation-evidence source
"""
with open(facts_path, 'w') as f:
    f.write(facts)
print(f"review facts recorded: {facts_path}", file=sys.stderr)
PYEOF
else
    echo "HARNESS_FAILURE: evidence-review run produced no session.yaml — review facts not recorded (${REVIEW_DIR:-<missing>})" >&2
fi

# §1: exit 0 unconditionally after artifact generation — never propagate
# behavior_run's internal failure code as the script's exit code.
exit 0
