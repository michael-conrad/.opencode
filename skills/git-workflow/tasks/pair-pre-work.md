# Pair-Mode Pre-Work Task

Detect pair mode from branch prefix and set up WIP-commit switching instead of worktree creation. This task is the starting point for all pair-mode workflows.

## Purpose

When the current branch starts with `pair-`, the agent operates in dev-pair mode: working directly in the main project directory alongside the developer. Instead of creating worktrees for isolation, pair mode uses WIP commits and branch switching to manage context.

## Detection

Check current branch name:
```bash
BRANCH=$(git branch --show-current)
```

If `$BRANCH` starts with `pair-`, pair mode is active. Otherwise, autonomous mode applies.

## Procedure

### Step 1: Detect Pair Mode

```bash
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" == pair-* ]]; then
    PAIR_MODE=true
else
    PAIR_MODE=false
fi
```

### Step 2: WIP-Commit Switching (instead of worktree creation)

When pair mode is active (branch name starts with `pair-`):

1. **Check for uncommitted changes:**
   ```bash
   git status --porcelain
   ```

2. **If changes exist, create WIP commit:**
   ```bash
   git add -A
   git commit -m "WIP: $(git branch --show-current) [pair-mode]

   Co-authored-by: <dev.name> <<dev.email>>
   Co-authored-by: AI: <AgentName> (<ModelId>) [pair-mode]"
   ```

   The WIP commit preserves uncommitted work when switching branches. It will be squashed during pair-pr-creation.

3. **If no changes but on protected branch (`dev`/`main`):**
   - Prompt developer: "You're on `$BRANCH`. Which issue should we work on?"
   - Create pair branch: `git checkout -b pair-feature/<issue>-<desc>`
   - No worktree needed — working directly in main directory

4. **If switching to existing pair branch:**
   ```bash
   git checkout <pair-branch>
   ```

   If the pair branch has WIP commits from a previous session, they are preserved.

### Step 3: Verify Git State

After WIP commit or branch switch, verify clean state:

```bash
git status --porcelain
git branch --show-current
git log -1 --oneline
```

### Step 4: Configure Working Mode

Based on detected mode:

| Check | Setting |
|-------|---------|
| `pair-*` branch | `worktree.path` NOT set (main directory) |
| `feature/*` branch | `worktree.path` may be set (autonomous mode) |
| Uncommitted changes | WIP commit before any branch switch |
| Remote tracking | `git branch -vv` to check push status |

### Step 5: Report Mode Status

Report to developer:

```
Pair mode: ACTIVE
Branch: <pair-branch>
Issue: #<N> (if detected from branch name)
Working directory: <main-project-dir>
Uncommitted: <count> file(s) → WIP committed
```

## Pair Mode vs Autonomous Mode

| Aspect | Autonomous Mode | Pair Mode |
|--------|----------------|-----------|
| Branch prefix | `feature/`, `spec/` | `pair-` |
| Working directory | `.worktrees/` | Main project dir |
| Branch switching | Worktree per branch | WIP commit + checkout |
| Worktree safety | Tier 1 mandate (when WORKTREE_REQUIRED) | Tier 2 — developer present |
| Commit trailers | Standard co-author | `[pair-mode]` tag |
| Isolation | Worktree provides full isolation | Developer provides oversight |

## Safety Invariants

Even in pair mode, certain invariants are maintained:

1. **Never commit to `dev` or `main`** — branch protection still applies
2. **Never force-push without authorization** — same as autonomous mode
3. **Never merge PRs** — agents cannot merge, even in pair mode
4. **Always include co-author trailers** — `[pair-mode]` tags on all commits

## Result Contract

```yaml
status: DONE | BLOCKED
task: pair-pre-work
pair_mode: bool
branch_name: <str>
wip_commit_created: bool
working_directory: <path>
issue_number: <N|null>
```