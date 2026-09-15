#!/bin/bash
# Per-scenario fixture (issue 2439, SC-6): HEALTHY fixture — give the test repo
# a real .opencode submodule at its pinned SHA (no drift), a DECLARED BUILD
# MANIFEST whose canonical build AND test commands both SUCCEED. The happy
# path must complete: the release-promoter verification gate runs ONCE per
# release, passes, and promotion PROCEEDS to tag creation.
#
# Pattern: corrected 2439-sc5 fixture pattern — stable-path bare origins
# (absolute path OUTSIDE the attempt workdir, because with-test-home MOVES the
# workdir into the test home), loud push failures.

setup_2439_sc6_gate_once_per_release() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    # Stable-path bare origin, loud push failures.
    local stable_tmp
    stable_tmp="$(cd "$wd/../.." && pwd)/tmp"
    local bare
    bare="$stable_tmp/origin-2439-sc6.git"
    rm -rf "$bare"
    git init -q --bare "$bare" 2>/dev/null || true
    git -C "$wd" remote remove origin 2>/dev/null || true
    git -C "$wd" remote add origin "$bare" 2>/dev/null || true

    # Clone the real .opencode remote into a stable path for the submodule URL.
    # Its AGENTS.md already contains the "Build / Lint / Test Commands" table
    # (the manifest fallback source). Pinned at clone HEAD — no drift.
    local submod_src
    submod_src="$stable_tmp/submod-src-2439-sc6"
    rm -rf "$submod_src"
    if ! git clone -q https://github.com/michael-conrad/.opencode.git "$submod_src"; then
        echo "FIXTURE_FAILURE: 2439-sc6 — clone of real .opencode remote failed" >&2
        return 1
    fi
    if ! grep -q "Build / Lint / Test Commands" "$submod_src/AGENTS.md"; then
        echo "FIXTURE_FAILURE: 2439-sc6 — submodule AGENTS.md lacks build manifest fallback section" >&2
        return 1
    fi

    # Build/test runner scripts. Both the BUILD and TEST commands SUCCEED
    # (exit 0) — the healthy path. The gate must run ONCE, pass, and let
    # promotion proceed to tag creation.
    mkdir -p "$wd/scripts"
    cat > "$wd/scripts/build.sh" <<'EOF'
#!/bin/bash
# Build runner stub — succeeds.
echo "build: OK"
exit 0
EOF
    cat > "$wd/scripts/test.sh" <<'EOF'
#!/bin/bash
# Test runner stub — succeeds (healthy fixture).
echo "test: all tests passed"
exit 0
EOF

    # Root repo build manifest: AGENTS.md at the repo root declares the
    # canonical build and test commands (primary manifest source).
    cat > "$wd/AGENTS.md" <<'EOF'
# AGENTS.md — Test Repository

## Build / Test Commands

| Task | Command |
|------|---------|
| Build | `bash scripts/build.sh` |
| Run all tests | `bash scripts/test.sh` |
EOF

    # Add the submodule at its pinned SHA (no drift) and commit with the
    # manifest and runner scripts.
    rm -rf "$wd/submod"
    if ! git -C "$wd" -c protocol.file.allow=always submodule add -q "$submod_src" submod; then
        echo "FIXTURE_FAILURE: 2439-sc6 — git submodule add of .opencode clone failed" >&2
        return 1
    fi
    git -C "$wd" add .gitmodules submod AGENTS.md scripts
    if ! git -C "$wd" commit -q -m "chore: add submod submodule and build manifest with passing build and test commands"; then
        echo "FIXTURE_FAILURE: 2439-sc6 — manifest + submodule commit failed" >&2
        return 1
    fi

    # NO drift: verify pinned gitlink SHA == submodule source HEAD.
    local pinned src_head
    pinned="$(git -C "$wd" rev-parse HEAD:submod)"
    src_head="$(git -C "$submod_src" rev-parse HEAD)"
    if [ "$pinned" != "$src_head" ]; then
        echo "FIXTURE_FAILURE: 2439-sc6 — unexpected drift (pinned != source HEAD)" >&2
        return 1
    fi

    # Fixture sanity: both the build and test commands succeed (healthy path).
    if ! (cd "$wd" && bash scripts/build.sh >/dev/null 2>&1); then
        echo "FIXTURE_FAILURE: 2439-sc6 — declared build command unexpectedly failed" >&2
        return 1
    fi
    if ! (cd "$wd" && bash scripts/test.sh >/dev/null 2>&1); then
        echo "FIXTURE_FAILURE: 2439-sc6 — declared test command unexpectedly failed (healthy fixture requires success)" >&2
        return 1
    fi
    if ! grep -q "bash scripts/test.sh" "$wd/AGENTS.md"; then
        echo "FIXTURE_FAILURE: 2439-sc6 — root build manifest missing declared test command" >&2
        return 1
    fi

    # Push main to origin. Loud failure.
    if ! git -C "$wd" push -q -u origin HEAD:refs/heads/main; then
        echo "FIXTURE_FAILURE: 2439-sc6 — parent push to bare origin $bare failed" >&2
        return 1
    fi
}

setup_2439_sc6_gate_once_per_release "$1"
