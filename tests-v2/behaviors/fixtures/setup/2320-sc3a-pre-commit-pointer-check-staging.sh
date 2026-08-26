#!/bin/bash
# Per-scenario fixture: 2320-sc3a-pre-commit-pointer-check-staging
# Sets up the repo state for SC-3a's RED behavioral test: a feature branch with a real
# source change pending, plus a dirty .opencode submodule pointer that the agent must
# stage and commit ALONGSIDE the real change (never dropped, never committed standalone).
#
# The harness provisions the workdir with an `.opencode` submodule and a `.gitmodules`
# entry (helpers.sh behavior_run), then commits an "init" commit that records the gitlink
# (submodule pointer). At that point the gitlink is CLEAN (matches submodule HEAD).
#
# This fixture makes the pointer DIRTY by committing a change INSIDE the submodule and
# advancing its HEAD beyond the recorded gitlink. The parent repo then reports the
# submodule as "modified" (new commits present) — a genuine dirty pointer.
#
# RED expectation: the agent reads pre-commit-pointer-check.md and follows its procedure
# to stage/commit a real source change alongside the dirty pointer. The current
# pre-commit-pointer-check.md Step 4 only "warns and suggests adding" dirty pointers — it
# does NOT unambiguously state the pointer MUST be staged and committed alongside the real
# change (never dropped, never committed standalone). So the agent does NOT reliably
# stage and commit the pointer alongside the real change. A clean-room evaluator reads
# session.yaml to judge whether the pointer was committed alongside the real change.

setup_sc3a_dirty_pointer() {
    local wd="$1"

    # Work on a feature branch so the change is a legitimate feature commit.
    git -C "$wd" checkout -b feature/2320-pointer-rides-alongside 2>/dev/null || true

    # Real source change (uncommitted, pending).
    mkdir -p "$wd/src"
    echo "real source change for SC-3a" > "$wd/src/real.txt"

    # Make the .opencode submodule pointer dirty: advance the submodule's HEAD past the
    # recorded gitlink so the parent repo sees a new-commit submodule (dirty pointer).
    if [ -d "$wd/.opencode/.git" ]; then
        git -C "$wd/.opencode" config user.email "test@test.dev" 2>/dev/null || true
        git -C "$wd/.opencode" config user.name "Test" 2>/dev/null || true
        # Use a robust marker file that is guaranteed writable inside the submodule.
        echo "SC-3a dirty pointer advance" >> "$wd/.opencode/AGENTS.md"
        git -C "$wd/.opencode" add AGENTS.md 2>/dev/null || true
        git -C "$wd/.opencode" commit -q -m "advance submodule HEAD to dirty the parent pointer" 2>/dev/null || true
    fi
}

setup_sc3a_dirty_pointer "$1"
