#!/bin/bash
# Per-scenario fixture: set up a feature branch 'feature/2313-enforcement' with the
# .opencode submodule pointer COMMITTED referencing a local-only commit (a commit that
# exists in the submodule working tree but is NOT on the submodule's remote
# origin/$DEFAULT_BRANCH). The enforcement-gate merged-commit check (SC-3) at PR
# creation Step 0 must detect this and block PR creation with SUBMODULE_PR_MISSING.
#
# RED phase: the current enforcement-gate.md Step 0 only does liveness verification
# (compares committed SHAs against remote trunk HEAD SHAs) — it has NO merged-commit
# reachability check via `git merge-base --is-ancestor` and does NOT block with
# SUBMODULE_PR_MISSING — the test FAILS (RED).

setup_sc3_enforcement_local_only_pointer() {
    local wd="$1"
    local sub="$wd/.opencode"

    # Create the feature branch for the enforcement-gate scenario.
    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true
    git -C "$wd" checkout -b feature/2313-enforcement 2>/dev/null || true

    # Set up a bare remote for the PARENT repo origin so the enforcement-gate can
    # resolve $DEFAULT_BRANCH via `git remote show origin` on the parent repo.
    local parent_origin="$wd/../parent-origin.git"
    git init --bare "$parent_origin" 2>/dev/null || true
    git -C "$wd" remote add origin "$parent_origin" 2>/dev/null || true
    git -C "$wd" push -q -u origin feature/2313-enforcement 2>/dev/null || true

    # Set up a bare remote for the submodule origin representing the MERGED state.
    # The enforcement-gate reachability check runs
    #   git -C <submodule> merge-base --is-ancestor <committed_sha> origin/$DEFAULT_BRANCH
    # so the submodule MUST have an origin whose default branch does NOT contain the
    # local-only commit. Push the submodule's current HEAD (the merged state) to the
    # bare origin as the default branch BEFORE creating the local-only commit.
    git -C "$sub" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$sub" config user.name "Test" 2>/dev/null || true
    local sub_origin="$wd/../sub-origin.git"
    git init --bare "$sub_origin" 2>/dev/null || true
    # The submodule is cloned from the real remote, so origin already exists. Redirect
    # it to the bare repo (set-url, not add) so the reachability check runs against the
    # isolated merged state rather than the live remote.
    git -C "$sub" remote set-url origin "$sub_origin" 2>/dev/null || true
    # HEAD is a detached HEAD (submodule checked out to a specific commit), so the
    # refspec MUST be fully qualified (HEAD:refs/heads/main) — a bare HEAD:main fails
    # with "not a full refname" on a detached HEAD.
    git -C "$sub" push -q -u origin HEAD:refs/heads/main 2>/dev/null || true

    # Create a local-only commit inside the .opencode submodule (NOT pushed to origin).
    local marker="$sub/SC3-LOCAL-ONLY-MARKER"
    echo "sc3 local-only commit $(date +%s)" > "$marker"
    git -C "$sub" add -A 2>/dev/null || true
    git -C "$sub" commit -q -m "chore: local-only commit for SC-3 enforcement-gate merged-commit check" 2>/dev/null || true

    # Update the parent repo's submodule pointer to the local-only commit and COMMIT it
    # so the enforcement-gate Step 0 sees a committed gitlink SHA referencing an
    # unmerged (local-only) commit.
    git -C "$wd" add .opencode 2>/dev/null || true
    git -C "$wd" commit -q -m "chore: point .opencode submodule to local-only commit for SC-3 enforcement-gate" 2>/dev/null || true
}

setup_sc3_enforcement_local_only_pointer "$1"
