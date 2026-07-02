# Task: cleanup/branch-cleanup

## Purpose

Delete merged branches, clean stale references, remove worktrees, sync dev, and verify clean repository state after PR merge.

## Entry Criteria

- PR merge verified (cleanup/verify-merge completed)
- Issue closure completed (cleanup/issue-closure completed)
- Closure-verification completed (cleanup/branch-cleanup Step 0)

## Exit Criteria

- Local merged branch deleted
- Remote merged branch deleted (if applicable)
- Stale remote references pruned
- Dev branch synced with remote (verified via hash comparison)
- Working tree clean

## Procedure

### Step 0: Closure-Verification (Adversarial Audit)

**⚠️ Before any branch operations, verify issue closure via adversarial audit.**

Invoke `adversarial-audit --task closure-verification --pr <N>` with `audit_phase: post_merge`. The dual-auditor dispatch must complete with a PASS consensus before any branch operations proceed.

#### Dispatch Procedure (Orchestrator)

The orchestrator dispatches the adversarial audit pipeline:

1. **`skill({name: "adversarial-audit"})`** — load the adversarial-audit skill
2. **Task `resolve-models`** — dispatch a clean-room sub-agent to resolve two cross-family auditor models via capability probe
3. **Task `closure-verification`** — dispatch two auditor sub-agents in parallel (each receives `spec_local_dir`, `audit_phase: post_merge`, PR number, and the standard dispatch fields only — no orchestrator reasoning, no pre-loaded findings)
4. **Task `cross-validate`** — dispatch a sub-agent with the pre-resolved `auditor_artifact_paths` to compute consensus
5. **Evaluate result contract** — if `status: BLOCKED` (issue not closed, SCs unverified), HALT and report findings. If `status: DONE` with PASS consensus, proceed to Step 1.

#### Result Contract Schema

```yaml
status: DONE | BLOCKED
artifact_path: "./tmp/{issue-N}/artifacts/pipeline-audit-closure-verification-{STATUS}-{timestamp}.yaml"
summary: "N criteria evaluated. X PASS, Y FAIL."
blocked_reason: "Spec issue #N not closed after PR merge"  # if BLOCKED
```

#### MUST_RECEIVE / MUST_NOT_RECEIVE

| Element | Value |
|---------|-------|
| `must_receive` | `github.owner`, `github.repo`, PR number, `audit_phase: post_merge`, `spec_local_dir`, `authorization_scope`, `halt_at`, `pr_strategy`, `pipeline_phase` |
| `must_not_receive` | Orchestrator reasoning, expected verdicts, pre-determined findings, cached git state, inline file paths to task files |

**🚫 CRITICAL: If closure-verification returns BLOCKED (issue not closed or SCs unverified), do NOT proceed to branch deletion. HALT and report findings for remediation.**

### Step 1: Switch to Dev and Sync (Fast-Forward Only)

```bash
git checkout dev
git pull origin dev --ff-only
```

**🚫 CRITICAL: The `--ff-only` flag is MANDATORY.** A plain `git pull origin dev` can silently succeed with a merge commit, hiding divergence issues.

**If `--ff-only` fails (diverged history):**
```bash
# HALT and report. Suggest manual resolution.
# Do NOT proceed with stale codebase
```

**Verify local dev matches the merge commit:**
```bash
git log --oneline -1 origin/dev
git log --oneline -1 dev
```

The two commit hashes MUST match. If they differ, re-pull and verify.

**Worktree context:** If running from a worktree, operate on the main working tree:
```bash
git -C /path/to/main/repo checkout dev && git -C /path/to/main/repo pull origin dev --ff-only
```

### Step 1.5: Dev Sync Verification Gate (MANDATORY — ZERO TOLERANCE)

1. Run: `git checkout dev && git pull origin dev --ff-only`
2. Capture local hash: `git log --oneline -1 dev`
3. Capture remote hash: `git log --oneline -1 origin/dev`
4. Compare hashes — they MUST match exactly
5. If hashes differ → re-pull and verify again (maximum 3 attempts)
6. If still different after 3 attempts → HALT and report

**Evidence artifact (MANDATORY):** Tool-call output showing matching hashes MUST be present before proceeding.

🚫 FORBIDDEN: Proceeding past this gate without matching hash evidence.

### Step 1.7: Park Parent Repo on dev

After submodule dev sync (Step 1/1.5), the parent repo must also be parked on `dev` with the latest changes. This step ensures both the submodule and the parent repo are on `dev` and up to date.

**Detect context:**

```bash
# If running from a worktree, use the main repo path for parent operations
PARENT_REPO_PATH="$(git -C "$(git rev-parse --show-toplevel)/.." rev-parse --show-toplevel 2>/dev/null || echo '')"

# If no parent repo (not a submodule), skip this step entirely
if [ -z "$PARENT_REPO_PATH" ]; then
    echo "Not a submodule — skipping parent repo dev parking."
    # Verify current repo is on dev (already done in Step 1.5)
    echo "Parent repo dev parking: N/A (not a submodule)"
else
    echo "Parent repo detected at: $PARENT_REPO_PATH"
fi
```

**Park parent repo on dev:**

```bash
if [ -n "$PARENT_REPO_PATH" ]; then
    # Switch parent repo to dev
    git -C "$PARENT_REPO_PATH" checkout dev
    git -C "$PARENT_REPO_PATH" pull origin dev --ff-only
fi
```

**Verify parent repo is on dev:**

```bash
if [ -n "$PARENT_REPO_PATH" ]; then
    PARENT_BRANCH=$(git -C "$PARENT_REPO_PATH" branch --show-current)
    if [ "$PARENT_BRANCH" != "dev" ]; then
        echo "ERROR: Parent repo is on '$PARENT_BRANCH', expected 'dev'"
        echo "HALT: Parent repo dev parking failed"
        # Do NOT proceed — dev parking is mandatory
    fi
fi
```

**Handle dirty submodule pointer(s) (CRITICAL):**

After submodule dev sync, the parent repo's submodule pointer(s) will be dirty — this is **expected and normal**. The parent repo tracks a specific submodule commit, and after `git pull origin dev` in each submodule, the submodule HEAD will differ from what the parent repo recorded on its own `dev` branch.

Detect dirty submodule(s) by checking `git status` for modified submodule entries — do NOT hardcode submodule names. Every submodule with a dirty pointer must be acknowledged but NEVER committed:

```bash
if [ -n "$PARENT_REPO_PATH" ]; then
    # Check for ANY dirty submodule pointer (detect dynamically, never hardcode)
    DIRTY_MODULES=$(git -C "$PARENT_REPO_PATH" status --short 2>/dev/null | grep '^\s*M' | awk '{print $2}' || echo '')

    if [ -n "$DIRTY_MODULES" ]; then
        echo "Dirty submodule pointer(s) detected:"
        echo "$DIRTY_MODULES"
        echo "No corrective action needed — dirty pointer(s) are normal post-sync state."
        # DO NOT: git add, git commit, git stash, or any corrective action on dirty submodule(s)
        # The dirty pointer(s) reflect that the submodule(s) are ahead of the parent repo's recorded commit.
        # This will be resolved naturally on the next pre-work cycle via tag-based hash permanence.
    fi
fi
```

**⚠️ CRITICAL: Dirty submodule pointer exemption:**
- 🚫 FORBIDDEN: Attempting to commit, stash, or resolve any dirty submodule pointer
- 🚫 FORBIDDEN: Treating a dirty submodule pointer as a cleanup failure or error condition
- 🚫 FORBIDDEN: Creating a feature branch + PR solely to update submodule pointer(s) (submodule-only PR, any number of submodules)
- 🚫 FORBIDDEN: Running `git add <submodule_path>`, `git commit`, or any git operation that commits submodule pointer(s) during cleanup
- ✅ REQUIRED: Acknowledge the dirty state as expected and continue
- ✅ REQUIRED: The parent repo `git status` after this step will show modified submodule entry/entries — this is correct and expected
- ✅ REQUIRED: Submodule pointer updates happen on feature branches during pre-work (Step 3.5), never on `dev` during cleanup

**Evidence artifact (MANDATORY):** Tool-call output showing `git -C "$PARENT_REPO_PATH" branch --show-current` returns `dev` MUST be present before proceeding. If no parent repo exists (not a submodule), evidence that the step was evaluated and skipped is sufficient.

### Step 1.9: Submodule Branch Cleanup Descent

After parent repo dev parking (Step 1.7), descend into each submodule to clean merged branches while preserving the dirty submodule pointer.

**Detect submodules via filesystem glob scan:**

```bash
REPO_PATHS=$(ls -d .git/ */.git/ */.git 2>/dev/null | sed 's|/\.git$||' | sed 's|/$||')
SUBMODULE_PATHS=""
for RP in $REPO_PATHS; do
    [ "$RP" = "." ] && continue
    SUBMODULE_PATHS="$SUBMODULE_PATHS $RP"
done
```

If no submodules exist (`SUBMODULE_PATHS` is empty), skip this step.

#### Orchestrator Dispatching: `submodule-dev-restore` Sub-Agent

For each submodule path, the orchestrator dispatches a clean-room `submodule-dev-restore` sub-agent. The sub-agent handles submodule entry, `git checkout dev`, and `git pull origin dev --ff-only`. The main task does NOT perform these operations inline.

**must_receive / must_not_receive:**

| Element | Value |
|---------|-------|
| `must_receive` | `submodule_path` (path to the submodule), `parent_repo_path` (absolute path to parent repo), `branch` = `dev` |
| `must_not_receive` | Orchestrator reasoning, expected outcomes, cached git state, pre-determined branch names, content verification results, tag data, or any information about branches to delete |
| `inline_fallback` | FORBIDDEN — re-task() clean-room on failure |

**Result contract schema:**

```yaml
status: DONE | BLOCKED
submodule_path: <path>
submodule_dev_head: <sha>
submodule_dev_synced: true | false
evidence:
  - <tool call: git branch --show-current returns dev>
  - <tool call: git log --oneline -1 dev matching origin/dev>
blocked_reason: <if BLOCKED, explanation of divergence>
```

**After the orchestrator receives DONE from the sub-agent for a submodule, proceed with cleanup operations:**

2. **Verify submodule is on dev (post-task() check):**

3. **Find merged branches:**
   ```bash
   git branch --merged dev | grep -v '^\*' | grep -v 'dev$'
   ```
   This lists all local branches whose commits are fully reachable from `dev`.

4. **Content verification gate (MANDATORY — see Step 3 for per-file details):**
   For each merged branch, verify content exists on `origin/main` before deletion:
   ```bash
   MERGED_BRANCH="<branch>"
   # Check diff against origin/main
   CHANGED_FILES=$(git diff --stat origin/main..."$MERGED_BRANCH")
   if [ -z "$CHANGED_FILES" ]; then
       echo "Branch $MERGED_BRANCH: all content present on origin/main — safe to delete"
   else
       echo "Branch $MERGED_BRANCH has content NOT on origin/main — flagging for review"
       # Produce content comparison table (same format as Step 3)
       # HALT deletion for this branch
   fi
   ```

5. **Delete local merged branches:**
   ```bash
   git branch -d "$MERGED_BRANCH"
   ```
   Use `-d` (safe delete — only if merged). If `-d` fails, the branch is NOT fully merged — HALT and report.

6. **Delete remote merged branches:**
   ```bash
   # Check if remote branch exists before attempting deletion
   if git ls-remote --heads origin "$MERGED_BRANCH" | grep -q "$MERGED_BRANCH"; then
       git push origin --delete "$MERGED_BRANCH"
   else
       echo "Remote branch $MERGED_BRANCH already deleted — skipping remote deletion"
   fi
   ```
   **Authorization note:** Remote branch deletion (`git push origin --delete`) is a destructive command per `000-critical-rules.md` §critical-rules-026. This operation is authorized as part of the cleanup pipeline scope — no separate authorization is required. However, the content verification gate (Step 4 above) MUST pass first.

7. **Tag-based hash permanence — tag-if-untagged:**
   Per `AGENTS.md` §Tag-Based Hash Permanence and §Idempotent Tag-if-Untagged Rule, verify the current submodule SHA is reachable via a tag. If not, tag it:
   ```bash
   CURRENT_SHA=$(git rev-parse HEAD)
   TAG_EXISTS=$(git tag --points-at "$CURRENT_SHA" | head -1)
   if [ -z "$TAG_EXISTS" ]; then
       # Generate context-appropriate tag
       PARENT_REPO_NAME="$(basename "$(git -C "$PARENT_REPO_PATH" rev-parse --show-toplevel 2>/dev/null || echo 'unknown')")"
       TAG="${PARENT_REPO_NAME}/v$(date +%Y%m%d)-submodule"
       git tag "$TAG" "$CURRENT_SHA"
       git push origin "$TAG" 2>/dev/null || echo "Could not push tag (remote may not be accessible)"
       echo "Tagged submodule SHA $CURRENT_SHA as $TAG"
   else
       echo "Submodule SHA $CURRENT_SHA already tagged ($TAG_EXISTS) — no action needed"
   fi
   ```

