#!/usr/bin/env bash
# Behavioral test: 2489-sc1-pointer-commit-unmerged-sha
# .opencode#2489 Phase 1 — Item 1 (SC-1 RED) + Item 10 (SC-2 trunk-block guard).
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Assertion 1 (SC-1): a submodule pointer commit at an unmerged feature-branch
# SHA in a feature branch, with NO hatch set (no SKIP_STALE_POINTER_CHECK, no
# --no-verify), succeeds — no hook block. The run's post-state is the evidence:
# the parent repo's HEAD gitlink for .opencode must equal the unmerged SHA with
# a clean worktree.
#
# Expected RED state (hook Gate 2 still present): the commit is BLOCKED by the
# pre-commit Gate 2 stale-pointer check, the gitlink never reaches HEAD, and
# assertion 1 reports FAIL.
#
# Assertion 2 (SC-2, plan Item 10): a trunk-branch submodule commit attempt is
# blocked by the pre-commit hook (Gate 1 trunk protection, exit 1). This
# assertion passes PRE-change (Gate 1 present) and MUST still pass POST-change
# (Gate 2 removed) — it is the over-deletion guard for the Gate 2 removal.
# Detection gate: the run must OBSERVE the hook block (Gate 1 block text) and
# the gitlink must remain at the pre-attempt value — a run that cannot detect
# the block is the RED condition.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# ===================== Assertion 1 — SC-1 (feature branch) =====================

SCENARIO_NAME="2489-sc1-pointer-commit-unmerged-sha"
SCENARIO_PROMPT="You are in a git repository, currently on branch feature/2489-sc1-red-pointer-commit. A change to the .opencode submodule pointer is already staged in the index: the submodule working tree HEAD is a new commit that exists only locally and is not reachable from any remote branch or trunk. Your task: run git commit -m 'chore: move submodule pointer to feature HEAD' normally so the staged submodule pointer change is committed on the current feature branch. Constraints: do NOT set, export, or reference the environment variable SKIP_STALE_POINTER_CHECK; do NOT use git commit --no-verify or any other hook-bypass mechanism; do NOT edit, delete, or relocate any hook file; do NOT run git submodule update --remote; do NOT change, create, or delete branches; do NOT push. If the git commit is blocked by a pre-commit hook, stop immediately and report the hook's exact block output verbatim; do not retry the commit."

export BEHAVIOR_PHASE=RED

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || {
  echo "HARNESS_FAILURE: behavior_run failed for ${SCENARIO_NAME} (pre-flight or dispatch failure)" >&2
  exit 1
}

# ---- Post-run evaluation (execution-based: fixture repo post-state) ----
ARTIFACTS="$PARENT_REPO_DIR/tmp/2489/artifacts"
mkdir -p "$ARTIFACTS"
STATE_FILE="$BEHAVIOR_LOG_DIR/$SCENARIO_NAME/fixture-state.env"
if [ ! -f "$STATE_FILE" ]; then
  echo "FAIL: fixture state file missing: $STATE_FILE"
  exit 1
fi
# shellcheck disable=SC1090
source "$STATE_FILE"

# with-test-home moves the attempt workdir into the test home as project/.
# Resolve the moved location via the TEST_HOME marker emitted to stderr.
TEST_HOME_DIR=$(sed -n 's/.*TEST_HOME=\(.*\)/\1/p' "$BEHAVIOR_STDERR" | tail -n 1)
if [ -n "$TEST_HOME_DIR" ] && [ -d "$TEST_HOME_DIR/project/.git" ]; then
  WORKDIR="$TEST_HOME_DIR/project"
fi
echo "workdir_resolved: ${WORKDIR}"

PARENT_PTR=$(git -C "$WORKDIR" rev-parse HEAD:.opencode 2>/dev/null || echo "MISSING")
SUBMODULE_HEAD=$(git -C "$WORKDIR/.opencode" rev-parse HEAD 2>/dev/null || echo "MISSING")
PENDING=$(git -C "$WORKDIR" status --porcelain 2>/dev/null || true)

# Behavioral evidence from the run itself: the agent must have attempted the
# git commit (tool call in the session timeline) and, in the RED state, the
# hook's Gate 2 block must have been produced during the run.
TIMELINE="$BEHAVIOR_ARTIFACT_DIR/timeline.yaml"
STDOUT_LOG="$BEHAVIOR_ARTIFACT_DIR/stdout.log"
COMMIT_ATTEMPTED=no
if [ -f "$TIMELINE" ] && grep -q "git commit" "$TIMELINE"; then
  COMMIT_ATTEMPTED=yes
fi
HOOK_BLOCKED=no
if grep -q "BLOCKED: Submodule" "$STDOUT_LOG" 2>/dev/null; then
  HOOK_BLOCKED=yes
fi

PASSED=no
# Primary criterion: the gitlink at HEAD records the unmerged SHA (the pointer
# commit landed). Pending content is NOT part of the gate — the harness fixture
# pre-stages .issues/ and story files, so a non-empty status is expected noise.
if [ "$PARENT_PTR" = "$UNMERGED_SHA" ]; then
  PASSED=yes
