#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Structural test: 2456-sc9-undetermined-ceiling-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# SC-9 (.opencode#2456, plan-03 Item 9, phase-3 RED): the undetermined-cycle
# ceiling predicate — a counter is persisted across invocations (under the
# existing flock discipline at tmp/.behavior-run.lock), counting 3 undetermined
# determination cycles produces a CEILING_REACHED mechanical block, the
# default ceiling is 3, and the block persists until developer-level
# remediation.
#
# Structural — mechanical counter predicate verified with SYNTHETIC
# determination records. NO MODEL DISPATCH REQUIRED (no opencode run, no
# behavior_run, no monitor lifecycle): the exercise surface is the helpers.sh
# counter/gate path itself, driven directly.
#
# GREEN expectation (recorded here for the Item-9 GREEN task):
#   1. PERSIST: __count_undetermined_cycle <artifact_dir> under the
#      tmp/.behavior-run.lock flock increments a counter persisted across
#      invocations (a state file that survives the process exiting —
#      verified by reading the persisted state back after re-invocation).
#   2. CEILING: after counting 3 undetermined determination cycles, the gate
#      __undetermined_ceiling_check <artifact_dir> produces a CEILING_REACHED
#      mechanical block (stderr line ^FATAL: … CEILING_REACHED …) and returns
#      non-zero — undetermined retries are not permitted past the ceiling.
#   3. DEFAULT: with no override configuration present, the ceiling is 3 —
#      the block fires on the 3rd cycle, not the 2nd and not a 4th.
#   4. PERSISTENT: the block persists until developer-level remediation —
#      a subsequent invocation of the gate still blocks (the clearance is
#      developer-authorized, not auto-expiring).
#
# RED condition (known gap today): helpers.sh carries NO cross-attempt
# undetermined-cycle counter and NO ceiling gate — neither
# __count_undetermined_cycle nor __undetermined_ceiling_check exists, so each
# assertion fails ⇒ the test exits 1 (red). A preliminary grep confirms no
# cross-attempt cycle counter exists in helpers.sh or with-test-home
# (evidence-only; the verdict-bearing fact is the failing assertions below).
#
# Synthetic fixtures: tmp/2456/artifacts/synthetic/sc9-cycle-{1,2,3}
# determination.yaml — same schema as __write_determination_record with
# classification: undetermined. Synthetic only — never real run evidence.
#
# Isolation: the counter state file lives under tmp/ so no production state
# is touched; tmp/.behavior-run.lock is released (rm -f) before the run; GNU
# `timeout` is FORBIDDEN per §5 (this test needs no process kills at all).
#
# Usage:  BEHAVIOR_PHASE=RED bash .opencode/tests-v2/behaviors/2456-sc9-undetermined-ceiling-red.sh
# Launch DETACHED and poll with the bash tool timeout >= 600000 ms.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2456-sc9-undetermined-ceiling-red"
# ── Evidence root ─────────────────────────────────────────────────────────────
ER="$(cd "$SCRIPT_DIR/../../.." && pwd)/tmp/2456/artifacts"
rm -f "$ER"/pipeline-red-9*
mkdir -p "$ER"
EV_ROOT="$ER/${SCENARIO_NAME}"
rm -rf "$EV_ROOT"
mkdir -p "$EV_ROOT"

rm -f tmp/.behavior-run.lock

# ── Synthetic undetermined determination fixtures (never model dispatch) ──────
FIX_ROOT="$ER/synthetic"
rm -rf "$FIX_ROOT"
mkdir -p "$FIX_ROOT"
for n in 1 2 3; do
    mkdir -p "$FIX_ROOT/sc9-cycle-$n"
    cat > "$FIX_ROOT/sc9-cycle-$n/determination.yaml" <<DET.EOF
determination_record:
  schema: determination-record
  schema_version: 1
  scenario_name: ${SCENARIO_NAME}-synthetic
  phase: RED
  attempt: ${n}
  model: synthetic
  exit_code: 0
  run_path: synthetic
  classification: undetermined
  poll_evidence:
    monitor_log: ${FIX_ROOT}/sc9-cycle-${n}/monitor.log
    polls_executed: 0
    classifier_session: ${FIX_ROOT}/sc9-cycle-${n}/classifier-session.yaml
  harness_version: ${BEHAVIOR_HARNESS_VERSION}
  recorded_at: 2026-09-23T00:00:00Z
  false_signal_annotations: []
  orchestrator_decisions: []
DET.EOF
done

PASS=0; FAIL=0

# ═ Assertion 1 — persisted cross-invocation counter under the flock ═══════════
# The counter function must exist in helpers.sh and increment a state file
# that survives process exit (persisted across invocations).
if grep -q '^__count_undetermined_cycle()' "$SCRIPT_DIR/helpers.sh"; then
    echo "  PASS: counter function defined in helpers.sh"; PASS=$((PASS+1))
else
    echo "  FAIL: counter function defined in helpers.sh — no cross-attempt cycle counter exists (RED)" >&2
    FAIL=$((FAIL+1))
fi

if [ "$(type -t __count_undetermined_cycle)" = function ]; then
    __count_undetermined_cycle "$FIX_ROOT/sc9-cycle-1"
    state_after_1="$(cat "$EV_ROOT/undetermined-cycle-count" 2>/dev/null || echo MISSING)"
    __count_undetermined_cycle "$FIX_ROOT/sc9-cycle-2"
    state_after_2="$(cat "$EV_ROOT/undetermined-cycle-count" 2>/dev/null || echo MISSING)"
