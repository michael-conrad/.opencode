# Plan: Workstream C — Procedure Checklist-ification

**Spec:** #1211
**Authorization scope:** `for_pr` | `halt_at: pr_created` | `pr_strategy: stacked`
**Type:** Separate (multi-phase, single-concern conversion)

## Summary

Convert all sequential numbered procedures in SKILL.md Operating Protocol sections and task files to `- [ ] N.` checklist format. Format-only changes — no content modifications.

**SCs covered:**
| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-C1 | All Operating Protocol sequential procedures use `- [ ] N.` checklist format | string |
| SC-C2 | All task file numbered procedures use `- [ ] N.` checklist format | string |
| SC-C3 | No checklist item contains completion emoji (✅, ☑, ✔) in its text | string |

**Scope:** 42 SKILL.md files (21 with Operating Protocol sections) + 253 task files across `.opencode/skills/*/tasks/`

---

## Pre-Work (before pipeline)

1. Create feature branch from dev: `feature/1211-checklist-ification`
2. Tag `.opencode` submodule: `.opencode/checkpoint/1211/pre`
3. Initialize pipeline state: `solve state init ./tmp/1211/state/`
4. Set initial state: `solve state update ./tmp/1211/state/ --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml --var-name previous_step --var-value init --var-name current_step --var-value sc-coherence-gate --var-name pipeline_state --var-value running`

## RED Assertions (for all phases)

- **SC-C1 RED:** `grep -n '^[0-9]\+\. ' .opencode/skills/*/SKILL.md` — expected to show remaining prose-numbered steps in Operating Protocols (RED = unconverted lines exist)
- **SC-C2 RED:** `grep -rn '^[0-9]\+\. ' .opencode/skills/*/tasks/*.md` — expected to show remaining prose-numbered steps in task files (RED = unconverted lines exist)
- **SC-C3 RED:** `grep -rn '✅\|☑\|✔' .opencode/skills/ --include='*.md' | grep '\- \[ \]'` — expected to show checklist items with completion emoji (RED = emoji exists in checklists)

## Verification Methods (for all phases)

- **SC-C1 (string):** For each SKILL.md `grep -c '\- \[ \] [0-9]'` on Operating Protocol sections — must match count of sequential numbered procedures; zero prose `^[0-9]+\.` lines remaining
- **SC-C2 (string):** For each task file `grep -c '\- \[ \] [0-9]'` on procedure sections — must match count of sequential numbered steps; zero prose `^[0-9]+\.` lines remaining
- **SC-C3 (string):** `grep -rn '✅\|☑\|✔' .opencode/skills/ --include='*.md' | grep '\- \[ \]'` — must return zero matches

---

## Phase 1: Core Pipeline/Workflow Skills — Operating Protocol Conversion

**Concern:** Convert Operating Protocol numbered procedures to checklist format for core pipeline and workflow skills (SC-C1).

**Files:**
- `.opencode/skills/approval-gate/SKILL.md`
- `.opencode/skills/git-workflow/SKILL.md`
- `.opencode/skills/implementation-pipeline/SKILL.md`
- `.opencode/skills/executing-plans/SKILL.md`
- `.opencode/skills/finishing-a-development-branch/SKILL.md`
- `.opencode/skills/pr-creation-workflow/SKILL.md`
- `.opencode/skills/conflict-resolution/SKILL.md`
- `.opencode/skills/changelog-generator/SKILL.md`
- `.opencode/skills/completion-core/SKILL.md`

| Gate | Dispatch | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|----------|--------|----------------|-----------------|-----|
| P1-G1: red-phase | sub-task | yes (blind) | general | `{issue: 1211, phase: 1, task: "red", files: [9 SKILL.md files], concern: "op-to-checklist"}` | SC-C1 |
| P1-G2: green-phase | sub-task | yes (blind) | general | `{issue: 1211, phase: 1, task: "green", files: [9 SKILL.md files], concern: "op-to-checklist"}` | SC-C1 |
| P1-G3: structural-checks | sub-task | yes (blind) | general | `{issue: 1211, phase: 1, task: "structural-checks", scan: "grep for remaining prose steps in OPs"}` | SC-C1 |
| P1-G4: checkpoint-commit | inline | N/A | N/A | — | SC-C1 |

