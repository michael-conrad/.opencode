---
plan_schema_version: "1.0"
issue: 2203
title: "Decouple plan-writing from implementation-pipeline — delete-not-strip"
authorization_scope: for_implementation
pr_strategy: stacked
phase_count: 4
lifecycle_events:
  - timestamp: "2026-07-30T18:12:00Z"
    event: plan_created
    plan_path: ".opencode/.issues/2203/plan.md"
    phase_count: 4
---

# Implementation Plan — #2203 — Decouple Plan-Writing from Implementation-Pipeline

**Goal:** Create a static reference card at `skills/writing-plans/reference/implementation-workflow.md` containing all 23 content sections from `skills/implementation-pipeline/`, update all plan-writer tasks to read the card instead of loading the live skill, update all cross-references across `.opencode/`, delete the entire `skills/implementation-pipeline/` directory, and add behavioral enforcement tests.

**Architecture:** Delete-not-strip approach. The reference card is a static `.md` file — no `skill()` call needed at plan-writing or execution time. The plan writer, research task, and validation task read the card directly. The implementation-pipeline skill directory is deleted entirely — no files remain. Pipeline chain `pre-work → implementation-pipeline → ...` is replaced with `pre-work → execute-plan → ...`.

**Files:**
- `skills/writing-plans/reference/implementation-workflow.md` (new)
- `skills/writing-plans/tasks/create.md`
- `skills/writing-plans/tasks/research.md`
- `skills/writing-plans/tasks/validate.md`
- `skills/writing-plans/reference/plan-artifact-format.md`
- `skills/implementation-pipeline/` (all files — deleted)
- `skills/audit/tasks/plan-fidelity-evaluator.md`
- `skills/audit/tasks/verification-audit-investigator.md`
- `skills/audit/tasks/verification-audit-evaluator.md`
- `skills/audit/tasks/verification-audit-validator.md`
- `skills/audit/tasks/verification-audit-arbiter.md`
- `guidelines/065-verification-honesty.md`
- `skills/approval-gate-scope/SKILL.md`
- 28 tertiary files with pipeline chain references
- New behavioral test files under `.opencode/tests-v2/behaviors/`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Reference Card | `test-driven-development` | `red` | `skills/writing-plans/reference/implementation-workflow.md` | SC-1, SC-2 | — |
| 2 — Plan Writer Update | `test-driven-development` | `green` | `skills/writing-plans/tasks/create.md`, `research.md`, `validate.md`, `plan-artifact-format.md` | SC-3, SC-4, SC-5, SC-6 | 1 |
| 3 — Deletion + Cross-Refs | `test-driven-development` | `green` | `skills/implementation-pipeline/`, audit tasks, guidelines, skills, tertiary files | SC-7, SC-8, SC-9, SC-11, SC-12 | 2 |
| 4 — Cleanup + Tests | `test-driven-development` | `patterns` | New behavioral test files, final grep sweep | SC-10, SC-13 | 3 |

---

## Phase Details

### Phase 1 — Reference Card

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `skills/writing-plans/reference/implementation-workflow.md` |
| SCs | SC-1, SC-2 |
| Depends On | — |

**Context:**
```yaml
target_file: skills/writing-plans/reference/implementation-workflow.md
source_dir: skills/implementation-pipeline/
sections:
  - Per-Task Cycle — step labels with dispatch indicators
  - Canonical Dispatch Strings — all 17 step to task() mappings
  - Dispatch Indicator Semantics — inline/sub-agent/clean-room
  - Audit Sequence Protocol — audit, remediate, z3-check
  - DISPATCH_GATE Protocol — orchestrator prompt rules, forbidden patterns
  - Required Sub-agent Task File Discovery Directive
  - Dispatch Context Contract — what to pass, what to exclude
  - Pipeline Re-Priming Enforcement Block
  - Orchestrator Entry Criteria
  - DONE_WITH_CONCERNS Coercion Rule
  - Remediation Routing — FAIL, research, re-dispatch
  - Pipeline Enforcement Rules — all 13 rules
  - Artifact Retention Rules — permanent/ephemeral/pre-cleanup
  - Lifecycle Manifest Event Emission — YAML format
  - Sub-agent Context Shape
  - Worktree Mode — path prefix rule
```

