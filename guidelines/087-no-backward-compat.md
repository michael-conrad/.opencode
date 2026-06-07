---
trigger_on: backward compat, refactor, deprecate, breaking change
tier: 2
load_when: sub-agent
---

# No Backward Compatibility During Refactoring

When refactoring internal (non-public API) code: Do NOT create backward compat aliases, deprecation warnings, or compatibility shims. Fix ALL callers immediately. Clean breaks are less confusing and less wasteful.

**Exception:** Public APIs with external consumers — use deprecation cycles per standard practice.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: no-backward-compat-001
    title: "No backward compatibility aliases for internal code"
    conditions:
      all: ["internal_code_refactored == true", "backward_compat_alias_created == true"]
    actions: [HALT]
    source: "087-no-backward-compat.md §Rule"

  - id: no-backward-compat-002
    title: "Fix all callers immediately when refactoring internal code"
    conditions:
      all: ["internal_code_refactored == true", "callers_not_fixed == true"]
    actions: [FIX_CALLERS]
    source: "087-no-backward-compat.md §Rule"

  - id: no-backward-compat-003
    title: "No deprecation warnings for internal code"
    conditions:
      all: ["internal_code_refactored == true", "deprecation_warning_added == true"]
    actions: [HALT]
    source: "087-no-backward-compat.md §Rule"
```
