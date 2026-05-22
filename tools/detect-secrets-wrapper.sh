#!/usr/bin/env bash
# Wrapper for detect-secrets pre-commit hook.
# Skips scanning unless .secrets.baseline exists in the project root.
# When present, enforces the baseline against staged files.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"
test -f "$PROJECT_DIR/.secrets.baseline" || exit 0
detect-secrets-hook --baseline .secrets.baseline "$@"