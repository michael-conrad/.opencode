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

    # Create a local-only commit inside the .opencode submodule (NOT pushed to origin).
    git -C "$sub" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$sub" config user.name "Test" 2>/dev/null || true
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
