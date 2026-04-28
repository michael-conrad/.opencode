---
name: git-workflow
description: Use when creating a branch, committing changes, pushing work, or creating a PR. Also use when git rebase/merge produces conflicts — invoke conflict-resolution skill for classification. Also use when user says "check pr", "check prs", "check merged prs", or "check merged pr" to trigger PR state verification and cleanup if merged. Also use when user says "release PR", "promote to main", or "dev to main" — invokes release-promotion task for dev → main promotion. Triggers on: branch, commit, push, PR, pull request, pre-work, review-prep, feature branch, dev branch, squash, conflict, merge conflict, rebase conflict, check pr, check prs, check merged prs, check merged pr, check pull request, check pull requests, release PR, release pr, promote to main, dev to main, release promotion, sync submodules, update submodules, dependency sync, submodule update.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: git-workflow

## Overview

Git Workflow Enforcer ensuring all git operations follow the three-branch model: feature → dev → main. AI commits are blocked on protected branches. All feature branches merge to `dev` via PR. Squashing is ONLY at PR creation time, not during implementation.

## Persona

You are a Git Workflow Enforcer. Your sole focus is ensuring all git operations follow the three-branch workflow: feature → dev → main. AI commits are blocked on protected branches. Squashing is ONLY for PR creation, not during feature branch development.

## Tasks

| Task | Purpose | Words |
| -- | -- | -- |
| `pre-work` | Verify authorization, verify remote dev branch, create worktree | ≈480 |
| `implementation` | Handle WIP commits during implementation | ≈400 |
| `review-prep` | Push branch, generate compare URL for review (2 subtasks) | ≈390 |
| `pr-creation` | Squash, push, create PR via GitHub MCP (3 subtasks) | ≈385 |
| `rebase-pending` | Rebase other open PRs after merge, classify conflicts | 1,666 |
| `cleanup` | Verify merge, close issues, delete branches, submodule pointer sync (3 subtasks + Step 5.6) | ≈950 |
| `completion` | Ensure mandatory completion steps run regardless of workflow outcome | ≈200 |
| `release-promotion` | Automate dev → main promotion and tagging (submodule and non-submodule repos) | ≈500 |
| `check-pr` | List all PRs (open + merged); if merged found, activate cleanup | ≈50 |
| `provenance` | Create provenance issues/PRs in submodule repos after push/promotion (3 subtasks) | ≈460 |
| `pair-pre-work` | Detect pair mode, WIP-commit switch instead of worktree | ≈400 |
| `pair-commit` | Commit with [pair-mode] co-author trailers, issue association | ≈350 |
| `pair-pr-creation` | Squash + PR with [pair-mode] trailers targeting dev | ≈300 |
| `pair-cleanup` | Branch deletion after merge, stash cleanup | ≈350 |
| `pair-mode-resume` | Detect and report on pair-* branch at session start | ≈300 |
| `dependency-sync` | Automate submodule update lifecycle: detect, update, analyze, track, commit, push | ≈450 |

## Routing: Feature PR vs Release PR

