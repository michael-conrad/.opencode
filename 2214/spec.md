> **Full spec and artifacts: [`.opencode/.issues/2214/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2214)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2214/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Intent & Executive Summary

- **Problem:** The file `skills/writing-plans/reference/implementation-workflow.md` contains 5 redundant representations of the same pipeline data: Pipeline Step Catalog (description + output), Trigger Dispatch Table (owning skill + dispatch string), Gate Sequence (ordered list), Audit Sequence Exception (inline prose), and Artifact Pre-Cleanup (step label + cleanup action). Each table carries a different subset of columns, forcing consumers to cross-reference multiple tables to get the full picture for any single step.
- **Objective:** Consolidate the 5 representations into 3 focused tables (Pre-implementation, RED-GREEN Daisy-Chain, Post-implementation), each carrying all columns (step name, owning skill, dispatch string, description) in one place. Cross-cutting sections (Per-Task Cycle, Coercion Rules, Artifact Retention) remain as standalone sections.
- **Scope:** Single file rewrite at `skills/writing-plans/reference/implementation-workflow.md`. No changes to consuming task files, no changes to the writing-plans SKILL.md, no changes to pipeline enforcement rules.
- **Success Criteria Overview:** 8 SCs covering content purity (no orchestrator sections, no frontmatter), 3 focused table presence, and cross-reference integrity.
- **Key Constraints:** File path must not change (REQ-1). All existing cross-references must remain valid (REQ-2). No consumer-side behavioral changes.
- **Stakeholders:** Plan writers (consume RED-GREEN Daisy-Chain + Per-Task Cycle + Coercion Rules + Artifact Retention), spec auditors and plan auditors (consume Post-implementation table).

## Objective

Rewrite `skills/writing-plans/reference/implementation-workflow.md` from its current state (5 redundant representations with split columns) into 3 focused tables (Pre-implementation, RED-GREEN Daisy-Chain, Post-implementation), each carrying all columns in one place. Cross-cutting sections (Per-Task Cycle, Coercion Rules, Artifact Retention) remain as standalone sections.

## Background

The file was migrated from the former `implementation-pipeline` skill but the skill card skeleton was preserved verbatim — Persona, Worktree Mode, Mandatory Task Discipline, DISPATCH_GATE, Sub-Agent Routing, and YAML frontmatter with `name:`/`license:`. These are orchestrator-level routing sections that do not belong in a reference doc consumed by sub-agents.

Beyond the routing content problem, the data itself was fragmented across 5 redundant representations:

1. **Pipeline Step Catalog** — step name, description, what it produces
2. **Trigger Dispatch Table** — step name, owning skill, canonical dispatch string
3. **Gate Sequence** — ordered list of step names with descriptions (duplicates Pipeline Step Catalog)
4. **Audit Sequence Exception** — inline prose describing audit as a multi-step sequence (duplicates Trigger Dispatch Table for the audit step)
5. **Artifact Pre-Cleanup** — step label and cleanup action (duplicates step names from Pipeline Step Catalog)

Each representation carried a different column subset, forcing consumers to cross-reference multiple tables to get the full picture for any single step. The rewrite consolidates all step data into 3 phase-grouped tables (Pre-implementation, RED-GREEN Daisy-Chain, Post-implementation), each carrying all 4 columns (step name, owning skill, dispatch string, description) in one place. The Gate Sequence section is eliminated — its ordering information is now implicit in the 3-table grouping. The Audit Sequence Exception is eliminated — its content is now in the Post-implementation table's audit row. The Artifact Pre-Cleanup table is preserved as a cross-cutting section under Artifact Retention.

**Provenance evidence:** Verified by reading the file at `skills/writing-plans/reference/implementation-workflow.md` — confirmed presence of YAML frontmatter (lines 1-6), Persona section (lines 27-33), Worktree Mode (lines 35-37), Mandatory Task Discipline (lines 39-44), DISPATCH_GATE (lines 93-109), and Sub-Agent Routing (lines 83-91). Also confirmed 5 redundant representations: Pipeline Step Catalog (lines 8-26), Trigger Dispatch Table (lines 28-46), Gate Sequence (lines 69-88), Audit Sequence Exception (lines 48-51), Artifact Pre-Cleanup (lines 107-124).

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | File contains only 3 focused tables (Pre-implementation, RED-GREEN Daisy-Chain, Post-implementation) plus cross-cutting sections (Per-Task Cycle, Coercion Rules, Artifact Retention) | string | grep for absence of Pipeline Step Catalog / Trigger Dispatch Table / Gate Sequence / Audit Sequence Exception / Persona / Worktree Mode / Mandatory Task Discipline / DISPATCH_GATE / Sub-Agent Routing sections |
| SC-2 | No YAML frontmatter with `name:`, `license:`, or `provenance:` | string | grep for absence of frontmatter delimiters |
| SC-3 | Pre-implementation table exists with columns: step name, owning skill, dispatch string, description | string | grep for table with those column headers |
| SC-4 | RED-GREEN Daisy-Chain table exists with columns: step name, owning skill, dispatch string, description | string | grep for table with those column headers |
| SC-5 | Per-Task Cycle section defines the RED→GREEN→COMMIT sequence | string | grep for RED, GREEN, COMMIT step definitions |
| SC-6 | Post-implementation table exists with columns: step name, owning skill, dispatch string, description | string | grep for table with those column headers |
| SC-7 | Coercion Rules section documents DONE_WITH_CONCERNS → FAIL and evidence type mismatch rules | string | grep for coercion rule definitions |
| SC-8 | Artifact Retention section documents what gets cleaned when | string | grep for artifact retention rules |
| SC-9 | All existing cross-references to this file from other task files remain valid after rewrite | string | grep for all reference paths in task files still resolve |
| SC-10 | Plan writer task files (create.md, research.md, validate.md) still read the file at the same path | string | grep for unchanged read paths in those task files |

## Not Included

- No changes to any task files that consume this reference doc
- No changes to the writing-plans skill card (SKILL.md)
- No changes to the pipeline enforcement rules themselves — only the reference doc format
- No new data tables beyond the 3 focused tables listed in SC-1
- No consumer-side behavioral changes — consumers read the same data at the same path
- No Gate Sequence section — ordering is now implicit in the 3-table grouping (Pre-implementation → RED-GREEN Daisy-Chain → Post-implementation)
- No Audit Sequence Exception section — audit details are now in the Post-implementation table's audit row

## Items

| Item | SCs | Description |
|------|-----|-------------|
| Strip orchestrator content | SC-1, SC-2 | Remove YAML frontmatter, Persona, Worktree Mode, Mandatory Task Discipline, DISPATCH_GATE, Sub-Agent Routing, Invocation, Orchestrator Entry Criteria, State Management, Remediation Routing, Lifecycle Manifest, Pipeline Enforcement Rules, Sub-agent Context Shape, Context Passing, Dispatch Mode Verification Gate, Overflow Signal, Cross-References |
| Consolidate 5 representations into 3 tables | SC-1, SC-3, SC-4, SC-6 | Replace Pipeline Step Catalog, Trigger Dispatch Table, Gate Sequence, Audit Sequence Exception, and Artifact Pre-Cleanup with 3 phase-grouped tables (Pre-implementation, RED-GREEN Daisy-Chain, Post-implementation), each carrying all 4 columns |
| Preserve cross-cutting sections | SC-5, SC-7, SC-8 | Keep Per-Task Cycle, Coercion Rules, and Artifact Retention as standalone sections |
| Verify cross-references | SC-9, SC-10 | Confirm all task files that reference this path still resolve |

## Documentation Sources

| Source | Path | Purpose |
|--------|------|---------|
| Current reference file | `skills/writing-plans/reference/implementation-workflow.md` | Source content to be restructured |
| Plan writer create task | `skills/writing-plans/tasks/create.md` | Consumer — reads this reference doc |
| Plan writer research task | `skills/writing-plans/tasks/research.md` | Consumer — reads this reference doc |
| Plan writer validate task | `skills/writing-plans/tasks/validate.md` | Consumer — reads this reference doc |
| Spec auditor tasks | `skills/audit/tasks/` | Consumer — may reference dispatch strings |
| Plan auditor tasks | `skills/audit/tasks/` | Consumer — may reference dispatch strings |

## Requirements

- REQ-1: The file must remain at `skills/writing-plans/reference/implementation-workflow.md` (path must not change)
- REQ-2: All existing cross-references from other task files must remain valid
- REQ-3: The 3 focused tables must contain all current dispatch entries (pre-regression, pre-regression-verify, red, green, post-regression, verify, commit-inline, audit, z3-check, structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary)
- REQ-4: The Per-Task Cycle must match the current RED→GREEN→COMMIT sequence
- REQ-5: No orchestrator-level routing content (Persona, Worktree Mode, Mandatory Task Discipline, DISPATCH_GATE, Sub-Agent Routing)
- REQ-6: No redundant representations — each step appears in exactly one table with all 4 columns

## Dependencies

- **File path stability:** The file must remain at `skills/writing-plans/reference/implementation-workflow.md` — all cross-references from other task files reference this path and must remain valid
- **Cross-reference integrity:** Every task file that reads this path must continue to resolve after the rewrite
- **No consumer-side changes:** No task files that consume this reference doc may be modified as part of this change
- **Implicit dependency — consumer task file structure:** The plan writer task files (create.md, research.md, validate.md) must continue to exist at their current paths with their current read-file instructions. If any of these task files are restructured, the reference doc rewrite may produce stale or orphaned data tables.
- **Implicit dependency — audit task file structure:** Spec auditor and plan auditor task files that reference dispatch strings from this file must continue to exist at their current paths. If audit task files are restructured, the table entries may become stale.
- **Implicit dependency — no concurrent edits:** No other agent or process may modify the reference file or any consuming task files during the rewrite window. Concurrent edits would produce merge conflicts or inconsistent state.

## Phases

| Phase | SCs | Description |
|-------|-----|-------------|
| 1 (REQ-5, REQ-6) | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8 | Rewrite the file: strip orchestrator content, consolidate 5 representations into 3 tables, preserve cross-cutting sections |
| 2 (REQ-1, REQ-2) | SC-9, SC-10 | Verify all cross-references remain valid |

## Enforcement Gate

- [ ] **Pre-commit:** Any remaining orchestrator content (Persona, Worktree Mode, etc.) or redundant representations (Pipeline Step Catalog, Trigger Dispatch Table, Gate Sequence, Audit Sequence Exception) → BLOCK — grep for prohibited section headers
- [ ] **Pre-PR:** Cross-reference integrity → BLOCK — grep for broken read paths in consuming task files
- [ ] **Post-merge:** Consumer task file changes → FLAG — verify no consumer-side changes were introduced

## Cost Frame

| Dimension | Estimate | Rationale |
|-----------|----------|-----------|
| File size | ~124 lines → ~100 lines | Consolidating 5 representations into 3 tables reduces redundancy; cross-cutting sections preserved |
| Verification | Low (string evidence only) | All SCs verified by grep — no behavioral tests needed |
| Risk | Low | No consumer-side changes; path stability guaranteed by REQ-1 |
| Revert cost | Low | Single file revert; no downstream artifacts to clean |

## Edge Cases

| Case | Handling |
|------|----------|
| DONE_WITH_CONCERNS referenced in SC-7 but not defined in current spec | Define in Coercion Rules section of the rewritten file: DONE_WITH_CONCERNS is a verification verdict meaning "all SCs pass but with documented concerns that do not block completion." It is coerced to FAIL by the Coercion Rules section — any non-clean pass is treated as FAIL for pipeline gate purposes. |
| File already partially rewritten mid-session | Read current file state before each edit; do not assume prior state |
| Cross-reference to a section that no longer exists | All cross-references point to the file path, not section anchors — path stability guarantees resolution |
| Consumer task file references section headers that get removed | Verify consuming task files reference the file path only, not section anchors within it |
| Gate Sequence section removed — consumers may rely on ordered list | Ordering is now implicit in the 3-table grouping (Pre-implementation → RED-GREEN Daisy-Chain → Post-implementation). Consumers that read the file for ordering will find the same sequence expressed as table order. |

## Alternatives Considered

| Alternative | Description | Why Not Chosen |
|-------------|-------------|----------------|
| Delete and recreate the file from scratch | Remove the file entirely and write a fresh reference doc | Loses git history and provenance trail. The rewrite preserves the file path and git history — consumers see a diff, not a new file. |
| Keep orchestrator content as-is, add data tables alongside | Append data tables without removing existing routing sections | Sub-agents would still encounter orchestrator-level routing instructions they cannot execute. The core problem is the presence of routing content, not the absence of data tables. |
| Move data tables to a separate file, keep routing content in current file | Split into two files: one for orchestrator routing, one for sub-agent data | REQ-1 requires the file path to remain stable. Splitting would break all existing cross-references. Consumer task files read this specific path — a split would require consumer-side changes, which are out of scope. |
| Convert to YAML data file instead of Markdown | Store the data catalog as structured YAML consumed programmatically | Consumer task files use `read` tool on Markdown files. A YAML format would require consumer-side changes to parse differently, violating the no-consumer-changes constraint. |
| Keep 5 representations but add a cross-reference index | Add a lookup table mapping each step to its row in each representation | Does not solve the core problem: consumers must still cross-reference 5 tables to get the full picture for any single step. The cross-reference index adds another representation without removing redundancy. |

## Traceability

| Requirement | SCs |
|-------------|-----|
| REQ-1 | SC-9, SC-10 |
| REQ-2 | SC-9 |
| REQ-3 | SC-3, SC-4, SC-6 |
| REQ-4 | SC-5 |
| REQ-5 | SC-1, SC-2 |
| REQ-6 | SC-1, SC-3, SC-4, SC-6 |

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-07-31 | Added Dependencies section | Missing Dependencies section — required per 11-dimension completeness check | Pipeline (validation findings) |
| 2026-07-31 | Added REQ references to phase table headings | Phase table headings lacked REQ references — required per structural validation phase coverage check | Pipeline (validation findings) |
| 2026-07-31 | Added SC-3, SC-6, SC-7, SC-8 to REQ-5 traceability row | Traceability table missing SC-3, SC-6, SC-7, SC-8 — all map to REQ-5 per validation findings | Pipeline (validation findings) |
| 2026-08-01 | Added Not Included, Items, Documentation Sources, Enforcement Gate, Cost Frame, Edge Cases sections | Spec audit found 6 missing required sections — remediate completeness FAIL | Pipeline (spec-audit findings) |
| 2026-08-01 | Added provenance evidence block to Background section | Spec audit found core claim about file content type asserted without tool-call evidence — remediate provenance FAIL | Pipeline (spec-audit findings) |
| 2026-08-01 | Added DONE_WITH_CONCERNS definition to Edge Cases | Term referenced in SC-7 but undefined — remediate completeness FAIL | Pipeline (spec-audit findings) |
| 2026-08-01 | Added 3 implicit dependencies to Dependencies section | Implicit dependencies not enumerated — remediate completeness FAIL | Pipeline (spec-audit findings) |
| 2026-08-01 | Converted Enforcement Gate from table to canonical checklist format | SC-PIPELINE-GATES FAIL — table format not canonical checklist format | Pipeline (re-audit findings) |
| 2026-08-01 | Added Intent & Executive Summary section with 6 fields | SC-STRUCTURAL-PREAMBLE FAIL — missing combined Intent & Executive Summary section | Pipeline (re-audit findings) |
| 2026-08-01 | Added Alternatives Considered section | Research adequacy gap noted by evaluator — document alternatives and rationale | Pipeline (re-audit findings) |
| 2026-08-01 | Restructured reference file from 5 redundant representations to 3 focused tables (Pre-implementation, RED-GREEN Daisy-Chain, Post-implementation); each table carries all 4 columns (step name, owning skill, dispatch string, description) in one place. Removed Gate Sequence and Audit Sequence Exception sections. Updated SC-1 through SC-8 to reflect new 3-table structure. Updated Background to explain simplification rationale. Updated Not Included, Items, Requirements, Phases, Enforcement Gate, Cost Frame, Edge Cases, Alternatives Considered, and Traceability sections. | Revision request: consolidate 5 redundant representations into 3 focused tables | Pipeline (revision request) |
