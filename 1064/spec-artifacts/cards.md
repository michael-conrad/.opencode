# Card Catalogue — Writing-Plans Consumer Awareness of Expanded Spec Structure

## STATUS: spec
## SCOPE: writing-plans-consumer-awareness
## DEPENDENCIES: [#850](https://github.com/michael-conrad/.opencode/issues/850), [#1060](https://github.com/michael-conrad/.opencode/issues/1060)
## ITEMS COVERED: 23

## Cards

### Card 1: Item mapping to SCs

| Item | Subject | SC(s) | Status |
|------|---------|-------|--------|
| 23 | Writing-Plans Consumer Awareness of Expanded SC Table | SC-1 through SC-16 | COVERED |

### Card 2: Structured fields consumption map

| Spec Artifact | Plan Consumer | Behavior | SC |
|--------------|---------------|----------|-----|
| SC-ID | Phase structure, TDD tasks | Each SC-ID referenced in the phase it belongs to; TDD verification steps specify which SC-IDs they cover | SC-1, SC-2 |
| Pipeline Step Binding | Verification dispatcher mapping | Plan does not re-create binding — reads it from spec SC table and passes through to pipeline verification steps | SC-3 |
| Phase Binding | Phase ordering, sub-issue creation | Plan phases match spec Phase Binding column; SCs assigned to wrong phase flagged | SC-4 |
| Verification Gate | Verification method selection | Plan does not override Verification Gate — passes through from spec; gate selection is spec-level | SC-3 |
| Artifact Path | Verification output location | Plan verification steps write to the declared artifact path; no plan-level path override | SC-5 |
| Risk Traceability | Phase risk analysis, mitigation steps | Each phase's "What could go wrong" section references the RISK-IDs from the spec Risk Traceability table | SC-13 |
| Decision Ledger | Phase design decisions, constraint compliance | Plan phases must not contradict DEC-IDs; if a phase's approach violates a DEC, the plan author escalates before writing the phase | SC-12 |
| Decomposition Classification | Combined vs separate plan format | Format decision is verified against the spec's classification, not re-evaluated by the plan author | SC-14 |

**Status**: DESIGNED — all 8 fields consumed per SC-1 through SC-14, with graceful degradation for missing sections per SC-15.

### Card 3: Cross-reference validation checks

| # | Check | FAIL Condition | SC |
|---|-------|----------------|-----|
| 1 | Every spec SC-ID has TDD task reference | Spec SC-ID not found in any plan TDD task heading | SC-8 |
| 2 | Every TDD SC-ID exists in spec SC table | Plan references SC-7 but spec has only SC-1 through SC-6 | SC-9 |
| 3 | Phase assignments match Phase Binding | SC-3 bound to Phase 2 in spec, Phase 1 in plan | SC-10 |
| 4 | Pipeline Step Binding preserved | SC-4 spec binding = green-doublecheck, plan assigns to red-doublecheck | SC-11 |
| 5 | No DEC-ID contradiction | DEC-1 says "silently deduplicate", plan says "409 on duplicate" | SC-12 |
| 6 | Every RISK-ID with Verifying SC has mitigation | RISK-1→SC-5 but SC-5 phase has no risk mitigation section | SC-13 |
| 7 | Combined/separate decision matches Decomposition Classification | multi-phase spec → combined format (should be separate) | SC-14 |

**Status**: DESIGNED — all 7 checks defined with per-check FAIL semantics and BLOCK-on-any-Fail.

### Card 4: Graceful degradation matrix

| Missing Spec Section | Effect | SC |
|----------------------|--------|-----|
| No Phase Binding column | Check 3 (phase assignment) skipped | SC-15 |
| No Decision Ledger | Check 5 (DEC-ID contradiction) skipped | SC-15 |
| No Risk Traceability table | Check 6 (RISK-ID mitigation) skipped | SC-15 |
| No Pipeline Step Binding column | Check 4 (binding preservation) skipped | SC-15 |
| No binding columns at all | Plan-structure BLOCKED with SPEC_SC_TABLE_UNREADABLE | SC-6 |

**Status**: DESIGNED — graceful degradation per SC-15, BLOCKED-on-unreadable per SC-6.

