# Implementation Plan — [#1437](https://github.com/michael-conrad/.opencode/issues/1437) — Holistic inline-execution prevention

- **Goal:** Add DISPATCH_GATE blocks to 4 skills, Persona sections to 20 skills, and behavioral enforcement tests for all 10 SCs to prevent orchestrator inline-execution of skill tasks.
- **Architecture:** Three independent phases — p1 (DISPATCH_GATE blocks, 4 items), p2 (Persona sections, 20 items), p3 (behavioral tests, 10 items). p1 and p2 are independent (parallel). p3 depends on both p1 and p2 complete.
- **Files:**
  - `.opencode/skills/adversarial-audit/SKILL.md`
  - `.opencode/skills/writing-plans/SKILL.md`
  - `.opencode/skills/researcher/SKILL.md`
  - `.opencode/skills/playwright-cli/SKILL.md`
  - `.opencode/skills/approval-gate/SKILL.md`
  - `.opencode/skills/changelog-generator/SKILL.md`
  - `.opencode/skills/completion-core/SKILL.md`
  - `.opencode/skills/correspondence/SKILL.md`
  - `.opencode/skills/engineering-approach/SKILL.md`
  - `.opencode/skills/executing-plans/SKILL.md`
  - `.opencode/skills/finishing-a-development-branch/SKILL.md`
  - `.opencode/skills/implementation-pipeline/SKILL.md`
  - `.opencode/skills/mcp-tool-usage/SKILL.md`
  - `.opencode/skills/plan-creation-pipeline/SKILL.md`
  - `.opencode/skills/pr-creation-workflow/SKILL.md`
  - `.opencode/skills/programming-principles/SKILL.md`
  - `.opencode/skills/receiving-code-review/SKILL.md`
  - `.opencode/skills/requesting-code-review/SKILL.md`
  - `.opencode/skills/skill-creator/SKILL.md`
  - `.opencode/skills/sync-guidelines/SKILL.md`
  - `.opencode/skills/systematic-debugging/SKILL.md`
  - `.opencode/skills/test-driven-development/SKILL.md`
  - `.opencode/tests/behaviors/` (new behavioral test files)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

## Phase 1 — Pre-RED Common

- **Concern:** Establish coherence baseline and pre-red baseline before any implementation begins.
- **Files:** None (verification-only)
- **SCs:** All
- **Dependencies:** None
- **Entry:** Plan approved, solve contract SAT
- **Exit:** Coherence baseline and pre-red baseline artifacts written to `./tmp/1437/artifacts/`

- [ ] 1. **Coherence gate (**clean-room**).** Dispatch `adversarial-audit --task coherence-extraction` with `{issue_number: 1437}`. Verify codebase coherence before any changes. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10**
- [ ] 2. **Pre-red-baseline (**clean-room**).** Dispatch `implementation-pipeline --task pre-red-baseline` with `{issue_number: 1437}`. Verify doc-source currency and SC-ID cross-reference traceability. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10**

## Phase 2 — DISPATCH_GATE blocks

- **Concern:** Add DISPATCH_GATE blocks at primacy position to 4 skills missing them.
- **Files:** `adversarial-audit/SKILL.md`, `writing-plans/SKILL.md`, `researcher/SKILL.md`, `playwright-cli/SKILL.md`
- **SCs:** SC-1, SC-2, SC-3, SC-4
- **Dependencies:** Phase 1 complete
- **Entry:** Coherence baseline and pre-red baseline artifacts written
- **Exit:** All 4 skills have DISPATCH_GATE block at primacy position before Invocation table; content-verification tests pass

### Item 1 — adversarial-audit DISPATCH_GATE

