#!/bin/bash
# Content-Verification Enforcement Test: Phase 7 — 2242-sc6 Full-Env Opt-In (Concern C8)
#
# Issue: .opencode#2244 — full-environment simulation in the tests-v2 harness.
# Phase: red-phase7-2242sc6-optin — Concern C8,
#        `.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh`
#        and its per-scenario fixture.
#
# SCs covered: SC10, SC11, SC12.
#
# SC10 (behavioral): When the full-env opt-in (`BEHAVIOR_NEEDS_MULTI_SUBMODULES=1` AND
#   `BEHAVIOR_NEEDS_REMOTE=1`) is set for the 2242-sc6 test, its session.yaml shows merged-PR
#   discovery (`gh pr list`) returned a merged branch and an open issue.
#
# SC11 (behavioral): In the SC10 run, the git-workflow-cleanup dispatch completes and produces
#   a result contract, and session.yaml shows the orchestrator never read the cleanup task
#   card (`tasks/cleanup.md`) — no file-read tool call targets that path.
#
# SC12 (behavioral): In the SC10 run, session.yaml shows the agent never halted to ask for
#   PR/branch context (no question-tool call or "provide PR" halt).
#
# RED state determination: The 2242-sc6 test currently sets ONLY `BEHAVIOR_NEEDS_REMOTE=1`
#   (line 26) — it does NOT set `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1`. The full-env opt-in for
#   Phase 7 requires BOTH flags (the merged-PR discovery and cleanup-dispatch completion depend
#   on multi-submodule provisioning + the wired GitBucket origin). SC10's structural prerequisite
#   (both flags present) is therefore RED-now. Assertions (a)-(b) below FAIL.
#
# The per-scenario fixture (`fixtures/setup/2242-sc6-cleanup-dispatch-no-task-card-read.sh`)
# already provisions a merged branch (feature/2242-merged merged into main) and an open issue
# (.issues/open/2242/spec.md) — the SC10 fixture prerequisite is already GREEN.
#
# SC11 and SC12 are behavioral: they are verified by clean-room session.yaml evaluation of an
# SC10 full-env run (clean-room sub-agent reads session.yaml and confirms the cleanup dispatch
# produced a result contract with no `tasks/cleanup.md` read, and that no question-tool call /
# PR-context halt occurred). They are NOT verifiable by this structural test. This test documents
# their structural prerequisites only.
#
# Usage: bash .opencode/tests-v2/test-2244-phase7-2242sc6-optin.sh
# Exit:  0 if all structural checks pass (GREEN), 1 if any check fails (expected RED on SC10).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

BEHAVIOR_TEST="$PROJECT_DIR/.opencode/tests-v2/behaviors/2242-sc6-cleanup-dispatch-no-task-card-read.sh"
FIXTURE="$PROJECT_DIR/.opencode/tests-v2/behaviors/fixtures/setup/2242-sc6-cleanup-dispatch-no-task-card-read.sh"

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
echo "=== Phase 7 — 2242-sc6 Full-Env Opt-In (Spec #2244, Concern C8) ==="
echo ""
echo "Target file: $BEHAVIOR_TEST"
echo "Fixture:     $FIXTURE"
echo ""

# ---------------------------------------------------------------------------
# SC10 (behavioral) structural PREREQUISITE: the full-env opt-in sets BOTH
# BEHAVIOR_NEEDS_MULTI_SUBMODULES=1 AND BEHAVIOR_NEEDS_REMOTE=1 on the 2242-sc6
# test. Merged-PR discovery and cleanup-dispatch completion require multi-submodule
# provisioning (test-submodule-1/test-submodule-2, the repos whose PRs/branches the
# cleanup deletes) plus the wired GitBucket origin. A single-flag run cannot satisfy
# SC10's "gh pr list returned a merged branch and an open issue" criterion.
#
# RED-now: only BEHAVIOR_NEEDS_REMOTE=1 is set (line 26). BEHAVIOR_NEEDS_MULTI_SUBMODULES=1
# is absent. Assertions (a) and (b) below FAIL. GREEN adds the missing multi-submodule flag.
# ---------------------------------------------------------------------------
echo "--- SC10 (prereq): full-env opt-in sets BOTH flags on the 2242-sc6 test ---"

