#!/bin/bash
# Per-scenario fixture: 2320-sc2-enforcement-gate-closure-message
# Sets up the repo state for SC-2's RED behavioral test: a feature branch whose diff is
# submodule-pointer-only (the .opencode submodule pointer is the only change), so the
# enforcement-gate Step 0.5 submodule-bump-only PR gate applies.
#
# The harness provisions the workdir with an `.opencode` submodule and a `.gitmodules`
# entry (helpers.sh behavior_run), then commits an "init" commit that records the gitlink
# (submodule pointer). At that point the gitlink is CLEAN (matches submodule HEAD).
#
# This fixture creates a feature branch and makes a submodule-pointer-only change: it
# advances the submodule's HEAD past the recorded gitlink (a dirty pointer) and commits
# ONLY that pointer change in the parent repo. The branch's diff is then
# submodule-pointer-only — exactly the condition Step 0.5 gates on.
#
# RED expectation: the agent runs the enforcement-gate Step 0.5 check and reads the
# closure message "Submodule SHA already updated by submodule PR merge. No parent PR
# needed." Because the current message does NOT clarify that the pointer still rides
# alongside the next real root change, the agent does NOT record that the pointer rides
# alongside the next real root change (it may claim the pointer was resolved/dropped by
# the submodule merge). A clean-room evaluator reads session.yaml to judge whether the
# agent recorded that the root pointer rides alongside the next real root change.

setup_sc2_submodule_bump_only() {
    local wd="$1"

    # Work on a feature branch so the change is a legitimate feature commit.
    git -C "$wd" checkout -b feature/2320-submodule-bump 2>/dev/null || true

    # Make the .opencode submodule pointer dirty: advance the submodule's HEAD past the
    # recorded gitlink so the parent repo sees a new-commit submodule (dirty pointer).
    if [ -d "$wd/.opencode/.git" ]; then
        git -C "$wd/.opencode" config user.email "test@test.dev" 2>/dev/null || true
        git -C "$wd/.opencode" config user.name "Test" 2>/dev/null || true
        echo "SC-2 submodule-bump-only pointer advance" >> "$wd/.opencode/AGENTS.md"
        git -C "$wd/.opencode" add AGENTS.md 2>/dev/null || true
        git -C "$wd/.opencode" commit -q -m "advance submodule HEAD to dirty the parent pointer" 2>/dev/null || true
    fi

    # Commit ONLY the submodule pointer change in the parent repo, so the branch's diff
    # is submodule-pointer-only (the condition Step 0.5 gates on). The harness has staged
    # fixture files (.issues/, fixtures/, tmp/) in the index; a pathspec-limited commit of
    # `.opencode` restricts the commit to the submodule gitlink so the diff stays
    # submodule-pointer-only and does not sweep in the fixture files.
    git -C "$wd" add .opencode 2>/dev/null || true
    git -C "$wd" commit -q -m "chore: submodule-bump-only pointer update for SC-2 enforcement-gate" -- .opencode 2>/dev/null || true
}

setup_sc2_submodule_bump_only "$1"
