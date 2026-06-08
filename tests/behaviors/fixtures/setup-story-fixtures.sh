#!/bin/bash
# setup-story-fixtures.sh — Inject AI-generated story fixtures and Gutenberg text fixtures
# into behavioral test repos.
#
# Called by behavior_run() in helpers.sh after the isolated test repo is created.
# Copies the story files from the live working tree.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STORY_DIR="$SCRIPT_DIR/stories"

setup_story_fixtures() {
    local workdir="$1"

    # Inject story fixtures
    if [ -d "$STORY_DIR" ]; then
        mkdir -p "$workdir/fixtures/stories"
        for story_file in "$STORY_DIR"/*.txt; do
            if [ ! -f "$story_file" ]; then
                continue
            fi
            cp "$story_file" "$workdir/fixtures/stories/"
        done
        local count
        count=$(ls "$workdir/fixtures/stories/"*.txt 2>/dev/null | wc -l)
        echo "  injected $count story fixtures into test repo"
        git -C "$workdir" add fixtures/ 2>/dev/null || true
    fi

    # Inject Gutenberg text fixtures into tmp/ for file operation tests
    mkdir -p "$workdir/tmp"
    local gutenberg_count=0
    for guten_file in "$SCRIPT_DIR"/gutenberg-*.txt; do
        if [ ! -f "$guten_file" ]; then
            continue
        fi
        local basename
        basename=$(basename "$guten_file")
        cp "$guten_file" "$workdir/tmp/$basename"
        gutenberg_count=$((gutenberg_count + 1))
    done
    if [ "$gutenberg_count" -gt 0 ]; then
        echo "  injected $gutenberg_count Gutenberg text fixtures into test repo"
        git -C "$workdir" add tmp/ 2>/dev/null || true
    fi
}

# If called directly (not sourced), run setup
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    setup_story_fixtures "$@"
fi
