---
remote_issue: 1211
remote_url: "https://github.com/michael-conrad/.opencode/issues/1211"
last_sync: 2026-06-14T20:49:36Z
source: github.com
---

## Workstream C — Procedure Checklist-ification

**Parent:** #1208
**Depends on:** #1210 (Workstream B)

### Scope
All SKILL.md ## Operating Protocol sections + all task files (`.opencode/skills/*/tasks/*.md`) that contain sequential numbered procedures.

### Changes

Convert every prose-embedded numbered step description into `- [ ] N. ...` checklist format.

#### Before (prose):
```
### Step 4: Plan Phase Structure

Organize by concern flow:
- Determine phases needed
- Write prose for phase descriptions
- Prose-driven, not template-driven
```

#### After (checklist):
```
### Step 4: Plan Phase Structure

- [ ] 1. Determine phases needed
- [ ] 2. Write prose for phase descriptions
- [ ] 3. Verify format is template-driven (not prose-driven)
```

### Rules

1. **Every sequential numbered procedure** in SKILL.md Operating Protocols and task file Procedures sections MUST use checklist format.
2. **ALREADY IN CHECKLIST FORMAT**: Sections already using `- [ ] N.` do not need changes.
3. **NOT subject to this rule**: Non-sequential sections (Purpose, Overview, Persona, Entry/Exit Criteria, Cross-References, Context Required, tables, code blocks).
4. **Prevents step skipping.** The agent must check each box as it executes — a box left unchecked means an incomplete procedure.
5. **This is format-only.** No content changes to what each step says.

### SCs

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-C1 | All Operating Protocol sequential procedures use `- [ ] N.` checklist format | string |
| SC-C2 | All task file numbered procedures use `- [ ] N.` checklist format | string |
