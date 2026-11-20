#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated (.opencode#2753 behavioral scenarios)
#
# Shared fixture (.opencode#2753 scenarios): a parent+submodule release family.
# Layout, inside the test home:
#   <test-home>/remote-family/doaj.git    — bare submodule origin (master @ 2 commits)
#   <test-home>/remote-family/parent.git  — bare parent origin
#   <workdir>                             — the parent repo (test project), origin remote set
#
# The per-scenario setup scripts call setup_2753_family_base "$wd" first
# (family provisioning), then stage their scenario-specific drift/tamper.
#
# Determinism guards: re-sourcing (attempt-2 re-source after empty-output
# retry) is a no-op when the family markers already exist.
#
# Pre-supplied facts (tests-v2 AGENTS.md §3a): the trunk tip and the stale
# recorded pointer are written to <workdir>/.fixture-trunk-tip and
# <workdir>/.fixture-stale-pointer so the run agent never has to derive them.

setup_2753_family_base() {
    local wd="$1"
    local home
    home="$(dirname "$wd")"
    local rem="$home/remote-family"

    mkdir -p "$rem"
    # Rebuild unconditionally: bare remotes persist across invocations under
    # the project's tmp/; a stale parent.git master rejects the fresh
    # parent-base push with non-fast-forward (observed run-1 exit 128).
    rm -rf "$rem/doaj.git" "$rem/doaj-w" "$rem/parent.git"
    local GITC=(-c user.name=opencode-fixture -c user.email=fixture@local)

    # Submodule origin: bare, master with two commits (base → tip). The bare
    # repos are initialized with -b master: this git (2.53) defaults bare HEAD
    # to main, and a bare HEAD pointing at a nonexistent ref makes every clone
    # of it fail ("does not have a commit checked out") — the run-1 exit-128
    # mechanism.
    git init -q --bare -b master "$rem/doaj.git"
    git init -q "$rem/doaj-w"
    (
        cd "$rem/doaj-w"
        echo "doaj fixture content" > README.md
        git "${GITC[@]}" add README.md
        git "${GITC[@]}" commit -qm "doaj base"
        echo "second line" >> README.md
        git "${GITC[@]}" commit -qam "doaj tip"
        git branch -M master
        git push -q "$rem/doaj.git" master
    )
    local tip stale
    tip="$(git -C "$rem/doaj-w" rev-parse HEAD)"
    stale="$(git -C "$rem/doaj-w" rev-parse HEAD~1)"

    # Parent origin: bare, with the test project pushed as trunk.
    git init -q --bare -b master "$rem/parent.git"

    cd "$wd"
    git remote add origin "$rem/parent.git" 2>/dev/null ||
        git remote set-url origin "$rem/parent.git"
    local base
    base="$(git symbolic-ref --short HEAD)"
    if [ "$base" != "master" ]; then
        git branch -m "$base" master 2>/dev/null || true
    fi
    git "${GITC[@]}" add -A 2>/dev/null || true
    git "${GITC[@]}" commit -qm "parent base" 2>/dev/null || true
    git push -q origin master

    # Register the submodule at its (stale) recorded pointer: gitlink = stale,
    # no .gitmodules branch field. RECORDING IS PLUMBING-ONLY: a normal
    # `git add .gitmodules doaj` re-resolves the gitlink from the submodule
    # checkout HEAD (the tip) and silently reverts the stale recording — the
    # exact .opencode#2753 field failure. The commit is built through a temp
    # index (read-tree → update-index → write-tree → commit-tree), then HEAD
    # and the real index are moved to it with `reset --mixed` (keeps the
    # checkout, which is at the stale SHA — index, HEAD tree, and checkout
    # agree).
    # Provision the doaj checkout (clone at the tip). The stale recording
    # below is made by the plumbing commit — the checkout's position is left
    # to each scenario's own staging.
    if [ ! -e "$wd/doaj/.git" ]; then
        git -C "$wd" clone -q "$rem/doaj.git" doaj
        git -C "$wd/doaj" remote set-url origin "$rem/doaj.git"
    fi
    if ! git -C "$wd" config --file .gitmodules --get-regexp '^submodule\."doaj"' >/dev/null 2>&1; then
        # The cloned parent already carries a .gitmodules (registering
        # .opencode) — append the doaj entry rather than create the file.
        printf '[submodule "doaj"]\n\tpath = doaj\n\turl = %s\n' "$rem/doaj.git" >> "$wd/.gitmodules"
        local gm_blob head_sha tree new_commit
        gm_blob="$(git -C "$wd" hash-object -w "$wd/.gitmodules")"
        head_sha="$(git -C "$wd" rev-parse HEAD)"
        export GIT_INDEX_FILE="$wd/.git/fixture-index"
        git -C "$wd" read-tree "$head_sha"
        git -C "$wd" update-index --add --cacheinfo 100644,"$gm_blob",.gitmodules
        git -C "$wd" update-index --add --cacheinfo 160000,"$stale",doaj
        tree="$(git -C "$wd" write-tree)"
        new_commit="$(echo "record doaj at stale pointer $stale" | git -c user.name=opencode-fixture -c user.email=fixture@local commit-tree "$tree" -p "$head_sha")"
        unset GIT_INDEX_FILE
        rm -f "$wd/.git/fixture-index"
        git -C "$wd" reset -q --mixed "$new_commit"
    fi

    # Pre-supplied facts for the run agent (never derived from zero).
    printf 'trunk-tip=%s\n' "$tip" > "$wd/.fixture-trunk-tip"
    printf 'stale-pointer=%s\n' "$stale" > "$wd/.fixture-stale-pointer"
    touch "$wd/.fixture-family-ready"
    return 0
}

# Detached-lookup helper: read a fact file's value.
fixture_fact() {
    sed -n "s/^$1=//p" "$2"
}
