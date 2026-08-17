#!/bin/bash
# Behavioral test: 2292-sc2-live-root-guard
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (behavioral): The test harness SHALL detect when a git-mutating target
# resolves to the live repo ($PARENT_REPO_DIR / $PROJECT_DIR) and BLOCK with a
# clear diagnostic before mutating.
#
# RED STATE:
# helpers.sh has NO live-root mutation guard. A git-mutating operation whose
# resolved target equals the live .opencode repo ($PARENT_REPO_DIR) executes
# without any BLOCK — the mutation succeeds and the live repo is modified.
#
# THIS TEST IS AN ARTIFACT-ONLY GENERATOR. It:
#   1. Snapshots the live .opencode repo's `origin` remote and `main` ref (before)
#   2. Invokes the harness guard function `__assert_not_live_root` with the live
#      repo as the resolved git-mutating target, capturing its exit code and output
#   3. Snapshots the live repo again (after)
#   4. Writes the guard result and both snapshots into the artifact dir for
#      clean-room evaluation
# It does NOT assert, evaluate, or produce a verdict — it only generates artifacts.
#
# A clean-room sub-agent evaluates the artifacts. If the guard function is absent
# (command not found) or returns success (exit 0) for a live-repo target, the SC-2
# guard is not enforced and the SC FAILS (RED). If the guard returns non-zero with a
# clear BLOCK diagnostic and the live repo is unmutated (before == after), the guard
# is present and the SC PASSES (GREEN).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2292-sc2-live-root-guard"

# The live .opencode repo — the target a git-mutating op must be guarded against.
# $PARENT_REPO_DIR resolves to the live .opencode repo because helpers.sh walks up
# from its own location to the first directory containing .opencode/.
LIVE_REPO="$PARENT_REPO_DIR"

# Establish the artifact directory. This test does not run a model (it invokes the
# guard function directly), so it creates the artifact dir via the same helper
# behavior_run uses, keyed on the default test model for a stable slug.
MODEL="${DEFAULT_TEST_MODEL}"
ARTIFACT_DIR="$(__artifact_dir "$SCENARIO_NAME" "$MODEL")"
mkdir -p "$ARTIFACT_DIR"

# Before-snapshot of the live .opencode repo.
LIVE_BEFORE_REMOTE=""
if git -C "$LIVE_REPO" remote get-url origin &>/dev/null; then
    LIVE_BEFORE_REMOTE="$(git -C "$LIVE_REPO" remote get-url origin 2>/dev/null || true)"
fi
LIVE_BEFORE_MAIN="$(git -C "$LIVE_REPO" rev-parse main 2>/dev/null || true)"

# Invoke the harness guard function with the live repo as the resolved git-mutating
# target. In RED (no guard) this fails with "command not found" (exit 127). In GREEN
# (guard present) it returns non-zero with a BLOCK diagnostic and no mutation occurs.
# The `|| true` keeps the artifact-only generator from exiting non-zero on the
# expected RED failure; the exit code is captured for the clean-room evaluator.
set +e
GUARD_OUTPUT="$(__assert_not_live_root "$LIVE_REPO" 2>&1)"
GUARD_EXIT=$?
set -e

# After-snapshot of the live .opencode repo.
LIVE_AFTER_REMOTE=""
if git -C "$LIVE_REPO" remote get-url origin &>/dev/null; then
    LIVE_AFTER_REMOTE="$(git -C "$LIVE_REPO" remote get-url origin 2>/dev/null || true)"
fi
LIVE_AFTER_MAIN="$(git -C "$LIVE_REPO" rev-parse main 2>/dev/null || true)"

cat > "$ARTIFACT_DIR/live-root-guard-evidence.txt" <<SNAPSHOTEOF
# SC-2 live-root guard evidence — guard invocation result and before/after snapshots
# of the live .opencode repo. A clean-room sub-agent evaluates:
#   - guard_exit: 127 (command not found) => guard absent, SC FAILS (RED)
#   - guard_exit: 0 (success) for a live-repo target => guard not enforced, SC FAILS (RED)
#   - guard_exit: non-zero AND before == after => guard blocked the mutation, SC PASSES (GREEN)
live_repo: ${LIVE_REPO}
guard_exit: ${GUARD_EXIT}
guard_output:
${GUARD_OUTPUT}
before_origin: ${LIVE_BEFORE_REMOTE:-<none>}
after_origin:  ${LIVE_AFTER_REMOTE:-<none>}
before_main:   ${LIVE_BEFORE_MAIN:-<none>}
after_main:    ${LIVE_AFTER_MAIN:-<none>}
SNAPSHOTEOF

exit 0
