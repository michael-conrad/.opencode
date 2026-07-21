---
title: "SPEC-FIX: 4 naming inconsistency patterns across skill deck task cards"
status: draft
created: 2026-07-20
license: MIT
provenance: AI-generated
issue: 2041
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-20

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order.

## Problem

4 naming inconsistency patterns exist across the skill deck, making it difficult for the orchestrator to resolve task card references:

1. **Hyphenated vs underscored subdirectories** — `pre-implementation-analysis.md` (hyphenated) vs `pre_impl/` subdirectory (underscored) in `approval-gate-scope`
2. **Task name vs subdirectory name mismatch** — `screen-issue.md` exists as top-level file but subdirectory is named `screen/` (not `screen-issue/`); `pre-implementation-analysis.md` exists but subdirectory is `pre-impl/` (not `pre-implementation-analysis/`)
3. **TDT name vs actual file name mismatch** — `multimodal-dispatch` TDT references task `route` but actual files are `dispatch.md` and `dispatch-multi.md` — no `route.md` exists
4. **writing-plans task routing split** — `writing-plans` SKILL.md TDT references `create`, `update`, `retroactive`, `holistic-self-check` but has no `tasks/` directory. Task files exist in sibling skills `writing-plans-creation/tasks/` and `writing-plans-holistic/tasks/`

## Root Cause

Inconsistent naming conventions were applied during skill creation. Some skills use hyphenated names, others use underscores. Some TDT entries were written before the corresponding task files were created, leading to name mismatches.

## Fix

Standardize naming:
1. Convert `pre_impl/` to `pre-impl/` (hyphenated to match the parent file)
2. Rename `screen/` to `screen-issue/` to match the parent file
3. Create `route.md` or update TDT to reference `dispatch.md`
4. Either add `tasks/` directory to `writing-plans` or update TDT to reference sibling skill paths

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All subdirectory names match their parent task file names | `string` | Verify each subdirectory name matches the parent file name |
| SC-2 | All TDT task names match actual file names | `string` | Cross-reference all TDT entries against filesystem |
| SC-3 | `writing-plans` has a `tasks/` directory or TDT references sibling skills | `string` | Verify resolution of pattern 4 |

---

*Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)*
