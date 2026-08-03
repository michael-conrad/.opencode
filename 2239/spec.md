> GitHub Issue: https://github.com/michael-conrad/.opencode/issues/2239

# [SPEC] Remove redundant check-pr task, fix cleanup processing order

## Problem Statement

The `git-workflow-cleanup` skill has a redundant `check-pr.md` task file that duplicates logic already present in `cleanup.md`. The `check-pr` task was created as a separate entry point for "check pr" trigger phrases, but `cleanup.md` already contains all the same logic (PR scan, verify-merge, issue-closure, branch-cleanup). This creates confusion about which task to dispatch and increases maintenance surface area.

Additionally, `cleanup.md` processes the parent repo before submodules in Step 3 (branch-cleanup) and Step 4 (post-cleanup dev-tip verification). The correct order is submodules first, then parent — because submodule cleanup is a prerequisite for parent repo state verification.

## Root Cause / Motivation

The `git-workflow-cleanup` skill has two task files (`check-pr.md` and `cleanup.md`) that implement the same logic — PR scan, verify-merge, issue-closure, branch-cleanup. The `check-pr.md` file was created as a separate entry point for "check pr" trigger phrases, but `cleanup.md` already handles all of that. This duplication creates a maintenance trap: every future agent that encounters "check pr" in the TDT must decide between two identical tasks, and every wrong decision is a defect.

Additionally, `cleanup.md` processes the parent repo before submodules in branch-cleanup and post-cleanup dev-tip verification. The parent repo's `git status` and branch state depend on submodule state — verifying parent first produces false positives. Submodules-first is the only correct dependency order.

## Approach Chosen

Delete the redundant `check-pr.md` task file, remove all references to it from skill and task files, and fix the cleanup processing order to process submodules before the parent repo. Route the "check pr" TDT entry to the existing `cleanup` task for backward compatibility.

## Alternatives Considered & Why Discarded

| Alternative | Why Discarded |
|-------------|---------------|
| Keep `check-pr.md` and redirect it to call `cleanup.md` internally | Adds indirection without removing the maintenance trap. Agents still must decide which task to dispatch. |
| Merge both tasks into a single `pr-operations.md` | Larger refactor than needed. The `cleanup.md` task is well-structured; only the duplicate needs removal. |
| Keep both and add a deprecation warning to `check-pr.md` | Deprecation warnings are invisible to agents. The TDT entry would still be parsed and dispatched. |

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Delete `check-pr.md` outright rather than deprecating | Deprecation is invisible to AI agents — they parse the TDT and dispatch. A deleted file with no TDT entry is the only unambiguous signal. |
| Route "check pr" TDT entry to `cleanup` task | Backward compatibility: existing "check pr" trigger phrases continue to work. The routing change is in `git-workflow/SKILL.md` TDT only. |
| Submodules-first in both branch-cleanup and dev-tip verification | Consistent dependency ordering. Submodule state must be resolved before parent repo state can be accurately verified. |

## User Intent / Original Prompt

The user requested: "Remove the redundant check-pr task from git-workflow-cleanup and fix the cleanup processing order to process submodules before the parent repo."

## Requirements

