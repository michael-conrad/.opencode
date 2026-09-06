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

**If no submodules detected via `git submodule status`:** Skip entirely.

**If submodules detected:**

The dispatches a sub-agent via `task(subagent_type="general")`. The sub-agent performs a report-only verification — (a) liveness: compares committed SHAs against remote trunk HEAD SHAs, and (b) **merged-commit reachability**: for each committed submodule gitlink SHA, verifies it is an ancestor of the submodule's remote `origin/$DEFAULT_BRANCH` via `git merge-base --is-ancestor`. Returns PASS/FAIL per submodule. **NO auto-remediation. NO SHA bumps. NO commits.**

**Merged-commit reachability check:** A committed gitlink SHA that references a local-only (unmerged) commit means the submodule's own PR has not been merged — the build system would resolve the pointer to a commit that does not exist on the remote. For each submodule, resolve `$DEFAULT_BRANCH`, fetch `origin`, and run:

```bash
DEFAULT_BRANCH=$(git -C <submodule_path> remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
if [ -z "$DEFAULT_BRANCH" ]; then DEFAULT_BRANCH="main"; fi
git -C <submodule_path> fetch origin "$DEFAULT_BRANCH"
git -C <submodule_path> merge-base --is-ancestor <committed_gitlink_sha> origin/$DEFAULT_BRANCH
```

On exit code `0` (ancestor): the pointer is merged — proceed. On non-zero exit (local-only commit): block PR creation with `SUBMODULE_PR_MISSING`.

**Fail open on network error:** If the fetch or merge-base command fails because the remote is unreachable, do NOT block — warn and continue. Network flakiness must never block PR creation.

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
    merged: PASS | FAIL | SKIP
    result: PASS | FAIL
    detail: <optional explanation>
summary: <text>
```

**PASS →** Proceed to Step 0.5.
**FAIL →** BLOCK PR creation. Report which submodules failed, with both SHAs. If the failure is a local-only pointer (`merged: FAIL`), block with `SUBMODULE_PR_MISSING` — the committed gitlink SHA references an unmerged commit that must be merged to `origin/$DEFAULT_BRANCH` first. Do NOT create the PR. Do NOT auto-remediate. The developer must resolve submodule SHA mismatches manually.

**There is NO `--force` override for submodule dependency gates.**

### Step 0.5: Submodule-Bump-Only PR Gate (MANDATORY — parent repo only)

**If `identity_source` is NOT `root` or no submodules detected via `git submodule status`:** Skip entirely.

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
  echo "Note: the submodule PR merge does NOT resolve the parent repo's"
  echo "submodule pointer. The root pointer is NOT dropped — it remains"
  echo "dirty and rides ALONGSIDE the next real root-repo change on a"
  echo "feature branch. It is never committed in a standalone pointer-only"
  echo "commit/PR."
  echo ""
  echo "Then delete the branch and close any associated issue with"
  echo "state_reason=completed."
```
- **If only `.opencode` changed → BLOCK.** Do NOT create the parent PR. Close branch, comment, and halt.
- **If >1 file or non-submodule files changed → PASS.** Proceed to Step 1.

**AUTHORITY:** `audit --task spec-audit` auto-fix model, `000-critical-rules.md` §Implementation Without Spec (audit auto-fix exemption). Spec #414 Part 2 — prohibit submodule-bump-only parent PRs.

### Step 0.75: Ordering Gate — In-Scope Submodule Set Enumeration (MANDATORY GATE)

This step is the first condition of the stacked-PR ordering gate, evaluated immediately before parent stacked PR creation. Enumeration precedes merge verification: the in-scope submodule set MUST be enumerated before any merge-state verification runs, and merge verification operates only on the enumerated set.

**If no submodules detected via `git submodule status`:** Skip entirely.

Enumerate the in-scope submodule set from changed submodule paths relative to the trunk base — a submodule is in scope when its gitlink changed on the parent feature branch relative to `$DEFAULT_BRANCH`:

```bash
IN_SCOPE_SUBMODULES=$(git submodule status | awk '{print $2}' | while read -r sub; do
    if ! git diff --quiet "$DEFAULT_BRANCH"...HEAD -- "$sub"; then
        echo "$sub"
    fi
done)
```

- Each in-scope entry is a changed submodule path relative to the trunk base (`$DEFAULT_BRANCH` per Default Branch Resolution).
- An empty result means no in-scope submodule set exists — record the skip explicitly (ordering gate has no submodule set to verify) and proceed. The skip is explicit, not a silent pass.

