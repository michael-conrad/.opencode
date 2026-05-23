#!/bin/bash
# setup-fixture-issues.sh — Inject .issues/ fixture entries into behavioral test repos.
#
# Usage:
#   source "$(dirname "${BASH_SOURCE[0]}")/setup-fixture-issues.sh"
#   setup_fixture_issues "$workdir"
#
# This creates a .issues/ directory in the test repo with fixture issue entries
# that behavioral tests can reference. Fixture issues come from
# tests/behaviors/fixtures/issues/.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

FIXTURES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/issues"

setup_fixture_issues() {
    local workdir="$1"

    if [ ! -d "$FIXTURES_DIR" ]; then
        echo "WARNING: fixture issues directory not found: $FIXTURES_DIR" >&2
        return 0
    fi

    # Create .issues/ structure in the test repo
    mkdir -p "$workdir/.issues/open"
    mkdir -p "$workdir/.issues/closed"

    # Copy all fixture issue directories
    for issue_dir in "$FIXTURES_DIR"/*/; do
        if [ ! -d "$issue_dir" ]; then
            continue
        fi
        local issue_name
        issue_name=$(basename "$issue_dir")
        mkdir -p "$workdir/.issues/open/$issue_name"
        cp -r "$issue_dir"* "$workdir/.issues/open/$issue_name/" 2>/dev/null || true
    done

    # Update the counter file to be at least as high as the highest issue number
    local max_number=0
    for issue_dir in "$FIXTURES_DIR"/*/; do
        local issue_name
        issue_name=$(basename "$issue_dir")
        local number
        number=$(echo "$issue_name" | grep -oE '^[0-9]+' || echo "0")
        if [ "$number" -gt "$max_number" ]; then
            max_number=$number
        fi
    done

    local next_number=$((max_number + 1))
    echo "$next_number" > "$workdir/.issues/.counter"

    # Stage the .issues/ directory
    git -C "$workdir" add .issues/ 2>/dev/null || true
}