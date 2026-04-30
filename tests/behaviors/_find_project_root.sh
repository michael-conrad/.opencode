#!/bin/bash
# Shared shell function for project root resolution.
# Implements the walk-up pattern from 210-scripting.md:
# Walk up from the script's directory until basename(pwd) == ".opencode",
# then return its parent (the project root).
#
# Source this file in test/tool scripts:
#   source "$(dirname "${BASH_SOURCE[0]}")/_find_project_root.sh"
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

_find_project_root() {
    local current
    current="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
    while [ "$current" != "/" ]; do
        if [ "$(basename "$current")" = ".opencode" ]; then
            echo "$(dirname "$current")"
            return 0
        fi
        current="$(dirname "$current")"
    done
    echo "ERROR: Could not find project root (.opencode directory not found)" >&2
    return 1
}