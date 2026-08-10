---
plan_schema_version: 1
issue: 2254
title: "Remediate spec-creation and audit skill cards plus reference standards"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 7
dispatch: [test-driven-development]
---

# Implementation Plan — #2254 — Remediate spec-creation and audit skill cards plus reference standards

**Issue:** [.opencode#2254](https://github.com/michael-conrad/.opencode/issues/2254)

**Goal:** Remediate the spec-creation and audit skill card sets plus the consolidated reference standards so agents dispatch with canonical formats, resolve cross-references to real files, read the taxonomy and dimensions from canonical sources, and route to existing task cards — proven working end-to-end, not just well-formed.

**Architecture:** Apply exactly one prescriptive resolution per finding, each mapped one-to-one to a success criterion. Seven phases: (1) spec-creation dispatch + task precondition fixes, (2) audit skill structure + role cards, (3) cross-references + taxonomy, (4) completion routing, (5) revise exec-summary regeneration, (6) format conformance + linter + links, (7) functional end-to-end verification. Phases 1 and 2 are independent roots; phases 3/4 depend on phase 2; phase 5 depends on phase 1; phase 6 depends on phases 1+2; phase 7 (terminal) depends on all six prior phases. Each SC follows a RED → GREEN → post-regression → verify → commit per-task cycle.

**Files:**
- `.opencode/skills/spec-creation/` (SKILL.md, tasks/analyze.md, tasks/create.md, tasks/validate.md, tasks/revise.md)
- `.opencode/skills/audit/` (SKILL.md, tasks/*-role.md, tasks/completion.md, removed behavioral-sc-evaluator.md, flattened subdirectory task sets)
- `.opencode/skills/issue-operations-core/tasks/creation.md`
- `.opencode/reference/` (spec-structure-standards.md, holistic-dimensions.yaml, skill-card-description-standards.md, task-card-structure-standards.md, cost-model-standards.md)
- `.opencode/tools/impl/skildeck/`
- `.opencode/tests-v2/with-test-home`, `.opencode/tests-v2/behaviors/helpers.sh`, new behavioral test scripts + fixtures

**Dispatch:** `test-driven-development` (per-SC RED/GREEN/verify/commit cycle for all phases)

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

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | spec-creation dispatch + task precondition fixes | Canonical dispatch format, remove Task Files table, analyze issue anchoring, dynamic dimension loading, create exec-summary body + forward-reference, post-push reconciliation, issues-data URL root-cause fix | SC-1, SC-2, SC-17, SC-18, SC-19, SC-20, SC-21, SC-37 | — | 1–24 | test-driven-development |
| 2 | audit skill structure + role cards | Single Workflows section, remove TDT/Invocation/Tasks, canonical dispatch, rewrite description, repair role-card names/headings, flatten subdirectory tasks, remove redundant evaluator | SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-12, SC-14 | — | 25–51 | test-driven-development |
| 3 | cross-references + taxonomy | Repoint cross-references to role-split files, update reference task names, consolidate taxonomy citations, missing-type hard FAIL rule | SC-10, SC-11, SC-15, SC-16 | 2 | 52–63 | test-driven-development |
| 4 | completion routing | Correct completion task routing, repoint dangling verify-authorization | SC-13 | 2 | 64–67 | test-driven-development |
| 5 | revise exec-summary regeneration | Revise task regenerates exec-summary remote issue body on revision | SC-22 | 1 | 68–71 | test-driven-development |
| 6 | format conformance + linter + links | Reference-doc format updates, skill-card and task-card numbered-checkbox conformance, split fat task cards, dispatch-contract completeness, extend skildeck linter, verify markdown links, explicit orchestrator workflow steps | SC-23, SC-24, SC-25, SC-26, SC-27, SC-28, SC-29a, SC-29b, SC-29c, SC-31, SC-35, SC-36 | 1, 2 | 72–107 | test-driven-development |
| 7 | functional end-to-end verification | Shared test home with test project + test gitbucket instance; run spec-creation pipeline and audit DiMo chain end-to-end against fixture; incremental sequencing | SC-32, SC-33, SC-34 | 1, 2, 3, 4, 5, 6 | 108–119 | test-driven-development |

---

## Phase Details

### Phase 1 — spec-creation dispatch + task precondition fixes

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/SKILL.md`, `tasks/{analyze,create,validate}.md`, `.opencode/skills/issue-operations-core/tasks/creation.md` |
| SCs | SC-1, SC-2, SC-17, SC-18, SC-19, SC-20, SC-21, SC-37 |
| Depends On | — |

**Context:**
- Convert 6 deprecated `execute X from Y` dispatch prompts in spec-creation/SKILL.md to canonical `Follow the instructions in [<skill>/tasks/<task>.md](...)` format (SC-1)
- Remove the redundant `## Task Files` table from spec-creation/SKILL.md (SC-2)
- Add analyze.md BLOCK on unbound/placeholder issue number (SC-17, behavioral)
- Make validate.md load 11 holistic dimensions dynamically from reference/holistic-dimensions.yaml (SC-18)
- Route create.md remote issue body to canonical exec-summary body format per issue-operations-core/tasks/creation.md Step 5 (SC-19)
- Add forward-reference Spec Reference Blockquote / issues-data link to create.md remote body (SC-20)
- Sequence post-push reconciliation after issue-operations/platforms/local/tasks/push-artifacts.md (SC-21)
- Fix issues-data URL template in issue-operations-core/tasks/creation.md Step 5: `tree/issues-data/N/`, `{{SPEC_PATH}}` = `N/` (SC-37)

### Phase 2 — audit skill structure + role cards

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/SKILL.md`, `tasks/*-role.md`, removed `behavioral-sc-evaluator.md`, flattened subdirectory task sets |
| SCs | SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-12, SC-14 |
| Depends On | — |

**Context:**
- Convert audit/SKILL.md to single Workflows section with 4 DiMo steps (SC-3)
- Remove TDT/Invocation/Tasks sections from audit/SKILL.md (SC-4)
- Convert audit dispatch to canonical format (SC-5)
- Remove deprecated `execute <task> DiMo <role> from audit` strings (SC-6)
- Rewrite audit description to canonical agent-intent format (SC-7, semantic)
- Repair 40 role-card frontmatter `name:` fields to match filenames (SC-8)
- Repair role-card `# Task:` headings to match filenames (SC-9)
- Flatten three subdirectory audit tasks (closure-verification/, coherence-extraction/, spec-summary/) to flat role files and remove stub index files (SC-12)
- Remove redundant behavioral-sc-evaluator.md (SC-14)

### Phase 3 — cross-references + taxonomy

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/*-role.md`, `.opencode/reference/spec-structure-standards.md`, `.opencode/skills/spec-creation/tasks/analyze.md` |
| SCs | SC-10, SC-11, SC-15, SC-16 |
| Depends On | 2 |

**Context:**
- Repoint broken cross-references to non-existent monolithic role-task files (tasks/spec-audit.md, tasks/plan-fidelity.md) to actual role-split files, including reference/holistic-dimensions.yaml (SC-10)
- Update stale reference-doc task names (inspect/decompose/write/check/file) to actual names (analyze/create/validate/revise) in reference/skill-card-description-standards.md (SC-11)
- Point evidence-type taxonomy citations in spec-creation validate and audit role cards at the single canonical reference, loaded dynamically (SC-15)
- Make missing evidence-type declaration a hard FAIL routed to remediation in reference/spec-structure-standards.md (SC-16, semantic)

### Phase 4 — completion routing

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/audit/tasks/completion.md` |
| SCs | SC-13 |
| Depends On | 2 |

**Context:**
- Correct audit/tasks/completion.md routing to the actual 3-step verify-authorization workflow; remove dangling `approval-gate --task verify-authorization` reference (SC-13)

### Phase 5 — revise exec-summary regeneration

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/skills/spec-creation/tasks/revise.md` |
| SCs | SC-22 |
| Depends On | 1 |

**Context:**
- Make spec-creation/tasks/revise.md regenerate the exec-summary remote issue body when the spec is revised (SC-22)

### Phase 6 — format conformance + linter + links

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/reference/skill-card-description-standards.md`, `.opencode/reference/task-card-structure-standards.md`, `.opencode/skills/spec-creation/SKILL.md`, `.opencode/skills/audit/SKILL.md`, `tasks/*.md`, `.opencode/tools/impl/skildeck/` |
| SCs | SC-23, SC-24, SC-25, SC-26, SC-27, SC-28, SC-29a, SC-29b, SC-29c, SC-31, SC-35, SC-36 |
| Depends On | 1, 2 |

**Context:**
- Update reference/skill-card-description-standards.md §7 to specify Workflows as numbered-checkbox lists with execution-mode sub-bullets (SC-35)
- Update reference/task-card-structure-standards.md to specify numbered-checkbox Procedure, clean-room unit mandate, dispatch-contract completeness requirement (SC-36)
- Convert spec-creation/SKILL.md Workflows to numbered-checkbox with execution-mode sub-bullets (SC-23)
- Convert audit/SKILL.md Workflows to numbered-checkbox with execution-mode sub-bullets (SC-24)
- Convert every spec-creation/audit task-card Procedure to numbered-checkbox lists (SC-25)
- Split fat task cards whose procedures require internal sub-agent dispatch; adjust SKILL.md workflows to dispatch each split card as a separate step (SC-26, semantic)
- Verify dispatch-contract completeness: every workflow Context sub-bullet supplies every task-card Dispatch Contract/Entry Criteria parameter (SC-27, semantic)
- Extend skildeck linter to enforce numbered-checkbox workflow format, execution-mode sub-bullet, task-card clean-room unit, dispatch-contract completeness, markdown link correctness (SC-28, behavioral)
- Verify markdown links resolve to real targets (SC-29a)
- Verify markdown links use correct relative paths (SC-29b)
- Verify markdown links follow `Read [Text](path)` wording (SC-29c)
- Make workflows explicitly orchestrator step-by-step with explicit execution-mode sub-bullets (SC-31)

### Phase 7 — functional end-to-end verification

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` (per-SC RED/GREEN/verify/commit cycle) |
| Target | `.opencode/tests-v2/with-test-home`, `.opencode/tests-v2/behaviors/helpers.sh`, new behavioral test scripts + fixtures |
| SCs | SC-32, SC-33, SC-34 |
| Depends On | 1, 2, 3, 4, 5, 6 |

**Context:**
- Dispatch full spec-creation pipeline (analyze → create → validate) end-to-end against fixture in shared test home; assert valid spec with no mis-routing, no missing task cards, no broken cross-references, no deprecated dispatch strings (SC-32, behavioral)
- Dispatch audit DiMo 4-role chain (investigator → validator → evaluator → arbiter) end-to-end against fixture spec; assert valid verdict with each role dispatching to correct split task card with complete dispatch contract (SC-33, behavioral)
- Ensure spec-creation and audit behavioral tests share a common test home with test project + test gitbucket instance, sequenced incrementally (SC-34, behavioral)

---

## Exit Criteria

- [ ] C1. spec-creation/SKILL.md uses canonical dispatch format with zero deprecated `execute X from Y` strings and no Task Files table
- [ ] C2. audit/SKILL.md uses a single Workflows section with 4 DiMo steps, no TDT/Invocation/Tasks sections, canonical dispatch format, no deprecated DiMo strings, and a canonical agent-intent description
- [ ] C3. All 40 audit role-card frontmatter `name:` fields and `# Task:` headings match their filenames
- [ ] C4. Broken cross-references repointed to role-split files; stale reference-doc task names updated; taxonomy citations consolidated to single canonical reference; missing evidence-type is hard FAIL
- [ ] C5. Three subdirectory audit tasks flattened to flat role files; stub index files and behavioral-sc-evaluator.md removed
- [ ] C6. Completion task routing corrected; dangling verify-authorization repointed
- [ ] C7. analyze BLOCKs on unbound/placeholder issue number; validate loads 11 dimensions dynamically; create routes canonical exec-summary body with forward-reference blockquote and post-push reconciliation; revise regenerates exec-summary body
- [ ] C8. Both main SKILL.md Workflows sections and all task-card Procedures use numbered-checkbox lists with execution-mode sub-bullets; no fat task cards; dispatch contracts complete
- [ ] C9. skildeck linter enforces all new format rules
- [ ] C10. All markdown links in the two skills, reference docs, and issue-operations-core/tasks/creation.md resolve to real targets with correct relative paths and `Read [Text](path)` wording
- [ ] C11. Workflows explicitly orchestrator step-by-step with explicit inline-vs-dispatch decisions
- [ ] C12. Reference docs (skill-card-description-standards.md §7, task-card-structure-standards.md) specify the numbered-checkbox format with execution-mode indicator, clean-room unit mandate, and dispatch-contract completeness requirement
- [ ] C13. issue-operations-core/tasks/creation.md Step 5 uses `tree/issues-data/N/` with `{{SPEC_PATH}}` = `N/` (no `.issues/` prefix)
- [ ] C14. Full spec-creation pipeline and audit DiMo chain run end-to-end against fixture in shared test home with test gitbucket instance, producing valid output with no mis-routing, no missing task cards, no broken cross-references, no deprecated dispatch strings
- [ ] C15. All 38 SCs pass (SC-1..SC-37 with SC-29a/b/c)

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
