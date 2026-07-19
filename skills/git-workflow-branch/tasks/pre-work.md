# Task: pre-work

## Purpose

Create feature branch BEFORE any implementation work begins. Verify authorization, sync the default branch, and set up the working environment. Default mode is direct-branch (feature branch in main repo); worktree mode is opt-in when `WORKTREE_REQUIRED` is set.

## 🚫 ZERO TOLERANCE: Branch Before Edit

**The agent MUST create a feature branch BEFORE ANY filesystem change.**

**Branch creation mode is determined by `WORKTREE_REQUIRED`:**

| Mode | When | Branch Command | Path Behavior |
|------|------|---------------|---------------|
| **Direct-branch (default)** | `WORKTREE_REQUIRED` NOT set | `git checkout -b feature/X` or `git switch -c feature/X` | Relative paths work directly |
| **Worktree (opt-in)** | `WORKTREE_REQUIRED` set or developer request | `git worktree add .worktrees/feature-X -b feature/X "$DEFAULT_BRANCH"` | All paths prefixed with `worktree.path` |

**In both modes, the agent MUST NOT commit to `main` or `$DEFAULT_BRANCH`.** This is a Tier 1 (Non-Yielding) mandate.

This is the FIRST and MOST CRITICAL rule. Before writing any code, editing any file, creating any file, or making ANY change to the project:

- [ ] 1. **Verify on a feature branch** (NOT `main` or `$DEFAULT_BRANCH`) — either direct-branch or worktree
- [ ] 2. **All work happens on the feature branch** — never on `main` or `$DEFAULT_BRANCH`
- [ ] 3. **ONLY THEN**: Proceed with file changes

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
- `github_issue_write` → GitHub Issues via issue-operations, NOT local files → NOT a filesystem change <!-- Routes through issue-operations per SPEC #683 -->
- `issue-operations -> comment (github_add_issue_comment` → GitHub comments → NOT a filesystem change <!-- Routes through issue-operations per SPEC #683 -->

**Violation = Hard Stop**

- If you catch yourself about to edit files while on `main` or `$DEFAULT_BRANCH`, STOP immediately
- Create a feature branch first (direct-branch or worktree based on `WORKTREE_REQUIRED`)
- Never proceed past this checkpoint without an active feature branch

## Operating Protocol

- [ ] 1. **Mandatory call (no decision point):** The agent MUST call this task when:
   - User says `approved`, `go`, or similar authorization to begin implementation
    - DO NOT prompt — call the skill directly

## Entry Criteria

- User has authorized implementation (explicit `approved` or `go`)
- Authorization is for the correct issue
- Sub-issue structure verified (for multi-task specs)

## Branch Workflow Context

**Branch Model:**

- **Feature branches** (`feature/*` or `spec/*`): Branch from the default branch, merge to target branch
- **Main branches** (`main` or `master`): Production-ready code

**AI Commit Restrictions:**

- AI cannot commit to `main`, `master`, or `$DEFAULT_BRANCH` (blocked by git hooks)
- AI must create feature branches from the default branch
- AI must sync with the default branch before creating feature branch

## Procedure

### Step 0: Trunk-Tip Verification (**sub-agent**)

**Mandatory first step before any work begins.** Verify the repository is at a clean trunk-tip state:

- [ ] 0. **Trunk-tip verification (**sub-agent**).** `task(..., prompt: "execute trunk-tip-verification from git-workflow-branch")`. If BLOCKED, HALT with blocker report. Do NOT proceed to branch creation.

### Step 1: Verify Authorization Context

**This task receives authorization context from orchestration layer. DO NOT re-check authorization.**

### Step 2: Sync Default Branch

The working tree must be on the default branch and up-to-date so branch creation has the correct base:

```bash
DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
if [ -z "$DEFAULT_BRANCH" ]; then
    DEFAULT_BRANCH="main"
fi

git fetch origin
git checkout "$DEFAULT_BRANCH"
git pull origin "$DEFAULT_BRANCH"
```

### Step 2.1: Rebase Before Branch Creation

Before creating the feature branch, rebase the working tree on the latest target branch to ensure a clean base:

```bash
git fetch origin "$DEFAULT_BRANCH"
git rebase origin/"$DEFAULT_BRANCH"
```

