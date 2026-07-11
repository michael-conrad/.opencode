# Plan: Remove dead body-revision check from comment task, add routing gate

## Goal

Remove the dead Step 1.5b body-revision check from `issue-operations/tasks/comment.md`, remove the misleading annotation from the classification table, add a routing gate that redirects spec/plan corrections to the correct pipeline, and add a behavioral enforcement test.

## Architecture

Single file change: `.opencode/skills/issue-operations/tasks/comment.md`. The comment task's only job is posting comments — not revising bodies. Spec corrections route to `spec-creation --task change-control`. Plan corrections route to `writing-plans --task update`.

## Files

| File | Change |
|------|--------|
| `.opencode/skills/issue-operations/tasks/comment.md` | Remove Step 1.5b, remove dead annotation, add routing gate |
| `.opencode/tests/behaviors/1871-spec-correction-routing.sh` | New behavioral enforcement test |

## Phase Table

| Phase | ID | SCs | Description |
|-------|----|-----|-------------|
| 1 | implementation | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 | Remove dead code, add routing gate, add behavioral test |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | Step 1.5b removed from `comment.md` | 1 | 1.1 |
| SC-2 | Dead annotation removed from classification table | 1 | 1.2 |
| SC-3 | Routing gate redirects spec corrections to `spec-creation --task change-control` | 1 | 1.3 |
| SC-4 | Routing gate redirects plan corrections to `writing-plans --task update` | 1 | 1.3 |
| SC-5 | Agent routes spec corrections to `spec-creation`, not `issue-operations --task comment` | 1 | 1.4 |
| SC-6 | No body-revision logic remains in `comment.md` | 1 | 1.1, 1.2 |

## Safety/Rollback

**Phase 1 — Safety/Rollback:**
- Destructive operations: None (file edits only, no deletions)
- Rollback plan: `git checkout feature/1861-1871-1872-1873-stale-branch-detection -- .opencode/skills/issue-operations/tasks/comment.md`
- Data loss risk: None

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `.opencode/skills/issue-operations/tasks/comment.md` | ✅ | `editor_read_file` |
| 1.2 | `.opencode/skills/issue-operations/tasks/comment.md` line 56 | ✅ | `editor_read_file` |
| 1.3 | `.opencode/skills/spec-creation/tasks/change-control.md` | ✅ | Spec documentation |
| 1.3 | `.opencode/skills/writing-plans/tasks/update.md` | ✅ | Spec documentation |
| 1.4 | `.opencode/tests/behaviors/` | ✅ | Existing behavioral tests |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| Step 1.5b exists in comment.md | `editor_read_file` lines 63-81 | ✅ |
| Dead annotation exists at line 56 | `editor_read_file` line 56 | ✅ |
| spec-creation change-control task exists | Spec documentation | ✅ |
| writing-plans update task exists | Spec documentation | ✅ |

---

# Phase 1: Implementation

## Step 1.1: Remove Step 1.5b (body-revision check)

**SC:** SC-1, SC-6

Delete lines 63-81 from `.opencode/skills/issue-operations/tasks/comment.md` — the entire "### Step 1.5b: Body-Revision Check" section including the heading, the classification gate, the update spec body flow, the rationale paragraph, and the classification interaction note.

**Verification:** `grep -c "Step 1.5b" .opencode/skills/issue-operations/tasks/comment.md` returns 0.

## Step 1.2: Remove dead annotation from classification table

**SC:** SC-2, SC-6

On line 56 of `.opencode/skills/issue-operations/tasks/comment.md`, change:
```
| Revising/correcting spec | **internal** (triggers Phase 3 body update) | Correction updates the issue body, not a comment |
```
to:
```
| Revising/correcting spec | **internal** | Correction updates the issue body, not a comment |
```

**Verification:** `grep -c "triggers Phase 3 body update" .opencode/skills/issue-operations/tasks/comment.md` returns 0.

## Step 1.3: Add routing gate for spec/plan corrections

**SC:** SC-3, SC-4, SC-6

After the classification table (after line 61, the error handling paragraph), add a routing gate section that redirects spec/plan corrections to the correct pipeline:

```markdown
### Step 1.5b: Routing Gate for Spec/Plan Corrections

When content is classified as "Revising/correcting spec" or "Revising/correcting plan", do NOT post a comment. Route to the correct pipeline:

| Content Type | Route To |
|---|---|
| Revising/correcting spec | `spec-creation --task change-control` |
| Revising/correcting plan | `writing-plans --task update` |

The comment task's only job is posting comments — not revising bodies, not updating specs, not modifying plans.
```

**Verification:**
- `grep "spec-creation.*change-control" .opencode/skills/issue-operations/tasks/comment.md` returns match
- `grep "writing-plans.*update" .opencode/skills/issue-operations/tasks/comment.md` returns match
- `grep -c "body.*revision\|body.*update\|spec body" .opencode/skills/issue-operations/tasks/comment.md` returns 0 (excluding the routing gate itself)

## Step 1.4: Add behavioral enforcement test

**SC:** SC-5

Create `.opencode/tests/behaviors/1871-spec-correction-routing.sh` that:
1. Sends a prompt asking the agent to correct a spec
2. Verifies stderr shows `Skill "spec-creation"` dispatch
3. Verifies stderr does NOT show `issue-operations` comment task dispatch

**Verification:** `bash .opencode/tests/behaviors/1871-spec-correction-routing.sh` passes.

## Phase 1 Exit Criteria

| SC ID | Evidence Type | Verification Method |
|-------|---------------|---------------------|
| SC-1 | `string` | `grep -c "Step 1.5b" .opencode/skills/issue-operations/tasks/comment.md` == 0 |
| SC-2 | `string` | `grep -c "triggers Phase 3 body update" .opencode/skills/issue-operations/tasks/comment.md` == 0 |
| SC-3 | `string` | `grep "spec-creation.*change-control" .opencode/skills/issue-operations/tasks/comment.md` matches |
| SC-4 | `string` | `grep "writing-plans.*update" .opencode/skills/issue-operations/tasks/comment.md` matches |
| SC-5 | `behavioral` | `bash .opencode/tests/behaviors/1871-spec-correction-routing.sh` passes |
| SC-6 | `string` | `grep -c "body.*revision\|body.*update\|spec body" .opencode/skills/issue-operations/tasks/comment.md` == 0 (excluding routing gate) |
