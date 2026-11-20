#!/bin/bash
# Per-scenario fixture for 2759-capture-branch-slug-tag (.opencode#2759 SC-5).
#
# Family base (2753-family-common.sh): bare parent.git origin + bare doaj.git
# origin; the parent's recorded doaj pointer is the stale SHA (committed by
# plumbing), the doaj checkout sits at its remote trunk tip. Then:
#   1. the recording work's branch feature/pointer-capture-scenario — from
#      master, which records the stale pointer — exists, is checked out, and
#      is pushed (the boundary state; the run agent's first action is the
#      sync+capture step, not environment archaeology); the branch carries no
#      issue number and no issue exists anywhere for the work;
#   2. pre-supplied environment facts: git identity in the doaj checkout. NO
#      tag-naming fact (not even the bare slug) — the naming decision routes
#      through the deck's rule text (re-scope grounds recorded on the sibling
#      scenario's run-1 evidence, 2026-11-20).
#
# Determinism: re-sourcing is a no-op when the family scenario marker exists.
setup_2759_capture_branch_slug_tag() {
    source "$(dirname "${BASH_SOURCE[0]}")/2753-family-common.sh"
    local wd="$1"
    setup_2753_family_base "$wd"
    if [ -f "$wd/.fixture-scenario-ready" ]; then return 0; fi
    local GITC=(-c user.name=opencode-fixture -c user.email=fixture@local)
    # Work branch from master (records the stale pointer), checked out and
    # pushed — the branch-before-work boundary state on which the sync and
    # pointer capture happen.
    git -C "$wd" checkout -qb feature/pointer-capture-scenario
    git -C "$wd" "${GITC[@]}" push -q origin feature/pointer-capture-scenario
    # Pre-supplied environment facts (tests-v2 AGENTS.md §3a): identity in the
    # submodule checkout so `git tag`/`git commit` never fail on config.
    # Deliberately NO tag-naming fact (not even the bare slug): the
    # hash-permanence tag's name is the naming decision this scenario
    # exercises — the deck's rule text must decide it (RED run 1 evidence for
    # the sibling scenario, 2026-11-20: an expected-tag fact file masked the
    # naming decision; the fact was removed as the re-scope).
    git -C "$wd/doaj" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd/doaj" config user.name "Test" 2>/dev/null || true
    printf 'work-branch=feature/pointer-capture-scenario\n' > "$wd/.fixture-capture-facts"
    printf 'submodule-dir=doaj\n' >> "$wd/.fixture-capture-facts"
    touch "$wd/.fixture-scenario-ready"
    return 0
}
setup_2759_capture_branch_slug_tag "$1"
