# Task: pr-creation/enforcement-gate

## Purpose

Enforce mandatory pre-conditions before PR creation. Verify explicit PR instruction, review-prep completion, and branch push status.

## Entry Criteria

- Implementation is complete
- Developer may have said "create a PR" or similar

## Exit Criteria

- All enforcement gates pass
- PR creation is authorized to proceed

## Procedure

### Step 0: Submodule Hash Liveness Check (MANDATORY GATE — Sub-Agent Dispatch)

**If `.gitmodules` does NOT exist:** Skip entirely.

**If `.gitmodules` exists:** The agent MUST dispatch a `submodule-liveness-check` sub-agent to verify that all referenced submodule hashes are reachable. The main agent MUST NOT perform git operations on submodules inline — this is a CRITICAL GUIDELINE VIOLATION per `000-critical-rules.md` §Inline Work.

#### Sub-Agent Boundary

| Field | Value |
|-------|-------|
| **must_receive** | Submodule paths from `git submodule status`, `github.owner`, `github.repo`, parent repo short name, issue number, context (enforcement-gate) |
| **must_not_receive** | Implementation context, agent memory, full task file contents |

#### Dispatch Procedure

Invoke: `/submodule-verify` opencode command (or dispatch sub-agent with scoped instruction).

The sub-agent performs an **idempotent tag-if-untagged liveness check** — if a SHA is unreachable, it tags it first, then re-verifies:

1. For each submodule entry:
   a. Get committed SHA: `git ls-tree HEAD <path> | awk '{print $3}'`
   b. Check if SHA is reachable via any parent-repo tag: `git tag --contains <sha> | grep -E '<parent-repo-short>'`
   c. If reachable via a pre-work tag (`<parent-repo>/<issue-number>`), feature tag (`<parent-repo>/<issue-number>-<sub>`), or release tag (`<parent-repo>/v<N.N.N>`): ✅ PASS
   d. If reachable via dev branch or any other ref: ✅ PASS
   e. If NOT reachable by any parent-repo tag: **TAG the SHA** with the appropriate context tag, push the tag, then re-verify → PASS

2. The liveness check is **self-healing**: unreachable SHAs are tagged, not just reported. It never blocks for an unreachable SHA without attempting remediation first.

3. If ALL submodule hashes are reachable (either pre-existing or after tagging): Proceed to Step 1.

4. If ANY submodule hash is NOT reachable AND tagging also fails: **BLOCK PR creation** with specific failure report listing which submodule and which hash failed.

**Tagging is idempotent** — no duplicate tags, no errors on already-tagged SHAs. See `submodule-liveness-check.md` for the complete idempotent tag-if-untagged procedure.

**There is NO `--force` override for submodule liveness gates.**

#### Sub-Agent Result Contract

```yaml
status: DONE | BLOCKED
task: submodule-liveness-check
tags_added:
  - path: <submodule-path>
    tag_name: <tag-created>
    sha_tagged: <sha>
submodule_results:
  - path: <submodule-path>
    committed_sha: <sha>
    reachable: bool
    reachable_via: <tag-name or ref-name or "unreachable">
    tags_added: [<tag-names>]
evidence_artifacts:
  - tool: git ls-tree HEAD <path>
    output: <sha>
  - tool: git tag --contains <sha>
    output: <tag list>
```

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
git log origin/dev..HEAD --oneline

# Detect branch type via work state file
ls .opencode/tmp/work-*.md 2>/dev/null
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
   git reset --soft origin/dev
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

Query GitHub API for existing PRs on this branch:

- **Open PR:** Update existing PR (push new commits)
- **Closed PR (not merged):** Check reason, proceed with caution
- **Merged PR:** Rebase branch on dev, check for remaining changes

If branch already merged (no remaining changes):
```
✅ BRANCH ALREADY MERGED
The branch '{branch_name}' has already been merged via PR #{pr_number}.
No new PR needed.
```

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