---

## Phase 2: Planning & Creation Skills — Operating Protocol Conversion

**Concern:** Convert Operating Protocol numbered procedures for planning, creation, and documentation skills (SC-C1).

**Files:**
- `.opencode/skills/brainstorming/SKILL.md`
- `.opencode/skills/writing-plans/SKILL.md`
- `.opencode/skills/spec-creation/SKILL.md`
- `.opencode/skills/engineering-approach/SKILL.md`
- `.opencode/skills/skill-creator/SKILL.md`
- `.opencode/skills/systematic-debugging/SKILL.md`
- `.opencode/skills/sre-runbook/SKILL.md`
- `.opencode/skills/correspondence/SKILL.md`
- `.opencode/skills/researcher/SKILL.md`
- `.opencode/skills/test-driven-development/SKILL.md`

| Gate | Dispatch | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|----------|--------|----------------|-----------------|-----|
| P2-G1: red-phase | sub-task | yes (blind) | general | `{issue: 1211, phase: 2, task: "red", files: [10 SKILL.md files], concern: "op-to-checklist"}` | SC-C1 |
| P2-G2: green-phase | sub-task | yes (blind) | general | `{issue: 1211, phase: 2, task: "green", files: [10 SKILL.md files], concern: "op-to-checklist"}` | SC-C1 |
| P2-G3: structural-checks | sub-task | yes (blind) | general | `{issue: 1211, phase: 2, task: "structural-checks", scan: "grep for remaining prose steps in OPs"}` | SC-C1 |
| P2-G4: checkpoint-commit | inline | N/A | N/A | — | SC-C1 |

---

## Phase 3: Verification & Remaining Skills — Operating Protocol Conversion

**Concern:** Convert Operating Protocol numbered procedures for verification, issue, and utility skills (SC-C1).

**Files:**
- `.opencode/skills/verification-before-completion/SKILL.md`
- `.opencode/skills/verification-enforcement/SKILL.md`
- `.opencode/skills/completeness-gate/SKILL.md`
- `.opencode/skills/issue-review/SKILL.md`
- `.opencode/skills/pre-analysis/SKILL.md`
- `.opencode/skills/issue-operations/SKILL.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`
- `.opencode/skills/using-git-worktrees/SKILL.md`
- `.opencode/skills/adversarial-audit/SKILL.md`
- `.opencode/skills/plan/SKILL.md`

| Gate | Dispatch | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|----------|--------|----------------|-----------------|-----|
| P3-G1: red-phase | sub-task | yes (blind) | general | `{issue: 1211, phase: 3, task: "red", files: [remaining SKILL.md], concern: "op-to-checklist"}` | SC-C1 |
| P3-G2: green-phase | sub-task | yes (blind) | general | `{issue: 1211, phase: 3, task: "green", files: [remaining SKILL.md], concern: "op-to-checklist"}` | SC-C1 |
| P3-G3: structural-checks | sub-task | yes (blind) | general | `{issue: 1211, phase: 3, task: "structural-checks", scan: "grep for remaining prose steps in OPs"}` | SC-C1 |
| P3-G4: checkpoint-commit | inline | N/A | N/A | — | SC-C1 |

---

## Phase 4: Task Files — Core & Pipeline Skills

**Concern:** Convert numbered procedures in task files for core pipeline, workflow, planning, and creation skills (SC-C2).

**Files:** `tasks/*.md` under: approval-gate, git-workflow, implementation-pipeline, executing-plans, finishing-a-development-branch, pr-creation-workflow, conflict-resolution, changelog-generator, completion-core, brainstorming, writing-plans, spec-creation, engineering-approach, skill-creator, systematic-debugging, sre-runbook, correspondence, researcher, test-driven-development

