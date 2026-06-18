# Implementation Checklist — #1280

## Pre-Flight

- [ ] Z3 problem validated SAT (confirmed: `.opencode/.issues/1280/problem.yaml`)
- [ ] Plan created at `.opencode/.issues/1280/plan.md`
- [ ] Per-phase SC summary files created (sc-summary-phase-{1,2,3,4,5}.yaml)
- [ ] No global sc-summary.yaml exists

## Phase 1: buildPreImplementationGate() — Step Discreteness

- [ ] G1: sc-coherence-gate — Phase 1 concern coherent with spec R1
- [ ] G2: pre-red-baseline — Source file current, SC-1 traceable
- [ ] G3: red-phase — Content-verification test FAILS (grep for "discrete" in buildPreImplementationGate returns empty)
- [ ] G4: red-doublecheck — RED test confirmed failing
- [ ] G5: post-red-enforcement — Only test files modified
- [ ] G6: green-phase — buildPreImplementationGate() template string includes step discreteness language
- [ ] G7: post-green-enforcement — Only session-enforcement.ts modified
- [ ] G8: checkpoint-commit — `git commit -m "Phase 1: add step discreteness to buildPreImplementationGate"`
- [ ] G9: structural-checks — `npx tsc --noEmit` passes
- [ ] G10: green-doublecheck — Content-verification test PASSES
- [ ] G11: green-vbc — SC-1 verified PASS with grep evidence
- [ ] G12: adversarial-audit — Dual auditor consensus PASS
- [ ] G13: cross-validate — Cross-validate PASS
- [ ] G14: regression-check — Existing enforcement tests still pass
- [ ] G15: review-prep — Compare URL generated
- [ ] G16: exec-summary — Phase 1 completion reported

## Phase 2: buildCorePrinciplesBlock() — Principle Discreteness

- [ ] G1: sc-coherence-gate — Phase 2 concern coherent with spec R2
- [ ] G2: pre-red-baseline — Source file current, SC-2 traceable
- [ ] G3: red-phase — Content-verification test FAILS (grep for "discrete" in buildCorePrinciplesBlock returns empty)
- [ ] G4: red-doublecheck — RED test confirmed failing
- [ ] G5: post-red-enforcement — Only test files modified
- [ ] G6: green-phase — buildCorePrinciplesBlock() template string includes principle discreteness language
- [ ] G7: post-green-enforcement — Only session-enforcement.ts modified
- [ ] G8: checkpoint-commit — `git commit -m "Phase 2: add principle discreteness to buildCorePrinciplesBlock"`
- [ ] G9: structural-checks — `npx tsc --noEmit` passes
- [ ] G10: green-doublecheck — Content-verification test PASSES
- [ ] G11: green-vbc — SC-2 verified PASS with grep evidence
- [ ] G12: adversarial-audit — Dual auditor consensus PASS
- [ ] G13: cross-validate — Cross-validate PASS
- [ ] G14: regression-check — Existing enforcement tests still pass
- [ ] G15: review-prep — Compare URL generated
- [ ] G16: exec-summary — Phase 2 completion reported

## Phase 3: buildTier1EnforcementBlock() — Mandate Discreteness

- [ ] G1: sc-coherence-gate — Phase 3 concern coherent with spec R3
- [ ] G2: pre-red-baseline — Source file current, SC-3 traceable
- [ ] G3: red-phase — Content-verification test FAILS (grep for "discrete" in buildTier1EnforcementBlock returns empty)
- [ ] G4: red-doublecheck — RED test confirmed failing
- [ ] G5: post-red-enforcement — Only test files modified
- [ ] G6: green-phase — buildTier1EnforcementBlock() template string includes mandate discreteness language
- [ ] G7: post-green-enforcement — Only session-enforcement.ts modified
- [ ] G8: checkpoint-commit — `git commit -m "Phase 3: add mandate discreteness to buildTier1EnforcementBlock"`
- [ ] G9: structural-checks — `npx tsc --noEmit` passes
- [ ] G10: green-doublecheck — Content-verification test PASSES
- [ ] G11: green-vbc — SC-3 verified PASS with grep evidence
- [ ] G12: adversarial-audit — Dual auditor consensus PASS
- [ ] G13: cross-validate — Cross-validate PASS
- [ ] G14: regression-check — Existing enforcement tests still pass
- [ ] G15: review-prep — Compare URL generated
- [ ] G16: exec-summary — Phase 3 completion reported

## Phase 4: buildSubAgentPrinciplesBlock() — Multi-Step Context Rejection

- [ ] G1: sc-coherence-gate — Phase 4 concern coherent with spec R4
- [ ] G2: pre-red-baseline — Source file current, SC-4 traceable
- [ ] G3: red-phase — Content-verification test FAILS (grep for "PRELOADED_CONTEXT_REJECTED" or "multi-step" in buildSubAgentPrinciplesBlock returns empty)
- [ ] G4: red-doublecheck — RED test confirmed failing
- [ ] G5: post-red-enforcement — Only test files modified
- [ ] G6: green-phase — buildSubAgentPrinciplesBlock() template string includes multi-step context rejection language
- [ ] G7: post-green-enforcement — Only session-enforcement.ts modified
- [ ] G8: checkpoint-commit — `git commit -m "Phase 4: add multi-step context rejection to buildSubAgentPrinciplesBlock"`
- [ ] G9: structural-checks — `npx tsc --noEmit` passes
- [ ] G10: green-doublecheck — Content-verification test PASSES
- [ ] G11: green-vbc — SC-4 verified PASS with grep evidence
- [ ] G12: adversarial-audit — Dual auditor consensus PASS
- [ ] G13: cross-validate — Cross-validate PASS
- [ ] G14: regression-check — Existing enforcement tests still pass
- [ ] G15: review-prep — Compare URL generated
- [ ] G16: exec-summary — Phase 4 completion reported

## Phase 5: Behavioral Test for Step Discreteness

- [ ] G1: sc-coherence-gate — Phase 5 concern coherent with spec SC-5
- [ ] G2: pre-red-baseline — Behavioral test infrastructure available, SC-5 traceable
- [ ] G3: red-phase — Behavioral test FAILS (agent does NOT treat steps as discrete without enforcement language)
- [ ] G4: red-doublecheck — RED test confirmed failing
- [ ] G5: post-red-enforcement — Only test files modified
- [ ] G6: green-phase — Behavioral test PASSES (enforcement blocks now have discreteness language from Phases 1-4)
- [ ] G7: post-green-enforcement — Only test files modified
- [ ] G8: checkpoint-commit — `git commit -m "Phase 5: add behavioral test for step discreteness enforcement"`
- [ ] G9: structural-checks — `npx tsc --noEmit` passes
- [ ] G10: green-doublecheck — Behavioral test PASSES on re-run
- [ ] G11: green-vbc — SC-5 verified PASS with behavioral evidence
- [ ] G12: adversarial-audit — Dual auditor consensus PASS
- [ ] G13: cross-validate — Cross-validate PASS
- [ ] G14: regression-check — All existing enforcement tests still pass
- [ ] G15: review-prep — Compare URL generated
- [ ] G16: exec-summary — Phase 5 completion reported

## Post-All-Phases Sweep

- [ ] FINISHING CHECKLIST — git status clean, lint/typecheck from scratch
- [ ] PR CREATION — via `github_create_pull_request`, extract `html_url` from response
- [ ] POST-MERGE CLEANUP — delete merged branches, close issues, sync dev
