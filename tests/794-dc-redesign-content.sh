#!/bin/bash
# Content-Verification Test: 794-dc-redesign
#
# Three-tier testing architecture:
#   Tier 1 — Structural (bash ls/wc): File existence, word counts
#   Tier 2 — String (bash grep): Presence/absence of specific text patterns
#   Tier 3 — Semantic (task() sub-agents): AI reads files and makes analytical judgments
#
# This script covers Tiers 1 and 2. Tier 3 (semantic evaluation) runs via
# task() sub-agent dispatch outside this script — see the Semantic SC section
# at the end for which SCs get supplementary AI evaluation.
#
# SC-14 is behavioral — tested in 794-dc-redesign-orchestration.sh
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# The divide-and-conquer skill lives in the .opencode submodule
DC_SKILL_DIR="$PROJECT_DIR/.opencode/skills/divide-and-conquer"
SKILL_MD="$DC_SKILL_DIR/SKILL.md"
ASSEMBLE_WORK="$DC_SKILL_DIR/tasks/assemble-work.md"

OVERALL_RESULT=0

echo "=== Content-Verification Test: 794-dc-redesign ==="
echo ""

# ============================================================
# Tier 1: Structural assertions (filesystem state)
# ============================================================

# SC-2: assemble-work.md is under 3000 words (word count is filesystem state)
echo "--- SC-2: assemble-work.md word count ≤ 3000 ---"
SC2_WORDS=$(wc -w < "$ASSEMBLE_WORK" 2>/dev/null || echo "0")
SC2_WORDS=$(echo "$SC2_WORDS" | tr -d '[:space:]')
SC2_WORDS=${SC2_WORDS:-0}
if [ "$SC2_WORDS" -le 3000 ]; then
    echo "PASS: SC-2 — assemble-work.md is $SC2_WORDS words (≤ 3000)"
else
    echo "FAIL: SC-2 — assemble-work.md is $SC2_WORDS words (expected ≤ 3000)"
    OVERALL_RESULT=1
fi

