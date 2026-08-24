#!/bin/bash
# Per-scenario fixture: give the parent repo a real origin remote (bare repo with main
# pushed) and set up a feature branch 'feature/2313-precommit' with the .opencode
# submodule pointer STAGED (not committed) referencing a local-only commit (a commit
# that exists in the submodule working tree but is NOT on the submodule's remote
# origin/$DEFAULT_BRANCH). The pre-commit merged-commit gate (SC-2) at implementation.md
# step 6 must run `git merge-base --is-ancestor <staged_pointer_sha> origin/$DEFAULT_BRANCH`
# against the submodule's reachable origin and block the commit with a clear error.
#
# The submodule KEEPS its real origin (reachable from the harness test home). The
# reachability check `git merge-base --is-ancestor <local_only_sha> origin/main` against
# the real reachable origin correctly returns non-zero (not ancestor) -> step 6.e HALT +
# block the commit. The parent bare origin ensures the repo is a normal remote-tracking
# repo (not classified local-only) so the agent runs the full implementation pre-commit
# procedure and reaches step 6's merge-base check on the staged pointer.
#
# RED phase: the current implementation.md Pre-Commit Submodule Pointer Check has NO
# reachability check (step 6 does not exist), so the agent will NOT run
# `git merge-base --is-ancestor` against origin/$DEFAULT_BRANCH and will NOT block the
# commit with the merged-commit message — the test FAILS (RED).

setup_sc2_precommit_local_only_pointer() {
    local wd="$1"
    local sub="$wd/.opencode"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    # Create a bare origin for the parent repo and push main to it, so the parent is a
    # normal remote-tracking repo (not local-only) and the agent runs the full
    # implementation pre-commit procedure that reaches step 6's merged-commit check.
    local bare="$wd/../origin.git"
    git init -q --bare "$bare" 2>/dev/null || true
    git -C "$wd" remote add origin "$bare" 2>/dev/null || true
    git -C "$wd" push -q -u origin main 2>/dev/null || true

    # Create the feature branch for the pre-commit scenario.
    git -C "$wd" checkout -b feature/2313-precommit 2>/dev/null || true

    # Create a local-only commit inside the .opencode submodule (NOT pushed to origin).
    # The submodule keeps its real origin (reachable), so step 6's merge-base reachability
    # check runs against the live remote and correctly reports the local-only commit as
    # NOT an ancestor of origin/main.
    git -C "$sub" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$sub" config user.name "Test" 2>/dev/null || true
    local marker="$sub/SC2-LOCAL-ONLY-MARKER"
    echo "sc2 local-only commit $(date +%s)" > "$marker"
    git -C "$sub" add -A 2>/dev/null || true
    git -C "$sub" commit -q -m "chore: local-only commit for SC-2 pre-commit gate" 2>/dev/null || true

    # Update the parent repo's submodule pointer to the local-only commit and STAGE it
    # (git add, NOT commit) so the implementation pre-commit section sees a newly-staged
    # pointer referencing an unmerged (local-only) commit.
    git -C "$wd" add .opencode 2>/dev/null || true
}

setup_sc2_precommit_local_only_pointer "$1"
