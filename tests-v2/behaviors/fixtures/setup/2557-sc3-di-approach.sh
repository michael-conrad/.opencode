#!/bin/bash
# Per-scenario fixture: Python project with a hand-wired existing service for
# 2557-sc3.
#
# The existing ReportService constructs its own dependency inline (the
# hand-rolled wiring the DI mandate exists to stop). The scenario adds a new
# service + unit tests — with the deck's shared DI card present, the agent
# should reach for dependency-injector (container-first) rather than extend
# the hand-rolled pattern.
#
# The fixture script runs with $1 = the attempt workdir (a git repo with a
# .opencode submodule checkout).

set -euo pipefail

setup_2557_sc3() {
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
EOF

    cat > "$wd/src/mypkg/report.py" <<'EOF'
"""Reporting service (existing code)."""


class ReportStore:
    def load(self, key: str) -> str:
        return f"data-for-{key}"


class ReportService:
    """Constructs its own dependency — hand-rolled wiring."""

    def __init__(self) -> None:
        self._store = ReportStore()

    def render(self, key: str) -> str:
        return f"report: {self._store.load(key)}"
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
    git -C "$wd" commit -q -m "chore: package scaffolding with report service" || true
}

setup_2557_sc3 "$1"
