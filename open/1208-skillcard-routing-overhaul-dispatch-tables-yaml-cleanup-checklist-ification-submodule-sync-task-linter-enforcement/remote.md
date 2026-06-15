---
remote_issue: 1208
remote_url: "https://github.com/michael-conrad/.opencode/issues/1208"
last_sync: 2026-06-14T20:48:10Z
source: github.com
---

## Problem
- The #553 dispatch table removal left git-workflow with no trigger-to-task routing
- Investigation revealed the same gap across ALL 39 SKILL.md files
- Most skills have no structured mapping from user intent to task dispatch
- approval-gate has 13 tasks with zero routing guidance — worst offender
- 6 skills have orphan tasks with no invocation path
- YAML frontmatter contains dead "Triggers on:" keyword lists the pre-response gate never reads
- SKILL.md bodies contain AI bylines, stats, and word counts that add no routing value
- Operating protocols use prose paragraphs for sequential steps, enabling step-skipping
- skildeck has no validation for dispatch table presence

## Solution — 5 Workstreams

### Workstream A — YAML Frontmatter Cleanup
Scope: All 39 SKILL.md files
Changes:
- Remove `Triggers on:` keyword lists from YAML frontmatter descriptions
- Remove `provenance: "🤖 Co-authored with AI: ..."` from YAML frontmatter  
- Remove AI byline signoff lines from SKILL.md bodies (lines like `Co-authored with AI: ...`)
- Remove any word counts, line counts, or statistics from card bodies
- Descriptions become clean "Use when..." NLU prose — semantic not taxonomic
No dependencies — can execute first.

### Workstream B — Trigger Dispatch Tables
Scope: All 39 SKILL.md files
Changes:
- Add a "Trigger Dispatch Table" section to every SKILL.md body after the Overview
- Columns: `User says / Context | Task | Dispatch | Context passed`
- `Dispatch` column: `sub-task` (clean-room delegate), `blind sub-task` (no context besides what is in the Context column), `inline` (orchestrator does directly)
- Every skill gets a table. Single-task skills get one row. Zero exceptions.
- Cross-skill routing audit: verify no two dispatch tables claim the same primary trigger phrase. Resolve conflicts by routing to the more specific skill.
- The table must cover ALL user-facing trigger scenarios the skill can receive
Dependencies: Sequence after Workstream A (same files, different sections — merge-safe but sequential avoids conflicts).

### Workstream C — Procedure Checklist-ification
Scope: All SKILL.md Operating Protocols + all task files with procedural steps
Changes:
- Convert prose-embedded numbered step descriptions to `- [ ] N. ...` checklist format
- Every sequential procedure section becomes a mandatory checklist
- Prevents step skipping and incomplete execution
- Applies to Operating Protocol sections, Procedure sections, and any numbered step list
Dependencies: Depends on B (dispatch tables may restructure section boundaries).

### Workstream D — New submodule-sync Task
Scope: git-workflow skill
Changes:
- New task file at `.opencode/skills/git-workflow/tasks/submodule-sync.md`
- Lightweight: sync dirty submodule pointers to dev tip
- Referenced by git-workflow dispatch table row: `"sync submodules" / "update submodules" → submodule-sync`
Dependencies: Depends on B (dispatch table references the new task).

### Workstream E — skildeck Dispatch Table Validation
Scope: skildeck CLI tool
Changes:
- Add validation rule: every SKILL.md MUST have a Trigger Dispatch Table section
- Format check: must have correct columns, at least one row per task
- Add to skildeck validation pass
Dependencies: Depends on Workstream B (format must be defined before it can be validated).

## Z3 Dependency Contract

```yaml
phases:
  - id: workstream-a
    label: YAML frontmatter cleanup
    depends_on: []
    
  - id: workstream-b
    label: Dispatch tables
    depends_on: [workstream-a]
    
  - id: workstream-c
    label: Checklist-ification
    depends_on: [workstream-b]
    
  - id: workstream-d
    label: Submodule-sync task
    depends_on: [workstream-b]
    
  - id: workstream-e
    label: skildeck linter
    depends_on: [workstream-b]

constraints:
  - "workstream_a_complete → workstream_b_start"
  - "workstream_b_complete → workstream_c_start"
  - "workstream_b_complete → workstream_d_start"  
  - "workstream_b_complete → workstream_e_start"

verify:
  - solve check --contract --query "workstream_a < workstream_b and workstream_b < workstream_c and workstream_b < workstream_d and workstream_b < workstream_e" → SAT
```

## SC-ID Traceability

| SC | Workstream | Criterion | Evidence Type |
|----|-----------|-----------|---------------|
| SC-A1 | A | All 39 YAML frontmatters have clean "Use when..." descriptions with no Triggers on: keywords | string |
| SC-A2 | A | No AI byline lines remain in any SKILL.md body | string |
| SC-B1 | B | All 39 SKILL.md have a Trigger Dispatch Table section | string |
| SC-B2 | B | Every dispatch table has at minimum: User says / Context column, Task column, Dispatch column, Context passed column | string |
| SC-B3 | B | No conflicting primary triggers exist between any two dispatch tables | behavioral (cross-skill audit) |
| SC-B4 | B | Every task listed in a skill's Tasks section has at least one dispatch table row | string |
| SC-C1 | C | All Operating Protocol sequential procedures use - [ ] N. checklist format | string |
| SC-D1 | D | submodule-sync task file exists at the expected path | structural |
| SC-D2 | D | git-workflow dispatch table references submodule-sync for submodule sync triggers | string |
| SC-E1 | E | skildeck validate command checks dispatch table presence in SKILL.md | behavioral |
| SC-E2 | E | skildeck validate reports MISSING_DISPATCH_TABLE for SKILL.md without one | behavioral |
