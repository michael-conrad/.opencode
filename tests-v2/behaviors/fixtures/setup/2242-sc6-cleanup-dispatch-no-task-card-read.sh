#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture: set up a merged branch + referenced issue for SC-6.
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash:0731)
# SC-6 verifies that dispatching "cleanup from git-workflow-cleanup" produces a
# sub-agent result contract without the orchestrator having read any task card.
# Without a merged branch and an open issue, the orchestrator halts asking for an
# issue number and never dispatches — so a result contract is never produced.
# This fixture creates:
#   - feature/2242-merged — a branch with a commit, merged into main (cleanup target)
#   - an open .issues/2242/ issue referencing the cleanup (via fixture injection)
setup_merged_cleanup_target() {
    local wd="$1"

    # Create a feature branch with a commit
    git -C "$wd" checkout -b feature/2242-merged main 2>/dev/null || true
    echo "merged branch work" > "$wd/merged-work.txt"
    git -C "$wd" add merged-work.txt 2>/dev/null || true
    git -C "$wd" commit -m "feat: merged work for cleanup" 2>/dev/null || true

    # Merge it into main, leaving the feature branch as a merged branch to delete
    git -C "$wd" checkout main 2>/dev/null || true
    git -C "$wd" merge --no-ff feature/2242-merged -m "merge: feature/2242-merged" 2>/dev/null || true

    # Ensure .issues/ exists with an open issue entry the orchestrator can close
    mkdir -p "$wd/.issues/open/2242"
    if [ ! -f "$wd/.issues/open/2242/spec.md" ]; then
        cat > "$wd/.issues/open/2242/spec.md" <<'EOF'
## Problem

A PR for the opencode-config repo was merged and its cleanup (delete merged branch, close issue) is pending.

## Success Criteria

- [ ] Cleanup dispatched via git-workflow-cleanup without orchestrator task-card reads
EOF
    fi

    git -C "$wd" add -A 2>/dev/null || true
    git -C "$wd" commit -m "chore: cleanup fixture state" 2>/dev/null || true
}
setup_merged_cleanup_target "$1"