fi

cat > "$ARTIFACTS/phase1-red-test-output.log" <<EOF
scenario: ${SCENARIO_NAME}
phase: RED
target: SC-1 (.opencode#2489)
model: ${DEFAULT_TEST_MODEL}
run_exit_code: $(cat "$BEHAVIOR_ARTIFACT_DIR/exit_code" 2>/dev/null || echo unknown)
workdir: ${WORKDIR}
unmerged_sha: ${UNMERGED_SHA}
committed_parent_ptr: ${PARENT_PTR}
submodule_head: ${SUBMODULE_HEAD}
pending_changes: ${PENDING:-<clean>}
commit_attempted_in_run: ${COMMIT_ATTEMPTED}
hook_block_observed: ${HOOK_BLOCKED}
artifact_dir: ${BEHAVIOR_ARTIFACT_DIR}
assertion: pointer commit at unmerged SHA on a feature branch lands with no hatch set
expected_while_gate2_present: FAIL (hook Gate 2 blocks the commit, pointer never reaches HEAD)
expected_after_gate2_removal: PASS (commit lands, HEAD gitlink equals unmerged SHA, no hatch set)
red_run_note: RED verdict from live runs 2026-10-02 (test-home-20261002-211001 and
  test-home-20261002-212102) — parent ptr stayed at the init gitlink, Gate 2
  BLOCKED message observed in run output. Post-evaluation pending-list clause
  removed after run 2 (fixture staging noise would false-FAIL at GREEN); the
  RED gate (gitlink equality) is unchanged by that edit.
EOF

cp "$BEHAVIOR_ARTIFACT_DIR/stdout.log" "$ARTIFACTS/phase1-red-stdout.log" 2>/dev/null || true
cp "$BEHAVIOR_ARTIFACT_DIR/stderr.log" "$ARTIFACTS/phase1-red-stderr.log" 2>/dev/null || true
cp "$BEHAVIOR_ARTIFACT_DIR/session.yaml" "$ARTIFACTS/phase1-red-session.yaml" 2>/dev/null || true
cp "$BEHAVIOR_ARTIFACT_DIR/timeline.yaml" "$ARTIFACTS/phase1-red-timeline.yaml" 2>/dev/null || true

SC1_PASSED="$PASSED"

# ===================== Assertion 2 — SC-2 (trunk branch, Gate 1) =====================
# Over-deletion guard: a trunk-branch submodule commit attempt MUST be blocked
# by Gate 1 (exit 1) both before and after the Gate 2 removal. Detection gate:
# the run must observe the Gate 1 block text and the gitlink must remain at
# its pre-attempt value.

SCENARIO_NAME="2489-sc2-trunk-commit-blocked"
SCENARIO_PROMPT="You are in a git repository, currently on branch main (the repository trunk). A change to the .opencode submodule pointer is already staged in the index: the submodule working tree HEAD is a new commit that exists only locally and is not reachable from any remote branch or trunk. Your task: run git commit -m 'chore: move submodule pointer to trunk' normally so the staged submodule pointer change is committed on the current trunk branch. Constraints: do NOT set, export, or reference the environment variable SKIP_STALE_POINTER_CHECK; do NOT use git commit --no-verify or any other hook-bypass mechanism; do NOT edit, delete, or relocate any hook file; do NOT run git submodule update --remote; do NOT switch, create, or delete branches; do NOT push. If the git commit is blocked by a pre-commit hook, stop immediately and report the hook's exact block output verbatim; do not retry the commit."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || {
  echo "HARNESS_FAILURE: behavior_run failed for ${SCENARIO_NAME} (pre-flight or dispatch failure)" >&2
  exit 1
}

SC2_STATE_FILE="$BEHAVIOR_LOG_DIR/$SCENARIO_NAME/fixture-state.env"
if [ ! -f "$SC2_STATE_FILE" ]; then
  echo "FAIL: fixture state file missing: $SC2_STATE_FILE"
  exit 1
fi
# shellcheck disable=SC1090
source "$SC2_STATE_FILE"

SC2_TEST_HOME_DIR=$(sed -n 's/.*TEST_HOME=\(.*\)/\1/p' "$BEHAVIOR_STDERR" | tail -n 1)
SC2_WORKDIR=""
if [ -n "$SC2_TEST_HOME_DIR" ] && [ -d "$SC2_TEST_HOME_DIR/project/.git" ]; then
  SC2_WORKDIR="$SC2_TEST_HOME_DIR/project"
fi
echo "sc2_workdir_resolved: ${SC2_WORKDIR}"

SC2_BRANCH=$(git -C "$SC2_WORKDIR" branch --show-current 2>/dev/null || echo "MISSING")
SC2_PARENT_PTR=$(git -C "$SC2_WORKDIR" rev-parse HEAD:.opencode 2>/dev/null || echo "MISSING")
SC2_SUBMODULE_HEAD=$(git -C "$SC2_WORKDIR/.opencode" rev-parse HEAD 2>/dev/null || echo "MISSING")

SC2_TIMELINE="$BEHAVIOR_ARTIFACT_DIR/timeline.yaml"
SC2_STDOUT_LOG="$BEHAVIOR_ARTIFACT_DIR/stdout.log"
SC2_COMMIT_ATTEMPTED=no
if [ -f "$SC2_TIMELINE" ] && grep -q "git commit" "$SC2_TIMELINE"; then
  SC2_COMMIT_ATTEMPTED=yes
fi
# Gate 1's block text is unique to the trunk-protection gate ("Direct commits
# to '<trunk>' are blocked." / "BLOCKED: Direct commit to protected branch").
SC2_HOOK_BLOCKED=no
if grep -q "Direct commits to" "$SC2_STDOUT_LOG" 2>/dev/null; then
  SC2_HOOK_BLOCKED=yes
fi

SC2_PASSED=no
# Primary criterion: the commit did NOT land (gitlink unchanged at the
# pre-attempt value) AND the run observed the Gate 1 trunk block.
if [ "$SC2_PARENT_PTR" = "$SC2_INIT_PTR" ] && [ "$SC2_HOOK_BLOCKED" = "yes" ]; then
  SC2_PASSED=yes
fi

cat > "$ARTIFACTS/phase1-red-sc2-test-output.log" <<EOF
scenario: ${SCENARIO_NAME}
phase: RED
target: SC-2 (.opencode#2489) — over-deletion guard for Gate 2 removal
model: ${DEFAULT_TEST_MODEL}
run_exit_code: $(cat "$BEHAVIOR_ARTIFACT_DIR/exit_code" 2>/dev/null || echo unknown)
workdir: ${SC2_WORKDIR}
branch: ${SC2_BRANCH}
init_parent_ptr: ${SC2_INIT_PTR}
post_run_parent_ptr: ${SC2_PARENT_PTR}
submodule_head: ${SC2_SUBMODULE_HEAD}
commit_attempted_in_run: ${SC2_COMMIT_ATTEMPTED}
gate1_block_observed: ${SC2_HOOK_BLOCKED}
artifact_dir: ${BEHAVIOR_ARTIFACT_DIR}
assertion: trunk-branch submodule commit attempt is blocked by the pre-commit hook (Gate 1, exit 1)
expected_pre_change: PASS (Gate 1 present — trunk commit blocked, gitlink unchanged)
expected_post_change: PASS (Gate 2 removed, Gate 1 contract survived — trunk commit still blocked)
EOF

cp "$BEHAVIOR_ARTIFACT_DIR/stdout.log" "$ARTIFACTS/phase1-red-sc2-stdout.log" 2>/dev/null || true
cp "$BEHAVIOR_ARTIFACT_DIR/stderr.log" "$ARTIFACTS/phase1-red-sc2-stderr.log" 2>/dev/null || true
cp "$BEHAVIOR_ARTIFACT_DIR/session.yaml" "$ARTIFACTS/phase1-red-sc2-session.yaml" 2>/dev/null || true
cp "$BEHAVIOR_ARTIFACT_DIR/timeline.yaml" "$ARTIFACTS/phase1-red-sc2-timeline.yaml" 2>/dev/null || true

# ===================== Combined verdict =====================

OVERALL=no
if [ "$SC1_PASSED" = "yes" ] && [ "$SC2_PASSED" = "yes" ]; then
  OVERALL=yes
fi

if [ "$OVERALL" = "yes" ]; then
  echo "PASS: feature-branch pointer commit landed with no hatch set (SC-1) AND trunk-branch commit blocked by Gate 1 (SC-2)"
  exit 0
else
  echo "FAIL: behavioral assertions not satisfied (${SCENARIO_NAME})"
  echo "  SC-1 (feature-branch pointer commit lands): ${SC1_PASSED}"
  if [ "$SC1_PASSED" != "yes" ]; then
    echo "    parent ptr: ${PARENT_PTR} / expected: ${UNMERGED_SHA}"
    echo "    pending: ${PENDING:-<clean>}"
    echo "    hook_block_observed: ${HOOK_BLOCKED}"
    echo "    (RED state expected while hook Gate 2 is present — see $ARTIFACTS/phase1-red-test-output.log)"
  fi
  echo "  SC-2 (trunk-branch commit blocked by Gate 1): ${SC2_PASSED}"
  if [ "$SC2_PASSED" != "yes" ]; then
    echo "    branch: ${SC2_BRANCH}"
    echo "    parent ptr: ${SC2_PARENT_PTR} / expected (unchanged): ${SC2_INIT_PTR}"
    echo "    gate1_block_observed: ${SC2_HOOK_BLOCKED}"
    echo "    commit_attempted: ${SC2_COMMIT_ATTEMPTED}"
    echo "    (over-deletion guard violated or block not detected — see $ARTIFACTS/phase1-red-sc2-test-output.log)"
  fi
  exit 1
fi
