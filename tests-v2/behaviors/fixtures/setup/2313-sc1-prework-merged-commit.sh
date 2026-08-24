#!/bin/bash
# Per-scenario fixture: give the parent repo a real origin remote (bare repo with main
# pushed) so the pre-work trunk-tip-verification gate runs as a normal remote-tracking
# repo and reaches step 8 (the merged-commit check). The .opencode submodule keeps its
# real reachable origin; its committed pointer references a local-only commit (a commit
# that exists in the submodule working tree but is NOT on the submodule's remote
# origin/main).
#
# The reachability check `git merge-base --is-ancestor <local_only_sha> origin/main`
# against the submodule's real reachable origin correctly returns non-zero (not an
# ancestor) -> step 8 returns BLOCKED with SUBMODULE_UNMERGED_COMMIT.
#
# Without a parent remote, the agent classifies the repo as local-only and skips the
# remote-dependent checks (steps 3, 6) before reaching step 8's merge-base check, so
# the merged-commit gate never fires. RED phase: the current trunk-tip-verification.md
# has NO merged-commit check (only 7 checks), so the agent will NOT run
# `git merge-base --is-ancestor` and will NOT block with SUBMODULE_UNMERGED_COMMIT —
# the test FAILS (RED).

setup_sc1_parent_origin() {
    local wd="$1"
    local sub="$wd/.opencode"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    # Create a bare origin for the parent repo and push main to it, so session-init
    # reports a remote-tracking repo (not local-only) and the agent runs the full
    # 8-step trunk-tip-verification gate.
    local bare="$wd/../origin.git"
    git init -q --bare "$bare" 2>/dev/null || true
    git -C "$wd" remote add origin "$bare" 2>/dev/null || true
    git -C "$wd" push -q -u origin main 2>/dev/null || true

    # Create a local-only commit inside the .opencode submodule (NOT pushed to origin).
    # The submodule keeps its real origin (reachable from the harness test home), so
    # step 8's reachability check runs against the live remote and correctly reports
    # the local-only commit as NOT an ancestor of origin/main.
    git -C "$sub" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$sub" config user.name "Test" 2>/dev/null || true
    local marker="$sub/SC1-LOCAL-ONLY-MARKER"
    echo "sc1 local-only commit $(date +%s)" > "$marker"
    git -C "$sub" add -A 2>/dev/null || true
    git -C "$sub" commit -q -m "chore: local-only commit for SC-1 merged-commit gate" 2>/dev/null || true

    # Update the parent repo's submodule pointer to the local-only commit and commit it
    # so the pre-work gate sees a committed gitlink SHA referencing an unmerged
    # (local-only) commit.
    git -C "$wd" add .opencode 2>/dev/null || true
    git -C "$wd" commit -q -m "chore: point .opencode submodule to local-only commit for SC-1 trunk-tip gate" 2>/dev/null || true

    # Push main to origin AFTER the pointer change so step 3 (parent remote tracking
    # match) passes and the agent reaches step 8 (the merged-commit check). If main is
    # pushed only before the pointer change, origin/main is stale relative to local main
    # and step 3 blocks before step 8's merge-base check ever runs.
    git -C "$wd" push -q origin main 2>/dev/null || true
}

setup_sc1_parent_origin "$1"
