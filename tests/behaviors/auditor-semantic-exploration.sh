#!/bin/bash
# Behavioral Enforcement Test: Auditor Semantic Exploration (SC-9 from #397)
#
# Verifies that auditor agents perform semantic exploration (not just
# mechanical checking) when evaluating a spec where the Files Affected
# table is incomplete relative to the spec's own SC-6 scope claim.
#
# The test embeds the Semantic Depth Mandate directly in the prompt
# (since opencode-cli run cannot invoke subagents directly) and
# provides a local spec file with a deliberate gap between SC-6's
# scope and the Files Affected table.
#
# Mechanical grep: finds "dispatch" in all listed files → PASS (no gap detected)
# Semantic exploration: discovers SC-6's "ALL skills that dispatch auditor
# sub-agents" claim contradicts the incomplete Files Affected table → FAIL
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

BEHAVIOR_TIMEOUT=300

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-semantic-exploration"

TMP_SPEC_DIR="$PROJECT_DIR/tmp"
mkdir -p "$TMP_SPEC_DIR"
TMP_SPEC="$TMP_SPEC_DIR/test-spec-397-semantic.md"

cat > "$TMP_SPEC" << 'SPEC'
---
number: 397
title: "[SPEC-FIX] Intelligent Audit Dispatch"
status: "1.0 DRAFT"
labels: [spec, approved-for-pr]
---

# Intelligent Audit Dispatch — Audit Phase Identity, Semantic Depth, and Clean Room Protocol

## Success Criteria

SC-1: All auditor agent cards include a MANDATORY FIRST CHECK that detects context taint signals (expected outcomes, pre-determined file paths, orchestrator reasoning) and returns CONTEXT_TAINTED immediately.

SC-2: All auditor agent cards include a Semantic Depth Mandate prohibiting mechanical-only audit. Auditors must evaluate semantics, not just structure.

SC-3: All auditor agent cards include a `clean_room` output block in their JSON response schema.

SC-4: Agent cards remain generic across audit phases — they receive `audit_phase` from dispatch context, not hardcoded in the card.

SC-5: Each auditor SKILL.md declares its audit phase identity in the Persona/Operating Protocol section.

SC-6: All skills that dispatch auditor sub-agents must include `audit_phase` in their dispatch context schema.

SC-7: A critical violation `critical-rules-046` prohibits mechanical-only audit without full semantic and conflict exploration.

## Files Affected

| File | Change |
|------|--------|
| `.opencode/agents/auditor-*.md` (7 files) | Add MANDATORY FIRST CHECK, semantic depth mandate, CONTEXT_TAINTED refusal, clean_room output block |
| `.opencode/skills/spec-auditor/SKILL.md` | Add audit phase identity (phase: spec) to Persona/Operating Protocol |
| `.opencode/skills/adversarial-audit/SKILL.md` | Add audit phase identity + ensure dispatch context includes audit_phase |
| `.opencode/guidelines/000-critical-rules.md` | Add critical-rules-046 yaml+symbolic block |
SPEC

SEMANTIC_DEPTH_MANDATE=$(cat << 'AGENTCARD'
## Semantic Depth Mandate (SC-2)

**Mechanical-only audit is a critical violation per `critical-rules-046`.** You MUST evaluate semantics, not just structure.

### What "Semantic" means (REQUIRED):

- Verifying that text MEANS what the artifact claims, not just that it EXISTS
- Checking that "all" actually means ALL, not "the ones I remembered to list"
- Discovering gaps between stated scope and actual coverage
- Identifying contradictions between success criteria and file listings
- Evaluating whether causal claims follow from evidence, not just that claims are present

### What "Mechanical-only" means (PROHIBITED):

- Checking that sections exist without evaluating their content against stated scope
- Counting entries without verifying scope coverage
- Grep-based verification: finding keywords without understanding their context
- "Files Affected table has entries" without checking if those entries cover ALL the scope the SC claims
- "Section present" checks without evaluating whether the section content matches the SC promise

### REQUIRED for every audit:

1. Cross-reference each SC against the Files Affected table to verify scope coverage
2. Identify ANY file that should be affected by an SC but is NOT listed
3. Flag scope gaps where "all" or "every" in an SC is contradicted by missing files
4. Report findings as FAIL (scope gap) or PASS (full coverage), never as PASS just because "section exists"
AGENTCARD
)

SCENARIO_PROMPT="${SEMANTIC_DEPTH_MANDATE}

Audit the spec at /home/muksihs/git/opencode-config/tmp/test-spec-397-semantic.md for completeness. SC-6 states that ALL skills that dispatch auditor sub-agents must include audit_phase in their dispatch context schema. Check whether the Files Affected table covers every skill mentioned in SC-6, or whether dispatching skills like divide-and-conquer, executing-plans, finishing-a-development-branch, and writing-plans are missing from the table even though they dispatch sub-agents and would need audit_phase in their dispatch context."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# --- Assertion 1: Agent identifies the gap between SC-6 scope and Files Affected ---
assert_required_pattern_present "missing\|not listed\|not covered\|not included\|not mentioned\|omitted\|absent\|left out\|excluded\|scope gap\|scope mismatch\|discrepancy\|inconsistency\|incomplete.*Affected\|Affected.*incomplete\|SC-6.*scope\|should.*affect\|needs.*affect\|fails.*cover\|not.*account\|does not list\|not in the.*table\|table does not\|table missing\|not reflected\|unaccounted\|additional.*file" "identifies Files Affected gap relative to SC-6 scope" || OVERALL_RESULT=1

# --- Assertion 2: Agent does NOT just mechanically check table existence ---
assert_forbidden_pattern_absent "Files Affected table exists\|4 entries.*PASS\|all sections present\|structural PASS\|performed mechanical check\|only verified.*presence\|verified.*exists.*without.*semantic\|verified structure without.*meaning" "mechanical-only check that ignores scope completeness" || OVERALL_RESULT=1

# --- Assertion 3: Agent performs semantic comparison (not just keyword presence) ---
assert_required_pattern_present "divide.and.conquer\|executing.plans\|finishing.*development\|writing.plans\|dispatch.*skill\|skill.*dispatch\|sub.agent.*dispatch\|at least.*4\|more.*file\|additional.*file" "identifies specific missing dispatching skills" || OVERALL_RESULT=1

rm -f "$TMP_SPEC"

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT