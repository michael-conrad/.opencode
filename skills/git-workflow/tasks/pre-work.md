# Task: pre-work

## Purpose

Create feature branch BEFORE any implementation work begins. Verify authorization, sync dev, and set up workspace. Direct-branch (creating feature branch in main repo) is the PRIMARY and DEFAULT workflow. Worktrees are opt-in, used only when `WORKTREE_REQUIRED` is set.

## 🚫 ZERO TOLERANCE: Branch Before Edit

**The agent MUST create a feature branch BEFORE ANY filesystem change.**

**This is a Tier 1 (Non-Yielding) mandate** per `000-critical-rules.md` → "Mandate Tiering." Even with explicit developer authorization ("approved"/"go"), the agent MUST create a feature branch before editing files. Developer authorization can waive Tier 2 process mandates (spec-before-code, plan-before-implementation) but CANNOT waive this Tier 1 safety mandate. No exceptions, no fallbacks.

This is the FIRST and MOST CRITICAL rule. Before writing any code, editing any file, creating any file, or making ANY change to the project:

1. **Create feature branch** — in main repo by default, in worktree only when `WORKTREE_REQUIRED` is set
2. **All work happens on the feature branch** — never on `main` or `dev`
3. **ONLY THEN**: Proceed with file changes

**What Counts as a "Change"?**

- Editing any file (code, config, docs, tests)
- Creating new files
- Deleting files
- Renaming files
- Modifying `.gitignore`, `pyproject.toml`, any config
- Updating guidelines in `.opencode/`
- ANY filesystem modification whatsoever
- **Using file-editing MCP tools** (`pycharm_replace_text_in_file`, `pycharm_create_new_file`, etc.) — these ARE filesystem changes

**⚠️ MCP Tools Are NOT an Exception**

- `pycharm_replace_text_in_file` → edits files → MUST be on feature branch
- `pycharm_create_new_file` → creates files → MUST be on feature branch
- `github_issue_write` → GitHub Issues, NOT local files → NOT a filesystem change
- `github_add_issue_comment` → GitHub comments → NOT a filesystem change

**Violation = Hard Stop**

- If you catch yourself about to edit files while on `main` or `dev`, STOP immediately
- Create a feature branch before proceeding
- Never proceed past this checkpoint without an active feature branch

### ✅ ALWAYS DO

```
# Direct-branch mode (DEFAULT):
# 1. Sync dev: git checkout dev && git pull origin dev
# 2. Create feature branch: git checkout -b spec/my-change dev
# 3. Work directly in main working directory on the feature branch
```

### Worktree Mode (ONLY when `WORKTREE_REQUIRED` is set)

```
# Worktree mode (opt-in, when WORKTREE_REQUIRED is set):
# 1. Sync dev: git checkout dev && git pull origin dev
# 2. Invoke using-git-worktrees skill to create worktree
# 3. Work in .worktrees/spec-my-change/ (using worktree.path prefix)
```

### 🚫 NEVER DO

```
# WRONG — VIOLATION (editing on dev or main):
git checkout dev
# Edit files directly on dev

# WRONG — VIOLATION (creating worktree when WORKTREE_REQUIRED not set):
git worktree add .worktrees/spec-my-change -b spec/my-change dev
# Unnecessary isolation — direct-branch is the default
```

## Operating Protocol

1. **Mandatory invocation (no decision point):** The agent MUST invoke this task when:
   - User says `approved`, `go`, or similar authorization to begin implementation
   - DO NOT prompt for invocation — invoke the skill directly

## Entry Criteria

- User has authorized implementation (explicit `approved` or `go`)
- Authorization is for the correct issue
- Sub-issue structure verified (for multi-task specs)

## Three-Branch Workflow Context

**Branch Model:**

- **Feature branches** (`feature/*` or `spec/*`): Branch from `dev`, merge to `dev`
- **Dev branch** (`dev`): Staging/integration (evergreen, never deleted)
- **Main branches** (`main` or `master`): Production-ready code

**AI Commit Restrictions:**

- AI cannot commit to `main`, `master`, or `dev` (blocked by git hooks)
- AI must create feature branches from `dev` (not `main`)
- AI must sync with `dev` before creating feature branch

## Procedure

### Step 1: Verify Authorization Context

**This task receives authorization context from orchestration layer. DO NOT re-check authorization.**

### Step 2: Repo State Verification Gates

Before creating any branch, proactively verify the repository is in a good state.

#### Step 2a: Current Branch Check

Verify the working directory is on `dev` or an expected feature branch:

```bash
CURRENT_BRANCH=$(git branch --show-current)
```

