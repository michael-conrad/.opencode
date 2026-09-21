#!/bin/bash
# Per-scenario fixture for 2437-sc1-pr-creation-no-card-forwarding.
# Creates the feature branch the PR-creation prompt references so the
# orchestrator reaches the pr-creation dispatch decision instead of blocking
# on a missing branch (fixture-state defect, R-18 class).
# See .opencode/tests-v2/AGENTS.md §3 Step 0b for the fixture script contract.
setup_2437_sc1_branch() {
    local wd="$1"
    git -C "$wd" config user.email "opencode-test-user@example.com" 2>/dev/null || true
    git -C "$wd" config user.name "opencode-test-user" 2>/dev/null || true
    git -C "$wd" checkout -b feature/payment-gateway 2>/dev/null || true
    echo "# payment gateway integration stub" > "$wd/payment-gateway.txt"
    git -C "$wd" add payment-gateway.txt 2>/dev/null || true
    git -C "$wd" commit -m "feat: add payment gateway integration stub" 2>/dev/null || true
    git -C "$wd" checkout - 2>/dev/null || true
}
setup_2437_sc1_branch "$1"
