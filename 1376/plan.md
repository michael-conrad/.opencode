# Implementation Plan — [#1376](https://github.com/michael-conrad/.opencode/issues/1376) — implementation-pipeline SKILL.md orchestrator entry point

**Goal:** Fix implementation-pipeline SKILL.md to provide an orchestrator-facing entry point, create the missing `assemble-work.md` task file, and fix `pipeline-executor.md` purpose statement.

**Architecture:** Three concerns. Concern B (create `assemble-work.md`) and Concern C (fix `pipeline-executor.md`) execute in parallel. Concern A (rewrite SKILL.md) executes last — it references both B and C by name.

**Files:**
- `.opencode/skills/implementation-pipeline/SKILL.md`
- `.opencode/skills/implementation-pipeline/tasks/assemble-work.md` (new)
- `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Phase 1 — Create `tasks/assemble-work.md` and fix `tasks/pipeline-executor.md`

**Concern:** B (assemble-work.md creation) + C (pipeline-executor.md fix) — parallel, independent

**Files:** `.opencode/skills/implementation-pipeline/tasks/assemble-work.md`, `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md`

**SCs:** SC-4, SC-5, SC-6, SC-7, SC-11, SC-12, SC-13, SC-14, SC-15

**Dependencies:** None

**Entry condition:** Feature branch exists, spec approved

**Exit condition:** Both files modified, all 9 SCs verified PASS

### Pre-Flight

- [ ] 1. **Pre-flight handoff (**clean-room**).** Execute `implementation-pipeline --task pre-flight-handoff` — validates RED checkpoints, SC-ID traceability, approval cascade state, verification gate preservation. Writes manifest at `./tmp/1376/artifacts/plan-to-pipeline-handoff-*.yaml`.
- [ ] 2. **Handoff-consistency check (**clean-room**).** Read both `spec-to-plan-handoff-*.yaml` and `plan-to-pipeline-handoff-*.yaml` manifests. Compare SC coverage total, decomposition classification, phase count. BLOCK on mismatch.

### Concern B — Create `tasks/assemble-work.md`

- [ ] 3. **sc-coherence-gate (**clean-room**).** Run `adversarial-audit --task coherence-extraction` — verify the spec's SCs are coherent with the codebase state. Evidence-type uplift + substrate classification.
- [ ] 4. **pre-red-baseline (**clean-room**).** Run `implementation-pipeline --task pre-red-baseline` — doc-source-currency check, SC-ID cross-ref traceability. Write solution state file at `./tmp/1376/state/state.yaml`.
- [ ] 5. **RED (**clean-room**).** Verify `tasks/assemble-work.md` does not exist — `ls` returns non-zero. **→ SC-4**
- [ ] 6. **red-doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — confirm RED-side SC evidence. **→ SC-4**
- [ ] 7. **post-red-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/skills/implementation-pipeline/tasks/ | wc -l` — verify no files modified yet. **→ SC-4**
- [ ] 8. **GREEN (**clean-room**).** Create `tasks/assemble-work.md` with: purpose (orchestrator entry point after plan approval), plan reading from `.issues/{N}/plan.md` **→ SC-5**, work state file reading, pre-flight verification, feature branch/worktree creation, Step 1.5 entry proof marker **→ SC-11**, sub-agent dispatch, post-sub-agent completion checkpoint with hash mismatch detection **→ SC-14**, work state verification **→ SC-13**, OVERFLOW handling **→ SC-12**, squash-merge, verification gates, routing to `pipeline-executor` **→ SC-6**, result contract return. **→ SC-4, SC-5, SC-6, SC-11, SC-12, SC-13, SC-14**
- [ ] 9. **post-green-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/skills/implementation-pipeline/tasks/ | wc -l` — verify file was created. **→ SC-4**
- [ ] 10. **checkpoint-tag-create (**clean-room**).** Create git tag per `000-critical-rules.md` §Checkpoint Rollback Exception: `opencode-config/checkpoint/1376/phase-1-assemble-work-opencode`.
- [ ] 11. **checkpoint-commit (**inline**).** `git add .opencode/skills/implementation-pipeline/tasks/assemble-work.md && git commit -m "feat: create tasks/assemble-work.md entry point"`
- [ ] 12. **structural-checks (**clean-room**).** Run `finishing-a-development-branch --task checklist` — lint/typecheck/format results.
- [ ] 13. **GREEN doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — semantic-intent verification of all 7 SCs: SC-4 (file exists), SC-5 (plan.md reference), SC-6 (pipeline-executor reference), SC-11 (Step 1.5/entry proof), SC-12 (OVERFLOW), SC-13 (work state), SC-14 (completion checkpoint/hash mismatch).
- [ ] 14. **green-vbc (**clean-room**).** Run `verification-before-completion --task completion` — VbC completion artifact.

### Concern C — Fix `tasks/pipeline-executor.md`

- [ ] 15. **sc-coherence-gate (**clean-room**).** Run `adversarial-audit --task coherence-extraction` — verify the spec's SCs for pipeline-executor are coherent.
- [ ] 16. **pre-red-baseline (**clean-room**).** Run `implementation-pipeline --task pre-red-baseline` — doc-source-currency check. Write solution state file.
- [ ] 17. **RED (**clean-room**).** Verify `pipeline-executor.md` contains step count pattern — `grep` for `[0-9]+-step` returns match. **→ SC-7**
- [ ] 18. **red-doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — confirm RED-side SC evidence. **→ SC-7**
- [ ] 19. **post-red-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md | wc -l` — verify no changes yet. **→ SC-7**
- [ ] 20. **GREEN (**clean-room**).** Remove step count from Purpose section. Ensure purpose describes itself as internal step dispatch table, not orchestrator entry point. **→ SC-7, SC-15**
- [ ] 21. **post-green-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md | wc -l` — verify changes made.
- [ ] 22. **checkpoint-tag-create (**clean-room**).** Create git tag: `opencode-config/checkpoint/1376/phase-1-pipeline-executor-opencode`.
- [ ] 23. **checkpoint-commit (**inline**).** `git add .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md && git commit -m "fix: remove stale step count and fix purpose in pipeline-executor.md"`
- [ ] 24. **structural-checks (**clean-room**).** Run `finishing-a-development-branch --task checklist` — lint/typecheck/format results.
- [ ] 25. **GREEN doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — semantic-intent verification of SC-7 (no `[0-9]+-step` pattern) and SC-15 (no "orchestrator entry" or "entry point" in purpose).
- [ ] 26. **green-vbc (**clean-room**).** Run `verification-before-completion --task completion` — VbC completion artifact.

### Phase 1 Completion

- [ ] 27. **adversarial-audit (**orchestrator**).** Multi-dispatch: resolve-models → dispatch verification-audit with auditor_1 (remediate on FAIL) → same with auditor_2 → collect artifact paths.
- [ ] 28. **cross-validate (**clean-room**).** Run `adversarial-audit --task cross-validate` — receive `auditor_artifact_paths` from step 27, produce cross-validate findings YAML.
- [ ] 29. **regression-check (**clean-room**).** Run `test-driven-development --task patterns` — regression test results.
- [ ] 30. **review-prep (**clean-room**).** Run `git-workflow --task review-prep` — review-prep status.
- [ ] 31. **exec-summary (**clean-room**).** Run `completion-core --task completion` — append lifecycle event + chat exec summary.

**Concern transition:** Leaving Concern B+C (assemble-work + pipeline-executor) → entering Concern A (SKILL.md rewrite). Phase 2 depends on Phase 1 — SKILL.md references `assemble-work` by name.

## Phase 2 — Rewrite SKILL.md

**Concern:** A (SKILL.md rewrite) — depends on Phase 1 (references `assemble-work.md` by name)

**Files:** `.opencode/skills/implementation-pipeline/SKILL.md`

**SCs:** SC-1, SC-2, SC-3, SC-8, SC-9, SC-10

**Dependencies:** Phase 1 complete

**Entry condition:** `tasks/assemble-work.md` exists

**Exit condition:** SKILL.md rewritten, all 6 SCs verified PASS

### Pre-Flight

- [ ] 32. **Pre-flight handoff (**clean-room**).** Execute `implementation-pipeline --task pre-flight-handoff` — validates RED checkpoints, SC-ID traceability, approval cascade state.
- [ ] 33. **Handoff-consistency check (**clean-room**).** Read manifests, compare SC coverage total, decomposition classification, phase count. BLOCK on mismatch.

### Concern A — Rewrite SKILL.md

- [ ] 34. **sc-coherence-gate (**clean-room**).** Run `adversarial-audit --task coherence-extraction` — verify SKILL.md SCs are coherent.
- [ ] 35. **pre-red-baseline (**clean-room**).** Run `implementation-pipeline --task pre-red-baseline` — doc-source-currency check. Write solution state file.
- [ ] 36. **RED (**clean-room**).** Verify description contains "17 serial dispatch steps" — `grep` returns match. **→ SC-1**
- [ ] 37. **red-doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — confirm RED-side SC evidence. **→ SC-1**
- [ ] 38. **post-red-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/skills/implementation-pipeline/SKILL.md | wc -l` — verify no changes yet. **→ SC-1**
- [ ] 39. **GREEN — description (**clean-room**).** Remove "17 serial dispatch steps", "Z3-verified", "YAML contract". Add orchestrator-facing trigger description with mandatory signal ("MUST dispatch here"). **→ SC-1, SC-2**
- [ ] 40. **GREEN — Overview (**clean-room**).** Remove step count, Z3, YAML contract details. Replace with orchestrator-facing purpose statement. **→ SC-8**
- [ ] 41. **GREEN — Trigger Dispatch Table (**clean-room**).** Add row: `"execute plan" / "implement spec" / "run pipeline" / "assemble work"` → `assemble-work` with dispatch `orchestrator` and context `{issue_number, plan_path, authorization_scope, halt_at, pr_strategy}`. **→ SC-3**
- [ ] 42. **GREEN — Invocation (**clean-room**).** Add `assemble-work` as the entry point task in the invocation table. **→ SC-9**
- [ ] 43. **GREEN — Sub-Agent Routing (**clean-room**).** Add `assemble-work` as the orchestrator entry point that routes to `pipeline-executor`. **→ SC-10**
- [ ] 44. **post-green-enforcement (**clean-room**).** Run `git diff --name-only -- .opencode/skills/implementation-pipeline/SKILL.md | wc -l` — verify changes made.
- [ ] 45. **checkpoint-tag-create (**clean-room**).** Create git tag: `opencode-config/checkpoint/1376/phase-2-skill-rewrite-opencode`.
- [ ] 46. **checkpoint-commit (**inline**).** `git add .opencode/skills/implementation-pipeline/SKILL.md && git commit -m "fix: rewrite SKILL.md with orchestrator-facing entry point"`
- [ ] 47. **structural-checks (**clean-room**).** Run `finishing-a-development-branch --task checklist` — lint/typecheck/format results.
- [ ] 48. **GREEN doublecheck (**clean-room**).** Run `verification-before-completion --task verify` — semantic-intent verification of all 6 SCs: SC-1 (no internal details), SC-2 (MUST signal), SC-3 (orchestrator entry), SC-8 (no internal details in Overview), SC-9 (assemble-work in Invocation), SC-10 (assemble-work in Sub-Agent Routing).
- [ ] 49. **green-vbc (**clean-room**).** Run `verification-before-completion --task completion` — VbC completion artifact.

