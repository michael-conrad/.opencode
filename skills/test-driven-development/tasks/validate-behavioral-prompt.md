# Task: validate-behavioral-prompt

## Purpose

Validate that a behavioral test prompt will trigger the target behavior before the test is executed. Prevents wasted test runs where the agent halts at the authorization gate, lacks fixture data, or receives a prose-recall prompt instead of a real-domain task.

## Input

- `prompt_text`: The behavioral test prompt to validate
- `sc_list`: List of SC IDs the prompt is intended to verify

## Validation Checks

1. **Authorization context present** — The prompt MUST contain "approved" or "go" or equivalent authorization language. Without authorization, the agent halts at the approval gate and never reaches the target behavior.

2. **Real-domain task, not prose-recall** — The prompt MUST be a real-domain task that triggers natural agent behavior (e.g., "implement feature X", "fix bug Y", "create a spec for Z"). Prose-recall prompts ("describe how you would handle X", "what would you do if Y") are INVALID — they test what the agent says, not what it does.

3. **Fixture data available** — If the prompt references fixture issues, test repos, or specific data, verify those fixtures exist and are accessible.

4. **Target behavior reachable** — The prompt must be structured so the agent can reach the target behavior within the test's timeout. Prompts requiring multi-step pipelines or external dependencies may time out before reaching the target.

## Output

```yaml
status: DONE|BLOCKED
validation:
  authorization_present: true|false
  is_real_domain_task: true|false
  fixtures_available: true|false|not_applicable
  target_reachable: true|false
  findings:
    - "Authorization language missing — add 'approved' or 'go' to prompt"
    - "Prose-recall prompt — restructure as real-domain task"
blocker_reason: "Reason if BLOCKED"
```

## Rules

- A prompt that fails ANY validation check MUST return BLOCKED
- The prompt MUST NOT be modified by this task — only validated
- Validation is advisory for non-blocking findings (e.g., "target may be slow")
