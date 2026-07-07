# Task: pr-creation/enforcement-gate

## Purpose

Enforce mandatory pre-conditions before PR creation. Verify explicit PR instruction, review-prep completion, and branch push status.

## Default Branch Resolution

```bash
DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
if [ -z "$DEFAULT_BRANCH" ]; then DEFAULT_BRANCH="main"; fi
```

## Entry Criteria

- Implementation is complete
- Developer may have said "create a PR" or similar

## Exit Criteria

- All enforcement gates pass
- PR creation is authorized to proceed

## Procedure

### Step 0: Submodule PR Dependency Check (MANDATORY GATE)

**If no submodules detected via glob scan:** Skip entirely.

**If submodules detected:**

The orchestrator dispatches a sub-agent via `task(subagent_type="general")`. The sub-agent performs a report-only liveness verification — it compares committed SHAs against remote `dev` HEAD SHAs and returns PASS/FAIL per submodule. **NO auto-remediation. NO SHA bumps. NO commits.**

#### Task Context

```yaml
must_receive:
  - github.owner
  - github.repo
  - github.platform
  - branch (current working branch)
must_not_receive:
  - Any pre-determined SHA values or expected outcomes
  - Any orchestrator reasoning about which submodules should pass/fail
  - Any tool recipes, inline commands, or expected line numbers
```

#### Result Contract Schema

```yaml
status: DONE | BLOCKED
submodule_checks:
  - path: <submodule_path>
    committed_sha: <sha>
    remote_dev_sha: <sha>
    result: PASS | FAIL
    detail: <optional explanation>
summary: <text>
```

**PASS →** Proceed to Step 0.5.
**FAIL →** BLOCK PR creation. Report which submodules failed, with both SHAs. Do NOT create the PR. Do NOT auto-remediate. The developer must resolve submodule SHA mismatches manually.

**There is NO `--force` override for submodule dependency gates.**

### Step 0.5: Submodule-Bump-Only PR Gate (MANDATORY — parent repo only)

**If `identity_source` is NOT `root` or no submodules detected via glob scan:** Skip entirely.

**If parent repo context (`identity_source == "root"` AND submodules detected):**

Check if the PR diff is submodule-pointer-only:

```bash
CHANGED=$(git diff --stat "$DEFAULT_BRANCH"...HEAD | tail -1 | grep -oP '\d+ file' | grep -oP '\d+')
SUBMODULE_ONLY=$(git diff --stat "$DEFAULT_BRANCH"...HEAD | grep -c '\.opencode')
if [ "$CHANGED" = "1" ] && [ "$SUBMODULE_ONLY" = "1" ]; then
  echo "BLOCKED: Submodule-bump-only PRs are prohibited."
  echo ""
  echo "Creating a parent repo PR that only updates the submodule SHA is"
  echo "a guideline violation. The submodule SHA was already updated by"
  echo "the submodule PR merge. Close this branch with a comment:"
  echo ""
  echo "  'Submodule SHA already updated by submodule PR merge. No parent PR needed.'"
  echo ""
  echo "Then delete the branch and close any associated issue with"
  echo "state_reason=completed."
```
- **If only `.opencode` changed → BLOCK.** Do NOT create the parent PR. Close branch, comment, and halt.
- **If >1 file or non-submodule files changed → PASS.** Proceed to Step 1.

**AUTHORITY:** `adversarial-audit --task spec-audit` auto-fix model, `000-critical-rules.md` §Implementation Without Spec (audit auto-fix exemption). Spec #414 Part 2 — prohibit submodule-bump-only parent PRs.

### Step 1: Verify PR Instruction (MANDATORY)

**If ANY check fails → STOP and report. DO NOT proceed.**

| Check | Requirement |
| -- | -- |
| Explicit PR instruction | "create a PR", "make a PR", "push and create PR", "let's get a PR up" |
| review-prep completed | Compare URL was generated and reported |
| Branch pushed to remote | `git branch -vv` shows `[origin/branch]` |

**What does NOT authorize PR creation (HALT):**

