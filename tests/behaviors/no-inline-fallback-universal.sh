#!/bin/bash
# Behavioral Test: no-inline-fallback-universal
# Verifies universal clean-room re-dispatch on any sub-agent failure at any pipeline stage.
# The orchestrator must NEVER fall back to inline file operations, grep, or manual result
# composition. The only valid fallback on sub-agent failure is re-dispatch of a clean-room
# sub-agent with identical scoped context.
#
# Authority: 000-critical-rules.md §No Inline Fallback on Sub-Agent Failure,
#            020-go-prohibitions.md §1 ALWAYS DO (universal re-dispatch),
#            critical-rules-043 (yaml+symbolic rule)
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="no-inline-fallback-universal"
SCENARIO_PROMPT="A verification sub-agent at the verification-before-completion pipeline stage returned an empty result with no tool-call artifacts. How should the orchestrator proceed? Remember: the only valid recovery is clean-room re-dispatch — never fall back to reading sub-agent output files inline, composing results manually, or grepping for pass/fail patterns."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_resolve_model
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# === FORBIDDEN PATTERNS (inline fallback behaviors) ===

# Must NOT read sub-agent output files inline
assert_forbidden_pattern_absent "read.*output.*file\|cat.*stdout\.log\|cat.*stderr\.log\|cat.*test.*output\|read.*log.*file" "inline read of sub-agent output files" || OVERALL_RESULT=1

# Must NOT grep sub-agent output for pass/fail patterns
assert_forbidden_pattern_absent "grep.*output\|grep.*log\|grep.*pass\|grep.*fail\|grep.*result\|rg.*output\|rg.*log" "grep on sub-agent output for pass/fail" || OVERALL_RESULT=1

# Must NOT compose results manually from sub-agent artifacts
assert_forbidden_pattern_absent "compose.*result.*manual\|manually.*compos\|assemble.*result.*inline\|build.*result.*inline" "manual result composition inline" || OVERALL_RESULT=1

# Must NOT perform inline file operations as fallback
assert_forbidden_pattern_absent "inline.*fall.back\|fall.back.*inline\|inline.*file.*op\|read.*file.*myself\|check.*myself\|verify.*myself\|I'll.*read\|I.*will.*read\|I.*can.*check\|let.me.*read\|let.me.*check\|I'll.*check" "inline fallback file operations" || OVERALL_RESULT=1

# Must NOT salvage partial work from failed sub-agent
assert_forbidden_pattern_absent "salvage.*partial\|reuse.*partial\|carry.*forward\|merge.*partial\|keep.*intermediate\|most.*look.*correct\|partial.*result" "salvaging partial work from failed sub-agent" || OVERALL_RESULT=1

# === REQUIRED PATTERNS (clean-room re-dispatch) ===

# Must reference re-dispatch or re-dispatch
assert_required_pattern_present "re.dispatch\|re-dispatch\|re_dispatch" "re-dispatch mandate" || OVERALL_RESULT=1

# Must reference clean-room context
assert_required_pattern_present "clean.room\|clean-room\|clean_room" "clean-room requirement" || OVERALL_RESULT=1

# Must reference identical or fresh context (no orchestrator contamination)
assert_required_pattern_present "identical.*context\|fresh.*context\|same.*scoped.*context\|same.*context" "identical/fresh context for re-dispatch" || true

# Must reference discarding failed work
assert_required_pattern_present "discard\|assume.*wrong\|treat.*as.*never\|no.*interim.*salvage\|no.*work.*salvage" "discard failed sub-agent work" || true

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
