---
plan_schema_version: 1
issue: 2254
title: "Remediate spec-creation and audit skill cards plus reference standards"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 29
dispatch: [test-driven-development]
---

# Implementation Plan — #2254 — Remediate spec-creation and audit skill cards plus reference standards

**Issue:** [.opencode#2254](https://github.com/michael-conrad/.opencode/issues/2254)

**Goal:** Remediate the spec-creation and audit skill card sets plus the consolidated reference standards so agents dispatch with canonical formats, resolve cross-references to real files, read the taxonomy and dimensions from canonical sources, and route to existing task cards — proven working end-to-end, not just well-formed.

**Architecture:** Apply exactly one prescriptive resolution per finding, each mapped one-to-one to a success criterion. The plan is decomposed into 29 phases, each addressing exactly one concern from the concern-map artifact. Spec-creation concerns (phases 1–7) and audit concerns (phases 8–13) are independent root groups; cross-reference and taxonomy concerns (phases 14–17) depend on the audit role-card surface; completion routing (18) and revise regeneration (19) depend on their respective roots; format-conformance concerns (phases 20–26) depend on the restructured skill surfaces; functional end-to-end verification (phases 27–28) is terminal and depends on all prior phases; shared test home (29) is an independent infrastructure root. Each SC follows a RED → GREEN → post-regression → verify → commit per-task cycle, with the inline-vs-dispatched boundary fixed by the Execution Model below (no sub-agent ever dispatches another sub-agent).

**Files:**
- `.opencode/skills/spec-creation/` (SKILL.md, tasks/analyze.md, tasks/create.md, tasks/validate.md, tasks/revise.md)
- `.opencode/skills/audit/` (SKILL.md, tasks/*-role.md, tasks/completion.md, removed behavioral-sc-evaluator.md, flattened subdirectory task sets)
- `.opencode/skills/issue-operations-core/tasks/creation.md`
- `.opencode/reference/` (spec-structure-standards.md, holistic-dimensions.yaml, skill-card-description-standards.md, task-card-structure-standards.md, cost-model-standards.md)
- `.opencode/tools/impl/skildeck/`
- `.opencode/tests-v2/with-test-home`, `.opencode/tests-v2/behaviors/helpers.sh`, new behavioral test scripts + fixtures

**Dispatch:** `test-driven-development` (per-SC RED → GREEN → verify → commit cycle for all phases).

**Execution Model (Inline vs Dispatched — MANDATORY):** Every step in every phase carries an explicit execution mode. The hard constraint is that **sub-agents CANNOT dispatch sub-agents** (`task: deny` is hardcoded). Therefore:

| Step | Execution Mode |
|------|----------------|
| RED — write enforcement test, confirm FAIL | DISPATCHED to a clean-room sub-agent |
| GREEN — implement, confirm PASS | DISPATCHED to a SEPARATE clean-room sub-agent (never the RED sub-agent — preserves RED/GREEN separation) |
| Verify / post-regression | DISPATCHED to a sub-agent different from the producer |
| Behavioral `opencode run` execution (SC-17, SC-28, SC-32, SC-33, SC-34) | INLINE — orchestrator runs via bash with `with-test-home` wrapper; a sub-agent cannot dispatch this |
| session.yaml clean-room evaluation (behavioral SCs) | DISPATCHED to a clean-room sub-agent |
| Commit | DISPATCHED to a sub-agent |

**Rules:**
- **NO sub-agent is ever asked to dispatch another sub-agent.** Any step that requires running `opencode run` or dispatching a sub-agent is either INLINE (orchestrator) or a separate dispatched step — never embedded inside a sub-agent's procedure.
- Any step requiring `opencode run` is INLINE (orchestrator), never inside a sub-agent's procedure.
- Behavioral phases (3, 24, 27, 28, 29) split their RED/GREEN steps into: DISPATCHED (write test / implement) → INLINE (run `opencode run`) → DISPATCHED (evaluate session.yaml).
- Non-behavioral phases use the standard DISPATCHED RED → GREEN → verify → commit cycle with no inline run.
- RED and GREEN always run in separate sub-agents; verify always runs in a sub-agent different from the producer.

---

## Blast Radius

Affected files and impact zones from the blast-radius artifact:

| File | Change Type | Impact |
|------|-------------|--------|
| `.opencode/skills/spec-creation/SKILL.md` | Restructure | Canonical dispatch format, remove Task Files table, numbered-checkbox Workflows, explicit orchestrator steps |
| `.opencode/skills/audit/SKILL.md` | Restructure | Single Workflows section with 4 DiMo steps, remove TDT/Invocation/Tasks, canonical dispatch, numbered-checkbox, rewritten description |
| `.opencode/skills/spec-creation/tasks/{analyze,create,validate,revise}.md` | Edit | Issue anchoring, exec-summary body, dynamic dimensions, body regeneration, numbered-checkbox Procedures |
| `.opencode/skills/audit/tasks/*-role.md` | Restructure | Repair names/headings, repoint refs, flatten subdirectories, split fat cards, numbered-checkbox Procedures |
| `.opencode/skills/audit/tasks/completion.md` | Edit | Correct routing, repoint dangling verify-authorization |
| `.opencode/skills/audit/tasks/behavioral-sc-evaluator.md` | Remove | Redundant file with zero consumers |
| `.opencode/skills/issue-operations-core/tasks/creation.md` | Bug fix | Correct `.issues/` path prefix in issues-data URL template |
| `.opencode/reference/spec-structure-standards.md` | Edit | Update stale task names |
| `.opencode/reference/holistic-dimensions.yaml` | Cross-reference target | Dynamic loading source |
| `.opencode/reference/skill-card-description-standards.md` | Edit | §7 Workflows → numbered-checkbox with execution-mode indicator |
| `.opencode/reference/task-card-structure-standards.md` | Edit | Procedure → numbered-checkbox, clean-room unit, dispatch-contract completeness |
| `.opencode/reference/cost-model-standards.md` | Cross-reference target | Evidence-type taxonomy canonical reference |
| `.opencode/tools/impl/skildeck/` | Edit | Extend linter for new format rules |
| `.opencode/tests-v2/with-test-home` | Infrastructure | Shared test home for functional tests |
| `.opencode/tests-v2/behaviors/helpers.sh` | Infrastructure | `__ensure_gitbucket` for test gitbucket instance |

---

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

---

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Dispatch | Execution Mode |
|-------|------|---------|-----|------------|----------|----------------|
| 1 | spec-creation dispatch format | spec-creation dispatch format | SC-1 | — | test-driven-development | Dispatched TDD |
| 2 | spec-creation task routing | spec-creation task routing | SC-2 | 1 | test-driven-development | Dispatched TDD |
| 3 | analyze issue anchoring | analyze issue anchoring | SC-17 | — | test-driven-development | Dispatched TDD + Inline opencode run |
| 4 | dynamic dimension loading | dynamic dimension loading | SC-18 | — | test-driven-development | Dispatched TDD |
| 5 | create exec-summary body | create exec-summary body | SC-19, SC-20 | — | test-driven-development | Dispatched TDD |
| 6 | post-push reconciliation | post-push reconciliation | SC-21 | 5 | test-driven-development | Dispatched TDD |
| 7 | issues-data URL root-cause | issues-data URL root-cause | SC-37 | — | test-driven-development | Dispatched TDD |
| 8 | audit workflow structure | audit workflow structure | SC-3, SC-4 | — | test-driven-development | Dispatched TDD |
| 9 | audit description rewrite | audit description rewrite | SC-7 | — | test-driven-development | Dispatched TDD |
| 10 | audit dispatch format | audit dispatch format | SC-5, SC-6 | 8 | test-driven-development | Dispatched TDD |
| 11 | audit role-card naming | audit role-card naming | SC-8, SC-9 | 8 | test-driven-development | Dispatched TDD |
| 12 | audit flattening | audit flattening | SC-12 | 8 | test-driven-development | Dispatched TDD |
| 13 | redundant evaluator removal | redundant evaluator removal | SC-14 | 8 | test-driven-development | Dispatched TDD |
| 14 | audit cross-reference repoints | audit cross-reference repoints | SC-10 | 11, 12 | test-driven-development | Dispatched TDD |
| 15 | reference task names | reference task names | SC-11 | 8 | test-driven-development | Dispatched TDD |
| 16 | taxonomy source consolidation | taxonomy source consolidation | SC-15 | 4, 8 | test-driven-development | Dispatched TDD |
| 17 | missing-type rule | missing-type rule | SC-16 | 3 | test-driven-development | Dispatched TDD |
| 18 | completion routing | completion routing | SC-13 | 8 | test-driven-development | Dispatched TDD |
| 19 | revise exec-summary regeneration | revise exec-summary regeneration | SC-22 | 5 | test-driven-development | Dispatched TDD |
| 20 | numbered-checkbox Workflows format | numbered-checkbox Workflows format | SC-23, SC-24, SC-35 | 1, 2, 8, 9, 10 | test-driven-development | Dispatched TDD |
| 21 | numbered-checkbox task-card Procedure | numbered-checkbox task-card Procedure | SC-25, SC-36 | 3, 4, 5, 6, 11, 12, 14 | test-driven-development | Dispatched TDD |
| 22 | fat task-card splitting | fat task-card splitting | SC-26 | 21 | test-driven-development | Dispatched TDD |
| 23 | dispatch-contract completeness | dispatch-contract completeness | SC-27 | 20, 21 | test-driven-development | Dispatched TDD |
| 24 | linter enforcement | linter enforcement | SC-28 | 20, 21, 22, 23 | test-driven-development | Dispatched TDD + Inline opencode run |
| 25 | markdown link correctness | markdown link correctness | SC-29a, SC-29b, SC-29c | 20, 21 | test-driven-development | Dispatched TDD |
| 26 | workflow clarity | workflow clarity | SC-31 | 20 | test-driven-development | Dispatched TDD |
| 27 | functional spec-creation pipeline | functional spec-creation pipeline | SC-32 | 1, 2, 3, 4, 5, 6, 7, 19, 20, 21, 22, 23, 24, 25, 26, 29 | test-driven-development | Dispatched TDD + Inline opencode run |
| 28 | functional audit DiMo chain | functional audit DiMo chain | SC-33 | 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 20, 21, 22, 23, 24, 25, 26, 29 | test-driven-development | Dispatched TDD + Inline opencode run |
| 29 | shared test home + gitbucket | shared test home + gitbucket | SC-34 | — | test-driven-development | Dispatched TDD + Inline opencode run |

---

## Phase Details

### Phase 1 — spec-creation dispatch format

| Field | Value |
|-------|-------|
| Concern | spec-creation dispatch format |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/SKILL.md` |
| SCs | SC-1 |
| Depends On | — |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting zero deprecated `execute X from Y` dispatch strings remain; confirm it FAILs on the current code (RED, SC-1).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Convert the 6 deprecated `execute X from Y` dispatch prompts in spec-creation/SKILL.md to canonical `Follow the instructions in [<skill>/tasks/<task>.md](...)` format (GREEN, SC-1).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the canonical dispatch format is present; confirm PASS (GREEN, SC-1).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-1 (SC-1).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-1).

### Phase 2 — spec-creation task routing

| Field | Value |
|-------|-------|
| Concern | spec-creation task routing |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/SKILL.md` |
| SCs | SC-2 |
| Depends On | 1 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the `## Task Files` table is present; confirm it FAILs on the current code (RED, SC-2).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Remove the redundant `## Task Files` table from spec-creation/SKILL.md (GREEN, SC-2).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting task routing is unambiguous without the table; confirm PASS (GREEN, SC-2).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-2 (SC-2).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-2).

### Phase 3 — analyze issue anchoring

| Field | Value |
|-------|-------|
| Concern | analyze issue anchoring |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/tasks/analyze.md` |
| SCs | SC-17 |
| Depends On | — |
| Execution Mode | Dispatched TDD + Inline opencode run (behavioral) |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the behavioral enforcement test asserting analyze proceeds on an unbound/placeholder issue number (RED, SC-17).
- [ ] 2. **[INLINE — orchestrator]** Run the RED `opencode run` via the `with-test-home` wrapper; confirm analyze proceeds on an unbound issue number (FAIL) (RED, SC-17).
- [ ] 3. **[DISPATCHED — session.yaml sub-agent]** Evaluate the RED session.yaml clean-room; confirm the assertion FAILs (RED, SC-17).
- [ ] 4. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Implement the change: add a BLOCK to analyze.md on unbound/placeholder issue number (GREEN, SC-17).
- [ ] 5. **[INLINE — orchestrator]** Run the GREEN `opencode run` via the `with-test-home` wrapper; confirm analyze BLOCKs on an unbound/placeholder issue number (PASS) (GREEN, SC-17).
- [ ] 6. **[DISPATCHED — session.yaml sub-agent]** Evaluate the GREEN session.yaml clean-room; confirm the assertion PASSes (GREEN, SC-17).
- [ ] 7. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-17 (SC-17).
- [ ] 8. **[DISPATCHED — commit sub-agent]** Commit the change (SC-17).

### Phase 4 — dynamic dimension loading

| Field | Value |
|-------|-------|
| Concern | dynamic dimension loading |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/tasks/validate.md` |
| SCs | SC-18 |
| Depends On | — |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting validate.md uses hardcoded dimensions; confirm it FAILs on the current code (RED, SC-18).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Make validate.md load the 11 holistic dimensions dynamically from reference/holistic-dimensions.yaml (GREEN, SC-18).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting validate loads dimensions dynamically; confirm PASS (GREEN, SC-18).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-18 (SC-18).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-18).

### Phase 5 — create exec-summary body

| Field | Value |
|-------|-------|
| Concern | create exec-summary body |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/tasks/create.md` |
| SCs | SC-19, SC-20 |
| Depends On | — |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting create does not emit the canonical exec-summary body; confirm it FAILs on the current code (RED, SC-19, SC-20).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Route create.md remote issue body to the canonical exec-summary body format per issue-operations-core/tasks/creation.md Step 5 (GREEN, SC-19); add the forward-reference Spec Reference Blockquote / issues-data link to create.md remote body (GREEN, SC-20).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting create emits the canonical exec-summary body with forward-reference blockquote; confirm PASS (GREEN, SC-19, SC-20).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-19, SC-20 (SC-19, SC-20).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-19, SC-20).

### Phase 6 — post-push reconciliation

| Field | Value |
|-------|-------|
| Concern | post-push reconciliation |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/tasks/create.md` |
| SCs | SC-21 |
| Depends On | 5 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting reconciliation is not sequenced after push-artifacts; confirm it FAILs on the current code (RED, SC-21).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Sequence post-push reconciliation after issue-operations/platforms/local/tasks/push-artifacts.md (GREEN, SC-21).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting reconciliation runs after push-artifacts; confirm PASS (GREEN, SC-21).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-21 (SC-21).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-21).

### Phase 7 — issues-data URL root-cause

| Field | Value |
|-------|-------|
| Concern | issues-data URL root-cause |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/issue-operations-core/tasks/creation.md` |
| SCs | SC-37 |
| Depends On | — |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the `.issues/` prefix is present in the URL template; confirm it FAILs on the current code (RED, SC-37).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Fix the issues-data URL template in issue-operations-core/tasks/creation.md Step 5: `tree/issues-data/N/`, `{{SPEC_PATH}}` = `N/` (GREEN, SC-37).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the URL template uses `tree/issues-data/N/` with `{{SPEC_PATH}}` = `N/`; confirm PASS (GREEN, SC-37).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-37 (SC-37).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-37).

### Phase 8 — audit workflow structure

| Field | Value |
|-------|-------|
| Concern | audit workflow structure |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/SKILL.md` |
| SCs | SC-3, SC-4 |
| Depends On | — |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the old multi-section structure remains; confirm it FAILs on the current code (RED, SC-3, SC-4).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Convert audit/SKILL.md to a single Workflows section with 4 DiMo steps (GREEN, SC-3); remove the TDT/Invocation/Tasks sections from audit/SKILL.md (GREEN, SC-4).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the single Workflows section with 4 DiMo steps and no TDT/Invocation/Tasks; confirm PASS (GREEN, SC-3, SC-4).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-3, SC-4 (SC-3, SC-4).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-3, SC-4).

### Phase 9 — audit description rewrite

| Field | Value |
|-------|-------|
| Concern | audit description rewrite |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/SKILL.md` |
| SCs | SC-7 |
| Depends On | — |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the description uses the deprecated meta-instruction format; confirm it FAILs on the current code (RED, SC-7).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Rewrite the audit/SKILL.md description frontmatter to canonical agent-intent format, removing `Load via skill() when`, `Also load when`, and `User phrases:` meta-instructions (GREEN, SC-7).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the description is in canonical agent-intent format; confirm PASS (GREEN, SC-7).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-7 (SC-7).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-7).

### Phase 10 — audit dispatch format

| Field | Value |
|-------|-------|
| Concern | audit dispatch format |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/SKILL.md` |
| SCs | SC-5, SC-6 |
| Depends On | 8 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting deprecated DiMo dispatch strings remain; confirm it FAILs on the current code (RED, SC-5, SC-6).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Convert audit dispatch to the canonical format (GREEN, SC-5); remove the deprecated `execute <task> DiMo <role> from audit` strings (GREEN, SC-6).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting canonical dispatch format with zero deprecated DiMo strings; confirm PASS (GREEN, SC-5, SC-6).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-5, SC-6 (SC-5, SC-6).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-5, SC-6).

### Phase 11 — audit role-card naming

| Field | Value |
|-------|-------|
| Concern | audit role-card naming |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/*-role.md` |
| SCs | SC-8, SC-9 |
| Depends On | 8 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting role-card names/headings mismatch filenames; confirm it FAILs on the current code (RED, SC-8, SC-9).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Repair the 40 role-card frontmatter `name:` fields to match filenames (GREEN, SC-8); repair the role-card `# Task:` headings to match filenames (GREEN, SC-9).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting all role-card names/headings match filenames; confirm PASS (GREEN, SC-8, SC-9).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-8, SC-9 (SC-8, SC-9).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-8, SC-9).

### Phase 12 — audit flattening

| Field | Value |
|-------|-------|
| Concern | audit flattening |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/` |
| SCs | SC-12 |
| Depends On | 8 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the subdirectory task sets remain; confirm it FAILs on the current code (RED, SC-12).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Flatten the three subdirectory audit tasks (closure-verification/, coherence-extraction/, spec-summary/) to flat role files and remove stub index files (GREEN, SC-12).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the subdirectory task sets are flattened to flat role files; confirm PASS (GREEN, SC-12).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-12 (SC-12).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-12).

### Phase 13 — redundant evaluator removal

| Field | Value |
|-------|-------|
| Concern | redundant evaluator removal |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/behavioral-sc-evaluator.md` |
| SCs | SC-14 |
| Depends On | 8 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the file exists; confirm it FAILs on the current code (RED, SC-14).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Remove the redundant behavioral-sc-evaluator.md (GREEN, SC-14).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the file is absent; confirm PASS (GREEN, SC-14).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-14 (SC-14).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-14).

### Phase 14 — audit cross-reference repoints

| Field | Value |
|-------|-------|
| Concern | audit cross-reference repoints |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/*-role.md`, `.opencode/reference/holistic-dimensions.yaml` |
| SCs | SC-10 |
| Depends On | 11, 12 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting broken cross-references remain; confirm it FAILs on the current code (RED, SC-10).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Repoint broken cross-references to non-existent monolithic role-task files (tasks/spec-audit.md, tasks/plan-fidelity.md) to actual role-split files, including reference/holistic-dimensions.yaml (GREEN, SC-10).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting all cross-references resolve to role-split files; confirm PASS (GREEN, SC-10).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-10 (SC-10).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-10).

### Phase 15 — reference task names

| Field | Value |
|-------|-------|
| Concern | reference task names |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/reference/spec-structure-standards.md` |
| SCs | SC-11 |
| Depends On | 8 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting stale task names remain; confirm it FAILs on the current code (RED, SC-11).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Update stale reference-doc task names (inspect/decompose/write/check/file) to actual names (analyze/create/validate/revise) in reference/spec-structure-standards.md (GREEN, SC-11).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting actual task names are used; confirm PASS (GREEN, SC-11).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-11 (SC-11).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-11).

### Phase 16 — taxonomy source consolidation

| Field | Value |
|-------|-------|
| Concern | taxonomy source consolidation |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/tasks/validate.md`, `.opencode/skills/audit/tasks/*-role.md`, `.opencode/reference/cost-model-standards.md` |
| SCs | SC-15 |
| Depends On | 4, 8 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting taxonomy citations point at multiple sources; confirm it FAILs on the current code (RED, SC-15).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Point evidence-type taxonomy citations in spec-creation validate and audit role cards at the single canonical reference, loaded dynamically (GREEN, SC-15).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting all citations point at the single canonical reference; confirm PASS (GREEN, SC-15).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-15 (SC-15).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-15).

### Phase 17 — missing-type rule

| Field | Value |
|-------|-------|
| Concern | missing-type rule |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/tasks/analyze.md`, `.opencode/reference/spec-structure-standards.md` |
| SCs | SC-16 |
| Depends On | 3 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting a missing evidence-type is tolerated; confirm it FAILs on the current code (RED, SC-16).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Make missing evidence-type declaration a hard FAIL routed to remediation in reference/spec-structure-standards.md (GREEN, SC-16).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting a missing evidence-type is a hard FAIL; confirm PASS (GREEN, SC-16).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-16 (SC-16).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-16).

### Phase 18 — completion routing

| Field | Value |
|-------|-------|
| Concern | completion routing |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/completion.md` |
| SCs | SC-13 |
| Depends On | 8 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the dangling reference remains; confirm it FAILs on the current code (RED, SC-13).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Correct audit/tasks/completion.md routing to the actual 3-step verify-authorization workflow; remove the dangling `approval-gate --task verify-authorization` reference (GREEN, SC-13).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting routing is corrected and the dangling reference is removed; confirm PASS (GREEN, SC-13).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-13 (SC-13).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-13).

### Phase 19 — revise exec-summary regeneration

| Field | Value |
|-------|-------|
| Concern | revise exec-summary regeneration |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/tasks/revise.md` |
| SCs | SC-22 |
| Depends On | 5 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting revise does not regenerate the exec-summary body; confirm it FAILs on the current code (RED, SC-22).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Make spec-creation/tasks/revise.md regenerate the exec-summary remote issue body when the spec is revised (GREEN, SC-22).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting revise regenerates the exec-summary body on revision; confirm PASS (GREEN, SC-22).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-22 (SC-22).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-22).

### Phase 20 — numbered-checkbox Workflows format

| Field | Value |
|-------|-------|
| Concern | numbered-checkbox Workflows format |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/reference/skill-card-description-standards.md`, `.opencode/skills/spec-creation/SKILL.md`, `.opencode/skills/audit/SKILL.md` |
| SCs | SC-23, SC-24, SC-35 |
| Depends On | 1, 2, 8, 9, 10 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the Workflows sections are not numbered-checkbox; confirm it FAILs on the current code (RED, SC-23, SC-24, SC-35).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Update reference/skill-card-description-standards.md §7 to specify Workflows as numbered-checkbox lists with execution-mode sub-bullets (GREEN, SC-35); convert spec-creation/SKILL.md Workflows to numbered-checkbox with execution-mode sub-bullets (GREEN, SC-23); convert audit/SKILL.md Workflows to numbered-checkbox with execution-mode sub-bullets (GREEN, SC-24).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting both Workflows sections use numbered-checkbox with execution-mode sub-bullets; confirm PASS (GREEN, SC-23, SC-24, SC-35).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-23, SC-24, SC-35 (SC-23, SC-24, SC-35).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-23, SC-24, SC-35).

### Phase 21 — numbered-checkbox task-card Procedure

| Field | Value |
|-------|-------|
| Concern | numbered-checkbox task-card Procedure |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/reference/task-card-structure-standards.md`, `.opencode/skills/spec-creation/tasks/*.md`, `.opencode/skills/audit/tasks/*.md` |
| SCs | SC-25, SC-36 |
| Depends On | 3, 4, 5, 6, 11, 12, 14 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting task-card Procedures are not numbered-checkbox; confirm it FAILs on the current code (RED, SC-25, SC-36).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Update reference/task-card-structure-standards.md to specify numbered-checkbox Procedure, clean-room unit mandate, and dispatch-contract completeness requirement (GREEN, SC-36); convert every spec-creation/audit task-card Procedure to numbered-checkbox lists (GREEN, SC-25).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting all task-card Procedures use numbered-checkbox lists; confirm PASS (GREEN, SC-25, SC-36).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-25, SC-36 (SC-25, SC-36).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-25, SC-36).

### Phase 22 — fat task-card splitting

| Field | Value |
|-------|-------|
| Concern | fat task-card splitting |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/tasks/*.md`, `.opencode/skills/audit/tasks/*.md` |
| SCs | SC-26 |
| Depends On | 21 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting a fat task card requires internal sub-agent dispatch; confirm it FAILs on the current code (RED, SC-26).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Split fat task cards whose procedures require internal sub-agent dispatch; adjust SKILL.md workflows to dispatch each split card as a separate step (GREEN, SC-26).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting no task-card procedure requires internal sub-agent dispatch; confirm PASS (GREEN, SC-26).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-26 (SC-26).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-26).

### Phase 23 — dispatch-contract completeness

| Field | Value |
|-------|-------|
| Concern | dispatch-contract completeness |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/SKILL.md`, `.opencode/skills/audit/SKILL.md`, task cards |
| SCs | SC-27 |
| Depends On | 20, 21 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting a workflow Context sub-bullet omits a task-card parameter; confirm it FAILs on the current code (RED, SC-27).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Verify dispatch-contract completeness: every workflow Context sub-bullet supplies every task-card Dispatch Contract/Entry Criteria parameter (GREEN, SC-27).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting every workflow Context sub-bullet supplies every task-card parameter; confirm PASS (GREEN, SC-27).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-27 (SC-27).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-27).

### Phase 24 — linter enforcement

| Field | Value |
|-------|-------|
| Concern | linter enforcement |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/tools/impl/skildeck/` |
| SCs | SC-28 |
| Depends On | 20, 21, 22, 23 |
| Execution Mode | Dispatched TDD + Inline opencode run (behavioral) |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the behavioral enforcement test asserting the linter does not flag a format violation (RED, SC-28).
- [ ] 2. **[INLINE — orchestrator]** Run the RED `opencode run` via the `with-test-home` wrapper; confirm the linter does not flag the format violation (FAIL) (RED, SC-28).
- [ ] 3. **[DISPATCHED — session.yaml sub-agent]** Evaluate the RED session.yaml clean-room; confirm the assertion FAILs (RED, SC-28).
- [ ] 4. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Implement the change: extend the skildeck linter to enforce numbered-checkbox workflow format, execution-mode sub-bullet, task-card clean-room unit, dispatch-contract completeness, and markdown link correctness (GREEN, SC-28).
- [ ] 5. **[INLINE — orchestrator]** Run the GREEN `opencode run` via the `with-test-home` wrapper; confirm the linter flags all new format violations (PASS) (GREEN, SC-28).
- [ ] 6. **[DISPATCHED — session.yaml sub-agent]** Evaluate the GREEN session.yaml clean-room; confirm the assertion PASSes (GREEN, SC-28).
- [ ] 7. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-28 (SC-28).
- [ ] 8. **[DISPATCHED — commit sub-agent]** Commit the change (SC-28).

### Phase 25 — markdown link correctness

| Field | Value |
|-------|-------|
| Concern | markdown link correctness |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/`, `.opencode/skills/audit/`, `.opencode/reference/`, `.opencode/skills/issue-operations-core/tasks/creation.md` |
| SCs | SC-29a, SC-29b, SC-29c |
| Depends On | 20, 21 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting a broken link or incorrect relative path exists; confirm it FAILs on the current code (RED, SC-29a, SC-29b, SC-29c).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Verify markdown links resolve to real targets (GREEN, SC-29a); use correct relative paths (GREEN, SC-29b); follow `Read [Text](path)` wording (GREEN, SC-29c).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting all links resolve to real targets with correct relative paths and `Read [Text](path)` wording; confirm PASS (GREEN, SC-29a, SC-29b, SC-29c).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-29a, SC-29b, SC-29c (SC-29a, SC-29b, SC-29c).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-29a, SC-29b, SC-29c).

### Phase 26 — workflow clarity

| Field | Value |
|-------|-------|
| Concern | workflow clarity |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/SKILL.md`, `.opencode/skills/audit/SKILL.md` |
| SCs | SC-31 |
| Depends On | 20 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting workflows lack explicit orchestrator steps; confirm it FAILs on the current code (RED, SC-31).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Make workflows explicitly orchestrator step-by-step with explicit execution-mode sub-bullets (GREEN, SC-31).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting workflows are explicitly orchestrator step-by-step with execution-mode sub-bullets; confirm PASS (GREEN, SC-31).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-31 (SC-31).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-31).

### Phase 27 — functional spec-creation pipeline

| Field | Value |
|-------|-------|
| Concern | functional spec-creation pipeline |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/tests-v2/behaviors/` (new spec-creation behavioral test) |
| SCs | SC-32 |
| Depends On | 1, 2, 3, 4, 5, 6, 7, 19, 20, 21, 22, 23, 24, 25, 26, 29 |
| Execution Mode | Dispatched TDD + Inline opencode run (behavioral) |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the behavioral enforcement test asserting the pipeline mis-routes or produces a broken spec (RED, SC-32).
- [ ] 2. **[INLINE — orchestrator]** Run the RED `opencode run` via the `with-test-home` wrapper; confirm the pipeline mis-routes or produces a broken spec (FAIL) (RED, SC-32).
- [ ] 3. **[DISPATCHED — session.yaml sub-agent]** Evaluate the RED session.yaml clean-room; confirm the assertion FAILs (RED, SC-32).
- [ ] 4. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Dispatch the full spec-creation pipeline (analyze → create → validate) end-to-end against a fixture in the shared test home; assert a valid spec with no mis-routing, no missing task cards, no broken cross-references, no deprecated dispatch strings (GREEN, SC-32).
- [ ] 5. **[INLINE — orchestrator]** Run the GREEN `opencode run` via the `with-test-home` wrapper; confirm the pipeline produces a valid spec with no mis-routing, no missing task cards, no broken cross-references, no deprecated dispatch strings (PASS) (GREEN, SC-32).
- [ ] 6. **[DISPATCHED — session.yaml sub-agent]** Evaluate the GREEN session.yaml clean-room; confirm the assertion PASSes (GREEN, SC-32).
- [ ] 7. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-32 (SC-32).
- [ ] 8. **[DISPATCHED — commit sub-agent]** Commit the change (SC-32).

### Phase 28 — functional audit DiMo chain

| Field | Value |
|-------|-------|
| Concern | functional audit DiMo chain |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/tests-v2/behaviors/` (new audit DiMo behavioral test) |
| SCs | SC-33 |
| Depends On | 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 20, 21, 22, 23, 24, 25, 26, 29 |
| Execution Mode | Dispatched TDD + Inline opencode run (behavioral) |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the behavioral enforcement test asserting the DiMo chain mis-routes a role (RED, SC-33).
- [ ] 2. **[INLINE — orchestrator]** Run the RED `opencode run` via the `with-test-home` wrapper; confirm the DiMo chain mis-routes a role (FAIL) (RED, SC-33).
- [ ] 3. **[DISPATCHED — session.yaml sub-agent]** Evaluate the RED session.yaml clean-room; confirm the assertion FAILs (RED, SC-33).
- [ ] 4. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Dispatch the audit DiMo 4-role chain (investigator → validator → evaluator → arbiter) end-to-end against a fixture spec; assert a valid verdict with each role dispatching to the correct split task card with a complete dispatch contract (GREEN, SC-33).
- [ ] 5. **[INLINE — orchestrator]** Run the GREEN `opencode run` via the `with-test-home` wrapper; confirm each role dispatches to the correct split task card with a complete dispatch contract (PASS) (GREEN, SC-33).
- [ ] 6. **[DISPATCHED — session.yaml sub-agent]** Evaluate the GREEN session.yaml clean-room; confirm the assertion PASSes (GREEN, SC-33).
- [ ] 7. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-33 (SC-33).
- [ ] 8. **[DISPATCHED — commit sub-agent]** Commit the change (SC-33).

### Phase 29 — shared test home + gitbucket

| Field | Value |
|-------|-------|
| Concern | shared test home + gitbucket |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/tests-v2/with-test-home`, `.opencode/tests-v2/behaviors/helpers.sh` |
| SCs | SC-34 |
| Depends On | — |
| Execution Mode | Dispatched TDD + Inline opencode run (behavioral) |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the behavioral enforcement test asserting the tests use separate test homes (RED, SC-34).
- [ ] 2. **[INLINE — orchestrator]** Run the RED `opencode run` via the `with-test-home` wrapper; confirm the tests use separate test homes (FAIL) (RED, SC-34).
- [ ] 3. **[DISPATCHED — session.yaml sub-agent]** Evaluate the RED session.yaml clean-room; confirm the assertion FAILs (RED, SC-34).
- [ ] 4. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Ensure spec-creation and audit behavioral tests share a common test home with a test project + test gitbucket instance, sequenced incrementally (GREEN, SC-34).
- [ ] 5. **[INLINE — orchestrator]** Run the GREEN `opencode run` via the `with-test-home` wrapper; confirm the tests share a common test home with a test project + test gitbucket instance, sequenced incrementally (PASS) (GREEN, SC-34).
- [ ] 6. **[DISPATCHED — session.yaml sub-agent]** Evaluate the GREEN session.yaml clean-room; confirm the assertion PASSes (GREEN, SC-34).
- [ ] 7. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-34 (SC-34).
- [ ] 8. **[DISPATCHED — commit sub-agent]** Commit the change (SC-34).

---

## Exit Criteria

- [ ] C1. (SC-1, Phase 1) spec-creation/SKILL.md uses canonical dispatch format with zero deprecated `execute X from Y` strings.
- [ ] C2. (SC-2, Phase 2) spec-creation/SKILL.md has no Task Files table.
- [ ] C3. (SC-17, Phase 3) analyze.md BLOCKs on unbound/placeholder issue number.
- [ ] C4. (SC-18, Phase 4) validate.md loads the 11 holistic dimensions dynamically from reference/holistic-dimensions.yaml.
- [ ] C5. (SC-19, SC-20, Phase 5) create.md routes the canonical exec-summary body with forward-reference blockquote and issues-data link.
- [ ] C6. (SC-21, Phase 6) post-push reconciliation is sequenced after push-artifacts.
- [ ] C7. (SC-37, Phase 7) issue-operations-core/tasks/creation.md Step 5 uses `tree/issues-data/N/` with `{{SPEC_PATH}}` = `N/` (no `.issues/` prefix).
- [ ] C8. (SC-3, SC-4, Phase 8) audit/SKILL.md uses a single Workflows section with 4 DiMo steps and no TDT/Invocation/Tasks sections.
- [ ] C9. (SC-7, Phase 9) audit/SKILL.md description is in canonical agent-intent format with no meta-instructions.
- [ ] C10. (SC-5, SC-6, Phase 10) audit/SKILL.md uses canonical dispatch format with zero deprecated DiMo strings.
- [ ] C11. (SC-8, SC-9, Phase 11) all 40 audit role-card frontmatter `name:` fields and `# Task:` headings match their filenames.
- [ ] C12. (SC-12, Phase 12) three subdirectory audit tasks are flattened to flat role files; stub index files removed.
- [ ] C13. (SC-14, Phase 13) behavioral-sc-evaluator.md is removed.
- [ ] C14. (SC-10, Phase 14) broken cross-references are repointed to role-split files.
- [ ] C15. (SC-11, Phase 15) stale reference-doc task names are updated to analyze/create/validate/revise.
- [ ] C16. (SC-15, Phase 16) evidence-type taxonomy citations are consolidated to the single canonical reference, loaded dynamically.
- [ ] C17. (SC-16, Phase 17) missing evidence-type declaration is a hard FAIL routed to remediation.
- [ ] C18. (SC-13, Phase 18) completion task routing is corrected; dangling verify-authorization repointed.
- [ ] C19. (SC-22, Phase 19) revise.md regenerates the exec-summary remote issue body on revision.
- [ ] C20. (SC-23, SC-24, SC-35, Phase 20) both main SKILL.md Workflows sections use numbered-checkbox lists with execution-mode sub-bullets; reference §7 specifies the format.
- [ ] C21. (SC-25, SC-36, Phase 21) all task-card Procedures use numbered-checkbox lists; reference specifies clean-room unit and dispatch-contract completeness.
- [ ] C22. (SC-26, Phase 22) no fat task cards remain; split cards dispatched as separate workflow steps.
- [ ] C23. (SC-27, Phase 23) every workflow Context sub-bullet supplies every task-card Dispatch Contract/Entry Criteria parameter.
- [ ] C24. (SC-28, Phase 24) skildeck linter enforces all new format rules.
- [ ] C25. (SC-29a, SC-29b, SC-29c, Phase 25) all markdown links resolve to real targets with correct relative paths and `Read [Text](path)` wording.
- [ ] C26. (SC-31, Phase 26) workflows are explicitly orchestrator step-by-step with explicit inline-vs-dispatch decisions.
- [ ] C27. (SC-32, Phase 27) full spec-creation pipeline runs end-to-end against a fixture in the shared test home, producing a valid spec with no mis-routing, no missing task cards, no broken cross-references, no deprecated dispatch strings.
- [ ] C28. (SC-33, Phase 28) audit DiMo 4-role chain runs end-to-end against a fixture spec, producing a valid verdict with each role dispatching to the correct split task card with a complete dispatch contract.
- [ ] C29. (SC-34, Phase 29) spec-creation and audit behavioral tests share a common test home with a test project + test gitbucket instance, sequenced incrementally.
- [ ] C30. All 38 SCs pass (SC-1..SC-37 with SC-29a/b/c).
- [ ] C31. (Execution Model) Every phase step carries an explicit Inline vs Dispatched execution mode; RED and GREEN always run in separate sub-agents; verify runs in a sub-agent different from the producer; behavioral `opencode run` (SC-17, SC-28, SC-32, SC-33, SC-34) is INLINE (orchestrator via `with-test-home`); session.yaml evaluation is DISPATCHED; no sub-agent is ever asked to dispatch another sub-agent.

---

## lifecycle_events

| timestamp | event | plan_path | phase_count |
|-----------|-------|-----------|-------------|
| 2026-08-10T04:32:47Z | plan_created | .opencode/.issues/2254/plan.md | 29 |
| 2026-08-10T10:20:00Z | plan_revised | .opencode/.issues/2254/plan.md | 29 |

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
