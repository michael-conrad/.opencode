# Plan: Cleanup leaves parent repo on stale branch, hardcoded dev references

**Issue:** [michael-conrad/.opencode#1877](https://github.com/michael-conrad/.opencode/issues/1877)
**Authorization Scope:** `for_pr`
**Halt At:** `pr_created`
**Pipeline Phase:** plan-creation
**Branch:** `feature/1877-cleanup-parent-repo`

## Goal

Fix two root causes in the cleanup workflow:
1. Replace all hardcoded `dev` occurrences in `branch-cleanup.md` with `$DEFAULT_BRANCH`
2. Add `git branch --show-current` to `cleanup.md` Step 3 post-cleanup verification
3. Ensure parent repo is included in the repos-to-clean list in `cleanup.md` Step 4

## Architecture

This is a single-phase plan (no split needed). Three file modifications to two files, plus behavioral enforcement tests. All changes are string-level edits to markdown task files in the `.opencode/skills/git-workflow/tasks/cleanup/` directory.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md` | Replace all hardcoded `dev` with `$DEFAULT_BRANCH` |
| `.opencode/skills/git-workflow/tasks/cleanup.md` | Add `git branch --show-current` to Step 3; ensure parent repo in repos-to-clean list |
| `.opencode/tests/behaviors/` (new) | Behavioral enforcement tests for cleanup behavior |

## Phase Table

| Phase | Description | Steps | SCs |
|-------|-------------|-------|-----|
| 1 | Replace hardcoded `dev` in branch-cleanup.md, add show-current check, ensure parent repo in list, write behavioral tests | 1-10 | SC-1, SC-2, SC-3, SC-4 |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | All hardcoded `dev` references in branch-cleanup.md replaced with `$DEFAULT_BRANCH` | 1 | 1, 2, 3 |
| SC-2 | `cleanup.md` Step 3 or Step 4 includes `git branch --show-current` verification | 1 | 4, 5 |
| SC-3 | Parent repo is included in repos-to-clean list in `cleanup.md` Step 4 | 1 | 6 |
| SC-4 | Behavioral enforcement tests verify new cleanup behavior | 1 | 7, 8, 9, 10 |

## Phase 1: Fix Cleanup Workflow

### Step 1: Research — identify all hardcoded `dev` references in branch-cleanup.md

**Dispatch:** Sub-agent via `task()`
**Chain:** `none`
**SC:** SC-1

Scan `branch-cleanup.md` for all occurrences of `dev` used as a branch name reference. Produce a list of line numbers and context for each occurrence. Distinguish between:
- Prose references to `dev` (e.g., "sync dev", "Dev branch synced")
- Code block references (e.g., `git branch --merged "$DEFAULT_BRANCH"` already correct, but `git branch --merged dev` is wrong)
- Evidence artifact references (e.g., "dev tip")

**Evidence artifact:** `{project_root}/tmp/1877/dev-references.txt`

### Step 2: Replace hardcoded `dev` in branch-cleanup.md

**Dispatch:** Sub-agent via `task()`
**Chain:** `step_1`
**SC:** SC-1

Edit `branch-cleanup.md` to replace all hardcoded `dev` branch name references with `$DEFAULT_BRANCH`. Specific locations from the spec:

- Line 5: Purpose statement — "sync dev" → "sync trunk"
- Line 18: Exit criteria — "Dev branch synced" → "Trunk synced"
- Lines 300, 305, 341, 343, 429, 441: Prose and code block references
- Evidence artifact references: "dev tip" → "trunk tip"

**Verification:** Run `grep -n '\bdev\b' .opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md` and confirm no branch-name usage of `dev` remains. False positives (e.g., "developer", "submodule") are acceptable.

**Evidence artifact:** Diff of changes made.

### Step 3: Verify SC-1 — no hardcoded `dev` branch references remain

**Dispatch:** Inline
**Chain:** `step_2`
**SC:** SC-1

```bash
grep -c '\bdev\b' .opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md
```

Expected: returns 0 for branch-name usage. If non-zero, inspect each match and fix remaining occurrences.

### Step 4: Add `git branch --show-current` to cleanup.md Step 3

**Dispatch:** Sub-agent via `task()`
**Chain:** `step_3`
**SC:** SC-2

Edit `cleanup.md` Step 3 (Branch Cleanup and Sync) to add a `git branch --show-current` verification step after the branch-cleanup sub-task completes. The check should verify the repo is on the trunk branch after cleanup.

Add to Step 3:
```markdown
- [ ] **Post-cleanup branch verification:**
   ```bash
   CURRENT_BRANCH=$(git branch --show-current)
   DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
   if [ -z "$DEFAULT_BRANCH" ]; then DEFAULT_BRANCH="main"; fi
   if [ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" ]; then
       echo "WARNING: On branch '$CURRENT_BRANCH', expected '$DEFAULT_BRANCH'"
   else
       echo "Verified: on trunk branch '$DEFAULT_BRANCH'"
   fi
   ```
```

**Verification:** `grep 'git branch --show-current' .opencode/skills/git-workflow/tasks/cleanup.md` returns match.

### Step 5: Verify SC-2 — show-current check present

**Dispatch:** Inline
**Chain:** `step_4`
**SC:** SC-2

```bash
grep 'git branch --show-current' .opencode/skills/git-workflow/tasks/cleanup.md
```

Expected: at least one match in Step 3 or Step 4 context.

### Step 6: Ensure parent repo in repos-to-clean list in cleanup.md Step 4

**Dispatch:** Sub-agent via `task()`
**Chain:** `step_5`
**SC:** SC-3

Review `cleanup.md` Step 4 (Post-Cleanup Dev-Tip Verification). The spec says Step 4 already builds a `repos_to_check` list that includes the parent repo at index 0. Verify this is correct. If the parent repo is not explicitly included, add it.

The current Step 4 already has:
- Step 4.1: Detect parent repo path via `git rev-parse --show-superproject-working-tree`
- Step 4.2: Build repo list with parent at index 0 + submodules
- Step 4.3: For each repo, verify checked-out branch and compare hashes

If the parent repo inclusion is already correct, no change needed — document the verification.

**Verification:** `grep -A5 'parent.*repo\|repos_to_check\|index 0' .opencode/skills/git-workflow/tasks/cleanup.md` confirms parent repo is included.

### Step 7: Write behavioral enforcement tests (RED phase)

**Dispatch:** Sub-agent via `task()`
**Chain:** `step_6`
**SC:** SC-4

Create behavioral enforcement tests in `.opencode/tests/behaviors/` that verify the new cleanup behavior. Tests MUST fail (RED) before implementation changes are applied.

Test scenarios:
1. **`cleanup-branch-dev-references.sh`**: Send a prompt that triggers cleanup behavior. Assert the agent uses `$DEFAULT_BRANCH` instead of hardcoded `dev`. Use `assert_stderr_pattern_absent` for `dev` branch references and `assert_stderr_pattern_present` for `$DEFAULT_BRANCH` or trunk references.
2. **`cleanup-show-current.sh`**: Send a prompt that triggers cleanup post-verification. Assert the agent runs `git branch --show-current` as part of verification.

**Evidence artifact:** Test script files in `.opencode/tests/behaviors/`.

### Step 8: Run behavioral tests — confirm RED state

**Dispatch:** Inline
**Chain:** `step_7`
**SC:** SC-4

```bash
bash .opencode/tests/behaviors/cleanup-branch-dev-references.sh
bash .opencode/tests/behaviors/cleanup-show-current.sh
```

Expected: Both tests return non-zero (RED — tests fail because changes haven't been made yet).

### Step 9: Implement changes (GREEN phase)

**Dispatch:** Sub-agent via `task()`
**Chain:** `step_8`
**SC:** SC-1, SC-2, SC-3

Apply the changes identified in Steps 2, 4, and 6 to the affected files. This is the GREEN phase — make the changes that make the behavioral tests pass.

### Step 10: Run behavioral tests — confirm GREEN state

**Dispatch:** Inline
**Chain:** `step_9`
**SC:** SC-4

```bash
bash .opencode/tests/behaviors/cleanup-branch-dev-references.sh
bash .opencode/tests/behaviors/cleanup-show-current.sh
```

Expected: Both tests return zero (GREEN — tests pass after changes).

## Safety/Rollback Considerations

**Phase 1 — Safety/Rollback:**
- Destructive operations: None (all changes are string edits to markdown task files)
- Rollback plan: `git checkout -- .opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md .opencode/skills/git-workflow/tasks/cleanup.md` to revert all changes
- Data loss risk: none

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1, 2 | `.opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md` | ✅ | `editor_read_file` confirmed file exists with 471 lines |
| 4, 6 | `.opencode/skills/git-workflow/tasks/cleanup.md` | ✅ | `editor_read_file` confirmed file exists with 356 lines |
| 7 | `.opencode/tests/behaviors/` | ✅ | `glob` confirmed directory exists |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `branch-cleanup.md` has 40+ hardcoded `dev` references | Spec body (verified by reading file) | ✅ |
| `cleanup.md` Step 3 routes to `cleanup/branch-cleanup` | `editor_read_file` of `cleanup.md` line 116 | ✅ |
| `cleanup.md` Step 4 builds `repos_to_check` list | `editor_read_file` of `cleanup.md` lines 120-195 | ✅ |
| Spec is approved with `approved-for-pr` label | `github_issue_read(method=get_labels)` | ✅ |

## Exit Criteria

- [ ] SC-1: `grep -c '\bdev\b' branch-cleanup.md` returns 0 for branch-name usage (evidence_type: string)
- [ ] SC-2: `grep 'git branch --show-current' cleanup.md` returns match (evidence_type: string)
- [ ] SC-3: Parent repo is included in repos-to-clean list in cleanup.md Step 4 (evidence_type: string)
- [ ] SC-4: Behavioral tests pass (evidence_type: behavioral) — requires `behavior_run` artifact generation AND `behavioral-test-evaluation` clean-room dispatch before PASS verdict

## Implementation Pipeline Gates

After plan creation, the following pipeline gates MUST execute in order:
1. **Pre-work** (git-workflow) — verify branch state, tag submodules
2. **Implementation pipeline** (implementation-pipeline) — dispatch RED/GREEN sub-agents
3. **Verification-before-completion** — verify all SCs with evidence artifacts
4. **Finishing checklist** (finishing-a-development-branch) — final checks
5. **Review prep** (git-workflow --task review-prep) — prepare for PR
6. **PR creation** (git-workflow --task pr-creation) — create PR with stacked strategy
7. **Cleanup** (git-workflow --task cleanup) — post-merge cleanup

## Plan-Spec Alignment

The plan implements exactly what the spec defines:
- SC-1 → Steps 1-3: Replace hardcoded `dev` in branch-cleanup.md
- SC-2 → Steps 4-5: Add `git branch --show-current` to cleanup.md
- SC-3 → Step 6: Ensure parent repo in repos-to-clean list
- SC-4 → Steps 7-10: Behavioral enforcement tests (RED → GREEN)

No phases added beyond what the spec requires. No scope creep.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