### Step 2.5: Proactive Repo State Verification

**Before creating any feature branch, verify repo state:**
- [ ] 1. **Submodule initialization check:** Run glob scan to detect git repos: `REPO_PATHS=$(ls -d .git/ */.git/ */.git 2>/dev/null | sed 's|/\.git$||' | sed 's|/$||')`. If non-root repos found, note that submodule sync will be handled by a standard sub-agent task() in Steps 2.7/3.5 — do NOT run submodule commands inline.

- [ ] 2. **Submodule currency check:** Deferred to the sub-agent task() (Steps 2.7/3.5).
- [ ] 3. **Fresh clone handling:** After `git clone`, the dev parking protocol must be task()ed to a sub-agent — do NOT run `git submodule init` or `git submodule foreach` inline.

### Step 2.7: Automatic Prerequisite Operations

**⚠️ When authorization has been verified (approval-gate `verify-authorization` passed), the following git operations are AUTOMATIC prerequisites that MUST be performed WITHOUT soliciting developer confirmation.**

These operations are deterministic, mechanical steps that are either Tier 1 mandates (required by guidelines) or pipeline prerequisites (necessary for the authorized scope). They require NO judgment from the agent or the developer.

| Operation | Step | Classification | Condition |
|-----------|------|----------------|-----------|
| `git fetch origin` | Step 1.5/2 | Pipeline prerequisite | Remote exists |
| `git checkout "$DEFAULT_BRANCH" && git pull origin "$DEFAULT_BRANCH"` | Step 2 | Tier 1 mandate prerequisite | Always when remote exists |
| Task() sub-agent for submodule ops | Step 2.5/3 | Tier 1 mandate prerequisite | Submodules detected via glob scan |
| `git checkout -b feature/N-xyz` or `git switch -c feature/N-xyz` | Step 4 | Tier 1 mandate — required by Load [Skipping Git Pre-Check](guidelines/000-critical-rules.md) | Always |
| `git push -u origin feature/N-xyz` | Post-Step 6 | Pipeline prerequisite for `for_pr` scope | Remote exists, `halt_at >= pr_created` |

**Automatic classification conditions (ALL must be true):**

- [ ] 1. Authorization has been verified — `approval-gate --task verify-authorization` passed
- [ ] 2. The operation is a Tier 1 mandate or a deterministic prerequisite for authorized work
- [ ] 3. The operation requires no judgment — it is a deterministic, mechanical step
- [ ] 4. The scope covers the pipeline stage containing the operation (`for_pr`, `for_implementation`, `for_review_prep`)

**🚫 FORBIDDEN: Soliciting developer confirmation for automatic prerequisites:**

- "Should I sync the submodule?" → FORBIDDEN — submodule sync is automatic
- "May I create the feature branch?" → FORBIDDEN — branch creation is a Tier 1 mandate
- "Ready to proceed with git push?" → FORBIDDEN — initial push is a pipeline prerequisite
- "Proceed with pre-work?" → FORBIDDEN — pre-work is mandatory after authorization
- Any confirmation request for operations in the table above → FORBIDDEN

**✅ REQUIRED: Proceed autonomously through all pre-work steps once authorization is verified.**

The agent MUST NOT ask for confirmation, permission, or readiness before performing any operation listed in the table above. These are mechanical prerequisites that the agent MUST execute as part of the approved workflow.

**See also:** Load [Pushing Agent Intelligence Decisions to the User](guidelines/000-critical-rules.md) — whether to sync a submodule, create a branch, or push is NOT a decision requiring user input when authorization covers the pipeline stage.

### Sub-Agent Boundary: Submodule Operations — Orchestrator Dispatch

When submodules are detected via glob scan, the orchestrator dispatches a sub-agent via `task(subagent_type="general")` for submodule initialization, sync, and status operations. The sub-agent receives only:

**`must_receive`:**
- `worktree.path` (if in worktree mode; null otherwise)
- `submodule_paths` — list of discovered repo paths
- `github.owner` and `github.repo` (for context, NOT for API calls into the parent repo)

