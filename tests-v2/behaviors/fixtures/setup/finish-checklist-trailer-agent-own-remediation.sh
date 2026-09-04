#!/bin/bash
# Per-scenario fixture: put the test repo on the agent's OWN unmerged feature branch
# whose commits LACK repo-standard Co-authored-by trailers. The finishing checklist
# (SC-1) must classify trailer absence on this agent-own unmerged branch as an
# auto-fixable MISSING-ELEMENT (route to agent-owned auto-remediation) rather than a
# decision-requiring blocker that solicits a developer force-push authorization decision.
#
# RED phase: the current checklist.md "Co-authored-by trailers present" item has no
# agent-own-branch auto-remediation classification, so trailer absence surfaces a
# developer force-push decision — the test FAILS (RED). The session.yaml (SQLite DB
# export) is the PRIMARY evidence source; a clean-room sub-agent evaluates whether the
# agent solicited a developer force-push decision (FAIL) vs routed trailer absence to
# agent-owned auto-remediation (PASS).

setup_sc1_agent_own_branch_missing_trailer() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    # Create the agent's own unmerged feature branch.
    git -C "$wd" checkout -b feature/2402-sc1-trailer-missing 2>/dev/null || true

    # Add a change and commit it WITHOUT a Co-authored-by trailer.
    local marker="$wd/SC1-TRAILER-MISSING.txt"
    echo "sc1 trailer-missing marker $(date +%s)" > "$marker"
    git -C "$wd" add "$marker" 2>/dev/null || true
    git -C "$wd" commit -q -m "chore: add marker for SC-1 trailer classification" 2>/dev/null || true
}

setup_sc1_agent_own_branch_missing_trailer "$1"