| ID | Requirement | SHALL Statement |
|----|-------------|-----------------|
| R-1 | Remove redundant task file | The system SHALL delete `check-pr.md` from `.opencode/skills/git-workflow-cleanup/tasks/` |
| R-2 | Update cleanup skill references | The system SHALL remove all `check-pr` references from `git-workflow-cleanup/SKILL.md` |
| R-3 | Update workflow skill references | The system SHALL remove all `check-pr` references from `git-workflow/SKILL.md` |
| R-4 | Update cleanup task references | The system SHALL remove all `check-pr` references from `cleanup.md` |
| R-5 | Fix branch-cleanup order | The system SHALL process submodules before parent in `cleanup.md` Step 3 |
| R-6 | Fix verification order | The system SHALL list submodules before parent in `cleanup.md` Step 4 |
| R-7 | Behavioral backward compatibility | Dispatching "check pr" SHALL route to `git-workflow-cleanup --task cleanup` |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `check-pr.md` SHALL be deleted from `.opencode/skills/git-workflow-cleanup/tasks/` | structural | `! test -f .opencode/skills/git-workflow-cleanup/tasks/check-pr.md` |
| SC-2 | `git-workflow-cleanup/SKILL.md` SHALL have no `check-pr` references in its TDT or Tasks table | structural | `grep for 'check-pr' in .opencode/skills/git-workflow-cleanup/SKILL.md` |
| SC-3a | `git-workflow/SKILL.md` SHALL have no `check-pr` references in its TDT, Invocation section, or Sub-Skills table | structural | `grep for 'check-pr' in .opencode/skills/git-workflow/SKILL.md` |
| SC-3b | `git-workflow/SKILL.md` SHALL list the `git-workflow-cleanup` task count as 3 | structural | `Count task entries in git-workflow-cleanup Sub-Skills table` |
| SC-5 | `cleanup.md` SHALL have no `check-pr` references in its "Related tasks" or "Automatic Cleanup Detection" sections | structural | `grep for 'check-pr' in .opencode/skills/git-workflow-cleanup/tasks/cleanup.md` |
| SC-6 | `cleanup.md` Step 3 SHALL specify submodule-first iteration order for branch-cleanup | structural | `cleanup.md` current state |
| SC-7 | `cleanup.md` Step 4 SHALL list submodules before parent in the repo verification list | structural | `cleanup.md` current state |
| SC-8 | Dispatching "check pr" via `opencode run` SHALL route to `git-workflow-cleanup --task cleanup` (not `check-pr`) | behavioral | `opencode run` with 'check pr' trigger, inspect stderr for dispatch target |

## Items

### Item 1 (SC-1): Delete check-pr.md

- RED: `test -f .opencode/skills/git-workflow-cleanup/tasks/check-pr.md` passes (file exists before deletion)
- GREEN: Delete `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md`
- verify: `! test -f .opencode/skills/git-workflow-cleanup/tasks/check-pr.md`
- commit: Delete check-pr.md

### Item 2 (SC-2): Remove check-pr from git-workflow-cleanup/SKILL.md

- RED: Grep for `check-pr` in `git-workflow-cleanup/SKILL.md` finds matches
- GREEN: Remove `check-pr` row from TDT and Tasks table in `git-workflow-cleanup/SKILL.md`
- verify: Grep for `check-pr` in `git-workflow-cleanup/SKILL.md` finds no matches
- commit: Update git-workflow-cleanup/SKILL.md

### Item 3 (SC-3a, SC-3b): Remove check-pr from git-workflow/SKILL.md

- RED: Grep for `check-pr` in `git-workflow/SKILL.md` finds matches; task count is 4
- GREEN: Remove `check-pr` from TDT, Invocation, Sub-Skills; update task count to 3
- verify: Grep for `check-pr` in `git-workflow/SKILL.md` finds no matches; task count is 3
- commit: Update git-workflow/SKILL.md

### Item 4 (SC-5): Remove check-pr from cleanup.md

- RED: Grep for `check-pr` in `cleanup.md` finds matches
- GREEN: Remove `check-pr` references from Related tasks and Automatic Cleanup Detection sections
- verify: Grep for `check-pr` in `cleanup.md` finds no matches
- commit: Update cleanup.md

### Item 5 (SC-6): Fix branch-cleanup order in cleanup.md Step 3

- RED: Read Step 3, verify parent-first iteration order
- GREEN: Update Step 3 to process submodules before parent
- verify: Read Step 3, verify submodule-first iteration order
- commit: Update cleanup.md Step 3

### Item 6 (SC-7): Fix verification order in cleanup.md Step 4

- RED: Read Step 4, verify parent-first listing
- GREEN: Update Step 4 to list submodules before parent
- verify: Read Step 4, verify submodule-first listing
- commit: Update cleanup.md Step 4

