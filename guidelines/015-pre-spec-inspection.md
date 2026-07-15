---
trigger_on: code inspection, pre-spec, investigate codebase
tier: 2
load_when: sub-agent
---

# Pre-Spec Code Inspection

All six items MUST be completed before proposing any approach in a spec or bug report:

1. Trace actual call paths (`srclight_get_callers`)
2. Verify imports (`grep` import statements)
3. Detect dead code (`srclight_get_dependents`)
4. Verify format/protocol assumptions (`srclight_get_signature`, `read` source)
5. Confirm architectural layer (`read` target module + imports)
6. Check for existing alternatives (`srclight_hybrid_search`)

**Incomplete inspection = Read [Spec Without Investigation](000-critical-rules.md) — CRITICAL VIOLATION.**
**Read [brainstorming skill -> explore task](skills/brainstorming/SKILL.md) for the mandatory checklist integration.**

Each item requires its own tool-call evidence. A single "read the file" grep is NOT sufficient — every item must be independently verified with the specified tool.
