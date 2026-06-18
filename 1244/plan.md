# Plan: Decouple State Tracking from Design Artifacts

**Spec:** [michael-conrad/.opencode#1244](https://github.com/michael-conrad/.opencode/issues/1244)
**Authorization scope:** `for_pr` (auto-approve plan)
**Plan structure:** Separate (4 independent phases)

## Goal

Remove STATUS markers from plan bodies, relocate lifecycle manifest to `./tmp/{N}/`, make labels advisory-only for authorization gating, and add `./tmp/{N}/checklist.md` generation on plan creation.

## Architecture

The `.opencode/skills/` directory contains task files that reference STATUS markers in plan issue bodies for state tracking. This plan replaces those references with file-based state tracking in `./tmp/{N}/`. Four independent bugs in the spec target distinct file groups.

## Tech Stack

- Skill task files (Markdown) in `.opencode/skills/*/tasks/*.md`
- Behavioral tests (Bash) in `.opencode/tests/behaviors/`
- Z3 solver for pipeline gate validation
- `solve` and `plan` CLI tools for contract verification

---

> **Compliance Requirement:** All steps and sub-steps in this plan MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

## Phase 1: Remove STATUS Markers from Plan Bodies (SC-1, SC-2, SC-3)

**Concern:** Removing STATUS marker reads/writes from executing-plans, approval-gate, and implementation-pipeline task files. These markers are state tracking embedded in design artifacts — a correctness violation.

**Files:** `skills/executing-plans/tasks/`, `skills/approval-gate/`, `skills/implementation-pipeline/enforcement/`

**SCs covered:** SC-1, SC-2, SC-3

**Dependencies:** None (foundational phase)

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1244, "phase": 1}` | SC-1, SC-2, SC-3 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1244, "phase": 1}` | SC-1, SC-2, SC-3 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1244, "phase": 1}` | SC-1, SC-2, SC-3 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1244, "phase": 1}` | SC-1, SC-2, SC-3 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1244, "phase": 1}` | SC-1, SC-2, SC-3 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1244, "phase": 1}` | SC-1, SC-2, SC-3 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1244, "phase": 1}` | SC-1, SC-2, SC-3 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1, SC-2, SC-3 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1244, "phase": 1}` | SC-1, SC-2, SC-3 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1244, "phase": 1}` | SC-1, SC-2, SC-3 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1244, "phase": 1}` | SC-1, SC-2, SC-3 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1244, "phase": 1}` | SC-1, SC-2, SC-3 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1244, "phase": 1}` | SC-1, SC-2, SC-3 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1244, "phase": 1}` | SC-1, SC-2, SC-3 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1244, "phase": 1}` | SC-1, SC-2, SC-3 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1244, "phase": 1}` | SC-1, SC-2, SC-3 |

### Unit 1.1: Remove STATUS from executing-plans task files

| Gate | Name | Exit Criterion (unit-specific) |
|------|------|-------------------------------|
| 1 | sc-coherence-gate | Substrate classification confirms these are string-pattern changes — string evidence sufficient |
| 2 | pre-red-baseline | Source currency verified: executing-plans/tasks/ files exist and current |
| 3 | red-phase | Content-verification test shows `grep "STATUS" skills/executing-plans/tasks/*.md` matches — RED artifact PASS |
| 4 | red-doublecheck | RED-side evidence confirmed: STATUS patterns present in task files |
| 5 | green-phase | Remove STATUS marker read/write lines from executing-plans/tasks/step.md, start.md, completion.md |
| 6 | checkpoint-commit | Commit with message "executing-plans: remove STATUS markers from plan bodies" |
| 7 | structural-checks | lint/typecheck pass (no Python files affected) |
| 8 | green-doublecheck | `grep "STATUS" skills/executing-plans/tasks/*.md` returns empty — SC-1 PASS |
| 9 | green-vbc | SC-1 verified: string evidence showing STATUS pattern absent |
| 10 | adversarial-audit | Dual auditors confirm no STATUS references remain |
| 11 | cross-validate | Consensus PASS between both auditors |
| 12 | regression-check | No behavioral tests broken |
| 13 | review-prep | Git status clean, PR description drafted |
| 14 | exec-summary | Push, extract URL from API response |

### Unit 1.2: Remove STATUS from approval-gate task files

| Gate | Name | Exit Criterion (unit-specific) |
|------|------|-------------------------------|
| 1 | sc-coherence-gate | Substrate: string-pattern changes. approval-gate files reference STATUS — removal is safe |
| 2 | pre-red-baseline | Source currency: approval-gate tasks exist and current |
| 3 | red-phase | Content-verification: `grep "STATUS" skills/approval-gate/tasks/*.md` shows matches — RED |
| 4 | red-doublecheck | RED evidence: STATUS patterns confirmed in verify-sub-issues, scope-parsing, context-passing |
| 5 | green-phase | Remove STATUS marker references from approval-gate task files; route phase progress to `./tmp/{N}/work.md` |
| 6 | checkpoint-commit | Commit with message "approval-gate: remove STATUS markers, route to work.md" |
| 7 | structural-checks | lint pass |
| 8 | green-doublecheck | `grep "STATUS" skills/approval-gate/` shows no plan-body STATUS references — SC-2 PASS |
| 9 | green-vbc | SC-2 verified: string evidence |
| 10 | adversarial-audit | Dual auditors confirm SC-2 compliance |
| 11 | cross-validate | Consensus PASS |
| 12 | regression-check | No authorization tests broken |
| 13 | review-prep | Git status clean |
| 14 | exec-summary | Push, extract URL from API response |

### Unit 1.3: Remove Plan STATUS from implementation-pipeline

| Gate | Name | Exit Criterion (unit-specific) |
|------|------|-------------------------------|
| 1 | sc-coherence-gate | Substrate: string-pattern change. context-passing.md references Plan STATUS |
| 2 | pre-red-baseline | Source currency: implementation-pipeline/enforcement/ files exist |
| 3 | red-phase | Content-verification: `grep "Plan STATUS" skills/implementation-pipeline/` shows matches |
| 4 | red-doublecheck | RED evidence: Plan STATUS pattern confirmed |
| 5 | green-phase | Remove Plan STATUS references from context-passing.md |
| 6 | checkpoint-commit | Commit with message "implementation-pipeline: remove Plan STATUS references" |
| 7 | structural-checks | lint pass |
| 8 | green-doublecheck | `grep "Plan STATUS" skills/implementation-pipeline/` returns empty — SC-3 PASS |
| 9 | green-vbc | SC-3 verified: string evidence |
| 10 | adversarial-audit | Dual auditors confirm SC-3 compliance |
| 11 | cross-validate | Consensus PASS |
| 12 | regression-check | No pipeline tests broken |
| 13 | review-prep | Git status clean |
| 14 | exec-summary | Push, extract URL from API response |

---

## Phase 2: Relocate Lifecycle Manifest to `./tmp/{N}/` (SC-4)

**Concern:** Moving lifecycle event log from `.issues/{issue-N}/lifecycle.yaml` (design artifact directory) to `./tmp/{issue-N}/lifecycle.yaml` (ephemeral state directory).

**Files:** `skills/implementation-pipeline/SKILL.md`, `skills/spec-creation/tasks/write.md`, `skills/writing-plans/tasks/create/create-and-validate.md`

**SCs covered:** SC-4

**Dependencies:** None (independent of Phase 1)

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1244, "phase": 2}` | SC-4 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1244, "phase": 2}` | SC-4 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1244, "phase": 2}` | SC-4 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1244, "phase": 2}` | SC-4 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1244, "phase": 2}` | SC-4 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1244, "phase": 2}` | SC-4 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1244, "phase": 2}` | SC-4 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-4 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1244, "phase": 2}` | SC-4 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1244, "phase": 2}` | SC-4 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1244, "phase": 2}` | SC-4 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1244, "phase": 2}` | SC-4 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1244, "phase": 2}` | SC-4 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1244, "phase": 2}` | SC-4 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1244, "phase": 2}` | SC-4 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1244, "phase": 2}` | SC-4 |

### Unit 2.1: Relocate lifecycle manifest references

| Gate | Name | Exit Criterion (unit-specific) |
|------|------|-------------------------------|
| 1 | sc-coherence-gate | Substrate: string-pattern changes — lifecycle path references |
| 2 | pre-red-baseline | Source currency: 3 affected files exist |
| 3 | red-phase | Content-verification: `grep "\.issues/.*lifecycle"` shows 3 matches across 3 files |
| 4 | red-doublecheck | RED evidence: all `.issues/{N}/lifecycle.yaml` references confirmed |
| 5 | green-phase | Replace `.issues/{issue-N}/lifecycle.yaml` with `./tmp/{issue-N}/lifecycle.yaml` in all 3 files |
| 6 | checkpoint-commit | Commit with message "lifecycle: relocate manifest to ./tmp/{N}/" |
| 7 | structural-checks | lint pass |
| 8 | green-doublecheck | `grep "\.issues/{N}/lifecycle\|\.issues/{issue-N}/lifecycle"` shows 0 matches in skill files — SC-4 PASS |
| 9 | green-vbc | SC-4 verified: string evidence |
| 10 | adversarial-audit | Dual auditors confirm SC-4 compliance |
| 11 | cross-validate | Consensus PASS |
| 12 | regression-check | No pipeline tests broken |
| 13 | review-prep | Git status clean |
| 14 | exec-summary | Push, extract URL from API response |

---

## Phase 3: Labels Advisory-Only Authorization (SC-5, SC-6)

**Concern:** Making labels advisory metadata (stakeholder-facing) while authorization gates read from `./tmp/{N}/work.md`. Labels remain present for visibility but do not gate agent execution.

**Files:** `skills/approval-gate/tasks/verify-blockers.md`, `skills/approval-gate/tasks/verify-authorization.md`, `.opencode/tests/behaviors/`

**SCs covered:** SC-5, SC-6

**Dependencies:** Phase 1 must complete first (approval-gate references STATUS patterns being removed in Phase 1)

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1244, "phase": 3}` | SC-5, SC-6 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1244, "phase": 3}` | SC-5, SC-6 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1244, "phase": 3}` | SC-5, SC-6 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1244, "phase": 3}` | SC-5, SC-6 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1244, "phase": 3}` | SC-5, SC-6 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1244, "phase": 3}` | SC-5, SC-6 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1244, "phase": 3}` | SC-5, SC-6 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-5, SC-6 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1244, "phase": 3}` | SC-5, SC-6 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1244, "phase": 3}` | SC-5, SC-6 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1244, "phase": 3}` | SC-5, SC-6 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1244, "phase": 3}` | SC-5, SC-6 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1244, "phase": 3}` | SC-5, SC-6 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1244, "phase": 3}` | SC-5, SC-6 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1244, "phase": 3}` | SC-5, SC-6 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1244, "phase": 3}` | SC-5, SC-6 |

### Unit 3.1: Remove label-based authorization halt

**RED:** Behavioral test shows agent halts on `needs-approval` label even when `./tmp/{N}/work.md` has authorization scope.
**GREEN:** Behavioral test shows agent proceeds when work state has authorization even if `needs-approval` label is present.

| Gate | Name | Exit Criterion (unit-specific) |
|------|------|-------------------------------|
| 1 | sc-coherence-gate | Substrate: runtime-behavioral change. SC-5, SC-6 are behavioral — require behavioral evidence. Automatic uplift from string/structural to behavioral |
| 2 | pre-red-baseline | Source currency: verify-blockers.md, verify-authorization.md, work-state-schema.md exist |
| 3 | red-phase | Write behavioral test: agent halts on `needs-approval` label (SC-5 RED). Write behavioral test: agent halts despite work state having authorization when label present (SC-6 RED) |
| 4 | red-doublecheck | Behavioral RED tests confirmed failing — agent currently halts on label |
| 5 | green-phase | Modify verify-blockers.md: remove halt on `needs-approval` label. Modify verify-authorization.md: read from `./tmp/{N}/work.md` as primary gate, label sync is courtesy |
| 6 | checkpoint-commit | Commit with message "approval-gate: labels advisory-only, authorization from work.md" |
| 7 | structural-checks | lint pass |
| 8 | green-doublecheck | Behavioral tests PASS — agent no longer halts on label, uses work state file |
| 9 | green-vbc | SC-5, SC-6 verified: behavioral evidence from opencode-cli run |
| 10 | adversarial-audit | Dual auditors confirm behavioral evidence sufficient for SC-5, SC-6 |
| 11 | cross-validate | Consensus PASS |
| 12 | regression-check | Existing authorization behavioral tests still pass |
| 13 | review-prep | Git status clean |
| 14 | exec-summary | Push, extract URL from API response |

---

## Phase 4: Add Checklist Generation on Plan Creation (SC-7, SC-8, SC-9)

**Concern:** Adding `./tmp/{N}/checklist.md` generation to the writing-plans skill. The checklist replaces STATUS markers — agent reads checklist for next action instead of plan body STATUS.

**Files:** `skills/writing-plans/tasks/create/`, `skills/writing-plans/SKILL.md`

**SCs covered:** SC-7, SC-8, SC-9

**Dependencies:** Phase 1 must complete (STATUS removal creates the gap that checklist fills)

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1244, "phase": 4}` | SC-7, SC-8, SC-9 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1244, "phase": 4}` | SC-7, SC-8, SC-9 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1244, "phase": 4}` | SC-7, SC-8, SC-9 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1244, "phase": 4}` | SC-7, SC-8, SC-9 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1244, "phase": 4}` | SC-7, SC-8, SC-9 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1244, "phase": 4}` | SC-7, SC-8, SC-9 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1244, "phase": 4}` | SC-7, SC-8, SC-9 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-7, SC-8, SC-9 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1244, "phase": 4}` | SC-7, SC-8, SC-9 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1244, "phase": 4}` | SC-7, SC-8, SC-9 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1244, "phase": 4}` | SC-7, SC-8, SC-9 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1244, "phase": 4}` | SC-7, SC-8, SC-9 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1244, "phase": 4}` | SC-7, SC-8, SC-9 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1244, "phase": 4}` | SC-7, SC-8, SC-9 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1244, "phase": 4}` | SC-7, SC-8, SC-9 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1244, "phase": 4}` | SC-7, SC-8, SC-9 |

### Unit 4.1: Add checklist generation to writing-plans create pipeline

**RED:** Behavioral test shows plan creation does NOT generate `./tmp/{N}/checklist.md`.
**GREEN:** Behavioral test shows plan creation generates checklist with phases, steps, dispatch instructions.

| Gate | Name | Exit Criterion (unit-specific) |
|------|------|-------------------------------|
| 1 | sc-coherence-gate | Substrate: runtime-behavioral change. SC-7, SC-9 are behavioral. SC-8 is structural (file exists) |
| 2 | pre-red-baseline | Source currency: writing-plans/tasks/create/create-and-validate.md exists |
| 3 | red-phase | Write behavioral test: plan creation (opencode-cli run) does NOT produce checklist file. Also write structural RED: `./tmp/{N}/checklist.md` does not exist |
| 4 | red-doublecheck | RED behavioral test confirmed failing — no checklist generated |
| 5 | green-phase | Add checklist generation step to create-and-validate.md after plan content finalized. Generate `./tmp/{N}/checklist.md` with: every phase as section, every step as checkbox with dispatch instruction, status tracking per step |
| 6 | checkpoint-commit | Commit with message "writing-plans: add checklist generation on plan creation" |
| 7 | structural-checks | lint pass |
| 8 | green-doublecheck | Behavioral test PASS — plan creation generates checklist (SC-7). Structural check: `./tmp/{N}/checklist.md` exists, no `./tmp/{N}/checklist-phase-*.md` (SC-8). Behavioral test: agent reads checklist not plan body STATUS for next action (SC-9) |
| 9 | green-vbc | SC-7: behavioral. SC-8: structural (file exists). SC-9: behavioral |
| 10 | adversarial-audit | Dual auditors confirm behavioral evidence for SC-7, SC-9; structural for SC-8 |
| 11 | cross-validate | Consensus PASS |
| 12 | regression-check | No existing behavioral tests broken |
| 13 | review-prep | Git status clean |
| 14 | exec-summary | Push, extract URL from API response |

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

## Exit Criteria

| ID | Criterion |
|----|-----------|
| C1 | Plan header includes Goal, Architecture, Tech Stack |
| C2 | File structure references sub-folders (not individual files) |
| C3 | TDD tasks include mandatory Step 2 RED checkpoint |
| C4 | Phase descriptions include concern boundary annotations |
| C5 | Plan stored at `.opencode/.issues/1244/plan.md` |
| C6 | No TBD/TODO placeholders remain |
| C7 | Plan artifact created locally in `.opencode/.issues/1244/` |
| C8 | Approval cascade honors `for_pr` scope (auto-approved) |
| SC-1 | No STATUS in executing-plans task files |
| SC-2 | No STATUS in approval-gate task files |
| SC-3 | No Plan STATUS in implementation-pipeline |
| SC-4 | Lifecycle manifest at `./tmp/{N}/lifecycle.yaml` |
| SC-5 | Agent halts on auth missing in work.md, not label |
| SC-6 | Agent proceeds when work.md has auth despite label |
| SC-7 | Checklist generated on plan creation |
| SC-8 | Single checklist file at `./tmp/{N}/checklist.md` |
| SC-9 | Agent uses checklist not plan body for next action |

---