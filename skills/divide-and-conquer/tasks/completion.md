# Task: completion

Migrated from `implementation-workflow` task completion.

Idempotent completion subtask for divide-and-conquer. Ensures mandatory steps run regardless of where the workflow halted. This task is the completion guarantee: NO divide-and-conquer workflow ends without a status message.

## Purpose

When a divide-and-conquer operation halts — whether orchestrating a single-issue or multi-issue work set, whether all sub-agents succeeded, some returned errors, or the context budget was exhausted — the completion task ensures that all mandatory reporting and state verification steps have been performed.

## State Check Phase

### Step 1: Git Status Check

```bash
git status --porcelain
```

Determine if uncommitted changes exist from sub-agent operations. If yes, either commit or report as blocker.

### Step 2: Push Status Check

```bash
git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null
```

Determine if unpushed commits exist from sub-agent implementations. If yes, push or report as blocker.

### Step 3: Existing Comments Check

Check if completion comment was already posted on the issue. Avoid duplicate status updates by checking recent issue comments.

## Skill-Specific Completion

### Verification-Before-Completion (Remediation)

If `verification-before-completion --task verify` was not yet invoked:

1. Check for verification evidence in issue comments or `./tmp/`
2. If missing: invoke `verification-before-completion --task verify`
3. Verification produces per-SC evidence tables that must be present before completion

### Finishing-A-Development-Branch (Remediation)

If `finishing-a-development-branch --task checklist` was not yet invoked:

1. Check if branch readiness checklist has been run
2. If missing: invoke `finishing-a-development-branch --task checklist`
3. Checklist verifies lint, tests, format, and uncommitted changes

### Git-Workflow Review-Prep (Remediation)

If `git-workflow --task review-prep` was not yet invoked:

1. Check if compare URL exists in chat output
2. If missing: invoke `git-workflow --task review-prep`
3. Review-prep handles commit, push, and URL generation

## Shared Completion Delegation

Reference `.opencode/skills/completion-core/completion-core.md` for steps 3-6:

1. Push branch (with idempotency check — don't push if already pushed)
2. Generate compare URL (dev...branch)
3. Post status comment on issue (with idempotency check)
4. Report executive summary in chat (always runs)

## Completion Guarantee

**MANDATORY:** Regardless of workflow outcome (success, partial, error), produce a status message containing:
1. What was completed (which sub-agents finished successfully)
2. What was attempted but not completed (which sub-agents failed or returned empty)
3. Why the halt occurred (context exhaustion, sub-agent failure, authorization gap)

This guarantee is absolute — no divide-and-conquer workflow ends silently.

## Report Phase

Generate executive summary in chat:

```
**Summary:**

<What was implemented and its impact>

**Outcome:** <What changed for stakeholders>

Compare URL: <github.html_url><github.owner>/<github.repo>/compare/dev...<branch>
```

URL is ALWAYS last per `000-critical-rules.md`.

## Live Verification: Completion State (MANDATORY)

**Verify completion claims against actual state before halting.**

| Claim | Verification Action | Tool Call | Problem Class |
|-------|-------------------|-----------|---------------|
| "All commits pushed" | Verify no unpushed commits | `git diff @{u} HEAD` | VERIFICATION-GAP |
| "Verification invoked" | Verify evidence exists | `glob(pattern="./tmp/verification-*")` | MISSING-ELEMENT |
| "Checklist completed" | Verify branch readiness | `git status --porcelain` → clean | VERIFICATION-GAP |
| "Compare URL generated" | Verify URL exists in context | Check chat output for URL | MISSING-ELEMENT |

**Evidence artifacts:** See enforcement/work-state-verification.md §Evidence Artifacts

## Post-Dispatch Output Guarantee

After every sub-agent dispatch, the main agent MUST produce output — never transition from dispatch to halt without output:

| After Dispatch | Agent MUST |
|---------------|-----------|
| Sub-agent returned valid result | Report result or proceed |
| Sub-agent returned empty result | FALLBACK to inline + report warning |
| Sub-agent returned error | FALLBACK to inline + report error |
| Inline fallback also failed | Report double-failure + invoke completion + HALT |

## Enforcement References

- Completion checkpoint protocol: see `enforcement/completion-checkpoint.md`
- Result validation and finding classification: see `enforcement/result-validation.md`
- Work state verification: see `enforcement/work-state-verification.md`

Co-authored with AI: <AgentName> (<ModelId>)