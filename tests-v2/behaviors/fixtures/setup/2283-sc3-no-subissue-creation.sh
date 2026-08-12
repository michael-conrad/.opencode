#!/bin/bash
# Per-scenario fixture for 2283-sc3-no-subissue-creation.
# Creates a feature branch with the harness-staged .issues/ fixture files and
# wires a bare remote so git-workflow pre-work trunk-tip verification passes
# (pre-work BLOCKs on a dirty tree or missing remote tracking).
# Usage: this file is sourced by the harness with $attempt_workdir as $1.

set -euo pipefail

setup_finished_feature_branch() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev"
    git -C "$wd" config user.name "Test"

    # Bare remote so origin/$DEFAULT_BRANCH tracking exists for pre-work.
    local bare_repo="$wd/../origin.git"
    git init --bare -q "$bare_repo"

    # Commit fixture issues on main, then push main to origin.
    git -C "$wd" add -A 2>/dev/null || true
    git -C "$wd" commit -q --allow-empty -m "chore: fixture baseline" 2>/dev/null || true
    git -C "$wd" remote add origin "$bare_repo" 2>/dev/null || true
    git -C "$wd" push -q -u origin main 2>/dev/null || true

    # Create the feature branch carrying the (already-implemented) plan work.
    git -C "$wd" checkout -q -b feature/2283-branch-finish 2>/dev/null || true
    echo "# fully implemented plan work" >> "$wd/README.md"
    git -C "$wd" add -A 2>/dev/null || true
    git -C "$wd" commit -q -m "feat: implement all 4 phases of plan #2283" 2>/dev/null || true
    git -C "$wd" push -q -u origin feature/2283-branch-finish 2>/dev/null || true
}

setup_finished_feature_branch "$1"
