#!/bin/bash
# Content-Verification Enforcement Test: SC-3 — No-Outguess Mandate Documentation
#
# Issue: .opencode#2248 — Enforce no-outguess of harness model/GPU selection.
# Phase: red-phase1-2248 — SC-3 (string),
#        `.opencode/tests-v2/AGENTS.md` (no-outguess mandate documentation).
#
# SC-3 (string): `.opencode/tests-v2/AGENTS.md` SHALL document that the agent MUST NOT
#   outguess model/GPU selection during behavioral testing — the harness/ollama handles
#   model/GPU selection; `DEFAULT_TEST_MODEL` (from `default-model.sh`) is the single
#   source of truth; on failure/timeout the agent follows the §10 remediation path, not
#   VRAM/GPU outguessing.
#
# RED state: AGENTS.md currently does NOT document the no-outguess mandate. It has:
#   - The §10.4 fabricated-model-excuse prohibition (covers claims of unavailability).
#   - Mandate #5 default-model-not-changed (prevents editing `default-model.sh`).
#   But it does NOT state the agent MUST NOT outguess model/GPU selection (no VRAM
#   probing via `ollama-probe hw`, no hand-picked model override). Assertions (a)-(c)
#   below FAIL. GREEN adds the no-outguess mandate text to AGENTS.md.
#
# Evidence type: SC-3 is a `string` SC. This content-verification test greps AGENTS.md
#   for the required mandate strings. It is the primary gate for this documentation-only
#   SC (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2248-sc3-no-outguess-doc.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED on SC-3).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

AGENTS_MD="$PROJECT_DIR/.opencode/tests-v2/AGENTS.md"

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    local label="$1"
    echo "  PASS: $label"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    local label="$1"
    local detail="$2"
    echo "  FAIL: $label — $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

# grep_assert_present: pattern must appear at least once in the file.
grep_assert_present() {
    local label="$1"
    local file="$2"
    local pattern="$3"
    if grep -qF "$pattern" "$file" 2>/dev/null; then
        check_pass "$label"
    else
        check_fail "$label" "pattern '$pattern' not found in $file"
    fi
}

echo ""
echo "=== SC-3 — No-Outguess Mandate Documentation (Spec .opencode#2248) ==="
echo ""
echo "Target file: $AGENTS_MD"
echo ""

# ---------------------------------------------------------------------------
# SC-3 (string): AGENTS.md documents the agent MUST NOT outguess model/GPU selection.
#
# (a) The agent MUST NOT outguess model/GPU selection during behavioral testing —
#     the harness/ollama handles model/GPU selection. AGENTS.md must state this and
#     must forbid VRAM probing (`ollama-probe hw`) and hand-picked model overrides.
#     RED-now: "outguess" does not appear anywhere in AGENTS.md.
# ---------------------------------------------------------------------------
echo "--- SC-3 (a): agent MUST NOT outguess model/GPU selection ---"

# SC-3: the mandate uses the no-outguess language (currently MISSING → RED).
grep_assert_present \
    "SC-3: mandate states the agent MUST NOT outguess model/GPU selection" \
    "$AGENTS_MD" \
    "outguess"

# SC-3: the mandate attributes model/GPU selection to the harness/ollama — the agent
# does not handle it. A line must state the harness/ollama handles model/GPU selection
# as the agent's NOT-to-outguess concern (currently MISSING → RED). The discriminator
# is the no-outguess context, not a pre-existing "verified to work with the harness"
# line about the default model.
if grep -qE '.*outguess.*(harness|ollama).*' "$AGENTS_MD" 2>/dev/null; then
    check_pass "SC-3: mandate attributes model/GPU selection to the harness/ollama"
else
    check_fail "SC-3: mandate attributes model/GPU selection to the harness/ollama" \
        "no line ties model/GPU selection to the harness/ollama within the no-outguess mandate"
fi

# SC-3: VRAM probing via `ollama-probe hw` to justify a model override is forbidden
# (currently MISSING → RED).
grep_assert_present \
    "SC-3: mandate forbids VRAM probing (ollama-probe hw) to justify an override" \
    "$AGENTS_MD" \
    "ollama-probe"

