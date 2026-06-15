---
remote_issue: 912
remote_url: "https://github.com/michael-conrad/.opencode/issues/912"
last_sync: 2026-06-14T20:50:47Z
source: github.com
---

> **Scope revision: `.opencode#1222` Part 2 (Z3 Gate Transition) adds evidence-type mismatch detection at the hand-off boundary between every pipeline stage. This covers EVIDENCE_TYPE_MISMATCH at transition time. The SC coherence checking (pre-dispatch semantic analysis of spec SCs against dispatch ordering) remains independent and in full scope — #1222 gates on evidence types at hand-off, not on spec-level coherence.**

STATUS: 0.3

## Parent

#909 (implementation-pipeline tracking spec)

## Z3-Verified Placement

This spec is in **Phase 2** of the 909 cluster ordering. Depends on Merge Group A (#915, Phase 1).

## Dependencies

Merge Group A (#915) must merge first — coherence gate and remediation routing are pipeline steps that depend on the rename and dispatch routing table.

## Remaining Scope

### Phase 4: SC coherence gate (Z3 structural consistency)

Step `sc-coherence-gate` in the dispatch routing table (#915), dispatched as the first pipeline step (before red-phase). Dispatches to `adversarial-audit --task coherence-extraction`. Two sub-phases:

**Phase A — Z3 structural consistency:** Sub-agent calls `solve check` against SC evidence type constraints. Verifies declared SC constraints don't contradict each other. This is pre-dispatch analysis, not hand-off contract validation (that's #1222's domain).

**Phase B — Semantic evidence type mismatch:** Same sub-agent evaluates the spec's prose against each SC's declared evidence type. Detects when prose describes runtime agent behavior but SC declares `structural` or `string`. This is a spec-level audit finding — distinct from #1222's hand-off boundary check.

**Combined requirements:**
1. Sub-agent (coherence-extraction) calls solve tool for SC constraint consistency
2. Sub-agent evaluates prose vs evidence type mismatch
3. On detection from either phase: hard FAIL, write FAIL artifact, return FAIL contract
4. Orchestrator reads FAIL artifact, dispatches researcher skill
5. Researcher produces remediation artifact with `remediation_scope: spec_plan_and_implementation`
6. Orchestrator routes back through spec revision → plan revision → implementation

> Note: Evidence-type mismatch detection AT THE HAND-OFF BOUNDARY is covered by `#1222` Part 2 (Z3 Gate). This phase covers PRE-DISPATCH coherence — analyzing whether the spec's SCs are internally consistent before any task() call.

### Phase 5: Remediation routing (FAIL → researcher dispatch)

Unchanged from original spec. Orchestrator routing logic that handles FAIL from any gate step.

### Phase 7: Behavioral tests

Unchanged. Behavioral tests for integrated pipeline remain in full scope.

## Success Criteria (Phase 4 Only — Phase 5 and 7 are unchanged)

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Coherence-extraction sub-agent calls `solve check` for SC constraint consistency | `behavioral` |
| SC-2 | Prose-vs-evidence-type mismatch detected at spec level (pre-dispatch) | `behavioral` |
| SC-3 | Any detection from Phase A or B → hard FAIL artifact, not advisory | `behavioral` |
| SC-4 | FAIL artifact routes to researcher, researcher produces remediation scope | `behavioral` |

🤖 OpenCode (deepseek-v4-flash)