#### Merge-State Blocking Condition (MANDATORY)

For each in-scope submodule enumerated above, the stacked-PR procedure requires the submodule's PR to be merged before the parent stacked PR is created. Merge state is verified via a live platform API call using the merge-state fields — never inferred from local checkout state or git merge-base ancestry:

```bash
# Live-API merge-state verification per in-scope submodule PR (GitHub examples)
gh api repos/<owner>/<submodule_repo>/pulls/<pr_number> --jq '{state: .state, merged: .merged, merged_at: .merged_at}'
# or: gh pr view <pr_number> --repo <owner>/<submodule_repo> --json state,mergedAt
```

The `merged` / `merged_at` fields from the platform pulls API (or `state` / `mergedAt` from `gh pr view --json`) are the authoritative merge-state fields. The merge state is never inferred from local checkout state or git merge-base ancestry: the checked-out submodule, its local branches, and parent-side `git merge-base --is-ancestor` ancestry are NOT substitutes for the live-API merge-state answer. The Step 0 merged-commit reachability check (fail-open on network error) and this ordering-gate merge-state verification are separate checks with separate failure categories — ancestry staleness (stale pointer) is not an unmerged PR, and live-API verification with the merge-state fields is the only accepted merge-state source here.

- **Bounded retry on inconclusive merge state (fail-closed).** When the live-API merge-state fields return an inconclusive state (`merged`/`merged_at` absent or not yet reported — e.g., the platform has not computed merge state yet), probe again: the gate performs up to **3 probes** at **60-second intervals**. Each probe re-runs the same live-API merge-state verification. If a probe resolves to a definite merged or unmerged answer, proceed with that answer (an unmerged answer blocks per the unmerged-PR rule below). If all 3 probes at 60-second intervals are exhausted and the state is still inconclusive, **BLOCK**: report the inconclusive state with a clear reason **in chat**, naming the inconclusive submodule and its PR. Do NOT create the parent PR. Do NOT auto-remediate. This bounded-retry/report path is fail-closed: exhausted probes resolve to a block, never to a pass.
- **Unmerged in-scope submodule PR → BLOCK.** While any in-scope submodule PR is unmerged, parent stacked PR creation is blocked. Do NOT create the parent PR. Do NOT auto-remediate. Report the block naming the submodule and its open PR, then halt.
- The merge-state blocking condition applies only to the enumerated in-scope set. An empty in-scope set means no submodule PR can block — recorded with the enumeration skip above.

**AUTHORITY:** Spec `.opencode/.issues/2431/spec.md` R-1 — block parent stacked PR creation while any in-scope submodule PR is unmerged.

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

**This gate enforces the canonical commit-per-issue invariant: exactly one squashed commit per issue, carrying dual co-author trailers (AI + human) on the squashed commit.** Creating a PR with an incorrect commit count is a CRITICAL GUIDELINE VIOLATION per `000-critical-rules.md` §Un-Squashed PR.

```bash
# Count commits ahead of trunk
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
- Rebase branch on trunk, check for remaining changes
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
- `None` / `"unknown"` → Wait and retry, or determine mergeability locally via `git merge-base --is-ancestor origin/<target> HEAD` (exit 0 = mergeable)

**For AI-objective conflicts (imports, whitespace, additive):** Auto-resolve.
**For AI-subjective conflicts (logical, architectural, intent):** HALT and request developer input.

### Step 1.5e: Post-Creation Mergeability Gate Reference

The pre-creation gate acknowledges that a **post-creation mergeability check** runs after PR creation (see `pr-creation/create-pr.md` Step 7.2.4). This post-creation gate verifies the PR transitions to a mergeable state and does NOT remain in a terminal "PR is open" status. SC-5 (no terminal "PR is open" status) is enforced at the post-creation gate, not at this pre-creation gate.

**Pre-creation gate responsibility:** Ensure all pre-conditions pass so the post-creation mergeability check has a valid starting state.
**Post-creation gate responsibility:** Verify the PR becomes mergeable and report status.

## Enforcement Mechanisms

| Layer | Mechanism | Scope | Bypassable? |
| -- | -- | -- | -- |
| Local | `.opencode/hooks/pre-commit` | Blocks commit to main/master/dev | No |
| Local | `.opencode/hooks/post-commit` | Warns after commit to main/master/dev | N/A (post) |
| GitBucket | Branch protection rules | Requires PR for dev/main | No |

## Context Required

- Related tasks: `pr-creation/squash-push`, `pr-creation/create-pr`
- Related skills: `conflict-resolution`