# [SPEC] Eat your own dogfood — fix spec-creation and writing-plans dispatch and task structure

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The spec-creation and writing-plans skills have structural defects that prevent them from being invoked correctly. Three distinct failure modes:

**Problem 1 — Dispatch bypass:** Phrases like "create a spec" or "brainstorm for a spec" don't trigger the spec-creation skill. The agent inlines the work instead — creating the issue directly via `github_issue_write` without going through the skill's pipeline (no requirements extraction, no decomposition, no traceability, no risk analysis, no write task).

**Problem 2 — Remote body format:** When the spec writer does run, the remote issue body gets the full `spec.md` content dumped into it instead of the condensed 6-part exec summary format defined in `write.md` Step 7r. The remote body should be the short exec summary; the full spec lives in `.issues/{N}/spec.md`.

**Problem 3 — Plan output lacks skill/task routing:** The plan writer produces steps with inline procedure text instead of referencing the canonical `skill({name: "..."})` → `task(..., prompt: "...")` form. Plans must be routing documents that dispatch to implementation skill task cards, not re-implementations of those procedures. The full implementation pipeline (coherence gate, pre-red-baseline, RED/GREEN per item, VbC, adversarial audit, cross-validate, regression check, finishing checklist, review-prep, cleanup) must be enumerated with no skipped or combined steps, each referencing the correct skill/task combination.

**Problem 4 — Pipeline enforcement gaps (discovered during plan creation for this spec):** The writing-plans pipeline has no structural enforcement for mandatory steps. During plan creation for this spec, the following defects occurred:
- All 7 Z3 checks were skipped with the false rationalization "no contract files found" — contract files exist at `.opencode/skills/writing-plans/contracts/` (22 YAML files)
- Step 11 (clean-room plan generation) was skipped entirely until the downstream audit-fidelity gate caught the omission
- The orchestrator self-certified the readiness gate by creating `sc-pipeline-readiness.yaml` inline instead of dispatching to the pipeline-readiness-gate task
- The write sub-agent returned DONE without writing files to disk (empty result), requiring a re-task
- `todowrite` lifecycle was not used during pipeline execution
- `pipeline_phase` was not tracked through the pipeline
- No feature branch was created for plan artifacts
- Plan files were not committed to git
- `local-issues sync` was run only once at the end, not before `.issues/` writes

Root cause analysis identified 6 defect categories across both skills, plus 9 pipeline enforcement gaps.

## Scope

**In scope:**
- spec-creation SKILL.md trigger phrase expansion and dispatch table fixes
- spec-creation write.md structural renumbering (content templates → sub-bullets, 7r ordering, duplicate labels, Pre-Step naming)
- write.md Plan Format Requirements: mandate skill/task routing in plan steps, full implementation pipeline enumeration
- writing-plans SKILL.md execution model contradiction (SKILL.md says "no task()" but create.md dispatches sub-agents)
- Missing pipeline steps (adversarial-audit dispatch, orphan task files)
- Pipeline enforcement gates: mandatory Z3 contract verification, clean-room plan generation enforcement, readiness gate independence, sub-agent output verification, todowrite lifecycle, pipeline_phase tracking, feature branch for plan artifacts, plan file commit discipline, local-issues sync discipline
- Behavioral enforcement tests for all changes

