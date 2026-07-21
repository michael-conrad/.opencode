# {{TASK_NAME}}

{{BRIEF_PURPOSE_STATEMENT}}

## Dispatch Contract

The orchestrator MUST provide the following context fields when dispatching this task:

| Field | Required | Description |
|-------|----------|-------------|
| `{{CONTEXT_FIELD_1}}` | Yes | {{DESCRIPTION_1}} |
| `{{CONTEXT_FIELD_2}}` | Yes | {{DESCRIPTION_2}} |
| `{{CONTEXT_FIELD_3}}` | No | {{DESCRIPTION_3}} |

**Missing required context:** If any required field is absent, return:

```yaml
status: BLOCKED
reason: MISSING_REQUIRED_CONTEXT
message: "Required context field(s) missing: {{MISSING_FIELDS}}"
```

**Preloaded context rejection:** If the orchestrator includes inline reasoning, expected outcomes, file paths, or step sequences in the dispatch prompt, return:

```yaml
status: BLOCKED
reason: PRELOADED_CONTEXT_REJECTED
message: "Orchestrator preloaded context detected. Dispatch with canonical string only."
```

{% if DETERMINATION_PRODUCING %}
**Expected-determination rejection:** If the orchestrator includes an expected PASS/FAIL determination or expected verdict in the dispatch context, return:

```yaml
status: BLOCKED
reason: EXPECTED_DETERMINATION_REJECTED
message: "Expected determination detected. Dispatch without pre-judgment."
```
{% endif %}

## Output Contract

| Field | Required | Format | Description |
|-------|----------|--------|-------------|
| `artifact_path` | Yes | `{{ARTIFACT_PATH_TEMPLATE}}` | Path to the output artifact file |
| `artifact_format` | Yes | `{{ARTIFACT_FORMAT}}` | Format of the output artifact |
| `{{OUTPUT_FIELD_1}}` | Yes | `{{FORMAT_1}}` | {{DESCRIPTION_1}} |
| `{{OUTPUT_FIELD_2}}` | No | `{{FORMAT_2}}` | {{DESCRIPTION_2}} |

The output artifact MUST be written to `{{ARTIFACT_PATH_TEMPLATE}}` before returning.

## Frugal Contract

The sub-agent MUST return only the following fields to the orchestrator:

| Field | Required | Description |
|-------|----------|-------------|
| `status` | Yes | `DONE` / `BLOCKED` / `OVERFLOW` |
| `finding_summary` | Yes | 1-3 sentences of routing-significant output |
| `artifact_path` | Yes | Path to the full evidence artifact on disk |
| `blocker_reason` | If BLOCKED | Why the task was blocked |

Full evidence artifacts go to disk at `{{ARTIFACT_PATH_TEMPLATE}}`. The orchestrator reads only this contract — it does NOT re-read the artifact.

{% if CLEAN_ROOM %}
## Clean-Room Validation

This task requires independence from orchestrator bias. The sub-agent MUST:

1. **Reject preloaded context** — return `PRELOADED_CONTEXT_REJECTED` if the orchestrator includes inline reasoning, expected outcomes, file paths, or step sequences
2. **Discover scope independently** — read source files, run analysis tools, and determine the scope without orchestrator hints
3. **Produce evidence independently** — write full evidence artifacts to disk before returning
4. **Render binary judgment** — PASS (100% clean, no caveats) or FAIL (any caveat, any concern, any non-100% clean pass)
{% endif %}
