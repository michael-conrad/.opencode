#!/bin/bash
# Per-scenario fixture: set up a feature branch 'feature/2313-precommit' with the
# .opencode submodule pointer STAGED (not committed) referencing a local-only commit
# (a commit that exists in the submodule working tree but is NOT on the submodule's
# remote origin/$DEFAULT_BRANCH). The pre-commit merged-commit gate (SC-2) must block
# the commit with a clear error.
#
# RED phase: the current implementation.md Pre-Commit Submodule Pointer Check has NO
# reachability check, so the agent will NOT run `git merge-base --is-ancestor` against
# origin/$DEFAULT_BRANCH and will NOT block the commit — the test FAILS (RED).

setup_sc2_precommit_local_only_pointer() {
    local wd="$1"
    local sub="$wd/.opencode"

    # Create the feature branch for the pre-commit scenario.
    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true
    git -C "$wd" checkout -b feature/2313-precommit 2>/dev/null || true

    # Create a local-only commit inside the .opencode submodule (NOT pushed to origin).
    git -C "$sub" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$sub" config user.name "Test" 2>/dev/null || true
    local marker="$sub/SC2-LOCAL-ONLY-MARKER"
    echo "sc2 local-only commit $(date +%s)" > "$marker"
    git -C "$sub" add -A 2>/dev/null || true
    git -C "$sub" commit -q -m "chore: local-only commit for SC-2 pre-commit gate" 2>/dev/null || true

    # Update the parent repo's submodule pointer to the local-only commit and STAGE it
    # (git add, NOT commit) so the pre-commit section sees a newly-staged pointer.
    git -C "$wd" add .opencode 2>/dev/null || true
}

setup_sc2_precommit_local_only_pointer "$1"
