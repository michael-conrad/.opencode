#!/bin/bash
# setup-code-fixtures.sh — Inject code fixtures into behavioral test repos.
#
# Called by behavior_run() in helpers.sh after the isolated test repo is created.
# Copies code fixtures (source files with known bugs) for tests that need
# real codebases to investigate.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

CODE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/code"

setup_code_fixtures() {
    local workdir="$1"

    if [ ! -d "$CODE_DIR" ]; then
        echo "WARNING: code fixtures directory not found: $CODE_DIR" >&2
        return 0
    fi

    # Copy all code fixture directories
    for fixture_dir in "$CODE_DIR"/*/; do
        if [ ! -d "$fixture_dir" ]; then
            continue
        fi
        local fixture_name
        fixture_name=$(basename "$fixture_dir")
        mkdir -p "$workdir/src/$fixture_name"
        cp -r "$fixture_dir"/* "$workdir/src/$fixture_name/" 2>/dev/null || true
    done

    local count
    count=$(find "$workdir/src" -name '*.py' 2>/dev/null | wc -l)
    echo "  injected $count code fixture files into test repo"

    # Stage the src directory
    git -C "$workdir" add src/ 2>/dev/null || true
}

# If called directly (not sourced), run setup
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    setup_code_fixtures "$@"
fi
