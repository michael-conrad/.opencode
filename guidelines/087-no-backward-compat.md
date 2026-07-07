---
trigger_on: backward compat, refactor, deprecate, breaking change
tier: 2
load_when: sub-agent
---

# No Backward Compatibility During Refactoring

When refactoring internal (non-public API) code: Do NOT create backward compat aliases, deprecation warnings, or compatibility shims. Fix ALL callers immediately. Clean breaks are less confusing and less wasteful.

**Exception:** Public APIs with external consumers — use deprecation cycles per standard practice.
