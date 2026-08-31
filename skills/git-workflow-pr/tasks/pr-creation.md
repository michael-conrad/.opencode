# Task: pr-creation

## Purpose

Create pull request after explicit user instruction. Squash commits to single commit, push branch, create PR targeting `$DEFAULT_BRANCH` branch.

## Default Branch Resolution

```bash
DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
if [ -z "$DEFAULT_BRANCH" ]; then DEFAULT_BRANCH="main"; fi
```

## Operating Protocol

- [ ] 1. **User-initiated only:** "create a PR", "make a PR", "push and create PR"
- [ ] 2. **Squash to single commit:** ALL implementation commits combined into ONE clean commit
- [ ] 3. **Target `$DEFAULT_BRANCH` branch:** Feature PRs merge to `$DEFAULT_BRANCH` (not `main`)
- [ ] 4. **HALT after PR creation:** No prompting for next steps
- [ ] 5. **Human-only merge:** After PR creation, HALT — do not merge. Only the developer can merge. The `github_merge_pull_request` tool is FORBIDDEN for agent use.

## Entry Criteria

- User says "create a PR", "make a PR", "push and create PR", or similar
- Implementation is complete
- Developer has reviewed changes via compare URL
- Pre-Response Gate evaluation completed (skill deck evaluated against current context)
- **Release PR pre-validation:** When `{is_release: true}` or context is a release PR, verify:
  - Clean working tree (`git status --porcelain` is empty)
  - No pending rebase (no `.git/REBASE_HEAD`)
  - All changes committed
  - No uncommitted submodule changes — **release carve-out:** dirty/staged submodule pointers are EXPECTED and permitted in a parent-repo release (per AGENTS.md Release discipline and create-pr.md Step 6.8 `--release` Mode). The 'no uncommitted submodule changes' check SHALL NOT block the release path. This check remains enforced for non-release PRs.

## Exit Criteria

- PR created via GitHub API or GitBucket CLI
- PR URL extracted from API response and reported in chat
- Agent reports PR URL and HALTs — no prompting for next steps

## Procedure

### Step 0-1: Enforcement Gate and PR State Check

**Route to:** `pr-creation/enforcement-gate`

Route a sub-agent for report-only SHA verification (no auto-remediation). Then verifies explicit PR instruction, branch push status, existing PR state, and merge conflict detection.

### Pre-Push Submodule Pointer Verification

A merged `.opencode` submodule PR does NOT resolve the parent repo's submodule pointer and does NOT drop it. The pointer stays DIRTY and rides ALONGSIDE the next real root-repo change on a feature branch — it is committed together with the real change in the same commit, never dropped, and never committed in a standalone pointer-only commit/PR. Submodule-only pushes are blocked by pre-push hooks, so a pointer-only parent PR is FORBIDDEN.

Before squash and push, verify dirty submodule pointers are included in staged changes ONLY alongside real code changes:

- [ ] 1. Run `git submodule status | grep '^ '` to detect dirty submodule pointers
- [ ] 2. If dirty pointers found: verify they are staged (`git diff --cached --name-only` includes submodule paths)
- [ ] 3. If staged: verify there are non-submodule changes staged (`git diff --cached --name-only` shows files outside `.opencode/`). If NO non-submodule changes exist, HALT — do NOT push. Creating a parent-repo PR whose sole change is bumping submodule pointers is FORBIDDEN. A submodule repo filing its own PR for its own changes is normal and NOT covered by this prohibition.
- [ ] 4. If not staged: `git add <submodule_path>` before squash
- [ ] 5. Confirm staged files include both source changes AND submodule pointer updates

### Step 2-4: Changelog, Squash, Rebase, Push

**Route to:** `pr-creation/squash-push`

Generates changelog (or skips with `[skip changelog]`), squashes commits, rebases on current trunk, and pushes to remote with verification.

### Step 5-7: Collect Sub-Issues, Create PR, Extract URL

**Route to:** `pr-creation/create-pr`

Collects sub-issues from parent spec, creates PR with executive summary body, extracts URL from API response, reports in chat and HALTs.

### Step 8: HALT — Do Not Merge

**HALT — do not merge. Only the developer can merge. The `github_merge_pull_request` tool is FORBIDDEN for agent use.**

### Step 9: Ticket Status Reconciliation

