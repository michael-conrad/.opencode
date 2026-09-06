#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
#
# Per-scenario fixture: 2431-sc7-pointer-absent-from-trunk-blocks (SC-7, .opencode#2431).
# Sourced by behavior_run() with $1 = attempt workdir (the future test-home project).
# See .opencode/tests-v2/AGENTS.md §3 Step 0b for the fixture-script contract.
#
# Scenario state — parent stacked PR creation reached with an in-scope recorded
# pointer referencing a commit absent from the submodule's remote trunk
# `origin/$DEFAULT_BRANCH`. All state is inside the isolated workdir ONLY (never
# the live repo):
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
# 3. Parent feature branch feature/2431-sc7-parent-stacked-pr — bumps the
#    libs/dao-core gitlink from the merged-base SHA to the divergent SHA (the
#    in-scope gitlink change relative to the trunk base) and is left checked out
#    as the agent's starting state.
# 4. THE SC-7 CONDITION: the recorded pointer SHA (the divergent SHA) was created
#    on top of the merged feature SHA and pushed ONLY to a side branch
#    (divergent-post-merge) on the submodule's remote — it is a descendant of the
#    remote trunk head, therefore NOT an ancestor of origin/master. The recorded
#    pointer exists locally in the submodule and is fetchable from its origin,
#    but the commit is NOT contained in the remote trunk
#    (`git merge-base --is-ancestor <pointer> origin/master` fails). The submodule
#    working tree is synced to the recorded pointer, so `git submodule status`
#    shows NO `+` prefix — SC-6's working-tree divergence condition is NOT
#    triggered. The off-trunk pointer ancestry is the ONLY blocking condition
#    present.
# 5. fixtures-remote/parent-origin.git — isolated bare remote wired as the parent
#    repo's origin (relative URL). The agent's push lands on the isolated remote,
#    never on a real platform remote.
#
# RED expectation: the pointer-ancestry freshness assertion does not exist yet in
# pr-creation/enforcement-gate, so nothing blocks parent stacked PR creation while
# the in-scope recorded pointer references a commit absent from
# origin/$DEFAULT_BRANCH. A clean-room evaluator reads session.yaml to judge
# whether the gate blocked and no parent PR was created.

setup_2431_sc7_pointer_absent_from_trunk_blocks() {
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

    # --- 3. THE SC-7 CONDITION: divergent recorded pointer SHA ----------------
    # Commit D on top of the merged feature SHA and push it ONLY to a side
    # branch on the submodule's remote. D is a descendant of the remote trunk
    # head (master = merged feature SHA), therefore NOT an ancestor of
    # origin/master — the recorded parent pointer will reference a commit
    # absent from the remote trunk. The commit stays locally available and
    # remote-fetchable (side branch), so the submodule working tree can be
    # synced to it cleanly (no `+` prefix — SC-6's condition is NOT triggered).
    git -C "$dao_dir" checkout -q -b divergent-post-merge "$dao_merged_sha"
    echo "post-merge pointer state" > "$dao_dir/post-merge-note.txt"
    git -C "$dao_dir" add post-merge-note.txt
    git -C "$dao_dir" commit -q -m "chore: post-merge pointer state (never landed on remote trunk)"
    local dao_divergent_sha
    dao_divergent_sha="$(git -C "$dao_dir" rev-parse HEAD)"
    git -C "$dao_dir" push -q origin divergent-post-merge
    git -C "$dao_dir" checkout -q master

    # --- 4. parent feature branch with the in-scope pointer bump --------------
    git -C "$wd" checkout -q -b feature/2431-sc7-parent-stacked-pr
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
    # the merged-base SHA to the divergent SHA — a commit that is NOT contained
    # in the submodule's remote trunk (SC-7's condition).
    git -C "$wd" update-index --cacheinfo 160000,"$dao_divergent_sha",libs/dao-core
    git -C "$wd" commit -q -m "feat: bump libs/dao-core to post-merge SHA"

    # Sync the submodule working tree to the recorded pointer so
    # `git submodule status` shows NO `+` prefix — SC-7 isolates the
    # pointer-absent-from-trunk blocking condition; a `+` prefix would let a
    # GREEN gate block on SC-6's distinct condition instead. The divergent SHA
    # is reachable from the submodule origin (its side branch was pushed), so
    # the checkout succeeds.
    git -C "$wd" submodule update --init -q libs/dao-core 2>/dev/null || true

    # --- 5. isolated bare remote as the parent repo's origin ------------------
    local parent_bare="$wd/fixtures-remote/parent-origin.git"
    git init --bare -q "$parent_bare" || return 1
    git -C "$wd" remote remove origin 2>/dev/null || true
    git -C "$wd" remote add origin "../fixtures-remote/parent-origin.git"
    git -C "$wd" push -q origin master 2>/dev/null || true
    git -C "$wd" push -q origin feature/2431-sc7-parent-stacked-pr 2>/dev/null || true

    # --- cleanup of the seed working repo --------------------------------------
    rm -rf "$dao_seed"
}

setup_2431_sc7_pointer_absent_from_trunk_blocks "$1"