### Phase 2 — Plan Writer Update

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `skills/writing-plans/tasks/create.md`, `research.md`, `validate.md`, `plan-artifact-format.md` |
| SCs | SC-3, SC-4, SC-5, SC-6 |
| Depends On | 1 |

**Context:**
```yaml
files_to_modify:
  - skills/writing-plans/tasks/create.md
  - skills/writing-plans/tasks/research.md
  - skills/writing-plans/tasks/validate.md
  - skills/writing-plans/reference/plan-artifact-format.md
reference_card_path: skills/writing-plans/reference/implementation-workflow.md
changes:
  create.md: "Replace 'Load the implementation-pipeline TDT' with 'Read the implementation-workflow reference card'"
  research.md: "Replace TDT read with reference card read for skill+task selection"
  validate.md: "Replace TDT validation with reference card validation"
  plan-artifact-format.md: "Replace implementation-pipeline/SKILL.md validation rule with reference card reference"
```

### Phase 3 — Deletion + Cross-Refs

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `skills/implementation-pipeline/`, audit tasks, guidelines, skills, tertiary files |
| SCs | SC-7, SC-8, SC-9, SC-11, SC-12 |
| Depends On | 2 |

**Context:**
```yaml
delete_target: skills/implementation-pipeline/
cross_ref_groups:
  audit:
    count: 5
    files:
      - skills/audit/tasks/plan-fidelity-evaluator.md
      - skills/audit/tasks/verification-audit-investigator.md
      - skills/audit/tasks/verification-audit-evaluator.md
      - skills/audit/tasks/verification-audit-validator.md
      - skills/audit/tasks/verification-audit-arbiter.md
    change: "Replace dispatch-string reference to reference card"
  guideline:
    count: 1
    files:
      - guidelines/065-verification-honesty.md
    change: "All refs — TDT URL extraction, coercion rule to reference card"
  skill:
    count: 1
    files:
      - skills/approval-gate-scope/SKILL.md
    change: "DONE_WITH_CONCERNS coercion rule redirect to reference card"
  tertiary_chain:
    count: 28
    change: "pre-work to implementation-pipeline to ... to pre-work to execute-plan to ..."
enforcement_docs:
  - skills/implementation-pipeline/enforcement/context-passing.md
  - skills/implementation-pipeline/enforcement/dispatch-mode-verification.md
  - skills/implementation-pipeline/enforcement/overflow-signal.md
  - skills/implementation-pipeline/enforcement/work-state-verification.md
  - skills/implementation-pipeline/pipeline-state-machine.yaml
```

### Phase 4 — Cleanup + Tests

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `patterns` |
| Target | New behavioral test files, final grep sweep |
| SCs | SC-10, SC-13 |
| Depends On | 3 |

**Context:**
```yaml
test_scenarios:
  - name: "plan-writer-reads-card"
    description: "create.md reads reference card instead of loading implementation-pipeline TDT"
    sc: SC-3
  - name: "validator-checks-card"
    description: "validate.md validates against reference card"
    sc: SC-5
  - name: "delete-not-strip"
    description: "implementation-pipeline directory absent"
    sc: SC-7
orphan_sweep:
  pattern: "skills/implementation-pipeline/"
  scope: ".opencode/"
  expected_matches: 0
```

---

## Pre-Implementation Steps

- [ ] 1. **Coherence gate (**clean-room**).** Dispatch `audit --task coherence-maintenance` to verify spec/plan coherence before any file modification. Context: `{issue_number: 2203}`. **All SCs**
- [ ] 2. **Baseline check (**sub-agent**).** Dispatch `test-driven-development --task patterns` with `mode: pre-regression` to capture current test state. Context: `{issue_number: 2203}`. **All SCs**
- [ ] 3. **Baseline verify (**sub-agent**).** Dispatch `verification-before-completion --task verify` to confirm baseline passes. Context: `{issue_number: 2203}`. **All SCs**

---

## Phase 1 — Reference Card

**Concern:** Create and populate the static reference card with all 23 content sections from the implementation-pipeline skill.

