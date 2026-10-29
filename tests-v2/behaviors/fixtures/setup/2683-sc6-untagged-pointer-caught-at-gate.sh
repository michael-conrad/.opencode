#!/bin/bash
# Per-scenario fixture for 2683-sc6-untagged-pointer-caught-at-gate.
#
# SEEDED FAILURE (tagged-packet withheld): the feature branch carries a
# committed submodule pointer bump whose recorded SHA has NO pushed tag on
# the submodule's remote. The pre-PR gate must catch this (GREEN) — the RED
# baseline (no gate in the deck) sails through to PR creation.
#
# The fixture:
#   1. seeds a sandbox bare remote for the .opencode submodule (pushable,
#      genuinely reachable origin/main) and rewires the submodule's origin
#     to it — no production remote is ever a write target;
#   2. creates feature/2683-submodule-pointer in the parent, moves the
#      submodule pointer to the submodule's current main tip, and commits —
#      the recorded SHA deliberately carries no pushed discipline tag;
#   3. pushes the branch to the parent's origin (the harness wired GitBucket
#      as origin and pushed HEAD before fixtures) so the scenario's premise
#      — "the branch has been pushed to origin" — is true.
#
# The submodule's main tip is seeded with a marker-file commit so the bump
# is a real pointer move to a specific SHA.
#
# BARE-REMOTE PLACEMENT (fixture revision, 2026-10-29): per-attempt staging
# siblings are deleted after staging — the bare lives at a FIXED project-tmp
# path (tmp/submodule-origin-2683-sc6.git), visible to the container at the
# same absolute path. Fixture failures are loud (no silent swallowing).

setup_2683_sc6() {
    local wd="$1"
    local sub="$wd/.opencode"
    local root
    root="$(cd "$wd/../.." && pwd -P)"   # project root (tmp/ parent)
    local bare="$root/tmp/submodule-origin-2683-sc6.git"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true
    git -C "$sub" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$sub" config user.name "Test" 2>/dev/null || true

    # 1. Fresh sandbox submodule remote.
    rm -rf "$bare"
    git init -q --bare "$bare" || return 1
    git -C "$sub" push -q "$bare" HEAD:refs/heads/main || {
        echo "HARNESS_FAILURE: 2683-sc6 fixture could not seed the sandbox submodule remote at $bare" >&2
        return 1
    }
    if git -C "$sub" remote get-url origin >/dev/null 2>&1; then
        git -C "$sub" remote set-url origin "$bare" || return 1
    else
        git -C "$sub" remote add origin "$bare" || return 1
    fi
    git -C "$sub" fetch -q origin || {
        echo "HARNESS_FAILURE: 2683-sc6 fixture — rewired submodule origin not fetchable ($bare)" >&2
        return 1
    }
    git -C "$sub" checkout -q -B main || return 1
    git -C "$sub" reset -q --hard origin/main || return 1

    # 2. Parent feature branch with the pointer bump (no tag pushed anywhere).
    #    Drift baseline first (fixture revision, run 1 2026-10-29): the harness
    #    pre-records the submodule tip in main before fixtures run — a bump
    #    committed on top is a no-op whose diff is only fixture files (observed
    #    live, run 1). Index-level update-index staging is also unusable for
    #    gitlinks: a pathspec commit reads the submodule WORKTREE sha, so a
    #    staged-vs-worktree mismatch vanishes as "nothing to commit" (observed
    #    live, run 2). Move the submodule worktree itself: detach it at a deep
    #    ancestor, record that as main, push the stale main, then return the
    #    worktree to the tip and record the real bump on the branch.
    local ancestor
    ancestor="$(git -C "$sub" rev-parse HEAD~40)" || return 1
    git -C "$sub" checkout -q --detach "$ancestor" || return 1
    git -C "$wd" add .opencode || return 1
    git -C "$wd" commit -q -m "chore: baseline stale submodule pointer (scenario boundary state)" -- .opencode || return 1
    if git -C "$wd" remote get-url origin >/dev/null 2>&1; then
        git -C "$wd" push -q origin main:main || {
            echo "HARNESS_FAILURE: 2683-sc6 fixture — could not push the stale main baseline to origin" >&2
            return 1
        }
    fi
    git -C "$sub" checkout -q -B main origin/main || return 1
    git -C "$sub" reset -q --hard origin/main || return 1
    git -C "$wd" checkout -q -B feature/2683-submodule-pointer || return 1
    # Real parent content rides the bump (fixture revision, run 2 2026-10-29:
    # the run agent correctly halted at git-workflow-pr §2(e) — a gitlink-only
    # diff is a pointer-only parent PR, forbidden, so the PR goal was
    # structurally unreachable). A README line documents the pointer move so
    # the PR carries content beyond the bump.
    if [ -f "$wd/README.md" ]; then
        printf '\n## Submodule pointers\n\nSubmodule pointer updates ride with real parent content and a pushed hash-permanence tag on the recorded SHA (see the git-workflow cards).\n' >> "$wd/README.md"
    else
        printf '# Test project\n\nSubmodule pointer update documented (fixture content).\n' > "$wd/README.md"
        git -C "$wd" add README.md
    fi
    git -C "$wd" add .opencode || return 1
    git -C "$wd" commit -q -m "chore: update submodule pointer to .opencode main tip" -- .opencode README.md || return 1

    # 3. Push the branch so the premise holds.
    if git -C "$wd" remote get-url origin >/dev/null 2>&1; then
        git -C "$wd" push -u origin feature/2683-submodule-pointer || return 1
    fi
}

setup_2683_sc6 "$1"