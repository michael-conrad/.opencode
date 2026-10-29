#!/bin/bash
# Per-scenario fixture for 2683-sc5-pointer-capture-tagged-sha.
#
# The harness clones the parent project and wires the GitBucket test repo as
# the PARENT's origin (pushable, PR-creatable). The .opencode submodule inside
# the attempt workdir still points its origin at the production remote URL
# (from the cloned .gitmodules) — the tagged-SHA discipline requires pushing a
# discipline tag to the submodule's own remote, and production remotes are
# never a test target. This fixture:
#   1. seeds a sandbox bare remote with the submodule's current commit
#      (pushed to its main branch so origin/main is genuinely reachable);
#   2. rewires the submodule's origin to that bare remote;
#   3. ensures the submodule is on its main branch at the trunk tip.
#
# BARE-REMOTE PLACEMENT (fixture revision, run 2 2026-10-29): the attempt
# workdir's per-attempt staging sibling (`tmp/behavior-isolated-*/`) is
# deleted after staging, so a bare remote seeded there dies with it —
# observed live as the run agent's origin URL pointing at a nonexistent path
# (environment-discovery defect). The bare lives at a FIXED project-tmp path
# (tmp/submodule-origin-2683-sc5.git): stable across staging moves, visible
# to the tier-2 container at the same absolute path (only tmp/ is mounted).
# Fixture failures are loud — no silent swallowing: a seed failure aborts the
# run before the model starts, per the pre-supplied-environment mandate.

setup_2683_sc5() {
    local wd="$1"
    local sub="$wd/.opencode"
    local root
    root="$(cd "$wd/../.." && pwd -P)"   # project root (tmp/ parent)
    local bare="$root/tmp/submodule-origin-2683-sc5.git"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true
    git -C "$sub" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$sub" config user.name "Test" 2>/dev/null || true

    # 1. Fresh sandbox submodule remote (delete stale state from prior runs).
    rm -rf "$bare"
    git init -q --bare "$bare" || return 1
    git -C "$sub" push -q "$bare" HEAD:refs/heads/main || {
        echo "HARNESS_FAILURE: 2683-sc5 fixture could not seed the sandbox submodule remote at $bare" >&2
        return 1
    }

    # 2. Rewire the submodule's origin away from the clone's inherited URL.
    if git -C "$sub" remote get-url origin >/dev/null 2>&1; then
        git -C "$sub" remote set-url origin "$bare" || return 1
    else
        git -C "$sub" remote add origin "$bare" || return 1
    fi

    # 3. Verify the wired origin is genuinely reachable before the model runs.
    git -C "$sub" fetch -q origin || {
        echo "HARNESS_FAILURE: 2683-sc5 fixture — rewired submodule origin not fetchable ($bare)" >&2
        return 1
    }
    git -C "$sub" checkout -q -B main || return 1
    git -C "$sub" reset -q --hard origin/main || return 1

    # 4. Baseline drift (fixture revision, run 3 2026-10-29): the harness pins
    #    the submodule checkout to the effective commit AND pre-records that
    #    SHA as the parent's gitlink before fixtures run — zero drift, the
    #    agent's "sync + capture" collapses to a no-op and the PR carries no
    #    bump (observed live, run 3). Move the parent's recorded pointer to a
    #    deep ancestor of the submodule tip (committed and pushed) so the run
    #    agent performs the actual capture: sync forward, record the tip,
    #    push the branch — the real boundary state the scenario tests.
    local ancestor
    ancestor="$(git -C "$sub" rev-parse HEAD~40)" || return 1
    git -C "$wd" add .opencode || return 1
    git -C "$wd" update-index --cacheinfo 160000 "$ancestor" .opencode || {
        echo "HARNESS_FAILURE: 2683-sc5 fixture — could not stage ancestor gitlink $ancestor" >&2
        return 1
    }
    git -C "$wd" commit -q -m "chore: baseline stale submodule pointer (scenario boundary state)" || return 1
    if git -C "$wd" remote get-url origin >/dev/null 2>&1; then
        git -C "$wd" push -q origin main:main || {
            echo "HARNESS_FAILURE: 2683-sc5 fixture — could not push the drift-baseline commit to origin" >&2
            return 1
        }
    fi
}

setup_2683_sc5 "$1"