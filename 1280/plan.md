# Plan: Clarify Step Discreteness in Injected Compliance Enforcement Blocks

**Spec:** #1280
**Authorization scope:** `for_pr` (expanded from auto-approved for_plan)
**Halt at:** `pr_created`
**PR strategy:** `stacked`
**Decision:** Separate (multi-phase, single file, distinct concern per function)

## Phase 1: buildPreImplementationGate() — Step Discreteness

**Concern:** Add language to the 4-step checklist clarifying each step is discrete and must not be combined.

**File:** `.opencode/plugins/session-enforcement.ts` — `buildPreImplementationGate()` (line 821)

**SC-1:** `buildPreImplementationGate()` output includes "discrete" or "must not be combined"

**SC Summary:** `.opencode/.issues/1280/sc-summary-phase-1.yaml`

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1280, "phase": 1}` | SC-1 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1280, "phase": 1}` | SC-1 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "Write a behavioral test that verifies buildPreImplementationGate() output includes step discreteness language and FAILS because the language doesn't exist yet. Use assert_semantic for behavioral verification.", "issue_number": 1280, "phase": 1}` | SC-1 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1280, "phase": 1}` | SC-1 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1280, "phase": 1}` | SC-1 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "Modify the buildPreImplementationGate function so its output includes language that each step is discrete and must not be combined into a single task() call. Add 1-2 sentences after the step list.", "issue_number": 1280, "phase": 1}` | SC-1 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1280, "phase": 1}` | SC-1 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1280, "phase": 1}` | SC-1 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1280, "phase": 1}` | SC-1 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1280, "phase": 1}` | SC-1 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1280, "phase": 1}` | SC-1 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1280, "phase": 1}` | SC-1 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1280, "phase": 1}` | SC-1 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1280, "phase": 1}` | SC-1 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1280, "phase": 1}` | SC-1 |

### Per-Unit Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Phase 1 concern (step discreteness for pre-implementation gate) is coherent with spec R1 |
| 2 | pre-red-baseline | Source file `.opencode/plugins/session-enforcement.ts` is current; SC-1 traceable to spec |
| 3 | red-phase | Behavioral test exists and FAILS: `assert_semantic` confirms buildPreImplementationGate output lacks step discreteness language |
| 4 | red-doublecheck | RED test confirmed failing — no false positive |
| 5 | post-red-enforcement | Only test files modified (no src/ changes yet) |
| 6 | green-phase | buildPreImplementationGate() template string includes step discreteness language |
| 7 | post-green-enforcement | Only session-enforcement.ts modified (no test file changes) |
| 8 | checkpoint-commit | Git commit with message "Phase 1: add step discreteness to buildPreImplementationGate" |
| 9 | structural-checks | `npx tsc --noEmit` passes; no lint errors |
| 10 | green-doublecheck | Behavioral test PASSES: `assert_semantic` confirms buildPreImplementationGate output includes step discreteness language |
| 11 | green-vbc | SC-1 verified PASS with behavioral evidence (assert_semantic) — DDL cost: minutes at gate 1 vs. death spiral if structural-only |
| 12 | adversarial-audit | Dual auditor consensus PASS on Phase 1 changes |
| 13 | cross-validate | Cross-validate PASS — no evidence type mismatch |
| 14 | regression-check | Existing enforcement tests still pass |
| 15 | review-prep | Compare URL generated, PR body drafted |
| 16 | exec-summary | Phase 1 completion reported |

## Phase 2: buildCorePrinciplesBlock() — Principle Discreteness

**Concern:** Add language that each principle is a discrete mandate and actions implied by principles must be executed as discrete steps.

**File:** `.opencode/plugins/session-enforcement.ts` — `buildCorePrinciplesBlock()` (line 836)

**SC-2:** `buildCorePrinciplesBlock()` output includes "discrete"

**SC Summary:** `.opencode/.issues/1280/sc-summary-phase-2.yaml`

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1280, "phase": 2}` | SC-2 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1280, "phase": 2}` | SC-2 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "Write a behavioral test that verifies buildCorePrinciplesBlock() output includes principle discreteness language and FAILS because the language doesn't exist yet. Use assert_semantic for behavioral verification.", "issue_number": 1280, "phase": 2}` | SC-2 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1280, "phase": 2}` | SC-2 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1280, "phase": 2}` | SC-2 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "Modify the buildCorePrinciplesBlock function so its output includes language that each principle is a discrete mandate and actions implied by principles must be executed as discrete steps. Add 1-2 sentences after the principle list.", "issue_number": 1280, "phase": 2}` | SC-2 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1280, "phase": 2}` | SC-2 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-2 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1280, "phase": 2}` | SC-2 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1280, "phase": 2}` | SC-2 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1280, "phase": 2}` | SC-2 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1280, "phase": 2}` | SC-2 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1280, "phase": 2}` | SC-2 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1280, "phase": 2}` | SC-2 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1280, "phase": 2}` | SC-2 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1280, "phase": 2}` | SC-2 |

