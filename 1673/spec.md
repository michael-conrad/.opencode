# [SPEC] Eat your own dogfood — fix spec-creation and writing-plans dispatch and task structure

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The spec-creation and writing-plans skills have structural defects that prevent them from being invoked correctly. Two distinct failure modes:

**Problem 1 — Dispatch bypass:** Phrases like "create a spec" or "brainstorm for a spec" don't trigger the spec-creation skill. The agent inlines the work instead — creating the issue directly via `github_issue_write` without going through the skill's pipeline (no requirements extraction, no decomposition, no traceability, no risk analysis, no write task).

**Problem 2 — Remote body format:** When the spec writer does run, the remote issue body gets the full `spec.md` content dumped into it instead of the condensed 6-part exec summary format defined in `write.md` Step 7r. The remote body should be the short exec summary; the full spec lives in `.issues/{N}/spec.md`.

Root cause analysis identified 5 defect categories across both skills.

## Scope

**In scope:**
- spec-creation SKILL.md trigger phrase expansion and dispatch table fixes
- spec-creation write.md structural renumbering (content templates → sub-bullets, 7r ordering, duplicate labels, Pre-Step naming)
- writing-plans SKILL.md execution model contradiction (SKILL.md says "no task()" but create.md dispatches sub-agents)
- Missing pipeline steps (adversarial-audit dispatch, orphan task files)
- Behavioral enforcement tests for all changes

**Out of scope:**
- #1407 (routing-only SKILL.md restructure) — separate concern, modifies same files
- #1208 (5-workstream dispatch table overhaul) — separate concern, broader scope
- #202 (micro-management prohibition) — separate spec-fix
- #211 (BLOCK directives for missing spec files) — separate spec-fix

## Approach

Five phases, each addressing one defect category. Phases 1-2 are independent; Phases 3-5 depend on 1-2.

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
- `.opencode/skills/spec-creation/SKILL.md` — Tasks table, Invocation section

**Changes:**
- Expand Tasks table to list all 8 task files on disk (not just `create`)
- Fix Invocation section: canonical dispatch string references `create` task but no `tasks/create.md` exists. Either rename `tasks/write.md` to `tasks/create.md` or change the dispatch string to `"execute write task from spec-creation"`
- Expand Trigger Dispatch Table to include all sub-tasks or add a note that the `create` task's own dispatch table handles sub-step routing

### Phase 3: write.md Structural Renumbering

**Affected files:**
- `.opencode/skills/spec-creation/tasks/write.md`

**Changes:**
- **C1: Duplicate Step 1a/1b** — Rename second `Step 1a` (Forward-Looking Mandate) to `Step 1c` and second `Step 1b` (Sub-Folder References) to `Step 1d`
- **C2: 7r before 7a ordering** — Move `Step 7r` (Remote Issue Body Format) before `Step 7` (Create Issue) since the format definition is a prerequisite to creation. Renumber `7a`/`7b`/`7c`/`7d` accordingly
- **C3: Pre-Step / Step 0.x naming** — Rename `Pre-Step`, `Pre-Step 0.8`, `Step 0.5`, `Step 0.5a` to a consistent sequential scheme
- **C4: Content templates as numbered steps** — Move Decision Ledger, Risk Traceability, Revision Policy, Decomposition Classification, Spec Family Annotation, Non-Goals, Regression Invariants, and Cross-Cutting SC Designation from numbered steps to sub-bullets under the Assemble Spec step
- **C5: Numbering gap (19a → 20)** — Re-number all step labels to a consistent scheme

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
- `.opencode/skills/spec-creation/SKILL.md` — Operating Protocol
- `.opencode/skills/spec-creation/tasks/write.md` — Step 40

**Changes:**
- Add `[sub-task: spec-audit]` step to spec-creation Operating Protocol between completion and correctness-over-speed
- Fix write.md Step 40 to reference `adversarial-audit --task spec-audit` instead of `spec-auditor`
- Add dispatch path for `change-control.md` or remove orphaned task file
- Add dispatch path for `handoffs/spec-to-plan.md` or remove orphaned file

## Success Criteria

