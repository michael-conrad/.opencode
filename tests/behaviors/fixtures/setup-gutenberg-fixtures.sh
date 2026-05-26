#!/bin/bash
# setup-gutenberg-fixtures.sh — Inject gutenberg story fixtures into behavioral test repos.
#
# Called by behavior_run() in helpers.sh after the isolated test repo is created.
# Copies the generated story files from the live working tree.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

GUTENBERG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/gutenberg"

setup_gutenberg_fixtures() {
    local workdir="$1"

    if [ ! -d "$GUTENBERG_DIR" ]; then
        echo "WARNING: gutenberg fixtures directory not found: $GUTENBERG_DIR" >&2
        return 0
    fi

    # Create fixtures directory in the test repo
    mkdir -p "$workdir/fixtures/gutenberg"

    # Copy all story files
    for story_file in "$GUTENBERG_DIR"/*.txt; do
        if [ ! -f "$story_file" ]; then
            continue
        fi
        cp "$story_file" "$workdir/fixtures/gutenberg/"
    done

    local count
    count=$(ls "$workdir/fixtures/gutenberg/"*.txt 2>/dev/null | wc -l)
    echo "  injected $count gutenberg fixture stories into test repo"

    # Stage the fixtures directory
    git -C "$workdir" add fixtures/ 2>/dev/null || true
}

# If called directly (not sourced), run setup
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    setup_gutenberg_fixtures "$@"
fi
