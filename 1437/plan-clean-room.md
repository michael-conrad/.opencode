# Implementation Plan — [#1437](https://github.com/michael-conrad/.opencode/issues/1437) — Holistic inline-execution prevention

- **Goal:** Add DISPATCH_GATE blocks to 4 skills, Persona sections to 20 skills, and behavioral enforcement tests for all 10 SCs to prevent orchestrator inline-execution of skill tasks.
- **Architecture:** Three phases — p1 (DISPATCH_GATE blocks, 4 items), p2 (Persona sections, 20 items), p3 (behavioral tests, 10 items). p1 and p2 are independent (parallel). p3 depends on both p1 and p2 complete.
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
  - [ ] 4.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{artifact_path: ..., sc_ids: [SC-1]}`. **→ SC-1**
  - [ ] 4.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate` with `{auditor_artifact_paths: [...]}`. **→ SC-1**

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
  - [ ] 6.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{artifact_path: ..., sc_ids: [SC-2]}`. **→ SC-2**
  - [ ] 6.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-2**

### Item 3 — researcher DISPATCH_GATE

- [ ] 7. **RED (**sub-agent**).** Content-verification test: `grep "DISPATCH GATE" .opencode/skills/researcher/SKILL.md` — MUST return empty. **→ SC-3**
  - [ ] 7.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 7.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-3. **→ SC-3**
  - [ ] 7.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 7.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-3**
  - [ ] 7.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 8. **GREEN (**sub-agent**).** Add DISPATCH_GATE block at primacy position in `researcher/SKILL.md`. **→ SC-3**
  - [ ] 8.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 8.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-3**
  - [ ] 8.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 8.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-2-item-3-opencode`. **→ SC-3**
  - [ ] 8.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p1-item3: add DISPATCH_GATE to researcher SKILL.md`. **→ SC-3**
  - [ ] 8.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-3**
  - [ ] 8.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-3. **→ SC-3**
  - [ ] 8.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-3**
  - [ ] 8.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-3]}`. **→ SC-3**
  - [ ] 8.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-3**

### Item 4 — playwright-cli DISPATCH_GATE

- [ ] 9. **RED (**sub-agent**).** Content-verification test: `grep "DISPATCH GATE" .opencode/skills/playwright-cli/SKILL.md` — MUST return empty. **→ SC-4**
  - [ ] 9.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 9.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-4. **→ SC-4**
  - [ ] 9.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 9.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-4**
  - [ ] 9.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 10. **GREEN (**sub-agent**).** Add DISPATCH_GATE block at primacy position in `playwright-cli/SKILL.md`. **→ SC-4**
  - [ ] 10.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 10.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-4**
  - [ ] 10.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 10.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-2-item-4-opencode`. **→ SC-4**
  - [ ] 10.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p1-item4: add DISPATCH_GATE to playwright-cli SKILL.md`. **→ SC-4**
  - [ ] 10.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-4**
  - [ ] 10.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-4. **→ SC-4**
  - [ ] 10.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-4**
  - [ ] 10.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-4]}`. **→ SC-4**
  - [ ] 10.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-4**

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
  - [ ] 12.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 12.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 12.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 12.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 12.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 13. **GREEN (**sub-agent**).** Add `## Persona` section to `adversarial-audit/SKILL.md` with domain-specific identity-anchoring (dual cross-family auditor router, not an auditor) and consequence of inlining (contaminated pipeline, unverified verdicts). **→ SC-5, SC-6, SC-7**
  - [ ] 13.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 13.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 13.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 13.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-5-opencode`. **→ SC-5**
  - [ ] 13.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item5: add Persona to adversarial-audit SKILL.md`. **→ SC-5**
  - [ ] 13.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 13.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 13.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 13.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 13.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 6 — approval-gate Persona

