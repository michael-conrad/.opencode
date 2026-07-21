# Phase 1: Fix `audit/SKILL.md` structure

**SCs:** SC-1, SC-2, SC-3, SC-4
**Files:** `.opencode/skills/audit/SKILL.md`

## Steps

### 1.1 Add Pre-Flight Gate section
Insert `## Pre-Flight Gate` as the first content section after frontmatter (after line 10). Content per template:

```yaml
pre_flight:
  check: task() available
  on_failure:
    status: BLOCKED
    reason: TASK_UNAVAILABLE
    message: "task() is not available in this context. Cannot dispatch sub-agents for audit."
    action: HALT all operations
```

### 1.2 Remove global Invocation and DISPATCH_GATE sections
Delete lines 94-137 (Invocation, Explicit Dispatch Protocol, DiMo Role Chain Dispatch sections).

### 1.3 Add enumerated workflow sections
Add `## Workflow` section with 4 enumerated sub-sections:

```
### 1. Pre-Flight Gate
- **Dispatch type:** `orchestrator: inline`
- **Dispatch string:** N/A
- **Input:** N/A
- **Output:** PASS or BLOCKED

### 2. Trigger Dispatch
- **Dispatch type:** `orchestrator: read TDT, dispatch`
- **Dispatch string:** `"audit --task <task-name>"`
- **Input:** `{issue_number, spec_local_dir, artifact_evidence_dir}`
- **Output:** Sub-agent result contract

### 3. DiMo Chain Execution
- **Dispatch type:** `orchestrator: 4 sequential task() calls`
- **Dispatch string:** `"audit --task <task-name> DiMo chain: investigator → validator → evaluator → arbiter"`
- **Input:** `{issue_number, spec_local_dir, artifact_evidence_dir}`
- **Output:** `judgment.yaml` at `./tmp/{issue-N}/artifacts/{task-name}/`

### 4. Completion
- **Dispatch type:** `orchestrator: halt`
- **Dispatch string:** N/A
- **Input:** N/A
- **Output:** Structured halt message
```

### 1.4 Update TDT Dispatch column
Change all `sub-task (DiMo chain)` to `orchestrator: 4 sequential task() calls`. Remove HALT rows for missing artifacts. Ensure context passed includes `role_chain` field.

## Exit Criteria
- [ ] Pre-Flight Gate is first content section after frontmatter
- [ ] No `## Invocation` section exists
- [ ] No `## DISPATCH_GATE` section exists
- [ ] No `## Explicit Dispatch Protocol` section exists
- [ ] No `## DiMo Role Chain Dispatch` section exists
- [ ] `## Workflow` section with 4 enumerated sub-sections exists
- [ ] TDT Dispatch column uses `orchestrator: 4 sequential task() calls`
- [ ] All HALT rows removed from TDT
