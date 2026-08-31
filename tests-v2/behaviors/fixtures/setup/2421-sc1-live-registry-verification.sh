#!/bin/bash
# Per-scenario fixture setup for 2421-sc1-live-registry-verification
# Creates a minimal pyproject.toml in the test project root so the agent has a
# dependency manifest to add the 'requests' package to. The dependencies list is
# initially empty — the agent must query the live registry to determine the
# current stable version before pinning.

setup_2421_sc1_fixture() {
    local wd="$1"

    cat > "$wd/pyproject.toml" << 'EOF'
[project]
name = "test-project"
version = "0.1.0"
description = "Test project for live-registry verification behavioral test"
requires-python = ">=3.12"
dependencies = []
EOF
}

setup_2421_sc1_fixture "$1"