- [ ] 14. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/approval-gate/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 14.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 14.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 14.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 14.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 14.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 15. **GREEN (**sub-agent**).** Add `## Persona` section to `approval-gate/SKILL.md` with domain-specific identity-anchoring (authorization scope router, not an implementer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 15.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 15.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 15.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 15.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-6-opencode`. **→ SC-5**
  - [ ] 15.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item6: add Persona to approval-gate SKILL.md`. **→ SC-5**
  - [ ] 15.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 15.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 15.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 15.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 15.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 7 — changelog-generator Persona

- [ ] 16. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/changelog-generator/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 16.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 16.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 16.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 16.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 16.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 17. **GREEN (**sub-agent**).** Add `## Persona` section to `changelog-generator/SKILL.md` with domain-specific identity-anchoring (release-note dispatcher, not a writer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 17.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 17.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 17.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 17.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-7-opencode`. **→ SC-5**
  - [ ] 17.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item7: add Persona to changelog-generator SKILL.md`. **→ SC-5**
  - [ ] 17.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 17.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 17.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 17.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 17.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 8 — completion-core Persona

- [ ] 18. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/completion-core/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 18.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 18.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 18.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 18.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 18.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 19. **GREEN (**sub-agent**).** Add `## Persona` section to `completion-core/SKILL.md` with domain-specific identity-anchoring (workflow completion router, not a reporter) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 19.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 19.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 19.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 19.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-8-opencode`. **→ SC-5**
  - [ ] 19.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item8: add Persona to completion-core SKILL.md`. **→ SC-5**
  - [ ] 19.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 19.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 19.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 19.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 19.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 9 — correspondence Persona

- [ ] 20. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/correspondence/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 20.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 20.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 20.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 20.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 20.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 21. **GREEN (**sub-agent**).** Add `## Persona` section to `correspondence/SKILL.md` with domain-specific identity-anchoring (stakeholder communication dispatcher, not a drafter) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 21.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 21.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 21.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 21.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-9-opencode`. **→ SC-5**
  - [ ] 21.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item9: add Persona to correspondence SKILL.md`. **→ SC-5**
  - [ ] 21.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 21.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 21.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 21.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 21.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 10 — engineering-approach Persona

- [ ] 22. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/engineering-approach/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 22.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 22.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 22.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 22.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 22.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 23. **GREEN (**sub-agent**).** Add `## Persona` section to `engineering-approach/SKILL.md` with domain-specific identity-anchoring (design-discipline router, not a designer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 23.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 23.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 23.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 23.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-10-opencode`. **→ SC-5**
  - [ ] 23.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item10: add Persona to engineering-approach SKILL.md`. **→ SC-5**
  - [ ] 23.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 23.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 23.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 23.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 23.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 11 — executing-plans Persona

- [ ] 24. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/executing-plans/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 24.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 24.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 24.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 24.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 24.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 25. **GREEN (**sub-agent**).** Add `## Persona` section to `executing-plans/SKILL.md` with domain-specific identity-anchoring (plan-execution router, not an implementer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 25.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 25.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 25.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 25.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-11-opencode`. **→ SC-5**
  - [ ] 25.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item11: add Persona to executing-plans SKILL.md`. **→ SC-5**
  - [ ] 25.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 25.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 25.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 25.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 25.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 12 — finishing-a-development-branch Persona

- [ ] 26. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/finishing-a-development-branch/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 26.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 26.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 26.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 26.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 26.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 27. **GREEN (**sub-agent**).** Add `## Persona` section to `finishing-a-development-branch/SKILL.md` with domain-specific identity-anchoring (branch-finishing gate router, not a checklist executor) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 27.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 27.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 27.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 27.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-12-opencode`. **→ SC-5**
  - [ ] 27.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item12: add Persona to finishing-a-development-branch SKILL.md`. **→ SC-5**
  - [ ] 27.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 27.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 27.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 27.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 27.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 13 — implementation-pipeline Persona

- [ ] 28. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/implementation-pipeline/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 28.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 28.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 28.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 28.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 28.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 29. **GREEN (**sub-agent**).** Add `## Persona` section to `implementation-pipeline/SKILL.md` with domain-specific identity-anchoring (pipeline router, not an implementer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 29.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 29.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 29.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 29.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-13-opencode`. **→ SC-5**
  - [ ] 29.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item13: add Persona to implementation-pipeline SKILL.md`. **→ SC-5**
  - [ ] 29.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 29.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 29.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 29.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 29.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 14 — mcp-tool-usage Persona

- [ ] 30. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/mcp-tool-usage/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 30.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 30.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 30.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 30.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 30.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 31. **GREEN (**sub-agent**).** Add `## Persona` section to `mcp-tool-usage/SKILL.md` with domain-specific identity-anchoring (tool-selection router, not a tool user) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 31.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 31.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 31.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 31.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-14-opencode`. **→ SC-5**
  - [ ] 31.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item14: add Persona to mcp-tool-usage SKILL.md`. **→ SC-5**
  - [ ] 31.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 31.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 31.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 31.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 31.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 15 — plan-creation-pipeline Persona

- [ ] 32. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/plan-creation-pipeline/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 32.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 32.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 32.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 32.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 32.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 33. **GREEN (**sub-agent**).** Add `## Persona` section to `plan-creation-pipeline/SKILL.md` with domain-specific identity-anchoring (plan-creation router, not a planner) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 33.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 33.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 33.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 33.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-15-opencode`. **→ SC-5**
  - [ ] 33.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item15: add Persona to plan-creation-pipeline SKILL.md`. **→ SC-5**
  - [ ] 33.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 33.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 33.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 33.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 33.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 16 — playwright-cli Persona

- [ ] 34. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/playwright-cli/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 34.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 34.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 34.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 34.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 34.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 35. **GREEN (**sub-agent**).** Add `## Persona` section to `playwright-cli/SKILL.md` with domain-specific identity-anchoring (browser-automation dispatcher, not a browser operator) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 35.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 35.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 35.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 35.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-16-opencode`. **→ SC-5**
  - [ ] 35.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item16: add Persona to playwright-cli SKILL.md`. **→ SC-5**
  - [ ] 35.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 35.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 35.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 35.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 35.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 17 — pr-creation-workflow Persona

- [ ] 36. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/pr-creation-workflow/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 36.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 36.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 36.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 36.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 36.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 37. **GREEN (**sub-agent**).** Add `## Persona` section to `pr-creation-workflow/SKILL.md` with domain-specific identity-anchoring (PR-creation router, not a PR author) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 37.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 37.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 37.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 37.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-17-opencode`. **→ SC-5**
  - [ ] 37.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item17: add Persona to pr-creation-workflow SKILL.md`. **→ SC-5**
  - [ ] 37.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 37.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 37.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 37.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 37.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 18 — programming-principles Persona

- [ ] 38. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/programming-principles/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 38.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 38.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 38.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 38.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 38.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 39. **GREEN (**sub-agent**).** Add `## Persona` section to `programming-principles/SKILL.md` with domain-specific identity-anchoring (principle-enforcement router, not a code reviewer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 39.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 39.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 39.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 39.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-18-opencode`. **→ SC-5**
  - [ ] 39.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item18: add Persona to programming-principles SKILL.md`. **→ SC-5**
  - [ ] 39.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 39.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 39.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 39.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 39.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 19 — receiving-code-review Persona

- [ ] 40. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/receiving-code-review/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 40.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 40.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 40.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 40.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 40.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 41. **GREEN (**sub-agent**).** Add `## Persona` section to `receiving-code-review/SKILL.md` with domain-specific identity-anchoring (review-response router, not a fixer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 41.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 41.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 41.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 41.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-19-opencode`. **→ SC-5**
  - [ ] 41.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item19: add Persona to receiving-code-review SKILL.md`. **→ SC-5**
  - [ ] 41.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 41.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 41.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 41.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 41.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 20 — requesting-code-review Persona

- [ ] 42. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/requesting-code-review/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 42.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 42.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 42.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 42.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 42.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 43. **GREEN (**sub-agent**).** Add `## Persona` section to `requesting-code-review/SKILL.md` with domain-specific identity-anchoring (review-request router, not a reviewer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 43.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 43.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 43.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 43.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-20-opencode`. **→ SC-5**
  - [ ] 43.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item20: add Persona to requesting-code-review SKILL.md`. **→ SC-5**
  - [ ] 43.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 43.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 43.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 43.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 43.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 21 — skill-creator Persona

- [ ] 44. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/skill-creator/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 44.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 44.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 44.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 44.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 44.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 45. **GREEN (**sub-agent**).** Add `## Persona` section to `skill-creator/SKILL.md` with domain-specific identity-anchoring (skill-creation router, not a skill author) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 45.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 45.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 45.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 45.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-21-opencode`. **→ SC-5**
  - [ ] 45.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item21: add Persona to skill-creator SKILL.md`. **→ SC-5**
  - [ ] 45.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 45.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 45.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 45.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 45.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 22 — sync-guidelines Persona

- [ ] 46. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/sync-guidelines/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 46.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 46.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 46.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 46.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 46.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 47. **GREEN (**sub-agent**).** Add `## Persona` section to `sync-guidelines/SKILL.md` with domain-specific identity-anchoring (guideline-sync router, not a syncer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 47.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 47.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 47.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 47.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-22-opencode`. **→ SC-5**
  - [ ] 47.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item22: add Persona to sync-guidelines SKILL.md`. **→ SC-5**
  - [ ] 47.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 47.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 47.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 47.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 47.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 23 — systematic-debugging Persona

- [ ] 48. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/systematic-debugging/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 48.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 48.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 48.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 48.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 48.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 49. **GREEN (**sub-agent**).** Add `## Persona` section to `systematic-debugging/SKILL.md` with domain-specific identity-anchoring (debugging router, not a debugger) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 49.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 49.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 49.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 49.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-23-opencode`. **→ SC-5**
  - [ ] 49.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item23: add Persona to systematic-debugging SKILL.md`. **→ SC-5**
  - [ ] 49.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 49.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 49.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 49.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 49.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

### Item 24 — test-driven-development Persona

- [ ] 50. **RED (**sub-agent**).** Content-verification test: `grep "## Persona" .opencode/skills/test-driven-development/SKILL.md` — MUST return empty. **→ SC-5**
  - [ ] 50.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 50.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 50.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 50.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 50.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 51. **GREEN (**sub-agent**).** Add `## Persona` section to `test-driven-development/SKILL.md` with domain-specific identity-anchoring (TDD router, not a test writer) and consequence of inlining. **→ SC-5, SC-6, SC-7**
  - [ ] 51.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 51.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 51.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 51.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-3-item-24-opencode`. **→ SC-5**
  - [ ] 51.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p2-item24: add Persona to test-driven-development SKILL.md`. **→ SC-5**
  - [ ] 51.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 51.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5, SC-6, SC-7. **→ SC-5, SC-6, SC-7**
  - [ ] 51.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 51.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5, SC-6, SC-7]}`. **→ SC-5, SC-6, SC-7**
  - [ ] 51.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5, SC-6, SC-7**

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

- [ ] 53. **RED (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/1437-sc1-dispatch-gate-adversarial-audit.sh`. Send prompt triggering adversarial-audit skill. Assert via `assert_semantic` that agent dispatches via `task()` — test MUST FAIL (agent doesn't follow rule yet). **→ SC-1, SC-8**
  - [ ] 53.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 53.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-1, SC-8. **→ SC-1, SC-8**
  - [ ] 53.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 53.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-1, SC-8**
  - [ ] 53.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 54. **GREEN (**sub-agent**).** No code change needed — DISPATCH_GATE already added in Phase 2. Re-run behavioral test — MUST PASS. **→ SC-1, SC-8**
  - [ ] 54.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 54.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-1, SC-8**
  - [ ] 54.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 54.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Tag: `1437/checkpoint/phase-4-item-25-opencode`. **→ SC-1, SC-8**
  - [ ] 54.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Commit: `p3-item25: behavioral test for SC-1 adversarial-audit DISPATCH_GATE`. **→ SC-1, SC-8**
  - [ ] 54.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-1, SC-8**
  - [ ] 54.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-1, SC-8. **→ SC-1, SC-8**
  - [ ] 54.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-1, SC-8**
  - [ ] 54.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-1, SC-8]}`. **→ SC-1, SC-8**
  - [ ] 54.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-1, SC-8**

### Item 26 — SC-2 behavioral test (writing-plans DISPATCH_GATE)

- [ ] 55. **RED (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/1437-sc2-dispatch-gate-writing-plans.sh`. Send prompt triggering writing-plans skill. Assert via `assert_semantic` that agent dispatches via `task()` — test MUST FAIL. **→ SC-2, SC-8**
  - [ ] 55.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 55.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-2, SC-8. **→ SC-2, SC-8**
  - [ ] 55.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 55.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-2, SC-8**
  - [ ] 55.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 56. **GREEN (**sub-agent**).** Re-run test — MUST PASS. Tag: `1437/checkpoint/phase-4-item-26-opencode`. Commit: `p3-item26: behavioral test for SC-2 writing-plans DISPATCH_GATE`. **→ SC-2, SC-8**
  - [ ] 56.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 56.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-2, SC-8**
  - [ ] 56.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 56.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. **→ SC-2, SC-8**
  - [ ] 56.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. **→ SC-2, SC-8**
  - [ ] 56.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-2, SC-8**
  - [ ] 56.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-2, SC-8. **→ SC-2, SC-8**
  - [ ] 56.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-2, SC-8**
  - [ ] 56.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-2, SC-8]}`. **→ SC-2, SC-8**
  - [ ] 56.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-2, SC-8**

### Item 27 — SC-3 behavioral test (researcher DISPATCH_GATE)

- [ ] 57. **RED (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/1437-sc3-dispatch-gate-researcher.sh`. **→ SC-3, SC-8**
  - [ ] 57.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 57.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-3, SC-8. **→ SC-3, SC-8**
  - [ ] 57.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 57.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-3, SC-8**
  - [ ] 57.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 58. **GREEN (**sub-agent**).** Re-run test — MUST PASS. Tag: `1437/checkpoint/phase-4-item-27-opencode`. Commit: `p3-item27: behavioral test for SC-3 researcher DISPATCH_GATE`. **→ SC-3, SC-8**
  - [ ] 58.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 58.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-3, SC-8**
  - [ ] 58.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 58.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. **→ SC-3, SC-8**
  - [ ] 58.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. **→ SC-3, SC-8**
  - [ ] 58.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-3, SC-8**
  - [ ] 58.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-3, SC-8. **→ SC-3, SC-8**
  - [ ] 58.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-3, SC-8**
  - [ ] 58.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-3, SC-8]}`. **→ SC-3, SC-8**
  - [ ] 58.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-3, SC-8**

### Item 28 — SC-4 behavioral test (playwright-cli DISPATCH_GATE)

- [ ] 59. **RED (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/1437-sc4-dispatch-gate-playwright-cli.sh`. **→ SC-4, SC-8**
  - [ ] 59.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 59.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-4, SC-8. **→ SC-4, SC-8**
  - [ ] 59.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 59.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-4, SC-8**
  - [ ] 59.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 60. **GREEN (**sub-agent**).** Re-run test — MUST PASS. Tag: `1437/checkpoint/phase-4-item-28-opencode`. Commit: `p3-item28: behavioral test for SC-4 playwright-cli DISPATCH_GATE`. **→ SC-4, SC-8**
  - [ ] 60.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 60.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-4, SC-8**
  - [ ] 60.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 60.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. **→ SC-4, SC-8**
  - [ ] 60.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. **→ SC-4, SC-8**
  - [ ] 60.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-4, SC-8**
  - [ ] 60.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-4, SC-8. **→ SC-4, SC-8**
  - [ ] 60.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-4, SC-8**
  - [ ] 60.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-4, SC-8]}`. **→ SC-4, SC-8**
  - [ ] 60.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-4, SC-8**

### Item 29 — SC-5 content-verification test (all 20 skills have Persona)

- [ ] 61. **RED (**sub-agent**).** Write content-verification test at `.opencode/tests/behaviors/1437-sc5-persona-all-20.sh`. Count skills without `## Persona` — MUST be > 0 (test fails = RED). **→ SC-5**
  - [ ] 61.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 61.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 61.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 61.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**
  - [ ] 61.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 62. **GREEN (**sub-agent**).** Re-run count — MUST be 0. Tag: `1437/checkpoint/phase-4-item-29-opencode`. Commit: `p3-item29: content-verification test for SC-5 all skills have Persona`. **→ SC-5**
  - [ ] 62.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 62.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
  - [ ] 62.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 62.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. **→ SC-5**
  - [ ] 62.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. **→ SC-5**
  - [ ] 62.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
  - [ ] 62.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-5. **→ SC-5**
  - [ ] 62.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
  - [ ] 62.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-5]}`. **→ SC-5**
  - [ ] 62.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-5**

### Item 30 — SC-6 semantic test (domain-specific Persona)

- [ ] 63. **RED (**sub-agent**).** Write semantic test at `.opencode/tests/behaviors/1437-sc6-persona-domain-specific.sh`. Sub-agent reads each Persona and judges domain-specificity — test MUST FAIL (Personas don't exist yet). **→ SC-6**
  - [ ] 63.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 63.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-6. **→ SC-6**
  - [ ] 63.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 63.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-6**
  - [ ] 63.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 64. **GREEN (**sub-agent**).** Re-run test — MUST PASS. Tag: `1437/checkpoint/phase-4-item-30-opencode`. Commit: `p3-item30: semantic test for SC-6 domain-specific Persona`. **→ SC-6**
  - [ ] 64.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 64.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-6**
  - [ ] 64.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 64.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. **→ SC-6**
  - [ ] 64.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. **→ SC-6**
  - [ ] 64.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-6**
  - [ ] 64.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-6. **→ SC-6**
  - [ ] 64.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-6**
  - [ ] 64.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-6]}`. **→ SC-6**
  - [ ] 64.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-6**

