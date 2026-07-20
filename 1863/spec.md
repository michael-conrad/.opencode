# SPEC-FIX: Resolve Committed Merge Conflict Markers in writing-plans

## Problem

Merge commit `22a2a853` (PR #1859, merge of feature/492-stale-branch-detection) contains unresolved conflict markers in the committed tree. Three conflict blocks across two files:

| File | Lines | Sides |
|------|-------|-------|
| `skills/writing-plans/SKILL.md` | 3-7 | Description field: #1855 noun-phrase format vs stale stash "Use when" format |
| `skills/writing-plans/SKILL.md` | 49-59 | Dispatch table: #1835 artifact HALT rows vs #1853 holistic-self-check row |
| `skills/writing-plans/tasks/create.md` | 10-106 | #1850 Step 0 pre-flight gate vs #1853 template sections |

**Root cause:** Stash `@{0}` (WIP on #1815 at commit `268781f4`) contained uncommitted writing-plans changes. When PR #1859 merged, the stash was applied during the merge, creating conflicts that were committed unresolved.

**Intent chain (chronological):**
1. #1835 — added 7 analytical artifact HALT rows to dispatch table
2. #1850 — added Step 0 holistic evaluation gate to create.md
3. #1855 — rewrote all 43 SKILL.md descriptions to noun-phrase format
4. #1853 — added holistic self-check to description + dispatch table + template sections to create.md
5. #492 — stale-branch detection (no writing-plans impact)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | No conflict markers in `skills/writing-plans/SKILL.md` | `string` | `grep -c '<<<<<<<'` returns 0 |
| SC-2 | No conflict markers in `skills/writing-plans/tasks/create.md` | `string` | `grep -c '<<<<<<<'` returns 0 |
| SC-3 | Description field uses #1855 noun-phrase format with #1853 holistic self-check additions | `string` | grep for "Implementation plan creator" + "holistic self-check" |
| SC-4 | Dispatch table has both #1835 artifact HALT rows and #1853 holistic-self-check row | `string` | grep for "blast-radius artifact missing" + "holistic check" |
| SC-5 | create.md has both #1850 Step 0 pre-flight gate and #1853 template sections | `string` | grep for "Holistic Spec Evaluation" + "Plan Template Sections" |
| SC-6 | YAML frontmatter is valid (no conflict markers in YAML) | `string` | `python -c "import yaml; yaml.safe_load(open('skills/writing-plans/SKILL.md').read().split('---')[1])"` succeeds |

## Files Affected

| File | Change |
|------|--------|
| `skills/writing-plans/SKILL.md` | Resolve 2 conflict blocks (description + dispatch table) |
| `skills/writing-plans/tasks/create.md` | Resolve 1 conflict block (Step 0 + template sections) |

## Out of Scope

- Changes to other files
- Changes to the stash (stash@{0} is preserved)
- Behavioral enforcement tests (this is a mechanical fix of committed conflict markers)

## No-Lobotomize Clause

**Any skipped, deferred, or otherwise attempted bypass of an SC failure marks ALL SCs as FAIL. The PR must be immediately rejected and trashed as defective and unusable.**

---

🤖 OpenCode (ollama-cloud/deepseek-v4-flash)