# Interface Compatibility Analysis — Issue #1885

**Generated: 2026-07-11**
**Spec: [SPEC-FIX] Close artifact gate bypass escape hatch in writing-plans skill**

## Connected Unit Pairs

From the spec's 7 changes (decomposed units), the following producer-consumer relationships exist:

| Pair ID | Producer | Consumer | Connection Type | Data Flow Direction |
|---------|----------|----------|-----------------|---------------------|
| P1 | Change 3: Entry Criteria (SKILL.md) | Change 1: Trigger Dispatch Table (SKILL.md) | Direct — Entry Criteria declare prerequisites that TDT must enforce | Entry Criteria → TDT |
| P2 | Change 1: Trigger Dispatch Table (SKILL.md) | Change 2: pre-plan-readiness task | Direct — TDT dispatches to pre-plan-readiness; TDT's artifact pre-check must match pre-plan-readiness's check | TDT → pre-plan-readiness |
| P3 | Change 4: Mandatory Task Discipline item 8 (SKILL.md) | Change 2: pre-plan-readiness task | Direct — Item 8 declares the hard-gate rule; pre-plan-readiness enforces it | Item 8 → pre-plan-readiness |
| P4 | Change 2: pre-plan-readiness task | Change 5: spec-to-plan handoff | Data-flow — Both validate artifact presence; handoff manifest consumes the same artifact list | pre-plan-readiness → handoff |
| P5 | Change 1-5: All file changes | Change 6: Critical-rules entry | Direct — File changes define the behavior; critical-rules entry codifies the prohibition | File changes → critical-rules |
| P6 | Change 1-6: All structural changes | Change 7: Behavioral enforcement test | Data-flow — Structural changes produce rule text; behavioral test verifies agent behavior | Structural changes → behavioral test |

## Type Compatibility Matrix

| Pair ID | Producer Output Type | Consumer Input Type | Compatibility | Verdict |
|---------|---------------------|---------------------|---------------|---------|
| P1 | Entry Criteria: list of prerequisite strings (spec approval, authorization scope, analytical artifact presence) | TDT "create plan" entry: dispatch condition + task reference | Structural — TDT entry references the same prerequisite concepts declared in Entry Criteria | ✅ Compatible |
| P2 | TDT "create plan" entry: dispatch to `pre-plan-readiness` with `{spec_issue_number}` context | pre-plan-readiness task: accepts `{spec_issue_number}`, checks `.issues/{N}/` for artifacts | Exact match — TDT passes `spec_issue_number`; pre-plan-readiness resolves `{N}` from it | ✅ Compatible |
| P3 | Item 8: hard-gate declaration "BLOCKED with MISSING_SPEC_ARTIFACT" | pre-plan-readiness: returns `status: BLOCKED` with `reason: MISSING_SPEC_ARTIFACT` | Exact match — Item 8's declared reason code matches pre-plan-readiness's return value | ✅ Compatible |
| P4 | pre-plan-readiness: artifact check procedure (7 artifact names) | spec-to-plan handoff: artifact validation check (same 7 artifact names) | Exact match — Both reference the same 7 artifact names | ✅ Compatible |
| P5 | File changes: modified SKILL.md, pre-plan-readiness.md, spec-to-plan.md | Critical-rules entry: references "artifact gate bypass" prohibition | Structural — Critical-rules entry must reference the same gate concept defined in file changes | ✅ Compatible |
| P6 | Structural changes: rule text in 4 files | Behavioral test: `opencode-cli run` prompt → agent behavior | Behavioral — Test prompt triggers agent to read modified files; agent behavior reflects rule text | ✅ Compatible |

## Contract Verification Table

| Pair ID | Producer Postconditions | Consumer Preconditions | Satisfaction | Verdict |
|---------|------------------------|----------------------|-------------|---------|
| P1 | Entry Criteria lists "analytical artifact presence" as prerequisite | TDT "create plan" entry must validate artifacts before dispatch | Entry Criteria declares the requirement; TDT enforces it. Consumer precondition is satisfied by producer postcondition. | ✅ Satisfied |
| P2 | TDT dispatches to pre-plan-readiness with artifact pre-check | pre-plan-readiness must receive `spec_issue_number` and check 7 artifacts | TDT passes `spec_issue_number`; pre-plan-readiness resolves `{N}` and checks artifacts. Consumer precondition satisfied. | ✅ Satisfied |
| P3 | Item 8 declares: "Missing artifacts produce BLOCKED with MISSING_SPEC_ARTIFACT" | pre-plan-readiness must return BLOCKED with MISSING_SPEC_ARTIFACT on missing artifacts | Item 8's postcondition (BLOCKED + MISSING_SPEC_ARTIFACT) exactly matches pre-plan-readiness's required return value. | ✅ Satisfied |
| P4 | pre-plan-readiness checks all 7 artifacts and returns PASS/BLOCKED | spec-to-plan handoff validates same 7 artifacts and writes manifest | Both consume the same artifact list. pre-plan-readiness blocks before handoff runs — handoff only executes if pre-plan-readiness passes. | ✅ Satisfied |
| P5 | File changes produce rule text that prohibits artifact gate bypass | Critical-rules entry must codify the same prohibition at Tier 2 | Critical-rules entry references the same gate concept. Tier 2 classification matches the violation severity. | ✅ Satisfied |
| P6 | Structural changes produce rule text the agent reads at runtime | Behavioral test sends prompt that triggers agent to read modified files and follow rules | Test prompt is a real-domain task ("create a plan for a spec without artifacts"). Agent reads SKILL.md, pre-plan-readiness.md, and follows the artifact gate. | ✅ Satisfied |

## Mismatch Report

No type mismatches detected. All producer-consumer pairs have compatible types.

## Violation Report

No contract violations detected. All consumer preconditions are satisfied by producer postconditions.

## Coverage Verification

| Check | Result |
|-------|--------|
| Every unit in decomposition appears in at least one connected pair | ✅ All 7 changes appear in the connected pairs table |
| Every connection type covered | ✅ Direct (P1, P2, P3, P5) and Data-flow (P4, P6) both covered |
| Every type mismatch documented | ✅ No mismatches found; all pairs verified compatible |
| Every contract violation documented | ✅ No violations found; all pre/postconditions verified satisfied |

## Cross-Unit Consistency Notes

1. **Artifact name consistency:** All 7 artifact names (blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment) must be spelled identically across all 5 file changes. The spec uses hyphenated names consistently.

2. **Reason code consistency:** `MISSING_SPEC_ARTIFACT` must be the exact reason code used in pre-plan-readiness (Change 2), Mandatory Task Discipline item 8 (Change 4), and the behavioral test assertion (Change 7).

3. **Tier classification consistency:** Change 6 (critical-rules entry) classifies the violation as Tier 2 (Process-Integrity). This must match the enforcement level in the behavioral test — the test asserts BLOCKED (not CRITICAL VIOLATION).

4. **Entry point vs. pipeline gate:** Change 1 (TDT) and Change 2 (pre-plan-readiness) add the check at the entry point. Change 5 (spec-to-plan handoff) adds a secondary validation. The Step 4a readiness check (not modified) remains as a tertiary gate. These three gates are complementary, not redundant — each fires at a different pipeline stage.

5. **Behavioral test dependency:** Change 7 (behavioral test) depends on Changes 1-6 being implemented first (Phase 1 → Phase 2). The test must be RED before Phase 1 changes (SC-8), then GREEN after Phase 1 changes are complete (SC-7).
