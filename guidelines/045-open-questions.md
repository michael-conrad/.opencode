---
trigger_on: open questions, unresolved, Q&A, clarify
tier: 2
load_when: sub-agent
---

# Open Questions in Plans

Implementation BLOCKED while open questions remain. All must be answered before any part of the plan can proceed.

## Procedure

1. STOP — SILENTLY HALT, do not implement
2. ASK each question one at a time using interviewer format (options a/b/c + custom)
3. WAIT for answer before proceeding to next question
4. UPDATE plan with answered question
5. After all answered: user must say "approved" before implementation

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: open-questions-001
    title: "Implementation blocked while open questions remain"
    conditions:
      all: ["plan_has_open_questions == true", "implementation_attempted == true"]
    actions: [HALT]
    triggers: [approval-gate]

  - id: open-questions-002
    title: "All open questions must be answered before implementation"
    conditions:
      all: ["plan_has_open_questions == true", "all_questions_answered == false"]
    actions: [HALT]
    triggers: [executing-plans]

  - id: open-questions-003
    title: "Explicit approved confirmation required after Q&A completion"
    conditions:
      all: ["all_questions_answered == true", "explicit_approval_received == false"]
    actions: [HALT]
    requires: [open-questions-002]
    triggers: [approval-gate]
```
