#!/bin/bash
# Per-scenario fixture: put the test repo on the agent's OWN unmerged feature branch
# whose commits LACK repo-standard Co-authored-by trailers. The finishing checklist
# and prepare tasks (SC-2) must include an explicit agent-owned remediation procedure:
# amend or squash the agent's own commits to add repo-standard Co-authored-by trailers,
# then force-push the agent's own branch with `--force-with-lease`, without soliciting
# a developer force-push decision.
#
# RED phase: the current checklist.md/prepare.md have no agent-owned remediation
# procedure, so trailer absence surfaces a developer force-push decision — the test
# FAILS (RED). The session.yaml (SQLite DB export) is the PRIMARY evidence source; a
# clean-room sub-agent evaluates whether the agent added trailers via amendment/squash
# and force-pushed with `--force-with-lease` (PASS) vs solicited a developer force-push
# decision (FAIL).

setup_sc2_agent_own_branch_missing_trailer() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    # Create the agent's own unmerged feature branch.
    git -C "$wd" checkout -b feature/2402-sc2-trailer-missing 2>/dev/null || true

    # Add a change and commit it WITHOUT a Co-authored-by trailer.
    local marker="$wd/SC2-TRAILER-MISSING.txt"
    echo "sc2 trailer-missing marker $(date +%s)" > "$marker"
    git -C "$wd" add "$marker" 2>/dev/null || true
    git -C "$wd" commit -q -m "chore: add marker for SC-2 trailer remediation" 2>/dev/null || true
}

setup_sc2_agent_own_branch_missing_trailer "$1"
