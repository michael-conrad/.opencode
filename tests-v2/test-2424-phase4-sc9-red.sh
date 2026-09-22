#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Validator gate check: .opencode#2424 phase 4 item 9 SC-9 (behavioral).
#
# SC-9: The card .opencode/skills/executing-plans/SKILL.md SHALL pass the
# full validator suite with zero violations for skill `executing-plans`.
# Evidence: run `uv run
# .opencode/skills/skill-creator/scripts/validate_skill_cards.py --json`
# from the parent repo root; assert the `executing-plans` skill_name has an
# empty violations list. EVIDENCE_TYPE_MISMATCH coercion applies —
# structural substitutes (file existence, grep of the card) FAIL; only live
# validator JSON execution counts as evidence.
#
# One test file, two data sources (two run modes):
#
#   --fixture <validator-json-path>
#       RED / discrimination proof against the recorded pre-change fixture
#       (tmp/2424/artifacts/pipeline-pre-regression-validator-executing-plans.json,
#       captured pre-change with REQ-2/REQ-3/REQ-5/REQ-6 violations for
#       skill executing-plans):
#       (a) DISCRIMINATION: asserts the fixture's executing-plans violations
#           list is NON-EMPTY and covers REQ-2, REQ-3, REQ-5, REQ-6 — proves
#           the gate detects the pre-change defect state (this assertion
#           PASSES against a valid fixture);
#       (b) RED EVENT: the SC-9 gate assertion ("violations EMPTY") evaluated
#           against the pre-change fixture FAILS — the confirmed-failing
#           enforcement test. Expected on FAIL: exit code 1 (non-zero).
#
#   --live
#       GREEN gate: runs the validator live (uv run
#       .opencode/skills/skill-creator/scripts/validate_skill_cards.py
#       --json, CWD = parent repo root) and asserts the executing-plans
#       violations list is EMPTY. Expected on PASS: exit code 0.
#
#       Note: the validator exits 1 when ANY skill in the deck has
#       violations; deck-wide violations outside `executing-plans` are out
#       of SC-9 scope. The gate decision is the executing-plans subset of
#       the JSON output, never the validator's own exit code.
#
# Environment (live mode, optional):
#   SC9_LIVE_OUT  path for the raw validator JSON (artifact capture)
#   SC9_LIVE_ERR  path for the validator stderr (artifact capture)
#
# Usage:
#   bash .opencode/tests-v2/test-2424-phase4-sc9-red.sh --fixture <json>
#   bash .opencode/tests-v2/test-2424-phase4-sc9-red.sh --live
#
# Exit:
#   --fixture mode: 1 when the gate fails against the pre-change fixture
#                   (expected RED outcome — confirmed-failing test);
#                   0 only if the fixture records no executing-plans
#                   violations (discrimination proof failure — the fixture
#                   does not capture the pre-change state, an unexpected
#                   outcome that invalidates the RED demonstration)
#   --live mode:    0 when the executing-plans violations list is EMPTY;
#                   1 otherwise (or when the validator cannot be executed)

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The validator discovers cards via the `.opencode/skills/*/SKILL.md` glob,
# so it MUST run with CWD at the parent repo root (the submodule mount
# point), not from inside the submodule checkout.
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VALIDATOR=".opencode/skills/skill-creator/scripts/validate_skill_cards.py"
FIXTURE_DEFAULT="$REPO_ROOT/tmp/2424/artifacts/pipeline-pre-regression-validator-executing-plans.json"

MODE="${1:-}"
FIXTURE_PATH=""

case "$MODE" in
  --fixture)
    FIXTURE_PATH="${2:-$FIXTURE_DEFAULT}"
    ;;
  --live)
    ;;
  *)
    echo "Usage: $0 --fixture <validator-json-path> | $0 --live" >&2
    echo "EXIT: 1"
    exit 1
    ;;
esac

if ! command -v python3 >/dev/null 2>&1; then
  echo "FAIL: python3 not found on PATH (required for validator JSON parsing)"
  echo "EXIT: 1"
  exit 1
fi

