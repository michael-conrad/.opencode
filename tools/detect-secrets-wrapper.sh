#!/usr/bin/env bash
# Wrapper for detect-secrets pre-commit hook.
# Skips scanning unless .secrets.baseline exists in the project root.
# When present, enforces the baseline against staged files.
if [[ "${1:-}" == "--description" ]]; then
    echo "Wrapper for detect-secrets pre-commit hook."
    exit 0
fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PARENT="$(dirname "$PROJECT_DIR")"
    if [ "$PARENT" = "$PROJECT_DIR" ]; then
        echo "FATAL: Could not find .opencode/ directory" >&2
        exit 1
    fi
    PROJECT_DIR="$PARENT"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"
test -f "$PROJECT_DIR/.secrets.baseline" || exit 0
detect-secrets-hook --baseline .secrets.baseline "$@"