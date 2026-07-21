# Phase 2: Add contract sections to all ~25 task files

**SCs:** SC-5
**Files:** All `.opencode/skills/audit/tasks/*.md` files

## Steps

### 2.1 Add Dispatch Contract section
To every task file, add after the purpose statement:

```
## Dispatch Contract

The orchestrator MUST provide the following context fields when dispatching this task:

| Field | Required | Description |
|-------|----------|-------------|
| `issue_number` | Yes | Issue number being audited |
| `spec_local_dir` | Yes | Path to spec directory |
| `artifact_evidence_dir` | Yes | Path to evidence artifacts directory |

**Missing required context:** If any required field is absent, return:
```yaml
status: BLOCKED
reason: MISSING_REQUIRED_CONTEXT
message: "Required context field(s) missing: {fields}"
```

**Preloaded context rejection:** If the orchestrator includes inline reasoning, expected outcomes, file paths, or step sequences in the dispatch prompt, return:
```yaml
status: BLOCKED
reason: PRELOADED_CONTEXT_REJECTED
message: "Orchestrator preloaded context detected. Dispatch with canonical string only."
```
```

### 2.2 Add Output Contract section
To every task file, add after Dispatch Contract:

```
## Output Contract

| Field | Required | Format | Description |
|-------|----------|--------|-------------|
| `artifact_path` | Yes | `./tmp/{issue-N}/artifacts/{task-name}/` | Path to the output artifact directory |
| `artifact_format` | Yes | `yaml` | Format of the output artifact |
| `finding_summary` | Yes | string | 1-3 sentence summary of findings |
| `verdict` | Yes | `PASS`/`FAIL` | Binary verdict |

The output artifact MUST be written to `./tmp/{issue-N}/artifacts/{task-name}/` before returning.
```

### 2.3 Add Frugal Contract section
To every task file, add after Output Contract:

```
## Frugal Contract

The sub-agent MUST return only the following fields to the orchestrator:

| Field | Required | Description |
|-------|----------|-------------|
| `status` | Yes | `DONE` / `BLOCKED` / `OVERFLOW` |
| `finding_summary` | Yes | 1-3 sentences of routing-significant output |
| `artifact_path` | Yes | Path to the full evidence artifact on disk |
| `blocker_reason` | If BLOCKED | Why the task was blocked |

Full evidence artifacts go to disk at `./tmp/{issue-N}/artifacts/{task-name}/`. The orchestrator reads only this contract.
```

### 2.4 Verify all files have all 3 contract sections
Run: `grep -l '## Dispatch Contract' tasks/*.md | wc -l` and similar for Output Contract, Frugal Contract.

### 2.5 Verify contract section consistency
Spot-check 5 files for consistent field names and format.

## Exit Criteria
- [ ] All task files have `## Dispatch Contract` section
- [ ] All task files have `## Output Contract` section
- [ ] All task files have `## Frugal Contract` section
- [ ] Section structure is consistent across all files
