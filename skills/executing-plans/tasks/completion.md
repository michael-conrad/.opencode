# Task: completion

Idempotent completion subtask for executing-plans. Ensures mandatory steps ran regardless of where the workflow halted. This task is the completion guarantee: NO executing-plans workflow ends without a status message.

## Purpose

When an executing-plans operation halts — whether all steps completed successfully, some steps partially completed, or an error occurred — the completion task ensures that all mandatory reporting and state maintenance steps have been performed. It is idempotent: invoking it multiple times produces the same result.

## State Check Phase

### Step 1: Assemble-Work Dispatch Verification

Check that the divide-and-conquer assemble-work dispatch was attempted:
- Look for evidence in `./tmp/` work state files
- Check issue comments for implementation evidence
- If missing: the dispatch was never attempted — flag as a verification gap

### Step 2: Plan Issue STATUS Verification

Verify the plan issue STATUS reflects the actual outcome:
- Read the plan issue if one exists
- Check if STATUS marker matches actual implementation state
- If mismatched: update STATUS to reflect current state
- Possible states: `DRAFT`, `IN_PROGRESS`, `COMPLETED`, `PARTIAL`, `BLOCKED`

### Step 3: Chat Executive Summary Verification

Verify that a chat executive summary was posted:
- Search recent chat output for summary/outcome/byline pattern
- If missing: generate and post executive summary now
- This ensures no workflow ends silently

## Skill-Specific Completion

### Assemble-Work Dispatch (Remediation)

If assemble-work dispatch was never attempted:
1. Check evidence for assemble-work invocation
2. If missing: invoke `divide-and-conquer --task assemble-work` as remediation
3. Note this as a remediation step in the final report

### Plan Issue STATUS (Remediation)

If plan issue STATUS was never updated:
1. Check plan issue STATUS marker against actual completion state
2. If mismatched: update STATUS to reflect current state
3. Post a comment documenting the update reason

### Chat Executive Summary (Remediation)

If chat output lacks an executive summary:
1. Generate summary from available evidence
2. Post summary to chat
3. Include all required elements (summary, outcome, URL, byline)

## Shared Completion Delegation

Reference `.opencode/skills/completion-core/completion-core.md` for reporting:

1. Report executive summary in chat (always runs)
2. Action URL (plan issue URL) as the URL (ALWAYS last element before byline)

## Completion Guarantee

**MANDATORY:** Regardless of workflow outcome (success, partial, error), produce a status message containing:
1. What was completed
2. What was attempted but not completed
3. Why the halt occurred

This guarantee is absolute — no executing-plans workflow ends silently.

## Report Phase

Generate executive summary in chat:

```
**Summary:**

<1-2 sentences describing impact>

**Outcome:** <What the result means for stakeholders>

<URL if applicable, ALWAYS LAST>

🤖 <AgentName> (<ModelId>) <status>
```

### Format Verification Before Halt (MANDATORY)

**Idempotent — safe to invoke multiple times. This verification runs before EVERY halt, regardless of path.**

- [ ] Executive summary present as **first** element
- [ ] Outcome line present after summary
- [ ] URL present IF relevant (after outcome, before byline)
- [ ] AI byline present as **LAST** element
- [ ] No stale todowrite items remain (all cleared or N/A)
- [ ] Plan issue STATUS matches actual outcome