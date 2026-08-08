#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral Enforcement Test: 2258-sc1-clean-submodule-sha
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Issue: .opencode#2258 — Pre-commit hook Gate 2 false-positives on clean submodules.
# SC-1: The pre-commit hook's Gate 2 SHALL correctly extract the full 40-char SHA for a
#       CLEAN submodule (not strip the leading hex char), so that a commit with all-clean
#       submodule pointers is not falsely blocked by the stale-pointer check.
#
# This is a RED-phase test. The GREEN implementation has NOT been applied yet, so the
# assertions below are expected to FAIL (non-zero exit). The GREEN phase will replace
# line 49 of `.opencode/hooks/pre-commit` with the explicit awk first-char test form:
#   STAGED_SHA=$(git submodule status "$sp" 2>/dev/null | awk '{s=$1; if (s ~ /^[+U-]/) s=substr(s,2); print s}' || true)
#
# Evidence type: SC-1 is behavioral — it executes the Gate 2 fallback SHA extraction
# against a real clean submodule and asserts it yields the full 40-char SHA equal to the
# true gitlink SHA from `git ls-tree HEAD`. It also asserts the naive `awk '{print
# substr($1,2)}'` and `sed 's/^[+-U]//'` both produce the 39-char truncated value that
# the fix eliminates.
#
# RED state: Line 49 currently uses the buggy `awk '{print substr($1,2)}'`, which strips
# the leading hex char of a clean submodule's status line, producing a 39-char SHA that
# never equals the 40-char remote tip → false BLOCK on every commit. The assertions below
# are RED because the current extraction does NOT yield the full 40-char SHA.
#
# Usage: bash .opencode/tests-v2/test-2258-sc1-clean-submodule-sha.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

HOOK_FILE="$PROJECT_DIR/.opencode/hooks/pre-commit"

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

echo ""
echo "=== SC-1: Gate 2 fallback SHA extraction yields full 40-char SHA for a clean submodule ==="
echo ""
echo "Target file: $HOOK_FILE"
echo ""

# ---------------------------------------------------------------------------
# SC-1 (behavioral): Execute the Gate 2 fallback SHA extraction against a real
# clean submodule and assert it yields the full 40-char SHA equal to the true
# gitlink SHA from `git ls-tree HEAD`. Assert the naive `awk '{print substr($1,2)}'`
# and `sed 's/^[+-U]//'` both produce the 39-char truncated value that the fix
# eliminates.
#
# RED-now: line 49 uses the buggy `awk '{print substr($1,2)}'`, which strips the
# leading hex char of a clean submodule's status line. GREEN replaces it with the
# explicit awk first-char test form.
# ---------------------------------------------------------------------------

# (a) The hook's Gate 2 fallback extraction (line 49) MUST NOT use the buggy
#     `awk '{print substr($1,2)}'` form, which strips the leading hex char.
if grep -qF "awk '{print substr(\$1,2)}'" "$HOOK_FILE" 2>/dev/null; then
    check_fail "SC-1: line 49 does NOT use the buggy awk substr form" \
        "found 'awk {print substr(\$1,2)}' in $HOOK_FILE"
else
    check_pass "SC-1: line 49 does NOT use the buggy awk substr form"
fi

# (b) The hook's Gate 2 fallback extraction MUST use the explicit awk first-char
#     test form, which strips only a status prefix (+/-/U) when present and never
#     strips a hex character.
if grep -qF "s=\$1; if (s ~ /^[+U-]/) s=substr(s,2); print s" "$HOOK_FILE" 2>/dev/null; then
    check_pass "SC-1: line 49 uses the explicit awk first-char test form"
else
    check_fail "SC-1: line 49 uses the explicit awk first-char test form" \
        "explicit awk first-char test form not found in $HOOK_FILE"
fi

# (c) The hook MUST NOT use the naive `sed 's/^[+-U]//'` form, which is
#     locale-dependent (range vs. set on GNU sed 4.9) and strips lowercase hex
#     chars including 'f' — producing the SAME 39-char false-positive.
if grep -qF "sed 's/^[+-U]//'" "$HOOK_FILE" 2>/dev/null; then
    check_fail "SC-1: line 49 does NOT use the naive sed range form" \
        "found 'sed s/^[+-U]//' in $HOOK_FILE"
else
    check_pass "SC-1: line 49 does NOT use the naive sed range form"
fi

# (d) Functional execution: run the Gate 2 fallback extraction against a real
#     clean submodule and assert it yields the full 40-char SHA equal to the true
#     gitlink SHA from `git ls-tree HEAD`.
#
#     Set up a temporary repo with a clean submodule (the .opencode submodule of
#     the parent repo), then run the extraction form currently in the hook and
#     compare against the true gitlink SHA.
TMP_REPO="$(mktemp -d "$PROJECT_DIR/tmp/2258-red-XXXXXX")"
CLEANUP_DIRS+=("$TMP_REPO")
git init -q "$TMP_REPO"
git -C "$TMP_REPO" config user.email "test@test.dev"
git -C "$TMP_REPO" config user.name "Test"

