#!/bin/bash
# Per-scenario fixture (issue 2440, SC-1): give the parent repo a real origin remote
# (bare repo with main pushed AFTER the pointer commit, per the 2313-sc1 fixture
# pattern) so the pre-work trunk-tip-verification gate runs as a normal
# remote-tracking repo, and give the .opencode submodule the SAFE pointer-only
# dirty state:
#
#   - submodule checkout is at the submodule's own origin/main tip (a merged commit)
#   - the parent's committed gitlink pointer references the PREVIOUS commit
#     (origin/main^ — also merged on the submodule remote)
#
# so `git submodule status` shows a `+` prefix and `git status` shows
# ` M .opencode` purely from the pointer/checkout mismatch — the checkout is a
# merged remote-trunk commit and the committed pointer is also merged. This is
# the SAFE state SC-1 requires the gate to classify as parent_clean: WARN with
# gate status DONE (not BLOCKED).
#
# RED phase: the current trunk-tip-verification.md classifies pointer-only dirt
# as failure/BLOCKED, so the agent will report BLOCKED instead of
# DONE-with-WARN — the run verdict is FAIL against the SC-1 criterion.

setup_2440_sc1_safe_state() {
    local wd="$1"
    local sub="$wd/.opencode"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    # Fetch the submodule remote and resolve the SAFE commit pair: the submodule
    # checkout target is the submodule's origin/main tip (merged commit); the
    # committed parent pointer is its parent (origin/main^ — also merged).
    git -C "$sub" fetch -q origin main 2>/dev/null || true
    local main_tip
    main_tip="$(git -C "$sub" rev-parse origin/main 2>/dev/null)" || return 0
    local prev_commit
    prev_commit="$(git -C "$sub" rev-parse origin/main^ 2>/dev/null)" || return 0

    # Step 1: move the submodule checkout to the previous commit and commit that
    # as the parent's gitlink pointer, so the committed pointer references a
    # commit merged on the submodule remote.
    git -C "$sub" checkout -q "$prev_commit" 2>/dev/null || true
    git -C "$wd" add .opencode 2>/dev/null || true
    git -C "$wd" commit -q -m "chore: point .opencode submodule to merged commit for SC-1 safe-state gate" 2>/dev/null || true

    # Step 2: push main to origin AFTER the pointer change so step 3 (parent
    # remote tracking match) passes and the agent reaches the pointer checks.
    git -C "$wd" push -q -u origin main 2>/dev/null || true

    # Step 3: move the submodule checkout to the submodule's origin/main tip.
    # The parent's committed gitlink still references origin/main^, so the
    # submodule pointer is dirty in the SAFE way (`+` prefix / ` M .opencode`)
    # with both commits merged on the submodule remote.
    git -C "$sub" checkout -q "$main_tip" 2>/dev/null || true
}

setup_2440_sc1_safe_state "$1"
