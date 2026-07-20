# [SPEC-FIX] Resolve Conflicting Skill Description Format Mandates

- **Status:** DRAFT
- **Branch Pattern:** `spec-fix/skill-description-format-alignment`
- **Depends On:** #1881 (skill split audit)

## Problem

Two authoritative sources mandate **mutually exclusive** description formats for skill card `description` fields:

| Source | Authority | Format Name | Pattern |
|--------|-----------|-------------|---------|
| `.opencode/skills/skill-creator/reference/routing-only-template.md` | **Canonical template** (all new skills MUST use) | **Agent-Intent Pattern** | `"<Noun phrase>. Dispatch when <agent-facing triggers>. Also dispatch when <additional triggers>. <Enforcement>. User phrases: <user triggers>."` |
| `.opencode/skills/skill-creator/tasks/validate.md` (validation task) | Mechanical validation (REQ-2) | **Farmage/CSO Pattern** | `"Use when <primary>. Also use when <secondary>. Invoke for: <tasks>. <Enforcement>. Trigger phrases: <phrases>."` |

**All 37 existing skills follow Agent-Intent Pattern** (matching the canonical template). The Farmage Pattern is only enforced by the validation task.

### Concrete Conflict

**Agent-Intent (canonical):**
```yaml
description: "Git branch, commit, push, and PR workflow manager with cleanup and provenance tracking. Dispatch when creating a branch, committing, pushing, or creating a PR. Also dispatch when handling rebase/merge conflicts (invoke conflict-resolution), checking PR state and cleanup, or running provenance tracking. Branch-and-PR discipline is REQUIRED. User phrases: create branch, commit, push, create PR, rebase, merge, check pr, check prs, check merged prs, pr merged, provenance, sync submodules, release PR."
```

**Farmage (validation task REQ-2):**
```yaml
description: "Use when creating a branch, committing, pushing, or creating a PR. Also use when handling rebase/merge conflicts, checking PR state, or running provenance tracking. Invoke for: branch, commit, push, pr, cleanup, provenance. Branch-and-PR discipline is REQUIRED. Trigger phrases: create branch, commit, push, create PR, rebase, merge, check pr, check prs, check merged prs, pr merged, provenance, sync submodules, release PR."
```

These are **semantically different** - Agent-Intent describes *what the skill is* + *when an agent dispatches it*; Farmage describes *when a user invokes it* + *task list*.

## Root Cause

The validation task (`validate.md`) was written to enforce the Farmage Pattern (imported from farmage/opencode-skills repo), but the canonical template (`routing-only-template.md`) was independently authored with the Agent-Intent Pattern. They were never aligned.

## Solution

**Update REQ-2 in `validate.md` to accept Agent-Intent Pattern as the canonical format.**

The validation must check for:
1. **Noun phrase opening** (what the skill IS)
2. **"Dispatch when" clause** (agent-facing trigger conditions)
3. **"Also dispatch when" clause** (additional agent-facing triggers)
4. **Enforcement statement** (REQUIRED/MANDATORY language)
5. **"User phrases:" clause** (preserved user-facing triggers)
6. **Max 1024 characters**
7. **Exclusion clauses** (`— distinct from <exclusion>`) for false-match skills

The Farmage Pattern should be treated as a legacy/alternative format that passes validation but is not the target format for new skills.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `validate.md` REQ-2 updated to specify Agent-Intent Pattern as canonical | structural |
| SC-2 | Validation script (`validate_skill_cards.py`) updated to accept Agent-Intent Pattern | behavioral |
| SC-3 | All 37 existing skills pass validation without modification | behavioral |
| SC-4 | Farmage Pattern still accepted (backward compat) but not required | behavioral |
| SC-5 | New skills created via `skill-creator --task init` use Agent-Intent Pattern | behavioral |

## Change Control

### Files Modified

| File | Change |
|------|--------|
| `.opencode/skills/skill-creator/tasks/validate.md` | Update REQ-2 specification to Agent-Intent Pattern with Farmage as accepted alternative |
| `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | Update validation logic to parse both patterns |

### Files Unchanged

| File | Reason |
|------|--------|
| `.opencode/skills/skill-creator/reference/routing-only-template.md` | Already canonical - no change needed |
| Existing SKILL.md files | Already follow Agent-Intent Pattern |

## Key Design Decisions

1. **Agent-Intent wins** - It's in the canonical template that all new skills MUST follow
2. **Backward compatibility** - Farmage Pattern still passes validation (don't break existing)
3. **Validation task is the bug** - It enforces a format not in the template
4. **No skill modifications needed** - All 37 existing skills already compliant with canonical format

## Related

- Prerequisite for #1881 (skill split audit) - new sub-skills must use canonical format
- Relates to `skill-creator` skill validation workflow
- Relates to `routing-only-template.md` as single source of truth for skill structure