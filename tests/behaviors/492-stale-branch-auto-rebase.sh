#!/bin/bash
# Behavioral test: 492-stale-branch-auto-rebase
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# RED phase: staleness-check step does not exist yet in review-prep.
# The agent will NOT detect staleness or auto-rebase — evaluation will FAIL.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

BEHAVIOR_PHASE="RED"
SUBMODULE_REMOTE="https://github.com/michael-conrad/.opencode.git"

setup_workdir() {
    local workdir="$1"
    git init -q "$workdir"
    git -C "$workdir" config user.email "test@test.dev"
    git -C "$workdir" config user.name "Test"
    local bare_repo="$workdir/../origin.git"
    git init --bare "$bare_repo"
    git -C "$workdir" remote add origin "$bare_repo"
}

setup_stale_branch() {
    local workdir="$1"
    setup_workdir "$workdir"
    echo "initial" > "$workdir/file.txt"
    git -C "$workdir" add file.txt
    git -C "$workdir" commit -q -m "initial"
    git -C "$workdir" branch -M dev
    git -C "$workdir" push -q origin dev
    git -C "$workdir" checkout -b feature/stale-test
    echo "feature work" >> "$workdir/file.txt"
    git -C "$workdir" add file.txt
    git -C "$workdir" commit -q -m "feature commit"
    git -C "$workdir" checkout dev
    echo "dev ahead 1" >> "$workdir/file.txt"
    git -C "$workdir" add file.txt
    git -C "$workdir" commit -q -m "dev ahead 1"
    echo "dev ahead 2" >> "$workdir/file.txt"
    git -C "$workdir" add file.txt
    git -C "$workdir" commit -q -m "dev ahead 2"
    git -C "$workdir" push -q origin dev
    git -C "$workdir" checkout feature/stale-test
}

setup_clean_branch() {
    local workdir="$1"
    setup_workdir "$workdir"
    echo "initial" > "$workdir/file.txt"
    git -C "$workdir" add file.txt
    git -C "$workdir" commit -q -m "initial"
    git -C "$workdir" branch -M dev
    git -C "$workdir" push -q origin dev
    git -C "$workdir" checkout -b feature/clean-test
    echo "feature work" >> "$workdir/file.txt"
    git -C "$workdir" add file.txt
    git -C "$workdir" commit -q -m "feature commit"
}

setup_conflict_branch() {
    local workdir="$1"
    setup_workdir "$workdir"
    echo "same line content" > "$workdir/file.txt"
    git -C "$workdir" add file.txt
    git -C "$workdir" commit -q -m "initial"
    git -C "$workdir" branch -M dev
    git -C "$workdir" push -q origin dev
    git -C "$workdir" checkout -b feature/conflict-test
    echo "feature version" > "$workdir/file.txt"
    git -C "$workdir" add file.txt
    git -C "$workdir" commit -q -m "feature change"
    git -C "$workdir" checkout dev
    echo "dev version" > "$workdir/file.txt"
    git -C "$workdir" add file.txt
    git -C "$workdir" commit -q -m "dev change"
    git -C "$workdir" push -q origin dev
    git -C "$workdir" checkout feature/conflict-test
}

finalize_workdir() {
    local workdir="$1"
    git clone -q "$SUBMODULE_REMOTE" "$workdir/.opencode"
    mkdir -p "$workdir/.issues"
    git -C "$workdir" add -A
    git -C "$workdir" commit -q --allow-empty -m "setup complete"
}

# SC-2: Stale branch — agent should detect staleness and auto-rebase
STALE_WD=$(mktemp -d "$PARENT_REPO_DIR/tmp/behavior-isolated-XXXXXX")
setup_stale_branch "$STALE_WD"
finalize_workdir "$STALE_WD"
echo "  [setup] stale branch: $(git -C "$STALE_WD" rev-list --count --left-right origin/dev...HEAD | cut -f1) commits behind"
behavior_run "492-stale-branch-auto-rebase-stale" \
    "Execute review-prep for the current feature branch. Prepare the branch for PR creation against dev." \
    "$DEFAULT_TEST_MODEL" "$STALE_WD"

# SC-5: Clean branch — agent should proceed normally
CLEAN_WD=$(mktemp -d "$PARENT_REPO_DIR/tmp/behavior-isolated-XXXXXX")
setup_clean_branch "$CLEAN_WD"
finalize_workdir "$CLEAN_WD"
echo "  [setup] clean branch: $(git -C "$CLEAN_WD" rev-list --count --left-right origin/dev...HEAD | cut -f1) commits behind"
behavior_run "492-stale-branch-auto-rebase-clean" \
    "Execute review-prep for the current feature branch. Prepare the branch for PR creation against dev." \
    "$DEFAULT_TEST_MODEL" "$CLEAN_WD"

# SC-4: Tier 3 conflict — agent should halt and escalate
CONFLICT_WD=$(mktemp -d "$PARENT_REPO_DIR/tmp/behavior-isolated-XXXXXX")
setup_conflict_branch "$CONFLICT_WD"
finalize_workdir "$CONFLICT_WD"
echo "  [setup] conflict branch: $(git -C "$CONFLICT_WD" rev-list --count --left-right origin/dev...HEAD | cut -f1) commits behind"
behavior_run "492-stale-branch-auto-rebase-conflict" \
    "Execute review-prep for the current feature branch. Prepare the branch for PR creation against dev." \
    "$DEFAULT_TEST_MODEL" "$CONFLICT_WD"

exit 0
