> **Full spec and artifacts: [`.opencode/.issues/2214/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2214)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2214/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Objective

Rewrite `skills/writing-plans/reference/implementation-workflow.md` from its current state (a skill card skeleton mislabeled as a reference doc) into a pure data catalog serving four consumers: spec writer, plan writer, spec auditor, and plan auditor.

## Background

The file was migrated from the former `implementation-pipeline` skill but the skill card skeleton was preserved verbatim — Persona, Worktree Mode, Mandatory Task Discipline, DISPATCH_GATE, Sub-Agent Routing, and YAML frontmatter with `name:`/`license:`. These are orchestrator-level routing sections that do not belong in a reference doc consumed by sub-agents. The file needs to be stripped down to just the data tables that the four consumer roles need.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | File contains only data tables (Pipeline Step Catalog, Trigger Dispatch Table, Per-Task Cycle, Gate Sequence, Coercion Rules, Artifact Retention) | string | grep for absence of Persona/Worktree Mode/Mandatory Task Discipline/DISPATCH_GATE/Sub-Agent Routing sections |
| SC-2 | No YAML frontmatter with `name:`, `license:`, or `provenance:` | string | grep for absence of frontmatter delimiters |
| SC-3 | Pipeline Step Catalog table exists with columns: step name, description, what it produces | string | grep for table with those column headers |
| SC-4 | Trigger Dispatch Table exists with columns: step name, owning skill, canonical dispatch string | string | grep for table with those column headers |
| SC-5 | Per-Task Cycle section defines the RED→GREEN→COMMIT sequence | string | grep for RED, GREEN, COMMIT step definitions |
| SC-6 | Gate Sequence section lists mandatory gate order for a phase | string | grep for gate sequence definition |
| SC-7 | Coercion Rules section documents DONE_WITH_CONCERNS → FAIL and evidence type mismatch rules | string | grep for coercion rule definitions |
| SC-8 | Artifact Retention section documents what gets cleaned when | string | grep for artifact retention rules |
| SC-9 | All existing cross-references to this file from other task files remain valid after rewrite | string | grep for all reference paths in task files still resolve |
| SC-10 | Plan writer task files (create.md, research.md, validate.md) still read the file at the same path | string | grep for unchanged read paths in those task files |

## Requirements

- REQ-1: The file must remain at `skills/writing-plans/reference/implementation-workflow.md` (path must not change)
- REQ-2: All existing cross-references from other task files must remain valid
- REQ-3: The Trigger Dispatch Table must contain all current dispatch entries (pre-regression, red, green, verify, audit, etc.)
- REQ-4: The Per-Task Cycle must match the current RED→GREEN→COMMIT sequence
- REQ-5: No orchestrator-level routing content (Persona, Worktree Mode, Mandatory Task Discipline, DISPATCH_GATE, Sub-Agent Routing)

## Dependencies

- **File path stability:** The file must remain at `skills/writing-plans/reference/implementation-workflow.md` — all cross-references from other task files reference this path and must remain valid
- **Cross-reference integrity:** Every task file that reads this path must continue to resolve after the rewrite
- **No consumer-side changes:** No task files that consume this reference doc may be modified as part of this change

## Phases

| Phase | SCs | Description |
|-------|-----|-------------|
| 1 (REQ-5) | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8 | Rewrite the file as a pure data catalog |
| 2 (REQ-1, REQ-2) | SC-9, SC-10 | Verify all cross-references remain valid |

## Traceability

| Requirement | SCs |
|-------------|-----|
| REQ-1 | SC-9, SC-10 |
| REQ-2 | SC-9 |
| REQ-3 | SC-4 |
| REQ-4 | SC-5 |
| REQ-5 | SC-1, SC-2, SC-3, SC-6, SC-7, SC-8 |

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-07-31 | Added Dependencies section | Missing Dependencies section — required per 11-dimension completeness check | Pipeline (validation findings) |
| 2026-07-31 | Added REQ references to phase table headings | Phase table headings lacked REQ references — required per structural validation phase coverage check | Pipeline (validation findings) |
| 2026-07-31 | Added SC-3, SC-6, SC-7, SC-8 to REQ-5 traceability row | Traceability table missing SC-3, SC-6, SC-7, SC-8 — all map to REQ-5 per validation findings | Pipeline (validation findings) |