| ID | Phase | Criterion | Evidence Type | Verification Method |
|----|-------|-----------|---------------|---------------------|
| SC-1 | 1 | spec-creation SKILL.md description includes article-variant triggers (`create a spec`, `write a spec`, `draft a spec`, `create a specification`, `write a specification`, `draft a specification`, `author a spec`, `make a spec`, `make specification`, `spec it out`) | `string` | `grep -q "create a spec" .opencode/skills/spec-creation/SKILL.md` |
| SC-2 | 1 | writing-plans SKILL.md description includes article-variant triggers (`create a plan`, `write a plan`, `draft a plan`, `make a plan`, `make plan`, `create an implementation plan`, `write an implementation plan`, `implementation steps`, `task list`, `break down the work`, `create the tasks`, `define the phases`) | `string` | `grep -q "create a plan" .opencode/skills/writing-plans/SKILL.md` |
| SC-3 | 1 | Behavioral test: agent dispatches `skill({name: "spec-creation"})` when user says "create a spec" | `behavioral` | `opencode-cli run "create a spec for X"` → stderr shows `Skill "spec-creation"` |
| SC-4 | 1 | Behavioral test: agent dispatches `skill({name: "writing-plans"})` when user says "create a plan" | `behavioral` | `opencode-cli run "create a plan for X"` → stderr shows `Skill "writing-plans"` |
| SC-5 | 2 | spec-creation Tasks table lists all 8 task files | `string` | `grep -c "|" .opencode/skills/spec-creation/SKILL.md` for task entries |
| SC-6 | 2 | Invocation section references an existing task file (either `tasks/create.md` exists or dispatch string references `write` task) | `structural` | `ls .opencode/skills/spec-creation/tasks/create.md` or grep for correct dispatch string |
| SC-7 | 3 | No duplicate Step 1a/1b labels in write.md | `string` | `grep -c "Step 1a" .opencode/skills/spec-creation/tasks/write.md` == 1 |
| SC-8 | 3 | Step 7r (Remote Issue Body Format) appears before Step 7 (Create Issue) in write.md | `string` | Line number of "Step 7r" < line number of "Step 7: Create Issue" |
| SC-9 | 3 | No Pre-Step / Step 0.x naming in write.md — all steps use consistent sequential scheme | `string` | `grep -c "Pre-Step\|Step 0\." .opencode/skills/spec-creation/tasks/write.md` == 0 |
| SC-10 | 3 | Content templates (Decision Ledger, Risk Traceability, etc.) are sub-bullets under Assemble Spec, not numbered steps | `string` | Content template sections are indented under Step 5 (Assemble Spec) |
| SC-11 | 4 | writing-plans SKILL.md has no "no task() calls" language | `string` | `grep -c "no task()" .opencode/skills/writing-plans/SKILL.md` == 0 |
| SC-12 | 4 | writing-plans SKILL.md Mandatory Task Discipline states sub-agent dispatch model | `string` | `grep -q "sub-agent" .opencode/skills/writing-plans/SKILL.md` |
| SC-13 | 4 | Behavioral test: writing-plans create task dispatches sub-agents (not inline) for pipeline steps | `behavioral` | `opencode-cli run` with plan creation prompt → stderr shows task() calls |
| SC-14 | 5 | spec-creation Operating Protocol includes `adversarial-audit --task spec-audit` step | `string` | `grep -q "adversarial-audit" .opencode/skills/spec-creation/SKILL.md` |
| SC-15 | 5 | write.md Step 40 references `adversarial-audit --task spec-audit` not `spec-auditor` | `string` | `grep -q "adversarial-audit" .opencode/skills/spec-creation/tasks/write.md` |
| SC-16 | 5 | No orphan task files — every `.md` in `tasks/` has a dispatch path | `string` | Cross-reference `ls tasks/*.md` against dispatch table entries |
| SC-17 | 3 | `local-issues sync` is run before any changes are made in the `.issues/` folder, and `local-issues sync` is run immediately after the local `spec.md` is created or updated | `behavioral` | `opencode-cli run` with spec creation prompt → stderr shows `local-issues sync` before `.issues/` writes and after `spec.md` save |

## Dependencies

- Phase 1: None (independent)
- Phase 2: None (independent)
- Phase 3: Depends on Phase 2 (same file — write.md)
- Phase 4: None (independent — different skill)
- Phase 5: Depends on Phase 2 (same file — spec-creation SKILL.md)

## Edge Cases

- **Existing specs/plans are not affected** — trigger phrase changes only affect future invocations
- **#1407 (routing-only SKILL.md) modifies the same files** — coordinate merge order. This spec's Phase 2 (dispatch table expansion) is compatible with #1407's routing-only template. Implement this spec first, then #1407 will restructure the same content
- **#1208 (5-workstream overhaul) also modifies dispatch tables** — this spec's Phase 2 is a subset of #1208 Workstream B. If #1208 is implemented first, Phase 2 may be partially redundant

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