- [ ] 3. **RED (**sub-agent**).** Write content-verification test: `grep "DISPATCH GATE" .opencode/skills/adversarial-audit/SKILL.md` — MUST return empty (test fails = RED). **→ SC-1**
  - [ ] 3.1. **z3-check-red (**inline**).** `solve check` against red-phase output contract. SAT required.
  - [ ] 3.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` with RED-side SC evidence for SC-1. **→ SC-1**
  - [ ] 3.3. **z3-check-red-doublecheck (**inline**).** `solve check` against red-doublecheck output contract. SAT required.
  - [ ] 3.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. Verify git diff shows no source changes yet. **→ SC-1**
  - [ ] 3.5. **z3-check-post-red (**inline**).** `solve check` against post-red-enforcement output contract. SAT required.
- [ ] 4. **GREEN (**sub-agent**).** Add DISPATCH_GATE block at primacy position (before Invocation table) in `adversarial-audit/SKILL.md`. Use the canonical DISPATCH_GATE text from `spec-creation/SKILL.md`. **→ SC-1**
  - [ ] 4.1. **z3-check-green (**inline**).** `solve check` against green-phase output contract. SAT required.
  - [ ] 4.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. Verify git diff shows only the intended file changed. **→ SC-1**
  - [ ] 4.3. **z3-check-post-green (**inline**).** `solve check` against post-green-enforcement output contract. SAT required.
  - [ ] 4.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Creates git tag `1437/checkpoint/phase-2-item-1-opencode`. **→ SC-1**
  - [ ] 4.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit with message: `p1-item1: add DISPATCH_GATE to adversarial-audit SKILL.md`. **→ SC-1**
  - [ ] 4.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. Run lint/typecheck/format on changed files. **→ SC-1**
  - [ ] 4.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` with GREEN-side SC evidence for SC-1. Verify `grep "DISPATCH GATE" .opencode/skills/adversarial-audit/SKILL.md` returns non-empty. **→ SC-1**
  - [ ] 4.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. Produce VbC completion artifact. **→ SC-1**
  - [ ] 4.9. **adversarial-audit (**orchestrator**).** Multi-dispatch: resolve-models → dispatch `verification-audit` with auditor_1 (remediate on non-clean-pass) → same with auditor_2. **→ SC-1**
  - [ ] 4.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate` with `auditor_artifact_paths`. **→ SC-1**

### Item 2 — writing-plans DISPATCH_GATE

- [ ] 5. **RED (**sub-agent**).** Write content-verification test: `grep "DISPATCH GATE" .opencode/skills/writing-plans/SKILL.md` — MUST return empty (test fails = RED). **→ SC-2**
  - [ ] 5.1. **z3-check-red (**inline**).** `solve check` against red-phase output contract. SAT required.
  - [ ] 5.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` with RED-side SC evidence for SC-2. **→ SC-2**
  - [ ] 5.3. **z3-check-red-doublecheck (**inline**).** `solve check` against red-doublecheck output contract. SAT required.
  - [ ] 5.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-2**
  - [ ] 5.5. **z3-check-post-red (**inline**).** `solve check` against post-red-enforcement output contract. SAT required.
- [ ] 6. **GREEN (**sub-agent**).** Add DISPATCH_GATE block at primacy position (before Invocation table) in `writing-plans/SKILL.md`. **→ SC-2**
  - [ ] 6.1. **z3-check-green (**inline**).** `solve check` against green-phase output contract. SAT required.
  - [ ] 6.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-2**
  - [ ] 6.3. **z3-check-post-green (**inline**).** `solve check` against post-green-enforcement output contract. SAT required.
  - [ ] 6.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-2-item-2-opencode`. **→ SC-2**
  - [ ] 6.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p1-item2: add DISPATCH_GATE to writing-plans SKILL.md`. **→ SC-2**
  - [ ] 6.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-2**
  - [ ] 6.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-2. Verify `grep "DISPATCH GATE" .opencode/skills/writing-plans/SKILL.md` returns non-empty. **→ SC-2**
  - [ ] 6.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-2**
  - [ ] 6.9. **adversarial-audit (**orchestrator**).** Multi-dispatch: resolve-models → dispatch `verification-audit` with auditor_1 → auditor_2. **→ SC-2**
  - [ ] 6.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-2**

### Item 3 — researcher DISPATCH_GATE

- [ ] 7. **RED (**sub-agent**).** Content-verification test: `grep "DISPATCH GATE" .opencode/skills/researcher/SKILL.md` — MUST return empty. **→ SC-3**
  - [ ] 7.1–7.5. Same z3-check/red-doublecheck/post-red-enforcement chain as Item 1.
- [ ] 8. **GREEN (**sub-agent**).** Add DISPATCH_GATE block at primacy position in `researcher/SKILL.md`. **→ SC-3**
  - [ ] 8.1–8.10. Same z3-check/green-doublecheck/adversarial-audit/cross-validate chain as Item 1. Tag: `1437/checkpoint/phase-2-item-3-opencode`. Commit: `p1-item3: add DISPATCH_GATE to researcher SKILL.md`.

