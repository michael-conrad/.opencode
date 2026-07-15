# Plan: Cleanup leaves parent repo on stale branch, hardcoded dev references in cleanup.md

**Issue:** [michael-conrad/.opencode#1877](https://github.com/michael-conrad/.opencode/issues/1877)
**Authorization Scope:** `for_pr`
**Halt At:** `pr_created`
**Pipeline Phase:** plan-creation
**Branch:** `feature/1877-cleanup-parent-repo`

## Goal

Replace all 7 hardcoded `dev` references in `cleanup.md` with `$DEFAULT_BRANCH` or trunk-equivalent prose. The `branch-cleanup.md` file was already fixed in commit 0f901a3e and requires no changes. The `git branch --show-current` check and parent repo inclusion in repos-to-clean list are already implemented.

## Architecture

Single-phase plan. One file modification to `cleanup.md` (7 prose replacements), plus behavioral enforcement tests. All changes are string-level edits to a markdown task file.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` | Replace 7 hardcoded `dev` references with `$DEFAULT_BRANCH` or trunk-equivalent prose |
| `.opencode/tests-v2/behaviors/` (new) | Behavioral enforcement test for cleanup dev references |

## Phase Table

| Phase | Description | Steps | SCs |
|-------|-------------|-------|-----|
| 1 | Replace hardcoded `dev` in cleanup.md, write behavioral tests | 1-6 | SC-1, SC-2 |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | All 7 hardcoded `dev` references in cleanup.md replaced with `$DEFAULT_BRANCH` or trunk-equivalent prose | 1 | 1, 2, 3 |
| SC-2 | Behavioral enforcement tests verify the agent uses `$DEFAULT_BRANCH` instead of hardcoded `dev` in cleanup context | 1 | 4, 5, 6 |

## Phase 1: Replace hardcoded `dev` in cleanup.md

### Step 1: Research — identify all 7 hardcoded `dev` references in cleanup.md

**Dispatch:** Sub-agent via `task()`
**Chain:** `none`
**SC:** SC-1

Scan `cleanup.md` for all occurrences of `dev` used as a branch name reference. Produce a list of section locations and context for each occurrence. Distinguish between:
- Prose references to `dev` (e.g., "Switches to dev", "dev tip")
- Code block references (already use `$DEFAULT_BRANCH` — no change needed)
- False positives (`/dev/null`, `2>/dev/null`, `DEFAULT_BRANCH` variable name, `cd -`, `--delete`)

**Evidence artifact:** `{project_root}/tmp/1877/dev-references.txt`

### Step 2: Replace hardcoded `dev` in cleanup.md

**Dispatch:** Sub-agent via `task()`
**Chain:** `step_1`
**SC:** SC-1

Edit `cleanup.md` to replace all 7 hardcoded `dev` branch name references with `$DEFAULT_BRANCH` or trunk-equivalent prose. Specific locations (stable anchors — section headers):

1. **Exit Criteria** — "Submodule dev restored" → "Submodule trunk restored"
2. **Step 3 Purpose** — "Switches to dev" → "Switches to trunk"
3. **Step 4.3.a** — "Get local dev HEAD" → "Get local trunk HEAD"
4. **Step 4.3.b** — "Get remote dev HEAD" → "Get remote trunk HEAD"
5. **Step 4.3.e** — "repo is at dev tip" → "repo is at trunk tip"
6. **Step 4.5** — "All repos at dev tip" → "All repos at trunk tip"
7. **Step 1.5** — "Verify dev sync" → "Verify trunk sync"

**Verification:** Run `grep -n '\bdev\b' .opencode/skills/git-workflow-cleanup/tasks/cleanup.md` and confirm no branch-name usage of `dev` remains. False positives (`/dev/null`, `2>/dev/null`, `DEFAULT_BRANCH`, `cd -`, `--delete`) are acceptable.

**Evidence artifact:** Diff of changes made.

### Step 3: Verify SC-1 — no hardcoded `dev` branch references remain

**Dispatch:** Inline
**Chain:** `step_2`
**SC:** SC-1

```bash
grep -n '\bdev\b' .opencode/skills/git-workflow-cleanup/tasks/cleanup.md | grep -iv 'default_branch\|/dev/null\|--delete\|2>/dev/null\|cd -'
```

Expected: returns 0 matches. If non-zero, inspect each match and fix remaining occurrences.

### Step 4: Write behavioral enforcement test (RED phase)

**Dispatch:** Sub-agent via `task()`
**Chain:** `step_3`
**SC:** SC-2

Create a behavioral enforcement test in `.opencode/tests-v2/behaviors/` that verifies the agent uses `$DEFAULT_BRANCH` instead of hardcoded `dev` in cleanup context.

Test scenario: **`cleanup-dev-references.sh`**: Send a prompt that triggers cleanup behavior. Assert the agent uses `$DEFAULT_BRANCH` or trunk references instead of hardcoded `dev`. Use `assert_stderr_pattern_absent` for `dev` branch references and `assert_stderr_pattern_present` for `$DEFAULT_BRANCH` or trunk references.

**Evidence artifact:** Test script file in `.opencode/tests-v2/behaviors/`.

### Step 5: Run behavioral test — confirm RED state

**Dispatch:** Inline
**Chain:** `step_4`
**SC:** SC-2

```bash
bash .opencode/tests-v2/behaviors/cleanup-dev-references.sh
```

Expected: returns non-zero (RED — test fails because changes haven't been made yet).

### Step 6: Implement changes and confirm GREEN state

**Dispatch:** Sub-agent via `task()`
**Chain:** `step_5`
**SC:** SC-1, SC-2

Apply the changes identified in Step 2 to `cleanup.md`. This is the GREEN phase — make the changes that make the behavioral test pass.

After implementation, run:
```bash
bash .opencode/tests-v2/behaviors/cleanup-dev-references.sh
```

Expected: returns zero (GREEN — test passes after changes).

## Safety/Rollback Considerations

**Phase 1 — Safety/Rollback:**
- Destructive operations: None (all changes are string edits to a markdown task file)
- Rollback plan: `git checkout -- .opencode/skills/git-workflow-cleanup/tasks/cleanup.md` to revert all changes
- Data loss risk: none

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1, 2 | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` | ✅ | `editor_read_file` confirmed file exists with 356 lines |
| 4 | `.opencode/tests-v2/behaviors/` | ✅ | `glob` confirmed directory exists |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `cleanup.md` has 7 hardcoded `dev` references | `grep -n '\bdev\b'` on actual file, filtered for false positives | ✅ |
| `branch-cleanup.md` has 0 hardcoded `dev` references | `grep -n '\bdev\b'` on actual file, filtered for false positives | ✅ |
| `git branch --show-current` already exists in both files | `grep -n 'git branch --show-current'` on both files | ✅ |
| Parent repo already in repos-to-clean list | `editor_read_file` of cleanup.md Step 4.2 | ✅ |
| Spec is approved with `approved-for-pr` label | `github_issue_read(method=get_labels)` | ✅ |

## Exit Criteria

- [ ] SC-1: `grep -n '\bdev\b' cleanup.md` returns 0 for branch-name usage (evidence_type: string)
- [ ] SC-2: Behavioral test passes (evidence_type: behavioral) — requires `behavior_run` artifact generation AND `behavioral-test-evaluation` clean-room dispatch before PASS verdict

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
- SC-1 → Steps 1-3: Replace 7 hardcoded `dev` references in cleanup.md
- SC-2 → Steps 4-6: Behavioral enforcement test (RED → GREEN)

No phases added beyond what the spec requires. No scope creep.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
