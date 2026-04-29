# Pair-Mode PR Creation Task

Squash and create PR targeting `dev` with `[pair-mode]` trailers. This task handles the final step of pair-mode workflow: consolidating commits and publishing the PR for review.

## Purpose

After pair-mode implementation is complete, create a single squashed commit with proper co-author trailers and submit a PR targeting `dev`. Pair-mode PRs use `Implements` (not `Fixes`/`Closes`) to avoid premature issue auto-closure, preserving verification gates.

## Entry Criteria

- Pair-mode implementation is complete
- Developer is present (pair mode)
- All changes are committed
- Feature branch starts with `pair-`

## Procedure

### Step 1: Verify Pre-Conditions

1. Confirm on pair branch: `git branch --show-current` starts with `pair-`
2. Verify not on protected branch (`dev`/`main`)
3. Check for uncommitted changes: `git status --porcelain`
4. If uncommitted changes exist: run `--task pair-commit` first

### Step 2: Squash Workflow

Pair mode uses the same squash workflow as autonomous mode:

1. **Soft-reset to dev:**
   ```bash
   git reset --soft origin/dev
   ```

2. **Create single commit with pair-mode trailers:**
   ```bash
   git commit -m "<conventional subject>

   <body>

   Implements #<issue>

   Co-authored-by: <dev.name> <<dev.email>> [pair-mode]
   Co-authored-by: AI: <AGENT_NAME> (<MODEL_ID>) [pair-mode]"
   ```

3. **Verify squash commit:**
   ```bash
   git log -1 --format="%B"
   ```

   Confirm co-author trailers are present and correctly formatted.

### Step 3: Rebase on Current Dev

```bash
git fetch origin
git rebase origin/dev
```

If conflicts occur, HALT and report to the developer. In pair mode, the developer is present and can help resolve.

### Step 4: Push

```bash
git push -u origin <pair-branch>
```

If the branch was previously pushed, use `--force-with-lease` to update after squash:

```bash
git push --force-with-lease origin <pair-branch>
```

### Step 5: Create PR via GitHub MCP

```yaml
method: create_pull_request
owner: <github.owner>
repo: <github.repo>
title: "<conventional subject>"
head: "<pair-branch>"
base: "dev"
body: |
  ## Summary
  <1-3 bullet points>

  ## Outcome
  <What changed for stakeholders>

  Implements #<issue>

  Co-authored-by: <dev.name> <<dev.email>> [pair-mode]
  Co-authored-by: AI: <AGENT_NAME> (<MODEL_ID>) [pair-mode]
```

Extract PR URL from API response `html_url` field (per `000-critical-rules.md` §Fabricating URLs).

### Step 6: Report PR URL

Post PR URL in chat. HALT — wait for human to merge.

## PR Body Keyword Discipline

- Use `Implements #N` for pair-mode PRs (never `Fixes` or `Closes`)
- `Implements` links the PR to the issue without auto-closing on merge
- Auto-closure bypasses verification gates — `Fixes`/`Closes` are prohibited
- When PR merges, `Implements` creates a reference link but does not close the issue
- Issue closure is handled by `cleanup` task after merge is confirmed

## Key Principles

### Squash Before PR

Pair-mode branches typically contain multiple commits from the collaborative development session. Before creating the PR, all commits must be squashed into a single commit. This ensures the PR presents a clean, reviewable history rather than a verbose development log. The squash-push workflow from `pr-creation/squash-push.md` applies.

### Co-Author Trailers Required

Pair-mode commits MUST include co-author trailers for both the human developer and the AI agent. This is a non-negotiable attribution requirement per `080-code-standards.md`. The `[pair-mode]` tag distinguishes these trailers from autonomous-mode co-authorship.

### Human Present for Conflict Resolution

In pair mode, the developer is present and can help resolve rebase conflicts. Unlike autonomous mode where conflicts must be handled via the `conflict-resolution` skill, pair-mode conflicts can be discussed and resolved collaboratively. If conflicts occur during rebase, HALT and report to the developer.

### Idempotent PR Creation

If a PR already exists for this branch and target, use the existing PR rather than creating a duplicate. Non-idempotent API mutations (creating duplicates) violate `000-critical-rules.md` §Non-Idempotent API Mutations. Check for existing PRs before creating a new one.

## Error Handling

| Error | Resolution |
|-------|-----------|
| Push rejected (non-fast-forward) | Force-with-lease after squash |
| PR creation fails (already exists) | Use existing PR, extract its URL |
| Rebase conflicts | HALT and report to developer |
| Empty diff (nothing to PR) | Report "No changes to create PR for" |

## Result Contract

```yaml
status: DONE | BLOCKED
task: pair-pr-creation
pr_number: <N|null>
pr_url: <url|null>
squash_performed: bool
pair_mode: true
```