if [ "$MODE" = "--fixture" ]; then
  echo "=== SC-9 gate check — fixture mode (RED / discrimination proof) ==="
  echo "fixture: $FIXTURE_PATH"
  if [ ! -f "$FIXTURE_PATH" ]; then
    echo "FAIL: fixture not found: $FIXTURE_PATH"
    echo "EXIT: 1"
    exit 1
  fi
  if ! PARSED=$(python3 - "$FIXTURE_PATH" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    data = json.load(f)
violations = data.get("executing_plans_violations", [])
types = sorted({v.get("violation_type", "") for v in violations})
print(f"COUNT={len(violations)}")
print(f"TYPES={','.join(types)}")
for v in violations:
    print(f"VIOLATION {v.get('violation_type')} [{v.get('rule_id')}]: {v.get('message')}")
PY
  ); then
    echo "FAIL: fixture is not valid JSON: $FIXTURE_PATH"
    echo "EXIT: 1"
    exit 1
  fi
  echo "$PARSED"
  COUNT=$(sed -n 's/^COUNT=//p' <<<"$PARSED")
  TYPES=$(sed -n 's/^TYPES=//p' <<<"$PARSED")

  # (a) DISCRIMINATION PROOF: the fixture's executing-plans violations list
  # is NON-EMPTY and covers REQ-2/REQ-3/REQ-5/REQ-6 — the pre-change defect
  # state is recorded and detectable.
  DISC_STATUS=FAIL
  if [ "${COUNT:-0}" -gt 0 ]; then
    MISSING=""
    for REQ in REQ-2 REQ-3 REQ-5 REQ-6; do
      grep -q "$REQ" <<<"$TYPES" || MISSING="$MISSING $REQ"
    done
    if [ -z "$MISSING" ]; then
      DISC_STATUS=PASS
      echo "DISCRIMINATION: PASS — fixture records $COUNT executing-plans violations covering REQ-2/REQ-3/REQ-5/REQ-6 (pre-change defect state detected)"
    else
      echo "DISCRIMINATION: FAIL — fixture missing violation types:$MISSING"
    fi
  else
    echo "DISCRIMINATION: FAIL — fixture records NO executing-plans violations (invalid pre-change fixture)"
  fi

  # (b) RED EVENT: the SC-9 gate assertion ("violations EMPTY") evaluated
  # against the pre-change fixture — the confirmed-failing enforcement test.
  if [ "${COUNT:-0}" -eq 0 ]; then
    echo "GATE SC-9 (violations EMPTY): PASS — UNEXPECTED in fixture mode: the pre-change fixture shows a conforming card; discrimination proof failed"
    echo "EXIT: 0"
    exit 0
  fi
  echo "GATE SC-9 (violations EMPTY): FAIL — $COUNT violations detected for executing-plans in the pre-change fixture"
  echo "RED outcome confirmed: the SC-9 gate assertion fails against the pre-change state (exit 1 = expected confirmed-failing enforcement test)"
  echo "EXIT: 1"
  exit 1
fi

# --- live mode (GREEN gate) ---
echo "=== SC-9 gate check — live mode (GREEN gate) ==="
if ! command -v uv >/dev/null 2>&1; then
  echo "FAIL: uv not found on PATH (required to run the validator)"
  echo "EXIT: 1"
  exit 1
fi
OUT_FILE="${SC9_LIVE_OUT:-$REPO_ROOT/tmp/2424/artifacts/pipeline-sc9-live-validator.json}"
ERR_FILE="${SC9_LIVE_ERR:-$REPO_ROOT/tmp/2424/artifacts/pipeline-sc9-live-validator-stderr.log}"
mkdir -p "$(dirname "$OUT_FILE")" "$(dirname "$ERR_FILE")"
echo "validator: uv run $VALIDATOR --json (CWD=$REPO_ROOT)"
echo "raw JSON artifact: $OUT_FILE"
(cd "$REPO_ROOT" && uv run "$VALIDATOR" --json) >"$OUT_FILE" 2>"$ERR_FILE"
VALIDATOR_EXIT=$?
# The validator exits 1 on deck-wide violations outside executing-plans —
# out of SC-9 scope. Only a missing/invalid JSON output is a hard failure;
# the gate decision is the executing-plans subset of the JSON output.
echo "validator exit code: $VALIDATOR_EXIT (1 = deck-wide violations outside executing-plans, out of SC-9 scope; 0 = deck fully clean)"
if [ ! -s "$OUT_FILE" ]; then
  echo "FAIL: validator produced no JSON output (see $ERR_FILE)"
  echo "EXIT: 1"
  exit 1
fi
if ! PARSED=$(python3 - "$OUT_FILE" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    violations = json.load(f)
ep = [v for v in violations if v.get("skill_name") == "executing-plans"]
print(f"TOTAL={len(violations)}")
print(f"EP_COUNT={len(ep)}")
for v in ep:
    print(f"VIOLATION {v.get('violation_type')} [{v.get('rule_id')}]: {v.get('message')}")
PY
); then
  echo "FAIL: validator output is not valid JSON (see $OUT_FILE)"
  echo "EXIT: 1"
  exit 1
fi
echo "$PARSED"
TOTAL=$(sed -n 's/^TOTAL=//p' <<<"$PARSED")
EP_COUNT=$(sed -n 's/^EP_COUNT=//p' <<<"$PARSED")
echo "deck total violations (all skills): ${TOTAL:-unknown}"
echo "executing-plans violations: ${EP_COUNT:-unknown}"
if [ "${EP_COUNT:--1}" -eq 0 ]; then
  echo "GATE SC-9 (violations EMPTY): PASS — executing-plans violations list is EMPTY"
  echo "EXIT: 0"
  exit 0
fi
echo "GATE SC-9 (violations EMPTY): FAIL — executing-plans has ${EP_COUNT:-unknown} violations"
echo "EXIT: 1"
exit 1

# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
