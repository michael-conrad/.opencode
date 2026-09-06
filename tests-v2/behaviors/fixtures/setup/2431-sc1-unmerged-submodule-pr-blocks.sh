#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture: 2431-sc1-unmerged-submodule-pr-blocks (SC-1, .opencode#2431).
# Sourced by behavior_run() with $1 = attempt workdir (the future test-home project).
# See .opencode/tests-v2/AGENTS.md §3 Step 0b for the fixture-script contract.
#
# Scenario state — parent stacked PR creation reached with one in-scope submodule
# PR open (unmerged). All state is inside the isolated workdir ONLY (never the
# live repo):
#
# 1. fixtures-remote/dao-core.git — isolated bare remote for the in-scope
#    submodule. Seeded from a temp working repo so its trunk (the base branch,
#    resolved dynamically per the #2313 origin/$DEFAULT_BRANCH convention) carries
#    a merged-base commit. Relative URL — survives the test-home move.
# 2. libs/dao-core — the in-scope submodule, registered on the parent trunk at the
#    merged-base SHA. Its origin points at the isolated bare remote. Its
#    feature/304-flyway-unification branch carries a commit that is NOT on the
#    remote trunk — the local analog of an open, unmerged submodule PR (no PR
#    platform is provisioned; open-PR state is represented by the unmerged
#    feature commit on the remote's feature branch).
# 3. Parent feature branch feature/2431-parent-stacked-pr — bumps the
#    libs/dao-core gitlink from the merged-base SHA to the unmerged feature SHA
#    (the in-scope change relative to the trunk base) and is left checked out as
#    the agent's starting state.
# 4. fixtures-remote/parent-origin.git — isolated bare remote wired as the parent
#    repo's origin (relative URL). The agent's push lands on the isolated remote,
#    never on a real platform remote.
#
# RED expectation: the ordering gate does not exist yet in
# pr-creation/enforcement-gate, so nothing blocks parent stacked PR creation while
# the in-scope submodule PR (unmerged feature SHA) is open. A clean-room evaluator
# reads session.yaml to judge whether the gate blocked and no parent PR was created.

setup_2431_sc1_unmerged_submodule_pr_blocks() {
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

    # --- 2. the in-scope submodule with an unmerged feature commit ------------
    local dao_dir="$wd/libs/dao-core"
    mkdir -p "$wd/libs"
    git clone -q "$dao_bare" "$dao_dir"
    git -C "$dao_dir" config user.email "test@test.dev"
    git -C "$dao_dir" config user.name "Test"

    # Feature branch with a commit that is never pushed to the remote trunk —
    # the analog of an open, unmerged submodule PR.
    git -C "$dao_dir" checkout -q -b feature/304-flyway-unification
    echo "flyway unification work" > "$dao_dir/flyway.txt"
    git -C "$dao_dir" add flyway.txt
    git -C "$dao_dir" commit -q -m "feat: flyway unification (PR open, unmerged)"
    git -C "$dao_dir" push -q origin feature/304-flyway-unification
    local dao_feature_sha
    dao_feature_sha="$(git -C "$dao_dir" rev-parse HEAD)"
    # Return the checkout to master; the parent registers the pointer explicitly.
    git -C "$dao_dir" checkout -q master

    # --- 3. parent feature branch with the in-scope pointer bump --------------
    git -C "$wd" checkout -q -b feature/2431-parent-stacked-pr
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
    # the merged-base SHA to the unmerged feature SHA.
    git -C "$wd" update-index --cacheinfo 160000,"$dao_feature_sha",libs/dao-core
    git -C "$wd" commit -q -m "feat: bump libs/dao-core to flyway-unification SHA"

    # Sync the submodule working tree to the recorded pointer so
    # `git submodule status` shows NO `+` prefix — SC-1 isolates the unmerged-PR
    # blocking condition; a `+` prefix would let a GREEN gate block on SC-6's
    # distinct condition instead. The feature SHA is reachable from the submodule
    # origin (its feature branch was pushed), so the checkout succeeds.
    git -C "$wd" submodule update --init -q libs/dao-core 2>/dev/null || true

    # --- 4. isolated bare remote as the parent repo's origin ------------------
    local parent_bare="$wd/fixtures-remote/parent-origin.git"
    git init --bare -q "$parent_bare" || return 1
    git -C "$wd" remote remove origin 2>/dev/null || true
    git -C "$wd" remote add origin "../fixtures-remote/parent-origin.git"
    git -C "$wd" push -q origin master 2>/dev/null || true
    git -C "$wd" push -q origin feature/2431-parent-stacked-pr 2>/dev/null || true

    # --- cleanup of the seed working repo --------------------------------------
    rm -rf "$dao_seed"
}

setup_2431_sc1_unmerged_submodule_pr_blocks "$1"