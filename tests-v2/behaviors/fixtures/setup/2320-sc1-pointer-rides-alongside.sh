#!/bin/bash
# Per-scenario fixture: 2320-sc1-pointer-rides-alongside
# Sets up the repo state for SC-1's RED behavioral test: a feature branch with a real
# source change pending, plus a dirty .opencode submodule pointer that the agent must
# commit ALONGSIDE the real change (never dropped, never pointer-only).
#
# The harness provisions the workdir with an `.opencode` submodule and a `.gitmodules`
# entry (helpers.sh behavior_run), then commits an "init" commit that records the gitlink
# (submodule pointer). At that point the gitlink is CLEAN (matches submodule HEAD).
#
# This fixture makes the pointer DIRTY by committing a change INSIDE the submodule and
# advancing its HEAD beyond the recorded gitlink. The parent repo then reports the
# submodule as "modified" (new commits present) — a genuine dirty pointer.
#
# RED expectation: the agent reads the root AGENTS.md §Submodule Pointer Updates
# guidance. Because the current guidance does NOT unambiguously state the pointer rides
# ALONGSIDE the real change (it says "Include the pointer update alongside any other
# parent-repo change in the same commit"), the agent may drop the pointer or commit it
# standalone. A clean-room evaluator reads session.yaml to judge whether the pointer was
# committed alongside the real change.

setup_sc1_dirty_pointer() {
    local wd="$1"

    # Work on a feature branch so the change is a legitimate feature commit.
    git -C "$wd" checkout -b feature/2320-pointer-rides-alongside 2>/dev/null || true

    # Real source change (uncommitted, pending).
    mkdir -p "$wd/src"
    echo "real source change for SC-1" > "$wd/src/real.txt"

    # Make the .opencode submodule pointer dirty: advance the submodule's HEAD past the
    # recorded gitlink so the parent repo sees a new-commit submodule (dirty pointer).
    if [ -d "$wd/.opencode/.git" ]; then
        git -C "$wd/.opencode" config user.email "test@test.dev" 2>/dev/null || true
        git -C "$wd/.opencode" config user.name "Test" 2>/dev/null || true
        # Use a robust marker file that is guaranteed writable inside the submodule.
        echo "SC-1 dirty pointer advance" >> "$wd/.opencode/AGENTS.md"
        git -C "$wd/.opencode" add AGENTS.md 2>/dev/null || true
        git -C "$wd/.opencode" commit -q -m "advance submodule HEAD to dirty the parent pointer" 2>/dev/null || true
    fi
}

setup_sc1_dirty_pointer "$1"