# ---------------------------------------------------------------------------
# SC-3 (b): `DEFAULT_TEST_MODEL` (from `default-model.sh`) is the single source of
#     truth for model selection during behavioral testing. AGENTS.md must state this
#     and name `DEFAULT_TEST_MODEL` as the only model the agent uses.
#     RED-now: AGENTS.md references `DEFAULT_TEST_MODEL` only as the default model for
#     runs (§4/§9), but does NOT state it is the SINGLE source of truth the agent MUST
#     use without substitution.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC-3 (b): DEFAULT_TEST_MODEL is the single source of truth ---"

# SC-3: the mandate names DEFAULT_TEST_MODEL as the model used (present in §4/§9, but
# the mandate must also state it is the single source of truth — GREEN ties this).
grep_assert_present \
    "SC-3: mandate names DEFAULT_TEST_MODEL" \
    "$AGENTS_MD" \
    "DEFAULT_TEST_MODEL"

# SC-3: the mandate declares DEFAULT_TEST_MODEL the single source of truth the agent
# MUST use (without substitution). The discriminator is the agent-substitution context
# in the no-outguess mandate. This must NOT be satisfied by Mandate #5's unrelated
# "DEFAULT_TEST_MODEL in default-model.sh is the single source of truth" line, which
# only says do-not-edit default-model.sh — it says nothing about the agent's runtime
# model selection during behavioral testing (currently MISSING → RED).
if grep -qE 'DEFAULT_TEST_MODEL[^\n]*outguess[^\n]*|outguess[^\n]*DEFAULT_TEST_MODEL[^\n]*' "$AGENTS_MD" 2>/dev/null; then
    check_pass "SC-3: DEFAULT_TEST_MODEL is the single source of truth the agent MUST use"
else
    check_fail "SC-3: DEFAULT_TEST_MODEL is the single source of truth the agent MUST use" \
        "no line ties DEFAULT_TEST_MODEL to the no-outguess mandate as the sole model the agent uses"
fi

# ---------------------------------------------------------------------------
# SC-3 (c): on failure/timeout the agent follows the §10 remediation path, not
#     model-switching. AGENTS.md must direct the agent to the §10 remediation path
#     (stale lock, bash-tool timeout, §10.5 post-timeout recovery, §10.4 model-excuse
#     prohibition) instead of diagnosing "model too big"/"VRAM insufficient" and
#     switching models. RED-now: §10 documents remediation but does NOT forbid
#     model-switching as an alternative.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC-3 (c): failure/timeout follows §10 remediation, not model-switching ---"

# SC-3: the mandate directs failure/timeout handling to the §10 remediation path.
grep_assert_present \
    "SC-3: mandate references the §10 remediation path for failure/timeout" \
    "$AGENTS_MD" \
    "§10"

# SC-3: the mandate explicitly forbids switching models on failure/timeout (currently
# MISSING → RED). The word "switch" must appear in the no-outguess/remediation context.
if grep -qiE 'switch(model|ing|.*model)|model switch|do not switch' "$AGENTS_MD" 2>/dev/null; then
    check_pass "SC-3: mandate forbids switching models on failure/timeout"
else
    check_fail "SC-3: mandate forbids switching models on failure/timeout" \
        "no line forbids model-switching on test failure/timeout"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-3 (no-outguess mandate documentation) not yet implemented."
    echo "AGENTS.md documents the §10.4 fabricated-model-excuse prohibition and Mandate #5"
    echo "default-model-not-changed, but does NOT document that the agent MUST NOT outguess"
    echo "model/GPU selection (no VRAM probing / no hand-picked model override), that"
    echo "DEFAULT_TEST_MODEL is the single source of truth the agent MUST use, or that"
    echo "failure/timeout follows the §10 remediation path rather than model-switching."
    echo "GREEN adds the no-outguess mandate text to AGENTS.md."
    echo ""
    exit 1
fi
echo "SC-3 is GREEN — AGENTS.md documents the no-outguess mandate."
echo ""
exit 0
