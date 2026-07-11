# Plan: Fix Systemic Skill Card Validation Failures

## Goal

Reconcile three conflicting validation systems to the opencode binary's actual frontmatter schema, fix two over-limit descriptions, and create a local reference doc as ground truth.

## Architecture

Four independent phases, each touching a different file. No shared state between phases. Phases execute sequentially because each depends on the reference doc (Phase 1) being available for validation tooling (Phases 2-3) to reference.

## Files

| File | Change | Phase |
|------|--------|-------|
| `.opencode/reference/skill-card-schema.md` | **NEW** — binary frontmatter schema reference | 1 |
| `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | Add binary constraint checks, remove CSO prefix check, drop `type` field | 2 |
| `.opencode/plugins/session-enforcement.ts` | Remove CSO "Use when" check, update warning block, remove `type` from fix template | 3 |
| `.opencode/skills/writing-plans/SKILL.md` | Trim description from 1124→≤1024 chars | 4 |
| `.opencode/skills/spec-creation/SKILL.md` | Trim description from 1118→≤1024 chars | 4 |

## Phase Table

| Phase | Concern | Target | SCs |
|-------|---------|--------|-----|
| 1 | Reference doc | `.opencode/reference/skill-card-schema.md` | SC-1, SC-2, SC-3, SC-4, SC-5 |
| 2 | Validator fix | `validate_skill_cards.py` | SC-6, SC-7, SC-8, SC-9, SC-10 |
| 3 | Session enforcement | `session-enforcement.ts` | SC-11, SC-12, SC-13 |
| 4 | Description trim | `writing-plans/SKILL.md`, `spec-creation/SKILL.md` | SC-14, SC-15 |

## Exit Criteria

- All 13 SCs verified PASS
- `validate_skill_cards.py` runs clean against all 40 SKILL.md files
- `session-enforcement.ts` compiles with `npx tsc --noEmit`
- Both trimmed descriptions ≤ 1024 chars
- PR created against `.opencode` repo `main` branch
