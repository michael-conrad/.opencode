#!/bin/bash
# Per-scenario fixture (issue 2439, SC-2): give the test repo a real .opencode
# submodule so the release-promoter verification gate has a submodule to resolve
# to its gitlink-pinned SHA (`git submodule update --init --depth 1`).
#
# Pattern: corrected 2440-sc1 / 2313-sc1 / 2439-sc1 fixture pattern — stable-path
# bare origins (absolute path OUTSIDE the attempt workdir, because with-test-home
# MOVES the workdir into the test home), loud push failures.
#
# Submodule provisioning:
#   - Clone the real .opencode remote (https) into a stable path under tmp/
#     (outside the attempt workdir, same stability rationale as the bare).
#   - `git submodule add` it at `submod/` with that stable absolute path as the
#     submodule URL, then commit — so the parent repo carries a real gitlink and
#     a clonable .gitmodules URL for a shallow temp-copy checkout to resolve.
#   - The harness-provisioned `.opencode/` directory clone in the test home is
#     NOT a gitlink submodule, so a distinct path is required.

setup_2439_sc2_gate_submodule_pins() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    # Reuse the corrected SC-1 pattern: stable-path bare origin, loud push.
    local stable_tmp
    stable_tmp="$(cd "$wd/../.." && pwd)/tmp"
    local bare
    bare="$stable_tmp/origin-2439-sc2.git"
    rm -rf "$bare"
    git init -q --bare "$bare" 2>/dev/null || true
    git -C "$wd" remote remove origin 2>/dev/null || true
    git -C "$wd" remote add origin "$bare" 2>/dev/null || true

    # Clone the real .opencode remote into a stable path for the submodule URL.
    local submod_src
    submod_src="$stable_tmp/submod-src-2439-sc2"
    rm -rf "$submod_src"
    if ! git clone -q https://github.com/michael-conrad/.opencode.git "$submod_src"; then
        echo "FIXTURE_FAILURE: 2439-sc2 — clone of real .opencode remote failed" >&2
        return 1
    fi

    # Add it as a real submodule (gitlink + .gitmodules) and commit.
    rm -rf "$wd/submod"
    if ! git -C "$wd" -c protocol.file.allow=always submodule add -q "$submod_src" submod; then
        echo "FIXTURE_FAILURE: 2439-sc2 — git submodule add of .opencode clone failed" >&2
        return 1
    fi
    git -C "$wd" add .gitmodules submod
    if ! git -C "$wd" commit -q -m "chore: add submod submodule for release verification gate"; then
        echo "FIXTURE_FAILURE: 2439-sc2 — submodule commit failed" >&2
        return 1
    fi

    # Push main (with gitlink) to origin. Loud failure.
    if ! git -C "$wd" push -q -u origin HEAD:refs/heads/main; then
        echo "FIXTURE_FAILURE: 2439-sc2 — parent push to bare origin $bare failed" >&2
        return 1
    fi
}

setup_2439_sc2_gate_submodule_pins "$1"
