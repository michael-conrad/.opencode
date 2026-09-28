#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# .opencode#2456 plan-06 phase-6 item SC-18 (structural) — RED phase.
# Structural content check (advisory markdown check; NO model dispatch):
# asserts that .opencode/tests-v2/AGENTS.md §14 mirrors the supervisor
# polling mandate (SC-17's predicate: consecutive supervision gaps ≤300s,
# every gap closed by a per-poll FULL SEMANTIC CHECK of the run's session
# export, run-retry invocations separated by an intervening semantic check)
# as agent-facing instruction-surface text — so the discipline is default
# behavior for every sub-agent reading the deck, independent of orchestrator
# prompt phrasing.
#
# BASELINE (recorded honestly): §14 exists and mandates the harness monitor's
# 30-60s polling, but does NOT carry the agent-supervisor mandate — no ≤300s
# (5-minute) cadence bound, no per-poll full-semantic-check requirement for
# agent-supervised runs, no no-check retry-loop prohibition.
#
# RED condition: check FAILS (exit 1) — the §14 supervisor-mandate mirror
# text is absent today. GREEN adds the §14 text; re-run then exits 0.
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$SCRIPT_DIR/AGENTS.md"

[ -f "$TARGET" ] || { echo "FATAL: target file not found: $TARGET" >&2; exit 1; }

pass=0
total=0
missing=()

# Extract §14 (heading matching the bare section number '14') through the
# next heading of level <= start level, exclusive. Fence-aware; the [^0-9]
# guard prevents '14' matching '140' or '10.7x'.
section() {
    awk '
        /^```/ {
            infence = !infence
            if (started) print
            next
        }
        infence {
            if (started) print
            next
        }
        /^#{1,3} / {
            n = $0; sub(/ .*/, "", n); lvl = length(n)
            rest = $0; sub(/^#* /, "", rest)
            if (!started) {
                if (rest ~ /^14[^0-9]/) { started = 1; startlvl = lvl; print }
                next
            }
            if (lvl <= startlvl) exit
            print
            next
        }
        { if (started) print }
    ' "$TARGET"
}

report() { # report <requirement> <found 0|1>
    total=$((total+1))
    if [ "$2" -eq 1 ]; then
        pass=$((pass+1))
        echo "PASS [s14]: $1"
    else
        missing+=("$1")
        echo "FAIL [s14]: $1 ABSENT"
    fi
}

s14="$(section '14')"

# --- SC-18 mirror assertions (agent-facing supervisor mandate in §14) --------
# chk: grep exit 0 = identifier FOUND in §14.
chk() { # chk <requirement> <grep-args...>
    local req="$1"; shift
    if grep -q "$@" <<<"$s14"; then
        report "$req" 1
    else
        report "$req" 0
    fi
}

chk "names the supervisor mandate" -iE 'supervis'
chk "names the ≤300s (5-minute) cadence bound" -E '300 ?s|300 seconds|≤ ?300|5 minutes|five minutes'
chk "scopes the mandate to agent-supervised runs" -iE 'agent-supervised|agent supervis'
chk "requires a per-poll full semantic check" -iE 'full semantic check|semantic check'
chk "prohibits no-check retry loops" -iE 'no-check retry|retry loop|without a semantic check'

echo ""
echo "mirror-present: ${pass}/${total}"

if [ "$pass" -eq 0 ]; then
    echo "RED condition met: §14 carries NO part of the supervisor polling mandate (SC-17 predicate unmirrored)"
    exit 1
fi

if [ "${#missing[@]}" -gt 0 ]; then
    echo "MIRROR INCOMPLETE: ${#missing[@]} supervisor-mandate element(s) missing from §14"
    for m in "${missing[@]}"; do echo "  ABSENT: $m"; done
    exit 1
fi

echo "FULL MIRROR: §14 carries the supervisor mandate (≤300s cadence + per-poll full semantic check + no-check retry prohibition for agent-supervised runs)"
exit 0

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)