8. **Exit submodule — do NOT touch the pointer:**
   ```bash
   cd - > /dev/null
   # DO NOT: git add the submodule path, git commit, or any operation that modifies the parent repo
   # The dirty submodule pointer(s) are expected — Step 1.7 already handled acknowledgment
   ```

**After all submodules processed — acknowledge dirty pointer(s):**
```bash
echo "Submodule branch cleanup complete."
echo "Submodule pointer(s) are dirty — expected state after dev sync."
echo "No corrective action taken on submodule pointer(s)."
echo "The parent repo 'git status' will show modified submodule entry/entries — this is correct."
```

**🚫 FORBIDDEN:**
- `git add <submodule_path>` or any commit modifying any submodule pointer during cleanup
- `git submodule update --recursive` or any `--recursive` submodule command
- Switching the parent repo away from `dev`
- Treating a dirty submodule pointer as an error condition
- Creating a PR whose sole purpose is to update submodule pointer(s) (submodule-only PR, any number of submodules)

**✅ REQUIRED:**
- Verify each submodule is on `dev` before branch operations
- Content verification gate before each submodule branch deletion
- Tag-if-untagged for submodule SHAs
- Acknowledge dirty pointer after all submodules processed

**Evidence artifact (MANDATORY):** Tool-call output showing each submodule's `git branch --show-current` returns `dev`, the list of deleted branches per submodule, and the tag-if-untagged result per submodule. If no submodules exist, evidence that the step was evaluated and skipped is sufficient.

### Step 2: Remove Feature Worktree

```bash
SANITIZED=$(echo "<merged-branch-name>" | tr '/' '-')
WT_PATH=".worktrees/${SANITIZED}"

if [ -d ".worktrees" ] && git worktree list | grep -q "$WT_PATH"; then
    git worktree remove "$WT_PATH"
fi
```

### Step 2.5: Check for Active Parallel Worktrees

```bash
REMAINING=$(git worktree list | grep -c ".worktrees/spec-\|.worktrees/feature-")
if [ "$REMAINING" -gt 0 ]; then
    echo "Other feature worktrees still active: $REMAINING remaining"
    echo "Skipping git worktree prune"
else
    git worktree prune
fi
```

In parallel sub-agent mode, other agents may still be working in their worktrees. Only prune when ALL parallel work is confirmed complete.

### Step 3: Content Verification Gate (MANDATORY — ZERO TOLERANCE)

**⚠️ CRITICAL: Declaring a branch deletable without content verification is a CRITICAL GUIDELINE VIOLATION (see `000-critical-rules.md` §Content Verification Before Branch Deletion).**

Before deleting ANY merged branch, verify that all branch content is present on the target branch (dev):

1. **List changed files:** `git diff --stat origin/main...HEAD` — identify all files changed on the branch vs main
2. **For each file in the diff:**
   a. If file exists on main AND content matches: status = `IDENTICAL` — safe to delete
   b. If file exists on main BUT has newer/different content: `git diff origin/main...HEAD -- <file>` to compare; if main version supersedes branch version, status = `SUPERSEDED` — safe to delete with note
   c. If file does NOT exist on main: status = `UNIQUE` — MUST NOT delete branch, flag for developer review
3. **For tool/script files:** check version indicators (interface signatures, flag patterns, function presence) to determine supersession
4. **Produce content comparison table (MANDATORY evidence artifact):**

| File | Branch Version | Main Version | Status |
|------|---------------|-------------|--------|
| path/to/file | v4 (old interface) | v5 (new interface) | SUPERSEDED |
| path/to/unique | present | absent | UNIQUE — needs review |
| path/to/identical | match | match | IDENTICAL |

