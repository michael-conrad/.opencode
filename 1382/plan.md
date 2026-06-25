# Implementation Plan — [#1382](https://github.com/michael-conrad/.opencode/issues/1382) — Move plan format spec from create.md to write.md

- [ ] **Spec:** [#1382](https://github.com/michael-conrad/.opencode/issues/1382)
- [ ] **Goal:** Move the plan format specification from `create.md` (orchestrator task file) to `write.md` (sub-agent task file), so the sub-agent that produces the plan owns the format spec.
- [ ] **Architecture:** Three file modifications plus one behavioral test. The format spec moves from `create.md` §54-149 to `write.md` as new sections. `create.md` gets a reference to `write.md` instead. The input contract gets a `plan_format_reference` field. A behavioral test verifies the write sub-agent produces format-compliant output.
- [ ] **Files:**
  - `.opencode/skills/writing-plans/tasks/write.md`
  - `.opencode/skills/writing-plans/tasks/create.md`
  - `.opencode/skills/writing-plans/contracts/write-input-template.yaml`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Phase 1 — Move format spec from create.md to write.md

- [ ] **Concern:** Format specification ownership — the sub-agent that produces the plan must own the format spec.
- [ ] **Files:**
  - `.opencode/skills/writing-plans/tasks/write.md`
  - `.opencode/skills/writing-plans/tasks/create.md`
  - `.opencode/skills/writing-plans/contracts/write-input-template.yaml`
- [ ] **SCs:** SC-1, SC-2, SC-3, SC-4, SC-5
- [ ] **Dependencies:** None
- [ ] **Entry condition:** Spec #1382 approved, feature branch created
- [ ] **Exit condition:** All 4 items implemented, behavioral test passes

### Pre-Flight

- [ ] 1. **Pre-flight handoff (**clean-room**).** Execute `implementation-pipeline --task pre-flight-handoff` — validates RED checkpoints, SC-ID traceability, approval cascade state. Writes manifest at `./tmp/1382/artifacts/plan-to-pipeline-handoff-*.yaml`.
- [ ] 2. **Handoff-consistency check (**clean-room**).** Read both `spec-to-plan-handoff-*.yaml` and `plan-to-pipeline-handoff-*.yaml` manifests. Compare SC coverage total, decomposition classification, phase count. BLOCK on mismatch.

### Item 1 — Add format specification sections to write.md

- [ ] 3. **sc-coherence-gate (**clean-room**).** Run `adversarial-audit --task coherence-extraction` — verify SC-1 is coherent with codebase state. Evidence-type uplift + substrate classification.
- [ ] 4. **pre-red-baseline (**clean-room**).** Run `implementation-pipeline --task pre-red-baseline` — doc-source-currency check, SC-ID cross-ref traceability. Write solution state file at `./tmp/1382/state/state.yaml`.
- [ ] 5. **red-phase (**clean-room**).** Write a content-verification test that greps for each required section header in `write.md` — all absent. **→ SC-1**
- [ ] 6. **red-doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — confirm RED-side SC evidence. **→ SC-1**
- [ ] 7. **post-red-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/skills/writing-plans/tasks/write.md | wc -l` — verify no changes yet. **→ SC-1**
- [ ] 8. **green-phase (**clean-room**).** Add the following sections to `write.md` after the existing Procedure section:
  - Plan Format Requirements (Required Sections in order)
  - Dispatch Indicators table
  - Prohibited Patterns
  - Validation Rules
  - RED+green Item Chain Specification
  - Phase Completion Block
  - Concern Transition
  - Exit Criteria
- [ ] 9. **post-green-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/skills/writing-plans/tasks/write.md | wc -l` — verify changes made.
- [ ] 10. **checkpoint-tag-create (**clean-room**).** Create git tag per `000-critical-rules.md` §Checkpoint Rollback Exception: `opencode-config/checkpoint/1382/phase-1-item1-opencode`.
- [ ] 11. **checkpoint-commit (**inline**).** `git add .opencode/skills/writing-plans/tasks/write.md && git commit -m "Item 1: add format specification sections to write.md"`
- [ ] 12. **structural-checks (**clean-room**).** Run `finishing-a-development-branch --task checklist` — lint/typecheck/format results.
- [ ] 13. **green-doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — semantic-intent verification of SC-1. **→ SC-1**
- [ ] 14. **green-vbc (**clean-room**).** Run `verification-before-completion --task completion` — VbC completion artifact.

### Item 2 — Remove §54-149 from create.md, add reference to write.md

- [ ] 15. **sc-coherence-gate (**clean-room**).** Run `adversarial-audit --task coherence-extraction` — verify SC-2, SC-3 are coherent with codebase state.
- [ ] 16. **pre-red-baseline (**clean-room**).** Run `implementation-pipeline --task pre-red-baseline` — doc-source-currency check. Write solution state file.
- [ ] 17. **red-phase (**clean-room**).** Write a content-verification test that greps for each removed section header in `create.md` — all present. **→ SC-2, SC-3**
- [ ] 18. **red-doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — confirm RED-side SC evidence. **→ SC-2, SC-3**
- [ ] 19. **post-red-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/skills/writing-plans/tasks/create.md | wc -l` — verify no changes yet. **→ SC-2, SC-3**
- [ ] 20. **green-phase (**clean-room**).** Remove §54-149 (Plan Format, Plan Format Requirements, Dispatch Indicators, Prohibited Patterns, Validation Rules, RED+green chain spec, Phase Completion Block, Concern Transition, Exit Criteria) from `create.md`. Replace with: "The write sub-agent produces the plan per the format specification in `write.md`."
- [ ] 21. **post-green-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/skills/writing-plans/tasks/create.md | wc -l` — verify changes made.
- [ ] 22. **checkpoint-tag-create (**clean-room**).** Create git tag: `opencode-config/checkpoint/1382/phase-1-item2-opencode`.
- [ ] 23. **checkpoint-commit (**inline**).** `git add .opencode/skills/writing-plans/tasks/create.md && git commit -m "Item 2: remove format spec from create.md, add write.md reference"`
- [ ] 24. **structural-checks (**clean-room**).** Run `finishing-a-development-branch --task checklist` — lint/typecheck/format results.
- [ ] 25. **green-doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — semantic-intent verification of SC-2, SC-3. **→ SC-2, SC-3**
- [ ] 26. **green-vbc (**clean-room**).** Run `verification-before-completion --task completion` — VbC completion artifact.

### Item 3 — Add plan_format_reference field to write-input-template.yaml

- [ ] 27. **sc-coherence-gate (**clean-room**).** Run `adversarial-audit --task coherence-extraction` — verify SC-4 is coherent with codebase state.
- [ ] 28. **pre-red-baseline (**clean-room**).** Run `implementation-pipeline --task pre-red-baseline` — doc-source-currency check. Write solution state file.
- [ ] 29. **red-phase (**clean-room**).** Write a content-verification test that greps for `plan_format_reference` in `write-input-template.yaml` — absent. **→ SC-4**
- [ ] 30. **red-doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — confirm RED-side SC evidence. **→ SC-4**
- [ ] 31. **post-red-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/skills/writing-plans/contracts/write-input-template.yaml | wc -l` — verify no changes yet. **→ SC-4**
- [ ] 32. **green-phase (**clean-room**).** Add `plan_format_reference: string` field to `contracts/write-input-template.yaml` with default value `"writing-plans/tasks/write.md"`.
- [ ] 33. **post-green-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/skills/writing-plans/contracts/write-input-template.yaml | wc -l` — verify changes made.
- [ ] 34. **checkpoint-tag-create (**clean-room**).** Create git tag: `opencode-config/checkpoint/1382/phase-1-item3-opencode`.
- [ ] 35. **checkpoint-commit (**inline**).** `git add .opencode/skills/writing-plans/contracts/write-input-template.yaml && git commit -m "Item 3: add plan_format_reference field to write-input-template.yaml"`
- [ ] 36. **structural-checks (**clean-room**).** Run `finishing-a-development-branch --task checklist` — lint/typecheck/format results.
- [ ] 37. **green-doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — semantic-intent verification of SC-4. **→ SC-4**
- [ ] 38. **green-vbc (**clean-room**).** Run `verification-before-completion --task completion` — VbC completion artifact.

### Item 4 — Behavioral test: dispatch write sub-agent, verify format-compliant output

- [ ] 39. **sc-coherence-gate (**clean-room**).** Run `adversarial-audit --task coherence-extraction` — verify SC-5 is coherent with codebase state.
- [ ] 40. **pre-red-baseline (**clean-room**).** Run `implementation-pipeline --task pre-red-baseline` — doc-source-currency check. Write solution state file.
- [ ] 41. **red-phase (**clean-room**).** Write a behavioral test that dispatches a `write` sub-agent with the updated `write.md` and verifies the output plan does NOT match the established format (checklist `- [ ] N.`, dispatch indicators, SC annotations, phase metadata, admonishments). Test MUST FAIL. **→ SC-5**
- [ ] 42. **red-doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — confirm RED-side SC evidence. **→ SC-5**
- [ ] 43. **post-red-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/tests/behaviors/ | wc -l` — verify no changes yet. **→ SC-5**
- [ ] 44. **green-phase (**clean-room**).** Dispatch a `write` sub-agent for a test spec, verify output plan matches the established format (checklist `- [ ] N.`, dispatch indicators, SC annotations, phase metadata, admonishments). **→ SC-5**
- [ ] 45. **post-green-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/tests/behaviors/ | wc -l` — verify changes made.
- [ ] 46. **checkpoint-tag-create (**clean-room**).** Create git tag: `opencode-config/checkpoint/1382/phase-1-item4-opencode`.
- [ ] 47. **checkpoint-commit (**inline**).** `git add .opencode/tests/behaviors/ && git commit -m "Item 4: behavioral test for write sub-agent format compliance"`
- [ ] 48. **structural-checks (**clean-room**).** Run `finishing-a-development-branch --task checklist` — lint/typecheck/format results.
- [ ] 49. **green-doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — semantic-intent verification of SC-5. **→ SC-5**
- [ ] 50. **green-vbc (**clean-room**).** Run `verification-before-completion --task completion` — VbC completion artifact.

### Phase 1 Completion

- [ ] 51. **resolve-models (**inline**).** Run `.opencode/tools/resolve-models` to select cross-family auditors. Record `auditor_1` and `auditor_2` subagent types.
- [ ] 52. **auditor-1-dispatch (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `subagent_type` from `auditor_1`. Collect artifact path.
- [ ] 53. **auditor-1-remediate (**inline**).** If auditor_1 returned non-clean-pass (FAIL or DONE_WITH_CONCERNS): remediate root cause, re-run resolve-models (step 51), re-dispatch auditor_1 (step 52). Do NOT proceed to auditor_2 until auditor_1 returns clean PASS.
- [ ] 54. **auditor-2-dispatch (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `subagent_type` from `auditor_2`. Collect artifact path.
- [ ] 55. **auditor-2-remediate (**inline**).** If auditor_2 returned non-clean-pass: remediate root cause, re-run resolve-models (step 51), re-dispatch auditor_1 (step 52) and auditor_2 (step 54). Both must return clean PASS.
- [ ] 56. **cross-validate (**clean-room**).** Run `adversarial-audit --task cross-validate` — receive `auditor_artifact_paths` from steps 52 and 54, produce cross-validate findings YAML.
- [ ] 57. **regression-check (**clean-room**).** Run `test-driven-development --task patterns` — regression test results.
- [ ] 58. **review-prep (**clean-room**).** Run `git-workflow --task review-prep` — review-prep status.
- [ ] 59. **exec-summary (**clean-room**).** Run `completion-core --task completion` — append lifecycle event + chat exec summary.

**Concern transition:** Leaving format specification ownership → entering PR creation. Phase 1 delivers all file modifications and behavioral verification.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- [ ] C1: `write.md` contains Plan Format Requirements, Dispatch Indicators, Prohibited Patterns, Validation Rules, RED+green chain spec, Phase Completion Block, Concern Transition, and Exit Criteria sections
- [ ] C2: `create.md` no longer contains Plan Format Requirements, Dispatch Indicators, Prohibited Patterns, Validation Rules, RED+green chain spec, Phase Completion Block, Concern Transition, or Exit Criteria sections
- [ ] C3: `create.md` contains a reference to `write.md` for the format specification
- [ ] C4: `contracts/write-input-template.yaml` contains `plan_format_reference` field
- [ ] C5: Behavioral test passes — write sub-agent produces format-compliant plan output
