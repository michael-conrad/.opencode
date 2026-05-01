# Task: analyze

## Purpose

Independently discover the full scope of work needed for a given task. This sub-agent receives only an issue number and task description — it must autonomously read spec/plan documents, search the codebase, identify affected files, and return a dispatch plan with task partitions.

## Entry Criteria

- Issue number and task description received in dispatch context
- github.owner and github.repo available for API calls

## Exit Criteria

- Dispatch plan returned with task partitions and file scope
- All affected files independently discovered (not from orchestrator)

## Procedure

### Step 1: Load Spec and Plan

1. Read the spec issue via `github_issue_read(method="get", issue_number=<spec>)`
2. Read the plan issue via `github_issue_read(method="get", issue_number=<plan>)`
3. Read any sub-issue via `github_issue_read(method="get", issue_number=<sub_issue>)`
4. Read all comments on the sub-issue: `github_issue_read(method="get_comments", issue_number=<sub_issue>)`

### Step 2: Load Relevant Skill Task Files

1. Identify which skill's task files are relevant from the plan's file structure table
2. Read the SKILL.md for routing metadata only (not full content)
3. Read the specific task file referenced by the plan (for procedure details)

### Step 3: Discover Affected Files

1. For each file path mentioned in the plan's file structure table, verify existence via `glob` or `read`
2. Independently search the codebase for additional affected files:
   - Use `grep` to find patterns referenced in the task (e.g., function names, rule patterns)
   - Use `glob` to enumerate directories containing files with similar naming
   - Check for related test files, supporting scripts, or configuration files
3. Flag any files outside the plan's scope that may be affected

### Step 4: Determine Task Partitions

Group affected files into partitions based on:
- Architectural concern (e.g., enforcement rules vs routing tables vs test infrastructure)
- File type (guidelines, skills, task files, tests, configuration)
- Dependency ordering (foundational rules before routing changes before test validation)

### Step 5: Return Dispatch Plan

Return a structured dispatch plan:

```yaml
status: PLAN_READY
issue_number: <N>
task_description: "<task description>"
partitions:
  - concern: "<architectural concern>"
    files: ["path/to/file1.md", "path/to/file2.md"]
    task_actions: ["<action>", "<action>"]
    verification: "<how to verify this partition>"
  - concern: "<next concern>"
    files: [...]
    task_actions: [...]
    verification: "..."
discovered_files: ["<file1>", "<file2>"]
files_outside_plan_scope: ["<file>"]
total_estimated_changes: <N>
```

### Step 6: Context-Hash Audit Trail

Before dispatching the execution sub-agent, the orchestrator MUST compute and log a context hash. This enables post-execution integrity verification — confirming the execution sub-agent operated on the same dispatch plan that was produced.

#### 6.1 Compute Dispatch Payload Hash

1. Serialize the dispatch plan (Step 5 output) as canonical JSON with sorted keys
2. Compute SHA-256 hash: `printf '%s' "$serialized" | sha256sum | cut -d' ' -f1`
3. Store the hash as `context_hash` in the work state file alongside the dispatch plan

#### 6.2 Hash Storage Format in Work State File

```yaml
pre_analysis:
  issue_number: <N>
  context_hash: "<sha256-hex>"
  hash_computed_at: "<ISO-8601-timestamp>"
  partitions_count: <N>
  discovered_files_count: <N>
```

#### 6.3 Post-Execution Hash Comparison

After the execution sub-agent returns:

1. Re-read the original dispatch plan from the work state file
2. Re-compute the SHA-256 hash from the stored dispatch plan
3. Compare against the stored `context_hash`:
   - **Match**: Dispatch integrity confirmed — execution sub-agent used the same plan
   - **Mismatch**: Flag as `STRUCTURE-VIOLATION` — dispatch plan was modified between analysis and execution. The orchestrator MUST:
     1. Report the mismatch with both hash values
     2. Re-run pre-analysis (`analyze` task) on the original issue
     3. HALT — do NOT proceed with mismatched context

#### 6.4 Integrity Check Table

| Check | Method | On Mismatch |
|-------|--------|-------------|
| Dispatch payload hash | Re-compute vs stored | STRUCTURE-VIOLATION → re-analyze → HALT |
| Partition count consistency | Compare stored vs actual | WARNING — may indicate scope change |
| Timestamp freshness | Compare hash timestamp vs dispatch time | WARNING if > 30 min stale |

#### 6.5 Orchestrator Integration

The orchestrator invokes this check as part of the `assemble-work` post-sub-agent completion checkpoint. The check MUST run before any result contract is accepted as `DONE`. A hash mismatch blocks acceptance — the orchestrator treats the result as `BLOCKED` and re-dispatches the pre-analysis sub-agent.

```yaml+symbolic
  - id: pre-analysis-context-hash
    title: "Context-hash audit trail verifies dispatch payload integrity"
    conditions:
      all:
        - "execution_sub_agent_returned == true"
        - "context_hash_matches == false"
    actions:
      - FLAG(structure-violation)
      - RE_RUN(pre-analysis --task analyze)
      - HALT
    conflicts_with: []
    requires: [pre-analysis-001]
    triggers: [pre-analysis, divide-and-conquer]
    source: "pre-analysis/tasks/analyze.md §Step 6"
```

Co-authored with AI: <AgentName> (<ModelId>)
