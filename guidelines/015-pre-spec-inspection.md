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

**See `brainstorming` skill → `explore` task for the mandatory checklist integration. Incomplete inspection = `000-critical-rules.md` §Spec Without Investigation.**

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: pre-spec-inspection-001
    title: "Code inspection checklist must be completed before spec approach"
    conditions:
      all: ["spec_proposes_code_changes == true", "checklist_completed == false"]
    actions: [HALT]
    triggers: [brainstorming, spec-creation]
    source: "015-pre-spec-inspection.md §Mandatory Checklist"

  - id: pre-spec-inspection-002
    title: "All six checklist items must be addressed"
    conditions:
      all: ["checklist_started == true", "all_items_addressed == false"]
    actions: [HALT]
    requires: [pre-spec-inspection-001]
    triggers: [spec-creation]
    source: "015-pre-spec-inspection.md §Completeness Threshold"

  - id: pre-spec-inspection-003
    title: "Incomplete inspection is Spec Without Investigation violation"
    conditions:
      all: ["spec_proposes_code_changes == true", "checklist_completed == false"]
    actions: [VIOLATION(spec-without-investigation)]
    triggers: [approval-gate, spec-auditor]
    source: "015-pre-spec-inspection.md §Enforcement"
```
