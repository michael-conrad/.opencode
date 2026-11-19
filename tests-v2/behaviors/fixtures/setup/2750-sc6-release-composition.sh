#!/bin/bash
# Per-scenario fixture: drift-state consumer repo for
# 2750-sc6-release-composition (.opencode#2750 SC-6).
#
# Scenario state the composition phase must see:
#   - parent trunk zero commits since the last release tag (v1.0.0 tagged
#     at the current HEAD, including the stale pointer below)
#   - one registered submodule (vendor-lib) whose tracked-branch tip
#     (main, on the GitBucket-side repo) is ONE commit ahead of the
#     pointer the parent records — the drift state that the old
#     nothing-to-release reading stopped on
#   - the sibling .opencode submodule at-tip: its .gitmodules branch field
#     is pointed at this cycle's pushed feature branch so the executed
#     remote-tip comparison resolves at-tip, and its URL is the public
#     https form so the clean-room gate's shallow clone resolves it
#   - a root build manifest (AGENTS.md) declaring make build/test, both
#     passing, so the clean-room gate can run to completion
#
# The fixture runs with $1 = the attempt workdir (a git repo with the
# .opencode submodule checkout, origin wired to the GitBucket test repo).
# GITBUCKET_PORT/GB_TOKEN is in the fixture env per §3a.
#
# Token note: the harness's own origin-wiring pattern embeds the throwaway
# GitBucket admin token in the remote URL (an ephemeral, container-wiped
# instance); the vendor-lib URL in tracked .gitmodules follows the same
# throwaway-token pattern and never leaves the container.
set -euo pipefail

setup_2750_sc6() {
    local wd="$1"
    local port="${GITBUCKET_PORT:-}"
    local token="${GB_TOKEN:-root}"
    if [ -z "$port" ]; then
        echo "fixture: GITBUCKET_PORT not set — GitBucket provisioning missing" >&2
        exit 1
    fi

    # 1. Create the vendor-lib repo next to the test repo via the proven
    #    API form, then seed commit A on its main branch.
    #    (Auth: root:root Basic — the harness's own provisioning form; the
    #    minted token is for the gb CLI, not the API's Basic auth.)
    curl -s -u "root:root" -o /dev/null -w "%{http_code}" \
        -X POST "http://localhost:${port}/api/v3/user/repos" \
        -H "Content-Type: application/json" \
        -d '{"name":"vendor-lib"}' 2>&1 | grep -q "2[0-9][0-9]\|409" || {
        echo "fixture: could not create root/vendor-lib on GitBucket (all auth forms)" >&2
        exit 1
    }
    local vl_url="http://root:root@localhost:${port}/git/root/vendor-lib.git"

    local seed
    seed=$(mktemp -d)
    git -C "$seed" init -q -b main
    printf 'int vendor_version(void){return 1;}\n' > "$seed/vendor.c"
    git -C "$seed" add vendor.c
    git -C "$seed" -c user.email=test@test.dev -c user.name=Test commit -q -m "vendor initial (commit A)"
    git -C "$seed" push -q "$vl_url" HEAD:main
    rm -rf "$seed"

    # 2. Sibling .opencode submodule: https URL + feature-branch field so the
    #    executed remote-tip comparison resolves at-tip for this cycle.
    #    (Key form `submodule..opencode.*` addresses the existing section
    #    named ".opencode" — a bare "opencode" key would create a duplicate
    #    registration of the same path.)
    git -C "$wd" config -f .gitmodules submodule..opencode.url \
        https://github.com/michael-conrad/.opencode.git
    git -C "$wd" config -f .gitmodules submodule..opencode.branch \
        feature/2750-release-candidate-composition

    # 3. Register vendor-lib at the stale pointer (commit A), branch main.
    git -C "$wd" submodule add "$vl_url" vendor-lib
    git -C "$wd" config -f .gitmodules submodule.vendor-lib.branch main

    # 4. Build manifest + Makefile, both passing.
    cat > "$wd/Makefile" <<'EOF'
.PHONY: build test

build:
	@echo "build: bundling release artifacts"
test:
	@echo "test: suite placeholder"
EOF
    cat > "$wd/AGENTS.md" <<'EOF'
# Consumer repo — agent notes

## Build / Lint / Test Commands

| Purpose | Command |
|---------|---------|
| Build (canonical) | `make build` |
| Test (canonical) | `make test` |

The commands above are the repository's canonical build and test commands.
EOF

    # 5. One commit carrying the tooling + both pointer records ...
    git -C "$wd" add Makefile AGENTS.md .gitmodules
    git -C "$wd" -c user.email=test@test.dev -c user.name=Test commit -q -m "chore: register vendor-lib release tooling"

    # 6. ... then tag the prior release AT that state: the parent trunk has
    #    zero commits since v1.0.0 while vendor-lib's remote tip (commit B,
    #    pushed below) is one ahead of the recorded pointer.
    git -C "$wd" tag -a v1.0.0 -m "prior release"

    # 7. Advance vendor-lib's remote tip (commit B) — no parent commit rides
    #    with it: the drift lives entirely in the submodule.
    local adv
    adv=$(mktemp -d)
    git -C "$adv" clone -q "$vl_url" .
    printf 'int vendor_version(void){return 2;}\n' > "$adv/vendor.c"
    git -C "$adv" add vendor.c
    git -C "$adv" -c user.email=test@test.dev -c user.name=Test commit -q -m "vendor: bump (commit B)"
    git -C "$adv" push -q origin HEAD:main
    rm -rf "$adv"

    # 8. Submodule working tree back at the recorded pointer, workdir clean.
    git -C "$wd/vendor-lib" checkout -q HEAD -- . 2>/dev/null || true
    git -C "$wd" status --porcelain | grep -v '^??' && {
        echo "fixture: unexpected tracked drift after setup" >&2
        exit 1
    } || true
}

setup_2750_sc6 "$1"