- If on `dev`: proceed to Step 2b
- If on an existing feature branch: verify it is the intended branch or switch to `dev` first
- If on `main` or `master`: switch to `dev` before proceeding

#### Step 2b: Submodule Initialization Check

If `.gitmodules` exists, verify submodules are initialized and on `dev`:

```bash
test -f .gitmodules && git submodule status
```

**If any submodule shows `-` prefix (not initialized):**

Run the dev parking protocol to initialize all submodules:

```bash
git checkout dev && git pull && git submodule init && git submodule foreach "git checkout dev && git pull"
```

**If any submodule is NOT on its `dev` branch:**

Sync it to dev:

```bash
git submodule foreach "git checkout dev && git pull"
```

#### Step 2c: Fresh Clone Handling

After a fresh clone, submodules are unregistered and branches may not exist. Run the full dev parking protocol:

```bash
git checkout dev && git pull && git submodule init && git submodule foreach "git checkout dev && git pull"
```

If `dev` branch does not exist yet:

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
git submodule init && git submodule foreach "git checkout dev && git pull"
```

**If dev branch creation fails entirely (neither origin/dev nor origin/main exists), the agent MUST HALT immediately and report the fatal error. Proceeding on `main` is a CRITICAL GUIDELINE VIOLATION.**

#### Step 2d: Sync Dev Branch

Ensure `dev` is up-to-date before branching:

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

### Step 3: Create Feature Branch

**Default: Direct-branch in main repo.** Only create a worktree when `WORKTREE_REQUIRED` is set.

#### Step 3a: Direct-Branch Mode (DEFAULT)

Create feature branch directly in the main repo:

```bash
git checkout -b <branch-name> dev
```

Or using `git switch`:

```bash
git switch -c <branch-name> dev
```

- `worktree.path` is NOT set
- Relative paths work directly for all file operations
- Work in the main project directory on the feature branch

#### Step 3b: Worktree Mode (ONLY when `WORKTREE_REQUIRED` is set)

When the `WORKTREE_REQUIRED` flag is set, invoke `using-git-worktrees` skill:

1. Invoke `using-git-worktrees` skill
2. The skill creates the worktree: `git worktree add .worktrees/spec-<name> -b spec/<name> dev`
3. The skill exports `worktree.path`, `branch`, `DEV_BASE_HASH` as environment variables
4. If `worktree.path` is not set or empty: **FATAL ERROR → FLAG DEV → HALT**

**If worktree creation fails or `worktree.fatal=1` is detected:**

- HALT immediately
- Report the fatal error to the developer
- Do NOT attempt any implementation until the worktree infrastructure is fixed

### Step 3.5: Submodule Initialization and Sync

**If `.gitmodules` exists**, initialize and sync submodules before proceeding:

```bash
test -f .gitmodules
```

**If `.gitmodules` exists:**

1. **Advance submodules to their `dev` tip:**

   ```bash
   git submodule update --init --remote
   ```

   - This checks out each submodule at the tip of its `origin/dev` branch.

2. **For each submodule, ensure `origin/dev` exists:**

   ```bash
   # List submodule paths
   git config --file .gitmodules --get-regexp path | awk '{print $2}'
   ```

    For each submodule path:
    ```bash
    cd <submodule-path>
    git fetch origin
    if git rev-parse --verify origin/dev >/dev/null 2>&1; then
        git checkout dev
        git pull origin dev
    else
        git checkout -b dev origin/main
        if [ $? -ne 0 ]; then
            echo "FATAL: Failed to create dev branch in submodule <submodule-path> from origin/main. HALT."
            exit 1
        fi
        git push -u origin dev
    fi
    cd -
    ```

3. **Log submodule status:**

   ```bash
   git submodule foreach --recursive 'echo "  $(basename $path) checked-out=$(git rev-parse --short HEAD) committed=$(git rev-parse --short $sha1) dev-tip=$(git rev-parse --short origin/dev 2>/dev/null || echo N/A)"'
   ```

4. **Report status to chat:** Report each submodule's path, checked-out SHA, committed SHA, and dev tip SHA.

5. **If any submodule SHA changed from the parent's committed ref**, auto-commit the submodule bump:

   For each submodule whose checked-out SHA differs from the parent's committed SHA:
   1. Read the commit log between old and new SHA:
      ```bash
      cd <submodule-path>
      git log --oneline <old_sha>..<new_sha>
      cd -
      ```
   2. Generate a summary commit message with the count and first-line summaries:
      ```bash
      git add <submodule-path>
      git commit -m "chore(submodule): pin <path> to latest dev (N commits: summary)"
      ```
   3. Continue with normal pre-work flow.

**Mid-feature submodule sync discipline:** When working on a feature branch over an extended period, periodically sync submodules to stay current with upstream dev:

```bash
git submodule foreach "git checkout dev && git pull"
```

**If on `main` worktree or direct-branch targeting `main`:** Use `git submodule update --init` (no `--remote`) to lock submodules to their committed SHAs instead of advancing to dev tip.

**If `.gitmodules` does NOT exist:** Skip all submodule steps and proceed to Step 4.

### Step 4: Verify Branch Environment

**Before yielding back to orchestration layer, verify:**

#### Direct-Branch Mode:

```bash
git branch --show-current
# MUST show the feature branch name (not main, not dev)

