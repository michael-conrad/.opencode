# Task: completion

Idempotent completion subtask for finishing-a-development-branch. Ensures mandatory steps run regardless of where the workflow halted.

## State Check Phase

- [ ] 1. **Push status:** Check for unpushed commits
   ```bash
   git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null
   ```
- [ ] 2. **Compare URL generated:** Check if compare URL was already produced
- [ ] 3. **Lifecycle event:** Check if lifecycle event was already appended to `{project_root}/tmp/{issue-N}/lifecycle.yaml`

## Skill-Specific Completion

- [ ] 1. **Verify push** — ensure all commits are on remote
- [ ] 2. **Generate compare URL** ($DEFAULT_BRANCH...branch)

## Shared Completion Delegation

Reference `.opencode/skills/completion-core/completion-core.md` for steps 3-6:

- [ ] 1. Push branch (with idempotency check)
- [ ] 2. Generate compare URL ($DEFAULT_BRANCH...branch)
- [ ] 3. Append completion event to lifecycle manifest at `{project_root}/tmp/{issue-N}/lifecycle.yaml`
- [ ] 4. Report executive summary in chat (always runs)

## Completion Guarantee

**MANDATORY:** Regardless of workflow outcome (success, failure, error, early termination), produce a status message containing:
- [ ] 1. What was completed
- [ ] 2. What was attempted
- [ ] 3. Why the halt occurred (if not explicit completion)
- [ ] 4. Current branch state (if applicable)

This is the completion guarantee: NO workflow ends without a status message. The completion task is idempotent and safe to invoke multiple times.

## Report Phase

Generate executive summary in chat:

```
**Summary:**

<Branch readiness verification result>

**Outcome:** <What stakeholders get — branch is ready/not ready for PR>

Compare URL: <<Character-match verified URL from session-init values per URL Sourcing Rules>>
```

URL is ALWAYS last per `000-critical-rules.md`.

## Live Verification: Completion State Claims (MANDATORY)

**Before claiming branch is ready, verify against actual git state.**

| Claim | Verification Action | Tool Call | Problem Class |
|-------|-------------------|-----------|---------------|
| "All commits pushed" | Verify no unpushed commits | `git diff @{u} HEAD` → check empty | VERIFICATION-GAP |
| "Compare URL correct" | Verify URL uses correct base (trunk) and session values | Verify URL string format | STRUCTURE-VIOLATION |
| "Lifecycle event appended" | Verify lifecycle event exists | `grep -c "event:" {project_root}/tmp/{issue-N}/lifecycle.yaml` | MISSING-ELEMENT |

**Evidence artifact:** Git command output and/or GitHub MCP response confirming each claim.

### Finding Classification

| Finding | Problem Class | Classification | Action |
|--------|---------------|----------------|--------|
| Unpushed commits found | VERIFICATION-GAP | auto-fix | Push immediately |
| Compare URL uses wrong base | STRUCTURE-VIOLATION | auto-fix | Regenerate URL |
| Lifecycle event append incomplete | MISSING-ELEMENT | auto-fix | Append lifecycle event |

## Pipeline Signal

```
CONTINUE: git-workflow --task review-prep
HALT
```
