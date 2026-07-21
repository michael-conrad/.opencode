---
name: {{SKILL_NAME}}
description: {{ONE_LINE_DESCRIPTION}}
location: {{SKILL_PATH}}/SKILL.md
---

# {{SKILL_NAME}}

{{BRIEF_PURPOSE_STATEMENT}}

## Pre-Flight Gate

Before any dispatch, verify `task()` is available:

```yaml
pre_flight:
  check: task() available
  on_failure:
    status: BLOCKED
    reason: TASK_UNAVAILABLE
    message: "task() is not available in this context. Cannot dispatch sub-agents for {{SKILL_NAME}}."
    action: HALT all operations
```

## Trigger Dispatch Table

| Trigger | Dispatch | Notes |
|---------|----------|-------|
| {{TRIGGER_PATTERN_1}} | `task({{TASK_FILE_1}})` | {{NOTES_1}} |
| {{TRIGGER_PATTERN_2}} | `orchestrator: N sequential task() calls` | {{NOTES_2}} |
| {{TRIGGER_PATTERN_3}} | `orchestrator: halt` | {{NOTES_3}} |
| {{TRIGGER_PATTERN_4}} | `orchestrator: inline` | {{NOTES_4}} |

## Workflow

### 1. {{STEP_1_NAME}}

- **Dispatch type:** `task({{TASK_FILE_1}})`
- **Dispatch string:** `"{{SKILL_NAME}} --task {{TASK_1}}"`
- **Input:** `{{INPUT_DESCRIPTION_1}}`
- **Output:** `{{OUTPUT_DESCRIPTION_1}}`

### 2. {{STEP_2_NAME}}

- **Dispatch type:** `task({{TASK_FILE_2}})`
- **Dispatch string:** `"{{SKILL_NAME}} --task {{TASK_2}}"`
- **Input:** `{{INPUT_DESCRIPTION_2}}`
- **Output:** `{{OUTPUT_DESCRIPTION_2}}`

### 3. {{STEP_3_NAME}}

- **Dispatch type:** `orchestrator: N sequential task() calls`
- **Dispatch string:** `"{{SKILL_NAME}} --task {{TASK_3}}"` (repeat per sub-step)
- **Input:** `{{INPUT_DESCRIPTION_3}}`
- **Output:** `{{OUTPUT_DESCRIPTION_3}}`

### 4. {{STEP_4_NAME}}

- **Dispatch type:** `orchestrator: halt`
- **Dispatch string:** N/A
- **Input:** N/A
- **Output:** Structured halt message with summary, outcome, blockers, URL, byline
