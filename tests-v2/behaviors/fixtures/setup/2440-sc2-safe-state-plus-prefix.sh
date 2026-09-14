#!/bin/bash
# Per-scenario fixture (issue 2440, SC-2): give the parent repo a real origin
# remote (bare repo with main pushed AFTER the pointer commit, per the
# 2440-sc1 fixture pattern) so the pre-work trunk-tip-verification gate runs as
# a normal remote-tracking repo, and give the .opencode submodule the SAFE
# `+`-prefix pointer state:
#
#   - submodule checkout is at the submodule's own origin/main tip (a merged commit)
#   - the parent's committed gitlink pointer references the PREVIOUS commit
#     (origin/main^ — also merged on the submodule remote)
#
# so `git submodule status` shows the `+` prefix and `git status` shows
# ` M .opencode` purely from the pointer/checkout mismatch — the checkout is a
# merged remote-trunk commit and the committed pointer is also merged. This is
# the SAFE state SC-2 requires the gate to classify as
# submodule_pointer_match: WARN with gate status DONE (not BLOCKED/failure).
#
# RED phase note: if the current trunk-tip-verification.md already classifies
# the safe-state `+` prefix as WARN (SC-1 GREEN edit eaeba061 covered checks
# 4/6/7), the run verdict against SC-2 is ALREADY_GREEN — the scenario still
# runs to record the evidence.

setup_2440_sc2_safe_state() {
    local wd="$1"
    local sub="$wd/.opencode"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    # Rewire the submodule's origin to a local bare whose main = the feature
    # branch tip. The safe-state predicate requires the submodule checkout to
    # sit at the submodule's origin/main tip — but the card change under test
    # lives on the feature branch, and the real remote's main predates it. A
    # local submodule origin with main = feature tip makes the checkout both
    # (a) at origin/main tip (safe state) and (b) in possession of the updated
    # card. The stable absolute path survives the with-test-home workdir move.
    local sub_bare
    sub_bare="$(cd "$wd/../.." && pwd)/tmp/origin-2440-sc2-sub.git"
    rm -rf "$sub_bare"
    git init -q --bare "$sub_bare" 2>/dev/null || true
    git -C "$sub" remote remove origin 2>/dev/null || true
    git -C "$sub" remote add origin "$sub_bare" 2>/dev/null || true
    if ! git -C "$sub" push -q origin HEAD:refs/heads/main 2>/dev/null; then
        echo "FIXTURE_FAILURE: 2440-sc2 — submodule push to $sub_bare failed" >&2
        return 1
    fi

    # Fetch the submodule remote and resolve the SAFE commit pair: the submodule
    # checkout target is the submodule's origin/main tip (merged commit); the
    # committed parent pointer is its parent (origin/main^ — also merged).
    git -C "$sub" fetch -q origin main 2>/dev/null || true
    local main_tip
    main_tip="$(git -C "$sub" rev-parse origin/main 2>/dev/null)" || return 0
    local prev_commit
    prev_commit="$(git -C "$sub" rev-parse origin/main^ 2>/dev/null)" || return 0

    # Create a bare origin for the parent repo and push main to it, so
    # session-init reports a remote-tracking repo (not local-only) and the agent
    # runs the full remote-tracking trunk-tip gate (mirrors 2440-sc1).
    # The bare MUST live at a stable absolute path OUTSIDE the attempt workdir:
    # with-test-home MOVES the workdir into the test home (helpers/with-test-home),
    # so any origin URL pointing into tmp/behavior-isolated-* breaks after the move.
    # tmp/ is stable for the duration of the run. Remove any stale bare first so a
    # leftover from a prior run cannot mask a failed push.
    local bare
    bare="$(cd "$wd/../.." && pwd)/tmp/origin-2440-sc2.git"
    rm -rf "$bare"
    git init -q --bare "$bare" 2>/dev/null || true
    git -C "$wd" remote remove origin 2>/dev/null || true
    git -C "$wd" remote add origin "$bare" 2>/dev/null || true

    # Step 1: move the submodule checkout to the previous commit and commit that
    # as the parent's gitlink pointer, so the committed pointer references a
    # commit merged on the submodule remote.
    git -C "$sub" checkout -q "$prev_commit" 2>/dev/null || true
    git -C "$wd" add .opencode 2>/dev/null || true
    git -C "$wd" commit -q -m "chore: point .opencode submodule to merged commit for SC-2 safe-state gate" 2>/dev/null || true

    # Step 2: push main to origin AFTER the pointer change so step 3 (parent
    # remote tracking match) passes and the agent reaches the pointer checks.
    # Loud failure — a silently swallowed push error would leave the agent with
    # zero reachable parent remotes.
    if ! git -C "$wd" push -q -u origin main 2>/dev/null; then
        echo "FIXTURE_FAILURE: 2440-sc2 — parent push to bare origin $bare failed" >&2
        return 1
    fi

    # Step 3: move the submodule checkout to the submodule's origin/main tip.
    # The parent's committed gitlink still references origin/main^, so
    # `git submodule status` shows the `+` prefix in the SAFE way
    # (`+` prefix / ` M .opencode`) with both commits merged on the submodule
    # remote.
    git -C "$sub" checkout -q "$main_tip" 2>/dev/null || true
}

setup_2440_sc2_safe_state "$1"
