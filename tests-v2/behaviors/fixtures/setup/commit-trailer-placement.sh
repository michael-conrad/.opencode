#!/bin/bash
# Per-scenario fixture: set up a feature branch with a real source change so the
# agent can perform an implementation commit and then prepare the squash commit.
#
# The parent repo gets a bare origin (so it is a normal remote-tracking repo, not
# local-only) and a feature branch with src/feature.txt added. The agent reads the
# git-workflow-commit implementation and commit-prep procedures and performs an
# implementation commit, then prepares the squash commit message for PR creation.
#
# RED phase: the current .guidelines/commit-workflow.md:23 and
# git-workflow-commit/tasks/commit-prep.md:34 require TWO co-author trailers on EVERY
# implementation commit, contradicting implementation.md:60 and
# implementation-workflow.md:51 which state no trailers during implementation. So the
# agent may add co-author trailers to the implementation commit (SC-1a FAILS) and may
# not reliably add dual trailers to the squashed commit (SC-1b FAILS).

setup_commit_trailer_placement() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    # Create a bare origin for the parent repo and push main to it, so the parent is a
    # normal remote-tracking repo (not local-only) and the agent runs the full
    # implementation commit procedure.
    local bare="$wd/../origin.git"
    git init -q --bare "$bare" 2>/dev/null || true
    git -C "$wd" remote add origin "$bare" 2>/dev/null || true
    git -C "$wd" push -q -u origin main 2>/dev/null || true

    # Create the feature branch for the implementation commit scenario.
    git -C "$wd" checkout -b feature/commit-trailer-placement 2>/dev/null || true

    # Add a real source change to commit.
    mkdir -p "$wd/src"
    echo "feature content $(date +%s)" > "$wd/src/feature.txt"
    git -C "$wd" add src/feature.txt 2>/dev/null || true
}

setup_commit_trailer_placement "$1"