git status --porcelain
# MUST be empty or only pre-existing changes
```

#### Worktree Mode (when `WORKTREE_REQUIRED` is set):

```bash
git branch --show-current
# MUST show the feature branch name

git rev-parse --show-toplevel
# MUST show the worktree path (not main repo path)

echo $WORKTREE_PATH
# MUST NOT be empty — FATAL ERROR if empty
```

**If ANY check fails → STOP and report.**

### Step 5: Report Ready

**Direct-branch mode:**

Report: "Ready for implementation on branch: <branch-name> (direct-branch mode)"

```yaml
status: success
branch: <branch-name>
worktree_path: ""
dev_base_hash: <7-char-sha>
working_tree_clean: true
ready_for: implementation
```

**Worktree mode:**

Report: "Ready for implementation in worktree: <worktree-path> on branch: <branch-name>"

```yaml
status: success
branch: <branch-name>
worktree_path: .worktrees/<sanitized-branch-name>
dev_base_hash: <7-char-sha>
working_tree_clean: true
ready_for: implementation
```

## Context Received from Orchestration Layer

**Input context from `divide-and-conquer`:**

```yaml
authorization: confirmed (from approval-gate)
issue: <issue-number>
```

This task does NOT re-check authorization. Authorization was verified by `approval-gate` before this task was invoked.

## Yield-Back to Orchestration Layer

**After completion, this task yields:**

```yaml
status: success | failure
branch: "spec/<feature-name>" | "feature/<feature-name>"
worktree_path: "" | ".worktrees/<sanitized-branch-name>"
dev_base_hash: "<7-char-sha>"
working_tree_clean: true
ready_for: "implementation"
```

**`worktree_path` is empty string in direct-branch mode (default). Only populated when `WORKTREE_REQUIRED` is set.**

The orchestration layer (`divide-and-conquer`) receives this yield and passes relevant context to the implementation subagent.

## ⚠️ Edge Case: Already Implemented (No Changes Needed)

**When investigation reveals spec is already implemented:**

1. **Detect before branch creation:**

   - After reading files, verify all proposed changes are already present
   - Confirm no modifications needed
   - Document verification in issue comment

2. **Skip branch creation entirely:**

   - Do NOT create feature branch (direct or worktree)
   - Do NOT push anything
   - Do NOT create PR

3. **Close issue directly:**

   - Post verification comment explaining what was checked
   - Close issue with `state_reason: "completed"`
   - Report completion in chat

**Example Comment:**

```markdown
🤖 <AgentName> (<ModelId>) completed

**Summary:**

Verified all proposed changes were already implemented. No modifications needed.

**Verification Results:**

- [List what was checked and confirmed present]
- [File references with function names for existing content]

