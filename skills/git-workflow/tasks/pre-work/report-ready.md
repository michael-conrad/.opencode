# Sub-Task: pre-work/report-ready

## Purpose

Ready reporting IS the handoff between setup and implementation. Silent starts produce untracked state.

## Entry Criteria

- Feature branch created and verified (create-branch completed)
- Environment initialized (init-env completed)
- All verification checks passed

## Procedure

### Step 1: Gather Branch State

Collect the current state of the repository for the readiness report:

```bash
# Branch
git branch --show-current

# Working tree status
git status --porcelain

# Dev base hash
git rev-parse --short dev

# (Worktree mode only) Worktree path
git rev-parse --show-toplevel
```

### Step 2: Gather Submodule Status

If `.gitmodules` exists:

```bash
git submodule status
```

If no submodules, report `submodules: none`.

### Step 3: Confirm Authorization Scope

Verify the authorization scope aligns with the work ahead:

| Check | Method |
|-------|--------|
| Issue is open | `github_issue_read(method=get)` |
| Labels match scope | `github_issue_read(method=get_labels)` |
| Sub-issues linked (multi-task) | `github_issue_read(method=get_sub_issues)` |

### Step 4: Produce Ready Report

**Direct-branch mode:**

```yaml
status: success
branch: <branch-name>
worktree_path: null
direct_branch: true
dev_base_hash: <7-char-sha>
working_tree_clean: true
submodules: <status or "none">
authorization_scope: <scope>
halt_at: <stage>
pr_strategy: <strategy>
pipeline_phase: <phase>
issue_number: <N>
ready_for: implementation
```

Report: "Ready for implementation on branch: <branch-name> (direct-branch)"

**Worktree mode:**

```yaml
status: success
branch: <branch-name>
worktree_path: .worktrees/<sanitized-branch-name>
direct_branch: false
dev_base_hash: <7-char-sha>
working_tree_clean: true
submodules: <status or "none">
authorization_scope: <scope>
halt_at: <stage>
pr_strategy: <strategy>
pipeline_phase: <phase>
issue_number: <N>
ready_for: implementation
```

Report: "Ready for implementation in worktree: <worktree-path> on branch: <branch-name>"

### Step 5: Yield to Orchestration Layer

The yield-back to the orchestration layer (`divide-and-conquer`) provides all context needed for the implementation sub-agent:

```yaml
status: success|failure
branch: <branch-name>
worktree_path: <path or null>
direct_branch: true|false
dev_base_hash: <7-char-sha>
working_tree_clean: true|false
authorization_scope: <scope>
halt_at: <stage>
pr_strategy: <strategy>
pipeline_phase: <phase>
issue_number: <N>
submodule_status: <status>
ready_for: implementation
```

If ANY check produced a failure, return `status: failure` with the specific failure details.

## Edge Case: Already Implemented (No Changes Needed)

When investigation reveals the spec is already implemented:

1. **Detect before branch creation** — After reading files, verify all proposed changes are already present
2. **Skip branch creation** — Do NOT create feature branch, do NOT push, do NOT create PR
3. **Close issue directly** — Post verification comment, close issue with `state_reason: "completed"`
4. **HALT after closing** — No further steps needed, no worktree cleanup

## Exit Criteria

- Ready report produced with branch state, submodule status, and authorization scope
- All verification checks documented with evidence
- Yield-back to orchestration layer provides complete context
- Authorization scope confirmed and aligned with work ahead

## Task Context Rules

- **must_receive**: `authorization_scope`, `halt_at`, `issue_number`, `branch`, `dev_base_hash`
- **must_not_receive**: Implementation context, expected file changes, orchestrator reasoning

Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)