# Add the .opencode submodule at its current committed SHA (clean state).
SUBMODULE_URL="$(git -C "$PROJECT_DIR" config --get submodule..opencode.url 2>/dev/null || echo "https://github.com/michael-conrad/.opencode.git")"
SUBMODULE_SHA="$(git -C "$PROJECT_DIR" ls-tree HEAD .opencode | awk '{print $3}')"
git -C "$TMP_REPO" submodule add -q "$SUBMODULE_URL" .opencode 2>/dev/null || true
git -C "$TMP_REPO" -c protocol.file.allow=always submodule update --init .opencode 2>/dev/null || true
git -C "$TMP_REPO" checkout -q "$SUBMODULE_SHA" -- .opencode 2>/dev/null || true
git -C "$TMP_REPO" add -A 2>/dev/null || true
git -C "$TMP_REPO" commit -qm "init with clean submodule" 2>/dev/null || true

# Verify the submodule is CLEAN (space-prefixed status line, not +/U/-).
CLEAN_STATUS="$(git -C "$TMP_REPO" submodule status .opencode 2>/dev/null || true)"
if [[ "$CLEAN_STATUS" =~ ^[[:space:]] ]]; then
    check_pass "SC-1: test submodule is clean (space-prefixed status line)"
else
    check_fail "SC-1: test submodule is clean (space-prefixed status line)" \
        "submodule status is not clean: '$CLEAN_STATUS'"
fi

TRUE_GITLINK_SHA="$(git -C "$TMP_REPO" ls-tree HEAD .opencode | awk '{print $3}')"

# Run the extraction form currently in the hook (line 49) against the clean submodule.
# Extract the actual command from the hook to test the real behavior.
CURRENT_EXTRACTION="$(grep -E 'STAGED_SHA=\$\(git submodule status' "$HOOK_FILE" | head -1 || true)"
if [ -z "$CURRENT_EXTRACTION" ]; then
    check_fail "SC-1: hook contains a Gate 2 fallback extraction command" \
        "no 'STAGED_SHA=\$(git submodule status' line found in $HOOK_FILE"
else
    check_pass "SC-1: hook contains a Gate 2 fallback extraction command"
    # Run the hook's actual Gate 2 fallback extraction logic against the clean
    # submodule. Extract the awk program from the hook's line 49 (the fallback
    # path, which contains 'submodule status') and apply it to the clean
    # submodule's status line, mirroring the hook's real behavior.
    # The hook's command is: git submodule status "$sp" | awk '<program>'
    AWK_PROGRAM="$(grep -E 'STAGED_SHA=\$\(git submodule status' "$HOOK_FILE" | head -1 | grep -oE "awk '\{.*\}'" | sed "s/^awk '//; s/'$//" || true)"
    if [ -z "$AWK_PROGRAM" ]; then
        check_fail "SC-1: hook contains an awk extraction program" \
            "no awk program found in $HOOK_FILE"
    else
        check_pass "SC-1: hook contains an awk extraction program"
        EXTRACTED_SHA="$(git -C "$TMP_REPO" submodule status .opencode 2>/dev/null | awk "$AWK_PROGRAM" || true)"
        if [ "$EXTRACTED_SHA" = "$TRUE_GITLINK_SHA" ]; then
            check_pass "SC-1: Gate 2 fallback extraction yields the full 40-char SHA for a clean submodule"
        else
            check_fail "SC-1: Gate 2 fallback extraction yields the full 40-char SHA for a clean submodule" \
                "extracted '$EXTRACTED_SHA' (${#EXTRACTED_SHA} chars) != true gitlink '$TRUE_GITLINK_SHA' (${#TRUE_GITLINK_SHA} chars)"
        fi
    fi
fi

# (e) Assert the naive `awk '{print substr($1,2)}'` produces the 39-char truncated
#     value that the fix eliminates (demonstrates the bug the fix removes).
NAIVE_AWK_SHA="$(git -C "$TMP_REPO" submodule status .opencode 2>/dev/null | awk '{print substr($1,2)}' || true)"
if [ "${#NAIVE_AWK_SHA}" -eq 39 ]; then
    check_pass "SC-1: naive awk substr form produces the 39-char truncated value (bug confirmed)"
else
    check_fail "SC-1: naive awk substr form produces the 39-char truncated value (bug confirmed)" \
        "naive awk produced '${NAIVE_AWK_SHA}' (${#NAIVE_AWK_SHA} chars), expected 39"
fi

# (f) Assert the naive `sed 's/^[+-U]//'` produces the 39-char truncated value that
#     the fix eliminates (demonstrates the locale-dependent range bug).
NAIVE_SED_SHA="$(git -C "$TMP_REPO" submodule status .opencode 2>/dev/null | awk '{print $1}' | sed 's/^[+-U]//' || true)"
if [ "${#NAIVE_SED_SHA}" -eq 39 ]; then
    check_pass "SC-1: naive sed range form produces the 39-char truncated value (bug confirmed)"
else
    check_fail "SC-1: naive sed range form produces the 39-char truncated value (bug confirmed)" \
        "naive sed produced '${NAIVE_SED_SHA}' (${#NAIVE_SED_SHA} chars), expected 39"
fi

# Clean up the temp repo.
rm -rf "$TMP_REPO"

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-1 (Gate 2 fallback SHA extraction) not yet fixed."
    echo "Line 49 of .opencode/hooks/pre-commit still uses the buggy awk substr form,"
    echo "which strips the leading hex char of a clean submodule's status line, producing"
    echo "a 39-char SHA that never equals the 40-char remote tip → false BLOCK."
    echo ""
    exit 1
fi
exit 0
