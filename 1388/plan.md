# Implementation Plan — [#1388](https://github.com/michael-conrad/.opencode/issues/1388) — Fix C2: Remaining skill descriptions — mandatory language + narrative cleanup

**Spec:** [#1388](https://github.com/michael-conrad/.opencode/issues/1388) — Fix C2: Remaining skill descriptions — mandatory language + narrative cleanup (D4, D5)

**Goal:** Update all 28 skill descriptions to include mandatory language (MUST, REQUIRED, always, not optional, mandatory) and replace narrative-only sentences with dispatch-relevant content, while preserving consequence statements and maintaining D2/D3 correctness against each skill's Trigger Dispatch Table.

**Architecture:** Single-issue plan with 3 phases (10 skills per batch). Each phase follows the same RED→GREEN→doublecheck→checkpoint pattern. Post-steps for global verification, adversarial audit, cross-validate, regression check, and review-prep.

**Files:** `.opencode/skills/{changelog-generator,completeness-gate,completion-core,conflict-resolution,correspondence,engineering-approach,git-workflow,issue-operations,issue-review,mcp-tool-usage,multimodal-dispatch,plan,plan-creation-pipeline,pr-creation-workflow,pre-analysis,programming-principles,receiving-code-review,requesting-code-review,research,researcher,skill-creator,solve,spec-creation,sre-runbook,sync-guidelines,systematic-debugging,test-driven-development,using-git-worktrees,verification,writing-plans}/SKILL.md`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

---

## Phase 0 — Setup + Branch + Scaffolding

**Concern:** Establish feature branch, verify git state, run coherence gate, and prepare scaffolding.

**Files:** (none modified — git operations only)

**SCs:** (none — setup only)

**Dependencies:** None

**Entry:** Plan approved, authorization scope >= `for_implementation`

**Exit:** Feature branch created, coherence gate PASS, pre-red-baseline recorded

- [ ] 1. **Pre-work (**clean-room**).** Create feature branch `spec-fix/1388-skill-descriptions`, sync dev, verify git state. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 2. **Coherence gate (**clean-room**).** Verify plan coherence against spec #1388: confirm all 30 SKILL.md files exist under `.opencode/skills/*/SKILL.md`, confirm each has a `description:` field in YAML frontmatter, confirm research evidence at `tmp/research-evidence-1388.md` is accessible. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 3. **Pre-red-baseline (**clean-room**).** Record current state: for each of the 30 skills, capture the current `description:` value. Write baseline to `./tmp/1388-baseline-descriptions.json`. **→ SC-1, SC-2**

#### Phase 0 VbC

- [ ] 4. **VbC (**clean-room**).** Verify: branch exists on correct base, coherence gate PASS recorded, baseline file written with 30 entries. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving setup → entering description edits. Phase 1 depends on Phase 0 branch and baseline.

---

## Phase 1 — Skills 1-10: changelog-generator through mcp-tool-usage

**Concern:** Update descriptions for changelog-generator, completeness-gate, completion-core, conflict-resolution, correspondence, engineering-approach, git-workflow, issue-operations, issue-review, mcp-tool-usage

**Files:** `.opencode/skills/{changelog-generator,completeness-gate,completion-core,conflict-resolution,correspondence,engineering-approach,git-workflow,issue-operations,issue-review,mcp-tool-usage}/SKILL.md`

**SCs:** SC-1, SC-2, SC-3, SC-4

**Dependencies:** Phase 0 complete (branch + baseline)

**Entry:** Phase 0 VbC PASS

**Exit:** All 10 descriptions edited, RED tests confirmed FAIL before each GREEN, GREEN tests confirmed PASS after each GREEN, checkpoint commits created

- [ ] 5. **RED — Skills 1-10 (**sub-agent**).** Write grep-based RED test: for each of skills 1-10, assert `description:` field does NOT contain mandatory language (MUST/REQUIRED/always/not optional/mandatory). Run test, confirm FAIL. **→ SC-1**
- [ ] 6. **Z3 check RED (**inline**).** Verify RED test artifact exists and shows FAIL status. **→ SC-1**
- [ ] 7. **RED doublecheck (**clean-room**).** Read RED test output, confirm all 10 assertions failed as expected. **→ SC-1**
- [ ] 8. **Z3 check RED doublecheck (**inline**).** Verify doublecheck artifact confirms RED. **→ SC-1**
- [ ] 9. **Post-RED enforcement (**inline**).** Confirm no GREEN work started before RED confirmed. **→ SC-1**
- [ ] 10. **GREEN — Skills 1-10 (**sub-agent**).** Edit each of the 10 SKILL.md files: replace narrative-only sentence with mandatory language. For each skill, read the dispatch table from the SKILL.md, ensure new description covers all dispatch conditions (D3) and is correct (D2). **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 11. **Z3 check GREEN (**inline**).** Verify GREEN edits applied to all 10 files. **→ SC-1**
- [ ] 12. **Post-GREEN enforcement (**inline**).** Run grep test from step 5 again — confirm PASS (mandatory language now present). **→ SC-1**
- [ ] 13. **Z3 check post-GREEN (**inline**).** Verify post-GREEN enforcement shows PASS. **→ SC-1**
- [ ] 14. **Structural checks (**clean-room**).** Run `uvx pymarkdownlnt scan -r .opencode/skills/` on modified SKILL.md files. **→ SC-1, SC-2**
- [ ] 15. **GREEN doublecheck (**clean-room**).** Read all 10 edited descriptions, confirm: (a) mandatory language present, (b) no narrative-only sentences, (c) dispatch conditions still covered. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 16. **Checkpoint commit (**inline**).** `git add .opencode/skills/{changelog-generator,completeness-gate,completion-core,conflict-resolution,correspondence,engineering-approach,git-workflow,issue-operations,issue-review,mcp-tool-usage}/SKILL.md && git commit -m "Phase 1 batch 1: mandatory language for skills 1-10"`. Create checkpoint tag `opencode-config/checkpoint/1388/phase-1-batch-1-opencode`. **→ SC-1, SC-2**

#### Phase 1 VbC

- [ ] 17. **VbC (**clean-room**).** Verify: all 10 descriptions edited, RED tests confirmed FAIL before GREEN, GREEN tests confirmed PASS after, checkpoint commit created. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving skills 1-10 → entering skills 11-20. Phase 2 depends on Phase 1 VbC PASS.

---

## Phase 2 — Skills 11-20: multimodal-dispatch through researcher

**Concern:** Update descriptions for multimodal-dispatch, plan, plan-creation-pipeline, pr-creation-workflow, pre-analysis, programming-principles, receiving-code-review, requesting-code-review, research, researcher

**Files:** `.opencode/skills/{multimodal-dispatch,plan,plan-creation-pipeline,pr-creation-workflow,pre-analysis,programming-principles,receiving-code-review,requesting-code-review,research,researcher}/SKILL.md`

**SCs:** SC-1, SC-2, SC-3, SC-4

**Dependencies:** Phase 1 VbC PASS

**Entry:** Phase 1 VbC PASS confirmed

**Exit:** All 10 descriptions edited, RED tests confirmed FAIL before each GREEN, GREEN tests confirmed PASS after each GREEN, checkpoint commits created

- [ ] 18. **RED — Skills 11-20 (**sub-agent**).** Write grep-based RED test: for skills 11-20, assert `description:` field does NOT contain mandatory language. Note: pr-creation-workflow already has "must" — RED test for it will PASS (already has mandatory language). Confirm FAIL for the other 9. **→ SC-1**
- [ ] 19. **Z3 check RED (**inline**).** Verify RED test artifact exists. **→ SC-1**
- [ ] 20. **RED doublecheck (**clean-room**).** Read RED test output, confirm 9 of 10 failed as expected (pr-creation-workflow is expected PASS). **→ SC-1**
- [ ] 21. **Z3 check RED doublecheck (**inline**).** Verify doublecheck artifact. **→ SC-1**
- [ ] 22. **Post-RED enforcement (**inline**).** Confirm no GREEN work started. **→ SC-1**
- [ ] 23. **GREEN — Skills 11-20 (**sub-agent**).** Edit 10 SKILL.md files: for 9 skills (multimodal-dispatch, plan, plan-creation-pipeline, pre-analysis, programming-principles, receiving-code-review, requesting-code-review, research, researcher), replace narrative sentence with mandatory language. For pr-creation-workflow, remove narrative sentence only (mandatory language already present). Verify D2/D3 against each dispatch table. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 24. **Z3 check GREEN (**inline**).** Verify edits applied to all 10 files. **→ SC-1**
- [ ] 25. **Post-GREEN enforcement (**inline**).** Run grep test from step 18 — confirm 10 of 10 PASS (pr-creation-workflow was already PASS, 9 others now PASS). **→ SC-1**
- [ ] 26. **Z3 check post-GREEN (**inline**).** Verify post-GREEN enforcement. **→ SC-1**
- [ ] 27. **Structural checks (**clean-room**).** Run markdown lint on modified files. **→ SC-1, SC-2**
- [ ] 28. **GREEN doublecheck (**clean-room**).** Read all 10 edited descriptions, confirm mandatory language, no narrative sentences, dispatch coverage intact. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 29. **Checkpoint commit (**inline**).** `git add .opencode/skills/{multimodal-dispatch,plan,plan-creation-pipeline,pr-creation-workflow,pre-analysis,programming-principles,receiving-code-review,requesting-code-review,research,researcher}/SKILL.md && git commit -m "Phase 2 batch 2: mandatory language for skills 11-20"`. Create checkpoint tag `opencode-config/checkpoint/1388/phase-2-batch-2-opencode`. **→ SC-1, SC-2**

#### Phase 2 VbC

- [ ] 30. **VbC (**clean-room**).** Verify: all 10 descriptions edited, RED tests confirmed FAIL before GREEN, GREEN tests confirmed PASS after, checkpoint commit created. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving skills 11-20 → entering skills 21-30. Phase 3 depends on Phase 2 VbC PASS.

---

## Phase 3 — Skills 21-30: skill-creator through writing-plans

**Concern:** Update descriptions for skill-creator, solve, spec-creation, sre-runbook, sync-guidelines, systematic-debugging, test-driven-development, using-git-worktrees, verification, writing-plans

**Files:** `.opencode/skills/{skill-creator,solve,spec-creation,sre-runbook,sync-guidelines,systematic-debugging,test-driven-development,using-git-worktrees,verification,writing-plans}/SKILL.md`

**SCs:** SC-1, SC-2, SC-3, SC-4

**Dependencies:** Phase 2 VbC PASS

**Entry:** Phase 2 VbC PASS confirmed

**Exit:** All 10 descriptions edited, RED tests confirmed FAIL before each GREEN, GREEN tests confirmed PASS after each GREEN, checkpoint commits created

- [ ] 31. **RED — Skills 21-30 (**sub-agent**).** Write grep-based RED test: for skills 21-30, assert `description:` does NOT contain mandatory language. Note: using-git-worktrees already has "Always" — RED test for it will PASS. Confirm FAIL for the other 9. **→ SC-1**
- [ ] 32. **Z3 check RED (**inline**).** Verify RED test artifact. **→ SC-1**
- [ ] 33. **RED doublecheck (**clean-room**).** Read RED test output, confirm 9 of 10 failed as expected. **→ SC-1**
- [ ] 34. **Z3 check RED doublecheck (**inline**).** Verify doublecheck artifact. **→ SC-1**
- [ ] 35. **Post-RED enforcement (**inline**).** Confirm no GREEN work started. **→ SC-1**
- [ ] 36. **GREEN — Skills 21-30 (**sub-agent**).** Edit 10 SKILL.md files: for 9 skills (skill-creator, solve, spec-creation, sre-runbook, sync-guidelines, systematic-debugging, test-driven-development, verification, writing-plans), replace narrative sentence with mandatory language. For using-git-worktrees, remove narrative sentence only. Verify D2/D3 against each dispatch table. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 37. **Z3 check GREEN (**inline**).** Verify edits applied to all 10 files. **→ SC-1**
- [ ] 38. **Post-GREEN enforcement (**inline**).** Run grep test from step 31 — confirm 10 of 10 PASS. **→ SC-1**
- [ ] 39. **Z3 check post-GREEN (**inline**).** Verify post-GREEN enforcement. **→ SC-1**
- [ ] 40. **Structural checks (**clean-room**).** Run markdown lint on modified files. **→ SC-1, SC-2**
- [ ] 41. **GREEN doublecheck (**clean-room**).** Read all 10 edited descriptions, confirm mandatory language, no narrative sentences, dispatch coverage intact. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 42. **Checkpoint commit (**inline**).** `git add .opencode/skills/{skill-creator,solve,spec-creation,sre-runbook,sync-guidelines,systematic-debugging,test-driven-development,using-git-worktrees,verification,writing-plans}/SKILL.md && git commit -m "Phase 3 batch 3: mandatory language for skills 21-30"`. Create checkpoint tag `opencode-config/checkpoint/1388/phase-3-batch-3-opencode`. **→ SC-1, SC-2**

#### Phase 3 VbC

- [ ] 43. **VbC (**clean-room**).** Verify: all 10 descriptions edited, RED tests confirmed FAIL before GREEN, GREEN tests confirmed PASS after, checkpoint commit created. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving description edits → entering global verification. Post-steps depend on all 3 phases completing.

---

## Post-Steps — Global Verification + Audit + Review

**Concern:** Run all 4 SC verifications, adversarial audit, cross-validate, regression check, review-prep.

**Files:** All 30 edited SKILL.md files

**SCs:** SC-1, SC-2, SC-3, SC-4

**Dependencies:** Phase 3 VbC PASS

**Entry:** Phase 3 VbC PASS confirmed

**Exit:** All 4 SCs verified, evidence artifacts collected, adversarial audit PASS, cross-validate PASS, regression check PASS, review-prep complete

- [ ] 44. **SC-1 verification — mandatory language (**clean-room**).** Run grep across all 30 descriptions: assert each of the 28 target descriptions contains at least one of MUST/REQUIRED/always/not optional/mandatory. Collect PASS/FAIL per skill. Write evidence to `./tmp/behavioral-evidence-1388-SC-1.json`. **→ SC-1**
- [ ] 45. **SC-2 verification — no narrative sentences (**clean-room**).** Read all 30 descriptions. For each, classify every sentence as "dispatch-relevant" or "narrative-only". Assert zero narrative-only sentences across the 28 target descriptions. Write evidence to `./tmp/behavioral-evidence-1388-SC-2.json`. **→ SC-2**
- [ ] 46. **SC-3 verification — D2 correctness (**clean-room**).** For each of the 28 skills, read the SKILL.md dispatch table and compare against the new description. Assert description correctly reflects dispatch conditions (no false claims, no contradictions). Write evidence to `./tmp/behavioral-evidence-1388-SC-3.json`. **→ SC-3**
- [ ] 47. **SC-4 verification — D3 completeness (**clean-room**).** For each of the 28 skills, read the SKILL.md dispatch table and compare against the new description. Assert all dispatch conditions are covered by the description. Write evidence to `./tmp/behavioral-evidence-1388-SC-4.json`. **→ SC-4**
- [ ] 48. **Collect behavioral evidence (**inline**).** Copy all evidence files from `./tmp/behavioral-evidence-1388-*.json` to `./tmp/1388/artifacts/`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 49. **Adversarial audit — spec-audit (**clean-room**).** Dispatch adversarial auditor to audit the 28 edited descriptions against spec #1388. Auditor receives only the spec SCs and the edited descriptions — no orchestrator reasoning. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 50. **Cross-validate (**clean-room**).** Cross-validate auditor findings against evidence artifacts. Confirm no EVIDENCE_TYPE_MISMATCH. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 51. **Regression check (**clean-room**).** Verify no unintended changes: `git diff --stat` should show only the 30 SKILL.md files. No other files modified. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 52. **Review-prep (**clean-room**).** Prepare PR body with Summary, Outcome, Fixes #1388. Generate compare URL from session-init values. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 53. **Executive summary (**inline**).** Report: 30 descriptions edited, 28 with mandatory language added, 2 with narrative-only removal only, all 4 SCs verified. **→ SC-1, SC-2, SC-3, SC-4**

#### Post-Steps VbC

- [ ] 54. **VbC (**clean-room**).** Verify: all 4 SC evidence artifacts exist, adversarial audit PASS, cross-validate PASS, regression check clean, review-prep complete. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving verification → plan complete.

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

- **C1.** Feature branch `spec-fix/1388-skill-descriptions` exists on correct base
- **C2.** All 30 SKILL.md descriptions edited — 28 with mandatory language added, 2 with narrative-only removal only
- **C3.** SC-1 PASS: all 28 target descriptions contain mandatory language (verified by grep)
- **C4.** SC-2 PASS: all 28 target descriptions have no narrative-only sentences (verified by semantic inspection)
- **C5.** SC-3 PASS: all 28 descriptions pass D2 correctness against dispatch table (verified by semantic inspection)
- **C6.** SC-4 PASS: all 28 descriptions pass D3 completeness against dispatch table (verified by semantic inspection)
- **C7.** Behavioral evidence artifacts collected at `./tmp/1388/artifacts/`
- **C8.** Adversarial audit PASS with no EVIDENCE_TYPE_MISMATCH
- **C9.** Cross-validate PASS
- **C10.** Regression check: only the 30 SKILL.md files modified
- **C11.** Review-prep complete with PR body and compare URL