### Item 31 — SC-7 string test (consequence of inlining in Persona)

- [ ] 65. **RED (**sub-agent**).** Write string test at `.opencode/tests/behaviors/1437-sc7-persona-inline-consequence.sh`. Grep each Persona for "inline" or "contaminant" or "unverified" — MUST find zero (test fails = RED). **→ SC-7**
  - [ ] 65.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 65.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-7. **→ SC-7**
  - [ ] 65.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 65.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-7**
  - [ ] 65.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 66. **GREEN (**sub-agent**).** Re-run grep — MUST find at least one match in each Persona. Tag: `1437/checkpoint/phase-4-item-31-opencode`. Commit: `p3-item31: string test for SC-7 inlining consequence in Persona`. **→ SC-7**
  - [ ] 66.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 66.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-7**
  - [ ] 66.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 66.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. **→ SC-7**
  - [ ] 66.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. **→ SC-7**
  - [ ] 66.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-7**
  - [ ] 66.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-7. **→ SC-7**
  - [ ] 66.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-7**
  - [ ] 66.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-7]}`. **→ SC-7**
  - [ ] 66.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-7**

### Item 32 — SC-8 behavioral test (at least one skill dispatches via task())

- [ ] 67. **RED (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/1437-sc8-behavioral-dispatch-vs-inline.sh`. Send prompt triggering any skill with DISPATCH_GATE. Assert via `assert_semantic` that agent dispatches via `task()` — test MUST FAIL. **→ SC-8**
  - [ ] 67.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 67.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-8. **→ SC-8**
  - [ ] 67.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 67.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-8**
  - [ ] 67.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 68. **GREEN (**sub-agent**).** Re-run test — MUST PASS. Tag: `1437/checkpoint/phase-4-item-32-opencode`. Commit: `p3-item32: behavioral test for SC-8 agent dispatches via task()`. **→ SC-8**
  - [ ] 68.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 68.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-8**
  - [ ] 68.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 68.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. **→ SC-8**
  - [ ] 68.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. **→ SC-8**
  - [ ] 68.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-8**
  - [ ] 68.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-8. **→ SC-8**
  - [ ] 68.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-8**
  - [ ] 68.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-8]}`. **→ SC-8**
  - [ ] 68.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-8**

### Item 33 — SC-9 behavioral test (spec-creation behavioral test)

- [ ] 69. **RED (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/1437-sc9-behavioral-spec-creation.sh`. Send prompt triggering spec-creation skill. Assert via `assert_semantic` that agent dispatches via `task()` — test MUST FAIL. **→ SC-9**
  - [ ] 69.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 69.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-9. **→ SC-9**
  - [ ] 69.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 69.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-9**
  - [ ] 69.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 70. **GREEN (**sub-agent**).** Re-run test — MUST PASS. Tag: `1437/checkpoint/phase-4-item-33-opencode`. Commit: `p3-item33: behavioral test for SC-9 spec-creation dispatch`. **→ SC-9**
  - [ ] 70.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 70.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-9**
  - [ ] 70.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 70.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. **→ SC-9**
  - [ ] 70.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. **→ SC-9**
  - [ ] 70.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-9**
  - [ ] 70.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-9. **→ SC-9**
  - [ ] 70.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-9**
  - [ ] 70.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-9]}`. **→ SC-9**
  - [ ] 70.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-9**

### Item 34 — SC-10 regression check (all 36+ existing DISPATCH_GATE blocks intact)

- [ ] 71. **RED (**sub-agent**).** Write content-verification test at `.opencode/tests/behaviors/1437-sc10-dispatch-gate-regression.sh`. Count skills with "DISPATCH GATE" — MUST be < 36 (test fails = RED, showing regression). **→ SC-10**
  - [ ] 71.1. **z3-check-red (**inline**).** `solve check`. SAT required.
  - [ ] 71.2. **red-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-10. **→ SC-10**
  - [ ] 71.3. **z3-check-red-doublecheck (**inline**).** `solve check`. SAT required.
  - [ ] 71.4. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-10**
  - [ ] 71.5. **z3-check-post-red (**inline**).** `solve check`. SAT required.
- [ ] 72. **GREEN (**sub-agent**).** Re-run count — MUST be ≥ 40 (36 existing + 4 new). Tag: `1437/checkpoint/phase-4-item-34-opencode`. Commit: `p3-item34: regression test for SC-10 DISPATCH_GATE count`. **→ SC-10**
  - [ ] 72.1. **z3-check-green (**inline**).** `solve check`. SAT required.
  - [ ] 72.2. **post-green-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-10**
  - [ ] 72.3. **z3-check-post-green (**inline**).** `solve check`. SAT required.
  - [ ] 72.4. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. **→ SC-10**
  - [ ] 72.5. **checkpoint-commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. **→ SC-10**
  - [ ] 72.6. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-10**
  - [ ] 72.7. **green-doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for SC-10. **→ SC-10**
  - [ ] 72.8. **green-vbc (**sub-agent**).** Dispatch `verification-before-completion --task completion`. **→ SC-10**
  - [ ] 72.9. **adversarial-audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{sc_ids: [SC-10]}`. **→ SC-10**
  - [ ] 72.10. **cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate`. **→ SC-10**

#### Phase 4 VbC

- [ ] 73. **VbC (**clean-room**).** Verify all 10 behavioral/content-verification tests exist and pass. Run `bash .opencode/tests/behaviors/ --tag 1437` — all PASS. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10**

**Concern transition:** Leaving behavioral test creation → entering global post-steps. All implementation items complete.

## Phase 5 — Global Post-Steps

- **Concern:** Collect evidence, run adversarial audit, cross-validate, regression check, review-prep, and exec-summary.
- **Files:** None (verification and reporting)
- **SCs:** All
- **Dependencies:** All phases complete
- **Entry:** All 34 items committed; all behavioral tests passing
- **Exit:** Evidence collected, audit passed, review-prep complete, exec-summary reported

- [ ] 74. **Collect behavioral evidence (**sub-agent**).** Collect all behavioral evidence artifacts from `./tmp/behavioral-evidence-*/` into `./tmp/1437/artifacts/`. **→ All SCs**
- [ ] 75. **Adversarial audit (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `{artifact_path: ./tmp/1437/artifacts/, sc_ids: [SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10]}`. **→ All SCs**
- [ ] 76. **Cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate` with `{auditor_artifact_paths: [...]}`. **→ All SCs**
- [ ] 77. **Regression check (**sub-agent**).** Dispatch `test-driven-development --task patterns` (regression). Run full behavioral test suite: `bash .opencode/tests/test-enforcement.sh --tag 1437`. **→ All SCs**
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
- C8. All behavioral tests pass via `bash .opencode/tests/test-enforcement.sh --tag 1437`
- C9. Adversarial audit passes with dual cross-family auditor consensus
- C10. Review-prep complete with correct compare URL
