#!/bin/bash
# Per-scenario fixture: make the .opencode submodule pointer reference a local-only
# commit (a commit that exists in the submodule working tree but is NOT on the
# submodule's remote origin/$DEFAULT_BRANCH). The pre-work trunk-tip-verification
# merged-commit gate (SC-1) must detect this and block with SUBMODULE_UNMERGED_COMMIT.
#
# RED phase: the current trunk-tip-verification.md has NO merged-commit check, so the
# agent will NOT run `git merge-base --is-ancestor` against origin/main and will NOT
# block with SUBMODULE_UNMERGED_COMMIT — the test FAILS (RED).

setup_sc1_local_only_submodule_pointer() {
    local wd="$1"
    local sub="$wd/.opencode"

    # Create a local-only commit inside the .opencode submodule (NOT pushed to origin).
    git -C "$sub" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$sub" config user.name "Test" 2>/dev/null || true
    local marker="$sub/SC1-LOCAL-ONLY-MARKER"
    echo "sc1 local-only commit $(date +%s)" > "$marker"
    git -C "$sub" add -A 2>/dev/null || true
    git -C "$sub" commit -q -m "chore: local-only commit for SC-1 merged-commit gate" 2>/dev/null || true

    # Update the parent repo's submodule pointer to the local-only commit.
    git -C "$wd" add .opencode 2>/dev/null || true
    git -C "$wd" commit -q -m "chore: point .opencode submodule to local-only commit" 2>/dev/null || true
}

setup_sc1_local_only_submodule_pointer "$1"