### Per-Unit Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Phase 2 concern (principle discreteness for core principles) is coherent with spec R2 |
| 2 | pre-red-baseline | Source file is current; SC-2 traceable to spec |
| 3 | red-phase | Behavioral test exists and FAILS: `assert_semantic` confirms buildCorePrinciplesBlock output lacks principle discreteness language |
| 4 | red-doublecheck | RED test confirmed failing |
| 5 | post-red-enforcement | Only test files modified |
| 6 | green-phase | buildCorePrinciplesBlock() template string includes principle discreteness language |
| 7 | post-green-enforcement | Only session-enforcement.ts modified |
| 8 | checkpoint-commit | Git commit with message "Phase 2: add principle discreteness to buildCorePrinciplesBlock" |
| 9 | structural-checks | `npx tsc --noEmit` passes |
| 10 | green-doublecheck | Behavioral test PASSES: `assert_semantic` confirms buildCorePrinciplesBlock output includes principle discreteness language |
| 11 | green-vbc | SC-2 verified PASS with behavioral evidence (assert_semantic) — DDL cost: minutes at gate 1 vs. death spiral if structural-only |
| 12 | adversarial-audit | Dual auditor consensus PASS |
| 13 | cross-validate | Cross-validate PASS |
| 14 | regression-check | Existing enforcement tests still pass |
| 15 | review-prep | Compare URL generated |
| 16 | exec-summary | Phase 2 completion reported |

## Phase 3: buildTier1EnforcementBlock() — Mandate Discreteness

**Concern:** Add language that each mandate is discrete and independently enforceable.

**File:** `.opencode/plugins/session-enforcement.ts` — `buildTier1EnforcementBlock()` (line 860)

**SC-3:** `buildTier1EnforcementBlock()` output includes "discrete"