### Item 7 (SC-8): Verify behavioral backward compatibility

- RED: `opencode run` with "check pr" trigger dispatches to `check-pr` task (or no dispatch at all)
- GREEN: TDT routes "check pr" to `git-workflow-cleanup --task cleanup`
- verify: `opencode run` with "check pr" trigger, inspect stderr for dispatch to `cleanup`
- commit: No code change — verification only

## Traceability

| SC ID | Requirement ID | Item ID | Verification Method |
|-------|---------------|---------|---------------------|
| SC-1 | R-1 | I-1 | `! test -f .opencode/skills/git-workflow-cleanup/tasks/check-pr.md` |
| SC-2 | R-2 | I-2 | `grep for 'check-pr' in .opencode/skills/git-workflow-cleanup/SKILL.md` |
| SC-3a | R-3 | I-3 | `grep for 'check-pr' in .opencode/skills/git-workflow/SKILL.md` |
| SC-3b | R-3 | I-3 | `Count task entries in git-workflow-cleanup Sub-Skills table` |
| SC-5 | R-4 | I-4 | `grep for 'check-pr' in .opencode/skills/git-workflow-cleanup/tasks/cleanup.md` |
| SC-6 | R-5 | I-5 | Read Step 3, verify submodule-first iteration |
| SC-7 | R-6 | I-6 | Read Step 4, verify submodule-first listing |
| SC-8 | R-7 | I-7 | `opencode run` with 'check pr' trigger, inspect stderr for dispatch target |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `pre-spec-inspection.yaml` | config | `.opencode/.issues/2239/artifacts/pre-spec-inspection.yaml` | Read file |
| `cleanup.md` current state | code | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` | Read file |
| `git-workflow/SKILL.md` TDT | code | `.opencode/skills/git-workflow/SKILL.md` | Read file |

## Dependencies

| Reference | Relationship | Status |
|-----------|-------------|--------|
| Phase 1 → Phase 2 | Phase 1 and Phase 2 are independent — either can be implemented first | Satisfied |
| SC-1 → SC-2/SC-3a/SC-3b/SC-5 | Within Phase 1: SC-1 (delete file) must precede SC-2/SC-3a/SC-3b/SC-5 (update references) | Pending |
| SC-8 → all others | SC-8 (behavioral verification) must be last | Pending |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

- **SC-1 through SC-3b (remove check-pr):** Verifying file deletion and reference removal costs a grep and file-existence check — near-zero. Skipping verification costs a maintenance trap that every future agent must navigate, producing wrong dispatch decisions indefinitely.
- **SC-6 through SC-7 (fix processing order):** Verifying submodule-first order costs reading two step definitions — near-zero. Skipping verification costs false-positive state verification on every cleanup run, producing undetected dirty submodule state.
- **SC-8 (behavioral backward compatibility):** Verifying behavioral backward compatibility costs one `opencode run` invocation — measurable but bounded. Skipping verification costs a silent dispatch break that only surfaces when an agent uses "check pr" in production.

## Edge Cases

| Edge Case | Expected Behavior | Resolution |
|-----------|-------------------|------------|
| `check-pr.md` already deleted (partial state) | SC-1 verification passes; remaining SCs still enforced | RED phase detects file absence, GREEN is no-op, verify confirms absence |
| `cleanup.md` has additional `check-pr` references not listed in spec | All references must be removed — spec lists known locations, but grep-based verification catches any missed ones | Grep-based verification is exhaustive; no additional resolution needed |
| "check pr" trigger dispatched during transition (TDT updated but old dispatch still cached) | Agent dispatches based on current TDT; no caching layer exists in opencode dispatch | No resolution needed — caching is not a concern |
| Submodule has no branches to clean (empty submodule) | Step 3 iteration handles empty submodules gracefully — no-op is acceptable | No resolution needed — graceful handling is expected |
| Behavioral test times out | Per TDD integrity rules: diagnose timeout cause, do not weaken assertion | Diagnose timeout cause, remediate infrastructure, re-run |

## Approach

### Phase 1: Remove check-pr.md and update references

1. Delete `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md`
2. Update `git-workflow-cleanup/SKILL.md`:
   - Remove `check-pr` row from TDT
   - Remove `check-pr` row from Tasks table
3. Update `git-workflow/SKILL.md`:
   - Remove `check-pr` row from TDT (row 7)
   - Remove `check-pr` row from Invocation section (row 7)
   - Update Sub-Skills table: `git-workflow-cleanup` task count from 4 to 3
4. Update `cleanup.md`:
   - Remove "Related tasks" reference to check-pr
   - Remove "Check PR" Workflow subsection from "Automatic Cleanup Detection"
   - Remove "check pr" / "check prs" from "Entry triggers" (these phrases are handled by git-workflow/SKILL.md TDT routing to cleanup)

### Phase 2: Fix cleanup processing order

1. Update `cleanup.md` Step 3 (branch-cleanup): Change iteration order to process submodules before parent
2. Update `cleanup.md` Step 4 (post-cleanup dev-tip verification): Change repo list to list submodules before parent

## Affected Files

| File | Change Type | Phase |
|------|-------------|-------|
| `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` | DELETE | 1 |
| `.opencode/skills/git-workflow-cleanup/SKILL.md` | MODIFY (TDT, Tasks table) | 1 |
| `.opencode/skills/git-workflow/SKILL.md` | MODIFY (TDT, Invocation, Sub-Skills) | 1 |
| `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` | MODIFY (remove check-pr refs) | 1 |
| `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` | MODIFY (Step 3, Step 4 order) | 2 |

## Not Included

- Changes to `pair-cleanup` task — not affected by this spec
- Changes to `git-workflow-cleanup` task file count in any other location
- Any changes outside the `.opencode` submodule

## Open Questions

None.

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-03 | Split SC-3 into SC-3a (no check-pr references) and SC-3b (task count = 3). Re-numbered SC-4→SC-5, SC-5→SC-6, SC-6→SC-7, SC-7→SC-8. Updated Cost-Frame Statements and Dependencies to match. | SC-3 was compound — bundled two independently verifiable claims. | Pipeline (spec-creation revise task) |
| 2026-08-03 | Added Root Cause/Motivation, User Intent/Original Prompt, Alternatives Considered & Why Discarded, Key Design Decisions, Requirements (R-1 through R-7 with SHALL language), Items (I-1 through I-7), Traceability table, Enforcement Gate section, Edge Cases section. | Spec FAILS validation on completeness (missing 4 of 6 required preamble fields) and traceability (missing Requirements, Items, Traceability, Enforcement Gate, Edge Cases). | Pipeline (spec-creation revise task) |
| 2026-08-03 | Reordered preamble fields to match spec-structure-standards.md §1 order. Extracted Approach Chosen as standalone preamble field. Renamed SC table columns (Description→Criterion, Documentation Sources→Verification Method). Added standalone Documentation Sources section (§8). Converted Items to per-item TDD cycle format. Changed Enforcement Gate from table to blockquote. Changed Cost Frame from paragraphs to per-SC format. Added Resolution column to Edge Cases. Added Reference/Relationship/Status columns to Dependencies. | Spec FAILS validation on 8 format-level deviations from spec-structure-standards.md. | Pipeline (spec-creation revise task) |
| 2026-08-03 | Fixed SC-8 Verification Method from `git-workflow/SKILL.md TDT` to `opencode run` with 'check pr' trigger, inspect stderr for dispatch target. Fixed SC-1 through SC-5 Verification Method from `pre-spec-inspection.yaml` to concrete procedures. Updated Traceability table Verification Method column to match. | Validation FAIL: SC-8 evidence type mismatch (behavioral vs string/structural), SC-1–SC-5 WARN for artifact-filename references instead of concrete procedures. | Pipeline (spec-creation revise task) |
