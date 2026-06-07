#!/bin/bash
# Behavioral test: spec-structure-expansion-1060
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# RED phase: All 22 SCs from spec #1060 are NOT yet implemented.
# SC-1 to SC-21 (string): grep write.md for new content patterns — assert
#   PRESENCE → will FAIL because content doesn't exist → RED confirmed
# SC-22 (behavioral): model-run, assert stub creation via stderr →
#   will FAIL because pre-Step-0.8 doesn't exist → RED confirmed
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="spec-structure-expansion-1060"

WRITE_MD=".opencode/skills/spec-creation/tasks/write.md"
PARENT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TARGET_WRITE_MD="$PARENT_DIR/$WRITE_MD"

if [ ! -f "$TARGET_WRITE_MD" ]; then
  echo "FATAL: write.md not found at $TARGET_WRITE_MD" >&2
  exit 1
fi

OVERALL_RESULT=0

red_grep() {
  local pattern="$1"
  local label="$2"
  if grep -qE "$pattern" "$TARGET_WRITE_MD" 2>/dev/null; then
    echo "  GREEN (unexpected): $label"
    return 0
  else
    echo "  RED (expected): $label"
    return 1
  fi
}

echo "=== RED Phase: Spec Structure Expansion #1060 ==="
echo "Target: $(basename $TARGET_WRITE_MD)"
echo ""

# ============================================================
# Phase 1: SC Table Columns (SC-1 to SC-6, SC-16, SC-17)
# ============================================================
echo "--- Phase 1: SC Table Columns ---"

# SC-1: 8 new column headers absent from write.md
red_grep "Pipeline Step Binding" "SC-1: Pipeline Step Binding column" || OVERALL_RESULT=1
red_grep "Requirement Traceability" "SC-1: Requirement Traceability column" || OVERALL_RESULT=1
red_grep "Phase Binding" "SC-1: Phase Binding column" || OVERALL_RESULT=1
red_grep "Integration Mode" "SC-1: Integration Mode column" || OVERALL_RESULT=1
red_grep "Affinity Group" "SC-1: Affinity Group column" || OVERALL_RESULT=1
red_grep "Re-Entry Step" "SC-1: Re-Entry Step column" || OVERALL_RESULT=1

# SC-2: Requirement Traceability MUST declaration
red_grep "Requirement Traceability.*MUST" "SC-2: MUST declaration for Requirement Traceability" || OVERALL_RESULT=1

# SC-3: Phase Binding conditional annotation
red_grep "Phase Binding.*multi.phase|Phase Binding.*single" "SC-3: Phase Binding conditional annotation" || OVERALL_RESULT=1

# SC-4: 3-tier Verification Gate (red-green, pre-commit, ci)
red_grep "red.green.*pre.commit.*ci|pre.commit.*ci.*type|Verification Gate.*red.green" "SC-4: 3-tier gate definitions" || OVERALL_RESULT=1

# SC-5: Integration Mode Gate=ci conditional
red_grep "Gate.*ci.*Integration|Integration.*Mode.*required.*ci" "SC-5: Integration Mode Gate=ci condition" || OVERALL_RESULT=1

# SC-6: Re-Entry Step all-tiers mandatory
red_grep "Re.entry.*all.*tier|Re.entry.*mandatory" "SC-6: Re-Entry Step all-tiers mandatory" || OVERALL_RESULT=1

# SC-16: Affinity Group optional + use-case examples
red_grep "Affinity.*Group.*optional|Affinity.*Group.*use.case" "SC-16: Affinity Group optional" || OVERALL_RESULT=1

# SC-17: Artifact Path ./tmp/{issue-N}/ convention
red_grep "tmp.*issue.N|artifact.*path.*tmp" "SC-17: ./tmp/{issue-N} convention" || OVERALL_RESULT=1

# ============================================================
# Phase 2: Preamble Sections (SC-7 to SC-10, SC-18, SC-19)
# ============================================================
echo ""
echo "--- Phase 2: Preamble Sections ---"

