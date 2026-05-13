# Task: pre-work

## Purpose

Create feature branch BEFORE any implementation work begins. Verify authorization, sync dev, and set up the working environment. Default mode is direct-branch (feature branch in main repo); worktree mode is opt-in when `WORKTREE_REQUIRED` is set.

## 🚫 ZERO TOLERANCE: Branch Before Edit

**The agent MUST create a feature branch BEFORE ANY filesystem change.**

**Branch creation mode is determined by `WORKTREE_REQUIRED`:**

| Mode | When | Branch Command | Path Behavior |
|------|------|---------------|---------------|
| **Direct-branch (default)** | `WORKTREE_REQUIRED` NOT set | `git checkout -b feature/X` or `git switch -c feature/X` | Relative paths work directly |
| **Worktree (opt-in)** | `WORKTREE_REQUIRED` set or developer request | `git worktree add .worktrees/feature-X -b feature/X dev` | All paths prefixed with `worktree.path` |

**In both modes, the agent MUST NOT commit to `main` or `dev`.** This is a Tier 1 (Non-Yielding) mandate.

This is the FIRST and MOST CRITICAL rule. Before writing any code, editing any file, creating any file, or making ANY change to the project:

1. **Verify on a feature branch** (NOT `main` or `dev`) — either direct-branch or worktree
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
- Create a feature branch first (direct-branch or worktree based on `WORKTREE_REQUIRED`)
- Never proceed past this checkpoint without an active feature branch

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

### Step 1.5: Pre-flight — Verify `dev` branch exists on remote

Before syncing or creating a local `dev` branch, verify the remote has a `dev` branch. If it doesn't, create it from the default branch. If no remote exists, skip gracefully.

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

**Key behaviors:**

- **No remote at all:** Skip this check entirely — local-only repos require no remote branch setup
- **Remote exists but `dev` missing:** Create `dev` on origin from the default branch determined via `git remote show origin`
- **Verification failure after push:** HALT and report — do not proceed without a remote `dev` branch when a remote exists
- **DO NOT add any remotes** — this check only works with pre-existing remotes

### Step 2: Sync Dev Branch

The main working tree must be on `dev` and up-to-date so branch creation has the correct base:

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

**If dev branch creation fails entirely (neither origin/dev nor origin/main exists), the agent MUST HALT immediately and report the fatal error. Proceeding on `main` is a CRITICAL GUIDELINE VIOLATION.**

### Step 2.5: Proactive Repo State Verification

**Before creating any feature branch, verify repo state:**

1. **Submodule initialization check:** `git submodule status` — if any submodule shows `-` prefix (not initialized), run `git submodule init && git submodule foreach "git checkout dev && git pull"`
2. **Submodule currency check:** If any submodule is not on `dev` branch, sync it: `git submodule foreach "git checkout dev && git pull"`
3. **Fresh clone handling:** After `git clone`, the dev parking protocol must be run: `git checkout dev && git pull && git submodule init && git submodule foreach "git checkout dev && git pull"`

### Step 2.7: Automatic Prerequisite Operations

**⚠️ When authorization has been verified (approval-gate `verify-authorization` passed), the following git operations are AUTOMATIC prerequisites that MUST be performed WITHOUT soliciting developer confirmation.**

These operations are deterministic, mechanical steps that are either Tier 1 mandates (required by guidelines) or pipeline prerequisites (necessary for the authorized scope). They require NO judgment from the agent or the developer.

| Operation | Step | Classification | Condition |
|-----------|------|----------------|-----------|
| `git fetch origin` | Step 1.5/2 | Pipeline prerequisite | Remote exists |
| `git checkout dev && git pull origin dev` | Step 2 | Tier 1 mandate prerequisite | Always when remote exists |
| `git submodule init` + `git submodule foreach "git checkout dev && git pull"` | Step 2.5 | Tier 1 mandate prerequisite | `.gitmodules` exists |
| `git add .opencode` (submodule bump) | Step 3.5 | Tier 1 mandate prerequisite | Submodule SHA changed |
| `git checkout -b feature/N-xyz` or `git switch -c feature/N-xyz` | Step 3 | Tier 1 mandate — required by `000-critical-rules.md` §Skipping Git Pre-Check | Always |
| `git push -u origin feature/N-xyz` | Post-Step 5 | Pipeline prerequisite for `for_pr` scope | Remote exists, `halt_at >= pr_created` |

**Automatic classification conditions (ALL must be true):**

