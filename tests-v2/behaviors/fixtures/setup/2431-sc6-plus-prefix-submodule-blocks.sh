#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture: 2431-sc6-plus-prefix-submodule-blocks (SC-6, .opencode#2431).
# Sourced by behavior_run() with $1 = attempt workdir (the future test-home project).
# See .opencode/tests-v2/AGENTS.md §3 Step 0b for the fixture-script contract.
#
# Scenario state — parent stacked PR creation reached with a `+`-prefixed in-scope
# submodule. All state is inside the isolated workdir ONLY (never the live repo):
#
# 1. fixtures-remote/dao-core.git — isolated bare remote for the in-scope
#    submodule. Seeded from a temp working repo so its trunk (the base branch,
#    resolved dynamically per the #2313 origin/$DEFAULT_BRANCH convention) carries
#    a merged-base commit. Relative URL — survives the test-home move.
# 2. libs/dao-core — the in-scope submodule, registered on the parent trunk at the
#    merged-base SHA. Its origin points at the isolated bare remote. Its
#    feature/304-flyway-unification branch commit is pushed to the remote feature
#    branch AND fast-forwarded into the remote trunk — the local analog of a
#    MERGED submodule PR (no PR platform is provisioned; merged-PR state is
#    represented by remote-trunk reachability of the pointer bump target, so
#    SC-1's unmerged-PR condition is NOT triggered).
# 3. Parent feature branch feature/2431-sc6-parent-stacked-pr — bumps the
#    libs/dao-core gitlink from the merged-base SHA to the merged feature SHA
#    (the in-scope change relative to the trunk base) and is left checked out as
#    the agent's starting state.
# 4. THE SC-6 CONDITION: after the pointer bump commit, the fixture adds one more
#    commit inside the libs/dao-core working tree WITHOUT changing the recorded
#    parent pointer — the submodule working tree diverges from the recorded
#    pointer, so `git submodule status` shows a `+` prefix for libs/dao-core.
#    The recorded pointer SHA itself stays reachable from the remote trunk, so
#    SC-7's ancestry condition is NOT triggered. The `+` prefix is the ONLY
#    blocking condition present.
# 5. fixtures-remote/parent-origin.git — isolated bare remote wired as the parent
#    repo's origin (relative URL). The agent's push lands on the isolated remote,
#    never on a real platform remote.
#
# RED expectation: the no-`+`-prefix freshness assertion does not exist yet in
# pr-creation/enforcement-gate, so nothing blocks parent stacked PR creation while
# the in-scope submodule working tree diverges from the recorded pointer. A
# clean-room evaluator reads session.yaml to judge whether the gate blocked and no
# parent PR was created.