5. **Decision:**
   - If ANY file has `UNIQUE` status: HALT deletion, report unique files to developer, do NOT auto-delete
   - If ALL files have `SUPERSEDED` or `IDENTICAL` status: proceed with deletion

**🚫 FORBIDDEN:**
- Declaring a branch deletable based on PR merge status alone
- Declaring a branch deletable based on branch name pattern matching
- Declaring a branch deletable based on issue closure state
- Declaring a branch deletable based on commit count ahead/behind
- Deleting a branch without producing the content comparison table

**✅ REQUIRED:**
- `git diff --stat` to identify changed files
- Per-file content comparison (IDENTICAL/SUPERSEDED/UNIQUE)
- Content comparison table as evidence artifact before any deletion
- HALT and flag for developer review when UNIQUE content is found

### Step 3.2: Remove task() Entry Marker

After confirming content is safe to delete, remove the task() entry marker for the merged branch:

```bash
CLEANUP_BRANCH_NAME=$(git branch --show-current)
SAFE_BRANCH=$(echo "$CLEANUP_BRANCH_NAME" | tr '/' '-')
rm -f .issues/workflow/task-"$SAFE_BRANCH".marker
```

This marker was created by `assemble-work` Step 1.5 as task() entry proof for the pre-commit hook.

### Step 3.3: Delete Checkpoint Tags

Delete any checkpoint tags for the current issue(s) on this branch:

```bash
CONSUMER_REPO=<github.repo>
LOCAL_TAGS=$(git tag --list "${CONSUMER_REPO}/checkpoint/*" 2>/dev/null)
if [ -n "$LOCAL_TAGS" ]; then
  echo "$LOCAL_TAGS" | xargs -r git tag -d
  for tag in $LOCAL_TAGS; do
    git push origin --delete "$tag" 2>/dev/null || true
  done
fi
```

Checkpoint tag format: `<parent>/checkpoint/<issue>/phase-<N>-<submodule>` per `git-workflow/SKILL.md` §Tag Convention. Tags are workflow-ephemeral — deleted on branch cleanup.

### Step 3.4: Delete Current Merged Branch

```bash
git branch -d <merged-branch-name>
git push origin --delete <merged-branch-name> 2>/dev/null || echo "Remote already deleted"
git fetch --prune
git remote prune origin
```

**Why `git remote prune origin` is mandatory:** Stale remote-tracking references cause confusion and can interfere with new branch creation.

### Step 3.5: Work Branch Cleanup

When the merged branch was a work branch (created by `assemble-work`):

1. Delete individual feature branches that were squash-merged into the work branch
2. Delete the work branch itself
3. Remove individual feature worktrees
4. Remove work state file: `rm -f .issues/workflow/work-*.md 2>/dev/null || true`
5. Prune remote references

**⚠️ CRITICAL: Never delete a work branch or its feature branches until the work PR is confirmed merged via GitHub API.**

### Step 4: Clean Other Merged Branches

```bash
git branch --merged dev
```

For each merged branch (except main/master/dev): `git branch -d <branch>`

### Step 5: Verify Clean State

```bash
git status --porcelain  # Must be empty
git branch -vv          # Should show minimal branches
```

**`.issues/<N>/` Persistence:** The `.issues/<issue_number>/` directory MUST NOT be deleted. It persists permanently in the working tree on `dev` as immutable history. After merge, the feature branch's `.issues/<N>/` content lands in `dev` via the merge. Do NOT add cleanup steps that remove or archive these directories.

### Step 6: Succinct Confirmation

**The `cleanup` task is THE END of the PR workflow. It MUST produce a one-line succinct confirmation and then HALT.**

```
PR #<number> merged. Branch `<branch-name>` deleted. Cleanup complete.
```

**⚠️ CRITICAL: Do NOT re-report PR details or issue lists. The PR was already reported at creation time.**

### Final HALT (CRITICAL)

After cleanup, the agent MUST HALT. No prompting, no questions, no next steps.

| Action | Status |
| -- | -- |
| Close issues | ✅ Done |
| Delete branches | ✅ Done |
| Post final summary | ✅ Done |
| Ask "What's next?" | 🚫 NEVER |

## Context Required

- Related tasks: `cleanup/verify-merge`, `cleanup/issue-closure`
- Related guidelines: `000-critical-rules.md` (branch deletion rules)