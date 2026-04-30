#!/bin/bash
# Content-Verification Test: Submodule Sub-Agent Architecture
# Issue #215 - Verifies that each rewritten task file declares
# sub-agent boundaries with must_receive and must_not_receive.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../behaviors/_find_project_root.sh"
PROJECT_ROOT="$(_find_project_root)"
SKILLS_DIR="$PROJECT_ROOT/.opencode/skills/git-workflow"

OVERALL_RESULT=0

echo "=== Content-Verification Test: Submodule Sub-Agent Architecture ==="

# SC-17: ALL submodule git operations MUST be dispatched to sub-agents
# Check that task files reference sub-agent dispatch for submodule operations
FILES_WITH_SUBAGENT_DISPATCH=(
    "$SKILLS_DIR/tasks/pre-work.md"
    "$SKILLS_DIR/tasks/review-prep/push-and-cleanup.md"
    "$SKILLS_DIR/tasks/pr-creation/enforcement-gate.md"
    "$SKILLS_DIR/tasks/cleanup/branch-cleanup.md"
)

for f in "${FILES_WITH_SUBAGENT_DISPATCH[@]}"; do
    basename_f=$(basename "$f")
    if grep -q "sub-agent\|Sub-Agent\|MUST NOT.*inline\|dispatch.*sub-agent" "$f"; then
        echo "PASS: SC-17 — $basename_f contains sub-agent dispatch requirement"
    else
        echo "FAIL: SC-17 — $basename_f missing sub-agent dispatch requirement"
        OVERALL_RESULT=1
    fi
done

# SC-18: Each rewritten task file declares must_receive and must_not_receive
for f in "${FILES_WITH_SUBAGENT_DISPATCH[@]}"; do
    basename_f=$(basename "$f")
    if grep -q "must_receive\|must_not_receive\|Sub-Agent Boundary" "$f"; then
        echo "PASS: SC-18 — $basename_f declares sub-agent boundary"
    else
        echo "FAIL: SC-18 — $basename_f missing sub-agent boundary declaration"
        OVERALL_RESULT=1
    fi
done

# SC-19: Sub-agents return result contracts with status, submodule_results, evidence_artifacts
COMMANDS_DIR="$PROJECT_ROOT/.opencode/commands"
CMDS="submodule-tag-prework submodule-tag-feat submodule-verify"
for cmd in $CMDS; do
    if [ -f "$COMMANDS_DIR/${cmd}.md" ]; then
        if grep -q "status:\|submodule_results:\|evidence_artifacts:" "$COMMANDS_DIR/${cmd}.md"; then
            echo "PASS: SC-19 — $cmd.md contains result contract fields"
        else
            echo "FAIL: SC-19 — $cmd.md missing result contract fields"
            OVERALL_RESULT=1
        fi
    else
        echo "FAIL: SC-19 — $cmd.md does not exist"
        OVERALL_RESULT=1
    fi
done

# Also check branch-cleanup for submodule-dev-restore result contract
if grep -q "status:\|submodule_results:\|evidence_artifacts:" "$SKILLS_DIR/tasks/cleanup/branch-cleanup.md"; then
    echo "PASS: SC-19 — branch-cleanup.md contains result contract fields"
else
    echo "FAIL: SC-19 — branch-cleanup.md missing result contract fields for submodule-dev-restore"
    OVERALL_RESULT=1
fi

# SC-20: Sub-agents MUST NOT receive implementation context
for f in "${FILES_WITH_SUBAGENT_DISPATCH[@]}"; do
    basename_f=$(basename "$f")
    if grep -q "must_not_receive\|Implementation context.*agent memory\|full task file" "$f"; then
        echo "PASS: SC-20 — $basename_f declares must_not_receive constraints"
    else
        echo "FAIL: SC-20 — $basename_f missing must_not_receive constraints"
        OVERALL_RESULT=1
    fi
done

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: Content-verification — all sub-agent architecture checks passed"
else
    echo "FAIL: Content-verification — some sub-agent architecture checks failed"
fi

exit $OVERALL_RESULT