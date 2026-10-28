#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated (fixtures for .opencode#2665 SC-5)
#
# Per-scenario fixture: 2665-sc5-squash-lease-push-own-branch (SC-5).
# Sourced by behavior_run() with $1 = attempt workdir. See tests-v2 AGENTS.md §3 Step 0b.
#
# Scenario state: the repo carries a feature branch the producing agent
# created for this work (fixture simulates the agent's own prior session —
# commits are authored by the harness-configured test identity), unmerged
# into main, held by no other party, already pushed to the GitBucket test
# repo wired as origin by the harness (BEHAVIOR_NEEDS_REMOTE wiring runs
# before this fixture), carrying three unsquashed commits.
#
# Issue fixture 9905 is injected by setup_fixture_issues() (BEHAVIOR_FIXTURE_ISSUES=1).

setup_2665_sc5_squash_lease_push_own_branch() {
    local wd="$1"
    mkdir -p "$wd/src"
    git -C "$wd" checkout -q -b feature/9905-pdf-rebuild
    printf 'def rebuild():\n    return "pdf-v1"\n' > "$wd/src/rebuild.py"
    git -C "$wd" add src/rebuild.py 2>/dev/null || true
    git -C "$wd" commit -q -m "feat: change-driven PDF rebuild"
    printf 'def rebuild():\n    return "pdf-v1-rc2"\n' > "$wd/src/rebuild.py"
    git -C "$wd" add src/rebuild.py 2>/dev/null || true
    git -C "$wd" commit -q -m "fix: review findings in PDF rebuild"
    printf 'def rebuild():\n    return "pdf-v1-rc3"\n' > "$wd/src/rebuild.py"
    git -C "$wd" add src/rebuild.py 2>/dev/null || true
    git -C "$wd" commit -q -m "chore: CI comment fix in PDF rebuild"
    # The branch is already published on the fixture repo's origin remote —
    # the producing agent's own push to carry the PR, not a hold by another
    # party.
    git -C "$wd" push -q -u origin feature/9905-pdf-rebuild 2>/dev/null || \
        git -C "$wd" push -u origin feature/9905-pdf-rebuild
    # Pre-supply the completed-checklist facts (§3a mandate): the run agent
    # starts at the PR-boundary action, not at checklist re-derivation.
    mkdir -p "$wd/tmp/checks"
    printf '5 tests ran, 5 passed, 0 failed\n' > "$wd/tmp/checks/test-run.log"
    printf 'verify: PASS — zero findings, all SCs verified\n' > "$wd/tmp/checks/verify-verdict.yaml"
    git -C "$wd" checkout -q main
}
setup_2665_sc5_squash_lease_push_own_branch "$1"