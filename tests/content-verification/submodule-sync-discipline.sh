#!/bin/bash
# Content-Verification Test: Submodule Sync Discipline
# Issue #215 - Verifies that tag-based submodule hash permanence
# replaces dependency-sync PRs in all affected files.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(cd "$SCRIPT_DIR/../../skills/git-workflow" && pwd)"
GUIDELINES_DIR="$(cd "$SCRIPT_DIR/../../guidelines" && pwd)"
COMMANDS_DIR="$(cd "$SCRIPT_DIR/../../commands" 2>/dev/null && pwd || echo "NOT_FOUND")"
AGENTS_FILE="$(cd "$SCRIPT_DIR/../../.." && pwd)/AGENTS.md"

OVERALL_RESULT=0

echo "=== Content-Verification Test: Submodule Sync Discipline ==="

# SC-1: Pre-work MUST tag each submodule at dev tip with <parent-repo>/<issue-number> format
if grep -q "parent-repo.*issue-number\|<parent-repo>/<issue-number>" "$SKILLS_DIR/tasks/pre-work.md"; then
    echo "PASS: SC-1 — pre-work.md contains tag format reference"
else
    echo "FAIL: SC-1 — pre-work.md missing tag format reference"
    OVERALL_RESULT=1
fi

# SC-2: Pre-work MUST NOT create bump commits
if grep -q "MUST NOT.*git add.*submodule\|MUST NOT.*bump commit\|tag replaces.*bump" "$SKILLS_DIR/tasks/pre-work.md"; then
    echo "PASS: SC-2 — pre-work.md contains bump commit prohibition"
else
    echo "FAIL: SC-2 — pre-work.md missing bump commit prohibition"
    OVERALL_RESULT=1
fi

# SC-3: Development MUST leave submodule hashes dirty
if grep -q "leave.*dirty\|dirty.*hash\|no mid-implementation\|no.*resync" "$SKILLS_DIR/tasks/pre-work.md"; then
    echo "PASS: SC-3 — pre-work.md contains dirty hash instruction"
else
    echo "FAIL: SC-3 — pre-work.md missing dirty hash instruction"
    OVERALL_RESULT=1
fi

# SC-4: Feature branch push tags with <parent-repo>/<issue-number>-<sub> format
if grep -q "parent-repo.*issue-number.*sub\|<parent-repo>/<issue-number>-<sub>" "$SKILLS_DIR/tasks/review-prep/push-and-cleanup.md"; then
    echo "PASS: SC-4 — push-and-cleanup.md contains feature tag format reference"
else
    echo "FAIL: SC-4 — push-and-cleanup.md missing feature tag format reference"
    OVERALL_RESULT=1
fi

# SC-5: PR-time verification confirms hash reachability (liveness check)
if grep -q "liveness\|reachability\|reachable" "$SKILLS_DIR/tasks/pr-creation/enforcement-gate.md"; then
    echo "PASS: SC-5 — enforcement-gate.md contains liveness check reference"
else
    echo "FAIL: SC-5 — enforcement-gate.md missing liveness check reference"
    OVERALL_RESULT=1
fi

# SC-6: Cleanup restores submodules to dev tip without dependency-sync PR
if grep -q "dev-restore\|restore.*dev\|submodule-dev-restore" "$SKILLS_DIR/tasks/cleanup/branch-cleanup.md"; then
    echo "PASS: SC-6 — branch-cleanup.md contains dev-restore reference"
else
    echo "FAIL: SC-6 — branch-cleanup.md missing dev-restore reference"
    OVERALL_RESULT=1
fi

# SC-6 (continued): No dependency-sync PR in cleanup
if ! grep -q "dependency-sync\|dep-sync/" "$SKILLS_DIR/tasks/cleanup/branch-cleanup.md"; then
    echo "PASS: SC-6 — branch-cleanup.md has no dependency-sync PR reference"
else
    echo "FAIL: SC-6 — branch-cleanup.md still contains dependency-sync PR reference"
    OVERALL_RESULT=1
fi

# SC-7: dependency-sync task MUST be removed
if [ ! -f "$SKILLS_DIR/tasks/dependency-sync.md" ]; then
    echo "PASS: SC-7 — dependency-sync.md is removed"
else
    echo "FAIL: SC-7 — dependency-sync.md still exists"
    OVERALL_RESULT=1
fi

# SC-8: Tags MUST use <parent-repo>/ naming
if [ -f "$COMMANDS_DIR/submodule-tag-prework.md" ] && grep -q "<parent-repo>/<issue-number>" "$COMMANDS_DIR/submodule-tag-prework.md"; then
    echo "PASS: SC-8 — command file contains tag naming format"
