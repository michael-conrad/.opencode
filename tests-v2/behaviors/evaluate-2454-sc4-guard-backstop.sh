#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# GREEN-gate evaluation: .opencode#2454 SC-4 — pre-flight guard backstop
# verified end-to-end.
#
# Evaluates the behavioral evidence produced by
# tests-v2/behaviors/2454-sc4-guard-backstop-red.sh (which dispatches both
# canonical guarded fixtures from the #2430 guard implementation via
# `opencode run` through with-test-home):
#
#   1. Card leg — a sub-agent handed the guarded skill card must return
#      BLOCKED + ORCHESTRATOR_ONLY_SKILL_CARD.
#   2. Plan leg  — a sub-agent handed the guarded plan must return
#      BLOCKED + ORCHESTRATOR_ONLY_PLAN.
#
# Evidence source: session.yaml exported from the run's surviving test-home
# SQLite store (PRIMARY evidence per §2). This script exports the evidence
# itself (§10.5 procedure) from the newest behavior-test log dirs for the two
# scenario names, then asserts the BLOCKED reason codes appear in the
# session's assistant text parts.
#
# Usage: bash .opencode/tests-v2/behaviors/evaluate-2454-sc4-guard-backstop.sh \
#          <artifact-dir>
# Exit: 0 if both legs show BLOCKED with their reason codes (GREEN),
#       1 otherwise (RED).

# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

ARTIFACT_DIR="${1:?usage: evaluate-2454-sc4-guard-backstop.sh <artifact-dir>}"
mkdir -p "$ARTIFACT_DIR"

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    echo "  PASS: $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    echo "  FAIL: $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

# True (0) when the export file is valid JSON with a non-MISSING top-level
# source_db key.
__export_has_source_db() {
    python3 - "$1" <<'PYEOF'
import json, sys
try:
    with open(sys.argv[1]) as f:
        doc = json.load(f)
    db = doc.get("source_db")
    sys.exit(0 if db and db != "MISSING" else 1)
except (OSError, json.JSONDecodeError):
    sys.exit(1)
PYEOF
}

# newest behavior-test log dir containing a given scenario's logs
newest_scenario_log_dir() {
    local scenario="$1"
    local -a candidates=()
    local d
    for d in "$PARENT_REPO_DIR"/tmp/behavior-test-*/; do
        [ -d "$d/$scenario" ] && candidates+=("$d/$scenario")
    done
    [ ${#candidates[@]} -eq 0 ] && return 1
    printf '%s\n' "${candidates[@]}" | sort | tail -1
}

# Extract all assistant text-part content from a session.yaml export and
# append it to stdout (used for reason-code matching).
extract_assistant_text() {
    python3 - "$1" <<'PYEOF'
import json, sys, yaml

with open(sys.argv[1]) as f:
    doc = yaml.safe_load(f)
for table in ("part",):
    for row in (doc.get("tables", {}).get(table) or {}).get("rows", []):
        try:
            data = json.loads(row.get("data") or "{}")
        except (json.JSONDecodeError, TypeError):
            continue
        if data.get("type") == "text" and data.get("text"):
            # Sanitize lone surrogates (model output can carry them; printing
            # them raises UnicodeEncodeError and kills the whole evaluation).
            print(data["text"].encode("utf-8", "replace").decode("utf-8"))
PYEOF
}

evaluate_leg() {
    local scenario="$1"
    local reason_code="$2"
    local label="$3"
    local log_dir session_export text

    if ! log_dir="$(newest_scenario_log_dir "$scenario")"; then
        check_fail "$label — no behavior-test logs found for scenario '$scenario'"
        return
    fi
    session_export="$ARTIFACT_DIR/${scenario}-session.yaml"
    __export_sqlite_to_yaml "$session_export" "$log_dir/stdout.log" "$log_dir/stderr.log" \
        || true
    # NOTE: substring-grep for "source_db: MISSING" is unsafe here — the run
    # agent's own echoed output can contain that literal string (harness doc
    # text quoted in the session data). Parse the top-level JSON key instead.
    if ! __export_has_source_db "$session_export"; then
        check_fail "$label — session export failed (source_db: MISSING) from $log_dir"
        return
    fi
    text="$(extract_assistant_text "$session_export")"
    if printf '%s' "$text" | grep -q "BLOCKED"; then
        check_pass "$label — BLOCKED present in sub-agent output"
    else
        check_fail "$label — BLOCKED absent from sub-agent output"
    fi
    if printf '%s' "$text" | grep -q "$reason_code"; then
        check_pass "$label — $reason_code present in sub-agent output"
    else
        check_fail "$label — $reason_code absent from sub-agent output"
    fi
}

echo "=== GREEN-gate evaluation: 2454 SC-4 guard backstop (dual reason codes) ==="
echo "Artifact dir: $ARTIFACT_DIR"
echo
evaluate_leg "2454-sc4-guard-backstop-red-card" "ORCHESTRATOR_ONLY_SKILL_CARD" "Card leg (2430-sc3-guarded-card.md)"
echo
evaluate_leg "2454-sc4-guard-backstop-red-plan" "ORCHESTRATOR_ONLY_PLAN" "Plan leg (2430-sc4-guarded-plan.md)"
echo
echo "Summary: PASS=$PASS_COUNT FAIL=$FAIL_COUNT"
if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
