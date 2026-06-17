# Plan: Spec writer must embed compliance requirement notice in all generated specs

## Classification
- **Type:** single-task
- **Phases:** 1
- **PR Strategy:** stacked

## Phase 1: Template Update

### Concern
Add compliance requirement blockquote to spec body template at two positions in `write.md`.

### Items

#### Item 1: Add blockquote at top position (after STATUS/CREATED header)
- **RED:** Write behavioral enforcement test that verifies the spec writer does NOT include the compliance blockquote at the top of generated specs (test fails before change)
- **GREEN:** Edit `write.md` spec body template to include the compliance requirement blockquote after the STATUS/CREATED header
- **REFACTOR:** Verify SC-1 passes

#### Item 2: Add blockquote before success criteria table
- **RED:** Write behavioral enforcement test that verifies the spec writer does NOT include the compliance blockquote before the SC table (test fails before change)
- **GREEN:** Edit `write.md` spec body template to include the compliance requirement blockquote before the success criteria table
- **REFACTOR:** Verify SC-2 passes

#### Item 3: Verify only write.md changed
- **REFACTOR:** Run `git diff --name-only` to confirm only `write.md` is modified
- **REFACTOR:** Verify SC-3 passes

### Success Criteria Mapping
| ID | Criterion | Item |
|----|----------|------|
| SC-1 | Blockquote at top of generated spec body | Item 1 |
| SC-2 | Blockquote before success criteria table | Item 2 |
| SC-3 | Only write.md changed | Item 3 |

### Files Affected
- `.opencode/skills/spec-creation/tasks/write.md`