| Gate | Dispatch | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|----------|--------|----------------|-----------------|-----|
| P4-G1: red-phase | sub-task | yes (blind) | general | `{issue: 1211, phase: 4, task: "red", skill_roots: [core+pipeline+planning], concern: "task-to-checklist"}` | SC-C2 |
| P4-G2: green-phase | sub-task | yes (blind) | general | `{issue: 1211, phase: 4, task: "green", skill_roots: [core+pipeline+planning], concern: "task-to-checklist"}` | SC-C2 |
| P4-G3: structural-checks | sub-task | yes (blind) | general | `{issue: 1211, phase: 4, task: "structural-checks"}` | SC-C2 |
| P4-G4: checkpoint-commit | inline | N/A | N/A | — | SC-C2 |

---

## Phase 5: Task Files — Verification & Remaining Skills

**Concern:** Convert numbered procedures in task files for verification, audit, design, review, and utility skills (SC-C2).

**Files:** `tasks/*.md` under: verification-before-completion, verification-enforcement, completeness-gate, issue-review, pre-analysis, issue-operations, adversarial-audit, ui-design, ui-engineer, receiving-code-review, requesting-code-review, research, plan, solve, mcp-tool-usage, multimodal-dispatch, programming-principles, sync-guidelines, using-git-worktrees

| Gate | Dispatch | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|----------|--------|----------------|-----------------|-----|
| P5-G1: red-phase | sub-task | yes (blind) | general | `{issue: 1211, phase: 5, task: "red", skill_roots: [remaining skills], concern: "task-to-checklist"}` | SC-C2 |
| P5-G2: green-phase | sub-task | yes (blind) | general | `{issue: 1211, phase: 5, task: "green", skill_roots: [remaining skills], concern: "task-to-checklist"}` | SC-C2 |
| P5-G3: structural-checks | sub-task | yes (blind) | general | `{issue: 1211, phase: 5, task: "structural-checks"}` | SC-C2 |
| P5-G4: checkpoint-commit | inline | N/A | N/A | — | SC-C2 |

---

## Phase 6: Emoji Cleanup

**Concern:** Remove completion emoji (✅) from checklist items where they create semantic conflict with `- [ ]` (SC-C3).

**Files:** `skills/sre-runbook/tasks/generate.md` (32 checklist items with `✅`)

| Gate | Dispatch | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|----------|--------|----------------|-----------------|-----|
| P6-G1: emoji-remove | sub-task | yes (blind) | general | `{issue: 1211, task: "emoji-remove", file: "skills/sre-runbook/tasks/generate.md", pattern: "remove ✅ from checklist items"}` | SC-C3 |
| P6-G2: sc-c3-verify | sub-task | yes (blind) | general | `{issue: 1211, task: "verify-sc-c3", scan: "grep for ✅ in checklists"}` | SC-C3 |

### Verification Criteria

- **SC-C3:** `grep -rn '✅\|☑\|✔' .opencode/skills/ --include='*.md' | grep '\- \[ \]'` — zero matches

---

## Phase 7: Final Verification

**Concern:** Verify all files converted correctly — all SCs independently.

| Gate | Dispatch | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|----------|--------|----------------|-----------------|-----|
| P7-G1: sc-c1-verify | sub-task | yes (blind) | general | `{issue: 1211, task: "verify-sc-c1", scan: "grep all SKILL.md for remaining prose steps in OPs"}` | SC-C1 |
| P7-G2: sc-c2-verify | sub-task | yes (blind) | general | `{issue: 1211, task: "verify-sc-c2", scan: "grep all task files for remaining prose steps"}` | SC-C2 |
| P7-G3: sc-c3-verify | sub-task | yes (blind) | general | `{issue: 1211, task: "verify-sc-c3", scan: "grep for ✅ in checklists"}` | SC-C3 |

### Verification Criteria

- **SC-C1:** All SKILL.md Operating Protocol sections use `- [ ] N.` checklist format for numbered procedures
- **SC-C2:** All task file Procedure/Step sections use `- [ ] N.` checklist format for numbered procedures
- **SC-C3:** No checklist item contains completion emoji (✅, ☑, ✔) in its text

---

## Post-Implementation

1. Tag submodule: `.opencode/checkpoint/1211/post`
2. Run enforcement tests: `bash .opencode/tests/test-enforcement.sh --changed`
3. Run finish-checklist: `skill({name: "finishing-a-development-branch"})`
4. Create PR (stacked with #1214): commit 1 = #1214, commit 2 = #1211