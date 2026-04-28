# Pair-Mode Commit Task

Commit changes with `[pair-mode]` co-author trailers and optional issue association. This task implements the pair-mode commit convention that distinguishes pair-developed changes from autonomous agent changes.

## Purpose

In pair mode, the developer and agent work together in the same directory. Commits reflect this collaboration with `[pair-mode]` tags on co-author trailers, making it easy to identify pair-developed changes in git history.

## Commit Message Format

Pair mode commits include `[pair-mode]` tag in co-author trailers:

```
<conventional subject>

<optional body>

Co-authored-by: <dev.name> <<dev.email>> [pair-mode]
Co-authored-by: AI: <AGENT_NAME> (<MODEL_ID>) [pair-mode]
```

The `[pair-mode]` tag is the key differentiator — it clearly marks commits made during collaborative development sessions.

## Issue Association

When the pair branch contains an issue number (e.g., `pair-feature/123-xyz`):

1. **Extract issue number** from branch name using regex pattern
2. **Include issue reference** in commit footer: `Refs #123`
3. **Use `Implements #123`** (not `Fixes #123`) to avoid premature closure

Why `Implements` instead of `Fixes`/`Closes`:
- `Fixes` and `Closes` trigger GitHub auto-close when merged to default branch
- Auto-close bypasses verification gates (content verification, SC verification)
- `Implements` creates a reference link without auto-closing the issue
- The issue is closed manually by `cleanup` task after merge verification

When branch has no issue number or the branch name is ambiguous:
- Ask developer: "Which issue is this commit for?"
- If developer doesn't specify, omit issue reference entirely

## Procedure

### Step 1: Protected Branch Check

Before staging any changes, verify NOT on `dev` or `main`:

```bash
BRANCH=$(git branch --show-current)
if [ "$BRANCH" = "dev" ] || [ "$BRANCH" = "main" ]; then
    echo "BLOCKED: Cannot commit on $BRANCH"
    # Prompt developer to create pair branch first
fi
```

### Step 2: Stage Changes

```bash
git add -A
```

Review what will be committed:

```bash
git status --short
git diff --cached --stat
```

### Step 3: Create Commit with Pair-Mode Trailers

For commits with issue association:

```bash
git commit -m "<subject>

Implements #<issue>

Co-authored-by: <dev.name> <<dev.email>> [pair-mode]
Co-authored-by: AI: <AGENT_NAME> (<MODEL_ID>) [pair-mode]"
```

For commits without issue reference:

```bash
git commit -m "<subject>

<body if needed>

Co-authored-by: <dev.name> <<dev.email>> [pair-mode]
Co-authored-by: AI: <AGENT_NAME> (<MODEL_ID>) [pair-mode]"
```

### Step 4: Verify Commit

```bash
git log -1 --format="%B"
```

Confirm:
- Subject line follows conventional format
- Issue reference present (if applicable)
- Both co-author trailers present with `[pair-mode]` tags
- No trailing whitespace or formatting issues

### Step 5: Report Result

Report commit hash and details to developer:

```
Committed: <short-hash>
Branch: <pair-branch>
Files: <count> changed
Issue: #<N> (if applicable)
Trailers: [pair-mode]
```

## WIP Commits

During pair-mode sessions, developers may create WIP (Work In Progress) commits:

```bash
git commit -m "WIP: <branch-name> [pair-mode]

Co-authored-by: <dev.name> <<dev.email>> [pair-mode]
Co-authored-by: AI: <AGENT_NAME> (<MODEL_ID>) [pair-mode]"
```

WIP commits are squashed during `pair-pr-creation` to produce a single clean commit.

## Error Handling

| Error | Resolution |
|-------|-----------|
| Nothing to commit | Report "No changes to commit" |
| On protected branch | HALT — developer must create pair branch first |
| Commit fails (hooks) | Report hook output, let developer resolve |
| Trailers missing | Verify `git log -1` shows trailers; amend if missing |

## Result Contract

```yaml
status: DONE | BLOCKED
task: pair-commit
commit_hash: <sha>
issue_referenced: <N|null>
pair_mode: true
```