1. Authorization has been verified — `approval-gate --task verify-authorization` passed
2. The operation is a Tier 1 mandate or a deterministic prerequisite for authorized work
3. The operation requires no judgment — it is a deterministic, mechanical step
4. The scope covers the pipeline stage containing the operation (`for_pr`, `for_implementation`, `for_review_prep`)

**🚫 FORBIDDEN: Soliciting developer confirmation for automatic prerequisites:**

- "Should I sync the submodule?" → FORBIDDEN — submodule sync is automatic
- "May I create the feature branch?" → FORBIDDEN — branch creation is a Tier 1 mandate
- "Ready to proceed with git push?" → FORBIDDEN — initial push is a pipeline prerequisite
- "Proceed with pre-work?" → FORBIDDEN — pre-work is mandatory after authorization
- Any confirmation request for operations in the table above → FORBIDDEN

**✅ REQUIRED: Proceed autonomously through all pre-work steps once authorization is verified.**

The agent MUST NOT ask for confirmation, permission, or readiness before performing any operation listed in the table above. These are mechanical prerequisites that the agent MUST execute as part of the approved workflow.

**See also:** `000-critical-rules.md` §"Pushing Agent Intelligence Decisions to the User" — whether to sync a submodule, create a branch, or push is NOT a decision requiring user input when authorization covers the pipeline stage.

### Step 3: Create Feature Branch (Mode-Dependent)

#### Direct-Branch Mode (DEFAULT — when WORKTREE_REQUIRED is NOT set)

Create feature branch directly in the main repo:

```bash
git checkout -b <branch-name> dev
# or: git switch -c <branch-name> dev
```

**Relative paths work directly in direct-branch mode.** No worktree path prefixing needed.

**After branch creation:**

```bash
# Verify branch
git branch --show-current
# MUST show the feature branch name

# Verify working tree
git status --porcelain
# Report any uncommitted changes
```

#### Worktree Mode (OPT-IN — when WORKTREE_REQUIRED is set or developer requests)

Invoke `using-git-worktrees` skill to create an isolated worktree:

1. Invoke `using-git-worktrees` skill
2. The skill creates the worktree: `git worktree add .worktrees/<sanitized-name> -b <branch-name> dev`
3. The skill exports `worktree.path`, `branch`, `DEV_BASE_HASH` as environment variables
4. If `worktree.path` is not set or empty: **FATAL ERROR → FLAG DEV → HALT**

**If worktree creation fails or `worktree.fatal=1` is detected:**

- HALT immediately
- Report the fatal error to the developer
- Do NOT attempt any implementation until the worktree infrastructure is fixed
- There is NO fallback to direct-branch when worktree mode is explicitly requested

### Step 3.5: Submodule Initialization and Sync

**If `.gitmodules` exists**, initialize and sync submodules before proceeding:

```bash
test -f .gitmodules
```

**If `.gitmodules` exists:**

1. **Advance submodules to their `dev` tip:**

   ```bash
   git submodule foreach "git checkout dev && git pull"
   ```

   - This checks out each submodule at the tip of its `dev` branch.
   - Do NOT use `--recursive` flag (per `060-tool-usage.md`).

2. **Log submodule status:**

   ```bash
   git submodule status
   ```

3. **Report status to chat:** Report each submodule's path, checked-out SHA, committed SHA, and dev tip SHA.

4. **If any submodule SHA changed from the parent's committed ref**, auto-commit the submodule bump:

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

**If on `main` worktree:** Use `git submodule update --init` (no `--remote`) to lock submodules to their committed SHAs instead of advancing to dev tip.

**If `.gitmodules` does NOT exist:** Skip all submodule steps and proceed to Step 4.

### Step 3.7: Initialize .issues/<issue_number>/ Directory (MANDATORY)

After branch creation and submodule sync, initialize the `.issues/<issue_number>/` tracking directory:

1. **Create directory:**
   ```bash
   mkdir -p .issues/<issue_number>/
   ```

