#!/bin/bash
# Per-scenario fixture: pre-PR release state with a seeded build failure for
# 2557-sc6 (gate placement per .opencode#2590).
#
# The workdir is the "product repo" being promoted. The fixture:
#   - puts the workdir on the release branch (release/v1.2.0), which
#     behavior_run auto-pushes to the wired GitBucket origin
#   - writes the root build manifest (AGENTS.md) declaring the canonical
#     build/test commands (make build / make test)
#   - writes a Makefile whose `build` target FAILS (exit 1) — the seeded
#     failure the gate must catch, blocking PR filing before any PR exists
#   - commits the state
#
# The fixture script runs with $1 = the attempt workdir (a git repo with a
# .opencode submodule checkout).

set -euo pipefail

setup_2557_sc6() {
    local wd="$1"

    git -C "$wd" checkout -q -b release/v1.2.0

    cat > "$wd/Makefile" <<'EOF'
.PHONY: build test

build:
	@echo "build: bundling release artifacts"
	@exit 1

test:
	@echo "test: suite placeholder"
EOF

    cat > "$wd/AGENTS.md" <<'EOF'
# Product repo — agent notes

## Build / Lint / Test Commands

| Purpose | Command |
|---------|---------|
| Build (canonical) | `make build` |
| Test (canonical) | `make test` |

The commands above are the repository's canonical build and test commands.
EOF

    git -C "$wd" add AGENTS.md Makefile
    git -C "$wd" commit -q -m "chore: release tooling" || true
}

setup_2557_sc6 "$1"
