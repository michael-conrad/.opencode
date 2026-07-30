#!/bin/bash
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Content-Verification Test: Writing-Plans Research Task Card
#
# Verifies that skills/writing-plans/tasks/research.md produces phase
# decomposition, builds a dependency DAG, selects skill+task from
# the implementation-pipeline Trigger Dispatch Table, and runs Z3 solving.
#
# RED phase: research.md does NOT exist yet.
# Expected to FAIL (non-zero exit).
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

RESEARCH_MD=".opencode/skills/writing-plans/tasks/research.md"

echo "=== RED Test: writing-plans-research ==="
echo "Checking $RESEARCH_MD for phase decomposition, DAG, TDT selection, and Z3 solving..."
echo ""

EXISTS=false
HAS_PHASE_DECOMP=false
HAS_DAG=false
HAS_TDT_SELECT=false
HAS_Z3=false

# Check 1: research.md must exist
if [ -f "$RESEARCH_MD" ]; then
    EXISTS=true
    echo "  [FOUND] $RESEARCH_MD exists"
else
    echo "  [MISSING] $RESEARCH_MD does not exist (expected RED)"
fi

# Check 2: Must produce phase decomposition
if $EXISTS && grep -qi 'phase.*decomp\|decompose.*phase\|phase.*structur\|phase.*plan\|phase.*step\|phase.*concern' "$RESEARCH_MD" 2>/dev/null; then
    HAS_PHASE_DECOMP=true
    echo "  [FOUND] Phase decomposition logic"
else
    echo "  [MISSING] Phase decomposition (expected RED)"
fi

# Check 3: Must build a dependency DAG
if $EXISTS && grep -qi 'dag\|dependency.*graph\|dependency.*dag\|depends.*on\|dependency.*order\|dependency.*chain' "$RESEARCH_MD" 2>/dev/null; then
    HAS_DAG=true
    echo "  [FOUND] Dependency DAG logic"
else
    echo "  [MISSING] Dependency DAG (expected RED)"
fi

# Check 4: Must select skill+task from implementation-pipeline TDT
if $EXISTS && grep -qi 'implementation-pipeline\|trigger.*dispatch.*table\|tdt\|skill.*task.*select\|dispatch.*table\|pipeline.*tdt' "$RESEARCH_MD" 2>/dev/null; then
    HAS_TDT_SELECT=true
    echo "  [FOUND] Implementation-pipeline TDT selection"
else
    echo "  [MISSING] Implementation-pipeline TDT selection (expected RED)"
fi

# Check 5: Must run Z3 constraint solving
if $EXISTS && grep -qi 'solve\|z3\|sat\|unsat\|constraint.*solv\|tools/solve\|tools/plan' "$RESEARCH_MD" 2>/dev/null; then
    HAS_Z3=true
    echo "  [FOUND] Z3 constraint solving"
else
    echo "  [MISSING] Z3 constraint solving (expected RED)"
fi

echo ""
if $EXISTS && $HAS_PHASE_DECOMP && $HAS_DAG && $HAS_TDT_SELECT && $HAS_Z3; then
    echo "UNEXPECTED PASS: research.md has phase decomposition, DAG, TDT selection, and Z3 solving"
    exit 0
else
    echo "EXPECTED FAIL: research.md missing required capabilities (RED phase confirmed)"
    echo "  EXISTS=$EXISTS PHASE_DECOMP=$HAS_PHASE_DECOMP DAG=$HAS_DAG TDT_SELECT=$HAS_TDT_SELECT Z3=$HAS_Z3"
    exit 1
fi
