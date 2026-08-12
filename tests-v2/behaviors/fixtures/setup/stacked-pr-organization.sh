#!/bin/bash
# Per-scenario fixture for stacked-pr-organization.
# Commits the harness-staged .issues/ fixture files so the agent's git-workflow
# pre-work trunk-tip verification passes (pre-work BLOCKs on a dirty tree).
# Usage: this file is sourced by the harness with $attempt_workdir as $1.
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

setup_clean_issues_commit() {
    local wd="$1"
    git -C "$wd" add -A 2>/dev/null || true
    git -C "$wd" commit -q --allow-empty -m "chore: commit fixture issues" 2>/dev/null || true
}

setup_clean_issues_commit "$1"
