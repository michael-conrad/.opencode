#!/bin/bash
# Behavioral test: 2292-sc1-live-root-fallback
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 (behavioral): `__ensure_gitbucket()` in .opencode/tests-v2/behaviors/helpers.sh
# SHALL NOT fall back to $project_root for git-mutating remote operations when
# $TEST_PROJECT is unset.
#
# RED STATE:
# helpers.sh line 267 declares `local test_project="${TEST_PROJECT:-$project_root}"`.
# $TEST_PROJECT is only set inside with-test-home's subprocess (helpers.sh line 620),
# but __ensure_gitbucket() runs in the parent shell at line 488 — BEFORE that. So a
# BEHAVIOR_NEEDS_REMOTE=1 run resolves the git-mutating target to $project_root,
# which equals $PARENT_REPO_DIR — the LIVE .opencode repo. The remote-wiring block
# (lines 266-273) then `git remote remove/add origin` and `git push -u origin main`
# against the live repo, silently mutating its `origin` remote and `main` ref.
#
# THIS TEST IS AN ARTIFACT-ONLY GENERATOR. It:
#   1. Snapshots the live .opencode repo's `origin` remote and `main` ref (before)
#   2. Runs a BEHAVIOR_NEEDS_REMOTE=1 scenario, which triggers __ensure_gitbucket()
#   3. Snapshots the live repo again (after)
#   4. Writes both snapshots into the artifact dir for clean-room evaluation
# It does NOT assert, evaluate, or produce a verdict — it only generates artifacts.
#
# A clean-room sub-agent compares the before/after snapshots. If they differ, then
# __ensure_gitbucket() fell back to $project_root and mutated the live repo — the
# SC-1 defect is present and the SC FAILS (RED). If they are identical, the fallback
# is eliminated and the live repo is untouched — the SC PASSES (GREEN).
#
# PROMPT CONSTRUCTION:
# Real-domain task: exercise a git remote operation in a repo whose origin is wired
# to a GitBucket instance by BEHAVIOR_NEEDS_REMOTE=1. The harness's __ensure_gitbucket()
# remote-wiring block runs in the parent shell regardless of the model prompt, so the
# prompt's purpose is to produce a natural session (session.yaml) whose harness run
# either mutated the live repo (RED) or did not (GREEN). The prompt is a natural git
# remote task, NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2292-sc1-live-root-fallback"
SCENARIO_PROMPT="This repository's origin is a GitBucket instance (GB_HOST and GB_TOKEN are set). Push the current branch to origin and report the resulting remote state. Verify with git remote -v that origin points to the GitBucket instance and with git status that your local branch is up to date with origin."

# SC-1: provision a self-contained GitBucket instance so __ensure_gitbucket() runs
# the remote-wiring block. MUST be exported: with-test-home runs as a child process
# and gates GB_TOKEN propagation on this variable.
export BEHAVIOR_NEEDS_REMOTE=1

# Before-snapshot of the live .opencode repo (the target the fallback would hit).
# $PARENT_REPO_DIR resolves to the live .opencode repo because helpers.sh walks up
# from its own location to the first directory containing .opencode/.
LIVE_REPO="$PARENT_REPO_DIR"
LIVE_BEFORE_REMOTE=""
if git -C "$LIVE_REPO" remote get-url origin &>/dev/null; then
    LIVE_BEFORE_REMOTE="$(git -C "$LIVE_REPO" remote get-url origin 2>/dev/null || true)"
fi
LIVE_BEFORE_MAIN="$(git -C "$LIVE_REPO" rev-parse main 2>/dev/null || true)"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# After-snapshot of the live .opencode repo. behavior_run exports
# $BEHAVIOR_ARTIFACT_DIR pointing at the artifact dir it created.
LIVE_AFTER_REMOTE=""
if git -C "$LIVE_REPO" remote get-url origin &>/dev/null; then
    LIVE_AFTER_REMOTE="$(git -C "$LIVE_REPO" remote get-url origin 2>/dev/null || true)"
fi
LIVE_AFTER_MAIN="$(git -C "$LIVE_REPO" rev-parse main 2>/dev/null || true)"

cat > "$BEHAVIOR_ARTIFACT_DIR/live-repo-snapshots.txt" <<SNAPSHOTEOF
# SC-1 live-root mutation evidence — before/after snapshots of the live .opencode repo.
# A clean-room sub-agent compares before vs after. If origin remote or main ref changed,
# __ensure_gitbucket() fell back to \$project_root and mutated the live repo (SC-1 FAIL).
live_repo: ${LIVE_REPO}
before_origin: ${LIVE_BEFORE_REMOTE:-<none>}
after_origin:  ${LIVE_AFTER_REMOTE:-<none>}
before_main:   ${LIVE_BEFORE_MAIN:-<none>}
after_main:    ${LIVE_AFTER_MAIN:-<none>}
SNAPSHOTEOF

exit 0