### Phase 2 Completion

- [ ] 50. **adversarial-audit (**orchestrator**).** Multi-dispatch: resolve-models → dispatch verification-audit with auditor_1 (remediate on FAIL) → same with auditor_2 → collect artifact paths.
- [ ] 51. **cross-validate (**clean-room**).** Run `adversarial-audit --task cross-validate` — produce cross-validate findings YAML.
- [ ] 52. **regression-check (**clean-room**).** Run `test-driven-development --task patterns` — regression test results.
- [ ] 53. **review-prep (**clean-room**).** Run `git-workflow --task review-prep` — review-prep status.
- [ ] 54. **exec-summary (**clean-room**).** Run `completion-core --task completion` — append lifecycle event + chat exec summary.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- SC-1: SKILL.md description does not contain "17 serial dispatch steps", "Z3-verified", or "YAML contract"
- SC-2: SKILL.md description contains mandatory signal ("MUST dispatch here" or equivalent)
- SC-3: SKILL.md Trigger Dispatch Table has orchestrator entry point for "execute plan" / "implement spec"
- SC-4: `tasks/assemble-work.md` exists
- SC-5: `tasks/assemble-work.md` reads plan from `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md`
- SC-6: `tasks/assemble-work.md` dispatches to pipeline-executor
- SC-7: `tasks/pipeline-executor.md` does not contain a step count ("N-step", "N serial", etc.)
- SC-8: SKILL.md Overview does not contain step count, Z3, or YAML contract details
- SC-9: SKILL.md Invocation table includes `assemble-work` entry
- SC-10: SKILL.md Sub-Agent Routing mentions `assemble-work` as entry point
- SC-11: `tasks/assemble-work.md` references Step 1.5 entry proof marker
- SC-12: `tasks/assemble-work.md` references OVERFLOW handling
- SC-13: `tasks/assemble-work.md` references work state verification
- SC-14: `tasks/assemble-work.md` references post-sub-agent completion checkpoint
- SC-15: `tasks/pipeline-executor.md` purpose does not describe itself as orchestrator entry point