# (a) The test sets BEHAVIOR_NEEDS_MULTI_SUBMODULES=1 (currently MISSING → RED).
grep_assert_present \
    "SC10: 2242-sc6 test sets BEHAVIOR_NEEDS_MULTI_SUBMODULES=1" \
    "$BEHAVIOR_TEST" \
    "BEHAVIOR_NEEDS_MULTI_SUBMODULES=1"

# (b) The test sets BEHAVIOR_NEEDS_REMOTE=1 (currently present → GREEN).
grep_assert_present \
    "SC10: 2242-sc6 test sets BEHAVIOR_NEEDS_REMOTE=1" \
    "$BEHAVIOR_TEST" \
    "BEHAVIOR_NEEDS_REMOTE=1"

# ---------------------------------------------------------------------------
# SC10 (behavioral) fixture PREREQUISITE: the per-scenario fixture provides a merged
# branch and an open issue so `gh pr list` discovery has data to return. This is
# already GREEN — the fixture creates feature/2242-merged (merged into main) and an
# open .issues/open/2242/ issue.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC10 (fixture prereq): fixture provides a merged branch + open issue ---"

# (a) The fixture merges a feature branch into main, leaving a merged branch to delete.
grep_assert_present \
    "SC10: fixture creates feature/2242-merged branch" \
    "$FIXTURE" \
    "feature/2242-merged"

# (b) The fixture merges that branch into main (the cleanup-deletion target).
grep_assert_present \
    "SC10: fixture merges feature/2242-merged into main" \
    "$FIXTURE" \
    "merge --no-ff feature/2242-merged"

# (c) The fixture provisions an open issue the orchestrator can close.
grep_assert_present \
    "SC10: fixture provisions open issue (spec.md)" \
    "$FIXTURE" \
    ".issues/open/2242/spec.md"

# ---------------------------------------------------------------------------
# SC11 (behavioral): In the SC10 run, the git-workflow-cleanup dispatch completes and
# produces a result contract, and session.yaml shows the orchestrator never read the
# cleanup task card (`tasks/cleanup.md`) — no file-read tool call targets that path.
#
# SC12 (behavioral): In the SC10 run, session.yaml shows the agent never halted to ask
# for PR/branch context (no question-tool call or "provide PR" halt).
#
# Both are behavioral: they are verified by clean-room session.yaml evaluation of an SC10
# full-env run (the SC10 artifact). They are NOT verifiable by this structural test. The
# structural prerequisites they depend on are the SC10 opt-in assertions above: the cleanup
# dispatch can only complete (SC11) and avoid a PR-context halt (SC12) when merged-PR
# discovery returns data, which requires the full-env opt-in (both flags). This comment
# documents that dependency; it carries no structural assertion of its own.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC11: cleanup dispatch completes without a tasks/cleanup.md read (behavioral) ---"
echo "  SC11 is behavioral: verified by clean-room session.yaml evaluation of the SC10"
echo "  full-env run (result contract produced; no file-read tool call targets"
echo "  tasks/cleanup.md). Not verifiable structurally. Prerequisite = SC10 opt-in above."
echo ""
echo "--- SC12: no question-tool call / PR-context halt (behavioral) ---"
echo "  SC12 is behavioral: verified by clean-room session.yaml evaluation of the SC10"
echo "  full-env run (no question-tool call, no \"provide PR\" halt). Not verifiable"
echo "  structurally. Prerequisite = SC10 opt-in above."

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 7 (2242-sc6 full-env opt-in) not yet implemented."
    echo "The 2242-sc6 test sets only BEHAVIOR_NEEDS_REMOTE=1 (line 26); the full-env opt-in"
    echo "requires BEHAVIOR_NEEDS_MULTI_SUBMODULES=1 to also be set so merged-PR discovery"
    echo "returns a merged branch + open issue (SC10) and the cleanup dispatch can complete"
    echo "without a task-card read (SC11) or a PR-context halt (SC12)."
    echo ""
    exit 1
fi
echo "SC10 opt-in prerequisite is GREEN (both flags present). The full-env run is required"
echo "for the behavioral SC10/SC11/SC12 clean-room session.yaml evaluation."
echo ""
exit 0