2. **Fetch spec from API and mirror to `spec.md`:**
   - Call `github_issue_read(method="get", owner=<github.owner>, repo=<github.repo>, issue_number=<issue_number>)`
   - If success: write `.issues/<issue_number>/spec.md` with header `# Synced from GitHub Issue #<issue_number> at <ISO8601-timestamp>` followed by the issue body
   - If API unreachable: skip `spec.md` creation (no fallback since there's nothing to fall back to at initialization)
   - See `issue-operations/platforms/github-mcp/SKILL.md` → "spec.md Mirror" for the complete mirror procedure

3. **Write initial `state.md`:**
   ```markdown
   # State: Issue #<issue_number>

   **Branch:** <branch-name>
   **Workflow Phase:** pre-work
   **Created:** <ISO8601-timestamp>
   **Last Updated:** <ISO8601-timestamp>
   **Status:** initialized

   ## Current State

   Pre-work initialization complete. Awaiting implementation dispatch.

   ## Blockers

   None.
   ```

4. **Auto-commit `.issues/<issue_number>/`:**
   ```bash
   git add .issues/<issue_number>/spec.md .issues/<issue_number>/state.md
   git commit -m "docs(issues): <issue_number> - spec: mirrored from GitHub Issue #<issue_number>, state: pre-work initialization"
   ```

### Step 4: Verify Branch Environment

**Before yielding back to orchestration layer, verify:**

```bash
# Verify current branch
git branch --show-current
# MUST show the feature branch name (not main, not dev)

# Verify working tree
git status --porcelain
# Report any uncommitted changes
```

**In worktree mode, additionally verify:**

```bash
git rev-parse --show-toplevel
# MUST show the worktree path (not main repo path)

echo $WORKTREE_PATH
# MUST NOT be empty — FATAL ERROR if empty
```

**If ANY check fails → STOP and report.**

### Step 5: Report Ready

**Direct-branch mode:**

Report: "Ready for implementation on branch: <branch-name> (direct-branch)"

```yaml
status: success
branch: <branch-name>
worktree_path: null
direct_branch: true
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
direct_branch: false
dev_base_hash: <7-char-sha>
working_tree_clean: true
ready_for: implementation
```

## `investigate/` Scratch Branches

Under `for_analysis` scope, the agent may create `investigate/<topic>` scratch branches for read-only investigation. These are NOT feature branches — they are ephemeral throwaway branches.

### When to Use

- Investigating a bug hypothesis
- Running throwaway scripts to examine data
- Testing a refactoring idea without committing
- Exploring file structure in a clean context

### Naming Convention

```bash
git checkout -b investigate/<topic> dev
```

Examples: `investigate/parsing-bug`, `investigate/missing-env-var`, `investigate/test-failure-root-cause`

### Scope Gate

- `investigate/*` branches are permitted under `for_analysis` scope (self-assigned or explicit)
- `investigate/*` branches do NOT require `for_implementation` — they are read-only scratch branches
- The agent MUST NOT make permanent code changes on `investigate/*` branches
- Writes to `./tmp/` and throwaway scripts ARE permitted

### MUST Discard Before HALT

**🚫 CRITICAL: `investigate/` branches MUST be discarded before the halt message.**

```bash
git branch -D investigate/<topic>
```

This is a hard requirement — leaving `investigate/` branches in the repo pollutes branch space. The enforcement in `enforcement/halt-conditions.md` verifies this.

### `feature/` and `spec/` Branch Scope Gate

Creating `feature/*` or `spec/*` branches requires `for_implementation` scope or above. Under `for_analysis`, these branches are BLOCKED:

```bash
# 🚫 FORBIDDEN under for_analysis
git checkout -b feature/123-xyz dev  # Requires for_implementation+

# ✅ PERMITTED under for_analysis
git checkout -b investigate/parsing-bug dev  # Read-only scratch branch
```

If the agent attempts to create a `feature/` or `spec/` branch under `for_analysis`, the operation MUST be rejected and reported as a scope boundary violation.

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|implementation_complete|review_prep|pr_created>
pr_strategy: <none|individual|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Dispatch Rules
- Missing `authorization_scope` in dispatch context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

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
worktree_path: ".worktrees/<sanitized-branch-name>" | null
direct_branch: true | false
dev_base_hash: "<7-char-sha>"
working_tree_clean: true
ready_for: "implementation"
```

The orchestration layer (`divide-and-conquer`) receives this yield and passes relevant context to the implementation subagent.

## ⚠️ Edge Case: Already Implemented (No Changes Needed)

**When investigation reveals spec is already implemented:**

1. **Detect before branch creation:**

   - After reading files, verify all proposed changes are already present
   - Confirm no modifications needed
   - Document verification in issue comment

2. **Skip branch creation entirely:**

   - Do NOT create feature branch
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
   - No worktree cleanup (no worktree was created)

## Branch Name to Worktree Name Mapping (Worktree Mode Only)

Branch names containing `/` are sanitized for the worktree directory name:

| Branch Name | Worktree Directory |
| -- | -- |
| `feature/<name>` | `.worktrees/feature-<name>/` |
| `spec/<name>` | `.worktrees/spec-<name>/` |

**Rule:** Replace `/` with `-` in the worktree directory name.

### Worktree Already Exists Check (Worktree Mode Only)

```bash
git worktree list | grep "feature-xyz"
```

If found, report collision and HALT — do not reuse another branch's worktree.

## Enforcement Mechanisms (NO BYPASS)

| Layer | Mechanism | Scope | Bypassable? |
| -- | -- | -- | -- |
| **Local** | `.opencode/hooks/pre-commit` | Blocks commit to main | No |
| **Local** | `.opencode/hooks/post-commit` | Warns after commit to main | N/A (post) |
| **GitHub** | Branch protection rules | Requires PR | No |

**There is NO emergency bypass.** If you need to make an urgent fix:

1. Create a feature branch: `git checkout -b hotfix/urgent-fix dev`
2. Make your changes and commit
3. Push and create PR with `hotfix` label
4. Request expedited review

## Live Verification (MANDATORY)

**🚫 CRITICAL: Each verification point requires a tool call for evidence. Assertions without tool-call artifacts are VERIFICATION-GAP findings.**

### Branch State Verification

| Check | Tool Call | Expected Result | On Failure |
| -- | -- | -- | -- |
| Remote dev branch (when remote exists) | `git ls-remote origin dev` | Non-empty output | MISSING-ELEMENT → run Step 1.5 to create |
| Current branch | `git branch --show-current` | Feature branch name (not `main`, `dev`) | STRUCTURE-VIOLATION → HALT |
| Working tree clean | `git status --porcelain` | Empty output | VERIFICATION-GAP → stash or commit first |
| Worktree location (worktree mode only) | `git rev-parse --show-toplevel` | Worktree path (not main repo path) | STRUCTURE-VIOLATION → HALT |
| worktree.path set (worktree mode only) | `echo $WORKTREE_PATH` | Non-empty, matches worktree dir | STRUCTURE-VIOLATION → HALT (fatal) |
| Dev base hash | `git rev-parse --short dev` | Valid 7-char SHA | MISSING-ELEMENT → sync dev first |

### Verification Procedure

**After Step 4 (Verify Branch Environment), run these verifications and record evidence:**

```
1. git branch --show-current → EVIDENCE: <branch-name>
2. git status --porcelain → EVIDENCE: <output or "(empty)">
3. (worktree mode only) git rev-parse --show-toplevel → EVIDENCE: <path>
4. (worktree mode only) worktree.path → EVIDENCE: <path or "(empty)">
```

**Classification on failure:**

| Failure | Problem Class | Classification | Action |
| -- | -- | -- | -- |
| Remote dev branch missing | MISSING-ELEMENT | auto-fix | Run Step 1.5 to create dev on origin |
| On `main` or `dev` branch | CONFLICTING | flag-for-review | HALT — must create feature branch first |
| Dirty working tree | VERIFICATION-GAP | conditional | Stash or commit before implementation |
| `rev-parse` returns main repo path (worktree mode) | STRUCTURE-VIOLATION | auto-fix | Not in worktree — re-invoke using-git-worktrees |
| worktree.path empty (worktree mode) | STRUCTURE-VIOLATION | auto-fix | FATAL — cannot safely do file operations |
| dev hash stale | MISSING-ELEMENT | conditional | Re-run `git pull origin dev` |

**These verifications are MANDATORY. Skipping them is a CRITICAL GUIDELINE VIOLATION.**

## Context Required

- Related skills: `approval-gate` (authorization check), `using-git-worktrees` (worktree creation, opt-in only)
- Related tasks: `cleanup` (branch cleanup after PR merge)

## Enforcement Checklist

**Before starting any work, verify:**

- ✅ Authorization received (explicit `approved`, `go`, or `"#N approved"`)
- ✅ Remote dev branch exists on origin (or no remote — local-only repo skip)
- ✅ Feature branch created (not on `main` or `dev`)
- ✅ (Worktree mode only) `worktree.path` environment variable is set and non-empty
- ✅ (Worktree mode only) `git rev-parse --show-toplevel` in worktree shows worktree path
- ✅ `git branch --show-current` shows feature branch
- ✅ Feature branch created from `dev`

**These checks are MANDATORY. If ANY check fails → STOP and report.**