# Sub-Task: pre-work/sync-dev

## Purpose

Branch sync IS the foundation of clean merges. Stale branches produce merge conflicts — every merge conflict starts with a stale branch.

## Entry Criteria

- Authorization verified (verify-auth sub-task completed)
- Repository has remote configured (or is local-only)

## Procedure

### Step 1: Pre-flight — Verify Remote Dev Branch

Before syncing, verify the remote has a `dev` branch. If it doesn't, create it from the default branch. If no remote exists, skip gracefully.

```bash
if ! git remote 2>/dev/null | grep -q '^origin$'; then
    echo "No remote 'origin' found. Skipping remote dev branch check (local-only repo)."
else
    git fetch origin

    if ! git ls-remote origin dev 2>/dev/null | grep -q 'refs/heads/dev'; then
        echo "Remote branch 'dev' not found on origin. Creating from default branch..."

        DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')

        if [ -z "$DEFAULT_BRANCH" ]; then
            echo "FATAL: Cannot determine default branch on origin. HALT."
            exit 1
        fi

        git push origin "refs/heads/${DEFAULT_BRANCH}:refs/heads/dev"

        if ! git ls-remote origin dev 2>/dev/null | grep -q 'refs/heads/dev'; then
            echo "FATAL: Failed to create dev branch on origin. HALT."
            exit 1
        fi

        echo "Remote branch 'dev' created from '${DEFAULT_BRANCH}'."
    else
        echo "Remote branch 'dev' exists on origin."
    fi
fi
```

Key behaviors:
- **No remote at all:** Skip this check entirely — local-only repos require no remote branch setup
- **Remote exists but `dev` missing:** Create `dev` on origin from the default branch
- **Verification failure after push:** HALT and report
- **DO NOT add any remotes** — this check only works with pre-existing remotes

### Step 2: Sync Dev Branch

The main working tree must be on `dev` and up-to-date:

```bash
git fetch origin

if git rev-parse --verify origin/dev >/dev/null 2>&1; then
    git checkout dev
    git pull origin dev
else
    git checkout -b dev origin/main
    if [ $? -ne 0 ]; then
        echo "FATAL: Failed to create dev branch from origin/main. HALT."
        exit 1
    fi
    git push -u origin dev
fi
```

If dev branch creation fails entirely (neither origin/dev nor origin/main exists), HALT immediately and report the fatal error. Proceeding on `main` is a CRITICAL GUIDELINE VIOLATION.

### Step 3: Proactive Repo State Verification

Before creating any feature branch:

1. **Submodule initialization check:** Check if `.gitmodules` exists. If it does, note that submodule sync will be handled by the `submodule-tag-prework` sub-agent task() in create-branch Step 3.5 — do NOT run submodule commands inline.
2. **Submodule currency check:** Deferred to `submodule-tag-prework` sub-agent task() (create-branch Step 3.5).
3. **Fresh clone handling:** After `git clone`, the dev parking protocol must be task()ed to `submodule-tag-prework` — do NOT run `git submodule init` or `git submodule foreach` inline.

### Step 4: Yield Sync State

```yaml
status: success
dev_synced: true
dev_base_hash: <7-char-sha>
remote_dev_exists: true|false
has_submodules: true|false
submodule_paths: <list or empty>
```

## Exit Criteria

- Remote dev branch verified (or local-only repo confirmed)
- Local dev branch synced with `origin/dev`
- Dev base hash recorded for later reference
- Submodule presence noted (not synced — deferred to create-branch)
- Repo state ready for branch creation

## Task Context Rules

- **must_receive**: `worktree.path` (if in worktree mode; null otherwise)
- **must_not_receive**: Expected SHA values, expected commit counts, orchestrator reasoning, implementation context

Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)