**Out of scope:**
- `skill({name: "issue-operations"})` then `task(..., prompt: "execute ... task from issue-operations")` for #1407 — separate concern
- `skill({name: "issue-operations"})` then `task(..., prompt: "execute ... task from issue-operations")` for #1208 — separate concern
- `skill({name: "issue-operations"})` then `task(..., prompt: "execute ... task from issue-operations")` for #202 — separate concern
- `skill({name: "issue-operations"})` then `task(..., prompt: "execute ... task from issue-operations")` for #211 — separate concern
- Z3 contract schema redesign (#1222) — separate concern, this spec only adds mandatory invocation of existing contracts
- Routing-only SKILL.md restructuring (#1407) — separate concern, this spec only adds enforcement within existing structure

## Approach

Five phases. Phases 1-2 are independent; Phases 3-5 depend on 2.

## Phases

### Phase 1: Trigger Phrase Expansion

**Affected files:**
- `.opencode/skills/spec-creation/SKILL.md` — description field
- `.opencode/skills/writing-plans/SKILL.md` — description field

**Changes:**
- spec-creation: Add article-variant triggers (`create a spec`, `write a spec`, `draft a spec`, `create a specification`, `write a specification`, `draft a specification`, `author a spec`, `make a spec`, `make specification`, `spec it out`)
- writing-plans: Add article-variant triggers (`create a plan`, `write a plan`, `draft a plan`, `make a plan`, `make plan`, `create an implementation plan`, `write an implementation plan`, `implementation steps`, `task list`, `break down the work`, `create the tasks`, `define the phases`)

### Phase 2: Dispatch Table Fixes (spec-creation SKILL.md)

**Affected files:**
- `.opencode/skills/spec-creation/SKILL.md` — Tasks table, Invocation section, Trigger Dispatch Table

**Changes:**
- Expand Tasks table to list all 8 task files on disk (not just `create`)
- Update Invocation section: change the canonical dispatch from `task(..., prompt: "execute create task from spec-creation")` to `task(..., prompt: "execute write task from spec-creation")` to match the actual task file `tasks/write.md`. The `skill({name: "spec-creation"})` call remains unchanged.
- Expand Trigger Dispatch Table to include all sub-tasks that the orchestrator can directly invoke via `task()`: `requirements`, `decompose`, `traceability`, `pipeline-readiness-gate`, `risk`, `write`, `completion`. Each with its own dispatch row, dispatch type (`sub-task`), and canonical `task(..., prompt: "execute <task> task from spec-creation")` string.

### Phase 3: write.md Structural Renumbering + Plan Format Requirements

**Affected files:**
- `.opencode/skills/spec-creation/tasks/write.md`

**Changes:**
- **C1: Duplicate Step 1a/1b** — Rename second `Step 1a` (Forward-Looking Mandate) to `Step 1c` and second `Step 1b` (Sub-Folder References) to `Step 1d`
- **C2: 7r before 7a ordering** — Move `Step 7r` (Remote Issue Body Format) before `Step 7` (Create Issue) since the format definition is a prerequisite to creation. Renumber `7a`/`7b`/`7c`/`7d` accordingly
- **C3: Pre-Step / Step 0.x naming** — Rename `Pre-Step`, `Pre-Step 0.8`, `Step 0.5`, `Step 0.5a` to a consistent sequential scheme
- **C4: Content templates as numbered steps** — Move Decision Ledger, Risk Traceability, Revision Policy, Decomposition Classification, Spec Family Annotation, Non-Goals, Regression Invariants, and Cross-Cutting SC Designation from numbered steps to sub-bullets under the Assemble Spec step
- **C5: Numbering gap (19a → 20)** — Re-number all step labels to a consistent scheme
- **C6: Plan Format Requirements — skill/task routing mandate** — Add to the Plan Format Requirements section of write.md that every dispatch step in a plan MUST use the canonical `skill({name: "..."})` → `task(..., prompt: "execute <task> task from <skill>")` form. Plan steps MUST NOT contain inline procedure text — the plan is a routing document, not a re-implementation of skill task cards. The full implementation pipeline must be enumerated with no skipped or combined steps, each referencing the correct skill/task combination for the appropriate implementation skill task card.

### Phase 4: writing-plans Execution Model Contradiction

**Affected files:**
- `.opencode/skills/writing-plans/SKILL.md` — Mandatory Task Discipline, Persona, Sub-Agent Routing, Operating Protocol

**Changes:**
- Remove all "no task() calls" language from SKILL.md (lines 12, 22, 71, 84, 120)
- Update Mandatory Task Discipline to state that the pipeline dispatches sub-agents for each step
- Update Persona section to reflect sub-agent dispatch model
- Update Sub-Agent Routing section to document the sub-agent dispatch pattern
- Update Operating Protocol to include dispatch indicators matching create.md's implementation

### Phase 5: Missing Pipeline Steps

**Affected files:**
- `.opencode/skills/spec-creation/SKILL.md` — Operating Protocol, Trigger Dispatch Table
- `.opencode/skills/spec-creation/tasks/write.md` — Step 40
- `.opencode/skills/writing-plans/SKILL.md` — Trigger Dispatch Table

**Changes:**
- Add step to spec-creation Operating Protocol: `task(..., prompt: "execute spec-audit task from adversarial-audit")`
- Fix write.md Step 40 to reference `skill({name: "adversarial-audit"})` then `task(..., prompt: "execute spec-audit task from adversarial-audit")` instead of `spec-auditor`
- Add dispatch path for `change-control.md` in spec-creation SKILL.md Trigger Dispatch Table and Operating Protocol
- Add dispatch path for `handoffs/spec-to-plan.md` in writing-plans SKILL.md Trigger Dispatch Table

### Phase 6: Pipeline Enforcement Gates

**Affected files:**
- `.opencode/skills/writing-plans/tasks/create.md` — Operating Protocol (add Z3 contract paths, add clean-room plan enforcement, add sub-agent output verification)
- `.opencode/skills/writing-plans/SKILL.md` — Mandatory Task Discipline (add pipeline enforcement rules)
- `.opencode/skills/writing-plans/contracts/` — 22 existing YAML contract files (no changes needed, but must be referenced correctly)

**Changes:**

- **C7: Mandatory Z3 contract verification** — Every Z3 check step in create.md MUST include the exact `solve check` command with the correct contract path. The current steps say "Z3 check — `solve check` verify ... per `contracts/create-output-template.yaml:research`" but the contract files exist at `.opencode/skills/writing-plans/contracts/`. Fix all 7 Z3 check steps to reference the correct absolute or relative path to the contract files. Add a behavioral test that verifies the agent runs `solve check` (not skips it) during pipeline execution.

- **C8: Clean-room plan generation enforcement** — Step 11 (clean-room plan generation) MUST be a mandatory gate that cannot be skipped. The orchestrator MUST NOT proceed past Step 10 without dispatching Step 11. Add a structural check: if Step 11 is skipped, the pipeline MUST halt. The clean-room sub-agent MUST receive ONLY the spec body — no existing plan context, no orchestrator reasoning.

- **C9: Readiness gate independence** — The readiness gate (Step 4) MUST read `sc-pipeline-readiness.yaml` that was created by an independent sub-agent (pipeline-readiness-gate task), NOT by the orchestrator. Add a check: if the file was created by the orchestrator (same session, no sub-agent dispatch), the gate MUST return BLOCKED. The orchestrator MUST NOT self-certify any gate.

- **C10: Sub-agent output verification** — Every sub-agent that claims to have written files MUST have those files verified on disk before the orchestrator accepts the result. Add a post-dispatch check: after every sub-agent returns DONE with a file path, run `ls` or `file-exists` to confirm the file exists. If the file does not exist, re-task clean-room (do not accept the empty result).

- **C11: Pipeline execution discipline** — Add to writing-plans Mandatory Task Discipline:
  - `todowrite` lifecycle MUST be maintained throughout pipeline execution (CREATE with status, UPDATE on transition, CLEAR before HALT)
  - `pipeline_phase` MUST be tracked and updated after each step
  - A feature branch MUST be created before any plan artifacts are written
  - Plan artifacts MUST be committed to the feature branch after creation
  - `local-issues sync` MUST be run before any `.issues/` writes and after each write

- **C12: Sequential step ordering enforcement** — Add to create.md Operating Protocol that every step with a chain dependency MUST execute sequentially. No parallel dispatch of chain-dependent steps. Each step's output is the next step's input. The "sub-agent dispatch implies independence" rationalization is explicitly prohibited. (This complements #1688 which adds the prohibition to SKILL.md.)

## local-issues sync Discipline

The `.issues/` directory is gitignored in the main branch (`.gitignore:/.issues/`) so that `git -C */..issues/` worktree operations function correctly. Persistence is handled by the `issues-data` branch via `local-issues sync`.

**`local-issues sync`** auto-commits all local `.issues/` changes to the `issues-data` branch, pulls latest, and pushes. It is the sole persistence mechanism for `.issues/` artifacts.

**Rules:**
- `local-issues sync` MUST be run before any changes are made in the `.issues/` folder
- `local-issues sync` MUST be run immediately after the local spec folder's contents are created or updated
- Any git commit that touches `.issues/` files MUST use the full `-C` path form: `git -C <repo-root> add .issues/{N}/` — never a relative path, never from inside the repo. This is because `.issues/` is gitignored in the main branch and only tracked on `issues-data`.

## Success Criteria

| ID | Phase | Criterion | Evidence Type | Verification Method |
|----|-------|-----------|---------------|---------------------|
| SC-1 | 1 | spec-creation SKILL.md description includes article-variant triggers (`create a spec`, `write a spec`, `draft a spec`, `create a specification`, `write a specification`, `draft a specification`, `author a spec`, `make a spec`, `make specification`, `spec it out`) | `string` | `grep -q "create a spec" .opencode/skills/spec-creation/SKILL.md` |
| SC-2 | 1 | writing-plans SKILL.md description includes article-variant triggers (`create a plan`, `write a plan`, `draft a plan`, `make a plan`, `make plan`, `create an implementation plan`, `write an implementation plan`, `implementation steps`, `task list`, `break down the work`, `create the tasks`, `define the phases`) | `string` | `grep -q "create a plan" .opencode/skills/writing-plans/SKILL.md` |
| SC-3 | 1 | Behavioral test: agent dispatches `skill({name: "spec-creation"})` when user says "create a spec" | `behavioral` | `opencode-cli run "create a spec for X"` → stderr shows `Skill "spec-creation"` |
| SC-4 | 1 | Behavioral test: agent dispatches `skill({name: "writing-plans"})` when user says "create a plan" | `behavioral` | `opencode-cli run "create a plan for X"` → stderr shows `Skill "writing-plans"` |
| SC-5 | 2 | spec-creation Tasks table lists all 8 task files | `string` | `grep -c "|" .opencode/skills/spec-creation/SKILL.md` for task entries |
| SC-6 | 2 | Invocation section canonical dispatch is `task(..., prompt: "execute write task from spec-creation")` (references existing `tasks/write.md`) | `string` | `grep -q "execute write task from spec-creation" .opencode/skills/spec-creation/SKILL.md` |
| SC-7 | 2 | Trigger Dispatch Table includes rows for all orchestrator-invocable sub-tasks: `requirements`, `decompose`, `traceability`, `pipeline-readiness-gate`, `risk`, `write`, `completion`. Each row includes the canonical `task(..., prompt: "execute <task> task from spec-creation")` string. | `string` | `grep -q "execute requirements task from spec-creation" .opencode/skills/spec-creation/SKILL.md` for each sub-task |
| SC-8 | 3 | No duplicate Step 1a/1b labels in write.md | `string` | `grep -c "Step 1a" .opencode/skills/spec-creation/tasks/write.md` == 1 |
| SC-9 | 3 | Step 7r (Remote Issue Body Format) appears before Step 7 (Create Issue) in write.md | `string` | Line number of "Step 7r" < line number of "Step 7: Create Issue" |
| SC-10 | 3 | No Pre-Step / Step 0.x naming in write.md — all steps use consistent sequential scheme | `string` | `grep -c "Pre-Step\|Step 0\." .opencode/skills/spec-creation/tasks/write.md` == 0 |
| SC-11 | 3 | Content templates (Decision Ledger, Risk Traceability, etc.) are sub-bullets under Assemble Spec, not numbered steps | `string` | Content template sections are indented under Step 5 (Assemble Spec) |
| SC-12 | 3 | write.md Plan Format Requirements section mandates that every dispatch step in a plan uses `skill({name: "..."})` → `task(..., prompt: "execute <task> task from <skill>")` form, and that plan steps MUST NOT contain inline procedure text | `string` | `grep -q "skill({name:" .opencode/skills/spec-creation/tasks/write.md` in Plan Format Requirements section |
| SC-13 | 3 | write.md Plan Format Requirements mandates full implementation pipeline enumeration (coherence gate, pre-red-baseline, RED/GREEN per item, VbC, adversarial audit, cross-validate, regression check, finishing checklist, review-prep, cleanup) with no skipped or combined steps | `string` | `grep -q "coherence gate" .opencode/skills/spec-creation/tasks/write.md` in Plan Format Requirements |
| SC-14 | 3 | `local-issues sync` is run before any changes are made in the `.issues/` folder, and `local-issues sync` is run immediately after the local spec folder's contents are created or updated | `behavioral` | `opencode-cli run` with spec creation prompt → stderr shows `local-issues sync` before `.issues/` writes and after spec folder content changes |
| SC-15 | 4 | writing-plans SKILL.md has no "no task() calls" language | `string` | `grep -c "no task()" .opencode/skills/writing-plans/SKILL.md` == 0 |
| SC-16 | 4 | writing-plans SKILL.md Mandatory Task Discipline states sub-agent dispatch model | `string` | `grep -q "sub-agent" .opencode/skills/writing-plans/SKILL.md` |
| SC-17 | 4 | Behavioral test: writing-plans create task dispatches sub-agents (not inline) for pipeline steps | `behavioral` | `opencode-cli run` with plan creation prompt → stderr shows task() calls |
| SC-18 | 5 | spec-creation Operating Protocol includes `task(..., prompt: "execute spec-audit task from adversarial-audit")` step | `string` | `grep -q "execute spec-audit task from adversarial-audit" .opencode/skills/spec-creation/SKILL.md` |
| SC-19 | 5 | write.md Step 40 references `skill({name: "adversarial-audit"})` then `task(..., prompt: "execute spec-audit task from adversarial-audit")` instead of `spec-auditor` | `string` | `grep -q "execute spec-audit task from adversarial-audit" .opencode/skills/spec-creation/tasks/write.md` |
| SC-20 | 5 | spec-creation SKILL.md Trigger Dispatch Table includes a row for `change-control` task with canonical dispatch string | `string` | `grep -q "change-control" .opencode/skills/spec-creation/SKILL.md` |
| SC-21 | 5 | writing-plans SKILL.md Trigger Dispatch Table includes a row for `handoffs/spec-to-plan` task with canonical dispatch string | `string` | `grep -q "spec-to-plan" .opencode/skills/writing-plans/SKILL.md` |
| SC-22 | 6 | All 7 Z3 check steps in create.md reference correct contract file paths (`.opencode/skills/writing-plans/contracts/`) | `string` | `grep -c "contracts/" .opencode/skills/writing-plans/tasks/create.md` >= 7 |
| SC-23 | 6 | Behavioral test: agent runs `solve check` during pipeline execution (does not skip Z3 steps) | `behavioral` | `opencode-cli run` with plan creation prompt → stderr shows `solve check` calls |
| SC-24 | 6 | Step 11 (clean-room plan generation) is a mandatory gate — pipeline halts if skipped | `string` | `grep -q "MUST" .opencode/skills/writing-plans/tasks/create.md` in Step 11 section |
| SC-25 | 6 | Readiness gate (Step 4) requires `sc-pipeline-readiness.yaml` created by independent sub-agent, not orchestrator | `string` | `grep -q "independent" .opencode/skills/writing-plans/tasks/create.md` in readiness section |
| SC-26 | 6 | Post-dispatch file verification: sub-agent file claims are verified on disk before acceptance | `string` | `grep -q "file-exists\|ls" .opencode/skills/writing-plans/tasks/create.md` in post-dispatch section |
| SC-27 | 6 | writing-plans Mandatory Task Discipline includes todowrite lifecycle, pipeline_phase tracking, feature branch, commit discipline, local-issues sync | `string` | `grep -q "todowrite" .opencode/skills/writing-plans/SKILL.md` in Mandatory Task Discipline |
| SC-28 | 6 | create.md Operating Protocol states sequential step ordering — no parallel dispatch of chain-dependent steps | `string` | `grep -q "sequential" .opencode/skills/writing-plans/tasks/create.md` |
| SC-29 | 6 | Behavioral test: agent does NOT skip Z3 checks when contract files exist | `behavioral` | `opencode-cli run` with plan creation prompt → stderr shows `solve check` for each Z3 step, not skipped |

## Dependencies

- Phase 1: None (independent)
- Phase 2: None (independent)
- Phase 3: Depends on Phase 2 (same file — write.md)
- Phase 4: None (independent — different skill)
- Phase 5: Depends on Phase 2 (same file — spec-creation SKILL.md)
- Phase 6: Depends on Phase 4 (same file — writing-plans SKILL.md and create.md)

## Edge Cases

- **Existing specs/plans are not affected** — trigger phrase changes only affect future invocations
- `skill({name: "issue-operations"})` then `task(..., prompt: "execute ... task from issue-operations")` for #1407 modifies the same files — coordinate merge order. This spec's Phase 2 (dispatch table expansion) is compatible with #1407's routing-only template. Implement this spec first, then #1407 will restructure the same content
- `skill({name: "issue-operations"})` then `task(..., prompt: "execute ... task from issue-operations")` for #1208 also modifies dispatch tables — this spec's Phase 2 is a subset of #1208 Workstream B. If #1208 is implemented first, Phase 2 may be partially redundant
- **Phase 6 overlaps with #1222 (Z3 contract schema)** — #1222 redesigns the contract schema and Z3 gate architecture. Phase 6 only adds mandatory invocation of existing contracts, not schema redesign. If #1222 is implemented first, Phase 6's Z3 steps may need to be updated to match the new schema. If Phase 6 is implemented first, #1222 will replace the contract paths.
- **Phase 6 overlaps with #1688 (parallel execution prohibition)** — #1688 adds the prohibition to SKILL.md Mandatory Task Discipline. Phase 6 C12 adds the same prohibition to create.md Operating Protocol. These are complementary — implement #1688 first (SKILL.md), then Phase 6 C12 (create.md).
- **Phase 6 overlaps with #1407 (routing-only SKILL.md)** — #1407 restructures SKILL.md files to remove procedure text. Phase 6 adds enforcement rules to SKILL.md Mandatory Task Discipline. If #1407 is implemented first, Phase 6's SKILL.md changes must be in the routing-only format. If Phase 6 is implemented first, #1407 will migrate the enforcement rules to the new format.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `srclight_search_symbols("spec-creation")` | Identify spec-creation skill structure |
| Direct source search | `srclight_search_symbols("writing-plans")` | Identify writing-plans skill structure |
| Local docs | `.opencode/skills/spec-creation/SKILL.md` | Analyze dispatch table, Operating Protocol, trigger phrases |
| Local docs | `.opencode/skills/spec-creation/tasks/write.md` | Analyze step numbering, content templates, 7r ordering |
| Local docs | `.opencode/skills/writing-plans/SKILL.md` | Analyze execution model contradiction |
| Local docs | `.opencode/skills/writing-plans/tasks/create.md` | Analyze sub-agent dispatch pattern |
| GitHub Issues | michael-conrad/.opencode#1208, #1407, #1560, #1558, #1564, #1562, #1669 | Cross-reference related dispatch fix specs |
| GitHub Issues | michael-conrad/opencode-config#202, #211 | Cross-reference related spec-fix issues |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

Co-authored with AI: OpenCode (deepseek-v4-flash)
