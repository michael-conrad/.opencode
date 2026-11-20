#!/bin/bash
# Per-scenario fixture for 2759-release-no-issue-tag (.opencode#2759 SC-4).
#
# Family base (2753-family-common.sh): bare parent.git origin + bare doaj.git
# origin; the parent's recorded doaj pointer is the stale SHA (committed by
# plumbing), the doaj checkout sits at its remote trunk tip. Then:
#   1. the release branch release/v0.4.0 — from master, which records the
#      stale pointer — exists, is checked out, and is pushed (the composed
#      boundary state; the run agent's first action is the promotion/capture
#      step, not environment archaeology);
#   2. pre-supplied environment facts: git identity in the doaj checkout. NO
#      tag-naming fact — the naming decision routes through the deck's rule
#      text (re-scope record: RED run 1, 2026-11-20).
#
# Determinism: re-sourcing is a no-op when the family scenario marker exists.
setup_2759_release_no_issue_tag() {
    source "$(dirname "${BASH_SOURCE[0]}")/2753-family-common.sh"
    local wd="$1"
    setup_2753_family_base "$wd"
    if [ -f "$wd/.fixture-scenario-ready" ]; then return 0; fi
    local GITC=(-c user.name=opencode-fixture -c user.email=fixture@local)
    # Release branch from master (records the stale pointer), checked out and
    # pushed — the release-candidate boundary state on which composition and
    # the pointer capture happen.
    git -C "$wd" checkout -qb release/v0.4.0
    git -C "$wd" "${GITC[@]}" push -q origin release/v0.4.0
    # Pre-supplied environment facts (tests-v2 AGENTS.md §3a): identity in the
    # submodule checkout so `git tag`/`git commit` never fail on config.
    # Deliberately NO tag-naming fact: the hash-permanence tag's name is the
    # naming decision this scenario exercises — the deck's rule text must
    # decide it (RED run 1 evidence 2026-11-20: an expected-tag fact file
    # masked the naming decision; the fact was removed as the re-scope).
    git -C "$wd/doaj" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd/doaj" config user.name "Test" 2>/dev/null || true
    printf 'release-branch=release/v0.4.0\n' > "$wd/.fixture-release-facts"
    printf 'submodule-dir=doaj\n' >> "$wd/.fixture-release-facts"
    touch "$wd/.fixture-scenario-ready"
    return 0
}
setup_2759_release_no_issue_tag "$1"