After the PR is created and the PR URL is reported, BEFORE reporting completion, check the ticket's current status and update it to reflect the PR-created state (`for_pr`/`approved-for-pr`) if an update is warranted. **The read is a mandatory precondition for any update. You MUST perform the `local-issues read` first and record the current status and labels from its output before any decision — you may NOT assume, recall, or infer the ticket's status from earlier context, memory, or conversation. If you have not just performed a successful `local-issues read` in this step, you MUST NOT perform an update, and you MUST NOT report completion.**

> **MANDATORY — do NOT skip.** This step runs via the `local-issues` CLI (`.opencode/tools/local-issues`) against the local `.issues/` worktree. It does NOT require a git remote, GitHub credentials, or a remote issue tracker. A local-only repo, a test environment, or a missing/absent remote is NOT a valid reason to skip the status read and update. If the ticket is in a pre-PR state and the PR was created, you MUST perform BOTH the read and the update. Skipping this step makes the PR-creation result INVALID.

- [ ] 1. **Read current ticket status — MUST run first** — Execute the `local-issues` read command now and base the update decision ONLY on its output: `./.opencode/tools/local-issues read --number <repo>#<N>` (the `--number` flag is required; the qualified `<repo>#<N>` form is accepted for reads, and a bare `--number <N>` also works when the repo qualifier is unknown). Capture and record the current `status` field and the labels array from the actual command output.
- [ ] 2. **Evaluate whether an update is warranted** — Using ONLY the status and labels read in step 1, an update is warranted when the ticket is still in a pre-PR state: `status: open` combined with the absence of a PR-created marker (e.g., no `approved-for-pr`, `approved-for-pr-only`, or equivalent PR-created label in the labels array).
- [ ] 3. **Update only when warranted** — When step 2 determined an update is warranted, transition the ticket to the PR-created state: apply the PR-created label (e.g., `approved-for-pr`) via the `local-issues` CLI: `./.opencode/tools/local-issues update --number <repo>#<N> --labels approved-for-pr` (the `--number` flag is required and mutations MUST use the qualified `{repo}#{N}` form). Confirm the update succeeded (exit 0, `updated: true`).
- [ ] 4. **Skip when already correct** — When the read in step 1 shows the ticket already carries the PR-created marker, do NOT update the ticket status. **An already-present PR-created label is a skip condition — do NOT re-apply it.** When skipping, record the reason in the result contract, citing the label observed in the step 1 read.

## Sub-Task Files

| Sub-Task | Purpose | Words |
| -- | -- | -- |
| `pr-creation/enforcement-gate` | Verify pre-conditions, task() sub-agent, PR instruction, conflict detection | ≈600 |
| `pr-creation/squash-push` | Changelog, squash, rebase, push with live verification | ≈600 |
| `pr-creation/create-pr` | Sub-issue collection, PR creation, URL extraction, body format | ≈550 |

## Co-Author Trailers (MANDATORY)

Every squash commit MUST include:
- [ ] 1. AI Trailer: `Co-authored-by: <AgentName> (<ModelId>) <noreply@example.com>`
- [ ] 2. Human Trailer: `Co-authored-by: <dev.name> <dev.email>`

## Review Phase (Mandatory)

After implementation and BEFORE PR creation:

- [ ] 1. Agent pushes feature branch to remote
- [ ] 2. Agent reports compare URL in CHAT ONLY (NEVER to GitHub Issues)
- [ ] 3. Developer reviews changes via GitHub diff viewer
- [ ] 4. Developer decides whether to create PR or request changes
- [ ] 5. If satisfied, developer says "create a PR"
- [ ] 6. Agent creates PR (squash, push, create PR, HALT)

## Context Required

- Related skills: `review-prep`, `conflict-resolution`
- Related tasks: `pr-creation/enforcement-gate`, `pr-creation/squash-push`, `pr-creation/create-pr`
### [critical-rules-016] Wrong PR Body Format
A PR body without Summary/Outcome/Fixes structure buries the intent of your changes under implementation details. Reviewers need context, not code dumps. Professional engineers write PR bodies that tell the story — amateurs dump diffs and expect reviewers to reverse-engineer the intent. Read [git-workflow skill](skills/git-workflow/SKILL.md) → `pr-creation` → PR Body Requirements.


### [critical-rules-016] Wrong Compare URL Base Branch
Using the wrong base branch in a compare URL sends reviewers to the wrong diff — your changes look different against the wrong baseline. Professional engineers verify the base branch before every compare URL — amateurs send reviewers to the wrong diff and waste everyone's time. PR compare URL base: `$DEFAULT_BRANCH` (the trunk).