**`must_not_receive`:**
- Any pre-determined file paths, line numbers, or expected SHAs
- The parent's authorization scope or halt_at value
- Orchestrator reasoning about what the sub-agent should find
- Any cached `git submodule status` output
- Any commit messages or summaries from previous syncs
- Tool recipes (e.g., "run `git submodule foreach` then `git log`")

🚫 **FORBIDDEN:** Pre-loading the sub-agent with expected SHA values, expected commit counts, expected log summaries, or any orchestrator analysis of what changed. The sub-agent independently discovers submodule state.

### Step 3: Submodule Work — All Submodule Operations Complete Before Main Repo Work Begins

**All submodule work completes before any main repo work.** The main repo's submodule pointer is a committed SHA — syncing submodules to trunk tip updates the submodule working tree but does NOT update the main repo's gitlink entry. The main repo feature branch must be created AFTER the submodule pointer is updated to the tagged SHA.

**If no submodules detected via glob scan:** Skip this step and proceed to Step 4.

**If submodules detected:** The orchestrator dispatches a sub-agent via `task(subagent_type="general")` with the boundary context defined in the Sub-Agent Boundary section above. The sub-agent independently:

- [ ] 1. Detects the submodule path(s)
- [ ] 2. Initializes submodules if needed (`git submodule init`)
- [ ] 3. Resolves the trunk branch via `DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')` and checks out each submodule to trunk tip (`git submodule foreach "git checkout \"$DEFAULT_BRANCH\" && git pull origin \"$DEFAULT_BRANCH\" --ff-only"`)
   - **HALT on failure:** If `git pull --ff-only` fails (non-ff or network error), the sub-agent MUST produce a structured divergence report. Do NOT fall back to merge or rebase — `--ff-only` is a hard gate that prevents accidental divergence from trunk.
   - **Autonomous divergence handling (MANDATORY):** On `--ff-only` failure, the agent autonomously analyzes the divergence and attempts resolution:
     ```bash
     SUBMODULE_PATH="<path>"
     DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
     AHEAD=$(git rev-list --count "origin/$DEFAULT_BRANCH..$DEFAULT_BRANCH" 2>/dev/null || echo "unknown")
     BEHIND=$(git rev-list --count "$DEFAULT_BRANCH..origin/$DEFAULT_BRANCH" 2>/dev/null || echo "unknown")
     echo "DIVERGENCE DETECTED: Submodule at $SUBMODULE_PATH"
     echo "  Ahead by $AHEAD commits (local changes not on origin/$DEFAULT_BRANCH)"
     echo "  Behind by $BEHIND commits (origin/$DEFAULT_BRANCH changes not in local $DEFAULT_BRANCH)"
     # Autonomous resolution attempt:
     if [ "$AHEAD" = "0" ] && [ "$BEHIND" != "0" ] && [ "$BEHIND" != "unknown" ]; then
       # Only behind — safe to fast-forward
       git pull origin "$DEFAULT_BRANCH"
     elif [ "$AHEAD" != "0" ] && [ "$AHEAD" != "unknown" ] && [ "$BEHIND" = "0" ]; then
       # Only ahead — local changes not pushed, push them
       git push origin "$DEFAULT_BRANCH"
     elif [ "$AHEAD" != "0" ] && [ "$BEHIND" != "0" ] && [ "$AHEAD" != "unknown" ] && [ "$BEHIND" != "unknown" ]; then
       # Both ahead and behind — semantic analysis needed
       # Attempt rebase first (safe for linear history)
       if git rebase "origin/$DEFAULT_BRANCH" 2>/dev/null; then
         echo "Autonomous rebase successful — divergence resolved."
       else
         echo "Autonomous rebase failed — semantic conflict detected."
         echo "HALT: Developer consultation required — divergence cannot be auto-resolved."
         echo "  Suggested resolution:"
         echo "    - Review and resolve rebase conflicts manually"
         echo "    - If local changes should be discarded: git reset --hard origin/$DEFAULT_BRANCH"
       fi
     else
       echo "HALT: Developer consultation required — divergence cannot be auto-resolved."
       echo "  Suggested resolution:"
       echo "    - If local changes are intentional: git push origin $DEFAULT_BRANCH"
       echo "    - If local changes should be discarded: git reset --hard origin/$DEFAULT_BRANCH"
       echo "    - If local changes should be rebased: git rebase origin/$DEFAULT_BRANCH"
     fi
     ```
   - **Result contract on divergence:**
     ```yaml
     status: DONE | BLOCKED
     reason: SUBMODULE_FF_FAILURE | SUBMODULE_DIVERGENCE_RESOLVED
     submodule_path: "<path>"
     ahead: <N>
     behind: <N>
     resolution: "autonomous_push | autonomous_rebase | escalated"
     ```
