# Implementation Plan — [#1379](https://github.com/michael-conrad/.opencode/issues/1379) — Replace adversarial-audit prose exception with individual dispatch rows

**Goal:** Replace the single `adversarial-audit`/`orchestrator` row in the Trigger Dispatch Table, Dispatch Routing Table, and pipeline-executor.md dispatch table with 6 individual rows (resolve-models inline, auditor-1-dispatch sub-agent, auditor-1-remediate inline, auditor-2-dispatch sub-agent, auditor-2-remediate inline, cross-validate clean-room). Remove all prose exception blocks that duplicate the table.

**Architecture:** Single phase — all 6 changes are structural edits to 2 files. No behavioral tests, no RED/GREEN cycle. All SCs are structural (grep-verifiable).

**Files:**
- `.opencode/skills/implementation-pipeline/SKILL.md` — Trigger Dispatch Table, Dispatch Routing Table, Invocation section, Sub-Agent Routing section
- `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` — Dispatch table

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Phase 1 — Replace adversarial-audit prose exception with individual dispatch rows

**Concern:** Eliminate all prose exceptions for adversarial-audit sequence; replace with individual enumerated dispatch rows in both tables

**Files:** `.opencode/skills/implementation-pipeline/SKILL.md`, `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8

**Dependencies:** None

**Entry condition:** Feature branch exists, spec approved

**Exit condition:** Both files modified, all 8 SCs verified PASS

### Pre-Flight

- [ ] 1. **Pre-flight handoff (**clean-room**).** Execute `implementation-pipeline --task pre-flight-handoff` — validates RED checkpoints, SC-ID traceability, approval cascade state. Writes manifest at `./tmp/1379/artifacts/plan-to-pipeline-handoff-*.yaml`.
- [ ] 2. **Handoff-consistency check (**clean-room**).** Read both `spec-to-plan-handoff-*.yaml` and `plan-to-pipeline-handoff-*.yaml` manifests. Compare SC coverage total, decomposition classification, phase count. BLOCK on mismatch.

### Structural Edits — SKILL.md

- [ ] 3. **sc-coherence-gate (**clean-room**).** Run `adversarial-audit --task coherence-extraction` — verify the spec's SCs are coherent with the codebase state. Evidence-type uplift + substrate classification.
- [ ] 4. **pre-red-baseline (**clean-room**).** Run `implementation-pipeline --task pre-red-baseline` — doc-source-currency check, SC-ID cross-ref traceability. Write solution state file at `./tmp/1379/state/state.yaml`.
- [ ] 5. **RED (**clean-room**).** Verify `## Trigger Dispatch Table` in SKILL.md contains `adversarial-audit.*orchestrator` — `grep` returns match. **→ SC-1**
- [ ] 6. **red-doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — confirm RED-side SC evidence. **→ SC-1**
- [ ] 7. **post-red-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/skills/implementation-pipeline/SKILL.md | wc -l` — verify no changes yet. **→ SC-1**
- [ ] 8. **GREEN — Trigger Dispatch Table (**clean-room**).** Replace the single `adversarial-audit`/`orchestrator` row in `## Trigger Dispatch Table` with 6 individual rows: `resolve-models` (inline), `auditor-1-dispatch` (sub-agent), `auditor-1-remediate` (inline), `auditor-2-dispatch` (sub-agent), `auditor-2-remediate` (inline), `cross-validate` (clean-room). **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 9. **GREEN — Dispatch Routing Table (**clean-room**).** Replace the prose multi-dispatch cell in `## Dispatch Routing Table` with 6 individual rows matching the trigger dispatch table. Each row has a single dispatch target and a single artifact produced. **→ SC-5**
- [ ] 10. **GREEN — Remove prose notes block (**clean-room**).** Remove the `**Note:**` block immediately after the Dispatch Routing Table that describes the multi-dispatch sequence as a numbered checklist. **→ SC-5 (reinforced)**
- [ ] 11. **GREEN — Remove Invocation exception block (**clean-room**).** Remove the `**Exception — adversarial-audit sequence:**` block in the `## Invocation` section. **→ SC-6**
- [ ] 12. **GREEN — Remove Sub-Agent Routing exception (**clean-room**).** Remove the `**Exception — adversarial-audit sequence:**` paragraph in the `## Sub-Agent Routing` section. **→ SC-7**
- [ ] 13. **post-green-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/skills/implementation-pipeline/SKILL.md | wc -l` — verify changes made.
- [ ] 14. **checkpoint-tag-create (**clean-room**).** Create git tag per `000-critical-rules.md` §Checkpoint Rollback Exception: `opencode-config/checkpoint/1379/phase-1-skill-opencode`.
- [ ] 15. **checkpoint-commit (**inline**).** `git add .opencode/skills/implementation-pipeline/SKILL.md && git commit -m "fix: replace adversarial-audit prose exception with individual dispatch rows in SKILL.md"`
- [ ] 16. **structural-checks (**clean-room**).** Run `finishing-a-development-branch --task checklist` — lint/typecheck/format results.
- [ ] 17. **GREEN doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — semantic-intent verification of SC-1 through SC-7. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7**
- [ ] 18. **green-vbc (**clean-room**).** Run `verification-before-completion --task completion` — VbC completion artifact.

### Structural Edits — pipeline-executor.md

- [ ] 19. **sc-coherence-gate (**clean-room**).** Run `adversarial-audit --task coherence-extraction` — verify SC-8 is coherent with pipeline-executor.md state.
- [ ] 20. **pre-red-baseline (**clean-room**).** Run `implementation-pipeline --task pre-red-baseline` — doc-source-currency check. Write solution state file.
- [ ] 21. **RED (**clean-room**).** Verify `## Dispatch Table` in pipeline-executor.md contains `adversarial-audit` as a single row — `grep` returns match. **→ SC-8**
- [ ] 22. **red-doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — confirm RED-side SC evidence. **→ SC-8**
- [ ] 23. **post-red-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md | wc -l` — verify no changes yet. **→ SC-8**
- [ ] 24. **GREEN — pipeline-executor dispatch table (**clean-room**).** Replace the single `adversarial-audit` row (step 13) in `## Dispatch Table` with 6 individual rows: step 13 resolve-models (inline), step 14 auditor-1-dispatch (sub-agent), step 15 auditor-1-remediate (inline), step 16 auditor-2-dispatch (sub-agent), step 17 auditor-2-remediate (inline), step 18 cross-validate (clean-room). Renumber existing steps 14-17 to 19-22. **→ SC-8**
- [ ] 25. **post-green-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md | wc -l` — verify changes made.
- [ ] 26. **checkpoint-tag-create (**clean-room**).** Create git tag: `opencode-config/checkpoint/1379/phase-1-executor-opencode`.
- [ ] 27. **checkpoint-commit (**inline**).** `git add .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md && git commit -m "fix: replace adversarial-audit single row with individual dispatch rows in pipeline-executor.md"`
- [ ] 28. **structural-checks (**clean-room**).** Run `finishing-a-development-branch --task checklist` — lint/typecheck/format results.
- [ ] 29. **GREEN doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — semantic-intent verification of SC-8. **→ SC-8**
- [ ] 30. **green-vbc (**clean-room**).** Run `verification-before-completion --task completion` — VbC completion artifact.

### Phase 1 Completion

- [ ] 31. **resolve-models (**inline**).** Run `.opencode/tools/resolve-models` to select cross-family auditors. Record `auditor_1` and `auditor_2` subagent types.
- [ ] 32. **auditor-1 dispatch (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `subagent_type` from `auditor_1`. Collect artifact path.
- [ ] 33. **auditor-1 remediate (**inline**).** If auditor_1 returned non-clean-pass (FAIL or DONE_WITH_CONCERNS): remediate root cause, re-run resolve-models (step 31), re-dispatch auditor_1 (step 32). Do NOT proceed to auditor_2 until auditor_1 returns clean PASS.
- [ ] 34. **auditor-2 dispatch (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `subagent_type` from `auditor_2`. Collect artifact path.
- [ ] 35. **auditor-2 remediate (**inline**).** If auditor_2 returned non-clean-pass: remediate root cause, re-run resolve-models (step 31), re-dispatch auditor_1 (step 32) and auditor_2 (step 34). Both must return clean PASS.
- [ ] 36. **cross-validate (**clean-room**).** Run `adversarial-audit --task cross-validate` — receive `auditor_artifact_paths` from steps 32 and 34, produce cross-validate findings YAML.
- [ ] 37. **regression-check (**clean-room**).** Run `test-driven-development --task patterns` — regression test results.
- [ ] 38. **review-prep (**clean-room**).** Run `git-workflow --task review-prep` — review-prep status.
- [ ] 39. **exec-summary (**clean-room**).** Run `completion-core --task completion` — append lifecycle event + chat exec summary.

**Concern transition:** N/A — single phase. All changes are structural edits to 2 files.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- SC-1: Trigger Dispatch Table has no `adversarial-audit` row with `orchestrator` dispatch
- SC-2: Trigger Dispatch Table has `resolve-models` row with `inline` dispatch
- SC-3: Trigger Dispatch Table has `auditor-1-dispatch` and `auditor-2-dispatch` rows with `sub-agent` dispatch
- SC-4: Trigger Dispatch Table has `cross-validate` row with `clean-room` dispatch
- SC-5: Dispatch Routing Table has no prose multi-dispatch cell for adversarial-audit
- SC-6: Invocation section has no prose exception block for adversarial-audit
- SC-7: Sub-Agent Routing section has no duplicate prose exception for adversarial-audit
- SC-8: `pipeline-executor.md` dispatch table has no single `adversarial-audit` row (only individual step rows present)
