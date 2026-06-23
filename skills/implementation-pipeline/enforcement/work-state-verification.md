# Work State Verification Module

## Live State Verification Table

When `assemble-work` records claims about work state (e.g., "sub-agent completed", "issue linked"), each claim MUST be verified against live state before the orchestration proceeds.

### Verification Table

| Claim | Verification Action | Tool Call | Problem Class |
|-------|---------------------|-----------|---------------|
| Sub-agent completed | Result contract exists with status DONE or DONE_WITH_CONCERNS | Read work state file | STRUCTURE-VIOLATION |
| Issue created | Issue exists on GitHub with correct title and labels | `issue-operations -> read-issue (github_issue_read(method=get, issue_number=N)` | MISSING-ELEMENT | <!-- Routes through issue-operations per SPEC #683 -->
| Sub-issues linked | `issue-operations -> read-sub-issues (github_issue_read(method=get_sub_issues)` returns expected sub-issues | `github_issue_read(method=get_sub_issues, issue_number=N)` | MISSING-ELEMENT | <!-- Routes through issue-operations per SPEC #683 -->
| Branch created | Branch exists in local worktree | `git rev-parse --verify <branch>` | MISSING-ELEMENT |
| Worktree path set | Worktree directory exists and is git repository | `git rev-parse --show-toplevel` in worktree | STRUCTURE-VIOLATION |
| All phases complete | Every phase in work state has status DONE | Read work state file | VERIFICATION-GAP |
| PR URL valid | PR URL extracted from API response, not constructed | Extract from `github_create_pull_request` response `html_url` | CONFLICTING |

### Work State File Format

Work state files are stored at `.tmp/work-state-{issue-N}.yaml` and contain:

```yaml
# .tmp/work-state-{issue-N}.yaml
schema_version: "1.0"
issue_number: <N>
current_phase: <phase-N>
completed_phases: [<phase-1>, <phase-2>, ...]
current_step: <step_label>
pipeline_state: init | running | complete | failed
contract_path: .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml
sc_results:
  SC-<N>:
    status: pending | pass | fail
    evidence_type: behavioral | semantic | string | structural
    evidence_path: <path>
    verified_at: <ISO8601>
checkpoint_tags:
  phase-<N>: <tag-name>
started_at: <ISO8601>
updated_at: <ISO8601>
```

### Z3 Type Declarations

The work state fields `current_step` and `pipeline_state` are declared in the Z3 contract at `pipeline-state-machine.yaml`:

| Field | Z3 Type | Domain |
|-------|---------|--------|
| `current_step` | `z3.String` | All valid step labels (see `pipeline-state-machine.yaml` `variables.current_step.domain`) |
| `pipeline_state` | `z3.String` | `[init, running, complete, failed]` |

### Z3 Contract Section

The `contract_path` field in the work state file links to the Z3-verifiable state machine contract. The contract at `pipeline-state-machine.yaml` defines:

- **Variables**: `current_step`, `previous_step`, `pipeline_state` with typed domains
- **Preconditions**: Transition constraints (e.g., `Implies(previous_step == 'init', current_step == 'pre-red-baseline')`)
- **Postconditions**: Terminal state constraints (e.g., `Implies(current_step == 'exec-summary', pipeline_state == 'complete')`)

Work state files MUST be validated against the contract before pipeline advancement. Validation checks:
1. `current_step` is a member of the declared domain
2. `pipeline_state` is a member of `[init, running, complete, failed]`
3. The transition from `previous_step` to `current_step` satisfies all preconditions
4. Terminal states satisfy all postconditions

### Evidence Artifacts

Every claim about work state MUST have a corresponding tool-call artifact:
- Work state file read → verify branch/status entries
- Git commands → verify branch/worktree state
- GitHub API calls → verify issue/PR state

Claims without artifacts are verification honesty violations.