> **Full spec and artifacts: [`.opencode/.issues/1398/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1398/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1398/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exec Summary

Fix two defects in `skills/spec-creation/SKILL.md`: remove the dead `diagram` task entry that routes to a nonexistent task file, and add the missing `change-control` entry to the Invocation table and Operating Protocol.

### Cards (dependency order)
1. **Remove `diagram` from all three tables** — Trigger Dispatch Table, Tasks table, Invocation table
2. **Add `change-control` to Invocation table** — with canonical dispatch string matching the other tasks
3. **Add `change-control` step to Operating Protocol** — positioned after `write` (step 9) and before `completion` (step 10)

### Key Decisions
- **No task file creation for `diagram`**: The diagram-generation rules are already embedded in the `write` task's procedure. Creating a separate `diagram.md` would duplicate logic and create a maintenance burden.
- **`change-control` step position**: After `write` and before `completion` — change control is a post-write review step that must happen before the workflow completes.

### Risk Callouts
- **Risk of stale references**: If the SKILL.md is edited manually between spec creation and implementation, the line numbers and table positions may shift. The implementation MUST use grep/pattern matching, not line numbers.
- **Risk of missing `change-control` in other tables**: The Trigger Dispatch Table and Tasks table already list `change-control` — only the Invocation table and Operating Protocol are missing it. Verify this assumption during implementation.

## Problem

**Defect A — Dead `diagram` task entry:** Commit `75995c64` (feat #163, mermaid workflow diagrams) added `diagram` to the Trigger Dispatch Table, Tasks table, and Invocation table of `skills/spec-creation/SKILL.md`. The task file `tasks/diagram.md` was never created and has never existed in any commit. The diagram-generation rules (check dependencies → generate mermaid → insert at prescribed location → scan for workflow state markers) are already embedded in the `write` task's procedure. The `diagram` entry is a dead dispatch target that routes to nothing.

**Defect B — `change-control` missing from Invocation table and Operating Protocol:** `change-control` is one of the 6 original tasks from the initial spec-creation commit (`4ec894fc`, feat #629). It has a valid task file on disk (`tasks/change-control.md`, 94 lines) and is listed in the Trigger Dispatch Table and Tasks table. It is missing from the Invocation table (no `task(..., prompt: "execute change-control task from spec-creation")` entry) and from the Operating Protocol (no step number assigns it a position in the execution chain). This is a regression from the refactoring that introduced the current Invocation table format.

## Scope

- Remove `diagram` from Trigger Dispatch Table (line 34)
- Remove `diagram` from Tasks table (line 52)
- Remove `diagram` from Invocation table (line 68)
- Add `change-control` to Invocation table with canonical dispatch string
- Add `change-control` step to Operating Protocol after `write` and before `completion`

## Approach

Two independent edits to `skills/spec-creation/SKILL.md`:

1. **Defect A**: Delete the three lines containing `diagram` entries — one per table. Each table has exactly one `diagram` row.
2. **Defect B**: Add a new row to the Invocation table for `change-control` following the same format as the other tasks. Add a new step to the Operating Protocol numbered between the current step 9 (`write`) and step 10 (`completion`), following the same `[sub-task: change-control]` format.

## Impact

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Line numbers shift between spec and implementation | Medium | Low | Use grep/pattern matching, not line numbers |
| `change-control` already present in some tables but not others | Low | Low | Verified during spec creation — Trigger Dispatch Table and Tasks table confirmed correct |
| Behavioral test infrastructure unavailable | Low | Medium | Fall back to content-verification grep tests; behavioral tests are preferred but content-verification is acceptable for structural-only changes |

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1398/`.
After creation, `local-issues sync 1398` MUST be run and the result committed to create the local `.opencode/.issues/1398/` entry.
The implementation plan will be created in `.opencode/.issues/1398/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `diagram` removed from Trigger Dispatch Table | `string` | `grep -n "diagram" skills/spec-creation/SKILL.md \| grep "Trigger Dispatch Table"` — 0 matches | If match found, delete the `diagram` row from the Trigger Dispatch Table | remove-diagram | `.opencode/skills/spec-creation/SKILL.md` | DEC-1 | Phase 1 | pre-commit | single | — | — | — | Phase 1 |
| SC-2 | `diagram` removed from Tasks table | `string` | `grep -n "diagram" skills/spec-creation/SKILL.md \| grep "Tasks table"` — 0 matches | If match found, delete the `diagram` row from the Tasks table | remove-diagram | `.opencode/skills/spec-creation/SKILL.md` | DEC-1 | Phase 1 | pre-commit | single | — | — | — | Phase 1 |
| SC-3 | `diagram` removed from Invocation table | `string` | `grep -n "diagram" skills/spec-creation/SKILL.md \| grep "Invocation"` — 0 matches | If match found, delete the `diagram` row from the Invocation table | remove-diagram | `.opencode/skills/spec-creation/SKILL.md` | DEC-1 | Phase 1 | pre-commit | single | — | — | — | Phase 1 |
| SC-4 | `change-control` added to Invocation table with canonical dispatch string | `string` | `grep "execute change-control task from spec-creation" skills/spec-creation/SKILL.md` — 1 match | If 0 matches, add the `change-control` row to the Invocation table | add-change-control-invocation | `.opencode/skills/spec-creation/SKILL.md` | DEC-2 | Phase 2 | pre-commit | single | — | — | — | Phase 2 |
| SC-5 | `change-control` step added to Operating Protocol after `write` and before `completion` | `string` | `grep "change-control" skills/spec-creation/SKILL.md \| grep "Operating Protocol"` — 1 match, positioned between `write` and `completion` | If 0 matches, add the `change-control` step to the Operating Protocol | add-change-control-protocol | `.opencode/skills/spec-creation/SKILL.md` | DEC-2 | Phase 2 | pre-commit | single | — | — | — | Phase 2 |
| SC-6 | No existing task files modified or deleted | `structural` | `ls skills/spec-creation/tasks/ \| wc -l` — file count unchanged (8), `diagram.md` absent | If file count changed or `diagram.md` exists, revert unintended file changes | verify-files | `.opencode/skills/spec-creation/tasks/` | DEC-1, DEC-2 | Phase 2 | pre-commit | single | — | — | — | Phase 2 |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

### All-or-Nothing Gate

ALL success criteria MUST pass for implementation to be considered complete. Any SKIPPED SC is treated as FAIL. Any FAILED SC triggers autonomous remediation by the producing agent. Gate holds position until remediation is verified.

### Evidence Type Classification

| SC | Change Affects Runtime Behavior? | Required Evidence Type | Declared Type |
|----|--------------------------------|----------------------|---------------|
| SC-1 | NO — table entry removal, no behavioral change | `string` | `string` |
| SC-2 | NO — table entry removal, no behavioral change | `string` | `string` |
| SC-3 | NO — table entry removal, no behavioral change | `string` | `string` |
| SC-4 | NO — table entry addition, no behavioral change | `string` | `string` |
| SC-5 | NO — step addition, no behavioral change | `string` | `string` |
| SC-6 | NO — file listing, no behavioral change | `structural` | `structural` |

### Determinism Gate

Each SC produces the same PASS/FAIL result regardless of auditor. Verification commands are exact grep/pattern matches with no subjective thresholds.

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Remove `diagram` entries without creating `diagram.md` | The diagram-generation rules are already embedded in the `write` task's procedure. Creating a separate task file would duplicate logic. | MUST | SC-1, SC-2, SC-3, SC-6 |
| DEC-2 | Add `change-control` to Invocation table and Operating Protocol only | The Trigger Dispatch Table and Tasks table already list `change-control`. Only the Invocation table and Operating Protocol are missing it. | MUST | SC-4, SC-5, SC-6 |
| DEC-3 | Position `change-control` step after `write` and before `completion` | Change control is a post-write review step that must happen before the workflow completes. | MUST | SC-5 |

## Risk Traceability Table

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Line numbers shift between spec creation and implementation | Medium | Low | Use grep/pattern matching, not line numbers | SC-1, SC-2, SC-3, SC-4, SC-5 |
| RISK-2 | Behavioral test infrastructure unavailable | Low | Medium | Content-verification grep tests are sufficient for structural-only changes | SC-1 through SC-6 |
| RISK-3 | `change-control` already present in Invocation table from prior edit | Low | Low | SC-4 verification will detect this — if already present, no action needed | SC-4 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Decomposition Classification

| Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
| -------------- | ---------------- | ---------------------- | ----------- |
| single-task | 1 | None | single PR |

## Explicit Non-Goals

- **The `description` frontmatter fix** — tracked in #1388 (Fix C2). Not covered here.
- **No changes to `tasks/change-control.md` content** — the task file is correct as-is.
- **No changes to any other SKILL.md file** — only `skills/spec-creation/SKILL.md` is modified.
- **No behavioral enforcement tests** — these are structural-only changes (table entries). Content-verification grep tests are sufficient.

## Regression Invariants

1. All existing task files in `skills/spec-creation/tasks/` MUST remain unchanged.
2. The Trigger Dispatch Table MUST continue to list all valid dispatch targets.
3. The Operating Protocol step numbering MUST remain sequential after the `change-control` insertion.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `git log --all -- skills/spec-creation/tasks/diagram.md` | Verify `diagram.md` never existed |
| Direct source search | `ls skills/spec-creation/tasks/` | Verify current task file inventory (8 files, no `diagram.md`) |
| Direct source search | `wc -l skills/spec-creation/tasks/change-control.md` | Verify `change-control.md` exists (93 lines) |
| Direct source search | `git show 75995c64 --stat` | Verify commit that added `diagram` entries |
| Direct source search | `git show 4ec894fc --stat` | Verify initial spec-creation commit with 6 original tasks |
| Direct source search | Read `skills/spec-creation/SKILL.md` | Verify current state of all three tables and Operating Protocol |

---

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1398/plan.md` before implementation begins.

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created