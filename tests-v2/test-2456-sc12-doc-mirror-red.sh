#!/usr/bin/env bash
# .opencode#2456 Phase 5 / item 12 / SC-12 (structural) — RED phase.
# Structural content check (advisory markdown checks; NO model dispatch):
# asserts .opencode/tests-v2/AGENTS.md §10.7 / §14 / R-18 / §17 mirror the
# exact implemented predicates — for each implemented predicate identifier,
# asserts the corresponding identifier appears in the relevant section
# (§14 for monitor semantics, §10.7 for the resume gate, R-18/§17 for
# cause-analysis). RED condition: 0 of the identifiers are present ->
# check FAILS (exit 1).
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$SCRIPT_DIR/AGENTS.md"

[ -f "$TARGET" ] || { echo "FATAL: target file not found: $TARGET" >&2; exit 1; }

pass=0
total=0
missing=()

# Extract a markdown section from (the line matching the ERE heading anchor)
# through the next heading of level <= start heading level, exclusive.
section() {
    local saj="$1" sa
    sa="$(printf '%s' "$saj" | sed -e 's/[][\/$*.^|+(){}\\]/\\&/g')"
    sed -n -E "/^#{1,3} ${sa}/,/^#{1,3} /p" "$TARGET" | sed '$d'
}

report() { # report <section_name> <identifier> <found 0|1>
    local sec="$1" id="$2" found="$3"
    total=$((total+1))
    if [ "$found" -eq 1 ]; then
        pass=$((pass+1))
        echo "PASS [${sec}]: ${id}"
    else
        missing+=("(${sec}) ${id}")
        echo "FAIL [${sec}]: ${id} ABSENT"
    fi
}

chk() { # chk <section_name> <section_text> <identifier>
    local sec="$1" text="$2" id="$3"
    local found=0
    if printf '%s' "$text" | grep -qF -- "$id"; then found=1; fi
    report "$sec" "$id" "$found"
}

# --- §14: monitor semantics -------------------------------------------------
s14="$(section '## 14\.')"
chk s14 "$s14" 'monitor.log'
chk s14 "$s14" 'classifier'
chk s14 "$s14" 'verifiable goal condition'
chk s14 "$s14" 'determination.yaml'
chk s14 "$s14" 'notify_offtrack'
chk s14 "$s14" 'halt-class'
chk s14 "$s14" 'halt+notify'

# --- §10.7: the resume gate --------------------------------------------------
s107="$(section '### 10.7 ')"
chk s107 "$s107" '__record_orchestrator_decision'
chk s107 "$s107" '__sc8_determination_gate'
chk s107 "$s107" 'CEILING_REACHED'

# --- R-18 / §17: cause-analysis ----------------------------------------------
s17="$(section '## 17\.')"
# R-18 anchor: the R-18 citation block around line 406 (R-18 remit text) plus §17.
s18="$(grep -B3 -A6 'R-18' "$TARGET" | head -100)"
chk s17 "$s17" '__fold_false_signal'
chk s17 "$s17" 'dispatch-failure'
chk s17 "$s17" 'efficiency-defect'
chk s17 "$s18" 'efficiency-defect'

echo ""
echo "identifier-present: ${pass}/${total}"

if [ "$pass" -eq 0 ]; then
    echo "RED condition met: 0 of ${total} implemented predicate identifiers appear in AGENTS.md §10.7/§14/R-18/§17"
    exit 1
fi

if [ "${#missing[@]}" -gt 0 ]; then
    echo "MIRROR INCOMPLETE: ${#missing[@]} identifier(s) missing from their designated section(s)"
    for m in "${missing[@]}"; do echo "  ABSENT: $m"; done
    exit 1
fi

echo "FULL MIRROR: all ${total} implemented predicate identifiers present in their designated section(s)"
exit 0
