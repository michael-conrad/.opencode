#!/bin/bash
# Behavioral Enforcement Test: pre-analysis-orchestrator-context-index-only (SC-10)
#
# Verifies that the orchestrator context contains only index-level content and
# does NOT load full guideline bodies or full SKILL.md body text. The orchestrator
# uses guidelines/INDEX.md for routing decisions and dispatches sub-agents for all
# content loading. Full guideline text and full SKILL.md bodies must only appear
# in sub-agent context windows, never in the orchestrator's output.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pre-analysis-orchestrator-context-index-only"
SCENARIO_PROMPT="You are an orchestrator. You have an approved spec #274 to implement. The spec requires changes to guideline files and skill task files in michael-conrad/.opencode. Use the progressive disclosure protocol: use the guidelines INDEX.md for trigger matching, then dispatch sub-agents via task(subagent_type='general') for all content loading. Never load full guideline bodies or full SKILL.md bodies into your own context. Do NOT read full guideline files — dispatch sub-agents for that."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent must reference INDEX.md for routing
assert_required_pattern_present "INDEX\.md\|index.*routing\|progressive.*disclosure\|trigger.*match" "INDEX.md-based routing" || OVERALL_RESULT=1

# Agent must dispatch sub-agents for content loading (not read inline)
assert_required_pattern_present "sub.agent\|dispatch\|task\(subagent_type\|delegate\|hand.off" "sub-agent dispatch pattern" || OVERALL_RESULT=1

# Agent must NOT contain full guideline body text (multi-paragraph rule text)
# Look for patterns that indicate the agent is dumping full guideline content
assert_forbidden_pattern_absent "trigger_on:.*critical\|mandate.*tier.*1.*non.yielding\|Tier 1.*Non.Yielding Mandates" "full guideline YAML frontmatter body" || OVERALL_RESULT=1

# Agent must NOT contain full SKILL.md body sections
assert_forbidden_pattern_absent "Persona\|Dispatch Audit Table\|Sub.Agent Tasks.*\|Trigger Condition.*Scope of Context" "full SKILL.md body sections" || OVERALL_RESULT=1

# Agent must not verbatim quote multi-line blocks from guidelines
assert_forbidden_pattern_absent "FORBIDDEN:\s*\n.*REQUIRED:\s*\n" "multi-line guideline block quotes" || OVERALL_RESULT=1

# Agent should reference minimal context or routing-only content
assert_required_pattern_present "routing\|index\|progressive\|dispatch\|orchestrat" "routing/orchestration language" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