else
    state_after_1=MISSING; state_after_2=MISSING
    FAIL=$((FAIL+1)); FAIL=$((FAIL+1))
    echo "  FAIL: counting undetermined cycle 1 — __count_undetermined_cycle does not exist (RED)" >&2
    echo "  FAIL: counter increments across invocations — counter path absent (RED)" >&2
fi

# Persistence: the state file must exist ON DISK (survives process exit).
if [ "$state_after_1" != MISSING ] && [ "$state_after_2" != MISSING ] \
   && [ "$state_after_1" != 0 ] && [ "$state_after_2" -gt "$state_after_1" ] 2>/dev/null; then
    echo "  PASS: counter persisted and incremented across invocations ($state_after_1 -> $state_after_2)"; PASS=$((PASS+1))
else
    echo "  FAIL: counter persisted and incremented across invocations — state: $state_after_1 -> $state_after_2 (RED)" >&2
    FAIL=$((FAIL+1))
fi

# ═ Assertion 2 — 3 undetermined cycles produce CEILING_REACHED block ══════════
ceiling_fired=1; block_line=""
if [ "$(type -t __undetermined_ceiling_check)" = function ]; then
    if ! out2="$(__undetermined_ceiling_check "$FIX_ROOT" 2>&1)"; then
        ceiling_fired=0; block_line="$out2"
    else
        ceiling_fired=1
    fi
    # 3rd cycle counted via the counter function before the gate.
    __count_undetermined_cycle "$FIX_ROOT/sc9-cycle-3" 2>/dev/null
    count_at_fire="$(cat "$EV_ROOT/undetermined-cycle-count" 2>/dev/null || echo MISSING)"
    if ! out3="$(__undetermined_ceiling_check "$FIX_ROOT" 2>&1)"; then
        ceiling_fired=0; block_line="$out3"
    fi
fi
if [ "$ceiling_fired" = 0 ] && printf '%s' "$block_line" | grep -q 'CEILING_REACHED'; then
    echo "  PASS: CEILING_REACHED mechanical block produced after 3 undetermined cycles"; PASS=$((PASS+1))
else
    echo "  FAIL: CEILING_REACHED mechanical block after 3 undetermined cycles — no gate exists; third cycle does not block (RED)" >&2
    FAIL=$((FAIL+1))
fi

# ═ Assertion 3 — default ceiling = 3 ═══════════════════════════════════════════
if ! printf '%s' "$block_line" | grep -q 'CEILING_REACHED'; then
    echo "  FAIL: default ceiling is 3 (block fires on 3rd cycle, no override present) — the block itself is absent so the default is unverifiable (RED)" >&2
    FAIL=$((FAIL+1))
else
    if [ "$count_at_fire" != 3 ]; then
        echo "  FAIL: default ceiling is 3 — block fired at count $count_at_fire (expected 3) (RED)" >&2
        FAIL=$((FAIL+1))
    else
        echo "  PASS: default ceiling is 3 — block fired exactly on the 3rd cycle"; PASS=$((PASS+1))
    fi
fi

# ═ Assertion 4 — block persists until developer-level remediation ═════════════
persist_observed=0
if [ "$(type -t __undetermined_ceiling_check)" = function ]; then
    if out4="$(__undetermined_ceiling_check "$FIX_ROOT" 2>&1)"; then
        persist_observed=0   # gate returned success after ceiling reached — no persistence
    else
        if printf '%s' "$out4" | grep -q 'CEILING_REACHED'; then persist_observed=1; fi
    fi
fi
if [ "$persist_observed" = 1 ]; then
    echo "  PASS: block persists across subsequent invocations (no auto-expiry)"; PASS=$((PASS+1))
else
    echo "  FAIL: block persists across subsequent invocations — gate absent, no persistent block state to observe (RED)" >&2
    FAIL=$((FAIL+1))
fi

# ═ Evidence artifact ══════════════════════════════════════════════════════════
if [ "$FAIL" -gt 0 ]; then
    OUT="$ER/pipeline-red-9-${SCENARIO_NAME}.yaml"
    {
        echo "== SC-9 RED evidence (.opencode#2456) =="
        echo "test: ${SCENARIO_NAME}"
        echo "sc_ref: SC-9 (plan-03 Item 9, phase 3, item 9)"
        echo "evidence_type: structural"
        echo "model_dispatch: none (synthetic determination records)"
        echo "synthetic_fixtures: $FIX_ROOT/sc9-cycle-{1,2,3}/determination.yaml (classification: undetermined)"
        echo "counter_state: $state_after_1 -> $state_after_2"
        echo "phase: RED"
        echo "fail_assertions: $FAIL"
        echo "pass_assertions: $PASS"
        echo "verdict: RED (exit 1) — no persisted undetermined-cycle counter and no CEILING_REACHED gate exist in helpers.sh/with-test-home"
        echo "blocker_class: none (red is the expected terminal state; GREEN implementer: items 64/67)"
    } > "$OUT" 2>&1
    echo "RED: $FAIL failing assertion(s) recorded — evidence: $OUT"
    exit 1
fi

exit 0