**Outcome:** Spec requirements verified complete without additional changes.
```

4. **HALT after closing:**
   - No further steps needed
   - No worktree or branch cleanup needed (none was created)

## Branch Name to Worktree Name Mapping

When worktree mode is active, branch names containing `/` are sanitized for the worktree directory name:

| Branch Name | Worktree Directory |
| -- | -- |
| `feature/<name>` | `.worktrees/feature-<name>/` |
| `spec/<name>` | `.worktrees/spec-<name>/` |

**Rule:** Replace `/` with `-` in the worktree directory name.

### Worktree Already Exists Check (Worktree Mode Only)

```bash
# Check if worktree for this branch already exists
git worktree list | grep "spec-xyz"
```

If found, report collision and HALT — do not reuse another branch's worktree.

## Enforcement Mechanisms (NO BYPASS)

| Layer | Mechanism | Scope | Bypassable? |
| -- | -- | -- | -- |
| **Local** | `.opencode/hooks/pre-commit` | Blocks commit to main/dev | No |
| **Local** | `.opencode/hooks/post-commit` | Warns after commit to main/dev | N/A (post) |
| **GitHub** | Branch protection rules | Requires PR | No |

**There is NO emergency bypass.** If you need to make an urgent fix:

1. Create a feature branch: `git checkout -b hotfix/urgent-fix dev`
2. Make your changes and commit on the branch
3. Push and create PR with `hotfix` label
4. Request expedited review

## Live Verification (MANDATORY)

**🚫 CRITICAL: Each verification point requires a tool call for evidence. Assertions without tool-call artifacts are VERIFICATION-GAP findings.**

### Branch State Verification

| Check | Tool Call | Expected Result | On Failure |
| -- | -- | -- | -- |
| Current branch | `git branch --show-current` | Feature branch name (not `main`, `dev`) | STRUCTURE-VIOLATION → HALT |
| Working tree clean | `git status --porcelain` | Empty output | VERIFICATION-GAP → stash or commit first |
| Dev base hash | `git rev-parse --short dev` | Valid 7-char SHA | MISSING-ELEMENT → sync dev first |

### Worktree Mode Verification (ONLY when `WORKTREE_REQUIRED` is set)

| Check | Tool Call | Expected Result | On Failure |
| -- | -- | -- | -- |
| Worktree location | `git rev-parse --show-toplevel` | Worktree path (not main repo path) | STRUCTURE-VIOLATION → HALT |
| worktree.path set | `echo $WORKTREE_PATH` (or equivalent) | Non-empty, matches worktree dir | STRUCTURE-VIOLATION → HALT (fatal) |

### Submodule State Verification

| Check | Tool Call | Expected Result | On Failure |
| -- | -- | -- | -- |
| Submodules initialized | `git submodule status` | No `-` prefix entries | MISSING-ELEMENT → run `git submodule init` |
| Submodules on dev | `git submodule foreach "git branch --show-current"` | `dev` for each submodule | MISSING-ELEMENT → sync submodules |

### Verification Procedure

**After Step 4 (Verify Branch Environment), run these verifications and record evidence:**

```
1. git branch --show-current → EVIDENCE: <branch-name>
2. git status --porcelain → EVIDENCE: <output or "(empty)">
3. git rev-parse --short dev → EVIDENCE: <7-char-sha>
```

**Worktree mode additional checks (ONLY when `WORKTREE_REQUIRED` is set):**

```
4. git rev-parse --show-toplevel → EVIDENCE: <path>
5. worktree.path → EVIDENCE: <path or "(empty)">
```

**Submodule checks (ONLY when `.gitmodules` exists):**

```
6. git submodule status → EVIDENCE: <status output>
7. git submodule foreach "git branch --show-current" → EVIDENCE: <branch names>
```

**Classification on failure:**

| Failure | Problem Class | Classification | Action |
| -- | -- | -- | -- |
| On `main` or `dev` branch | CONFLICTING | flag-for-review | HALT — must create feature branch first |
| Dirty working tree | VERIFICATION-GAP | conditional | Stash or commit before implementation |
| `rev-parse` returns main repo path (worktree mode) | STRUCTURE-VIOLATION | auto-fix | Not in worktree — re-invoke using-git-worktrees |
| worktree.path empty (worktree mode) | STRUCTURE-VIOLATION | auto-fix | FATAL — cannot safely do file operations |
| dev hash stale | MISSING-ELEMENT | conditional | Re-run `git pull origin dev` |
| Submodule not initialized | MISSING-ELEMENT | auto-fix | Run `git submodule init` |
| Submodule not on dev | MISSING-ELEMENT | auto-fix | Run `git submodule foreach "git checkout dev && git pull"` |

**These verifications are MANDATORY. Skipping them is a CRITICAL GUIDELINE VIOLATION.**

## Context Required

- Related skills: `approval-gate` (authorization check), `using-git-worktrees` (worktree creation, only when `WORKTREE_REQUIRED` is set)
- Related tasks: `cleanup` (branch cleanup after PR merge)

## Enforcement Checklist

**Before starting any work, verify:**

- ✅ Authorization received (explicit `approved`, `go`, or `"#N approved"`)
- ✅ On `dev` branch before creating feature branch
- ✅ Submodules initialized and on `dev` (if `.gitmodules` exists)
- ✅ Feature branch created from `dev` (NOT on `main` or `dev`)
- ✅ `git branch --show-current` shows feature branch name

**Worktree mode additional checks (ONLY when `WORKTREE_REQUIRED` is set):**

- ✅ Worktree created (not operating directly on `dev` or `main`)
- ✅ `worktree.path` environment variable is set and non-empty (FATAL ERROR if empty)
- ✅ `git rev-parse --show-toplevel` in worktree shows worktree path

**These checks are MANDATORY. If ANY check fails → STOP and report.**
