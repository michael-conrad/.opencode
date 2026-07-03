#!/bin/bash
# RED phase: content-verification test for researcher merge (SC-5)
# Verifies researcher/SKILL.md exists and research/SKILL.md does NOT
# mention researcher's purpose. MUST FAIL in RED phase (baseline state).
#
# SC-5: Cross-skill conflicts resolved — researcher merged into research
# SC-5: grep -c "researcher/SKILL.md" returns > 0 (file exists — RED)
# SC-5: grep -c "implementation-pipeline.*remediation" research/SKILL.md returns 0 (not updated — RED)
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

SCENARIO_NAME="researcher-merge"
OVERALL_RESULT=0

echo "=== RED Phase Test: Researcher Merge (SC-5) ==="

# ============================================================
# SC-5: researcher/SKILL.md exists (RED state — not yet deleted)
# ============================================================
echo ""
echo "--- SC-5: researcher/SKILL.md exists ---"

RESEARCHER_FILE="$PROJECT_DIR/.opencode/skills/researcher/SKILL.md"
if [ -f "$RESEARCHER_FILE" ]; then
    echo "  FOUND: researcher/SKILL.md exists — RED state confirmed (not yet deleted)"
    echo "  RESULT: FAIL (expected RED — file still present)"
    SC1_RESULT=1
    OVERALL_RESULT=1
else
    echo "  NOT FOUND: researcher/SKILL.md is missing"
    echo "  RESULT: PASS (file already deleted — unexpected for RED)"
    SC1_RESULT=0
fi

# ============================================================
# SC-5: research/SKILL.md description does NOT mention researcher's purpose
# ============================================================
echo ""
echo "--- SC-5: research/SKILL.md description does NOT mention researcher's purpose ---"

RESEARCH_FILE="$PROJECT_DIR/.opencode/skills/research/SKILL.md"
# researcher's purpose includes "implementation-pipeline" and "remediation" context
SC2_COUNT=$(grep -c "implementation-pipeline.*remediation\|remediation.*implementation-pipeline\|remediation scope\|remediation-scope" "$RESEARCH_FILE" 2>/dev/null || true)

if [ "$SC2_COUNT" -eq 0 ]; then
    echo "  NOT FOUND: research/SKILL.md does not mention researcher's remediation purpose — RED state confirmed"
    echo "  RESULT: FAIL (expected RED — description not yet updated)"
    SC2_RESULT=1
    OVERALL_RESULT=1
else
    echo "  FOUND: research/SKILL.md mentions researcher's purpose ($SC2_COUNT match(es))"
    echo "  RESULT: PASS (description already updated — unexpected for RED)"
    SC2_RESULT=0
fi

# ============================================================
# Report
# ============================================================
echo ""
echo "=== RED Phase Results ==="
echo "SC-5 (researcher/SKILL.md exists): $([ "$SC1_RESULT" -eq 0 ] && echo "PASS (deleted)" || echo "FAIL (present — expected RED)")"
echo "SC-5 (research description not updated): $([ "$SC2_RESULT" -eq 0 ] && echo "PASS (updated)" || echo "FAIL (not updated — expected RED)")"

# Write artifact output
mkdir -p "$PROJECT_DIR/tmp/1602/artifacts"
cat > "$PROJECT_DIR/tmp/1602/artifacts/researcher-merge-red-output.log" << LOGEOF
=== RED Phase Test: Researcher Merge (SC-5) ===
SC-5 (researcher/SKILL.md exists):
  file: $RESEARCHER_FILE
  exists: $([ -f "$RESEARCHER_FILE" ] && echo "yes" || echo "no")
  result: $([ "$SC1_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL")

SC-5 (research description not updated):
  file: $RESEARCH_FILE
  grep matches: $SC2_COUNT
  result: $([ "$SC2_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL")

OVERALL: $([ "$OVERALL_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL (expected RED — baseline state confirmed)")
LOGEOF

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME (all SCs pass — unexpected for RED phase)"
else
    echo "FAIL: $SCENARIO_NAME (expected RED behavior — baseline state confirmed)"
fi

exit $OVERALL_RESULT
