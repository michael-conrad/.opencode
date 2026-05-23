# Sub-Task: pre-work/create-branch

## Purpose

Branch creation IS the first implementation act. Code without a branch IS code on the wrong foundation.

## Entry Criteria

- Authorization verified (verify-auth completed)
- Dev branch synced (sync-dev completed)
- Dev base hash available from sync-dev yield

## Procedure

### Step 1: Create Feature Branch (Mode-Dependent)

#### Direct-Branch Mode (DEFAULT — when WORKTREE_REQUIRED is NOT set)

```bash
git checkout -b <branch-name> dev
# or: git switch -c <branch-name> dev
```

Relative paths work directly in direct-branch mode. No worktree path prefixing needed.

#### Worktree Mode (OPT-IN — when WORKTREE_REQUIRED is set or developer requests)

Invoke `using-git-worktrees` skill to create an isolated worktree:

1. Invoke `using-git-worktrees` skill
2. The skill creates: `git worktree add .worktrees/<sanitized-name> -b <branch-name> dev`
3. The skill exports `worktree.path`, `branch`, `DEV_BASE_HASH` as environment variables
4. If `worktree.path` is not set or empty: **FATAL ERROR → FLAG DEV → HALT**

If worktree creation fails or `worktree.fatal=1` is detected, HALT immediately. Do NOT attempt implementation until worktree infrastructure is fixed. There is NO fallback to direct-branch when worktree mode is explicitly requested.

**Branch naming convention** per `115-branch-naming.md`:
- Feature: `feature/<issue-number>-<short-description>`
- Spec: `spec/<issue-number>-<short-description>`
- Pair: `pair-<issue-number>-<short-description>`

**Branch Name to Worktree Name Mapping (Worktree Mode):**

| Branch Name | Worktree Directory |
| -- | -- |
| `feature/<name>` | `.worktrees/feature-<name>/` |
| `spec/<name>` | `.worktrees/spec-<name>/` |

Rule: Replace `/` with `-` in the worktree directory name.

### Step 2: Submodule Initialization and Sync — task() to `submodule-tag-prework`

**If `.gitmodules` does NOT exist:** Skip this step and proceed to Step 3.

**If `.gitmodules` exists:** task() a `submodule-tag-prework` sub-agent with the following boundary context:

**must_receive:**
- `worktree.path` (if in worktree mode; null otherwise)
- `.gitmodules` file path
- `github.owner` and `github.repo` (for context, NOT for API calls)
- `issue_number` (for tag naming: `<parent-repo>/<issue-number>`)

**must_not_receive:**
- Pre-determined file paths, line numbers, or expected SHAs
- The parent's authorization scope or halt_at value
- Orchestrator reasoning about what the sub-agent should find
- Any cached `git submodule status` output
- Any commit messages or summaries from previous syncs
- Tool recipes (e.g., "run `git submodule foreach` then `git log`")

The sub-agent independently:
1. Checks `.gitmodules` existence
2. Initializes submodules if needed (`git submodule init`)
3. Checks out each submodule to its `dev` tip (`git submodule foreach "git checkout dev && git pull"`)
4. Logs submodule status (`git submodule status`)
5. Tags each submodule at dev tip with `<parent-repo>/<issue-number>` format (`git tag -a`)
6. Pushes tags to submodule remote (`git push origin <tag>`)
7. Verifies tags exist on remote (`git ls-remote --tags origin <tag>`)
8. Reports results in its result contract

**If on `main` worktree:** The sub-agent uses `git submodule update --init` (no `--remote`, no `--recursive`) to lock submodules to their committed SHAs. Pass `worktree_type: main` in the task context.

**CRITICAL: Do NOT inline submodule operations.** The orchestrator never runs `git submodule` commands directly. Do NOT use `--recursive` with any git submodule command per `060-tool-usage.md` §4.

**If submodule-tag-prework returns `status: BLOCKED`:** Re-task() with original scoped context. If second task() also fails, report the double-failure and HALT.

### Step 3: Initialize .issues/ Worktree and Issue Directory (MANDATORY)

After branch creation and submodule sync:

