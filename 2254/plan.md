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

**Goal:** Remediate the spec-creation and audit skill card sets plus the consolidated reference standards so agents dispatch with canonical formats, resolve cross-references to real files, carry complete dispatch contracts, and route to existing task cards — proven working end-to-end, not just well-formed.

**Architecture:** Apply exactly one prescriptive resolution per finding, each mapped one-to-one to a success criterion. The plan is decomposed into 29 phases. Audit role-card surface preparation (phases 1–13) establishes the role-split task surface and inventories the defects (monolithic refs, YAML frontmatter, dispatch/result contracts, Procedure format) that the repair SCs target; Phase 14 repairs the audit monolithic cross-references (SC-40). Spec-creation surface preparation (phases 15–20) inventories the spec-creation SKILL.md/task-card surface (broken links, missing `skills/` prefix, Procedure format) that the repair SCs target. Phase 21 repairs the residual create.md format gap (SC-25) and removes YAML frontmatter from the audit role cards (SC-43). Phase 22 verifies task-card format conformance. Phase 23 repairs the audit dispatch/result contracts (SC-41, SC-42). Phase 24 extends the skildeck linter (SC-44, SC-45, SC-46). Phase 25 repairs the spec-creation broken links (SC-38, SC-39). Phase 26 verifies workflow clarity. Functional end-to-end verification (phases 27–28) is terminal and depends on all prior phases; shared test home (29) is an independent infrastructure root. Each SC follows a RED → GREEN → post-regression → verify → commit per-task cycle, with the inline-vs-dispatched boundary fixed by the Execution Model below (no sub-agent ever dispatches another sub-agent).