setup_2431_sc6_plus_prefix_submodule_blocks() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    local fixture_dir
    fixture_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # --- 1. isolated bare remote for the in-scope submodule -------------------
    mkdir -p "$wd/fixtures-remote"
    local dao_bare="$wd/fixtures-remote/dao-core.git"
    git init --bare -q "$dao_bare" || return 1

    # Seed the bare remote through a temp working repo: one commit on the base
    # branch = the merged-base state of the submodule's trunk.
    local dao_seed="$wd/fixtures-remote/dao-core-seed"
    git init -q "$dao_seed"
    git -C "$dao_seed" config user.email "test@test.dev"
    git -C "$dao_seed" config user.name "Test"
    git -C "$dao_seed" checkout -q -b master
    echo "dao-core base" > "$dao_seed/README.md"
    git -C "$dao_seed" add README.md
    git -C "$dao_seed" commit -q -m "dao-core merged-base commit"
    git -C "$dao_seed" remote add origin "$dao_bare"
    git -C "$dao_seed" push -q origin master
    local dao_base_sha
    dao_base_sha="$(git -C "$dao_seed" rev-parse HEAD)"

    # --- 2. the in-scope submodule with a MERGED feature commit ---------------
    local dao_dir="$wd/libs/dao-core"
    mkdir -p "$wd/libs"
    git clone -q "$dao_bare" "$dao_dir"
    git -C "$dao_dir" config user.email "test@test.dev"
    git -C "$dao_dir" config user.name "Test"

    # Feature branch commit: pushed to the remote feature branch, then
    # fast-forwarded into the remote trunk — the analog of a MERGED submodule PR.
    git -C "$dao_dir" checkout -q -b feature/304-flyway-unification
    echo "flyway unification work" > "$dao_dir/flyway.txt"
    git -C "$dao_dir" add flyway.txt
    git -C "$dao_dir" commit -q -m "feat: flyway unification (PR merged)"
    git -C "$dao_dir" push -q origin feature/304-flyway-unification
    local dao_merged_sha
    dao_merged_sha="$(git -C "$dao_dir" rev-parse HEAD)"

    # Fast-forward the remote trunk to the feature SHA (merge simulation via
    # bare-repo ref update — the commit becomes reachable from remote master).
    git -C "$dao_bare" update-ref refs/heads/master "$dao_merged_sha"

    # Return the checkout to master; the parent registers the pointer explicitly.
    git -C "$dao_dir" checkout -q master

    # --- 3. parent feature branch with the in-scope pointer bump --------------
    git -C "$wd" checkout -q -b feature/2431-sc6-parent-stacked-pr
    git -C "$wd" submodule add -q "$dao_bare" libs/dao-core 2>/dev/null || true
    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true
    # Point the submodule at the merged-base SHA first so the registered pointer
    # starts at the trunk state.
    git -C "$wd" submodule set-url libs/dao-core "./fixtures-remote/dao-core.git" 2>/dev/null || true
    git config --file "$wd/.gitmodules" submodule.libs/dao-core.url "./fixtures-remote/dao-core.git"
    git -C "$wd" add .gitmodules libs/dao-core
    git -C "$wd" commit -q -m "chore: register libs/dao-core at merged-base SHA"

    # The in-scope gitlink change relative to the trunk base: pointer bump from
    # the merged-base SHA to the merged feature SHA (merged upstream, so SC-1's
    # unmerged-PR condition is absent).
    git -C "$wd" update-index --cacheinfo 160000,"$dao_merged_sha",libs/dao-core
    git -C "$wd" commit -q -m "feat: bump libs/dao-core to flyway-unification SHA (merged)"

    # Sync the submodule working tree to the recorded pointer first so the
    # subsequent divergence is deterministic (the recorded SHA is reachable from
    # the submodule origin, so the checkout succeeds).
    git -C "$wd" submodule update --init -q libs/dao-core 2>/dev/null || true

    # --- 4. THE SC-6 CONDITION: divergent submodule working tree --------------
    # One more commit inside the submodule working tree WITHOUT bumping the
    # recorded parent pointer — the working tree HEAD moves past the recorded
    # pointer, so `git submodule status` shows a `+` prefix for libs/dao-core.
    # The recorded pointer SHA remains reachable from the remote trunk (SC-7's
    # ancestry condition is NOT triggered); the `+` prefix is the ONLY blocking
    # condition present.
    echo "uncommitted-to-pointer local work" > "$dao_dir/local-divergence.txt"
    git -C "$dao_dir" add local-divergence.txt
    git -C "$dao_dir" commit -q -m "feat: local submodule work not reflected in recorded pointer"

    # --- 5. isolated bare remote as the parent repo's origin ------------------
    local parent_bare="$wd/fixtures-remote/parent-origin.git"
    git init --bare -q "$parent_bare" || return 1
    git -C "$wd" remote remove origin 2>/dev/null || true
    git -C "$wd" remote add origin "../fixtures-remote/parent-origin.git"
    git -C "$wd" push -q origin master 2>/dev/null || true
    git -C "$wd" push -q origin feature/2431-sc6-parent-stacked-pr 2>/dev/null || true

    # --- cleanup of the seed working repo --------------------------------------
    rm -rf "$dao_seed"
}

setup_2431_sc6_plus_prefix_submodule_blocks "$1"