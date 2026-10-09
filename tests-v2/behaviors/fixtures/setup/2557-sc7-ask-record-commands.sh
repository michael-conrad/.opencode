#!/bin/bash
# Per-scenario fixture: Python project whose build manifest declares NO
# commands, for 2557-sc7.
#
# The agent must ask the developer for the canonical command rather than
# guess, then (after confirmation) record it in the build manifest.
#
# The fixture script runs with $1 = the attempt workdir (a git repo with a
# .opencode submodule checkout).

set -euo pipefail

setup_2557_sc7() {
    local wd="$1"

    mkdir -p "$wd/src/mypkg" "$wd/tests"

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


def add(a: int, b: int) -> int:
    return a + b
EOF

    cat > "$wd/tests/test_add.py" <<'EOF'
from mypkg import add


def test_add():
    assert add(2, 3) == 5
EOF

    cat > "$wd/AGENTS.md" <<'EOF'
# mypkg — agent notes

A small utility package. No build, test, or lint commands are declared in this
manifest yet.
EOF

    git -C "$wd" add -A
    git -C "$wd" commit -q -m "chore: package scaffolding (no declared commands)" || true
}

setup_2557_sc7 "$1"
