#!/bin/bash
# setup-story-fixtures.sh — Inject AI-generated story fixtures into behavioral test repos.
#
# Called by behavior_run() in helpers.sh after the isolated test repo is created.
# Copies the story files from the live working tree.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

STORY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/stories"

setup_story_fixtures() {
    local workdir="$1"

    if [ ! -d "$STORY_DIR" ]; then
        echo "WARNING: story fixtures directory not found: $STORY_DIR" >&2
        return 0
    fi

    # Create fixtures directory in the test repo
    mkdir -p "$workdir/fixtures/stories"

    # Copy all story files
    for story_file in "$STORY_DIR"/*.txt; do
        if [ ! -f "$story_file" ]; then
            continue
        fi
        cp "$story_file" "$workdir/fixtures/stories/"
    done

    local count
    count=$(ls "$workdir/fixtures/stories/"*.txt 2>/dev/null | wc -l)
    echo "  injected $count story fixtures into test repo"

    # Stage the fixtures directory
    git -C "$workdir" add fixtures/ 2>/dev/null || true
}

# If called directly (not sourced), run setup
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    setup_story_fixtures "$@"
fi
