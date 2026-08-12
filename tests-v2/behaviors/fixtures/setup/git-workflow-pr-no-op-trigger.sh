#!/bin/bash
# Per-scenario fixture for git-workflow-pr-no-op-trigger.
# Creates a feature branch with the harness-staged .issues/ fixture files,
# wires a bare remote so origin/main tracking exists for the merge-base
# ancestry check, and pre-pushes the feature branch so the post-creation
# mergeability check (create-pr.md Step 7.2) can run standalone (the scope
# point where the no-op trigger mechanism lives and where the local
# merge-base check is required to fire).
# Usage: this file is sourced by the harness with $attempt_workdir as $1.

set -euo pipefail

setup_no_op_trigger_fixture() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev"
    git -C "$wd" config user.name "Test"

    # Bare remote so origin/main tracking exists for the merge-base check.
    # Use an ABSOLUTE path: the harness moves the workdir into the test home
    # after this fixture runs, so a relative "$wd/../origin.git" URL would
    # resolve against the moved location and break origin/main resolution.
    local bare_repo="$(cd "$wd/.." && pwd)/origin.git"
    git init --bare -q "$bare_repo"

    # Commit fixture issues on main, then push main to origin.
    git -C "$wd" add -A 2>/dev/null || true
    git -C "$wd" commit -q --allow-empty -m "chore: fixture baseline" 2>/dev/null || true
    git -C "$wd" remote add origin "$bare_repo" 2>/dev/null || true
    git -C "$wd" push -q -u origin main 2>/dev/null || true

    # Create the feature branch carrying the (already-implemented) plan work.
    git -C "$wd" checkout -q -b feature/2267-no-op-trigger 2>/dev/null || true
    echo "# no-op trigger removal work" >> "$wd/README.md"
    git -C "$wd" add -A 2>/dev/null || true
    git -C "$wd" commit -q -m "feat: implement plan #2267" 2>/dev/null || true
    git -C "$wd" push -q -u origin feature/2267-no-op-trigger 2>/dev/null || true
}

setup_no_op_trigger_fixture "$1"