### Item 4 — playwright-cli DISPATCH_GATE

- [ ] 9. **RED (**sub-agent**).** Content-verification test: `grep "DISPATCH GATE" .opencode/skills/playwright-cli/SKILL.md` — MUST return empty. **→ SC-4**
  - [ ] 9.1–9.5. Same z3-check/red-doublecheck/post-red-enforcement chain.
- [ ] 10. **GREEN (**sub-agent**).** Add DISPATCH_GATE block at primacy position in `playwright-cli/SKILL.md`. **→ SC-4**
  - [ ] 10.1–10.10. Same z3-check/green-doublecheck/adversarial-audit/cross-validate chain. Tag: `1437/checkpoint/phase-2-item-4-opencode`. Commit: `p1-item4: add DISPATCH_GATE to playwright-cli SKILL.md`.

#### Phase 2 VbC

- [ ] 11. **VbC (**clean-room**).** Verify all 4 skills have DISPATCH_GATE block at primacy position. `grep -l "DISPATCH GATE" .opencode/skills/{adversarial-audit,writing-plans,researcher,playwright-cli}/SKILL.md` — all 4 must return non-empty. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving DISPATCH_GATE block addition → entering Persona section addition. Phase 3 (Persona) is independent of Phase 2 — no ordering dependency.

## Phase 3 — Persona sections

- **Concern:** Add `## Persona` sections with inline-vs-dispatch identity-anchoring to 20 skills missing them.
- **Files:** 20 SKILL.md files listed in Files section
- **SCs:** SC-5, SC-6, SC-7
- **Dependencies:** Phase 1 complete (independent of Phase 2)
- **Entry:** Coherence baseline and pre-red baseline artifacts written
- **Exit:** All 20 skills have `## Persona` section with domain-specific language and consequence of inlining

### Item 5 — adversarial-audit Persona

- [ ] 12. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/adversarial-audit/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 12.1–12.5. z3-check/red-doublecheck/post-red-enforcement chain.
- [ ] 13. **GREEN (**sub-agent**).** Add `## Persona` section to `adversarial-audit/SKILL.md` with domain-specific identity-anchoring (dual cross-family auditor router, not an auditor) and consequence of inlining (contaminated pipeline, unverified verdicts). **→ SC-5, SC-6, SC-7**
  - [ ] 13.1–13.10. z3-check/green-doublecheck/adversarial-audit/cross-validate chain. Tag: `1437/checkpoint/phase-3-item-5-opencode`. Commit: `p2-item5: add Persona to adversarial-audit SKILL.md`.

### Item 6 — approval-gate Persona

