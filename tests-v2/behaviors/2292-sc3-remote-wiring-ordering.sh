#!/bin/bash
# Behavioral test: 2292-sc3-remote-wiring-ordering
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3 (behavioral): The `__ensure_gitbucket()` remote-wiring block SHALL run
# against a validated isolated repo established before remote wiring, or be
# relocated/guarded so it cannot hit the live repo. GitBucket origin MUST be wired
# on the isolated `$attempt_workdir` and the live repo origin MUST be untouched.
#
# RED STATE:
# `__ensure_gitbucket()` is invoked from behavior_run() at helpers.sh line 524,
# BEFORE the isolated `$attempt_workdir` is created (line 544). Its remote-wiring
# block (lines 291-307) therefore runs before any isolated target exists. With
# $TEST_PROJECT unset at that point, the block now emits a BLOCKED diagnostic and
# returns 1 (post SC-1/SC-2), which aborts behavior_run() with "GitBucket
# provisioning failed" — so the isolated attempt_workdir never gets its GitBucket
# origin wired. The remote-wiring ordering defect is present: the block runs before
# an isolated target exists instead of being relocated/guarded to run against the
# established isolated repo.
#
# THIS TEST IS AN ARTIFACT-ONLY GENERATOR. It:
#   1. Snapshots the live .opencode repo's `origin` remote and `main` ref (before)
#   2. Runs a BEHAVIOR_NEEDS_REMOTE=1 scenario, which triggers __ensure_gitbucket()
#   3. Captures the behavior_run exit code (the provisioning may abort in RED)
#   4. Snapshots the live repo again (after)
#   5. Inspects the most recent isolated attempt_workdir (if any) for a wired
#      GitBucket origin
#   6. Writes all evidence into the artifact dir for clean-room evaluation
# It does NOT assert, evaluate, or produce a verdict — it only generates artifacts.
#
# A clean-room sub-agent evaluates the artifacts. If the live repo origin/main
# changed (before != after) OR the isolated attempt_workdir has no GitBucket origin
# wired (provisioning aborted before the isolated target existed), the SC-3
# ordering defect is present and the SC FAILS (RED). If the isolated attempt_workdir
# has a GitBucket origin wired AND the live repo is untouched, the remote-wiring
# block runs against the established isolated repo and the SC PASSES (GREEN).
#
# PROMPT CONSTRUCTION:
# Real-domain task: exercise a git remote operation in a repo whose origin is wired
# to a GitBucket instance by BEHAVIOR_NEEDS_REMOTE=1. The harness's __ensure_gitbucket()
# remote-wiring block runs in the parent shell regardless of the model prompt, so the
# prompt's purpose is to produce a natural session (session.yaml) whose harness run
# either wired the isolated attempt_workdir origin (GREEN) or aborted before an
# isolated target existed (RED). The prompt is a natural git remote task, NOT a
# prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2292-sc3-remote-wiring-ordering"
SCENARIO_PROMPT="This repository's origin is a GitBucket instance (GB_HOST and GB_TOKEN are set). Push the current branch to origin and report the resulting remote state. Verify with git remote -v that origin points to the GitBucket instance and with git status that your local branch is up to date with origin."

# SC-3: provision a self-contained GitBucket instance so __ensure_gitbucket() runs
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

# Run the BEHAVIOR_NEEDS_REMOTE=1 scenario. In RED, __ensure_gitbucket() aborts
# before an isolated target exists, so behavior_run returns 1 and no artifact dir
# is created. Capture the exit code and continue generating evidence regardless.
set +e
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
BEHAVIOR_RUN_EXIT=$?
set -e

# After-snapshot of the live .opencode repo.
LIVE_AFTER_REMOTE=""
if git -C "$LIVE_REPO" remote get-url origin &>/dev/null; then
    LIVE_AFTER_REMOTE="$(git -C "$LIVE_REPO" remote get-url origin 2>/dev/null || true)"
fi
LIVE_AFTER_MAIN="$(git -C "$LIVE_REPO" rev-parse main 2>/dev/null || true)"

# Inspect the most recent isolated test-home project (if any) for a wired GitBucket
# origin. with-test-home MOVES the attempt_workdir into $test_home/project, so the
# isolated repo lives at tmp/test-home-*/project — NOT tmp/behavior-isolated-*.
# In RED the provisioning aborts before the isolated project is established, so
# this is empty. In GREEN the test-home project exists with a GitBucket origin wired.
ISOLATED_WORKDIR=""
ISOLATED_ORIGIN=""
ISOLATED_WORKDIR="$(ls -dt "$PARENT_REPO_DIR"/tmp/test-home-*/project 2>/dev/null | head -1 || true)"
if [ -n "$ISOLATED_WORKDIR" ] && [ -d "$ISOLATED_WORKDIR" ]; then
    if git -C "$ISOLATED_WORKDIR" remote get-url origin &>/dev/null; then
        ISOLATED_ORIGIN="$(git -C "$ISOLATED_WORKDIR" remote get-url origin 2>/dev/null || true)"
    fi
fi

# Establish the artifact directory. behavior_run may not have created one (RED
# abort), so create it via the same helper keyed on the default test model.
MODEL="${DEFAULT_TEST_MODEL}"
ARTIFACT_DIR="$(__artifact_dir "$SCENARIO_NAME" "$MODEL")"
mkdir -p "$ARTIFACT_DIR"

cat > "$ARTIFACT_DIR/remote-wiring-ordering-evidence.txt" <<SNAPSHOTEOF
# SC-3 remote-wiring ordering evidence — live repo before/after snapshots, the
# behavior_run exit code, and the isolated attempt_workdir origin wiring.
# A clean-room sub-agent evaluates:
#   - live repo origin/main changed (before != after) => live repo mutated, SC FAILS (RED)
#   - behavior_run_exit: 1 AND isolated_origin empty => provisioning aborted before an
#     isolated target existed, remote-wiring ordering defect present, SC FAILS (RED)
#   - isolated_origin contains a GitBucket URL AND live repo untouched => remote wiring
#     ran against the established isolated repo, SC PASSES (GREEN)
live_repo: ${LIVE_REPO}
behavior_run_exit: ${BEHAVIOR_RUN_EXIT}
before_origin: ${LIVE_BEFORE_REMOTE:-<none>}
after_origin:  ${LIVE_AFTER_REMOTE:-<none>}
before_main:   ${LIVE_BEFORE_MAIN:-<none>}
after_main:    ${LIVE_AFTER_MAIN:-<none>}
isolated_workdir: ${ISOLATED_WORKDIR:-<none>}
isolated_origin:  ${ISOLATED_ORIGIN:-<none>}
SNAPSHOTEOF

exit 0