- [ ] 4. Logs submodule status (`git submodule status`)
- [ ] 5. Tags each submodule at dev tip with `<parent-repo>/<issue-number>` format (`git tag -a`)
- [ ] 6. Pushes tags to submodule remote (`git push origin <tag>`)
- [ ] 7. Verifies tags exist on remote (`git ls-remote --tags origin <tag>`)
- [ ] 8. Creates feature branch in each submodule from the tagged commit:
     - For each submodule, check if a feature branch already exists: `git branch --list feature/<issue-number>-*`
     - If branch exists: rebase it onto the tagged commit to pick up the latest trunk changes:
       ```bash
       git checkout feature/<issue-number>-<slug>
       git rebase <parent-repo>/<issue-number>
       ```
       This ensures the submodule branch is up-to-date with the tagged SHA that the main repo now references. Do NOT skip — a stale submodule branch recreates the pointer mismatch.
     - If branch does not exist: create feature branch from the tagged commit:
       ```bash
       git checkout -b feature/<issue-number>-<slug> <parent-repo>/<issue-number>
       ```
     - Push the feature branch to the submodule remote: `git push -u origin feature/<issue-number>-<slug>`
- [ ] 9. Reports results in its result contract

**The orchestrator receives a result contract containing:**

```yaml
status: DONE | BLOCKED
submodules_found: <count>
submodules_updated: <list of (path, old_sha, new_sha, commit_count)>
submodule_branches_created: <list of (path, branch_name, tag_used)>
submodule_branches_skipped: <list of (path, branch_name, reason)>
```

**If `status: BLOCKED`** (e.g., submodule checkout fails): Re-task() with original scoped context. If second task() also fails, report the double-failure and HALT.

**If on `main` worktree:** The sub-agent uses `git submodule update --init` (no `--remote`) to lock submodules to their committed SHAs instead of advancing to dev tip. Pass `worktree_type: main` in the task context.

**Do NOT inline the submodule operations.** The orchestrator never runs `git submodule` commands or reads submodule logs directly.

### Step 4: Update Main Repo Submodule Pointer and Create Feature Branch

**Main repo work starts AFTER all submodule work is complete.** The submodule pointer must be updated to the tagged SHA before the feature branch is created, so the branch captures the correct pointer.

- [ ] 1. **Update submodule pointer:** For each submodule, stage the updated gitlink entry:
     ```bash
     git add <submodule-path>
     ```
- [ ] 2. **Create feature branch** (mode-dependent):

#### Direct-Branch Mode (DEFAULT — when WORKTREE_REQUIRED is NOT set)

```bash
git checkout -b <branch-name> "$DEFAULT_BRANCH"
# or: git switch -c <branch-name> "$DEFAULT_BRANCH"
```

**Relative paths work directly in direct-branch mode.** No worktree path prefixing needed.

#### Worktree Mode (OPT-IN — when WORKTREE_REQUIRED is set or developer requests)

Invoke `using-git-worktrees` skill to create an isolated worktree:

- [ ] 1. Invoke `using-git-worktrees` skill
- [ ] 2. The skill creates the worktree: `git worktree add .worktrees/<sanitized-name> -b <branch-name> "$DEFAULT_BRANCH"`
- [ ] 3. The skill exports `worktree.path`, `branch`, `BASE_HASH` as environment variables
- [ ] 4. If `worktree.path` is not set or empty: **FATAL ERROR → FLAG DEV → HALT**

**If worktree creation fails or `worktree.fatal=1` is detected:**

- HALT immediately
- Report the fatal error to the developer
- Do NOT attempt any implementation until the worktree infrastructure is fixed
- There is NO fallback to direct-branch when worktree mode is explicitly requested

