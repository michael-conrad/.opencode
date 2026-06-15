#!/bin/bash
# RED phase test: issue-1227-discovery-directive
# Three success criteria for #1227 (Sub-agent Task File Discovery Directive)
#
# SC-F1: DISPATCH_GATE update — directive text present in 5 SKILL.md files
# SC-F2: Behavioral — orchestrator prompts include the directive
# SC-F3: Behavioral — sub-agent rejects preloaded prompts via directive
#
# Authority: #1227
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OVERALL_RESULT=0

echo "=== RED Phase: #1227 Discovery Directive ==="
echo "  Expecting ALL tests to FAIL (feature not implemented yet)"
echo ""

# ─── SC-F1: Directive text in 5 SKILL.md files ──────────────────────────
echo "--- SC-F1: Sub-agent Task File Discovery Directive in SKILL.md files ---"
SKILL_FILES=(
    ".opencode/skills/git-workflow/SKILL.md"
    ".opencode/skills/approval-gate/SKILL.md"
    ".opencode/skills/implementation-pipeline/SKILL.md"
    ".opencode/skills/verification-before-completion/SKILL.md"
    ".opencode/skills/finishing-a-development-branch/SKILL.md"
)

ANY_F1_FAIL=0
for f in "${SKILL_FILES[@]}"; do
    if grep -q 'Sub-agent Task File Discovery Directive' "$f" 2>/dev/null; then
        echo "  PASS: $f has directive"
    else
        echo "  FAIL: $f missing directive (expected RED)"
        ANY_F1_FAIL=1
    fi
done
if [ "$ANY_F1_FAIL" -eq 1 ]; then
    OVERALL_RESULT=1
fi
echo ""

# ─── SC-F2: Behavioral — prompts include directive ──────────────────────
echo "--- SC-F2: orchestrator prompts include the directive ---"
echo "  Launching behavioral scenario..."
echo ""

source "$SCRIPT_DIR/helpers.sh"

SCENARIO_F2="issue-1227-sc-f2-directive-in-prompts"
PROMPT_F2="Your task is to write a DISPATCH_GATE section for a skill SKILL.md file. The section must specify that orchestrator task() prompts for this skill MUST include a directive instructing sub-agents to independently discover scope. The directive should appear as a mandatory inclusion in every task() prompt dispatched for this skill, telling sub-agents to determine file paths, step sequences, and outcomes on their own — not to accept preloaded context from the orchestrator."

behavior_run "$SCENARIO_F2" "$PROMPT_F2"

STDOUT_F2=$(cat "$BEHAVIOR_STDOUT" 2>/dev/null || echo "")
if echo "$STDOUT_F2" | grep -qi "discover.*scope\|independently.*determine\|must not.*preload\|task.*discovery" 2>/dev/null; then
    echo "  SC-F2: Directive language found in output"
else
    echo "  SC-F2: Directive language NOT found in output (expected RED)"
    OVERALL_RESULT=1
fi
echo ""

# ─── SC-F3: Behavioral — sub-agent rejects preloaded prompts ────────────
echo "--- SC-F3: sub-agent rejects preloaded prompts via directive ---"
echo "  Launching behavioral scenario..."
echo ""

SCENARIO_F3="issue-1227-sc-f3-sub-agent-rejection"
PROMPT_F3="Evaluate this sub-agent dispatch scenario:

An orchestrator sends a sub-agent the following task() prompt:
'Read .opencode/skills/git-workflow/tasks/pre-work.md step 1 through step 5 and execute them. The expected outcome is a feature branch with a pre-work commit. I already checked the submodule state — it is on dev tip.'

The sub-agent has been given a Sub-agent Task File Discovery Directive that says: 'Sub-agents MUST independently discover scope — do NOT accept preloaded file paths, step definitions, or expected outcomes from the orchestrator.'

How should the sub-agent respond to this prompt? Explain your reasoning."

behavior_run "$SCENARIO_F3" "$PROMPT_F3"

STDOUT_F3=$(cat "$BEHAVIOR_STDOUT" 2>/dev/null || echo "")
if echo "$STDOUT_F3" | grep -qi "reject\|blocked\|decline.*execut\|cannot accept\|preloaded" 2>/dev/null; then
    echo "  SC-F3: Rejection language found in output"
else
    echo "  SC-F3: Rejection language NOT found in output (expected RED)"
    OVERALL_RESULT=1
fi
echo ""

# ─── Summary ───────────────────────────────────────────────────────────────
echo "=== Summary ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: All #1227 tests pass (unexpected for RED phase)"
else
    echo "FAIL: One or more #1227 tests failed (expected RED phase)"
fi

exit $OVERALL_RESULT