**Files:**
- `skills/writing-plans/reference/implementation-workflow.md` (new)

**SCs:** SC-1, SC-2

**Dependencies:** None

**Entry Conditions:**
- Spec #2203 is approved
- Feature branch exists
- Pre-implementation steps complete

**Exit Conditions:**
- `skills/writing-plans/reference/implementation-workflow.md` exists
- File contains all 16 enumerated content sections from implementation-pipeline/SKILL.md
- All 4 enforcement directory files merged into appropriate sections
- Pipeline state machine content either merged or noted as deleted (plan order IS the state machine)

---

- [ ] 4. **RED — Create reference card file (**sub-agent**).** Dispatch `test-driven-development --task red` to create `skills/writing-plans/reference/implementation-workflow.md` with empty shell. Context: `{issue_number: 2203, target_file: skills/writing-plans/reference/implementation-workflow.md}`. **SC-1**
- [ ] 5. **GREEN — Populate reference card with all sections (**sub-agent**).** Dispatch `test-driven-development --task green` to populate the reference card with all 23 content sections from `skills/implementation-pipeline/SKILL.md` and the 4 enforcement files. Read the source files, extract all content, and write to the reference card. Sections to include: Per-Task Cycle, Canonical Dispatch Strings (all 17 step to task() mappings), Dispatch Indicator Semantics, Audit Sequence Protocol, DISPATCH_GATE Protocol, Required Sub-agent Task File Discovery Directive, Dispatch Context Contract, Pipeline Re-Priming Enforcement Block, Orchestrator Entry Criteria, DONE_WITH_CONCERNS Coercion Rule, Remediation Routing, Pipeline Enforcement Rules (all 13 rules), Artifact Retention Rules, Lifecycle Manifest Event Emission, Sub-agent Context Shape (merge from enforcement/work-state-verification.md), Worktree Mode, Context Passing (merge from enforcement/context-passing.md), Dispatch Mode Verification (merge from enforcement/dispatch-mode-verification.md), Overflow Signal (merge from enforcement/overflow-signal.md), State Management (note: plan step order IS the state machine). Context: `{issue_number: 2203, target_file: skills/writing-plans/reference/implementation-workflow.md, source_dir: skills/implementation-pipeline/}`. **SC-2**
- [ ] 6. **GREEN doublecheck — Verify section coverage (**clean-room**).** Dispatch clean-room sub-agent to verify the reference card contains all 16 enumerated sections. Read the file, grep for each section header, report PASS/FAIL per section. Context: `{issue_number: 2203, target_file: skills/writing-plans/reference/implementation-workflow.md}`. **SC-2**
- [ ] 7. **Checkpoint commit (**inline**).** Run `git add skills/writing-plans/reference/implementation-workflow.md && git commit -m "Phase 1: create reference card with all 23 implementation-pipeline sections"`. Context: `{issue_number: 2203}`.

#### Phase 1 VbC

