#!/bin/bash
# Behavioral test: 492-stale-branch-auto-rebase
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-GREEN}"
TEST_REMOTE="git@github.com:michael-conrad/test-submodule-1.git"

setup_workdir() {
    local workdir="$1"
    git init -q "$workdir"
    git -C "$workdir" config user.email "test@test.dev"
    git -C "$workdir" config user.name "Test"
    git -C "$workdir" remote add origin "$TEST_REMOTE"
}

seed_dev_branch() {
    local workdir="$1"
    echo "initial" > "$workdir/file.txt"
    git -C "$workdir" add file.txt
    git -C "$workdir" commit -q -m "initial"
    git -C "$workdir" branch -M dev
    git -C "$workdir" push -q -f -u origin dev
}

setup_stale_branch() {
    local workdir="$1"
    git -C "$workdir" fetch -q origin dev
    git -C "$workdir" checkout -q dev
    git -C "$workdir" reset -q --hard origin/dev
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
    git -C "$workdir" fetch -q origin dev
    git -C "$workdir" checkout -q dev
    git -C "$workdir" reset -q --hard origin/dev
    git -C "$workdir" checkout -b feature/clean-test
    echo "feature work" >> "$workdir/file.txt"
    git -C "$workdir" add file.txt
    git -C "$workdir" commit -q -m "feature commit"
}

setup_conflict_branch() {
    local workdir="$1"
    git -C "$workdir" fetch -q origin dev
    git -C "$workdir" checkout -q dev
    git -C "$workdir" reset -q --hard origin/dev
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
    local submodule_remote
    submodule_remote="$(git -C "$SCRIPT_DIR/../.." remote get-url origin 2>/dev/null || echo "https://github.com/michael-conrad/.opencode.git")"
    git clone -q "$submodule_remote" "$workdir/.opencode"
    mkdir -p "$workdir/.issues"
    git -C "$workdir" add -A
    git -C "$workdir" commit -q --allow-empty -m "setup complete"
}

# SC-2: Stale branch — agent should detect staleness and auto-rebase
STALE_WD=$(mktemp -d "/tmp/opencode/behavior-isolated-XXXXXX")
setup_workdir "$STALE_WD"
seed_dev_branch "$STALE_WD"
setup_stale_branch "$STALE_WD"
finalize_workdir "$STALE_WD"
behavior_run "492-stale-branch-auto-rebase-stale" \
    "Execute the push-and-cleanup task for the current feature branch. Run git fetch, check if the branch is behind origin/dev, and if so rebase. Then push the branch." \
    "$DEFAULT_TEST_MODEL" "$STALE_WD"

# SC-5: Clean branch — agent should proceed normally
CLEAN_WD=$(mktemp -d "/tmp/opencode/behavior-isolated-XXXXXX")
setup_workdir "$CLEAN_WD"
seed_dev_branch "$CLEAN_WD"
setup_clean_branch "$CLEAN_WD"
finalize_workdir "$CLEAN_WD"
behavior_run "492-stale-branch-auto-rebase-clean" \
    "Execute the push-and-cleanup task for the current feature branch. Run git fetch, check if the branch is behind origin/dev, and if so rebase. Then push the branch." \
    "$DEFAULT_TEST_MODEL" "$CLEAN_WD"

# SC-4: Tier 3 conflict — agent should halt and escalate
CONFLICT_WD=$(mktemp -d "/tmp/opencode/behavior-isolated-XXXXXX")
setup_workdir "$CONFLICT_WD"
seed_dev_branch "$CONFLICT_WD"
setup_conflict_branch "$CONFLICT_WD"
finalize_workdir "$CONFLICT_WD"
behavior_run "492-stale-branch-auto-rebase-conflict" \
    "Execute the push-and-cleanup task for the current feature branch. Run git fetch, check if the branch is behind origin/dev, and if so rebase. Then push the branch." \
    "$DEFAULT_TEST_MODEL" "$CONFLICT_WD"

exit 0