# SC-7: 5 preamble section definitions
red_grep "Decision Ledger.*DEC|purpose.*Decision.*Ledger" "SC-7a: Decision Ledger section" || OVERALL_RESULT=1
red_grep "Risk Traceability.*RISK|purpose.*Risk.*Traceability" "SC-7b: Risk Traceability section" || OVERALL_RESULT=1
red_grep "Revision Policy.*cascade|purpose.*Revision.*Policy" "SC-7c: Revision Policy section" || OVERALL_RESULT=1
red_grep "Decomposition Classification.*task|purpose.*Decomposition" "SC-7d: Decomposition Classification" || OVERALL_RESULT=1
red_grep "Spec Family.*annotation|purpose.*Spec.*Family" "SC-7e: Spec Family Annotation" || OVERALL_RESULT=1

# SC-8: Decision Ledger template with DEC-IDs
red_grep "DEC.ID[^s]" "SC-8: DEC-ID prefix" || OVERALL_RESULT=1

# SC-9: Risk Traceability template with RISK-IDs
red_grep "RISK.ID[^s]" "SC-9: RISK-ID prefix" || OVERALL_RESULT=1

# SC-10: Revision Policy artifact cascade declarations
red_grep "artifact cascade|cascade.*declar" "SC-10: Revision Policy cascade table" || OVERALL_RESULT=1

# SC-18: Decomposition Classification table (single-task vs multi-phase)
red_grep "single.*task.*multi.*phase.*criteria|single.*task vs.*multi" "SC-18: single-task vs multi-phase table" || OVERALL_RESULT=1

# SC-19: Spec Family annotation optional punch list
red_grep "punch.list.*selector|selector.*punch.list|Spec Family.*optional.*sel" "SC-19: Spec Family punch list" || OVERALL_RESULT=1

# ============================================================
# Phase 3: Mandatory Content Areas (SC-11, SC-12, SC-15)
# ============================================================
echo ""
echo "--- Phase 3: Mandatory Content Areas ---"

# SC-11: Explicit Non-Goals template
red_grep "## Explicit Non.Goals" "SC-11: Explicit Non-Goals header" || OVERALL_RESULT=1

# SC-12: Regression Invariants template
red_grep "## Regression Invariants" "SC-12: Regression Invariants header" || OVERALL_RESULT=1

# SC-15: Cross-cutting/Common SC designation
red_grep "cross.cutting.*SC|Common SC.*designation|shared.*verification.*budget" "SC-15: Cross-cutting SC designation" || OVERALL_RESULT=1

# ============================================================
# Phase 4: Self-Review Substeps (SC-13, SC-14)
# ============================================================
echo ""
echo "--- Phase 4: Self-Review Substeps ---"

# SC-13: SC-to-SC coherence check
red_grep "SC.to.SC.*coherence|coherence.*substep|pairwise.*contradict" "SC-13: SC-to-SC coherence substep" || OVERALL_RESULT=1

# SC-14: Verification-Method-to-Artifact-Path consistency check
red_grep "Verification Method.*Artifact|consistency.*substep|cross.column.*verification" "SC-14: consistency check substep" || OVERALL_RESULT=1

# ============================================================
# Phase 5: New Steps + Behavioral Test (SC-20, SC-21, SC-22)
# ============================================================
echo ""
echo "--- Phase 5: New Steps ---"

# SC-20: Step 7a exec-summary format rules
red_grep "Step 7a\b" "SC-20: Step 7a exec-summary format rules" || OVERALL_RESULT=1

# SC-21: Step 7b remote push + local mirror
red_grep "Step 7b\b" "SC-21: Step 7b remote push + mirror" || OVERALL_RESULT=1

# SC-22: pre-Step-0.8 stub creation (behavioral — model-run)
echo ""
echo "--- SC-22: Behavioral — pre-Step-0.8 stub creation ---"

red_grep "pre.Step.0.8|Step 0.8" "SC-22: pre-Step-0.8 stub creation step" || OVERALL_RESULT=1

# ============================================================
# Summary
# ============================================================
echo ""
echo "=== RED Phase Summary ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
  echo "STATUS: PASS (unexpected — all content already present = GREEN behavior)"
elif [ "$OVERALL_RESULT" -ge 28 ]; then
  echo "STATUS: FAIL (RED phase confirmed — $OVERALL_RESULT/31 assertions failed)"
else
  echo "STATUS: PARTIAL FAIL ($OVERALL_RESULT/31 failures — some content already present)"
fi

exit $OVERALL_RESULT