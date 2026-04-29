# Pair-Mode Resume Task

Detect and report on `pair-*` branch at session start, enabling the developer to resume work without context loss.

## Purpose

Pair-mode resume runs automatically when the agent detects the current branch starts with `pair-`. It gathers the state of the pair-mode session — related issue, uncommitted changes, unpushed commits, and stash state — and reports a complete summary to the developer so they can immediately resume where they left off.

## Detection

```bash
BRANCH=$(git branch --show-current)
```

If `$BRANCH` starts with `pair-`, pair mode is active and resume proceeds.

## Procedure

### Step 1: Identify Issue Number from Branch Name

Extract numeric issue reference from branch name using pattern matching:

| Branch Pattern | Issue Number |
|---------------|-------------|
| `pair-feature/123-xyz` | #123 |
| `pair-spec/456-abc` | #456 |
| `pair-bugfix/789` | #789 |
| `pair-experiment` | null (no issue) |

Parse the first numeric group after the `/` delimiter as the issue number.

### Step 2: Show Diff Summary

Report all changes made since diverging from dev:

```bash
git diff --stat origin/dev..HEAD
```

If origin/dev is not available locally, fetch first:

```bash
git fetch origin dev
git diff --stat origin/dev..HEAD
```

### Step 3: Check for Uncommitted Changes

```bash
git status --porcelain
```

Count and categorize:
- Modified files (M prefix)
- New/untracked files (?? prefix)
- Deleted files (D prefix)

### Step 4: Check for Unpushed Commits

```bash
git rev-list --count origin/<pair-branch>..HEAD 2>/dev/null
```

If the remote branch does not exist yet (new pair branch), all commits are unpushed:

```bash
git rev-list --count origin/dev..HEAD
```

### Step 5: Check Stash State

```bash
git stash list | grep "pair-"
```

Pair-related stashes indicate interrupted work that may need resuming.

### Step 6: Report to Developer

```
Pair mode resumed on `<branch>`
- Related issue: #123
- Changes: X files changed, Y insertions(+), Z deletions(-)
- Uncommitted: N file(s)
- Unpushed: M commit(s)
- Stashes: K pair-related stash(es)
```

### Step 7: Suggest Resume Actions

Based on the state detected:

| State | Suggested Action |
|-------|-----------------|
| Uncommitted changes | "You have uncommitted work. Commit with `--task pair-commit` or stash." |
| Unpushed commits | "You have unpushed commits. Push when ready with `--task pair-pr-creation`." |
| No pending work | "Branch is clean and up to date. Ready for new work." |
| Stashes exist | "You have pair-related stashes. Check with `git stash list`." |

## No Pair Branch Active

If current branch does NOT start with `pair-`:
- No pair-mode resume needed
- Skip this task entirely
- Return SKIP status

## Key Principles

### Zero Context Loss

The resume task is designed to eliminate context loss between pair-mode sessions. When a developer returns to a pair branch, all relevant state must be gathered and reported without requiring the developer to reconstruct what happened previously. The summary provides enough context to resume work immediately.

### Non-Destructive by Default

Resume is read-only. It reports state but does not modify anything — no stashing, committing, pushing, or branch switching. The developer decides what actions to take based on the reported state. The "Suggest Resume Actions" section provides recommendations, but these are advisory only.

### Pair Stash Preservation

Stashes created during pair-mode work must be preserved until explicitly addressed by the developer. The resume task reports stashes but never pops or drops them. Pair stashes may contain partial work that the developer intended to resume.

## Sub-Agent Dispatch Context

When dispatched as a sub-agent:

- Receive: (none — uses git state directly)
- Return: `status`, `pair_branch`, `issue_number`, `changes_summary`, `uncommitted_count`, `unpushed_count`, `stash_count`
- Must NOT: Modify any files, switch branches, pop stashes, or push commits
- Must NOT: Assume the developer wants to continue — only report state

## Integration with Pair-Mode Workflow

The resume task connects to the broader pair-mode workflow:

| After Resume | Next Skill/Task |
|-------------|-----------------|
| Developer wants to commit uncommitted work | `pair-commit` |
| Developer wants to push and create PR | `pair-pr-creation` |
| Developer wants to clean up completed work | `pair-cleanup` |
| Developer wants to start fresh on same branch | `pair-pre-work` |

## Result Contract

```yaml
status: DONE | SKIP
task: pair-mode-resume
pair_branch: <str|null>
issue_number: <N|null>
changes_summary: <str>
uncommitted_count: <int>
unpushed_count: <int>
stash_count: <int>
```

## References

- `git-workflow` skill — pair-mode workflow overview
- `pair-pre-work` — initial pair-mode setup
- `pair-commit` — committing pair-mode changes
- `pair-pr-creation` — creating PRs from pair branches