**SC Summary:** `.opencode/.issues/1280/sc-summary-phase-3.yaml`

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1280, "phase": 3}` | SC-3 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1280, "phase": 3}` | SC-3 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "Write a behavioral test that verifies buildTier1EnforcementBlock() output includes mandate discreteness language and FAILS because the language doesn't exist yet. Use assert_semantic for behavioral verification.", "issue_number": 1280, "phase": 3}` | SC-3 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1280, "phase": 3}` | SC-3 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1280, "phase": 3}` | SC-3 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "Modify the buildTier1EnforcementBlock function so its output includes language that each mandate is discrete and independently enforceable. Add 1-2 sentences after the mandate list.", "issue_number": 1280, "phase": 3}` | SC-3 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1280, "phase": 3}` | SC-3 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-3 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1280, "phase": 3}` | SC-3 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1280, "phase": 3}` | SC-3 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1280, "phase": 3}` | SC-3 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1280, "phase": 3}` | SC-3 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1280, "phase": 3}` | SC-3 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1280, "phase": 3}` | SC-3 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1280, "phase": 3}` | SC-3 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1280, "phase": 3}` | SC-3 |

### Per-Unit Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Phase 3 concern (mandate discreteness for Tier 1 enforcement) is coherent with spec R3 |
| 2 | pre-red-baseline | Source file is current; SC-3 traceable to spec |
| 3 | red-phase | Behavioral test exists and FAILS: `assert_semantic` confirms buildTier1EnforcementBlock output lacks mandate discreteness language |
| 4 | red-doublecheck | RED test confirmed failing |
| 5 | post-red-enforcement | Only test files modified |
| 6 | green-phase | buildTier1EnforcementBlock() template string includes mandate discreteness language |
| 7 | post-green-enforcement | Only session-enforcement.ts modified |
| 8 | checkpoint-commit | Git commit with message "Phase 3: add mandate discreteness to buildTier1EnforcementBlock" |
| 9 | structural-checks | `npx tsc --noEmit` passes |
| 10 | green-doublecheck | Behavioral test PASSES: `assert_semantic` confirms buildTier1EnforcementBlock output includes mandate discreteness language |
| 11 | green-vbc | SC-3 verified PASS with behavioral evidence (assert_semantic) — DDL cost: minutes at gate 1 vs. death spiral if structural-only |
| 12 | adversarial-audit | Dual auditor consensus PASS |
| 13 | cross-validate | Cross-validate PASS |
| 14 | regression-check | Existing enforcement tests still pass |
| 15 | review-prep | Compare URL generated |
| 16 | exec-summary | Phase 3 completion reported |

## Phase 4: buildSubAgentPrinciplesBlock() — Multi-Step Context Rejection

**Concern:** Add language that sub-agents receiving multi-step context must return PRELOADED_CONTEXT_REJECTED.

**File:** `.opencode/plugins/session-enforcement.ts` — `buildSubAgentPrinciplesBlock()` (line 849)

**SC-4:** `buildSubAgentPrinciplesBlock()` output includes "PRELOADED_CONTEXT_REJECTED" or "multi-step"

**SC Summary:** `.opencode/.issues/1280/sc-summary-phase-4.yaml`

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1280, "phase": 4}` | SC-4 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1280, "phase": 4}` | SC-4 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "Write a behavioral test that verifies buildSubAgentPrinciplesBlock() output includes PRELOADED_CONTEXT_REJECTED or multi-step language and FAILS because the language doesn't exist yet. Use assert_semantic for behavioral verification.", "issue_number": 1280, "phase": 4}` | SC-4 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1280, "phase": 4}` | SC-4 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1280, "phase": 4}` | SC-4 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "Modify the buildSubAgentPrinciplesBlock function so its output includes language that sub-agents receiving multi-step context must return PRELOADED_CONTEXT_REJECTED. Add 1-2 sentences after the principle list.", "issue_number": 1280, "phase": 4}` | SC-4 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1280, "phase": 4}` | SC-4 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-4 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1280, "phase": 4}` | SC-4 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1280, "phase": 4}` | SC-4 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1280, "phase": 4}` | SC-4 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1280, "phase": 4}` | SC-4 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1280, "phase": 4}` | SC-4 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1280, "phase": 4}` | SC-4 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1280, "phase": 4}` | SC-4 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1280, "phase": 4}` | SC-4 |

### Per-Unit Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Phase 4 concern (multi-step context rejection for sub-agent principles) is coherent with spec R4 |
| 2 | pre-red-baseline | Source file is current; SC-4 traceable to spec |
| 3 | red-phase | Behavioral test exists and FAILS: `assert_semantic` confirms buildSubAgentPrinciplesBlock output lacks PRELOADED_CONTEXT_REJECTED or multi-step language |
| 4 | red-doublecheck | RED test confirmed failing |
| 5 | post-red-enforcement | Only test files modified |
| 6 | green-phase | buildSubAgentPrinciplesBlock() template string includes multi-step context rejection language |
| 7 | post-green-enforcement | Only session-enforcement.ts modified |
| 8 | checkpoint-commit | Git commit with message "Phase 4: add multi-step context rejection to buildSubAgentPrinciplesBlock" |
| 9 | structural-checks | `npx tsc --noEmit` passes |
| 10 | green-doublecheck | Behavioral test PASSES: `assert_semantic` confirms buildSubAgentPrinciplesBlock output includes PRELOADED_CONTEXT_REJECTED or multi-step language |
| 11 | green-vbc | SC-4 verified PASS with behavioral evidence (assert_semantic) — DDL cost: minutes at gate 1 vs. death spiral if structural-only |
| 12 | adversarial-audit | Dual auditor consensus PASS |
| 13 | cross-validate | Cross-validate PASS |
| 14 | regression-check | Existing enforcement tests still pass |
| 15 | review-prep | Compare URL generated |
| 16 | exec-summary | Phase 4 completion reported |