### Card 5: File changes

| File | Change | Phase |
|------|--------|-------|
| `tasks/create/plan-structure.md` | Add Step 2: SC Table Structured Consumption (8-field mapping) | 1 |
| `tasks/create/plan-structure.md` | Add entry criterion: spec SC table must have SC-ID + at least one binding column | 1 |
| `tasks/create/plan-structure.md` | Add sc-to-plan-map.yaml artifact generation substep | 1 |
| `tasks/create/plan-structure.md` | Renumber Steps 2-5 to Steps 3-6 | 1 |
| `tasks/create/plan-structure.md` | Update Step 1 Exit Criteria to reflect new numbering | 1 |
| `tasks/create/create-and-validate.md` | Add Step 4: Cross-Reference Validation (7 checks) | 2 |
| `tasks/create/create-and-validate.md` | Update Step 8 self-review to reference cross-reference validation as pipeline-entry gate | 2 |
| `tasks/create/create-and-validate.md` | Renumber Steps 10-13 to Steps 11-14 | 2 |

**Status**: DESIGNED — 8 file changes across 2 task files, 2 phases.

### Card 6: Behavioral test manifest

| SC | Test Type | Assertion Method | Phase |
|----|-----------|------------------|-------|
| SC-1 | behavioral | `assert_semantic "SC-1" "plan-structure maps SC-IDs to phases"` | 1 |
| SC-2 | behavioral | `assert_semantic "SC-2" "plan consumes all 8 structured fields"` | 1 |
| SC-3 | behavioral | `assert_semantic "SC-3" "plan does not re-create binding/gate values"` | 1 |
| SC-4 | behavioral | `assert_semantic "SC-4" "phase ordering matches spec Phase Binding"` | 1 |
| SC-5 | behavioral | `assert_semantic "SC-5" "verification steps reference Artifact Path"` | 1 |
| SC-6 | behavioral | `assert_semantic "SC-6" "plan-structure BLOCKED on unreadable SC table"` | 1 |
| SC-7 | behavioral | `assert_semantic "SC-7" "create-and-validate cross-reference validation substep exists"` | 2 |
| SC-8 | behavioral | `assert_semantic "SC-8" "spec SC-ID without TDD task is FAIL"` | 2 |
| SC-9 | behavioral | `assert_semantic "SC-9" "phantom SC-ID in plan is FAIL"` | 2 |
| SC-10 | behavioral | `assert_semantic "SC-10" "phase assignment mismatch is FAIL"` | 2 |
| SC-11 | behavioral | `assert_semantic "SC-11" "gate deviation is FAIL"` | 2 |
| SC-12 | behavioral | `assert_semantic "SC-12" "DEC-ID contradiction is FAIL"` | 2 |
| SC-13 | behavioral | `assert_semantic "SC-13" "unmitigated RISK-ID is FAIL"` | 2 |
| SC-14 | behavioral | `assert_semantic "SC-14" "format mismatch against Decomposition Classification is FAIL"` | 2 |
| SC-15 | behavioral | `assert_semantic "SC-15" "missing columns skipped gracefully"` | 2 |
| SC-16 | string | `grep for sc-to-plan-map in plan-structure.md` | 1 |

**Status**: PLANNED — 15 behavioral + 1 string test across 2 phases.

### Card 7: Dependency chain position

```
#848 → #853 → #849 → #850 → #1060 → #1061 → #1062 → #1063 → #1064 (this spec)
```

**Status**: FINAL DEPENDENCY — #1064 is the last spec in the chain. #1060 MUST be merged before implementation begins.

### Card 8: Risk register

| RISK-ID | Description | Likelihood | Impact | SC |
|---------|-------------|------------|--------|-----|
| RISK-1 | Behavioral test run time for 14 SCs | Medium | Medium | SC-1 through SC-15 |
| RISK-2 | Word count limit on task files | Medium | High | All |
| RISK-3 | Legacy spec interaction with SC-6 BLOCKED | Low | High | SC-6, SC-15 |
| RISK-4 | Model availability for semantic assertions | Medium | Medium | SC-1 through SC-15 |