- [ ] 3. **Commit the submodule pointer update as the first commit on the feature branch:**
     ```bash
     git commit -m "chore: update submodule pointer to <parent-repo>/<issue-number> tag"
     ```
     This ensures the feature branch's first commit captures the correct submodule SHA. Subsequent implementation commits build on this foundation.

**⚠️ CRITICAL: No-Op Branch Guard**

After committing the submodule pointer, if the branch has NO additional commits with source code changes by the time PR creation is requested, the branch MUST be deleted instead of creating a PR:

```bash
# Before PR creation, verify branch has non-submodule changes
NON_SUBMODULE_COMMITS=$(git log origin/"$DEFAULT_BRANCH"..HEAD --oneline --name-only | grep -v '^[0-9a-f]\{7\} ' | grep -v '^$' | grep -v '^\.opencode$' | wc -l)
if [ "$NON_SUBMODULE_COMMITS" -eq 0 ]; then
  echo "HARD BLOCK: Branch has only submodule pointer changes."
  echo "Delete this branch: git checkout \"$DEFAULT_BRANCH\" && git branch -D <branch>"
  echo "Do NOT create a PR. Submodule-only PRs are against policy."
  exit 1
fi
```

**After branch creation and pointer commit:**

```bash
# Verify branch
git branch --show-current
# MUST show the feature branch name

# Verify working tree
git status --porcelain
# Report any uncommitted changes
```

### Step 5: Verify Branch Environment

**Before yielding back to orchestration layer, verify:**