**Files:**
- `.opencode/skills/spec-creation/` (SKILL.md, tasks/analyze.md, tasks/create.md, tasks/validate.md, tasks/revise.md)
- `.opencode/skills/audit/` (SKILL.md, tasks/*-role.md, tasks/completion.md)
- `.opencode/skills/issue-operations-core/tasks/creation.md`
- `.opencode/skills/issue-operations/platforms/local/tasks/push-artifacts.md`
- `.opencode/reference/` (task-card-structure-standards.md, skill-card-description-standards.md, spec-structure-standards.md, holistic-dimensions.yaml)
- `.opencode/tools/impl/skildeck/`
- `.opencode/tests-v2/with-test-home`, `.opencode/tests-v2/behaviors/helpers.sh`, behavioral test scripts + fixtures

**Dispatch:** `test-driven-development` (per-SC RED → GREEN → verify → commit cycle for all phases).

**Execution Model (Inline vs Dispatched — MANDATORY):** Every step in every phase carries an explicit execution mode. The hard constraint is that **sub-agents CANNOT dispatch sub-agents** (`task: deny` is hardcoded). Therefore:

| Step | Execution Mode |
|------|----------------|
| RED — write enforcement test, confirm FAIL | DISPATCHED to a clean-room sub-agent |
| GREEN — implement, confirm PASS | DISPATCHED to a SEPARATE clean-room sub-agent (never the RED sub-agent — preserves RED/GREEN separation) |
| Verify / post-regression | DISPATCHED to a sub-agent different from the producer |
| Behavioral `opencode run` execution (SC-32, SC-33) | INLINE — orchestrator runs via bash with `with-test-home` wrapper; a sub-agent cannot dispatch this |
| session.yaml clean-room evaluation (behavioral SCs) | DISPATCHED to a clean-room sub-agent |
| Commit | DISPATCHED to a sub-agent |

**Rules:**
- **NO sub-agent is ever asked to dispatch another sub-agent.** Any step that requires running `opencode run` or dispatching a sub-agent is either INLINE (orchestrator) or a separate dispatched step — never embedded inside a sub-agent's procedure.
- Any step requiring `opencode run` is INLINE (orchestrator), never inside a sub-agent's procedure.
- Behavioral phases (24, 27, 28) split their RED/GREEN steps into: DISPATCHED (write test / implement) → INLINE (run `opencode run`) → DISPATCHED (evaluate session.yaml).
- Non-behavioral phases use the standard DISPATCHED RED → GREEN → verify → commit cycle with no inline run.
- RED and GREEN always run in separate sub-agents; verify always runs in a sub-agent different from the producer.

---

## Blast Radius

Affected files and impact zones from the blast-radius artifact:

| File | Change Type | Impact |
|------|-------------|--------|
| `.opencode/skills/spec-creation/SKILL.md` | Edit | Remove/repoint broken `docs/specs/how-to-write-good-spec-ai-agents.md` reference (SC-38) |
| `.opencode/skills/spec-creation/tasks/create.md` | Edit | Convert Procedure sub-steps to numbered-checkbox (SC-25); add `skills/` prefix to issue-operations refs (SC-39) |
| `.opencode/skills/spec-creation/tasks/revise.md` | Edit | Add `skills/` prefix to issue-operations refs (SC-39) |
| `.opencode/skills/audit/SKILL.md` | Edit | Reduce dispatch Context to each role's accepted subset, remove `pr_number` (SC-41); Returns `summary` not `finding_summary` (SC-42) |
| `.opencode/skills/audit/tasks/*-role.md` | Edit | Repoint 17 monolithic refs to role-split cards (SC-40); remove YAML frontmatter from 48 cards (SC-43) |
| `.opencode/tools/impl/skildeck/` | Edit | Extend linter for task-card link correctness (SC-44), no-YAML-frontmatter (SC-45), dispatch-contract completeness (SC-46) |
| `.opencode/tests-v2/with-test-home` | Infrastructure | Shared test home for functional tests (SC-34) |
| `.opencode/tests-v2/behaviors/helpers.sh` | Infrastructure | `__ensure_gitbucket` for test gitbucket instance (SC-34) |
| `.opencode/tests-v2/behaviors/2254-sc{32,33,34}-*.sh` | New | Behavioral test scripts + fixtures (SC-32, SC-33, SC-34) |

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
| 1 | audit role-card surface inventory | audit role-card surface | — | — | test-driven-development | Dispatched TDD |
| 2 | audit role-card frontmatter audit | audit role-card surface | — | 1 | test-driven-development | Dispatched TDD |
| 3 | audit role-card heading/name verification | audit role-card surface | — | 1 | test-driven-development | Dispatched TDD |
| 4 | audit role-card cross-reference inventory | audit role-card surface | — | 1 | test-driven-development | Dispatched TDD |
| 5 | audit role-card dispatch contract inventory | audit role-card surface | — | 1 | test-driven-development | Dispatched TDD |
| 6 | audit role-card result contract inventory | audit role-card surface | — | 1 | test-driven-development | Dispatched TDD |
| 7 | audit role-card Procedure format audit | audit role-card surface | — | 1 | test-driven-development | Dispatched TDD |
| 8 | audit role-card clean-room unit verification | audit role-card surface | — | 1 | test-driven-development | Dispatched TDD |
| 9 | audit role-card split verification | audit role-card surface | — | 1 | test-driven-development | Dispatched TDD |
| 10 | audit SKILL.md workflow inventory | audit role-card surface | — | 1 | test-driven-development | Dispatched TDD |
| 11 | audit SKILL.md dispatch contract inventory | audit role-card surface | — | 5, 10 | test-driven-development | Dispatched TDD |
| 12 | audit SKILL.md Returns contract inventory | audit role-card surface | — | 6, 10 | test-driven-development | Dispatched TDD |
| 13 | audit SKILL.md link inventory | audit role-card surface | — | 10 | test-driven-development | Dispatched TDD |
| 14 | audit monolithic cross-reference repair | audit cross-reference repair | SC-40 | 4 | test-driven-development | Dispatched TDD |
| 15 | spec-creation SKILL.md link inventory | spec-creation surface | — | — | test-driven-development | Dispatched TDD |
| 16 | spec-creation task-card reference inventory | spec-creation surface | — | — | test-driven-development | Dispatched TDD |
| 17 | spec-creation task-card Procedure format audit | spec-creation surface | — | — | test-driven-development | Dispatched TDD |
| 18 | spec-creation task-card surface verification | spec-creation surface | — | — | test-driven-development | Dispatched TDD |
| 19 | spec-creation SKILL.md workflow inventory | spec-creation surface | — | — | test-driven-development | Dispatched TDD |
| 20 | spec-creation dispatch contract inventory | spec-creation surface | — | — | test-driven-development | Dispatched TDD |
| 21 | format conformance + frontmatter removal | format conformance + frontmatter | SC-25, SC-43 | 2, 7, 17 | test-driven-development | Dispatched TDD |
| 22 | task-card format conformance verification | task-card format conformance | — | 21 | test-driven-development | Dispatched TDD |
| 23 | dispatch-contract repair | dispatch-contract repair | SC-41, SC-42 | 11, 12, 21 | test-driven-development | Dispatched TDD |
| 24 | linter extension | linter extension | SC-44, SC-45, SC-46 | 21, 22, 23 | test-driven-development | Dispatched TDD + Inline opencode run |
| 25 | spec-creation broken-link repair | spec-creation broken-link repair | SC-38, SC-39 | 15, 16, 21 | test-driven-development | Dispatched TDD |
| 26 | workflow clarity verification | workflow clarity | — | 23, 25 | test-driven-development | Dispatched TDD |
| 27 | functional spec-creation pipeline | functional spec-creation pipeline | SC-32 | 14, 21, 22, 23, 24, 25, 26, 29 | test-driven-development | Dispatched TDD + Inline opencode run |
| 28 | functional audit DiMo chain | functional audit DiMo chain | SC-33 | 14, 21, 22, 23, 24, 25, 26, 29 | test-driven-development | Dispatched TDD + Inline opencode run |
| 29 | shared test home + gitbucket | shared test home + gitbucket | SC-34 | — | test-driven-development | Dispatched TDD + Inline opencode run |

---

## Phase Details

### Phase 1 — audit role-card surface inventory

| Field | Value |
|-------|-------|
| Concern | audit role-card surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/*.md` |
| SCs | — (preparation) |
| Depends On | — |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the audit role-card surface is inventoried (enumerate role-split cards, identify the 17 monolithic references); confirm it FAILs on the current code (RED, prep for SC-40).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the audit role-card surface inventory artifact enumerating the role-split cards and the monolithic references that point to non-existent files (GREEN, prep for SC-40).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the inventory artifact is complete; confirm PASS (GREEN, prep for SC-40).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep for SC-40).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep for SC-40).

### Phase 2 — audit role-card frontmatter audit

| Field | Value |
|-------|-------|
| Concern | audit role-card surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/*.md` |
| SCs | — (preparation for SC-43) |
| Depends On | 1 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the role cards carrying YAML frontmatter are identified; confirm it FAILs on the current code (RED, prep for SC-43).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the frontmatter inventory artifact identifying the 48 audit role cards that start with `---` (GREEN, prep for SC-43).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the frontmatter inventory is complete; confirm PASS (GREEN, prep for SC-43).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep for SC-43).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep for SC-43).

### Phase 3 — audit role-card heading/name verification

| Field | Value |
|-------|-------|
| Concern | audit role-card surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/*.md` |
| SCs | — (preparation) |
| Depends On | 1 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting role-card headings are verified against filenames; confirm it FAILs on the current code (RED, prep).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the heading/name verification artifact confirming each role card's `# Task:` heading matches its filename (GREEN, prep).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the verification artifact is complete; confirm PASS (GREEN, prep).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep).

### Phase 4 — audit role-card cross-reference inventory

| Field | Value |
|-------|-------|
| Concern | audit role-card surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/*.md` |
| SCs | — (preparation for SC-40) |
| Depends On | 1 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the cross-references to monolithic task files are mapped; confirm it FAILs on the current code (RED, prep for SC-40).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the cross-reference inventory artifact mapping each monolithic reference to the actual role-split card it should point to (GREEN, prep for SC-40).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the cross-reference inventory is complete; confirm PASS (GREEN, prep for SC-40).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep for SC-40).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep for SC-40).

### Phase 5 — audit role-card dispatch contract inventory

| Field | Value |
|-------|-------|
| Concern | audit role-card surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/*.md` |
| SCs | — (preparation for SC-41) |
| Depends On | 1 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting each role card's Dispatch Contract accepted params are inventoried; confirm it FAILs on the current code (RED, prep for SC-41).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the dispatch-contract inventory artifact enumerating each role card's accepted Dispatch Contract params (GREEN, prep for SC-41).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the dispatch-contract inventory is complete; confirm PASS (GREEN, prep for SC-41).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep for SC-41).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep for SC-41).

### Phase 6 — audit role-card result contract inventory

| Field | Value |
|-------|-------|
| Concern | audit role-card surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/*.md` |
| SCs | — (preparation for SC-42) |
| Depends On | 1 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting each role card's Result Contract field names are inventoried; confirm it FAILs on the current code (RED, prep for SC-42).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the result-contract inventory artifact enumerating each role card's Result Contract field names (e.g., `summary`) (GREEN, prep for SC-42).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the result-contract inventory is complete; confirm PASS (GREEN, prep for SC-42).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep for SC-42).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep for SC-42).

### Phase 7 — audit role-card Procedure format audit

| Field | Value |
|-------|-------|
| Concern | audit role-card surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/*.md` |
| SCs | — (preparation for SC-25) |
| Depends On | 1 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting task-card Procedures using plain numbered lists are identified; confirm it FAILs on the current code (RED, prep for SC-25).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the Procedure-format inventory artifact identifying task cards whose Procedure sections use plain numbered lists instead of numbered-checkbox (GREEN, prep for SC-25).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the Procedure-format inventory is complete; confirm PASS (GREEN, prep for SC-25).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep for SC-25).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep for SC-25).

### Phase 8 — audit role-card clean-room unit verification

| Field | Value |
|-------|-------|
| Concern | audit role-card surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/*.md` |
| SCs | — (preparation) |
| Depends On | 1 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting no role card's procedure requires internal sub-agent dispatch; confirm it FAILs on the current code (RED, prep).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the clean-room unit verification artifact confirming no role card dispatches sub-agents internally (GREEN, prep).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the clean-room verification artifact is complete; confirm PASS (GREEN, prep).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep).

### Phase 9 — audit role-card split verification

| Field | Value |
|-------|-------|
| Concern | audit role-card surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/*.md` |
| SCs | — (preparation) |
| Depends On | 1 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the audit role cards are role-split (investigator/validator/evaluator/arbiter); confirm it FAILs on the current code (RED, prep).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the split verification artifact confirming the role cards are organized as role-split cards (GREEN, prep).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the split verification artifact is complete; confirm PASS (GREEN, prep).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep).

### Phase 10 — audit SKILL.md workflow inventory

| Field | Value |
|-------|-------|
| Concern | audit role-card surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/SKILL.md` |
| SCs | — (preparation) |
| Depends On | 1 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the `Run an audit` Workflows section steps are inventoried; confirm it FAILs on the current code (RED, prep).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the workflow inventory artifact enumerating the `Run an audit` Workflows steps (GREEN, prep).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the workflow inventory is complete; confirm PASS (GREEN, prep).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep).

### Phase 11 — audit SKILL.md dispatch contract inventory

| Field | Value |
|-------|-------|
| Concern | audit role-card surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/SKILL.md` |
| SCs | — (preparation for SC-41) |
| Depends On | 5, 10 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the Context passed to each role in the `Run an audit` Workflows section is inventoried; confirm it FAILs on the current code (RED, prep for SC-41).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the dispatch-contract inventory artifact enumerating the Context params passed to each role (e.g., the 21-param union) and cross-referencing against each role's accepted subset (GREEN, prep for SC-41).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the dispatch-contract inventory is complete; confirm PASS (GREEN, prep for SC-41).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep for SC-41).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep for SC-41).

### Phase 12 — audit SKILL.md Returns contract inventory

| Field | Value |
|-------|-------|
| Concern | audit role-card surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/SKILL.md` |
| SCs | — (preparation for SC-42) |
| Depends On | 6, 10 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the Returns field names in the `Run an audit` Workflows section are inventoried; confirm it FAILs on the current code (RED, prep for SC-42).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the Returns-contract inventory artifact enumerating the Returns field names (e.g., `finding_summary`) and cross-referencing against the role cards' Result Contract field names (e.g., `summary`) (GREEN, prep for SC-42).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the Returns-contract inventory is complete; confirm PASS (GREEN, prep for SC-42).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep for SC-42).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep for SC-42).

### Phase 13 — audit SKILL.md link inventory

| Field | Value |
|-------|-------|
| Concern | audit role-card surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/SKILL.md` |
| SCs | — (preparation) |
| Depends On | 10 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the markdown links in audit/SKILL.md are inventoried; confirm it FAILs on the current code (RED, prep).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the link inventory artifact enumerating the markdown links in audit/SKILL.md and their resolution status (GREEN, prep).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the link inventory is complete; confirm PASS (GREEN, prep).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep).

### Phase 14 — audit monolithic cross-reference repair

| Field | Value |
|-------|-------|
| Concern | audit cross-reference repair |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/*.md` |
| SCs | SC-40 |
| Depends On | 4 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the 17 monolithic task-file references in `audit/tasks/*.md` are absent; confirm it FAILs on the current code (RED, SC-40).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Remove or repoint the 17 monolithic references (e.g., `tasks/verification-audit.md`, `tasks/drift-detection.md`, `tasks/spec-audit.md`, `tasks/plan-fidelity.md`) to the actual role-split cards on disk (GREEN, SC-40).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting no monolithic reference resolves to a non-existent file; confirm PASS (GREEN, SC-40).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-40 (SC-40).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-40).

### Phase 15 — spec-creation SKILL.md link inventory

| Field | Value |
|-------|-------|
| Concern | spec-creation surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/SKILL.md` |
| SCs | — (preparation for SC-38) |
| Depends On | — |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the markdown links in spec-creation/SKILL.md are inventoried; confirm it FAILs on the current code (RED, prep for SC-38).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the link inventory artifact enumerating the markdown links in spec-creation/SKILL.md and their resolution status, including the broken `docs/specs/how-to-write-good-spec-ai-agents.md` reference (GREEN, prep for SC-38).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the link inventory is complete; confirm PASS (GREEN, prep for SC-38).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep for SC-38).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep for SC-38).

### Phase 16 — spec-creation task-card reference inventory

| Field | Value |
|-------|-------|
| Concern | spec-creation surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/tasks/create.md`, `.opencode/skills/spec-creation/tasks/revise.md` |
| SCs | — (preparation for SC-39) |
| Depends On | — |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the issue-operations references in create.md and revise.md are inventoried; confirm it FAILs on the current code (RED, prep for SC-39).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the reference inventory artifact enumerating the `issue-operations-core/tasks/creation.md` and `issue-operations/platforms/local/tasks/push-artifacts.md` references and their missing `skills/` prefix (GREEN, prep for SC-39).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the reference inventory is complete; confirm PASS (GREEN, prep for SC-39).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep for SC-39).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep for SC-39).

### Phase 17 — spec-creation task-card Procedure format audit

| Field | Value |
|-------|-------|
| Concern | spec-creation surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/tasks/*.md` |
| SCs | — (preparation for SC-25) |
| Depends On | — |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the plain-numbered-list Procedures in spec-creation task cards are identified; confirm it FAILs on the current code (RED, prep for SC-25).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the Procedure-format inventory artifact identifying create.md's plain-numbered-list sub-steps (Step 3, Step 3.1, Step 3.2, Step 6, Step 7) (GREEN, prep for SC-25).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the Procedure-format inventory is complete; confirm PASS (GREEN, prep for SC-25).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep for SC-25).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep for SC-25).

### Phase 18 — spec-creation task-card surface verification

| Field | Value |
|-------|-------|
| Concern | spec-creation surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/tasks/*.md` |
| SCs | — (preparation) |
| Depends On | — |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the spec-creation task cards are verified to exist; confirm it FAILs on the current code (RED, prep).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the task-card surface verification artifact confirming analyze.md, create.md, validate.md, and revise.md exist and are well-formed (GREEN, prep).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the task-card surface verification artifact is complete; confirm PASS (GREEN, prep).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep).

### Phase 19 — spec-creation SKILL.md workflow inventory

| Field | Value |
|-------|-------|
| Concern | spec-creation surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/SKILL.md` |
| SCs | — (preparation) |
| Depends On | — |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the spec-creation Workflows steps are inventoried; confirm it FAILs on the current code (RED, prep).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the workflow inventory artifact enumerating the spec-creation Workflows steps (GREEN, prep).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the workflow inventory is complete; confirm PASS (GREEN, prep).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep).

### Phase 20 — spec-creation dispatch contract inventory

| Field | Value |
|-------|-------|
| Concern | spec-creation surface |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/SKILL.md` |
| SCs | — (preparation) |
| Depends On | — |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the dispatch contracts in the spec-creation Workflows section are inventoried; confirm it FAILs on the current code (RED, prep).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the dispatch-contract inventory artifact enumerating the Context passed to each spec-creation task (GREEN, prep).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting the dispatch-contract inventory is complete; confirm PASS (GREEN, prep).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep).

### Phase 21 — format conformance + frontmatter removal

| Field | Value |
|-------|-------|
| Concern | format conformance + frontmatter |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/tasks/create.md`, `.opencode/skills/audit/tasks/*.md` |
| SCs | SC-25, SC-43 |
| Depends On | 2, 7, 17 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting create.md's Procedure sub-steps (Step 3, Step 3.1, Step 3.2, Step 6, Step 7) still use plain numbered lists and that audit role cards still carry YAML frontmatter; confirm it FAILs on the current code (RED, SC-25, SC-43).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Convert the plain numbered lists in create.md's Procedure sub-steps to numbered-checkbox lists (`- [ ] N.`) (GREEN, SC-25); remove the YAML frontmatter from the 48 audit role cards that start with `---` (GREEN, SC-43).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting no plain numbered lists remain in create.md's Procedure sub-steps and no audit role card starts with `---`; confirm PASS (GREEN, SC-25, SC-43).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-25, SC-43 (SC-25, SC-43).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-25, SC-43).

### Phase 22 — task-card format conformance verification

| Field | Value |
|-------|-------|
| Concern | task-card format conformance |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/tasks/*.md`, `.opencode/skills/audit/tasks/*.md` |
| SCs | — (preparation for SC-44) |
| Depends On | 21 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting all task-card Procedures in spec-creation and audit conform to numbered-checkbox; confirm it FAILs on the current code (RED, prep for SC-44).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the format-conformance verification artifact confirming every task-card Procedure in spec-creation and audit uses numbered-checkbox lists (GREEN, prep for SC-44).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting all task-card Procedures conform; confirm PASS (GREEN, prep for SC-44).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep for SC-44).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep for SC-44).

### Phase 23 — dispatch-contract repair

| Field | Value |
|-------|-------|
| Concern | dispatch-contract repair |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/SKILL.md` |
| SCs | SC-41, SC-42 |
| Depends On | 11, 12, 21 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the `Run an audit` Workflows section still passes the 21-param union and returns `finding_summary`; confirm it FAILs on the current code (RED, SC-41, SC-42).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Reduce the Context passed to each role to its accepted subset and remove `pr_number` where no task card accepts it (GREEN, SC-41); change the Returns contracts to use `summary` matching the task cards' Result Contracts (GREEN, SC-42).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting no over-supplied/unconsumed params and Returns field names match the task cards' Result Contracts; confirm PASS (GREEN, SC-41, SC-42).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-41, SC-42 (SC-41, SC-42).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-41, SC-42).

### Phase 24 — linter extension

| Field | Value |
|-------|-------|
| Concern | linter extension |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/tools/impl/skildeck/` |
| SCs | SC-44, SC-45, SC-46 |
| Depends On | 21, 22, 23 |
| Execution Mode | Dispatched TDD + Inline opencode run (behavioral) |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the behavioral enforcement test asserting the linter does not flag broken task-card links, task-card YAML frontmatter, or dispatch-contract mismatches (RED, SC-44, SC-45, SC-46).
- [ ] 2. **[INLINE — orchestrator]** Run the RED `opencode run` via the `with-test-home` wrapper; confirm the linter does not flag the three defect classes (FAIL) (RED, SC-44, SC-45, SC-46).
- [ ] 3. **[DISPATCHED — session.yaml sub-agent]** Evaluate the RED session.yaml clean-room; confirm the assertion FAILs (RED, SC-44, SC-45, SC-46).
- [ ] 4. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Extend skildeck-lint to enforce broken markdown-link targets across task cards (SC-44), the no-YAML-frontmatter-on-task-cards rule (SC-45), and dispatch-contract completeness including result-contract field-name matching and no over-supplied/unconsumed context params (SC-46) (GREEN, SC-44, SC-45, SC-46).
- [ ] 5. **[INLINE — orchestrator]** Run the GREEN `opencode run` via the `with-test-home` wrapper; confirm the linter flags all three defect classes (PASS) (GREEN, SC-44, SC-45, SC-46).
- [ ] 6. **[DISPATCHED — session.yaml sub-agent]** Evaluate the GREEN session.yaml clean-room; confirm the assertion PASSes (GREEN, SC-44, SC-45, SC-46).
- [ ] 7. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-44, SC-45, SC-46 (SC-44, SC-45, SC-46).
- [ ] 8. **[DISPATCHED — commit sub-agent]** Commit the change (SC-44, SC-45, SC-46).

### Phase 25 — spec-creation broken-link repair

| Field | Value |
|-------|-------|
| Concern | spec-creation broken-link repair |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/SKILL.md`, `.opencode/skills/spec-creation/tasks/create.md`, `.opencode/skills/spec-creation/tasks/revise.md` |
| SCs | SC-38, SC-39 |
| Depends On | 15, 16, 21 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the broken `docs/specs/how-to-write-good-spec-ai-agents.md` reference and the missing `skills/` prefix in create.md/revise.md remain; confirm it FAILs on the current code (RED, SC-38, SC-39).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Remove or repoint the broken reference in spec-creation/SKILL.md and ensure every markdown link in the file resolves (GREEN, SC-38); add the `skills/` prefix to the `issue-operations-core/tasks/creation.md` and `issue-operations/platforms/local/tasks/push-artifacts.md` references in create.md and revise.md (GREEN, SC-39).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting no broken reference remains and all issue-operations references resolve under `.opencode/skills/`; confirm PASS (GREEN, SC-38, SC-39).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS against SC-38, SC-39 (SC-38, SC-39).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (SC-38, SC-39).

### Phase 26 — workflow clarity verification

| Field | Value |
|-------|-------|
| Concern | workflow clarity |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/SKILL.md`, `.opencode/skills/audit/SKILL.md` |
| SCs | — (preparation for SC-32, SC-33) |
| Depends On | 23, 25 |
| Execution Mode | Dispatched TDD |

**Procedure (execution mode per step):**
- [ ] 1. **[DISPATCHED — RED sub-agent]** Write the RED enforcement test asserting the spec-creation and audit Workflows sections are not explicitly orchestrator step-by-step; confirm it FAILs on the current code (RED, prep for SC-32, SC-33).
- [ ] 2. **[DISPATCHED — GREEN sub-agent (separate from RED)]** Produce the workflow-clarity verification artifact confirming both Workflows sections are explicitly orchestrator step-by-step with explicit execution-mode sub-bullets (GREEN, prep for SC-32, SC-33).
- [ ] 3. **[DISPATCHED — GREEN sub-agent]** Run the GREEN enforcement test asserting both Workflows sections are explicitly orchestrator step-by-step; confirm PASS (GREEN, prep for SC-32, SC-33).
- [ ] 4. **[DISPATCHED — verification sub-agent (different from producer)]** Run post-regression and verify PASS (prep for SC-32, SC-33).
- [ ] 5. **[DISPATCHED — commit sub-agent]** Commit the change (prep for SC-32, SC-33).

### Phase 27 — functional spec-creation pipeline

| Field | Value |
|-------|-------|
| Concern | functional spec-creation pipeline |
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/tests-v2/behaviors/` (new spec-creation behavioral test) |
| SCs | SC-32 |
| Depends On | 14, 21, 22, 23, 24, 25, 26, 29 |
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
| Depends On | 14, 21, 22, 23, 24, 25, 26, 29 |
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

- [ ] C1. (SC-40, Phase 14) all 17 monolithic task-file references in `audit/tasks/*.md` are removed or repointed to the actual role-split cards on disk.
- [ ] C2. (SC-25, SC-43, Phase 21) create.md's Procedure sub-steps use numbered-checkbox lists; no audit role card starts with YAML frontmatter.
- [ ] C3. (SC-41, SC-42, Phase 23) the `Run an audit` Workflows dispatch contracts pass exactly each role's accepted subset (no `pr_number` where unaccepted) and the Returns fields use `summary`.
- [ ] C4. (SC-44, SC-45, SC-46, Phase 24) skildeck-lint enforces task-card link correctness, no-YAML-frontmatter-on-task-cards, and dispatch-contract completeness.
- [ ] C5. (SC-38, SC-39, Phase 25) spec-creation/SKILL.md has no broken reference and all markdown links resolve; create.md/revise.md issue-operations references carry the correct `skills/` prefix.
- [ ] C6. (SC-32, Phase 27) full spec-creation pipeline runs end-to-end against a fixture in the shared test home, producing a valid spec with no mis-routing, no missing task cards, no broken cross-references, no deprecated dispatch strings.
- [ ] C7. (SC-33, Phase 28) audit DiMo 4-role chain runs end-to-end against a fixture spec, producing a valid verdict with each role dispatching to the correct split task card with a complete dispatch contract.
- [ ] C8. (SC-34, Phase 29) spec-creation and audit behavioral tests share a common test home with a test project + test gitbucket instance, sequenced incrementally.
- [ ] C9. All 13 SCs pass (SC-25, SC-32, SC-33, SC-34, SC-38, SC-39, SC-40, SC-41, SC-42, SC-43, SC-44, SC-45, SC-46).
- [ ] C10. (Execution Model) Every phase step carries an explicit Inline vs Dispatched execution mode; RED and GREEN always run in separate sub-agents; verify runs in a sub-agent different from the producer; behavioral `opencode run` (SC-32, SC-33) is INLINE (orchestrator via `with-test-home`); session.yaml evaluation is DISPATCHED; no sub-agent is ever asked to dispatch another sub-agent.

---

## lifecycle_events

| timestamp | event | plan_path | phase_count |
|-----------|-------|-----------|-------------|
| 2026-08-10T04:32:47Z | plan_created | .opencode/.issues/2254/plan.md | 29 |
| 2026-08-10T10:20:00Z | plan_revised | .opencode/.issues/2254/plan.md | 29 |
| 2026-08-15T21:00:00Z | plan_revised | .opencode/.issues/2254/plan.md | 29 |

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
