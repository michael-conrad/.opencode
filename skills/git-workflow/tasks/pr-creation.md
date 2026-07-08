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

## Entry Criteria

- User says "create a PR", "make a PR", "push and create PR", or similar
- Implementation is complete
- Developer has reviewed changes via compare URL
- Pre-Response Gate evaluation completed (skill deck evaluated against current context)
- **Release PR pre-validation:** When `{is_release: true}` or context is a release PR, verify:
  - Clean working tree (`git status --porcelain` is empty)
  - No pending rebase (no `.git/REBASE_HEAD`)
  - All changes committed
  - No uncommitted submodule changes

## Exit Criteria

- PR created via GitHub API or GitBucket CLI
- PR URL extracted from API response and reported in chat
- Agent reports PR URL and HALTs — no prompting for next steps

## Procedure

### Step 0-1: Enforcement Gate and PR State Check

**Route to:** `pr-creation/enforcement-gate`

task() sub-agent for report-only SHA verification (no auto-remediation). Then verifies explicit PR instruction, branch push status, existing PR state, and merge conflict detection.

### Pre-Push Submodule Pointer Verification

Before squash and push, verify dirty submodule pointers are included in staged changes:

- [ ] 1. Run `git submodule status | grep '^ '` to detect dirty submodule pointers
- [ ] 2. If dirty pointers found: verify they are staged (`git diff --cached --name-only` includes submodule paths)
- [ ] 3. If not staged: `git add <submodule_path>` before squash
- [ ] 4. Confirm staged files include both source changes AND submodule pointer updates

### Step 2-4: Changelog, Squash, Rebase, Push

**Route to:** `pr-creation/squash-push`

Generates changelog (or skips with `[skip changelog]`), squashes commits, rebases on current dev, and pushes to remote with verification.

### Step 5-7: Collect Sub-Issues, Create PR, Extract URL

**Route to:** `pr-creation/create-pr`

Collects sub-issues from parent spec, creates PR with executive summary body, extracts URL from API response, reports in chat and HALTs.

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