## Phase 5: Behavioral Test for Step Discreteness

**Concern:** Create behavioral enforcement test that verifies the agent treats each enforcement block step as discrete (does not combine steps into a single task() call).

**SC-5:** Behavioral test verifies agent treats each step as discrete

**SC Summary:** `.opencode/.issues/1280/sc-summary-phase-5.yaml`

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1280, "phase": 5}` | SC-5 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1280, "phase": 5}` | SC-5 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "Write behavioral test at .opencode/tests/behaviors/1280-phase5-behavioral.sh that sends a prompt triggering enforcement blocks and uses assert_semantic to verify the agent dispatches discrete steps. Test MUST FAIL because the enforcement blocks don't have discreteness language yet.", "issue_number": 1280, "phase": 5}` | SC-5 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1280, "phase": 5}` | SC-5 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1280, "phase": 5}` | SC-5 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "No code change needed — the behavioral test verifies the combined effect of Phases 1-4. The test should PASS now because all four enforcement blocks have discreteness language.", "issue_number": 1280, "phase": 5}` | SC-5 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1280, "phase": 5}` | SC-5 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-5 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1280, "phase": 5}` | SC-5 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1280, "phase": 5}` | SC-5 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1280, "phase": 5}` | SC-5 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1280, "phase": 5}` | SC-5 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1280, "phase": 5}` | SC-5 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1280, "phase": 5}` | SC-5 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1280, "phase": 5}` | SC-5 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1280, "phase": 5}` | SC-5 |

### Per-Unit Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Phase 5 concern (behavioral test for step discreteness) is coherent with spec SC-5 |
| 2 | pre-red-baseline | Behavioral test infrastructure available; SC-5 traceable to spec |
| 3 | red-phase | Behavioral test exists and FAILS: `bash .opencode/tests/behaviors/1280-phase5-behavioral.sh` returns non-zero |
| 4 | red-doublecheck | RED test confirmed failing — agent does NOT treat steps as discrete without enforcement language |
| 5 | post-red-enforcement | Only test files modified |
| 6 | green-phase | Behavioral test PASSES: `bash .opencode/tests/behaviors/1280-phase5-behavioral.sh` returns zero (enforcement blocks now have discreteness language from Phases 1-4) |
| 7 | post-green-enforcement | Only test files modified |
| 8 | checkpoint-commit | Git commit with message "Phase 5: add behavioral test for step discreteness enforcement" |
| 9 | structural-checks | `npx tsc --noEmit` passes |
| 10 | green-doublecheck | Behavioral test PASSES on re-run |
| 11 | green-vbc | SC-5 verified PASS with behavioral evidence |
| 12 | adversarial-audit | Dual auditor consensus PASS |
| 13 | cross-validate | Cross-validate PASS |
| 14 | regression-check | All existing enforcement tests still pass |
| 15 | review-prep | Compare URL generated |
| 16 | exec-summary | Phase 5 completion reported |

## Inter-Phase Handoff

Between each phase, update Z3 state and verify dependency contract remains SAT. Phases 1-4 are independent (different template strings in the same file, no overlap). Phase 5 depends on Phases 1-4 being complete (behavioral test verifies combined effect).

## Post-All-Phases Sweep

- [ ] FINISHING CHECKLIST — git status clean, lint/typecheck from scratch
- [ ] PR CREATION — via `github_create_pull_request`, extract `html_url` from response
- [ ] POST-MERGE CLEANUP — delete merged branches, close issues, sync dev
