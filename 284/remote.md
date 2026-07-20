---
remote_issue: 284
remote_url: "https://github.com/michael-conrad/opencode-config/issues/284"
last_sync: 2026-07-20T14:29:29Z
source: github
---

# [SPEC-FIX] Resolve Conflicting Skill Description Format Mandates (Unified Agent-Intent + Farmage)

## Problem Statement

The skill-creator skill currently enforces two conflicting description format mandates in its validation logic:

1. **Unified Agent-Intent Description Pattern** (from `080-code-standards.md` and skill-card templates): Requires a single unified description field that combines agent intent + farmage in one string
2. **Farmage Description Pattern** (from skill-creator validation): Requires a separate `farmage` field with specific format requirements

These two mandates conflict, causing validation failures when creating or updating skills that follow either pattern. The validation logic in `skill-creator` rejects skills that conform to one pattern but not the other, creating a catch-22 for skill authors.

## Root Cause

The conflict stems from two separate specification sources that were never reconciled:

- **Source A** (Unified pattern): Skill cards should have a single `description` field following the pattern: ` — `
- **Source B** (Separate pattern): Skill cards should have separate `description` and `farmage` fields with distinct validation rules

The `skill-creator` validation code implements checks for both patterns simultaneously, rejecting any skill that doesn't satisfy both — which is impossible since the patterns are mutually exclusive.

## Affected Files

- `.opencode/skills/skill-creator/SKILL.md` — validation rules
- `.opencode/skills/skill-creator/tasks/validate.md` — validation logic
- `.opencode/skills/skill-creator/tasks/create.md` — creation template
- `.opencode/skills/skill-creator/tasks/update.md` — update validation

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Skill validation ACCEPTS skills with unified description pattern (`description: " — "`) | behavioral |
| SC-2 | Skill validation REJECTS skills with ONLY separate farmage field (no `description`) — DEPRECATED FORMAT | behavioral |
| SC-3 | Skill validation REJECTS skills with NEITHER pattern (must have at least unified pattern) | behavioral |
| SC-4 | Skill creation template generates skills conforming to unified pattern by default | structural |
| SC-5 | Skill update preserves unified pattern when present; rejects farmage-only updates | behavioral |
| SC-6 | Documentation in SKILL.md clearly states the unified pattern is the ONLY accepted format | string |

## Proposed Resolution

Unify on the **Unified Agent-Intent + Farmage Description Pattern** as the single canonical format:

```
description: " — "
```

Where:
- ``: What the skill does for the agent (e.g., "Validates skill cards against format standards")
- ``: What the skill produces for the farm (e.g., "emits validated skill card with compliance report")

The separate `farmage` field is **DEPRECATED AND REJECTED**. Skills with only a `farmage` field (no `description`) MUST BE REJECTED with a clear error message directing the author to migrate to the unified format. Auto-migration is explicitly prohibited — the deprecated format must not be silently accepted or converted.

## Verification Method

Run `skill-creator --task validate` against:
1. A skill with unified description only → PASS
2. A skill with separate farmage only → FAIL with migration guidance (DEPRECATED FORMAT REJECTED)
3. A skill with both → PASS (backward compat for transition period)
4. A skill with neither → FAIL with clear error

---

🤖 Co-authored with AI:  ()