- [ ] 14. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/approval-gate/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 14.1–14.5. z3-check/red-doublecheck/post-red-enforcement chain.
- [ ] 15. **GREEN (**sub-agent**).** Add `## Persona` section to `approval-gate/SKILL.md` with domain-specific identity-anchoring (authorization scope router, not an implementer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 15.1–15.10. z3-check/green-doublecheck/adversarial-audit/cross-validate chain. Tag: `1437/checkpoint/phase-3-item-6-opencode`. Commit: `p2-item6: add Persona to approval-gate SKILL.md`.

### Item 7 — changelog-generator Persona

- [ ] 16. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/changelog-generator/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 16.1–16.5. z3-check/red-doublecheck/post-red-enforcement chain.
- [ ] 17. **GREEN (**sub-agent**).** Add `## Persona` section to `changelog-generator/SKILL.md` with domain-specific identity-anchoring (release-note dispatcher, not a writer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 17.1–17.10. z3-check/green-doublecheck/adversarial-audit/cross-validate chain. Tag: `1437/checkpoint/phase-3-item-7-opencode`. Commit: `p2-item7: add Persona to changelog-generator SKILL.md`.

### Item 8 — completion-core Persona

- [ ] 18. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/completion-core/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 19. **GREEN (**sub-agent**).** Add `## Persona` section to `completion-core/SKILL.md` with domain-specific identity-anchoring (workflow completion router, not a reporter) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full z3-check/green-doublecheck/adversarial-audit/cross-validate chain. Tag: `1437/checkpoint/phase-3-item-8-opencode`. Commit: `p2-item8: add Persona to completion-core SKILL.md`.

### Item 9 — correspondence Persona

- [ ] 20. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/correspondence/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 21. **GREEN (**sub-agent**).** Add `## Persona` section to `correspondence/SKILL.md` with domain-specific identity-anchoring (stakeholder communication dispatcher, not a drafter) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full chain. Tag: `1437/checkpoint/phase-3-item-9-opencode`. Commit: `p2-item9: add Persona to correspondence SKILL.md`.

### Item 10 — engineering-approach Persona

- [ ] 22. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/engineering-approach/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 23. **GREEN (**sub-agent**).** Add `## Persona` section to `engineering-approach/SKILL.md` with domain-specific identity-anchoring (design-discipline router, not a designer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full chain. Tag: `1437/checkpoint/phase-3-item-10-opencode`. Commit: `p2-item10: add Persona to engineering-approach SKILL.md`.

### Item 11 — executing-plans Persona

- [ ] 24. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/executing-plans/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 25. **GREEN (**sub-agent**).** Add `## Persona` section to `executing-plans/SKILL.md` with domain-specific identity-anchoring (plan-execution router, not an implementer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full chain. Tag: `1437/checkpoint/phase-3-item-11-opencode`. Commit: `p2-item11: add Persona to executing-plans SKILL.md`.

### Item 12 — finishing-a-development-branch Persona

- [ ] 26. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/finishing-a-development-branch/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 27. **GREEN (**sub-agent**).** Add `## Persona` section to `finishing-a-development-branch/SKILL.md` with domain-specific identity-anchoring (branch-finishing gate router, not a checklist executor) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full chain. Tag: `1437/checkpoint/phase-3-item-12-opencode`. Commit: `p2-item12: add Persona to finishing-a-development-branch SKILL.md`.

### Item 13 — implementation-pipeline Persona

- [ ] 28. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/implementation-pipeline/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 29. **GREEN (**sub-agent**).** Add `## Persona` section to `implementation-pipeline/SKILL.md` with domain-specific identity-anchoring (pipeline router, not an implementer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full chain. Tag: `1437/checkpoint/phase-3-item-13-opencode`. Commit: `p2-item13: add Persona to implementation-pipeline SKILL.md`.

### Item 14 — mcp-tool-usage Persona

- [ ] 30. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/mcp-tool-usage/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 31. **GREEN (**sub-agent**).** Add `## Persona` section to `mcp-tool-usage/SKILL.md` with domain-specific identity-anchoring (tool-selection router, not a tool user) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full chain. Tag: `1437/checkpoint/phase-3-item-14-opencode`. Commit: `p2-item14: add Persona to mcp-tool-usage SKILL.md`.

### Item 15 — plan-creation-pipeline Persona

- [ ] 32. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/plan-creation-pipeline/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 33. **GREEN (**sub-agent**).** Add `## Persona` section to `plan-creation-pipeline/SKILL.md` with domain-specific identity-anchoring (plan-creation router, not a planner) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full chain. Tag: `1437/checkpoint/phase-3-item-15-opencode`. Commit: `p2-item15: add Persona to plan-creation-pipeline SKILL.md`.

### Item 16 — playwright-cli Persona

- [ ] 34. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/playwright-cli/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 35. **GREEN (**sub-agent**).** Add `## Persona` section to `playwright-cli/SKILL.md` with domain-specific identity-anchoring (browser-automation dispatcher, not a browser operator) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full chain. Tag: `1437/checkpoint/phase-3-item-16-opencode`. Commit: `p2-item16: add Persona to playwright-cli SKILL.md`.

### Item 17 — pr-creation-workflow Persona

- [ ] 36. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/pr-creation-workflow/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 37. **GREEN (**sub-agent**).** Add `## Persona` section to `pr-creation-workflow/SKILL.md` with domain-specific identity-anchoring (PR-creation router, not a PR author) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full chain. Tag: `1437/checkpoint/phase-3-item-17-opencode`. Commit: `p2-item17: add Persona to pr-creation-workflow SKILL.md`.

### Item 18 — programming-principles Persona

- [ ] 38. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/programming-principles/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 39. **GREEN (**sub-agent**).** Add `## Persona` section to `programming-principles/SKILL.md` with domain-specific identity-anchoring (principle-enforcement router, not a code reviewer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full chain. Tag: `1437/checkpoint/phase-3-item-18-opencode`. Commit: `p2-item18: add Persona to programming-principles SKILL.md`.

### Item 19 — receiving-code-review Persona

- [ ] 40. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/receiving-code-review/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 41. **GREEN (**sub-agent**).** Add `## Persona` section to `receiving-code-review/SKILL.md` with domain-specific identity-anchoring (review-response router, not a fixer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full chain. Tag: `1437/checkpoint/phase-3-item-19-opencode`. Commit: `p2-item19: add Persona to receiving-code-review SKILL.md`.

### Item 20 — requesting-code-review Persona

- [ ] 42. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/requesting-code-review/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 43. **GREEN (**sub-agent**).** Add `## Persona` section to `requesting-code-review/SKILL.md` with domain-specific identity-anchoring (review-request router, not a reviewer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full chain. Tag: `1437/checkpoint/phase-3-item-20-opencode`. Commit: `p2-item20: add Persona to requesting-code-review SKILL.md`.

### Item 21 — skill-creator Persona

- [ ] 44. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/skill-creator/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 45. **GREEN (**sub-agent**).** Add `## Persona` section to `skill-creator/SKILL.md` with domain-specific identity-anchoring (skill-creation router, not a skill author) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full chain. Tag: `1437/checkpoint/phase-3-item-21-opencode`. Commit: `p2-item21: add Persona to skill-creator SKILL.md`.

### Item 22 — sync-guidelines Persona

- [ ] 46. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/sync-guidelines/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 47. **GREEN (**sub-agent**).** Add `## Persona` section to `sync-guidelines/SKILL.md` with domain-specific identity-anchoring (guideline-sync router, not a syncer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full chain. Tag: `1437/checkpoint/phase-3-item-22-opencode`. Commit: `p2-item22: add Persona to sync-guidelines SKILL.md`.

### Item 23 — systematic-debugging Persona

- [ ] 48. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/systematic-debugging/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 49. **GREEN (**sub-agent**).** Add `## Persona` section to `systematic-debugging/SKILL.md` with domain-specific identity-anchoring (debugging router, not a debugger) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full chain. Tag: `1437/checkpoint/phase-3-item-23-opencode`. Commit: `p2-item23: add Persona to systematic-debugging SKILL.md`.

### Item 24 — test-driven-development Persona

- [ ] 50. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/test-driven-development/SKILL.md` — MUST return empty. **→ SC-5**
- [ ] 51. **GREEN (**sub-agent**).** Add `## Persona` section to `test-driven-development/SKILL.md` with domain-specific identity-anchoring (TDD router, not a test writer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - Full chain. Tag: `1437/checkpoint/phase-3-item-24-opencode`. Commit: `p2-item24: add Persona to test-driven-development SKILL.md`.

#### Phase 3 VbC

- [ ] 52. **VbC (**clean-room**).** Verify all 20 skills have `## Persona` section. `for skill in <20-names>; do grep -q "## Persona" .opencode/skills/$skill/SKILL.md || echo MISSING: $skill; done` — zero MISSING lines. Dispatch semantic sub-agent to verify each Persona is domain-specific (not copy-paste generic) and includes consequence of inlining. **→ SC-5, SC-6, SC-7**

**Concern transition:** Leaving Persona section addition → entering behavioral enforcement test creation. Phase 4 depends on Phase 2 (DISPATCH_GATE blocks exist) and Phase 3 (Persona sections exist).

## Phase 4 — Behavioral enforcement tests

- **Concern:** Create behavioral enforcement tests for all 10 SCs that verify agent dispatches via `task()` instead of inlining.
- **Files:** `.opencode/tests/behaviors/` (new test files)
- **SCs:** SC-8, SC-9, SC-10
- **Dependencies:** Phase 2 complete (DISPATCH_GATE blocks exist), Phase 3 complete (Persona sections exist)
- **Entry:** All 24 SKILL.md changes committed; DISPATCH_GATE and Persona content in place
- **Exit:** Behavioral tests exist for all 10 SCs; SC-8 and SC-9 verified via `opencode-cli run`; SC-10 verified via count check

### Item 25 — SC-1 behavioral test (adversarial-audit DISPATCH_GATE)

- [ ] 53. **RED (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/dispatch-gate-adversarial-audit.sh`. Send prompt triggering adversarial-audit skill. Assert via `assert_semantic` that agent dispatches via `task()` — test MUST FAIL (agent doesn't follow rule yet). **→ SC-1, SC-8**
  - [ ] 53.1–53.5. z3-check/red-doublecheck/post-red-enforcement chain.
- [ ] 54. **GREEN (**sub-agent**).** No code change needed — DISPATCH_GATE already added in Phase 2. Re-run behavioral test — MUST PASS. **→ SC-1, SC-8**
  - [ ] 54.1–54.10. z3-check/green-doublecheck/adversarial-audit/cross-validate chain. Tag: `1437/checkpoint/phase-4-item-25-opencode`. Commit: `p3-item25: behavioral test for SC-1 adversarial-audit DISPATCH_GATE`.

### Item 26 — SC-2 behavioral test (writing-plans DISPATCH_GATE)

- [ ] 55. **RED (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/dispatch-gate-writing-plans.sh`. Send prompt triggering writing-plans skill. Assert via `assert_semantic` that agent dispatches via `task()` — test MUST FAIL. **→ SC-2, SC-8**
- [ ] 56. **GREEN (**sub-agent**).** Re-run test — MUST PASS. Tag: `1437/checkpoint/phase-4-item-26-opencode`. Commit: `p3-item26: behavioral test for SC-2 writing-plans DISPATCH_GATE`. **→ SC-2, SC-8**

### Item 27 — SC-3 behavioral test (researcher DISPATCH_GATE)

- [ ] 57. **RED (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/dispatch-gate-researcher.sh`. **→ SC-3, SC-8**
- [ ] 58. **GREEN (**sub-agent**).** Re-run test — MUST PASS. Tag: `1437/checkpoint/phase-4-item-27-opencode`. Commit: `p3-item27: behavioral test for SC-3 researcher DISPATCH_GATE`. **→ SC-3, SC-8**

### Item 28 — SC-4 behavioral test (playwright-cli DISPATCH_GATE)

- [ ] 59. **RED (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/dispatch-gate-playwright-cli.sh`. **→ SC-4, SC-8**
- [ ] 60. **GREEN (**sub-agent**).** Re-run test — MUST PASS. Tag: `1437/checkpoint/phase-4-item-28-opencode`. Commit: `p3-item28: behavioral test for SC-4 playwright-cli DISPATCH_GATE`. **→ SC-4, SC-8**

### Item 29 — SC-5 behavioral test (all 20 skills have Persona)

- [ ] 61. **RED (**sub-agent**).** Write content-verification test at `.opencode/tests/behaviors/persona-all-skills.sh`. Count skills without `## Persona` — MUST be > 0 (test fails = RED). **→ SC-5**
- [ ] 62. **GREEN (**sub-agent**).** Re-run count — MUST be 0. Tag: `1437/checkpoint/phase-4-item-29-opencode`. Commit: `p3-item29: content-verification test for SC-5 all skills have Persona`. **→ SC-5**

### Item 30 — SC-6 behavioral test (domain-specific Persona)

- [ ] 63. **RED (**sub-agent**).** Write semantic test at `.opencode/tests/behaviors/persona-domain-specific.sh`. Sub-agent reads each Persona and judges domain-specificity — test MUST FAIL (Personas don't exist yet). **→ SC-6**
- [ ] 64. **GREEN (**sub-agent**).** Re-run test — MUST PASS. Tag: `1437/checkpoint/phase-4-item-30-opencode`. Commit: `p3-item30: semantic test for SC-6 domain-specific Persona`. **→ SC-6**

### Item 31 — SC-7 behavioral test (consequence of inlining in Persona)

- [ ] 65. **RED (**sub-agent**).** Write string test at `.opencode/tests/behaviors/persona-inlining-consequence.sh`. Grep each Persona for "inline" or "contaminant" or "unverified" — MUST find zero (test fails = RED). **→ SC-7**
- [ ] 66. **GREEN (**sub-agent**).** Re-run grep — MUST find at least one match in each Persona. Tag: `1437/checkpoint/phase-4-item-31-opencode`. Commit: `p3-item31: string test for SC-7 inlining consequence in Persona`. **→ SC-7**

### Item 32 — SC-8 behavioral test (at least one skill dispatches via task())

- [ ] 67. **RED (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/dispatch-via-task.sh`. Send prompt triggering any skill with DISPATCH_GATE. Assert via `assert_semantic` that agent dispatches via `task()` — test MUST FAIL. **→ SC-8**
- [ ] 68. **GREEN (**sub-agent**).** Re-run test — MUST PASS. Tag: `1437/checkpoint/phase-4-item-32-opencode`. Commit: `p3-item32: behavioral test for SC-8 agent dispatches via task()`. **→ SC-8**

### Item 33 — SC-9 behavioral test (spec-creation behavioral test)

- [ ] 69. **RED (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/spec-creation-dispatch.sh`. Send prompt triggering spec-creation skill. Assert via `assert_semantic` that agent dispatches via `task()` — test MUST FAIL. **→ SC-9**
- [ ] 70. **GREEN (**sub-agent**).** Re-run test — MUST PASS. Tag: `1437/checkpoint/phase-4-item-33-opencode`. Commit: `p3-item33: behavioral test for SC-9 spec-creation dispatch`. **→ SC-9**

### Item 34 — SC-10 regression check (all 36 existing DISPATCH_GATE blocks intact)

- [ ] 71. **RED (**sub-agent**).** Write content-verification test at `.opencode/tests/behaviors/dispatch-gate-regression.sh`. Count skills with "DISPATCH GATE" — MUST be < 36 (test fails = RED, showing regression). **→ SC-10**
- [ ] 72. **GREEN (**sub-agent**).** Re-run count — MUST be ≥ 40 (36 existing + 4 new). Tag: `1437/checkpoint/phase-4-item-34-opencode`. Commit: `p3-item34: regression test for SC-10 DISPATCH_GATE count`. **→ SC-10**

#### Phase 4 VbC

- [ ] 73. **VbC (**clean-room**).** Verify all 10 behavioral/content-verification tests exist and pass. Run `bash .opencode/tests/behaviors/ --tag dispatch-gate --tag persona` — all PASS. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10**

**Concern transition:** Leaving behavioral test creation → entering global post-steps. All implementation items complete.

## Phase 5 — Global Post-Steps

- **Concern:** Collect evidence, run adversarial audit, cross-validate, regression check, review-prep, and exec-summary.
- **Files:** None (verification and reporting)
- **SCs:** All
- **Dependencies:** All phases complete
- **Entry:** All 34 items committed; all behavioral tests passing
- **Exit:** Evidence collected, audit passed, review-prep complete, exec-summary reported

- [ ] 74. **Collect behavioral evidence (**sub-agent**).** Collect all behavioral evidence artifacts from `./tmp/behavioral-evidence-*/` into `./tmp/1437/artifacts/`. **→ All SCs**
- [ ] 75. **Adversarial audit (**orchestrator**).** Multi-dispatch: resolve-models → dispatch `verification-audit` with auditor_1 (remediate on non-clean-pass) → same with auditor_2. **→ All SCs**
- [ ] 76. **Cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate` with `auditor_artifact_paths`. **→ All SCs**
- [ ] 77. **Regression check (**sub-agent**).** Dispatch `test-driven-development --task patterns` (regression). Run full behavioral test suite: `bash .opencode/tests/test-enforcement.sh --tag dispatch-gate --tag persona`. **→ All SCs**
- [ ] 78. **Review-prep (**sub-agent**).** Dispatch `git-workflow --task review-prep`. Verify compare URL uses correct base branch (`compare/dev...<branch>`). **→ All SCs**
- [ ] 79. **Exec-summary (**sub-agent**).** Dispatch `completion-core --task completion`. Append lifecycle event, produce chat executive summary with: Summary → Outcome → Blockers → URL → Byline. **→ All SCs**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

- C1. All 4 target skills have DISPATCH_GATE block at primacy position before Invocation table
- C2. All 20 target skills have `## Persona` section with inline-vs-dispatch identity-anchoring
- C3. Each new Persona section uses domain-specific language (verified by semantic sub-agent)
- C4. Each new Persona section includes consequence of inlining (contaminated pipeline, unverified deliverable)
- C5. Behavioral enforcement test exists for at least one skill verifying agent dispatches via `task()` instead of inlining
- C6. `spec-creation` SKILL.md changes have behavioral enforcement test
- C7. All existing DISPATCH_GATE blocks (36 skills) remain intact — no regressions
- C8. All behavioral tests pass via `bash .opencode/tests/test-enforcement.sh --tag dispatch-gate --tag persona`
- C9. Adversarial audit passes with dual cross-family auditor consensus
- C10. Review-prep complete with correct compare URL
