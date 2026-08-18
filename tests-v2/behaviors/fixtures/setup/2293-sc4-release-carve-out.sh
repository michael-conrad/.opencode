#!/bin/bash
# Per-scenario fixture: set up a dirty/staged submodule pointer for SC-4.
# The .opencode submodule HEAD is advanced past the parent's recorded gitlink,
# and the new pointer is staged in the parent repo — the state expected in a
# parent-repo release. The release pre-validation in pr-creation.md (line 32)
# still contains "No uncommitted submodule changes", so an agent executing the
# pr-creation task card blocks the release path (RED). After the release carve-out
# is added, the same state must NOT block the release (GREEN).

setup_dirty_staged_pointer() {
    local wd="$1"

    # Advance the .opencode submodule HEAD past the parent's recorded gitlink.
    git -C "$wd/.opencode" commit -q --allow-empty -m "advance submodule for release" 2>/dev/null || true

    # Stage the new submodule pointer in the parent repo (gitlink update).
    git -C "$wd" add .opencode 2>/dev/null || true

    # Leave the pointer staged but uncommitted — the dirty/staged state expected
    # in a parent-repo release.
}

setup_dirty_staged_pointer "$1"
