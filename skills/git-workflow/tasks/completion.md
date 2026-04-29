# Task: completion

Idempotent completion subtask for git-workflow. Ensures mandatory steps run regardless of where the workflow halted. This task is the completion guarantee: NO git-workflow session ends without a status message.

## Purpose

When a git-workflow operation halts — whether successful, partially complete, or failed — the completion task ensures that all mandatory cleanup and reporting steps have been performed. It is idempotent: invoking it multiple times produces the same result.

## State Check Phase

### Step 1: Check Git Status

```bash
git status --porcelain
```

Determine if uncommitted changes exist. If yes, either commit or report as blocker.

### Step 2: Check Push Status

```bash
git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null
```

Determine if unpushed commits exist. If yes, push or report as blocker.

### Step 3: Check Existing Comments

If an issue context is available, verify whether a completion comment was already posted. Check recent issue comments to avoid duplicate status updates.

### Step 4: Verify Compare/PR URL

Check if compare URL or PR URL was already generated. Look for URL in recent chat output. If missing, this is a verification gap that needs remediation.

## Skill-Specific Completion

### Review-Prep Path

If review-prep has not yet been run:

1. Delegate to `git-workflow --task review-prep`
2. Review-prep handles: commit, push, compare URL generation
3. Check if compare URL was already generated
4. If missing: invoke review-prep as remediation

### Cleanup Path

If on cleanup path after PR merge:

1. Verify PR merge via GitHub API before closing issues
2. Ensure branch deletion completed
3. Ensure issue closure completed
4. Verify local dev HEAD matches origin/dev

### Implementation Path

If implementation just completed:

1. Verify all changes are committed
2. Verify all commits are pushed
3. Verify compare URL exists in chat output

## Shared Completion Delegation

Reference `.opencode/skills/completion-core/completion-core.md` for steps 3-6:

1. Push branch (with idempotency check — don't push if already pushed)
2. Generate compare URL (dev...branch) — only if not already generated
3. Post status comment on issue (with idempotency check — don't post if already posted)
4. Report executive summary in chat (always runs)

## Completion Guarantee

**MANDATORY:** Regardless of workflow outcome (success, partial, error), produce a status message containing:
1. What was completed
2. What was attempted but not completed
3. Why the halt occurred

This guarantee is absolute — no git-workflow ends silently.

## Report Phase

Generate executive summary in chat:

```
**Summary:**

<Git operation result and its impact>

**Outcome:** <What changed for stakeholders>

<URL if applicable, ALWAYS LAST>

🤖 <AgentName> (<ModelId>) <status>
```

URL is ALWAYS last per `000-critical-rules.md`. Compare URL format: `<github.html_url><github.owner>/<github.repo>/compare/dev...<branch>`. PR URL format: `<github.html_url><github.owner>/<github.repo>/pull/<N>`.

## Format Verification Before Halt (MANDATORY)

**Idempotent — safe to invoke multiple times. This verification runs before EVERY halt, regardless of path.**

- [ ] Executive summary present as **first** element
- [ ] Outcome line present after summary
- [ ] URL present IF relevant (after outcome, before byline)
- [ ] AI byline present as **LAST** element
- [ ] No stale todowrite items remain