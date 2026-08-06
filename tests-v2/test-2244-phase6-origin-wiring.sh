#!/bin/bash
# Content-Verification Enforcement Test: Phase 6 — GitBucket Origin Wiring + Discovery (Concern C2)
#
# Issue: .opencode#2244 — full-environment simulation in the tests-v2 harness.
# Phase: red-phase6-origin-wiring — Concern C2,
#        `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run origin-wiring + gh pr list).
#
# SCs covered: SC2, SC3.
#
# SC2 (structural): When BEHAVIOR_NEEDS_REMOTE=1 is set in the environment and GitBucket is
#   provisioned, behavior_run() in helpers.sh wires the GitBucket instance as the test repo's
#   `origin` remote in the attempt workdir.
#
# SC3 (behavioral): When the GitBucket origin is wired (SC2), the agent's `gh pr list` call in
#   the isolated test env discovers merged branches and open issues without GitHub auth.
#
# RED state determination: The origin-wiring block ALREADY EXISTS in helpers.sh (lines ~545-552).
# It branches on `BEHAVIOR_NEEDS_REMOTE=1`, requires `GITBUCKET_PORT` (i.e. GitBucket is
# provisioned), attaches the GitBucket instance as `origin` via
# `git remote add origin "http://root:${gb_token}@localhost:${gb_port}/git/root/test-repo.git"`,
# and pushes main. This fully satisfies SC2's structural criterion — SC2 is ALREADY GREEN.
#
# SC3 is behavioral: merged-PR/issue discovery is verified by clean-room session.yaml evaluation
# of a `BEHAVIOR_NEEDS_REMOTE=1` opencode run (the clean-room sub-agent confirms `gh pr list`
# returned merged-branch/issue results and the agent did not halt for missing PR context).
# SC3 is NOT verifiable by this structural test. This test asserts the wiring PREREQUISITE
# exists (SC2), which is what SC3 depends on.
#
# This test is expected to PASS on SC2 (GREEN already present). If any SC2 assertion fails, the
# origin-wiring prerequisite is defective and SC3 cannot be verified.
#
# Usage: bash .opencode/tests-v2/test-2244-phase6-origin-wiring.sh
# Exit:  0 if all SC2 wiring-prerequisite checks pass (GREEN), 1 if any check fails.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

HELPERS_SH="$PROJECT_DIR/.opencode/tests-v2/behaviors/helpers.sh"

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
echo "=== Phase 6 — GitBucket Origin Wiring + Discovery (Spec #2244, Concern C2) ==="
echo ""
echo "Target file: $HELPERS_SH"
echo ""

# ---------------------------------------------------------------------------
# SC2 (structural): When BEHAVIOR_NEEDS_REMOTE=1 is set and GitBucket is provisioned,
# behavior_run() wires the GitBucket instance as the test repo's `origin` remote in the
# attempt workdir.
#
# RED-now: the origin-wiring block ALREADY EXISTS (helpers.sh ~lines 545-552) and fully
# satisfies SC2 — this is an already-GREEN criterion. The assertions below confirm the
# wiring prerequisite is present and correct.
# ---------------------------------------------------------------------------
echo "--- SC2: GitBucket origin wiring in behavior_run ---"

# (a) The origin-wiring block branches on BEHAVIOR_NEEDS_REMOTE=1.
grep_assert_present \
    "SC2: origin-wiring block branches on BEHAVIOR_NEEDS_REMOTE" \
    "$HELPERS_SH" \
    "BEHAVIOR_NEEDS_REMOTE"

# (b) The block requires GitBucket to be provisioned (GITBUCKET_PORT non-empty).
grep_assert_present \
    "SC2: origin wiring requires GitBucket provisioned (GITBUCKET_PORT)" \
    "$HELPERS_SH" \
    'GITBUCKET_PORT:-}"'

# (c) The block attaches the GitBucket instance as origin via `remote add origin` with the
# localhost GitBucket URL.
grep_assert_present \
    "SC2: remote add origin with the localhost GitBucket URL" \
    "$HELPERS_SH" \
    "remote add origin \"http://root:\${gb_token}@localhost:\${gb_port}/git/root/test-repo.git\""

# (d) The origin is wired on the attempt workdir.
grep_assert_present \
    "SC2: origin wired on the attempt workdir" \
    "$HELPERS_SH" \
    "git -C \"\$attempt_workdir\" remote add origin"

# ---------------------------------------------------------------------------
# SC3 (behavioral): When the GitBucket origin is wired (SC2), the agent's `gh pr list` call
# in the isolated test env discovers merged branches and open issues without GitHub auth.
#
# SC3 is NOT verifiable by a structural test. Merged-PR/issue discovery is verified by
# clean-room session.yaml evaluation of a BEHAVIOR_NEEDS_REMOTE=1 opencode run: the
# clean-room sub-agent reads session.yaml and confirms `gh pr list` returned merged-branch/
# issue results and the agent did not halt for missing PR context.
#
# The structural prerequisite that SC3 depends on is the SC2 origin wiring asserted above.
# This comment documents SC3's behavioral verification path; it carries no structural
# assertion of its own. The presence of the wired origin (SC2 GREEN) is the prerequisite
# under which SC3 discovery is evaluated.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC3: merged-PR/issue discovery without GitHub auth (behavioral) ---"
echo "  SC3 is behavioral: verified by clean-room session.yaml evaluation of a"
echo "  BEHAVIOR_NEEDS_REMOTE=1 opencode run (gh pr list discovery + no PR-context halt)."
echo "  This structural test asserts only the wiring prerequisite (SC2)."

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "FAILURE: SC2 origin-wiring prerequisite is defective in helpers.sh."
    echo "The origin-wiring block must wire the GitBucket instance as origin when"
    echo "BEHAVIOR_NEEDS_REMOTE=1 and GitBucket is provisioned. SC3 discovery cannot be"
    echo "verified without a correct wired origin."
    echo ""
    exit 1
fi
echo "SC2 is GREEN (origin-wiring prerequisite present). SC3 remains behavioral and is"
echo "verified by clean-room session.yaml evaluation, not this structural test."
echo ""
exit 0
