#!/bin/bash
# Shared fixture setup for 2219 dead-branch tests (SC-6/7/8/9/10).
# Creates two branches in the test repo:
#   feature/2219-sub-pointer-only — only submodule pointer changes (dead branch)
#   feature/2219-real-changes    — real code + submodule pointer changes (live branch)
# Usage: source this file, then call setup_dead_branches <workdir>

setup_dead_branches() {
    local wd="$1"

    # Dead branch: only submodule pointer change
    git -C "$wd" checkout -b feature/2219-sub-pointer-only main 2>/dev/null || true
    echo "# dirty submodule pointer" >> "$wd/.gitmodules"
    git -C "$wd" add .gitmodules 2>/dev/null || true
    git -C "$wd" commit -m "chore: update submodule pointer" 2>/dev/null || true
    git -C "$wd" checkout main 2>/dev/null || true

    # Live branch: real code + submodule pointer change
    git -C "$wd" checkout -b feature/2219-real-changes main 2>/dev/null || true
    mkdir -p "$wd/src"
    echo "real code change" > "$wd/src/test.txt"
    echo "# dirty submodule pointer" >> "$wd/.gitmodules"
    git -C "$wd" add src/test.txt .gitmodules 2>/dev/null || true
    git -C "$wd" commit -m "feat: real change plus submodule update" 2>/dev/null || true
    git -C "$wd" checkout main 2>/dev/null || true
}
