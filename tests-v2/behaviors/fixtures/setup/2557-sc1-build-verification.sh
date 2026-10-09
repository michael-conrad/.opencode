#!/bin/bash
# Per-scenario fixture: build-affecting-change project for 2557-sc1.
#
# Creates a small Python package (uv-buildable) whose AGENTS.md is the repo's
# declared build manifest: a "Build / Lint / Test Commands" section naming the
# canonical build command (uv build) and test command. The scenario prompt asks
# for a packaging-affecting change (version bump), so the deck's
# build-verification practice (shallow temp-copy checkout + manifest-sourced
# build + final-outputs assertion) is the behavior under test.
#
# The fixture script runs with $1 = the attempt workdir (a git repo with a
# .opencode submodule checkout).

set -euo pipefail

setup_2557_sc1() {
    local wd="$1"

    mkdir -p "$wd/src/mypkg"

    cat > "$wd/pyproject.toml" <<'EOF'
[build-system]
requires = ["setuptools>=68"]
build-backend = "setuptools.build_meta"

[project]
name = "mypkg"
version = "0.1.0"
description = "A small utility package"
requires-python = ">=3.10"
EOF

    cat > "$wd/src/mypkg/__init__.py" <<'EOF'
"""A small utility package."""

__version__ = "0.1.0"
EOF

    cat > "$wd/README.md" <<'EOF'
# mypkg

A small utility package used by the team's internal tooling.
EOF

    cat > "$wd/AGENTS.md" <<'EOF'
# mypkg — agent notes

## Build / Lint / Test Commands

| Purpose | Command |
|---------|---------|
| Build (canonical) | `uv build` |
| Test (canonical) | `uv run python -m pytest` |
| Lint | `uv run ruff check src/` |

The commands above are the repository's canonical build and test commands.
Build outputs land in `dist/` (wheel + sdist).
EOF

    git -C "$wd" add -A
    git -C "$wd" commit -q -m "chore: package scaffolding" || true
}

setup_2557_sc1 "$1"