```bash
# Verify current branch
git branch --show-current
# MUST show the feature branch name (not main, not $DEFAULT_BRANCH)

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

### Step 6: Report Ready

**Direct-branch mode:**

Report: "Ready for implementation on branch: <branch-name> (direct-branch)"

```yaml
status: success
branch: <branch-name>
worktree_path: null
direct_branch: true
base_hash: <7-char-sha>
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
base_hash: <7-char-sha>
working_tree_clean: true
ready_for: implementation
```

## `observe/` Scratch Branches

Under `for_analysis` scope, the agent may create `observe/<topic>` scratch branches for read-only investigation. These are NOT feature branches — they are ephemeral throwaway branches.

### When to Use

- Investigating a bug hypothesis
- Running throwaway scripts to examine data
- Testing a refactoring idea without committing
- Exploring file structure in a clean context

### Naming Convention

```bash
git checkout -b observe/<topic> "$DEFAULT_BRANCH"
```

Examples: `observe/parsing-bug`, `observe/missing-env-var`, `observe/test-failure-root-cause`

### Scope Gate

- `observe/*` branches are permitted under `for_analysis` scope (self-assigned or explicit)
- `observe/*` branches do NOT require `for_implementation` — they are read-only scratch branches
- The agent MUST NOT make permanent code changes on `observe/*` branches
- Writes to `{project_root}/tmp/` and throwaway scripts ARE permitted

### MUST Discard Before HALT

**🚫 CRITICAL: `observe/` branches MUST be discarded before the halt message.**

```bash
git branch -D observe/<topic>
```

This is a hard requirement — leaving `observe/` branches in the repo pollutes branch space. The enforcement in `enforcement/halt-conditions.md` verifies this.

### `feature/` and `spec/` Branch Scope Gate

Creating `feature/*` or `spec/*` branches requires `for_implementation` scope or above. Under `for_analysis`, these branches are BLOCKED:

```bash
# 🚫 FORBIDDEN under for_analysis
git checkout -b feature/123-xyz "$DEFAULT_BRANCH"  # Requires for_implementation+

# ✅ PERMITTED under for_analysis
git checkout -b observe/parsing-bug "$DEFAULT_BRANCH"  # Read-only scratch branch
```

If the agent attempts to create a `feature/` or `spec/` branch under `for_analysis`, the operation MUST be rejected and reported as a scope boundary violation.

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Task Context Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Context Received from Orchestration Layer

**Input context from `implementation-pipeline`:**

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
    base_hash: "<7-char-sha>"
working_tree_clean: true
ready_for: "implementation"
```

The orchestration layer (`implementation-pipeline`) receives this yield and passes relevant context to the implementation subagent.

## ⚠️ Edge Case: Already Implemented (No Changes Needed)

**When investigation reveals spec is already implemented:**

- [ ] 1. **Detect before branch creation:**

   - After reading files, verify all proposed changes are already present
   - Confirm no modifications needed
   - Document verification in issue comment

- [ ] 2. **Skip branch creation entirely:**

   - Do NOT create feature branch
   - Do NOT push anything
   - Do NOT create PR

- [ ] 3. **Close issue directly:**

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

- [ ] 4. **HALT after closing:**
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

- [ ] 1. Create a feature branch: `git checkout -b hotfix/urgent-fix "$DEFAULT_BRANCH"`
- [ ] 2. Make your changes and commit
- [ ] 3. Push and create PR with `hotfix` label
- [ ] 4. Request expedited review

## Live Verification (MANDATORY)

**🚫 CRITICAL: Each verification point requires a tool call for evidence. Assertions without tool-call artifacts are VERIFICATION-GAP findings.**

### Branch State Verification

| Check | Tool Call | Expected Result | On Failure |
| -- | -- | -- | -- |
| Default branch synced (when remote exists) | `git ls-remote origin "$DEFAULT_BRANCH"` | Non-empty output | MISSING-ELEMENT → fetch and sync |
| Current branch | `git branch --show-current` | Feature branch name (not the trunk) | STRUCTURE-VIOLATION → HALT |
| Working tree clean | `git status --porcelain` | Empty output | VERIFICATION-GAP → stash or commit first |
| Worktree location (worktree mode only) | `git rev-parse --show-toplevel` | Worktree path (not main repo path) | STRUCTURE-VIOLATION → HALT |
| worktree.path set (worktree mode only) | `echo $WORKTREE_PATH` | Non-empty, matches worktree dir | STRUCTURE-VIOLATION → HALT (fatal) |
| Base hash | `git rev-parse --short "$DEFAULT_BRANCH"` | Valid 7-char SHA | MISSING-ELEMENT → sync default branch first |

### Verification Procedure

**After Step 5 (Verify Branch Environment), run these verifications and record evidence:**

```
1. git branch --show-current → EVIDENCE: <branch-name>
2. git status --porcelain → EVIDENCE: <output or "(empty)">
3. (worktree mode only) git rev-parse --show-toplevel → EVIDENCE: <path>
4. (worktree mode only) worktree.path → EVIDENCE: <path or "(empty)">
```

**Classification on failure:**

| Failure | Problem Class | Classification | Action |
| -- | -- | -- | -- |
| Default branch not synced | MISSING-ELEMENT | auto-fix | Run `git fetch origin "$DEFAULT_BRANCH"` |
| On `main` or `$DEFAULT_BRANCH` branch | CONFLICTING | FAIL | HALT — must create feature branch first |
| Dirty working tree | VERIFICATION-GAP | FAIL | Stash or commit before implementation |
| `rev-parse` returns main repo path (worktree mode) | STRUCTURE-VIOLATION | auto-fix | Not in worktree — re-invoke using-git-worktrees |
| worktree.path empty (worktree mode) | STRUCTURE-VIOLATION | auto-fix | FATAL — cannot safely do file operations |
| base hash stale | MISSING-ELEMENT | FAIL | Re-run `git pull origin "$DEFAULT_BRANCH"` |

**These verifications are MANDATORY. Skipping them is a CRITICAL GUIDELINE VIOLATION.**

## Context Required

- Related skills: `approval-gate` (authorization check), `using-git-worktrees` (worktree creation, opt-in only)
- Related tasks: `cleanup` (branch cleanup after PR merge)

## Enforcement Checklist

**Before starting any work, verify:**

- ✅ Authorization received (explicit `approved`, `go`, or `"#N approved"`)
- ✅ Feature branch created (not on `main` or `$DEFAULT_BRANCH`)
- ✅ (Worktree mode only) `worktree.path` environment variable is set and non-empty
- ✅ (Worktree mode only) `git rev-parse --show-toplevel` in worktree shows worktree path
- ✅ `git branch --show-current` shows feature branch
- ✅ Feature branch created from the default branch

**These checks are MANDATORY. If ANY check fails → STOP and report.**