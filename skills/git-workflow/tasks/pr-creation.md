# Task: pr-creation

## Purpose

Create pull request after explicit user instruction. Squash commits to single commit, push branch, create PR targeting `dev` branch. This is the top-level routing document that delegates to three sub-task files.

## Operating Protocol

1. **User-initiated only:** "create a PR", "make a PR", "push and create PR"
2. **Squash to single commit:** ALL implementation commits combined into ONE clean commit (single-issue branches)
3. **Target `dev` branch:** Feature PRs merge to `dev` (not `main`). Only release PRs target `main`.
4. **HALT after PR creation:** Wait for human to merge. Agents NEVER merge PRs (Tier 1 mandate).

## Entry Criteria

- User says "create a PR", "make a PR", "push and create PR", or similar explicit instruction
- Implementation is complete (all files modified, tests passing)
- Developer has reviewed changes via compare URL
- Authorization scope includes `for_pr` or `pr_only` (if pipeline-scoped)

**Exception:** `for_pr`/`pr_only` authorization scope auto-authorizes PR creation per `000-critical-rules.md` §Creating PRs Without Explicit Instruction.

## Exit Criteria

- PR created via GitHub API with proper body format
- PR URL extracted from API response `html_url` field and reported in chat
- Agent HALTs waiting for human merge

## Procedure

The pr-creation task delegates to three sub-task files executed sequentially:

### Step 0-1: Enforcement Gate and PR State Check

**Route to:** `pr-creation/enforcement-gate`

Verifies:
- Submodule hash liveness (all referenced hashes reachable via tags/refs)
- Explicit PR instruction exists (or `for_pr`/`pr_only` scope)
- Branch is pushed to remote
- No existing open PR on the same head branch
- No merge conflicts with base

### Step 2-4: Changelog, Squash, Rebase, Push

**Route to:** `pr-creation/squash-push`

- Generates changelog (or skips with `[skip changelog]`)
- Squashes commits to single commit (single-issue) or verifies work branch structure
- Rebases on current dev
- Pushes to remote with force-with-lease

### Step 5-7: Collect Sub-Issues, Create PR, Extract URL

**Route to:** `pr-creation/create-pr`

- Collects sub-issues from parent spec or plan
- Creates PR with executive summary body (Summary/Outcome format)
- Extracts URL from API response `html_url` filed
- Reports PR URL in chat and HALTs

## Sub-Task Files

| Sub-Task | Purpose | Words |
| -- | -- | -- |
| `pr-creation/enforcement-gate` | Verify pre-conditions, submodule hash liveness (sub-agent dispatch), PR instruction, conflict detection | ≈650 |
| `pr-creation/squash-push` | Changelog, squash, rebase, push with live verification | ≈600 |
| `pr-creation/create-pr` | Sub-issue collection, PR creation, URL extraction, body format | ≈550 |

## Co-Author Trailers (MANDATORY)

Every squash commit MUST include:
1. AI Trailer: `Co-authored-by: <AgentName> (<ModelId>) <noreply@example.com>`
2. Human Trailer: `Co-authored-by: <dev.name> <dev.email>`

## PR Body Format (MANDATORY)

PR bodies use the Summary/Outcome format — NOT implementation details:

```markdown
## Summary

<1-3 bullet points describing what changed>

## Outcome

<What changed for stakeholders>

Implements #<issue>
```

**NEVER** write implementation details, code walkthroughs, or step-by-step descriptions in PR bodies.

## Review Phase (Mandatory)

After implementation and BEFORE PR creation:

1. Agent pushes feature branch to remote
2. Agent reports compare URL in CHAT ONLY (NEVER to GitHub Issues)
3. Developer reviews changes via GitHub diff viewer
4. Developer decides whether to create PR or request changes
5. If satisfied, developer says "create a PR"
6. Agent creates PR (squash, push, create PR, HALT)

## Error Handling

| Error | Resolution |
|-------|-----------|
| Enforcement gate fails | Report specific gate failure, HALT |
| Existing PR found | Use existing PR, extract its URL |
| Squash fails | Check for uncommitted changes, resolve, retry |
| Push fails | Check remote connectivity, retry once |
| PR creation fails | Check GitHub API status, retry once |

## Context Required

- Related skills: `review-prep`, `conflict-resolution`
- Related tasks: `pr-creation/enforcement-gate`, `pr-creation/squash-push`, `pr-creation/create-pr`