else
    echo "FAIL: SC-8 — command file missing tag naming format"
    OVERALL_RESULT=1
fi

# SC-9: Pre-work Step 3.5 replaced with sub-agent dispatch
if grep -q "submodule-tag-prework\|sub-agent.*dispatch\|MUST NOT perform.*git tag.*submodule.*inline" "$SKILLS_DIR/tasks/pre-work.md"; then
    echo "PASS: SC-9 — pre-work.md dispatches submodule-tag-prework sub-agent"
else
    echo "FAIL: SC-9 — pre-work.md missing sub-agent dispatch for submodule tags"
    OVERALL_RESULT=1
fi

# SC-10: Review-prep Step 0 dispatches submodule-feature-push sub-agent
if grep -q "submodule-feature-push\|sub-agent.*dispatch\|MUST NOT perform.*git.*push.*submodule.*inline" "$SKILLS_DIR/tasks/review-prep/push-and-cleanup.md"; then
    echo "PASS: SC-10 — push-and-cleanup.md dispatches submodule-feature-push sub-agent"
else
    echo "FAIL: SC-10 — push-and-cleanup.md missing sub-agent dispatch"
    OVERALL_RESULT=1
fi

# SC-11: Enforcement-gate Step 0 dispatches submodule-liveness-check sub-agent
if grep -q "submodule-liveness-check\|sub-agent.*dispatch\|MUST NOT.*inline" "$SKILLS_DIR/tasks/pr-creation/enforcement-gate.md"; then
    echo "PASS: SC-11 — enforcement-gate.md dispatches submodule-liveness-check sub-agent"
else
    echo "FAIL: SC-11 — enforcement-gate.md missing sub-agent dispatch"
    OVERALL_RESULT=1
fi

# SC-12: Cleanup Step 5.6 MUST be removed
if ! grep -q "5\.6\|Step 5\.6\|dependency-sync PR\|dep-sync" "$SKILLS_DIR/tasks/cleanup/branch-cleanup.md"; then
    echo "PASS: SC-12 — branch-cleanup.md has no Step 5.6 or dependency-sync reference"
else
    echo "FAIL: SC-12 — branch-cleanup.md still contains Step 5.6 or dependency-sync reference"
    OVERALL_RESULT=1
fi

# SC-13: Opencode commands exist for all three submodule operations
CMDS="submodule-tag-prework submodule-tag-feat submodule-verify"
for cmd in $CMDS; do
    if [ -f "$COMMANDS_DIR/${cmd}.md" ]; then
        echo "PASS: SC-13 — command file $cmd.md exists"
    else
        echo "FAIL: SC-13 — command file $cmd.md missing"
        OVERALL_RESULT=1
    fi
done

# SC-14: SKILL.md has dependency-sync removed and Sub-Agent Task Table with 4 sub-agents
if ! grep -q "dependency-sync" "$SKILLS_DIR/SKILL.md"; then
    echo "PASS: SC-14 — SKILL.md has no dependency-sync entry"
else
    echo "FAIL: SC-14 — SKILL.md still contains dependency-sync reference"
    OVERALL_RESULT=1
fi

if grep -q "submodule-tag-prework\|submodule-feature-push\|submodule-liveness-check\|submodule-dev-restore" "$SKILLS_DIR/SKILL.md"; then
    echo "PASS: SC-14 — SKILL.md contains submodule sub-agent entries"
else
    echo "FAIL: SC-14 — SKILL.md missing submodule sub-agent entries"
    OVERALL_RESULT=1
fi

# SC-15: AGENTS.md submodule discipline reflects tag-based workflow
if grep -q "tag-based\|tag.*dev tip\|tag.*permanence\|no dependency-sync PR" "$AGENTS_FILE"; then
    echo "PASS: SC-15 — AGENTS.md contains tag-based workflow reference"
else
    echo "FAIL: SC-15 — AGENTS.md missing tag-based workflow reference"
    OVERALL_RESULT=1
fi

# SC-16: Provenance tracking updated for feature-branch pushes
if grep -q "feature-branch\|feature branch\|tip tag\|tip-tag" "$SKILLS_DIR/tasks/provenance/dev-push-provenance.md"; then
    echo "PASS: SC-16 — dev-push-provenance.md contains feature-branch push reference"
else
    echo "FAIL: SC-16 — dev-push-provenance.md missing feature-branch push reference"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: Content-verification — all submodule sync discipline checks passed"
else
    echo "FAIL: Content-verification — some submodule sync discipline checks failed"
fi

exit $OVERALL_RESULT