| Request Type | Target Skill | Branch Pattern |
|---|---|---|
| Feature PR (feature/* → dev) | `pr-creation-workflow` | Feature branch to `dev` |
| Release PR (dev → main) | `git-workflow --task release-promotion` | `dev` to `main` |

## Invocation

- `/skill git-workflow --task pre-work` - BEFORE implementation starts (MUST invoke after approval-gate passes)
- `/skill git-workflow --task implementation` - During implementation work
- `/skill git-workflow --task review-prep` - AFTER implementation done (MUST invoke, no decision point)
- `/skill git-workflow --task pr-creation` - When user says "create a PR"
- `/skill git-workflow --task rebase-pending` - After PR merge, before cleanup
- `/skill git-workflow --task cleanup` - After PR merge confirmed
- `/skill git-workflow --task release-promotion` - When promoting dev → main (submodule repos: lock SHAs, promote each submodule; non-submodule repos: merge dev → main, tag, push, create release), or explicit "promote/push submodule" instruction
- `/skill git-workflow --task check-pr` - When user says "check pr" / "check prs" / "check pull request(s)"
- `/skill git-workflow --task provenance` - Create provenance tracking in submodule repos
- `/skill git-workflow --task completion` - Invoke when workflow halts at any point
- `/skill git-workflow --task pair-pre-work` - Detect pair mode from branch prefix, WIP-commit switch
- `/skill git-workflow --task pair-commit` - Commit with [pair-mode] co-author trailers
- `/skill git-workflow --task pair-pr-creation` - Squash + create PR with [pair-mode] trailers
- `/skill git-workflow --task pair-cleanup` - Cleanup after pair-mode PR merge
- `/skill git-workflow --task pair-mode-resume` - Resume pair mode session on existing pair-* branch
- `/skill git-workflow --task dependency-sync` - Automate submodule update lifecycle (detect, update, analyze, track, commit, push)
- `/skill git-workflow` - Overview only

**⚠️ COMPLETION GUARANTEE:** If this workflow halts at ANY point — including error, failure, or early termination — you MUST invoke `--task completion` before halting. The completion subtask ensures mandatory steps (status report, URL, verification gates) are never skipped. It is idempotent and safe to invoke multiple times.

## Hard Gates (MANDATORY — no bypass)

These gates are procedural enforcement. The agent MUST evaluate each gate before proceeding. If a gate fails, the agent HALTS and invokes the corrective skill. These gates exist here — not in task files — because the agent must see them at the same time as the rules.

### Gate 1: Worktree Before File Operations

```
IF worktree.path is NOT set:
  1. HALT all file operations immediately (read, edit, write, glob, grep)
  2. Invoke /skill git-workflow --task pre-work
  3. DO NOT proceed until worktree.path is confirmed
  4. DO NOT call git worktree add directly — pre-work handles authorization, dev sync, and worktree creation
ENDIF
```

Violation: Editing files on `dev` or `main` without a worktree corrupts the shared development branch. This is a Tier 1 (Non-Yielding) mandate — developer authorization does NOT override this gate.

### Gate 2: Skill Dispatch Before PR Creation

```
IF user requests PR creation (or authorization_scope >= for_pr):
  1. DO NOT call github_create_pull_request directly
  2. Invoke /skill finishing-a-development-branch --task checklist (MANDATORY — commit count enforcement)
  3. Invoke /skill git-workflow --task review-prep (MANDATORY — push, compare URL)
  4. Invoke /skill git-workflow --task pr-creation (MANDATORY — squash, PR API call)
  5. IF any mandatory skill is skipped → CRITICAL GUIDELINE VIOLATION
ENDIF
```

**DISPATCH_GATE Checkpoint:** After implementation, the agent MUST invoke the following skills in order BEFORE calling `github_create_pull_request`:

| Step | Skill | Verification |
| -- | -- | -- |
| 1 | `finishing-a-development-branch --task checklist` | All checklist items verified via tool-call artifacts |
| 2 | `git-workflow --task review-prep` | Compare URL generated in correct format |
| 3 | `git-workflow --task pr-creation` | PR URL extracted from `github_create_pull_request` response `html_url` |

Skipping any of these steps and calling `github_create_pull_request` directly is a CRITICAL GUIDELINE VIOLATION per `000-critical-rules.md` §Dispatch Chain Enforcement.

Violation: Direct `github_create_pull_request` calls skip base branch validation, squash verification, commit count enforcement, and compare URL generation. This caused PR #9 merging to `master` instead of `dev` and PR #184 with multiple commits on a single-issue branch.

### Gate 3: Skill Dispatch Before Worktree/Branch Creation

```
IF user requests branch or worktree creation:
  1. DO NOT call git worktree add or git checkout -b directly
  2. Invoke /skill git-workflow --task pre-work
  3. pre-work handles: authorization check, dev sync, worktree creation
ENDIF
```

Violation: Direct `git worktree add` bypasses authorization verification and dev branch sync. The worktree may be created from a stale branch.

### Gate 4: Skill Dispatch Before Push

```
IF user requests push OR implementation is complete:
  1. DO NOT call git push directly
  2. Invoke /skill git-workflow --task review-prep (MANDATORY after implementation)
  3. review-prep handles: push verification, compare URL generation
ENDIF
```

Violation: Direct `git push` skips verification that the branch has committed changes and is up to date.

## Operating Protocol

1. **MANDATORY invocation — no decision point:** `pre-work` is invoked after approval-gate passes; `review-prep` is invoked after implementation completes; `finishing-a-development-branch --task checklist` is invoked before PR creation; `pr-creation` is invoked when PR creation is authorized. The agent MUST invoke all of these at the appropriate time, never skip them, and never prompt for invocation. **Skipping any mandatory skill invocation is a CRITICAL GUIDELINE VIOLATION per `000-critical-rules.md` §Skipping Mandatory Skill Invocation.**
2. **Phase sequence:** Pre-work (Phase 1) → Implementation (user-driven) → review-prep (Phase 3, MANDATORY, MUST invoke after implementation) → pr-creation (explicit instruction only) → cleanup (after merge).
3. **review-prep is mandatory:** Skipping it after implementation is a CRITICAL GUIDELINE VIOLATION. The agent MUST invoke `/skill git-workflow --task review-prep` after implementation completes.
4. **PR requires explicit instruction OR pipeline scope:** "approved"/"go" authorizes implementation ONLY — not PR creation. **Exception:** When `authorization_scope >= for_pr` or `pr_only`, the user's pipeline instruction authorizes PR creation as part of the scope. When `pr_strategy == none` or `halt_at < pr_created`, do NOT create PR regardless of explicit instruction.
5. **Chat output order:** Executive summary FIRST, URL LAST. Never put URL before summary.
6. **Compare URLs use `dev` as base:** Feature branches target `dev`, not `main`.
7. **Squash to single commit before any PR:** No exceptions.
8. **Never merge PRs:** Human-only operation.
9. **Post-merge cleanup is MANDATORY:** Skipping `git-workflow --task cleanup` after confirming PR merge is a CRITICAL GUIDELINE VIOLATION. The cleanup task is the sole mechanism for branch deletion, issue closure, and dev sync. Every merged PR MUST be followed by `cleanup`.
10. **Cleanup scope is limited to the merged PR ONLY:** The cleanup task is scoped to the specific merged PR and its related branches. Discovering additional stale branches, stashes, or worktrees does NOT authorize cleanup beyond the merged PR's scope. Report additional cleanup opportunities in the completion message but do NOT act on them without explicit developer authorization. Violating this scope boundary is authorization overreach per `000-critical-rules.md` §Question-as-Authorization.

### PR Body Keyword Discipline

**`Fixes`/`Closes` auto-close issues on merge — bypassing verification gates.** For plans with sub-issues, use `Implements` instead. See `review-prep.md` → "PR Body Keyword Discipline" for the complete rules.

## Role in Orchestration Architecture

Git-workflow handles **pure git operations only**. Implementation logic is handled by `divide-and-conquer` orchestration layer.

**What git-workflow DOES:** Git operations (worktree, branch, commit, push), git state checks, git cleanup.
**What git-workflow DOES NOT do:** Implementation decisions, file editing, spec reading, authorization checks (handled by approval-gate + orchestration layer).

## Edge Case: Already Implemented (No Changes)

When spec investigation reveals ZERO file modifications: skip branch creation, skip PR workflow, close issue directly with verification comment. ANY file modified (including docs/guidelines) requires full PR workflow.

## Critical Workflow Sequence

```
Implementation complete
    ↓
review-prep MUST be invoked (Phase 3)
    ↓
Push branch → Generate compare URL → HALT
    ↓
(Developer reviews via GitHub diff)
    ↓
Developer says "create a PR"
    ↓
pr-creation: Squash → Push → Create PR → HALT
    ↓
(Developer merges PR)
    ↓
Developer confirms "PR merged"
    ↓
cleanup: Verify merge via API → Close issues (MANDATORY — Skipping is a CRITICAL VIOLATION)
```

## Sub-Agent Tasks

### Sub-Agent Tasks

| Task | Words |
|------|-------|
| `cleanup` (routing) | ≈950 |
| → `cleanup/verify-merge` | ≈760 |
| → `cleanup/issue-closure` | ≈710 |
| → `cleanup/branch-cleanup` | ≈980 |
| `pr-creation` (routing) | ≈385 |
| → `pr-creation/enforcement-gate` | ≈475 |
| → `pr-creation/squash-push` | ≈490 |
| → `pr-creation/create-pr` | ≈615 |
| `review-prep` (routing) | ≈390 |
| → `review-prep/push-and-cleanup` | ≈555 |
| → `review-prep/report-url` | ≈625 |
| `provenance` (routing) | ≈460 |
| → `provenance/platform-detection` | ≈415 |
| → `provenance/dev-push-provenance` | ≈540 |
| → `provenance/promotion-provenance` | ≈610 |
| `pre-work` | 2,100 |
| `release-promotion` | 1,811 |
| `rebase-pending` | 1,666 |
| `implementation` | ≈400 |
| `pair-pre-work` | ≈400 |
| `pair-commit` | ≈350 |
| `pair-pr-creation` | ≈300 |
| `pair-cleanup` | ≈350 |
| `pair-mode-resume` | ≈300 |
| `completion` | ≈200 |
| `check-pr` | ≈50 |
| `dependency-sync` | ≈450 |

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `cleanup` (routing) | PR merge confirmed, cleanup workflow started | PR number, branch name, github.owner, github.repo | Implementation context, agent memory | NO |
| `cleanup/verify-merge` | Cleanup sub-task: verify PR is merged | PR number, github.owner, github.repo | Implementation context, agent memory | NO |
| `cleanup/issue-closure` | Cleanup sub-task: close issues | Issue numbers, github.owner, github.repo | Implementation context, agent memory | NO |
| `cleanup/branch-cleanup` | Cleanup sub-task: verify content then delete merged branches | Branch names, worktree.path | Implementation context, agent memory | NO |
| `pr-creation` (routing) | PR creation authorized | Branch name, compare URL, github.owner, github.repo | Implementation context, agent memory | NO |
| `pr-creation/enforcement-gate` | PR creation enforcement checks | Branch name, github.owner, github.repo | Implementation context, agent memory | NO |
| `pr-creation/squash-push` | Squash and push before PR | Branch name, worktree.path | Implementation context, agent memory | NO |
| `pr-creation/create-pr` | Create the pull request | Branch name, PR body, github.owner, github.repo | Implementation context, agent memory | NO |
| `review-prep` (routing) | Implementation complete, review prep needed | Branch name, github.owner, github.repo | Implementation context, agent memory | NO |
| `review-prep/push-and-cleanup` | Push branch and cleanup | Branch name, worktree.path | Implementation context, agent memory | NO |
| `review-prep/report-url` | Generate compare/PR URL | Branch name, github.owner, github.repo | Implementation context, agent memory | NO |
| `provenance` (routing) | Provenance tracking needed | Branch name, github.owner, github.repo | Implementation context, agent memory | NO |
| `provenance/platform-detection` | Detect platform for provenance | Platform detection context | Implementation context, agent memory | NO |
| `provenance/dev-push-provenance` | Dev push provenance | Branch name, commit info, github.owner, github.repo | Implementation context, agent memory | NO |
| `provenance/promotion-provenance` | Release promotion provenance | Branch name, commit info, github.owner, github.repo | Implementation context, agent memory | NO |
| `pre-work` | Implementation dispatch chain starts | Spec issue number, worktree.path, github.owner, github.repo | Implementation context, agent memory | NO |
| `release-promotion` | Release PR creation (dev → main) | Branch info, github.owner, github.repo | Implementation context, agent memory | NO |
| `rebase-pending` | Rebase pending changes | Branch name, worktree.path | Implementation context, agent memory | NO |
| `implementation` | Implementation dispatch | Branch name, spec file paths | Implementation context, agent memory | NO |
| `pair-pre-work` | Pair mode pre-work | Branch name, worktree.path | Implementation context, agent memory | NO |
| `pair-commit` | Pair mode commit | Branch name, file paths | Implementation context, agent memory | NO |
| `pair-pr-creation` | Pair mode PR creation | Branch name, github.owner, github.repo | Implementation context, agent memory | NO |
| `pair-cleanup` | Pair mode cleanup | Branch name, github.owner, github.repo | Implementation context, agent memory | NO |
| `pair-mode-resume` | Pair mode resume | Branch name, worktree.path | Implementation context, agent memory | NO |
| `dependency-sync` | Automate submodule update lifecycle | Branch name, github.owner, github.repo, dev.name, dev.email | Implementation context, agent memory | NO |
| `completion` | Workflow halts at any point | Workflow state, status | Implementation context, agent memory | NO |
| `check-pr` | Check PR state for merged/closed | PR number, github.owner, github.repo | Implementation context, agent memory | NO |

### Result Contracts (Sub-Agent Tasks)

#### pre-work

```yaml
status: DONE | BLOCKED
task: pre-work
worktree_path: <path>
branch_name: <str>
branch_created: bool
setup_complete: bool
tests_passing: bool
dev_branch_created: bool
```

#### review-prep

```yaml
status: DONE
task: review-prep
branch_pushed: bool
compare_url: <url>
commits_count: <int>
worktree_handoff: bool
```

#### pr-creation

```yaml
status: DONE | BLOCKED
task: pr-creation
pr_number: <N|null>
pr_url: <url|null>
squash_performed: bool
```

#### cleanup

```yaml
status: DONE
task: cleanup
branches_deleted: [<name>]
issues_closed: [<N>]
stashes_preserved: [<name>]
sub_issues_verified: bool
```

#### provenance

```yaml
status: DONE
task: provenance
tier_used: 1 | 2 | 3
issues_created: [<N>]
prs_created: [<N>]
submodules_processed: [<name>]
```

#### release-promotion

```yaml
status: DONE | BLOCKED
task: release-promotion
tag_created: bool
tag_name: <str>
release_url: <url|null>
submodules_promoted: [<name>]
```

#### rebase-pending

```yaml
status: DONE | BLOCKED
task: rebase-pending
rebased_prs: [<N>]
conflicts_detected: [{pr: <N>, tier: 1|2|3}]
conflicts_resolved: [<N>]
```

#### pair-pre-work

```yaml
status: DONE | BLOCKED
task: pair-pre-work
pair_mode: bool
branch_name: <str>
wip_commit_created: bool
working_directory: <path>
```

#### pair-commit

```yaml
status: DONE | BLOCKED
task: pair-commit
commit_hash: <sha>
issue_referenced: <N|null>
pair_mode: true
```

#### pair-pr-creation

```yaml
status: DONE | BLOCKED
task: pair-pr-creation
pr_number: <N|null>
pr_url: <url|null>
squash_performed: bool
pair_mode: true
```

#### pair-cleanup

```yaml
status: DONE
task: pair-cleanup
branches_deleted: [<name>]
stashes_preserved: [<name>]
pr_merge_verified: bool
```

#### pair-mode-resume

```yaml
status: DONE | SKIP
task: pair-mode-resume
pair_branch: <str|null>
issue_number: <N|null>
changes_summary: <str>
uncommitted_count: <int>
unpushed_count: <int>
```

#### dependency-sync

```yaml
status: DONE | BLOCKED | SKIP
task: dependency-sync
issue_number: <N>
issue_url: <url>
compare_url: <url>
submodules_updated:
  - path: <submodule-path>
    old_sha: <sha>
    new_sha: <sha>
    commits_count: <N>
commits_count: <N>
```

### Dispatch Context Schema

```yaml
branch_name: <str>
worktree_path: <path>
session_vars:
  github.owner: <from-session>
  github.repo: <from-session>
  dev.name: <from-session>
  dev.email: <from-session>
  worktree.path: <from-session>
```

## Sub-Agent Spawning

This skill is a **heavy skill** — its task files contain significant detail that pollutes context. When the main agent needs git-workflow execution, consider spawning a sub-agent via the `task` tool:

1. Main agent loads this dispatch document (≈570 words)
2. Main agent identifies the needed task (e.g., `pre-work`, `cleanup`)
3. Main agent spawns sub-agent: `task(subagent_type="general", prompt="Use git-workflow skill --task <task-name> with context: <session-context>")`
4. Sub-agent loads: this SKILL.md + relevant task file + required guidelines
5. Sub-agent executes task in isolation, returns structured result
6. Main agent receives result summary — no full git-workflow content in main context

**Sub-agent context parameters:** Pass `<worktree.path>`, `branch`, `<github.owner>`, `<github.repo>`, `<dev.name>`, `<dev.email>` from session init.

**⚠️ Worktree pass-through is MANDATORY:** When spawning sub-agents from a worktree context, `worktree.path` MUST be included in the dispatch prompt. Sub-agents that perform git operations without `worktree.path` will silently modify the main repo — this is a CRITICAL GUIDELINE VIOLATION (see #741).

## Live Verification Requirements

**🚫 CRITICAL: Every git-workflow task MUST verify actual git/GitHub state via tool calls before acting on claims. Do NOT trust cached values, assumed branch names, or claimed merge status without direct evidence.**

### Verification Matrix

| Verification Point | Tool Call | Expected Evidence | Applies To |
| -- | -- | -- | -- |
| **Branch state** | `git branch --show-current` | Current branch name matches expected | pre-work, implementation, rebase-pending |
| **Remote dev branch** | `git ls-remote origin dev` | Non-empty output (when remote exists) | pre-work |
| **Working tree cleanliness** | `git status --porcelain` | Empty output (no uncommitted changes) | review-prep, pr-creation |
| **Worktree location** | `git rev-parse --show-toplevel` | Returns worktree path (not main repo) | pre-work, implementation |
| **Commit/push state** | `git log dev..HEAD --oneline` | At least one commit ahead of dev | review-prep, pr-creation |
| **Tracking branch** | `git branch -vv` | `[origin/<branch>]` tracking exists | review-prep |
| **Unpushed commits** | `git diff @{u} HEAD` | Empty diff (all commits pushed) | review-prep |
| **PR merge status** | `github_pull_request_read(method=get)` | `merged_at` is not None | cleanup |
| **Sub-issue closure** | `github_issue_read(method=get_sub_issues)` | All sub-issues state=closed | cleanup |
| **File existence** | `git status --porcelain` | No uncommitted files (all committed) | pr-creation, implementation |
| **Staged state** | `git diff --staged` | Expected changes are staged | commit-prep, pr-creation |
| **Unstaged changes** | `git diff` | Empty (no unstaged changes) | pr-creation |
| **Worktree environment** | `echo $WORKTREE_PATH` | Non-empty path matching worktree dir | pre-work, implementation |
| **Stash state** | `git stash list` | Expected number of stashes (usually 0) | cleanup |

### Adversarial Verification Principles

1. **No cached trust:** Re-verify git state before every state-modifying operation (commit, push, squash, rebase)
2. **Evidence required:** Each verification point MUST produce a tool-call artifact — assertions without evidence are VERIFICATION-GAP findings
3. **Contradiction detection:** If actual state contradicts expected state, classify as a finding before proceeding

### Finding Classification

| Finding | Problem Class | Classification | Action |
| -- | -- | -- | -- |
| Branch name doesn't match expected | STRUCTURE-VIOLATION | auto-fix | Report actual branch, verify worktree context |
| Working tree dirty when should be clean | VERIFICATION-GAP | conditional | Commit or stash before proceeding |
| `merged_at` is None (no merge) | CONFLICTING | flag-for-review | HALT — do not close issues |
| Tracking branch missing | MISSING-ELEMENT | auto-fix | Push with `-u` to establish tracking |
| Unpushed commits detected | VERIFICATION-GAP | conditional | Push before generating compare URL |
| worktree.path empty/not set | STRUCTURE-VIOLATION | auto-fix | HALT — fatal error, cannot proceed safely |
| Staged changes differ from expected | CONFLICTING | flag-for-review | Verify staging matches intent before commit |
| Sub-issue closed without merged PR | VERIFICATION-GAP | flag-for-review | Investigate closure reason, may need reopen |

## Submodule Provenance

### Three-Tier Model

When a submodule is pushed or promoted from the parent repo, provenance tracking creates a traceable record in the submodule repository. The tier used depends on API availability:

| Tier | Method | When Available | Provenance Record |
| -- | -- | -- | -- |
| 1 | Issue + PR in submodule repo | Full API access | Full issue + PR with `Fixes #N` and cross-links |
| 2 | Issue only in submodule repo | API available, PR creation fails | Issue documenting the change |
| 3 | Commit message provenance | No API access | Structured commit message with parent context |

### When Each Tier Applies

| Condition | Tier |
| -- | -- |
| API responds successfully, full access | Tier 1: Create issue + PR |
| API responds but PR endpoint fails (403, 405) | Tier 2: Create issue only |
| API returns 403/404/auth error, or platform is `unknown` | Tier 3: Commit message only |

### Integration Points

| Integration | When Provenance Runs |
| -- | -- |
| `review-prep` (Step 0, Submodule Push Automation) | After each submodule is pushed to dev — provenance tracks the dev-push |
| `release-promotion` (Step 2h) | After each submodule is promoted dev → main — provenance tracks the promotion |

### Fire-and-Forget Semantics

Provenance operations are **fire-and-forget** — they never block git operations:

- All fallbacks are **silent** — no HALT, no developer intervention required
- If Tier 1 fails, automatically downgrade to Tier 2
- If Tier 2 fails, automatically downgrade to Tier 3
- The parent repo push/promotion proceeds **regardless** of provenance outcome
- Cross-reference comments on the parent issue are non-blocking — failures are logged, not raised

### Platform Detection

Before provenance tracking, each submodule's host platform is detected from its remote URL:

- `github.com` → GitHub API
- Known GitBucket host patterns → GitBucket API
- Unknown → Tier 3 (no API available)

Detection results are cached for the session to avoid redundant API calls.

## Pair Mode

### Mode Detection

Pair mode is detected from the branch name prefix:

| Branch Pattern | Mode | Working Directory |
|---|---|---|
| `pair-feature/123-xyz` | Dev-pair | Main project dir |
| `pair-spec/456-abc` | Dev-pair | Main project dir |
| `feature/789-xyz` | Autonomous | `.worktrees/` |
| `spec/789-abc` | Autonomous | `.worktrees/` |
| `dev` or `main` | None | Prompt to create/switch |

The `pair-` prefix IS the mode signal. No state files needed — branch name carries everything.

### Pair Mode vs Autonomous Mode

| Aspect | Autonomous Mode | Pair Mode |
|--------|----------------|-----------|
| Branch prefix | `feature/`, `spec/` | `pair-` |
| Working directory | `.worktrees/` | Main project dir |
| Branch switching | Worktree per branch | WIP commit + checkout |
| Worktree safety | Tier 1 mandate | Tier 2 — developer present |
| Commit trailers | Standard co-author | `[pair-mode]` tag |
| PR workflow | Same squash workflow | Same squash workflow |

### Pair Mode Branch Discipline

1. **Always use `pair-` prefix** — no exceptions
2. **Never operate in `.worktrees/`** when pair mode is active
3. **WIP commits before branch switches** — never leave uncommitted changes on a branch switch
4. **Commit trailers always include `[pair-mode]`** — distinguishes from autonomous commits
5. **PR body uses `Implements #N`** — never `Fixes` or `Closes` (avoids premature closure)

### Pair Mode Session Start

The `session_context.py` plugin detects pair mode at session start and injects context:
- Identity section (always): github.owner, github.repo, github.platform, credential status
- Pair mode resume context: branch name, related issue, diff summary
- Trigger warnings: on_main_branch, protected_branch_with_changes, uncommitted_work

### Pair Mode Task Sequence

```
Session start → pair-mode-resume detects pair-* branch
    ↓
pair-pre-work: WIP-commit switch (no worktree)
    ↓
(pair-commits as needed during work)
    ↓
pair-pr-creation: Squash → Push → Create PR
    ↓
(Developer merges PR)
    ↓
pair-cleanup: Delete branch, clean stashes
```

<!-- Issue #5: Submodule Detection & Routing — Success Criteria: Update git-workflow SKILL.md with Submodule Worktree Mechanics section -->

## Submodule Worktree Mechanics

### Detection

When `git rev-parse --show-toplevel` returns a path that is a descendant of a parent repo's `.git/modules/` path, OR when `.gitmodules` contains a path matching `worktree.path` prefix, the agent is in a **submodule worktree**.

### Path Rules

| Rule | Submodule Worktree | Parent Repo |
| -- | -- | -- |
| `worktree.path` prefix | REQUIRED for ALL file ops | Same |
| `git rev-parse --show-toplevel` | Returns submodule root | Returns parent root |
| Relative `read/edit/write` | Resolves to parent repo root — FORBIDDEN | Allowed only when not in worktree |
| `.gitmodules` edits | Only in parent repo context | Allowed |

### Provenance & Submodule PRs

- Submodule feature branches target `dev` (same as non-submodule)
- Release promotion: lock submodule SHA, promote submodule `dev → main`, update parent repo reference
- Provenance tracking uses the three-tier model (see `## Submodule Provenance`)
- Cross-repo provenance: parent repo PR body references submodule PR/issue numbers

### Safety Gates

- [ ] Verify `worktree.path` matches submodule root before ANY file modification
- [ ] Verify `.gitmodules` is NOT accidentally overwritten with submodule content
- [ ] Verify GitHub API calls target the correct `<github.owner>/<github.repo>` (submodule, not parent)

## Cross-References

- Related skills: `approval-gate` (authorization), `pr-creation-workflow` (PR timing), `changelog-generator` (changelog generation), `conflict-resolution` (conflict classification during rebase/merge)
- Related guidelines: `000-critical-rules.md`, `115-branch-naming.md`
- Authorization classification: See `010-approval-gate.md` §Action Authorization Classification
- Related skill tasks: `git-workflow --task pre-work` (branch creation), `git-workflow --task cleanup` (post-merge), `git-workflow --task pr-creation` (PR workflow), `git-workflow --task provenance` (submodule provenance tracking)

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-26T00:00:00Z"
rules:
  - id: git-workflow-provenance-001
    title: "Submodule provenance tracking after push or promotion"
    conditions:
      all:
        - "submodule_pushed == true OR submodule_promoted == true"
    actions:
      - INVOKE(git-workflow --task provenance)
    conflicts_with: []
    requires: []
    triggers: [release-promotion, review-prep]
    source: "git-workflow/SKILL.md Tasks table"
  - id: git-workflow-url-001
    title: "Post-creation URLs must be extracted from API response (NEVER constructed)"
    conditions:
      all:
        - "resource_created_by_api == true"
        - "url_source == template_construction"
    actions:
      - HALT
      - EXTRACT_FROM_API_RESPONSE
    conflicts_with: []
    requires: []
    triggers: [pr-creation, review-prep]
    source: "git-workflow/SKILL.md §Fabricating URLs"
  - id: git-workflow-url-002
    title: "Pre-creation URLs must be constructed from verified session-init values with character-match"
    conditions:
      all:
        - "resource_not_yet_created == true"
        - "url_construction_needed == true"
    actions:
      - CONSTRUCT_FROM_SESSION_INIT
      - CHARACTER_MATCH_VERIFY
    conflicts_with: []
    requires: []
    triggers: [review-prep]
    source: "git-workflow/SKILL.md §Fabricating URLs"
  - id: git-workflow-chat-001
    title: "Chat output format requires all 4 elements in order"
    conditions:
      all:
        - "halt_point_reached == true"
    actions:
      - VERIFY(summary_exists && outcome_exists && url_if_applicable && byline_last)
    conflicts_with: []
    requires: []
    triggers: [review-prep, pr-creation]
    source: "git-workflow/SKILL.md §Chat Output Format"
tasks:
  - id: pre-work
    skill: git-workflow
    preconditions: ["authorization_verified == true"]
    postconditions: ["worktree_path_is_set == true && feature_branch_exists == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Worktree Bypass"
    source: "git-workflow/SKILL.md"
  - id: implementation
    skill: git-workflow
    preconditions: ["worktree_path_is_set == true"]
    postconditions: ["implementation_changes_committed == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Uncommitted Changes After Implementation"
    source: "git-workflow/SKILL.md"
  - id: review-prep
    skill: git-workflow
    preconditions: ["implementation_complete == true", "verification_passed == true", "checklist_passed == true"]
    postconditions: ["branch_pushed == true", "compare_url_generated == true", "chat_output_format_correct == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping review-prep After Implementation"
    source: "git-workflow/SKILL.md"
    evidence_artifacts:
      - gate: url_sourcing_rule_1
        verification: "pr_url == html_url_from_github_create_pull_request_response"
        expected: "exact API response match"
      - gate: url_sourcing_rule_2
        verification: "compare_url contains github.owner AND github.repo from session-init"
        expected: "character-for-character match"
      - gate: chat_output_format
        verification: "output contains summary, outcome, URL (if applicable), byline in order"
        expected: "all 4 elements present and correctly ordered"
  - id: pr-creation
    skill: git-workflow
    preconditions: ["compare_url_exists == true && halt_at >= pr_created"]
    postconditions: ["pr_url_extracted_from_api == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Fabricating URLs"
    source: "git-workflow/SKILL.md"
  - id: cleanup
    skill: git-workflow
    preconditions: ["pr_merged == true"]
    postconditions: ["branch_deleted == true && issues_closed == true && dev_synced == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping Post-Merge Cleanup"
    source: "git-workflow/SKILL.md"
  - id: release-promotion
    skill: git-workflow
    preconditions: ["release_authorized == true"]
    postconditions: ["release_pr_created == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Branch Protection"
    source: "git-workflow/SKILL.md"
  - id: check-pr
    skill: git-workflow
    preconditions: ["pr_url_exists == true"]
    postconditions: ["pr_status_checked == true"]
    mandatory: false
    bypass_violation: ""
    source: "git-workflow/SKILL.md"
  - id: provenance
    skill: git-workflow
    preconditions: ["commit_sha_provided == true"]
    postconditions: ["provenance_report_produced == true"]
    mandatory: false
    bypass_violation: ""
    source: "git-workflow/SKILL.md"
  - id: dependency-sync
    skill: git-workflow
    preconditions: ["gitmodules_exists == true", "working_tree_clean == true", "submodules_have_updates == true"]
    postconditions: ["tracking_issue_created == true", "branch_pushed == true", "compare_url_generated == true"]
    mandatory: false
    bypass_violation: ""
    source: "git-workflow/SKILL.md"
  - id: completion
    skill: git-workflow
    preconditions: ["any_state"]
    postconditions: ["completion_tasks_executed == true"]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping Completion Guarantee on Workflow Halt"
    source: "git-workflow/SKILL.md"
decomposition:
  - type: skill-task
    skill: approval-gate
    task: verify-authorization
    mandatory: true
    bypass_violation: "CRITICAL: Skill Bypass"
  - type: skill-task
    skill: verification-before-completion
    task: verify
    mandatory: true
    bypass_violation: "CRITICAL: Skipping Verification"
  - type: skill-task
    skill: finishing-a-development-branch
    task: checklist
    mandatory: true
    bypass_violation: "CRITICAL: Uncommitted/Unpushed Changes After Implementation"
  - type: command
    skill: git
    task: push
    mandatory: true
    bypass_violation: "CRITICAL: Fabricating URLs"
  - type: command
    skill: git
    task: rev-parse --show-toplevel
    mandatory: true
    bypass_violation: "CRITICAL: Worktree Bypass"
  - type: command
    skill: git
    task: branch --show-current
    mandatory: true
    bypass_violation: "CRITICAL: Branch First"
  - type: sub-agent-dispatch
    isolation: clean-room
    must_receive: [task description, required git state, branch name, worktree.path, compare URL data]
    must_not_receive: [implementation context, agent memory from prior phases, cached verification results]
    mandatory: true
    bypass_violation: "CRITICAL: Skipping Clean-Room Dispatch for Sub-Agents"
state_machines:
  - id: branch-lifecycle
    states: [pre_work, implementing, review_ready, pr_created, merged, cleaned_up]
    start_state: pre_work
    decomposition_guard:
      field: "decomposition.feature_branch_exists"
      message: "CRITICAL: Cannot proceed without feature branch"
    transitions:
      - from: pre_work
        to: implementing
        guard: "feature_branch_exists == true && worktree_path_is_set == true"
        action: BEGIN_IMPLEMENTATION
      - from: implementing
        to: review_ready
        guard: "verification_passed == true && checklist_passed == true"
        action: PUSH_AND_GENERATE_URL
      - from: review_ready
        to: pr_created
        guard: "halt_at >= pr_created && explicit_pr_instruction == true"
        action: CREATE_PR
      - from: review_ready
        to: merged
        guard: "pr_merged_by_human == true"
        action: INVOKE(cleanup)
      - from: pr_created
        to: merged
        guard: "pr_merged_by_human == true"
        action: INVOKE(cleanup)
      - from: merged
        to: cleaned_up
        guard: "branch_deleted == true && issues_closed == true"
        action: COMPLETE
gates:
  - id: not-on-protected-branch
    condition: "current_branch != 'main' && current_branch != 'dev'"
    on_fail: "HALT"
    critical_violation: true
  - id: feature-branch-exists
    condition: "feature_branch_exists == true"
    on_fail: "INVOKE(git-workflow/pre-work)"
    critical_violation: true
  - id: push-before-url
    condition: "branch_pushed == true"
    on_fail: "HALT and push first"
    critical_violation: true
  - id: merge-confirmed-before-cleanup
    condition: "pr_merged == true"
    on_fail: "HALT"
    critical_violation: true
evidence_artifacts:
  - name: branch_state
    type: tool_call
    verification: "git branch --show-current confirms expected branch"
  - name: push_confirmation
    type: tool_call
    verification: "git push output confirms branch pushed"
  - name: compare_url
    type: constructed_url
    verification: "URL format matches dev...branch pattern"
  - name: pr_merge_status
    type: api_call
    verification: "github_pull_request_read(method=get) merged_at != null"
  - name: worktree_location
    type: tool_call
    verification: "git rev-parse --show-toplevel matches worktree.path"
```