1. **Initialize .issues/ worktree:**

   ```bash
   local-issues setup
   ```

   Exit code handling:

   | Exit Code | Meaning | Agent Action |
   |-----------|---------|--------------|
   | 0 | Success — worktree ready | Continue |
   | 1 | Fatal error — retry won't help | HALT and report stderr |
   | 2 | Blocked — stale worktree detected | Remediate: remove stale worktree, retry |

   Exit code 2 remediation: Read stale path from stderr, `git worktree remove <stale_path>`, re-run `local-issues setup`, verify worktree, clean up `.issues.bak`.

2. **Create issue-specific directory:**

   ```bash
   mkdir -p .issues/<issue_number>/
   ```

3. **Fetch spec from API and mirror to `spec.md`:**
   - Call `issue-operations → read-issue (github_issue_read(method="get", owner=<github.owner>, repo=<github.repo>, issue_number=<issue_number>))`
   - Write `.issues/<issue_number>/spec.md` with header `# Synced from GitHub Issue #<issue_number> at <ISO8601-timestamp>` followed by issue body
   - If API unreachable: skip `spec.md` creation

4. **Write initial `state.md`:**

   ```markdown
   # State: Issue #<issue_number>

   **Branch:** <branch-name>
   **Workflow Phase:** pre-work
   **Created:** <ISO8601-timestamp>
   **Last Updated:** <ISO8601-timestamp>
   **Status:** initialized

   ## Current State

   Pre-work initialization complete. Awaiting implementation task().

   ## Blockers

   None.
   ```

5. **Auto-commit `.issues/<issue_number>/`:**

   ```bash
   git add .issues/<issue_number>/spec.md .issues/<issue_number>/state.md
   git commit -m "docs(issues): <issue_number> - spec: mirrored from GitHub Issue #<issue_number>, state: pre-work initialization"
   ```

### Step 4: Verify Branch Environment

```bash
# Verify current branch
git branch --show-current
# MUST show feature branch name (not main, not dev)

# Verify working tree
git status --porcelain
# Report any uncommitted changes
```

**In worktree mode, additionally verify:**

```bash
git rev-parse --show-toplevel
# MUST show worktree path (not main repo path)

echo $WORKTREE_PATH
# MUST NOT be empty — FATAL ERROR if empty
```

If ANY check fails, STOP and report.

### Step 5: Yield Branch State

```yaml
status: success
branch: <branch-name>
worktree_path: <path or null>
direct_branch: true|false
dev_base_hash: <7-char-sha>
working_tree_clean: true|false
ready_for: implementation
```

## 🚫 ZERO TOLERANCE: Branch Before Edit

**The agent MUST create a feature branch BEFORE ANY filesystem change.**

**What Counts as a "Change":**
- Editing any file (code, config, docs, tests)
- Creating new files
- Deleting files
- Renaming files
- Modifying `.gitignore`, `pyproject.toml`, any config
- Updating guidelines in `.opencode/`
- ANY filesystem modification whatsoever
- Using file-editing MCP tools (`pycharm_replace_text_in_file`, `pycharm_create_new_file`, etc.) — these ARE filesystem changes

**NOT filesystem changes:**
- `github_issue_write` → GitHub Issues via issue-operations
- `github_add_issue_comment` → GitHub comments via issue-operations

**Violation = Hard Stop** — create a feature branch first.

## Investigate/ Scratch Branches

Under `for_analysis` scope, the agent may create `investigate/<topic>` scratch branches for read-only investigation. These are NOT feature branches — they are ephemeral throwaway branches.

- `investigate/*` branches are permitted under `for_analysis` scope (self-assigned or explicit)
- The agent MUST NOT make permanent code changes on `investigate/*` branches
- Writes to `./tmp/` and throwaway scripts ARE permitted
- `investigate/` branches MUST be discarded before HALT: `git branch -D investigate/<topic>`
- Creating `feature/*` or `spec/*` branches under `for_analysis` is BLOCKED — requires `for_implementation+`

## Exit Criteria

- Feature branch created from `dev` (not `main`)
- Branch name matches naming convention per `115-branch-naming.md`
- If submodules exist: submodule-tag-prework sub-agent completed
- `.issues/<issue_number>/` directory initialized with `spec.md` and `state.md`
- `.issues/` worktree initialized
- Working tree clean (or uncommitted changes reported)
- `dev_base_hash` recorded
- Branch environment verification passed

## Task Context Rules

- **must_receive**: `authorization_scope`, `issue_number`, `dev_base_hash`, `worktree.path` (if worktree mode)
- **must_not_receive**: Implementation context, expected outcomes, orchestrator reasoning

Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)