- [ ] 8. **VbC — Verify reference card exists and has all sections (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SC-1 (file exists via `ls`) and SC-2 (grep for each section header). Context: `{issue_number: 2203, sc_ids: [SC-1, SC-2]}`. **SC-1, SC-2**

**Concern transition:** Leaving reference card creation to entering plan writer update. Phase 2 depends on Phase 1's reference card existing.

---

## Phase 2 — Plan Writer Update

**Concern:** Update all plan-writer tasks to read the reference card instead of loading the implementation-pipeline TDT.

**Files:**
- `skills/writing-plans/tasks/create.md`
- `skills/writing-plans/tasks/research.md`
- `skills/writing-plans/tasks/validate.md`
- `skills/writing-plans/reference/plan-artifact-format.md`

**SCs:** SC-3, SC-4, SC-5, SC-6

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: reference card exists at `skills/writing-plans/reference/implementation-workflow.md`
- Phase 1 VbC passed

**Exit Conditions:**
- `create.md` reads the reference card instead of loading the implementation-pipeline TDT
- `research.md` reads the reference card for skill+task selection
- `validate.md` validates against the reference card
- `plan-artifact-format.md` validation rule references the reference card

---

- [ ] 9. **RED — Update create.md to read reference card (**sub-agent**).** Dispatch `test-driven-development --task red` to edit `skills/writing-plans/tasks/create.md`. Replace "Load the implementation-pipeline TDT" with "Read the implementation-workflow reference card at `skills/writing-plans/reference/implementation-workflow.md`". Update step 1 to read the reference card file directly instead of calling `skill({name: "implementation-pipeline"})`. Context: `{issue_number: 2203, target_file: skills/writing-plans/tasks/create.md, reference_card: skills/writing-plans/reference/implementation-workflow.md}`. **SC-3**
- [ ] 10. **GREEN — Verify create.md reads card (**clean-room**).** Dispatch clean-room sub-agent to read `skills/writing-plans/tasks/create.md` and confirm it references the reference card path, not the implementation-pipeline TDT. Context: `{issue_number: 2203, target_file: skills/writing-plans/tasks/create.md}`. **SC-3**
- [ ] 11. **Checkpoint commit (**inline**).** Commit create.md update. Context: `{issue_number: 2203}`.

- [ ] 12. **RED — Update research.md to read reference card (**sub-agent**).** Dispatch `test-driven-development --task red` to edit `skills/writing-plans/tasks/research.md`. Replace the implementation-pipeline TDT read with a reference card read for skill+task selection. Update step 5 to read the reference card instead of loading the skill. Context: `{issue_number: 2203, target_file: skills/writing-plans/tasks/research.md, reference_card: skills/writing-plans/reference/implementation-workflow.md}`. **SC-4**
- [ ] 13. **GREEN — Verify research.md reads card (**clean-room**).** Dispatch clean-room sub-agent to read `skills/writing-plans/tasks/research.md` and confirm it references the reference card path. Context: `{issue_number: 2203, target_file: skills/writing-plans/tasks/research.md}`. **SC-4**
- [ ] 14. **Checkpoint commit (**inline**).** Commit research.md update. Context: `{issue_number: 2203}`.

- [ ] 15. **RED — Update validate.md to validate against reference card (**sub-agent**).** Dispatch `test-driven-development --task red` to edit `skills/writing-plans/tasks/validate.md`. Replace TDT validation with reference card validation. Update the validation step to check skill+task references against the reference card. Context: `{issue_number: 2203, target_file: skills/writing-plans/tasks/validate.md, reference_card: skills/writing-plans/reference/implementation-workflow.md}`. **SC-5**
- [ ] 16. **GREEN — Verify validate.md validates against card (**clean-room**).** Dispatch clean-room sub-agent to read `skills/writing-plans/tasks/validate.md` and confirm it validates against the reference card. Context: `{issue_number: 2203, target_file: skills/writing-plans/tasks/validate.md}`. **SC-5**
- [ ] 17. **Checkpoint commit (**inline**).** Commit validate.md update. Context: `{issue_number: 2203}`.

- [ ] 18. **RED — Update plan-artifact-format.md validation rule (**sub-agent**).** Dispatch `test-driven-development --task red` to edit `skills/writing-plans/reference/plan-artifact-format.md`. Replace the validation rule referencing `implementation-pipeline/SKILL.md` with a reference to `skills/writing-plans/reference/implementation-workflow.md`. Context: `{issue_number: 2203, target_file: skills/writing-plans/reference/plan-artifact-format.md, reference_card: skills/writing-plans/reference/implementation-workflow.md}`. **SC-6**
- [ ] 19. **GREEN — Verify plan-artifact-format.md references card (**clean-room**).** Dispatch clean-room sub-agent to read `skills/writing-plans/reference/plan-artifact-format.md` and confirm the validation rule references the reference card. Context: `{issue_number: 2203, target_file: skills/writing-plans/reference/plan-artifact-format.md}`. **SC-6**
- [ ] 20. **Checkpoint commit (**inline**).** Commit plan-artifact-format.md update. Context: `{issue_number: 2203}`.

#### Phase 2 VbC

- [ ] 21. **VbC — Verify all 4 plan-writer files updated (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SC-3, SC-4, SC-5, SC-6. Read each file, grep for reference card path, confirm no remaining implementation-pipeline TDT references. Context: `{issue_number: 2203, sc_ids: [SC-3, SC-4, SC-5, SC-6]}`. **SC-3, SC-4, SC-5, SC-6**

**Concern transition:** Leaving plan writer update to entering deletion and cross-reference updates. Phase 3 depends on Phase 2's plan-writer files being updated.

---

## Phase 3 — Deletion + Cross-Refs

**Concern:** Delete the implementation-pipeline directory, update all cross-references, migrate coercion rule, merge enforcement docs, and update pipeline chain.

**Files:**
- `skills/implementation-pipeline/` (all files — deleted)
- `skills/audit/tasks/plan-fidelity-evaluator.md`
- `skills/audit/tasks/verification-audit-investigator.md`
- `skills/audit/tasks/verification-audit-evaluator.md`
- `skills/audit/tasks/verification-audit-validator.md`
- `skills/audit/tasks/verification-audit-arbiter.md`
- `guidelines/065-verification-honesty.md`
- `skills/approval-gate-scope/SKILL.md`
- 28 tertiary files with pipeline chain references

**SCs:** SC-7, SC-8, SC-9, SC-11, SC-12

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: all 4 plan-writer files updated
- Phase 2 VbC passed
- Reference card contains all merged enforcement doc content

**Exit Conditions:**
- `skills/implementation-pipeline/` directory deleted entirely
- All 5 audit task cross-references updated to reference card
- `065-verification-honesty.md` Pre-Response Factual Claim Gate section updated (TDT URL extraction ref to reference card)
- `approval-gate-scope/SKILL.md` DONE_WITH_CONCERNS coercion rule redirect to reference card
- All 28 tertiary files have pipeline chain updated
- 4 enforcement docs merged into reference card and originals deleted
- `pipeline-state-machine.yaml` deleted

---

- [ ] 22. **RED — Update 5 audit task cross-references (**sub-agent**).** Dispatch `test-driven-development --task red` to update all 5 audit task files. For each file, replace `skills/implementation-pipeline/SKILL.md` with `skills/writing-plans/reference/implementation-workflow.md` in dispatch-string references. Files: `skills/audit/tasks/plan-fidelity-evaluator.md` (2 occurrences), `skills/audit/tasks/verification-audit-investigator.md` (1 occurrence), `skills/audit/tasks/verification-audit-evaluator.md` (1 occurrence), `skills/audit/tasks/verification-audit-validator.md` (1 occurrence), `skills/audit/tasks/verification-audit-arbiter.md` (1 occurrence). Context: `{issue_number: 2203, reference_card: skills/writing-plans/reference/implementation-workflow.md}`. **SC-8(a)**
- [ ] 23. **GREEN — Verify audit cross-references updated (**clean-room**).** Dispatch clean-room sub-agent to grep each of the 5 audit files for `skills/implementation-pipeline/` — confirm zero matches. Context: `{issue_number: 2203}`. **SC-8(a)**
- [ ] 24. **Checkpoint commit (**inline**).** Commit audit cross-reference updates. Context: `{issue_number: 2203}`.

- [ ] 25. **RED — Update 065-verification-honesty.md cross-references (**sub-agent**).** Dispatch `test-driven-development --task red` to edit `guidelines/065-verification-honesty.md`. Update the Pre-Response Factual Claim Gate section (TDT URL extraction ref) to reference `skills/writing-plans/reference/implementation-workflow.md` instead of `implementation-pipeline/SKILL.md`. Preserve the DONE_WITH_CONCERNS coercion rule references at lines 318 and 453 (update the path to reference card). Context: `{issue_number: 2203, target_file: guidelines/065-verification-honesty.md, reference_card: skills/writing-plans/reference/implementation-workflow.md}`. **SC-8(c), SC-11**
- [ ] 26. **GREEN — Verify 065-verification-honesty.md updated (**clean-room**).** Dispatch clean-room sub-agent to read `guidelines/065-verification-honesty.md` and confirm all references to `implementation-pipeline/SKILL.md` are replaced with the reference card path. Context: `{issue_number: 2203, target_file: guidelines/065-verification-honesty.md}`. **SC-8(c), SC-11**
- [ ] 27. **Checkpoint commit (**inline**).** Commit 065-verification-honesty.md updates. Context: `{issue_number: 2203}`.

- [ ] 28. **RED — Update approval-gate-scope/SKILL.md coercion rule redirect (**sub-agent**).** Dispatch `test-driven-development --task red` to edit `skills/approval-gate-scope/SKILL.md`. Update the DONE_WITH_CONCERNS coercion rule reference to point to `skills/writing-plans/reference/implementation-workflow.md` instead of `implementation-pipeline/SKILL.md`. Context: `{issue_number: 2203, target_file: skills/approval-gate-scope/SKILL.md, reference_card: skills/writing-plans/reference/implementation-workflow.md}`. **SC-11**
- [ ] 29. **GREEN — Verify approval-gate-scope updated (**clean-room**).** Dispatch clean-room sub-agent to read `skills/approval-gate-scope/SKILL.md` and confirm the coercion rule reference points to the reference card. Context: `{issue_number: 2203, target_file: skills/approval-gate-scope/SKILL.md}`. **SC-11**
- [ ] 30. **Checkpoint commit (**inline**).** Commit approval-gate-scope updates. Context: `{issue_number: 2203}`.

- [ ] 31. **RED — Update pipeline chain in 28 tertiary files (**sub-agent**).** Dispatch `test-driven-development --task red` to update the pipeline chain in all 28 tertiary files. Replace `pre-work → implementation-pipeline → verification-before-completion → finishing-checklist → review-prep` with `pre-work → execute-plan → verification-before-completion → finishing-checklist → review-prep`. Files per cross-ref-audit.yaml TERTIARY_CHAIN_UPDATE list. Context: `{issue_number: 2203, old_chain: "pre-work → implementation-pipeline → verification-before-completion → finishing-checklist → review-prep", new_chain: "pre-work → execute-plan → verification-before-completion → finishing-checklist → review-prep"}`. **SC-9**
- [ ] 32. **GREEN — Verify pipeline chain updated (**clean-room**).** Dispatch clean-room sub-agent to grep all 28 tertiary files for the old chain pattern — confirm zero matches. Context: `{issue_number: 2203, old_chain: "pre-work → implementation-pipeline → verification-before-completion → finishing-checklist → review-prep"}`. **SC-9**
- [ ] 33. **Checkpoint commit (**inline**).** Commit pipeline chain updates. Context: `{issue_number: 2203}`.

- [ ] 34. **RED — Merge enforcement docs into reference card (**sub-agent**).** Dispatch `test-driven-development --task red` to merge the 4 enforcement directory files into the reference card. For each file, read the content and append to the appropriate section of `skills/writing-plans/reference/implementation-workflow.md`: `enforcement/context-passing.md` to DISPATCH_GATE Protocol section, `enforcement/dispatch-mode-verification.md` to Pipeline Enforcement Rules section, `enforcement/overflow-signal.md` to Artifact Retention Rules section, `enforcement/work-state-verification.md` to Sub-agent Context Shape section. Context: `{issue_number: 2203, reference_card: skills/writing-plans/reference/implementation-workflow.md, enforcement_dir: skills/implementation-pipeline/enforcement/}`. **SC-12**
- [ ] 35. **GREEN — Verify enforcement docs merged (**clean-room**).** Dispatch clean-room sub-agent to read the reference card and confirm all 4 enforcement doc sections are present. Context: `{issue_number: 2203, reference_card: skills/writing-plans/reference/implementation-workflow.md}`. **SC-12**
- [ ] 36. **Checkpoint commit (**inline**).** Commit enforcement doc merge. Context: `{issue_number: 2203}`.

- [ ] 37. **RED — Delete implementation-pipeline directory (**inline**).** Run `rm -rf skills/implementation-pipeline/` to delete the entire directory. Context: `{issue_number: 2203, delete_target: skills/implementation-pipeline/}`. **SC-7**
- [ ] 38. **GREEN — Verify directory deleted (**clean-room**).** Dispatch clean-room sub-agent to run `ls skills/implementation-pipeline/` and confirm the directory does not exist. Context: `{issue_number: 2203, delete_target: skills/implementation-pipeline/}`. **SC-7**
- [ ] 39. **Checkpoint commit (**inline**).** Commit implementation-pipeline deletion. Context: `{issue_number: 2203}`.

#### Phase 3 VbC

- [ ] 40. **VbC — Verify deletion and all cross-references (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SC-7 (directory absent via `ls`), SC-8 (grep audit files for old path — zero matches), SC-9 (grep tertiary files for old chain — zero matches), SC-11 (grep approval-gate-scope and 065-verification-honesty.md for coercion rule reference), SC-12 (grep reference card for enforcement doc sections). Context: `{issue_number: 2203, sc_ids: [SC-7, SC-8, SC-9, SC-11, SC-12]}`. **SC-7, SC-8, SC-9, SC-11, SC-12**

**Concern transition:** Leaving deletion and cross-references to entering cleanup and tests. Phase 4 depends on Phase 3's deletion and cross-reference updates.

---

## Phase 4 — Cleanup + Tests

**Concern:** Add behavioral enforcement tests and run final orphan reference sweep.

**Files:**
- New behavioral test files under `.opencode/tests-v2/behaviors/`
- All `.opencode/` files (for final grep sweep)

**SCs:** SC-10, SC-13

**Dependencies:** Phase 3

**Entry Conditions:**
- Phase 3 complete: implementation-pipeline directory deleted, all cross-references updated
- Phase 3 VbC passed

**Exit Conditions:**
- Behavioral enforcement tests exist for plan-writer workflow and delete-not-strip
- Final grep sweep confirms zero matches for `skills/implementation-pipeline/` across all `.opencode/` files

---

- [ ] 41. **RED — Create behavioral enforcement test for plan-writer reads card (**sub-agent**).** Dispatch `test-driven-development --task red` to create a behavioral test at `.opencode/tests-v2/behaviors/plan-writer-reads-card.sh`. The test sends a plan-writing prompt via `opencode run` and asserts the agent reads the reference card (stderr shows reference card read, not implementation-pipeline skill load). Use `with-test-home` wrapper. Context: `{issue_number: 2203, test_dir: .opencode/tests-v2/behaviors/, test_name: plan-writer-reads-card}`. **SC-10**
- [ ] 42. **GREEN — Verify behavioral test exists (**clean-room**).** Dispatch clean-room sub-agent to verify the test file exists and has valid assertion helpers. Context: `{issue_number: 2203, test_file: .opencode/tests-v2/behaviors/plan-writer-reads-card.sh}`. **SC-10**
- [ ] 43. **Checkpoint commit (**inline**).** Commit plan-writer behavioral test. Context: `{issue_number: 2203}`.

- [ ] 44. **RED — Create behavioral enforcement test for validator checks card (**sub-agent**).** Dispatch `test-driven-development --task red` to create a behavioral test at `.opencode/tests-v2/behaviors/validator-checks-card.sh`. The test sends a validate scenario via `opencode run` and asserts the agent validates against the reference card. Context: `{issue_number: 2203, test_dir: .opencode/tests-v2/behaviors/, test_name: validator-checks-card}`. **SC-10**
- [ ] 45. **GREEN — Verify behavioral test exists (**clean-room**).** Dispatch clean-room sub-agent to verify the test file exists. Context: `{issue_number: 2203, test_file: .opencode/tests-v2/behaviors/validator-checks-card.sh}`. **SC-10**
- [ ] 46. **Checkpoint commit (**inline**).** Commit validator behavioral test. Context: `{issue_number: 2203}`.

- [ ] 47. **RED — Create behavioral enforcement test for delete-not-strip (**sub-agent**).** Dispatch `test-driven-development --task red` to create a behavioral test at `.opencode/tests-v2/behaviors/delete-not-strip.sh`. The test verifies the implementation-pipeline directory is absent (not stripped). Context: `{issue_number: 2203, test_dir: .opencode/tests-v2/behaviors/, test_name: delete-not-strip}`. **SC-10**
- [ ] 48. **GREEN — Verify behavioral test exists (**clean-room**).** Dispatch clean-room sub-agent to verify the test file exists. Context: `{issue_number: 2203, test_file: .opencode/tests-v2/behaviors/delete-not-strip.sh}`. **SC-10**
- [ ] 49. **Checkpoint commit (**inline**).** Commit delete-not-strip behavioral test. Context: `{issue_number: 2203}`.

- [ ] 50. **RED — Run final orphan reference sweep (**inline**).** Run `grep -rn 'skills/implementation-pipeline/' .opencode/ --include='*.md' --include='*.yaml' --include='*.ts' --include='*.py'` and confirm zero matches. If any matches found, report them and halt. Context: `{issue_number: 2203, sweep_pattern: "skills/implementation-pipeline/"}`. **SC-13**
- [ ] 51. **GREEN — Verify sweep clean (**clean-room**).** Dispatch clean-room sub-agent to re-run the grep and confirm zero matches. Context: `{issue_number: 2203, sweep_pattern: "skills/implementation-pipeline/"}`. **SC-13**
- [ ] 52. **Checkpoint commit (**inline**).** Commit any sweep fixes (if needed) or note clean sweep. Context: `{issue_number: 2203}`.

#### Phase 4 VbC

- [ ] 53. **VbC — Verify tests and sweep (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SC-10 (behavioral test files exist) and SC-13 (grep sweep zero matches). Context: `{issue_number: 2203, sc_ids: [SC-10, SC-13]}`. **SC-10, SC-13**

**Concern transition:** Leaving cleanup and tests to entering post-implementation steps.

---

## Post-Implementation Steps

- [ ] 54. **Structural checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist` to run lint, typecheck, and structural verification. Context: `{issue_number: 2203}`. **All SCs**
- [ ] 55. **Pre-PR gate (**sub-agent**).** Dispatch `verification-before-completion --task verify` to read all SC verdicts and BLOCK if any FAIL. Context: `{issue_number: 2203}`. **All SCs**
- [ ] 56. **Rationalization check (**sub-agent**).** Dispatch `verification-before-completion --task verify` with clean-room sub-agent to evaluate whether any proposed action is a rationalization. Context: `{issue_number: 2203}`. **All SCs**
- [ ] 57. **Regression check (**sub-agent**).** Dispatch `test-driven-development --task patterns` to run regression tests. Context: `{issue_number: 2203}`. **All SCs**
- [ ] 58. **Review prep (**sub-agent**).** Dispatch `git-workflow --task review-prep` to prepare PR review context. Context: `{issue_number: 2203}`. **All SCs**
- [ ] 59. **Create PR (**sub-agent**).** Dispatch `pr-creation-workflow --task create` with `{authorization_scope: for_implementation, halt_at: pr_created}`. Context: `{issue_number: 2203}`. **All SCs**
- [ ] 60. **Exec summary (**sub-agent**).** Dispatch `completion-core --task completion` to emit lifecycle event and summary. Context: `{issue_number: 2203}`. **All SCs**

---

## Exit Criteria

- [ ] C1. `skills/writing-plans/reference/implementation-workflow.md` exists
- [ ] C2. Reference card contains all 16 enumerated content sections from implementation-pipeline/SKILL.md
- [ ] C3. `create.md` reads the reference card instead of loading the implementation-pipeline TDT
- [ ] C4. `research.md` reads the reference card for skill+task selection
- [ ] C5. `validate.md` validates against the reference card
- [ ] C6. `plan-artifact-format.md` validation rule references the reference card
- [ ] C7. `skills/implementation-pipeline/` deleted entirely — all files removed
- [ ] C8. All cross-references to `skills/implementation-pipeline/` across `.opencode/` updated
- [ ] C9. Pipeline chain `pre-work → implementation-pipeline → ...` replaced with `pre-work → execute-plan → ...`
- [ ] C10. Behavioral enforcement tests exist for plan-writer workflow and delete-not-strip
- [ ] C11. DONE_WITH_CONCERNS coercion rule moved to reference card; approval-gate-scope and 065-verification-honesty.md updated
- [ ] C12. Enforcement directory contents merged into reference card; originals deleted
- [ ] C13. Final grep sweep confirms zero matches for `skills/implementation-pipeline/` across all `.opencode/` files
