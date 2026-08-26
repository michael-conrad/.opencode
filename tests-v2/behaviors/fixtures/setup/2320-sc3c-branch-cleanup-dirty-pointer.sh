#!/bin/bash
# Per-scenario fixture: 2320-sc3c-branch-cleanup-dirty-pointer
# Sets up the repo state for SC-3c's ALREADY_GREEN behavioral test: a repo whose
# submodule pointer is dirty during post-merge cleanup, which the agent must leave
# uncommitted per branch-cleanup.md Step 1.7 (cleanup exemption) and record as riding
# alongside the next real root change.
#
# The harness provisions the workdir with an `.opencode` submodule and a `.gitmodules`
# entry (helpers.sh behavior_run), then commits an "init" commit that records the gitlink
# (submodule pointer). At that point the gitlink is CLEAN (matches submodule HEAD).
#
# This fixture makes the pointer DIRTY by committing a change INSIDE the submodule and
# advancing its HEAD beyond the recorded gitlink. The parent repo then reports the
# submodule as "modified" (new commits present) — a genuine dirty pointer that appears
# during the post-merge cleanup workflow when Step 1.7 evaluates the parent repo state.
#
# The agent is NOT put on a feature branch for this scenario — it is the post-merge
# cleanup context, which operates on the trunk. The dirty pointer is observed there and,
# per branch-cleanup.md Step 1.7, MUST be left uncommitted (cleanup exemption) and
# acknowledged as expected, with the update riding alongside the next real root change.
#
# ALREADY_GREEN expectation: branch-cleanup.md Step 1.7 already states the dirty pointer
# is expected (line 148), left uncommitted (lines 170-173, 178), and rides alongside the
# next real root change (lines 163, 178). The agent following Step 1.7 leaves the pointer
# uncommitted and records it rides alongside. A clean-room evaluator reads session.yaml to
# judge whether the agent left the pointer uncommitted, treated it as expected, and
# recorded it rides alongside the next real root change.

setup_sc3c_dirty_pointer() {
    local wd="$1"

    # Make the .opencode submodule pointer dirty: advance the submodule's HEAD past the
    # current gitlink so the parent repo sees a new-commit submodule (dirty pointer).
    if [ -d "$wd/.opencode/.git" ]; then
        git -C "$wd/.opencode" config user.email "test@test.dev" 2>/dev/null || true
        git -C "$wd/.opencode" config user.name "Test" 2>/dev/null || true
        # Use a robust marker file that is guaranteed writable inside the submodule.
        echo "SC-3c dirty pointer advance" >> "$wd/.opencode/AGENTS.md"
        git -C "$wd/.opencode" add AGENTS.md 2>/dev/null || true
        git -C "$wd/.opencode" commit -q -m "advance submodule HEAD to dirty the parent pointer" 2>/dev/null || true
    fi
}

setup_sc3c_dirty_pointer "$1"
