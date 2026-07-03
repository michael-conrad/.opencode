# Overflow Signal Module

## OVERFLOW Contract Format

When a sub-agent's context window exceeds capacity during execution, it MUST emit an OVERFLOW result contract:

```yaml
status: OVERFLOW
task: <task-name>
completed_items: [<item-ids-or-names>]
remaining_items: [<item-ids-or-names>]
context_usage: <estimated-percentage>
suggested_split: <proposed-split-strategy>
```

## Re-Dispatch Protocol

When `assemble-work` receives an OVERFLOW result:

- [ ] 1. Record completed items in work state file
- [ ] 2. Create new sub-agent task(s) for remaining items using suggested split strategy
- [ ] 3. Re-dispatch new sub-agent(s) with reduced scope
- [ ] 4. Continue orchestration with accumulated results

### Split Strategies

| Strategy | When | Action |
|----------|------|--------|
| Per-item | Single large item causing overflow | Split into one sub-agent per remaining item |
| Per-phase | Multi-phase task with phase boundary | Split at phase boundaries |
| Chunked | Many small items | Split remaining items into 2-3 equal chunks |
| Fallback | No clear split point | HALT and report context overflow to developer |

### Context Allocation Awareness

Signal OVERFLOW only on concrete, observable signs:

- Tool output is truncated mid-result with content missing
- Required spec, plan, or file content cannot be included in task context because earlier content fills the window
- Previously read content is no longer accessible due to context displacement

Sub-process dispatch (opencode-cli run, task()) spawns independent processes — they do not affect orchestrator context allocation.