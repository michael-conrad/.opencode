# Task: pr-creation/squash-push

## Purpose

Squash implementation commits or verify existing commit structure for all branches, rebase on current target, and push to remote.

## Entry Criteria

- Enforcement gates passed (pr-creation/enforcement-gate)
- Implementation is complete and committed

## Exit Criteria

- Verified commit structure on feature branch (one commit per implementation item)
- Branch rebased on current target
- Branch pushed to remote with force-with-lease
- Working tree clean

## Procedure

### Step 1: Pre-Response Gate — Skill Deck Evaluation (MANDATORY)

Before proceeding to changelog generation, evaluate ALL available skills against the current context per `.opencode/AGENTS.md` §Universal Skill Dispatch Gate.

1. Read the `<available_skills>` list from the system prompt
2. Evaluate each skill's description and trigger phrases against the current context (release PR creation)
3. If one or more skills match: call `skill({name: "..."})` before proceeding
4. If no skill applies directly: provide a one-sentence justification in chat

**Release PR context:** When `{is_release: true}` or the context is a release PR, the agent MUST dispatch at minimum `changelog-generator` and `git-workflow` before proceeding. "No skill applies directly" is NOT a valid justification for release PR contexts.

### Step 2: Changelog Generation (MANDATORY)

Check for `[skip changelog]` in last commit message or PR title. If present, skip.

If not present, execute: `` `skill({name: "changelog-generator"})` ``

Then stage: `git add CHANGELOG.md`

**Enforcement gate:** Verify `git status --porcelain CHANGELOG.md` shows `M` or `A` before proceeding. If changelog not staged and no skip directive — HALT.

### Step 3: Squash to One Commit Per Item (MANDATORY)

All branches use the same squash strategy: one commit per implementation item.

```bash
git reset --soft origin/<target>
```

Then commit each item separately with the standardized format:

```bash
git commit -m "#<issue> <title> — <summary>" \
    --trailer "Co-authored-by: <AgentName> (<ModelId>) <noreply@example.com>" \
    --trailer "Co-authored-by: <dev.name> <dev.email>"
```

Generate the commit message from the combined diff of each implementation item. The format is `#<issue> <title> — <summary>` where:
- `<issue>` is the issue number
- `<title>` is the issue title
- `<summary>` is a brief description of what changed

Example: `#123 Add user login — implemented email validation and password hashing`

### Step 3.5: Rebase on Current Target (MANDATORY)

```bash
git fetch origin
git rebase origin/<target>
```

**If conflicts occur:** HALT and report conflicts to the developer. List conflicting files.

**This step is MANDATORY even if review-prep just ran a rebase.** Target may have been updated since.

### Step 4: Push to Remote

```bash
git push --force-with-lease origin <branch>
```

## Branch Mode (Conditional — Based on WORKTREE_REQUIRED)

**Direct-branch mode (default — when `WORKTREE_REQUIRED` is NOT set):**

- Operate normally from the main repo directory
- Relative paths work directly
- No worktree path prefixing needed

**Worktree mode (opt-in — when `WORKTREE_REQUIRED` is set):**

If `worktree.path` is not set or empty: **FATAL ERROR → FLAG DEV → HALT.** Do not proceed without a valid worktree path.

1. All `bash` tool calls MUST use `workdir="{{worktree.path}}"`
2. All `read`/`edit`/`write`/`glob`/`grep` tool calls MUST prefix with `{{worktree.path}}/`
3. Before any push/squash/rebase: verify `git branch --show-current` matches expected branch
4. `git rev-parse --show-toplevel` MUST return the worktree path
5. NEVER operate in the main working directory during worktree mode

## Live Verification (MANDATORY)

After squash and before push:

| Check | Command | Expected |
| -- | -- | -- |
| Working tree clean | `git status --porcelain` | Empty |
| Staged changes correct | `git diff --staged` | Only intended changes |
| No unstaged changes | `git diff` | Empty |
| Commits ahead of target | `git log origin/<target>..HEAD --oneline` | Expected commit(s) |
| Branch tracking | `git branch -vv` | `[origin/<branch>]` |
| Worktree path correct | `git rev-parse --show-toplevel` | Worktree path |

## Recovery from Accidental Protected Branch Commit

```bash
git branch feature/recovery HEAD
git checkout <target>
git reset --hard origin/<target>
git checkout feature/recovery
git push origin feature/recovery
```

## Context Required

- Related tasks: `pr-creation/enforcement-gate`, `pr-creation/create-pr`
- Related guidelines: `000-critical-rules.md` (co-author trailers)
