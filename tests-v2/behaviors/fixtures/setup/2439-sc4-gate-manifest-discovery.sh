#!/bin/bash
# Per-scenario fixture (issue 2439, SC-4): give the test repo a real .opencode
# submodule at its pinned SHA (NO drift — SC-3's territory) and a DECLARED
# BUILD MANIFEST: the root repo's AGENTS.md carries a "Build / Test Commands"
# table naming the canonical build and test commands, and the .opencode
# submodule's AGENTS.md (already present in the real submodule) carries the
# "Build / Lint / Test Commands" fallback source. The release-promoter
# verification gate must DISCOVER the canonical build/test commands from these
# manifests rather than assuming a build system; an undiscoverable manifest is
# a hard fail (MANIFEST_FAIL).
#
# Pattern: corrected 2439-sc3 fixture pattern — stable-path bare origins
# (absolute path OUTSIDE the attempt workdir, because with-test-home MOVES the
# workdir into the test home), loud push failures.

setup_2439_sc4_gate_manifest_discovery() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    # Stable-path bare origin, loud push failures.
    local stable_tmp
    stable_tmp="$(cd "$wd/../.." && pwd)/tmp"
    local bare
    bare="$stable_tmp/origin-2439-sc4.git"
    rm -rf "$bare"
    git init -q --bare "$bare" 2>/dev/null || true
    git -C "$wd" remote remove origin 2>/dev/null || true
    git -C "$wd" remote add origin "$bare" 2>/dev/null || true

    # Clone the real .opencode remote into a stable path for the submodule URL.
    # Its AGENTS.md already contains the "Build / Lint / Test Commands" table
    # (the manifest fallback source). Pinned at clone HEAD — no drift.
    local submod_src
    submod_src="$stable_tmp/submod-src-2439-sc4"
    rm -rf "$submod_src"
    if ! git clone -q https://github.com/michael-conrad/.opencode.git "$submod_src"; then
        echo "FIXTURE_FAILURE: 2439-sc4 — clone of real .opencode remote failed" >&2
        return 1
    fi
    if ! grep -q "Build / Lint / Test Commands" "$submod_src/AGENTS.md"; then
        echo "FIXTURE_FAILURE: 2439-sc4 — submodule AGENTS.md lacks build manifest fallback section" >&2
        return 1
    fi

    # Root repo build manifest: AGENTS.md at the repo root declares the
    # canonical build and test commands (primary manifest source).
    cat > "$wd/AGENTS.md" <<'EOF'
# AGENTS.md — Test Repository

## Build / Test Commands

| Task | Command |
|------|---------|
| Sync dependencies | `uv sync` |
| Run all tests | `uv run pytest test/` |
| Build | `uv build` |
EOF

    # Add the submodule at its pinned SHA (no drift) and commit with the manifest.
    rm -rf "$wd/submod"
    if ! git -C "$wd" -c protocol.file.allow=always submodule add -q "$submod_src" submod; then
        echo "FIXTURE_FAILURE: 2439-sc4 — git submodule add of .opencode clone failed" >&2
        return 1
    fi
    git -C "$wd" add .gitmodules submod AGENTS.md
    if ! git -C "$wd" commit -q -m "chore: add submod submodule and build manifest for release verification gate"; then
        echo "FIXTURE_FAILURE: 2439-sc4 — manifest + submodule commit failed" >&2
        return 1
    fi

    # NO drift: verify pinned gitlink SHA == submodule source HEAD.
    local pinned src_head
    pinned="$(git -C "$wd" rev-parse HEAD:submod)"
    src_head="$(git -C "$submod_src" rev-parse HEAD)"
    if [ "$pinned" != "$src_head" ]; then
        echo "FIXTURE_FAILURE: 2439-sc4 — unexpected drift (pinned != source HEAD)" >&2
        return 1
    fi
    if ! grep -q "uv run pytest test/" "$wd/AGENTS.md"; then
        echo "FIXTURE_FAILURE: 2439-sc4 — root build manifest missing declared test command" >&2
        return 1
    fi

    # Push main to origin. Loud failure.
    if ! git -C "$wd" push -q -u origin HEAD:refs/heads/main; then
        echo "FIXTURE_FAILURE: 2439-sc4 — parent push to bare origin $bare failed" >&2
        return 1
    fi
}

setup_2439_sc4_gate_manifest_discovery "$1"
