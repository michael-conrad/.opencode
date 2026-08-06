#!/bin/bash
# Content-Verification Enforcement Test: Phase 8 — AGENTS.md Documentation (Concern C9)
#
# Issue: .opencode#2244 — full-environment simulation in the tests-v2 harness.
# Phase: red-phase8-docs — Concern C9,
#        `.opencode/tests-v2/AGENTS.md` (mutual-exclusion rule + full-env opt-in docs).
#
# SCs covered: SC18.
#
# SC18 (string): `.opencode/tests-v2/AGENTS.md` SHALL document the
#   `BEHAVIOR_NEEDS_MULTI_SUBMODULES` / `BEHAVIOR_SET_BARE_REMOTE` mutual-exclusion
#   rule and the new full-environment opt-in capability (multi-submodule fixtures and
#   GitBucket origin wiring).
#
# RED state: AGENTS.md currently documents the GitBucket opt-in (`BEHAVIOR_NEEDS_REMOTE`)
#   in §12 (Self-Contained GitBucket Container for Remote API Tests) but does NOT document:
#     - The mutual-exclusion rule (`BEHAVIOR_NEEDS_REMOTE` + `BEHAVIOR_SET_BARE_REMOTE`
#       mutually exclusive → `HARNESS_FAILURE` rejection).
#     - The `BEHAVIOR_NEEDS_MULTI_SUBMODULES` flag / multi-submodule fixture opt-in
#       (test-submodule-1/test-submodule-2 provisioning) or its wiring to the GitBucket
#       origin under the full-env opt-in.
#   Assertions (a)-(b) below FAIL. GREEN adds a section to AGENTS.md documenting both.
#
# Evidence type: SC18 is a `string` SC. This content-verification test greps AGENTS.md for
#   the required documentation strings. It is the primary gate for this documentation-only
#   SC (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2244-phase8-agents-docs.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED on SC18).

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
echo "=== Phase 8 — AGENTS.md Documentation (Spec #2244, Concern C9) ==="
echo ""
echo "Target file: $AGENTS_MD"
echo ""

# ---------------------------------------------------------------------------
# SC18 (string): AGENTS.md documents the mutual-exclusion rule and the full-env opt-in.
#
# (a) The mutual-exclusion rule: a test MUST NOT set both BEHAVIOR_NEEDS_REMOTE and
#     BEHAVIOR_SET_BARE_REMOTE (both try to configure the origin remote and would
#     conflict; contradictory config is rejected with HARNESS_FAILURE). AGENTS.md must
#     name BOTH flags and the rejection. RED-now: BEHAVIOR_SET_BARE_REMOTE does not
#     appear anywhere in AGENTS.md.
# ---------------------------------------------------------------------------
echo "--- SC18 (a): mutual-exclusion rule (BEHAVIOR_NEEDS_REMOTE / BEHAVIOR_SET_BARE_REMOTE) ---"

# SC18: mutual-exclusion rule names the GitBucket remote-opt-in flag.
grep_assert_present \
    "SC18: mutual-exclusion rule names BEHAVIOR_NEEDS_REMOTE" \
    "$AGENTS_MD" \
    "BEHAVIOR_NEEDS_REMOTE"

# SC18: mutual-exclusion rule names the bare-remote flag (currently MISSING → RED).
grep_assert_present \
    "SC18: mutual-exclusion rule names BEHAVIOR_SET_BARE_REMOTE" \
    "$AGENTS_MD" \
    "BEHAVIOR_SET_BARE_REMOTE"

# SC18: mutual-exclusion rule states the two flags are mutually exclusive (currently
# MISSING → RED). A line must reference both flags in one mutual-exclusion statement.
if grep -qE '.*BEHAVIOR_NEEDS_REMOTE.*BEHAVIOR_SET_BARE_REMOTE.*|.*BEHAVIOR_SET_BARE_REMOTE.*BEHAVIOR_NEEDS_REMOTE.*' "$AGENTS_MD" 2>/dev/null; then
    check_pass "SC18: mutual-exclusion rule references BOTH flags in one statement"
else
    check_fail "SC18: mutual-exclusion rule references BOTH flags in one statement" \
        "no line combines BEHAVIOR_NEEDS_REMOTE and BEHAVIOR_SET_BARE_REMOTE in a mutual-exclusion statement"
fi

# ---------------------------------------------------------------------------
# SC18 (b): full-env opt-in capability — multi-submodule fixtures and GitBucket origin wiring.
#     AGENTS.md must document the BEHAVIOR_NEEDS_MULTI_SUBMODULES flag and the
#     test-submodule-1/test-submodule-2 fixtures it provisions. RED-now: none of these
#     appear anywhere in AGENTS.md.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC18 (b): full-env opt-in capability (BEHAVIOR_NEEDS_MULTI_SUBMODULES + fixtures) ---"

# SC18: the multi-submodule opt-in flag is documented (currently MISSING → RED).
grep_assert_present \
    "SC18: full-env opt-in names BEHAVIOR_NEEDS_MULTI_SUBMODULES" \
    "$AGENTS_MD" \
    "BEHAVIOR_NEEDS_MULTI_SUBMODULES"

# SC18: the multi-submodule fixtures (test-submodule-1/test-submodule-2) are documented
# (currently MISSING → RED).
grep_assert_present \
    "SC18: multi-submodule fixtures (test-submodule-1) documented" \
    "$AGENTS_MD" \
    "test-submodule-1"

grep_assert_present \
    "SC18: multi-submodule fixtures (test-submodule-2) documented" \
    "$AGENTS_MD" \
    "test-submodule-2"

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 8 (AGENTS.md documentation) not yet implemented."
    echo "AGENTS.md documents the GitBucket opt-in (BEHAVIOR_NEEDS_REMOTE) in §12 but does"
    echo "not document the BEHAVIOR_NEEDS_REMOTE / BEHAVIOR_SET_BARE_REMOTE mutual-exclusion"
    echo "rule or the BEHAVIOR_NEEDS_MULTI_SUBMODULES full-env opt-in (multi-submodule"
    echo "fixtures + GitBucket origin wiring). GREEN adds a section documenting both."
    echo ""
    exit 1
fi
echo "SC18 documentation is GREEN — AGENTS.md documents the mutual-exclusion rule and the"
echo "full-env opt-in capability."
echo ""
exit 0
