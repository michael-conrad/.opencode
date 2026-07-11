# [SPEC-FIX] Resolve Conflicting Skill Description Format Mandates (Unified Agent-Intent)

- **Status:** DRAFT
- **Branch Pattern:** `spec-fix/skill-description-format-alignment`
- **Depends On:** #1881 (skill split audit)

## Problem

Two authoritative sources mandate **mutually exclusive** description formats for skill card `description` fields:

| Source | Authority | Format Name | Pattern |
|--------|-----------|-------------|---------|
| `.opencode/skills/skill-creator/reference/routing-only-template.md` | Canonical template | **Agent-Intent** | `"Dispatch when ... Also dispatch when ... ... User phrases: ..."` |
| `.opencode/skills/skill-creator/tasks/validate.md` (validation task) | Mechanical validation (REQ-2) | **Farmage/CSO** | `"Use when ... Also use when ... Invoke for: ... ... Trigger phrases: ..."` |

**All 37 existing skills follow Agent-Intent Pattern.** The Farmage Pattern is only enforced by the validation task.

The core conflict: Agent-Intent is designed for **semantic dispatch** — the AI agent reads the description and dispatches based on its own internal understanding of what it needs to do. Farmage is designed for **magic-phrase matching** — matching literal user trigger phrases. These are fundamentally different approaches.

## Solution

**Adopt Agent-Intent as the single canonical format.** The Farmage Pattern is deprecated and rejected.

The Agent-Intent format already works correctly for all 37 existing skills. The only change needed is to:
1. Update the validation script to accept only Agent-Intent format
2. Add `Invoke for:` as an optional structural element (task names from dispatch table) — this is a reference aid, not a dispatch mechanism
3. Remove `User phrases:` as a mandatory element — it was a Farmage artifact that implies magic-phrase matching

### Canonical Format

```yaml
description: "... Dispatch when ... Also dispatch when ... Invoke for: ... ... — distinct from ..."
```

### Element Definitions

| Element | Purpose | Dispatch Mechanism |
|---------|---------|-------------------|
| Noun phrase (what skill IS) | Declarative identity | — |
| `Dispatch when` | Primary agent-facing intent triggers | **Semantic** — AI reads and understands intent |
| `Also dispatch when` | Additional agent-facing intent triggers | **Semantic** — AI reads and understands intent |
| `Invoke for:` | Task names from dispatch table (OPTIONAL) | Structural reference only |
| Enforcement statement (REQUIRED/MANDATORY) | Declarative | — |
| `— distinct from` | Disambiguation from similar skills | Semantic |

### What Is NOT in the Canonical Format

| Element | Source | Why Excluded |
|---------|--------|-------------|
| `User phrases:` | Farmage | Implies magic-phrase matching; counter to Agent-Intent semantic dispatch |
| `Trigger phrases:` | Farmage | Same — magic-phrase matching |
| `Use when` / `Also use when` | Farmage | Redundant with `Dispatch when` / `Also dispatch when` |

### Example: git-workflow (Agent-Intent)

```yaml
description: "Git branch, commit, push, and PR workflow manager with cleanup and provenance tracking. Dispatch when creating a branch, committing, pushing, or creating a PR. Also dispatch when handling rebase/merge conflicts (invoke conflict-resolution), checking PR state and cleanup, or running provenance tracking. Invoke for: branch, commit, push, pr, cleanup, conflict, provenance. Branch-and-PR discipline is REQUIRED. — distinct from using-git-worktrees, pr-creation-workflow, conflict-resolution."
```

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `validate.md` REQ-2 updated to specify Agent-Intent as canonical | structural |
| SC-2 | Validation script (`validate_skill_cards.py`) REJECTS Farmage format and any format with `User phrases:` or `Trigger phrases:` as mandatory elements | behavioral |
| SC-3 | All 37 existing skills pass validation in their current Agent-Intent format (no reformatting needed) | behavioral |
| SC-4 | New skills created via `skill-creator --task init` use Agent-Intent format | behavioral |
| SC-5 | `routing-only-template.md` updated to show Agent-Intent as canonical | structural |

## Change Control

### Files Modified

| File | Change |
|------|--------|
| `.opencode/skills/skill-creator/tasks/validate.md` | REQ-2 rewritten to specify Agent-Intent as canonical; remove Farmage validation |
| `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | Validate Agent-Intent format; REJECT Farmage format and `User phrases:`/`Trigger phrases:` elements |
| `.opencode/skills/skill-creator/reference/routing-only-template.md` | Update template description example to Agent-Intent format |

### Files Updated (No Changes Needed)

| File | Reason |
|------|--------|
| `.opencode/skills/*/SKILL.md` | All 37 already use Agent-Intent format — no changes needed |

## Key Design Decisions

1. **Agent-Intent is the single canonical format** — Farmage is deprecated and rejected
2. **Semantic dispatch** — AI agent dispatches based on understanding intent, not matching magic phrases
3. **`Invoke for:` is optional** — structural reference to task names, not a dispatch mechanism
4. **`User phrases:` excluded** — implies magic-phrase matching, counter to Agent-Intent philosophy
5. **No transition period** — validation rejects Farmage format immediately
6. **No reformatting needed** — all 37 existing skills already use Agent-Intent format

## Related

- Prerequisite for #1881 (skill split audit) - new sub-skills use Agent-Intent format
- Relates to `skill-creator` skill validation workflow
- Relates to `routing-only-template.md` as single source of truth for skill structure
