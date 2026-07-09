# Task: review-prep/push-and-cleanup

## Purpose

Clean temp files, handle submodule push automation, rebase on current trunk, and verify branch is pushed to remote — all prerequisite steps before generating the compare URL.

## Default Branch Resolution

```bash
DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
if [ -z "$DEFAULT_BRANCH" ]; then DEFAULT_BRANCH="main"; fi
```

## Entry Criteria

- All implementation work complete
- Feature branch exists (may or may not be pushed)

## Exit Criteria

- Temp files cleaned
- Submodule changes pushed (if applicable)
- Branch rebased on current trunk
- Branch pushed to remote with tracking

## Procedure

### Step 0: Submodule Feature Push via Sub-Agent Orchestrator Dispatch (CONDITIONAL)

**If no submodules detected via glob scan:** Skip entirely.

**If submodules detected:** The orchestrator dispatches a sub-agent via `task(subagent_type="general")` to handle submodule push automation instead of executing inline bash.

#### Task Context Schema

The sub-agent receives exactly this context — nothing more:

```yaml
must_receive:
  - parent_repo_owner: string   # github.owner of parent repo
  - parent_repo_name: string    # github.repo of parent repo
  - parent_branch: string       # feature branch name in parent
  - submodule_paths: string[]   # list of submodule paths from glob scan
  - dev_name: string            # developer name for commit authorship
  - dev_email: string           # developer email for commit authorship

must_not_receive:
  - Any implementation context
  - Agent reasoning or cached results
  - Expected outcomes or pre-determined file paths
  - Parent repo implementation details or work state
```

#### Result Contract Schema

The sub-agent returns:

```yaml
status: "DONE" | "FAILED" | "SKIPPED"
submodule_results:
  - path: string
    status: "PUSHED" | "NO_CHANGES" | "FAILED"
    sha: string | null
    error: string | null
evidence_artifacts:
  - check: "submodule_foreach_diff"
    result: "ALL_CLEAN" | "CHANGED_DETECTED" | "NOT_RUN"
  - check: "push_verification"
    result: "PUSHED" | "FAILED" | "SKIPPED"
```

**Sub-agent push failure (any submodule returns FAILED):** BLOCK parent repo push. Report which submodule failed. Do NOT proceed to Step 1.

**`--skip-submodules` flag:** Warn and proceed without submodule push steps. Skip task() entirely; go to Step 1.

**Provenance tracking after submodule push:** Invoke `` `skill({name: "git-workflow"})` `` then `` `task(..., prompt: "execute provenance task from git-workflow with mode=trunk-push")` `` for each pushed submodule. Provenance is best-effort tracking.

### Step 1: Temp File Cleanup (MANDATORY)

Clean scoped issue temp files. Pipeline artifacts under `{project_root}/tmp/{issue-N}/artifacts/` are NOT cleaned here — they are cleaned by the step-specific pre-cleanup table in implementation-pipeline SKILL.md and at PR merge by the cleanup task.

```bash
rm -rf {project_root}/tmp/{issue-N}/temp_*.py {project_root}/tmp/{issue-N}/test_*.py {project_root}/tmp/{issue-N}/design-*.md 2>/dev/null
rm -rf {project_root}/tmp/{issue-N}/.cache 2>/dev/null
```

### Step 1.5: Rebase on Current Trunk (MANDATORY)

```bash
git fetch origin
git rebase origin/"$DEFAULT_BRANCH"
```

**If conflicts:** Invoke `conflict-resolution` skill to classify and resolve:
- Tier 1 (Trivial): auto-resolve, silent
- Tier 2 (Textual but safe): auto-resolve, note in chat
- Tier 3 (Intent conflict): HALT for developer review

🚫 NEVER resolve ALL conflicts with `git checkout --theirs/--ours` without classification.

**This step is MANDATORY even if no other agents are known to be working.**

### Step 2: Verify Branch Is Pushed

```bash
git branch -vv
```

**If branch is NOT pushed to remote:**
```bash
git push -u origin <branch-name>
```

## Branch Mode (Conditional — Based on WORKTREE_REQUIRED)

**Direct-branch mode (default — when `WORKTREE_REQUIRED` is NOT set):**

- Operate normally from the main repo directory
- Relative paths work directly
- No worktree path prefixing needed
- `git fetch`/`git rebase` run directly

**Worktree mode (opt-in — when `WORKTREE_REQUIRED` is set):**

If `worktree.path` is not set or empty: **FATAL ERROR → FLAG DEV → HALT.** Do not proceed without a valid worktree path.

1. All `bash` calls use `workdir="{{worktree.path}}"`
2. All `read`/`edit`/`write`/`glob`/`grep` prefix with `{{worktree.path}}/`
3. Verify branch before push: `git branch --show-current`
4. `git rev-parse --show-toplevel` MUST return the worktree path
5. NEVER operate in the main working directory during worktree mode

### Step 2.5: Worktree Handoff (CONDITIONAL)

**Only when `worktree.path` is set (autonomous mode).** Skip in pair mode.

1. Remove worktree: `git worktree remove <worktree.path>`
   - Failure: try `git worktree remove --force <worktree.path>`
   - Unrecognized: `rm -rf <worktree.path>` (orphaned directory)
2. Checkout feature branch: `git checkout <branch-name>`
   - Dirty tree fallback: `git stash push -m "auto-stash before worktree-handoff"` then retry
   - Branch not found locally: `git fetch origin <branch-name> && git checkout -b <branch-name> origin/<branch-name>`
3. Clear `worktree.path` session variable

**⚠️ After handoff, all subsequent file operations use main repo path.**

## Live Verification (MANDATORY)

| Check | Command | Expected |
| -- | -- | -- |
| Working tree clean | `git status --porcelain` | Empty |
| Commits ahead of dev | `git log "$DEFAULT_BRANCH"..HEAD --oneline` | At least one |
| Tracking branch exists | `git branch -vv` | `[origin/<branch>]` |
| All commits pushed | `git diff @{u} HEAD` | Empty |
| Branch on correct base | `git merge-base HEAD origin/"$DEFAULT_BRANCH"` | Dev-based SHA |

## Push-Then-URL Enforcement (MANDATORY — Bug #1231)

**⚠️ Generating a compare URL before confirming `git push` succeeded is a CRITICAL GUIDELINE VIOLATION.**

The compare URL MUST NOT be generated or reported until ALL of the following are verified:

1. `git push -u origin <branch-name>` returned exit code 0
2. `git branch -vv` shows tracking branch `[origin/<branch-name>]`
3. `git diff @{u} HEAD` returns empty (all commits pushed)

If push fails: DO NOT generate a compare URL. Report the push failure and HALT.

**Rationale:** Bug #1231 documented an agent that generated a compare URL from session-init values without first pushing the branch. The URL was syntactically valid but pointed to a non-existent remote branch — a fabricated URL that cannot resolve. Push-then-URL ordering ensures the compare URL points to reality.

## Context Required

- Related tasks: `review-prep/report-url`
- Related skills: `conflict-resolution`, `git-workflow --task provenance`