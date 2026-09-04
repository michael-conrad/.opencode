#!/bin/bash
# Per-scenario fixture: set up a feature branch with two real source changes so the
# agent can perform two WIP implementation commits and then prepare for PR creation.
#
# The parent repo gets a bare origin (so it is a normal remote-tracking repo, not
# local-only) and a feature branch with src/feature-a.txt and src/feature-b.txt added.
# The agent reads the git-workflow-commit implementation procedure, commits each feature
# as its own WIP commit, then prepares for PR creation via review-prep and pr-creation.
#
# RED phase: the commit-count sources conflict. 000-critical-rules.md:173 states
# "one commit per issue" while implementation.md:105-115 permits multiple implementation
# commits during dev, and review-prep.md:45-75 forces squash to exactly one commit at
# review-prep (BEFORE PR creation). So the agent may squash during development
# (SC-2a FAILS) and may squash at review-prep rather than deferring to PR creation
# (SC-2b FAILS).

setup_commit_count_squash_timing() {
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

    # Create the feature branch for the two-feature implementation scenario.
    git -C "$wd" checkout -b feature/commit-count-squash-timing 2>/dev/null || true

    # Add two real source changes to commit as separate WIP commits.
    mkdir -p "$wd/src"
    echo "feature a content $(date +%s)" > "$wd/src/feature-a.txt"
    echo "feature b content $(date +%s)" > "$wd/src/feature-b.txt"
    git -C "$wd" add src/feature-a.txt src/feature-b.txt 2>/dev/null || true
}

setup_commit_count_squash_timing "$1"
