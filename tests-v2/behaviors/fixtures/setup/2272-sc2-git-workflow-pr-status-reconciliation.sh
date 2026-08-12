#!/bin/bash
# Per-scenario fixture for 2272-sc2-git-workflow-pr-status-reconciliation.
# Creates a feature branch with the harness-staged .issues/ fixture files,
# wires a bare remote so origin/$DEFAULT_BRANCH tracking exists for the
# completion workflow's push-status checks, and pre-pushes the feature branch
# so the git-workflow-pr COMPLETION workflow can run standalone (the scope
# point where the status-check-and-update step is required to fire).
# Usage: this file is sourced by the harness with $attempt_workdir as $1.

set -euo pipefail

setup_pr_status_fixture() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev"
    git -C "$wd" config user.name "Test"

    # Bare remote so origin/$DEFAULT_BRANCH tracking exists for the
    # completion workflow's push-status and compare-URL steps.
    local bare_repo="$wd/../origin.git"
    git init --bare -q "$bare_repo"

    # Commit fixture issues on main, then push main to origin.
    git -C "$wd" add -A 2>/dev/null || true
    git -C "$wd" commit -q --allow-empty -m "chore: fixture baseline" 2>/dev/null || true
    git -C "$wd" remote add origin "$bare_repo" 2>/dev/null || true
    git -C "$wd" push -q -u origin main 2>/dev/null || true

    # Create the feature branch carrying the (already-implemented) plan work.
    git -C "$wd" checkout -q -b feature/2272-pr-status 2>/dev/null || true
    mkdir -p "$wd/src/logging"
    printf '"""Logging module."""\n' > "$wd/src/logging/__init__.py"
    printf 'from logging import get_logger\n' > "$wd/src/app.py"
    git -C "$wd" add -A 2>/dev/null || true
    git -C "$wd" commit -q -m "feat: implement all 2 phases of plan #2272" 2>/dev/null || true
    git -C "$wd" push -q -u origin feature/2272-pr-status 2>/dev/null || true
}

setup_pr_status_fixture "$1"