| Phrase | Reason |
| -- | -- |
| "approved" | Authorizes implementation ONLY, NOT PR creation |
| "go" | Authorizes implementation ONLY, NOT PR creation |
| Implementation complete | Does NOT authorize PR |
| "continue" | Ambiguous — could mean next phase |

### Step 1.2: Commit Count Verification (MANDATORY GATE)

**This gate enforces the commit-per-issue invariant.** Creating a PR with an incorrect commit count is a CRITICAL GUIDELINE VIOLATION per `000-critical-rules.md` §Un-Squashed PR.

```bash
# Count commits ahead of dev
git log origin/"$DEFAULT_BRANCH"..HEAD --oneline

# Detect branch type via work state file
ls {project_root}/tmp/{issue-N}/work.md 2>/dev/null
```

**Branch type detection and enforcement:**

| Branch Type | Detection | Expected Commits | On Mismatch |
| -- | -- | -- | -- |
| **Single-issue** | No `work-*.md` file found | **Exactly 1** | HALT — squash required via `pr-creation/squash-push.md` Step 3 |
| **Work branch** | `work-*.md` file exists | **N** (N = work items in state) | HALT — verify commit count matches work state items |

**Single-issue branch with >1 commit:**

1. HALT — DO NOT proceed to PR creation
2. Squash per `pr-creation/squash-push.md` Step 3:
   ```bash
   git reset --soft origin/"$DEFAULT_BRANCH"
   git commit -m "<descriptive message>" \
       --trailer "Co-authored-by: <AgentName> (<ModelId>) <ai-email>" \
       --trailer "Co-authored-by: <dev.name> <dev.email>"
   git push --force-with-lease origin <branch>
   ```
3. Re-verify commit count after squash
4. Only then proceed to Step 1.5

**Work branch with mismatched commit count:**

1. HALT — verify work state file item count matches actual commits
2. If under-committed: check for missing implementation items
3. If over-committed: squash extraneous commits per item boundaries
4. Re-verify before proceeding

**AUTHORITY:** `000-critical-rules.md` §Un-Squashed PR, `pr-creation/squash-push.md` Step 3

### Step 1.5: Check Existing PR State

Query GitHub API for **open** PRs on this branch using `state=open` filter:

```bash
# Query ONLY open PRs — never query all PRs
gh pr list --head <branch_name> --state open --json number,html_url
```

**If an OPEN PR exists on this branch:**
- Update existing PR (push new commits)
- This is the correct behavior — an open PR is in-flight work

**If NO open PR exists (but a closed PR exists on the branch):**
- **Do NOT re-open the closed PR.**
- **Create a new PR.**
- A closed (unmerged) PR is an indicator that the previous attempt was defective — the developer closed it. Do not re-use defective code.
- The developer must explicitly say "use the closed PR" for it to be considered.

**If a MERGED PR exists on this branch:**
- Rebase branch on dev, check for remaining changes
- If branch already merged (no remaining changes):
  ```
  ✅ BRANCH ALREADY MERGED
  The branch '{branch_name}' has already been merged via PR #{pr_number}.
  No new PR needed.
  ```

**Developer override:**
- If the developer explicitly says "use the closed PR" or equivalent, consider the closed PR.
- Without explicit instruction, always create a new PR when no open PR exists.

### Step 1.5d: Merge Conflict Detection

For OPEN PRs, check `mergeable` attribute:
- `True` / `"clean"` → Proceed
- `False` / `"dirty"` → Classify and resolve conflicts per `conflict-resolution` skill
- `None` / `"unknown"` → Wait and retry, or check locally

**For AI-objective conflicts (imports, whitespace, additive):** Auto-resolve.
**For AI-subjective conflicts (logical, architectural, intent):** HALT and request developer input.

## Enforcement Mechanisms

| Layer | Mechanism | Scope | Bypassable? |
| -- | -- | -- | -- |
| Local | `.opencode/hooks/pre-commit` | Blocks commit to main/master/dev | No |
| Local | `.opencode/hooks/post-commit` | Warns after commit to main/master/dev | N/A (post) |
| GitBucket | Branch protection rules | Requires PR for dev/main | No |

## Context Required

- Related tasks: `pr-creation/squash-push`, `pr-creation/create-pr`
- Related skills: `conflict-resolution`