# SC-7: Deleted task files do not exist (filesystem state)
echo "--- SC-7: Deleted task files don't exist ---"
DELETED_FILES=(
    "tasks/orchestrate.md"
    "tasks/dispatch.md"
    "tasks/merge.md"
    "tasks/completion.md"
    "tasks/assess.md"
    "tasks/decompose.md"
    "tasks/implementer-prompt.md"
    "tasks/spec-reviewer-prompt.md"
    "tasks/code-quality-reviewer-prompt.md"
    "tasks/purification-and-enforcement.md"
    "tasks/context-passing.md"
)
SC7_MISSING=0
SC7_TOTAL=${#DELETED_FILES[@]}
for f in "${DELETED_FILES[@]}"; do
    if [ ! -f "$DC_SKILL_DIR/$f" ]; then
        SC7_MISSING=$((SC7_MISSING + 1))
    else
        echo "  FAIL: $f still exists"
    fi
done
if [ "$SC7_MISSING" -eq "$SC7_TOTAL" ]; then
    echo "PASS: SC-7 — All $SC7_MISSING deleted task files are gone"
else
    echo "FAIL: SC-7 — Only $SC7_MISSING/$SC7_TOTAL deleted task files are gone"
    OVERALL_RESULT=1
fi

# SC-12: Enforcement reference docs exist (filesystem state)
echo "--- SC-12: Enforcement reference docs exist ---"
SC12_CP=$(test -f "$DC_SKILL_DIR/enforcement/context-passing.md" && echo "1" || echo "0")
SC12_OS=$(test -f "$DC_SKILL_DIR/enforcement/overflow-signal.md" && echo "1" || echo "0")
SC12_WSV=$(test -f "$DC_SKILL_DIR/enforcement/work-state-verification.md" && echo "1" || echo "0")
if [ "$SC12_CP" -eq 1 ] && [ "$SC12_OS" -eq 1 ] && [ "$SC12_WSV" -eq 1 ]; then
    echo "PASS: SC-12 — All 3 enforcement reference docs exist"
else
    echo "FAIL: SC-12 — Missing enforcement docs: context-passing($SC12_CP), overflow-signal($SC12_OS), work-state-verification($SC12_WSV)"
    OVERALL_RESULT=1
fi

# SC-13: completion-checkpoint.md and result-validation.md are removed (filesystem state)
echo "--- SC-13: Folded enforcement files removed ---"
SC13_CC=$(test -f "$DC_SKILL_DIR/enforcement/completion-checkpoint.md" && echo "EXISTS" || echo "GONE")
SC13_RV=$(test -f "$DC_SKILL_DIR/enforcement/result-validation.md" && echo "EXISTS" || echo "GONE")
if [ "$SC13_CC" = "GONE" ] && [ "$SC13_RV" = "GONE" ]; then
    echo "PASS: SC-13 — completion-checkpoint.md and result-validation.md are removed"
else
    echo "FAIL: SC-13 — completion-checkpoint($SC13_CC), result-validation($SC13_RV)"
    OVERALL_RESULT=1
fi

# ============================================================
# Tier 2: String assertions (grep patterns — fast, deterministic)
# ============================================================

# SC-1: SKILL.md contains no references to deleted task files
# [Supplementary Tier 3: AI semantic — verify only assemble-work is routed]
echo "--- SC-1: No deleted task file references in SKILL.md ---"
DELETED_TASKS="\-\-task orchestrate|\-\-task dispatch|\-\-task merge|\-\-task completion|\-\-task assess|\-\-task decompose|\-\-task context-passing|\-\-task purification|\-\-task implementer-prompt|\-\-task spec-reviewer-prompt|\-\-task code-quality-reviewer-prompt|tasks/orchestrate|tasks/dispatch|tasks/merge|tasks/completion|tasks/assess|tasks/decompose|tasks/context-passing|tasks/purification|tasks/implementer-prompt|tasks/spec-reviewer-prompt|tasks/code-quality-reviewer-prompt|task.*orchestrate|task.*dispatch|task.*assess|task.*decompose"
SC1_COUNT=$(grep -cE "$DELETED_TASKS" "$SKILL_MD" 2>/dev/null || true)
SC1_COUNT=$(echo "$SC1_COUNT" | head -1 | tr -d '[:space:]')
SC1_COUNT=${SC1_COUNT:-0}
if [ "$SC1_COUNT" -eq 0 ]; then
    echo "PASS: SC-1 — SKILL.md has no references to deleted task files"
else
    echo "FAIL: SC-1 — SKILL.md has $SC1_COUNT reference(s) to deleted task files (expected 0)"
    OVERALL_RESULT=1
fi

# SC-3: assemble-work.md contains completeness-gate, adversarial-audit, verification-before-completion
# [Supplementary Tier 3: AI semantic — verify verification layers are properly integrated into pipeline]
echo "--- SC-3: assemble-work.md has verification layer references ---"
SC3_CG=$(grep -c "completeness-gate" "$ASSEMBLE_WORK" 2>/dev/null || true)
SC3_CG=$(echo "$SC3_CG" | head -1 | tr -d '[:space:]')
SC3_CG=${SC3_CG:-0}
SC3_AA=$(grep -c "adversarial-audit" "$ASSEMBLE_WORK" 2>/dev/null || true)
SC3_AA=$(echo "$SC3_AA" | head -1 | tr -d '[:space:]')
SC3_AA=${SC3_AA:-0}
SC3_VBC=$(grep -c "verification-before-completion" "$ASSEMBLE_WORK" 2>/dev/null || true)
SC3_VBC=$(echo "$SC3_VBC" | head -1 | tr -d '[:space:]')
SC3_VBC=${SC3_VBC:-0}
if [ "$SC3_CG" -ge 2 ] && [ "$SC3_AA" -ge 2 ] && [ "$SC3_VBC" -ge 2 ]; then
    echo "PASS: SC-3 — completeness-gate($SC3_CG), adversarial-audit($SC3_AA), verification-before-completion($SC3_VBC)"
else
    echo "FAIL: SC-3 — completeness-gate($SC3_CG, need ≥2), adversarial-audit($SC3_AA, need ≥2), verification-before-completion($SC3_VBC, need ≥2)"
    OVERALL_RESULT=1
fi

# SC-4: assemble-work.md has result contract schema with all 5 status values + VbA
# [Supplementary Tier 3: AI semantic — verify result contract is complete and correctly structured]
echo "--- SC-4: Result contract schema in assemble-work.md ---"
SC4_DONE=$(grep -c "DONE" "$ASSEMBLE_WORK" 2>/dev/null || true)
SC4_DONE=$(echo "$SC4_DONE" | head -1 | tr -d '[:space:]')
SC4_DONE=${SC4_DONE:-0}
SC4_DWC=$(grep -c "DONE_WITH_CONCERNS" "$ASSEMBLE_WORK" 2>/dev/null || true)
SC4_DWC=$(echo "$SC4_DWC" | head -1 | tr -d '[:space:]')
SC4_DWC=${SC4_DWC:-0}
SC4_BLOCKED=$(grep -c "BLOCKED" "$ASSEMBLE_WORK" 2>/dev/null || true)
SC4_BLOCKED=$(echo "$SC4_BLOCKED" | head -1 | tr -d '[:space:]')
SC4_BLOCKED=${SC4_BLOCKED:-0}
SC4_OVERFLOW=$(grep -c "OVERFLOW" "$ASSEMBLE_WORK" 2>/dev/null || true)
SC4_OVERFLOW=$(echo "$SC4_OVERFLOW" | head -1 | tr -d '[:space:]')
SC4_OVERFLOW=${SC4_OVERFLOW:-0}
SC4_FAIL=$(grep -c "FAIL" "$ASSEMBLE_WORK" 2>/dev/null || true)
SC4_FAIL=$(echo "$SC4_FAIL" | head -1 | tr -d '[:space:]')
SC4_FAIL=${SC4_FAIL:-0}
SC4_VBA=$(grep -c "Verify-Before-Acceptance" "$ASSEMBLE_WORK" 2>/dev/null || true)
SC4_VBA=$(echo "$SC4_VBA" | head -1 | tr -d '[:space:]')
SC4_VBA=${SC4_VBA:-0}
if [ "$SC4_DONE" -ge 1 ] && [ "$SC4_DWC" -ge 1 ] && [ "$SC4_BLOCKED" -ge 1 ] && [ "$SC4_OVERFLOW" -ge 1 ] && [ "$SC4_FAIL" -ge 1 ] && [ "$SC4_VBA" -ge 1 ]; then
    echo "PASS: SC-4 — All status values and Verify-Before-Acceptance found"
else
    echo "FAIL: SC-4 — Missing status values: DONE($SC4_DONE), DONE_WITH_CONCERNS($SC4_DWC), BLOCKED($SC4_BLOCKED), OVERFLOW($SC4_OVERFLOW), FAIL($SC4_FAIL), Verify-Before-Acceptance($SC4_VBA)"
    OVERALL_RESULT=1
fi

# SC-5: No raw git commands in assemble-work.md
# [Supplementary Tier 3: AI semantic — verify git delegation is to git-workflow, not just text absence]
echo "--- SC-5: No raw git commands in assemble-work.md ---"
SC5_ADD=$(grep -cE "(git add|git commit|git push)" "$ASSEMBLE_WORK" 2>/dev/null || true)
SC5_ADD=$(echo "$SC5_ADD" | head -1 | tr -d '[:space:]')
SC5_ADD=${SC5_ADD:-0}
if [ "$SC5_ADD" -eq 0 ]; then
    echo "PASS: SC-5 — No raw git add/commit/push commands in assemble-work.md"
else
    echo "FAIL: SC-5 — Found $SC5_ADD raw git command(s) in assemble-work.md (expected 0)"
    OVERALL_RESULT=1
fi

# SC-6: No inline verification logic in assemble-work.md
# [Supplementary Tier 3: AI semantic — verify verification delegation language, not just absence of patterns]
echo "--- SC-6: No inline verification patterns in assemble-work.md ---"
SC6_INLINE=$(grep -ciE "(inline.*verif|verify.*inline|self.verification)" "$ASSEMBLE_WORK" 2>/dev/null || true)
SC6_INLINE=$(echo "$SC6_INLINE" | head -1 | tr -d '[:space:]')
SC6_INLINE=${SC6_INLINE:-0}
if [ "$SC6_INLINE" -eq 0 ]; then
    echo "PASS: SC-6 — No inline verification patterns in assemble-work.md"
else
    echo "FAIL: SC-6 — Found $SC6_INLINE inline verification pattern(s)"
    OVERALL_RESULT=1
fi

# SC-8: SKILL.md has no Persona section or word count table
echo "--- SC-8: No Persona section or word count table in SKILL.md ---"
SC8_PERSONA=$(grep -c "Persona" "$SKILL_MD" 2>/dev/null || true)
SC8_PERSONA=$(echo "$SC8_PERSONA" | head -1 | tr -d '[:space:]')
SC8_PERSONA=${SC8_PERSONA:-0}
SC8_WORDS=$(grep -cE "Words\s*\|" "$SKILL_MD" 2>/dev/null || true)
SC8_WORDS=$(echo "$SC8_WORDS" | head -1 | tr -d '[:space:]')
SC8_WORDS=${SC8_WORDS:-0}
if [ "$SC8_PERSONA" -eq 0 ] && [ "$SC8_WORDS" -eq 0 ]; then
    echo "PASS: SC-8 — No Persona section or word count table in SKILL.md"
else
    echo "FAIL: SC-8 — Persona($SC8_PERSONA), word count table($SC8_WORDS) (expected 0 each)"
    OVERALL_RESULT=1
fi

# SC-9: SKILL.md tasks table has only assemble-work
# [Supplementary Tier 3: AI semantic — verify task routing is semantically correct, not just string match]
echo "--- SC-9: SKILL.md Tasks table has exactly assemble-work ---"
SC9_TASKS=$(grep -A5 "Tasks" "$SKILL_MD" 2>/dev/null || echo "")
SC9_ASSEMBLE=$(echo "$SC9_TASKS" | grep -c "assemble-work" 2>/dev/null || true)
SC9_ASSEMBLE=$(echo "$SC9_ASSEMBLE" | head -1 | tr -d '[:space:]')
SC9_ASSEMBLE=${SC9_ASSEMBLE:-0}
SC9_OTHER=$(echo "$SC9_TASKS" | grep -cE "(orchestrate|dispatch|merge|completion|assess|decompose)" 2>/dev/null || true)
SC9_OTHER=$(echo "$SC9_OTHER" | head -1 | tr -d '[:space:]')
SC9_OTHER=${SC9_OTHER:-0}
if [ "$SC9_ASSEMBLE" -ge 1 ] && [ "$SC9_OTHER" -eq 0 ]; then
    echo "PASS: SC-9 — Tasks table references only assemble-work"
else
    echo "FAIL: SC-9 — assemble-work($SC9_ASSEMBLE), other task refs($SC9_OTHER)"
    OVERALL_RESULT=1
fi

# SC-10: executing-plans/tasks/start.md does not reference orchestrate
echo "--- SC-10: start.md no orchestrate reference ---"
START_MD="$PROJECT_DIR/.opencode/skills/executing-plans/tasks/start.md"
if [ -f "$START_MD" ]; then
    SC10_ORCH=$(grep -c "orchestrate" "$START_MD" 2>/dev/null || true)
    SC10_ORCH=$(echo "$SC10_ORCH" | head -1 | tr -d '[:space:]')
    SC10_ORCH=${SC10_ORCH:-0}
    if [ "$SC10_ORCH" -eq 0 ]; then
        echo "PASS: SC-10 — start.md has no orchestrate reference"
    else
        echo "FAIL: SC-10 — start.md has $SC10_ORCH orchestrate reference(s)"
        OVERALL_RESULT=1
    fi
else
    echo "SKIP: SC-10 — start.md not found at expected path"
fi

# SC-11: SKILL.md symbolic rules don't reference deleted tasks
echo "--- SC-11: SKILL.md symbolic rules reference only live tasks ---"
SC11_DELETED=$(grep -cE "\-\-task orchestrate|\-\-task dispatch|\-\-task merge|\-\-task completion|\-\-task assess|\-\-task decompose|\-\-task context-passing|\-\-task purification|\-\-task implementer-prompt|\-\-task spec-reviewer-prompt|\-\-task code-quality-reviewer-prompt|tasks/orchestrate|tasks/dispatch|tasks/merge|tasks/completion|tasks/assess|tasks/decompose|tasks/context-passing|tasks/purification|tasks/implementer-prompt|tasks/spec-reviewer-prompt|tasks/code-quality-reviewer-prompt|task.*orchestrate|task.*dispatch|task.*assess|task.*decompose" "$SKILL_MD" 2>/dev/null || true)
SC11_DELETED=$(echo "$SC11_DELETED" | head -1 | tr -d '[:space:]')
SC11_DELETED=${SC11_DELETED:-0}
if [ "$SC11_DELETED" -eq 0 ]; then
    echo "PASS: SC-11 — No deleted task references in SKILL.md symbolic rules"
else
    echo "FAIL: SC-11 — Found $SC11_DELETED reference(s) to deleted tasks in SKILL.md"
    OVERALL_RESULT=1
fi

# SC-15: assemble-work.md uses "dependency order" not "execution order"
echo "--- SC-15: assemble-work.md uses dependency order ---"
SC15_DEP=$(grep -c "dependency order" "$ASSEMBLE_WORK" 2>/dev/null || true)
SC15_DEP=$(echo "$SC15_DEP" | head -1 | tr -d '[:space:]')
SC15_DEP=${SC15_DEP:-0}
SC15_EXEC=$(grep -c "execution order" "$ASSEMBLE_WORK" 2>/dev/null || true)
SC15_EXEC=$(echo "$SC15_EXEC" | head -1 | tr -d '[:space:]')
SC15_EXEC=${SC15_EXEC:-0}
if [ "$SC15_DEP" -ge 1 ] && [ "$SC15_EXEC" -eq 0 ]; then
    echo "PASS: SC-15 — Uses 'dependency order' ($SC15_DEP), not 'execution order'"
else
    echo "FAIL: SC-15 — dependency order($SC15_DEP, need ≥1), execution order($SC15_EXEC, need 0)"
    OVERALL_RESULT=1
fi

# SC-16: SKILL.md description field contains dark prose 003 (consequence-assertion)
echo "--- SC-16: SKILL.md description has dark prose 003 ---"
SC16=$(grep -cE "(produces.*defect|means.*impact|carries.*characterization)" "$SKILL_MD" 2>/dev/null || true)
SC16=$(echo "$SC16" | head -1 | tr -d '[:space:]')
SC16=${SC16:-0}
if [ "$SC16" -ge 1 ]; then
    echo "PASS: SC-16 — Dark prose 003 consequence-assertion found ($SC16 match(es))"
else
    echo "FAIL: SC-16 — No dark prose 003 consequence-assertion found in SKILL.md description"
    OVERALL_RESULT=1
fi

# SC-17: SKILL.md Overview contains dark prose 001 (confirmshaming)
echo "--- SC-17: SKILL.md Overview has dark prose 001 ---"
SC17=$(grep -cE "(is what.*looks like|means.*consequence)" "$SKILL_MD" 2>/dev/null || true)
SC17=$(echo "$SC17" | head -1 | tr -d '[:space:]')
SC17=${SC17:-0}
if [ "$SC17" -ge 1 ]; then
    echo "PASS: SC-17 — Dark prose 001 confirmshaming found ($SC17 match(es))"
else
    echo "FAIL: SC-17 — No dark prose 001 confirmshaming found in SKILL.md Overview"
    OVERALL_RESULT=1
fi

# SC-18: assemble-work.md Purpose contains dark prose 002 (goal hijacking identity-frame)
echo "--- SC-18: assemble-work.md Purpose has dark prose 002 ---"
SC18=$(grep -cE "(IS.*identity|requires.*condition|No valid.*without.*gate)" "$ASSEMBLE_WORK" 2>/dev/null || true)
SC18=$(echo "$SC18" | head -1 | tr -d '[:space:]')
SC18=${SC18:-0}
if [ "$SC18" -ge 1 ]; then
    echo "PASS: SC-18 — Dark prose 002 goal hijacking identity-frame found ($SC18 match(es))"
else
    echo "FAIL: SC-18 — No dark prose 002 found in assemble-work.md Purpose"
    OVERALL_RESULT=1
fi

# SC-19: assemble-work.md how-to guidance uses dark prose 006 (agency-respecting)
echo "--- SC-19: assemble-work.md how-to has dark prose 006 ---"
SC19_WHAT=$(grep -ciE "(what|why|source|guideline|per )" "$ASSEMBLE_WORK" 2>/dev/null || true)
SC19_WHAT=$(echo "$SC19_WHAT" | head -1 | tr -d '[:space:]')
SC19_WHAT=${SC19_WHAT:-0}
if [ "$SC19_WHAT" -ge 1 ]; then
    echo "PASS: SC-19 — Dark prose 006 agency-respecting pattern found ($SC19_WHAT reference(s))"
else
    echo "FAIL: SC-19 — No dark prose 006 agency-respecting patterns found"
    OVERALL_RESULT=1
fi

echo ""
echo "=== Summary ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: All Tiers 1-2 assertions passed"
    echo ""
    echo "    Tier 3 (semantic evaluation) supplements these SCs:"
    echo "    SC-1, SC-3, SC-4, SC-5, SC-6, SC-9, SC-11, SC-15, SC-16, SC-17, SC-18, SC-19"
    echo ""
    echo "    Tier 3 is dispatched during VbC as clean-room task() sub-agents."
    echo "    Each sub-agent reads the deliverable files and confirms whether"
    echo "    the content semantically meets the SC criteria — not via grep"
    echo "    pattern matching, but by analytical judgment."
    echo ""
    echo "    SC-8 (Persona/word count absences) and SC-10 (orchestrate reference)"
    echo "    are string-only — no semantic supplement needed."
else
    echo "FAIL: One or more Tier 1-2 assertions failed"
fi

exit $OVERALL_RESULT