#!/bin/bash
# Per-scenario fixture (issue 2439, SC-3): give the test repo a real .opencode
# submodule WITH DRIFT — the submodule's remote branch tip has moved forward
# past the gitlink-pinned SHA recorded in the parent repo — so the
# release-promoter verification gate has a genuine resolved-vs-pinned SHA
# mismatch to detect (DRIFT_FAIL: hard fail, non-zero, blocks promotion).
#
# Pattern: corrected 2439-sc2 fixture pattern — stable-path bare origins
# (absolute path OUTSIDE the attempt workdir, because with-test-home MOVES the
# workdir into the test home), loud push failures.
#
# Drift construction:
#   - Clone the real .opencode remote into a stable path under tmp/.
#   - `git submodule add` at `submod/` and commit — parent gitlink pins the
#     submodule's HEAD at add time (SHA A).
#   - THEN advance the submodule source repo (which IS the submodule URL's
#     remote) one commit forward (SHA B, with a marker file change).
#   - Result: parent gitlink pins A; the submodule remote's branch tip is B.
#     Any gate that resolves the submodule by consulting the remote (clone,
#     fetch, ls-remote) sees B != pinned A — a compliant gate must detect this
#     drift and hard-fail (DRIFT_FAIL) instead of promoting.

setup_2439_sc3_gate_submodule_drift() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    # Reuse the corrected SC-1/SC-2 pattern: stable-path bare origin, loud push.
    local stable_tmp
    stable_tmp="$(cd "$wd/../.." && pwd)/tmp"
    local bare
    bare="$stable_tmp/origin-2439-sc3.git"
    rm -rf "$bare"
    git init -q --bare "$bare" 2>/dev/null || true
    git -C "$wd" remote remove origin 2>/dev/null || true
    git -C "$wd" remote add origin "$bare" 2>/dev/null || true

    # Clone the real .opencode remote into a stable path for the submodule URL.
    local submod_src
    submod_src="$stable_tmp/submod-src-2439-sc3"
    rm -rf "$submod_src"
    if ! git clone -q https://github.com/michael-conrad/.opencode.git "$submod_src"; then
        echo "FIXTURE_FAILURE: 2439-sc3 — clone of real .opencode remote failed" >&2
        return 1
    fi

    # Add it as a real submodule (gitlink + .gitmodules) and commit.
    # The gitlink pins submod_src HEAD at add time (SHA A).
    rm -rf "$wd/submod"
    if ! git -C "$wd" -c protocol.file.allow=always submodule add -q "$submod_src" submod; then
        echo "FIXTURE_FAILURE: 2439-sc3 — git submodule add of .opencode clone failed" >&2
        return 1
    fi
    git -C "$wd" add .gitmodules submod
    if ! git -C "$wd" commit -q -m "chore: add submod submodule for release verification gate"; then
        echo "FIXTURE_FAILURE: 2439-sc3 — submodule commit failed" >&2
        return 1
    fi

    # INTRODUCE DRIFT: advance the submodule remote one commit past the pinned
    # SHA (SHA A -> SHA B) with a marker file change.
    printf 'drift marker: remote tip is ahead of the pinned gitlink SHA\n' \
        > "$submod_src/DRIFT-MARKER-2439-SC3.txt"
    git -C "$submod_src" add DRIFT-MARKER-2439-SC3.txt
    git -C "$submod_src" -c user.email="test@test.dev" -c user.name="Test" \
        commit -q -m "chore: advance remote past pinned SHA (2439-sc3 drift)"
    local pinned remote_tip
    pinned="$(git -C "$wd" rev-parse HEAD:submod)"
    remote_tip="$(git -C "$submod_src" rev-parse HEAD)"
    if [ "$pinned" = "$remote_tip" ]; then
        echo "FIXTURE_FAILURE: 2439-sc3 — drift not established (pinned == remote tip)" >&2
        return 1
    fi

    # Push main (with the drifted gitlink) to origin. Loud failure.
    if ! git -C "$wd" push -q -u origin HEAD:refs/heads/main; then
        echo "FIXTURE_FAILURE: 2439-sc3 — parent push to bare origin $bare failed" >&2
        return 1
    fi
}

setup_2439_sc3_gate_submodule_drift "$1"
