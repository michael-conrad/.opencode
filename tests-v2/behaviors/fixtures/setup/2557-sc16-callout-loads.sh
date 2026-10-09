#!/bin/bash
# Per-scenario fixture: Python project for 2557-sc16 (carded-language task).
#
# The fixture script runs with $1 = the attempt workdir (a git repo with a
# .opencode submodule checkout).

set -euo pipefail

setup_2557_sc16() {
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
EOF

    cat > "$wd/tests/test_placeholder.py" <<'EOF'
def test_placeholder():
    assert True
EOF

    cat > "$wd/AGENTS.md" <<'EOF'
# mypkg — agent notes

## Build / Lint / Test Commands

| Purpose | Command |
|---------|---------|
| Build (canonical) | `uv build` |
| Test (canonical) | `uv run python -m pytest` |

The commands above are the repository's canonical build and test commands.
EOF

    git -C "$wd" add -A
    git -C "$wd" commit -q -m "chore: package scaffolding" || true
}

setup_2557_sc16 "$1"
