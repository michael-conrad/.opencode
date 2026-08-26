#!/bin/bash
# Per-scenario fixture: 2320-sc3b-pr-creation-prepush-pointer-rides-alongside
# Sets up the repo state for SC-3b's RED behavioral test: a feature branch with a real
# source change committed, plus a dirty .opencode submodule pointer that the agent must
# verify is committed ALONGSIDE the real root change when reading pr-creation.md §Pre-Push
# before pushing (never treated as resolved by the submodule merge, never dropped).
#
# The harness provisions the workdir with an `.opencode` submodule and a `.gitmodules`
# entry (helpers.sh behavior_run), then commits an "init" commit that records the gitlink
# (submodule pointer). At that point the gitlink is CLEAN (matches submodule HEAD).
#
# This fixture makes the pointer DIRTY by committing a change INSIDE the submodule and
# advancing its HEAD beyond the recorded gitlink. The parent repo then reports the
# submodule as "modified" (new commits present) — a genuine dirty pointer. It also commits
# a real source change (src/real.txt) on the feature branch so the branch has a legitimate
# real root change alongside the dirty pointer — the exact §Pre-Push scenario.
#
# RED expectation: the agent reads pr-creation.md §Pre-Push Submodule Pointer Verification.
# Because the current §Pre-Push language does NOT explicitly state that a merged submodule
# PR does NOT resolve the root pointer (it only verifies dirty pointers are staged alongside
# real changes for the branch's own PR), the agent does NOT reliably verify the pointer is
# committed ALONGSIDE the real source change and may treat the submodule merge/existing
# state as resolving the pointer (leaving it uncommitted). A clean-room evaluator reads
# session.yaml to judge whether the agent verified the pointer is committed alongside the
# real root change and did NOT treat the submodule merge as resolving it.

setup_sc3b_dirty_pointer() {
    local wd="$1"

    # Work on a feature branch so the change is a legitimate feature commit.
    git -C "$wd" checkout -b feature/2320-pr-creation-prepush 2>/dev/null || true

    # Real source change (committed on the feature branch, pending push).
    mkdir -p "$wd/src"
    echo "real source change for SC-3b" > "$wd/src/real.txt"
    git -C "$wd" add src/real.txt 2>/dev/null || true
    git -C "$wd" commit -q -m "feat: real source change for SC-3b" 2>/dev/null || true

    # Make the .opencode submodule pointer dirty: advance the submodule's HEAD past the
    # current gitlink so the parent repo sees a new-commit submodule (dirty pointer).
    if [ -d "$wd/.opencode/.git" ]; then
        git -C "$wd/.opencode" config user.email "test@test.dev" 2>/dev/null || true
        git -C "$wd/.opencode" config user.name "Test" 2>/dev/null || true
        # Use a robust marker file that is guaranteed writable inside the submodule.
        echo "SC-3b dirty pointer advance" >> "$wd/.opencode/AGENTS.md"
        git -C "$wd/.opencode" add AGENTS.md 2>/dev/null || true
        git -C "$wd/.opencode" commit -q -m "advance submodule HEAD to dirty the parent pointer" 2>/dev/null || true
    fi
}

setup_sc3b_dirty_pointer "$1"
