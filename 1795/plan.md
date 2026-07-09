---
issue_number: 1795
spec_title: "[SPEC] PR Status Check — verify all mergeability signals, not just merged/state"
status: PLAN_CREATED
created_at: 2026-07-08T20:00:00Z
updated_at: 2026-07-08T20:45:00Z
---

# Plan: PR Status Check — Full Mergeability Signals

## Goal

After PR creation and during all PR status checks, the agent MUST read and act on `mergeable`, `base.sha`, `updated_at`, `created_at`, `state`, and `merged` fields from the PR API response — not just `state` and `merged`.

## Architecture

This is a single-phase plan. One concern: extend all PR status check locations to perform full mergeability diagnosis. The change touches 4 files across 2 skills, all within the `.opencode` submodule.

Each implementation step follows RED/GREEN decomposition: RED writes a behavioral test that fails (change doesn't exist yet), GREEN implements the change.

## Affected Files

| File | Change | SCs |
|------|--------|-----|
| `skills/git-workflow/tasks/pr-creation/create-pr.md` | Add post-creation mergeability check step after Step 5 (PR creation) | SC-1, SC-2, SC-3, SC-4, SC-5 |
| `skills/git-workflow/tasks/pr-creation/enforcement-gate.md` | Reference mergeability check in pre-creation gate | SC-5 |
| `skills/git-workflow/tasks/check-pr.md` | Phase 2: replace `state`/`merged`-only check with full mergeability check | SC-1, SC-2, SC-3, SC-4, SC-5 |
| `skills/issue-operations/tasks/verify-merge.md` | Step 2: extend merge verification with full mergeability signals | SC-1, SC-2, SC-3, SC-4 |

## Phase Table

| Phase | Description | SCs |
|-------|-------------|-----|
| Phase 1 | Add mergeability check after PR creation and in all PR status check locations | SC-1, SC-2, SC-3, SC-4, SC-5 |

## Implementation Steps

### Step 1: Post-creation mergeability check in `create-pr.md`

**File:** `skills/git-workflow/tasks/pr-creation/create-pr.md`

#### RED (write failing behavioral test)

Write a behavioral test that sends a prompt to create a PR and verifies the agent reads `mergeable`, `base.sha`, `updated_at`, `created_at`, `state`, and `merged` from the PR API response. The test MUST fail because the mergeability check step doesn't exist yet.

- **Test location:** `.opencode/tests/behaviors/pr-mergeability-check.sh`
- **Assertions:** `assert_semantic` for SC-1 (reads all 6 fields), SC-2 (diagnoses null mergeable), SC-3 (rebases on stale base), SC-4 (triggers computation when updated_at == created_at), SC-5 (never terminal "PR is open")
- **Expected result:** FAIL (RED)

#### GREEN (implement)

Add a new step after Step 5 (PR creation) that:

- Reads `mergeable`, `base.sha`, `updated_at`, `created_at`, `state`, `merged` from the PR API response (SC-1)
- If `mergeable` is `null`: diagnose root cause (stale base, conflict, or pending) and report to user (SC-2)
- If `base.sha` differs from remote base tip: rebase the PR branch onto current base (SC-3)
- If `updated_at` equals `created_at`: trigger mergeability computation (comment or no-op push) (SC-4)
- Never report "PR is open" as terminal status — always include mergeability diagnosis (SC-5)

**Dispatch:** `task(subagent_type="general")` with context `{file: "skills/git-workflow/tasks/pr-creation/create-pr.md", scs: ["SC-1","SC-2","SC-3","SC-4","SC-5"]}`

### Step 2: Mergeability reference in `enforcement-gate.md`

**File:** `skills/git-workflow/tasks/pr-creation/enforcement-gate.md`

#### RED (write failing behavioral test)

Write a behavioral test that verifies the pre-creation gate references the post-creation mergeability check. The test MUST fail because the reference doesn't exist yet.

- **Test location:** `.opencode/tests/behaviors/pr-enforcement-gate-mergeability.sh`
- **Assertions:** `assert_semantic` for SC-5 (gate enforces that "PR is open" is never a terminal status)
- **Expected result:** FAIL (RED)

#### GREEN (implement)

Add a reference in the pre-creation gate that the post-creation mergeability check will run. This ensures SC-5 (no terminal "PR is open" status) is enforced at the gate level.

**Dispatch:** `task(subagent_type="general")` with context `{file: "skills/git-workflow/tasks/pr-creation/enforcement-gate.md", scs: ["SC-5"]}`

### Step 3: Full mergeability check in `check-pr.md`

**File:** `skills/git-workflow/tasks/check-pr.md`

#### RED (write failing behavioral test)

Write a behavioral test that sends a prompt to check PR status and verifies the agent performs full mergeability diagnosis instead of `state`/`merged`-only. The test MUST fail because Phase 2 still uses the old check.

- **Test location:** `.opencode/tests/behaviors/pr-check-mergeability.sh`
- **Assertions:** `assert_semantic` for SC-1 through SC-5 (full mergeability diagnosis in check-pr context)
- **Expected result:** FAIL (RED)

#### GREEN (implement)

Replace the `state`/`merged`-only check in Phase 2 with the full mergeability check (SC-1 through SC-5). The mergeability diagnosis logic is the same as Step 1.

**Dispatch:** `task(subagent_type="general")` with context `{file: "skills/git-workflow/tasks/check-pr.md", scs: ["SC-1","SC-2","SC-3","SC-4","SC-5"]}`

### Step 4: Full mergeability signals in `verify-merge.md`

**File:** `skills/issue-operations/tasks/verify-merge.md`

#### RED (write failing behavioral test)

Write a behavioral test that verifies the merge verification step reads `mergeable`, `base.sha`, `updated_at`, `created_at` alongside `state` and `merged`. The test MUST fail because Step 2 only checks `state` and `merged`.

- **Test location:** `.opencode/tests/behaviors/verify-merge-mergeability.sh`
- **Assertions:** `assert_semantic` for SC-1 through SC-4 (mergeability signals in verify-merge context)
- **Expected result:** FAIL (RED)

#### GREEN (implement)

Extend Step 2's merge verification table to include `mergeable`, `base.sha`, `updated_at`, `created_at` fields alongside `state` and `merged` (SC-1 through SC-4).

**Dispatch:** `task(subagent_type="general")` with context `{file: "skills/issue-operations/tasks/verify-merge.md", scs: ["SC-1","SC-2","SC-3","SC-4"]}`

### Step 5: Verification — verification-before-completion

Run `skill({name: "verification-before-completion"})` to verify all 5 SCs against the modified files.

**Dispatch:** `task(subagent_type="general")` with context `{scs: ["SC-1","SC-2","SC-3","SC-4","SC-5"]}`

### Step 6: Audit — audit spec-fidelity

Run `skill({name: "audit", task: "spec-fidelity"})` to verify the implementation matches the spec.

**Dispatch:** `task(subagent_type="general")` with context `{spec_issue_number: 1795}`

### Step 7: Finishing checklist — finishing-a-development-branch

Run `skill({name: "finishing-a-development-branch"})` for branch readiness checks.

**Dispatch:** `task(subagent_type="general")`

### Step 8: Review prep — git-workflow review-prep

Run `skill({name: "git-workflow", task: "review-prep"})` for pre-PR review preparation.

**Dispatch:** `task(subagent_type="general")` with context `{base_branch: "dev"}`

## Exit Criteria

- All 5 SCs verified via behavioral test
- No `state`/`merged`-only PR status checks remain in affected files
- `mergeable: null` diagnosis path documented in all PR status check locations
- `base.sha` comparison and rebase trigger documented
- `updated_at == created_at` mergeability trigger documented
- SC-5 enforced: "PR is open" never a terminal status

## Admonishments

- Every change must be behavioral-tested (SC-1 through SC-5)
- Follow incremental build discipline: one SC per step
- No inline work — dispatch to sub-agents via `task()`
- No behavioral test substitution — FAIL if test cannot run
- All implementation-pipeline steps are mandatory — no exceptions
