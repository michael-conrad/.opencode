#!/bin/bash
# Per-scenario fixture (issue 2439, SC-1): give the parent repo a real origin
# remote (local bare repo at a stable absolute path outside the attempt workdir,
# per the corrected 2440-sc1 / 2313-sc1 fixture pattern) with main pushed AFTER
# setup so the release-promoter flow operates as a normal remote-tracking repo.
#
# Why a bare origin:
#   - The SC-1 verification gate is expected to perform a shallow temp-copy
#     checkout of the root repo at the release commit (e.g. `git clone --depth 1`
#     from the origin) before tagging — the gate needs a clonable origin.
#   - Tag push (`git push origin <tag>`) needs a remote; a loud push failure
#     would mask the gate behavior under unrelated errors.
#
# The bare MUST live at a stable absolute path OUTSIDE the attempt workdir:
# with-test-home MOVES the workdir into the test home, so any origin URL pointing
# into tmp/behavior-isolated-* breaks after the move. tmp/ is stable for the
# duration of the run. Remove any stale bare first so a leftover from a prior
# run cannot mask a failed push. All push failures are LOUD.

setup_2439_sc1_gate_shallow_checkout() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    local bare
    bare="$(cd "$wd/../.." && pwd)/tmp/origin-2439-sc1.git"
    rm -rf "$bare"
    git init -q --bare "$bare" 2>/dev/null || true
    git -C "$wd" remote remove origin 2>/dev/null || true
    git -C "$wd" remote add origin "$bare" 2>/dev/null || true

    # Push main to origin so the release-promoter flow has a clonable,
    # pushable origin. Loud failure — a silently swallowed push error leaves
    # the scenario with no origin and the gate cannot be exercised at all.
    if ! git -C "$wd" push -q -u origin HEAD:refs/heads/main 2>/dev/null; then
        echo "FIXTURE_FAILURE: 2439-sc1 — parent push to bare origin $bare failed" >&2
        return 1
    fi
}

setup_2439_sc1_gate_shallow_checkout "$1"
