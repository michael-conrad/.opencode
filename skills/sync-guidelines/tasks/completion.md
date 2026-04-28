# Task: completion

Idempotent completion subtask for sync-guidelines. Ensures mandatory steps ran regardless of where the workflow halted. This task is the completion guarantee: NO sync-guidelines workflow ends without a status message.

## Purpose

When a sync-guidelines operation halts — whether the sync was successful, partially completed with some files not classified, or failed — the completion task ensures that all mandatory reporting and state maintenance steps have been performed.

## State Check Phase

### Step 1: Classification Completion

Verify that all files were read and classified:
- Check evidence that each file was read (not just listed)
- Check that classification decisions have documented reasoning
- If missing: invoke `classify` task as remediation for unclassified files

### Step 2: Sync Issue Creation Verification

Verify that sync issues were created for core changes:
- Check evidence that sync issues exist in the target repository for core files
- Verify issue URLs are present and valid
- If missing: invoke `sync-push` or `sync-pull` task as remediation

### Step 3: Sync State File Verification

Verify that `.opencode/sync-state.yml` has been updated:
- Check that the file exists with updated timestamp and file list
- Verify the last sync date is current
- If stale: update sync state with current operation details

### Step 4: No Direct Modification Guard

Verify that no files were directly edited in the target repository:
- Sync-guidelines creates issues for review, NOT direct file modifications
- If direct edits were found: create sync issue to propose those changes formally
- This guard prevents unauthorized modifications to target repos

## Skill-Specific Completion

### Classification Verification (Remediation)

If classification was not fully completed:
1. Identify unclassified files from the file list
2. Read each unclassified file using the `read` tool
3. Apply the `classify` task criteria to determine core vs project-specific
4. Document classification reasoning for each file

### Sync Issue Verification (Remediation)

If sync issues were not created:
1. Identify core files that should have sync issues
2. Invoke `sync-push` or `sync-pull` task for each untracked core file
3. Verify issue creation by extracting `html_url` from API response

### Sync State File Update (Remediation)

If sync state is stale:
1. Read current `.opencode/sync-state.yml`
2. Update timestamp to current date/time
3. Add current operation details to file list
4. Write updated state back

## Shared Completion Delegation

Reference `.opencode/skills/completion-core/completion-core.md` for reporting:

1. Report executive summary in chat (always runs)
2. Sync issue URL(s) as the URL (ALWAYS last)

## Completion Guarantee

**MANDATORY:** Regardless of workflow outcome (success, partial, error), produce a status message containing:
1. What was completed
2. What was attempted but not completed
3. Why the halt occurred

This guarantee is absolute — no sync-guidelines workflow ends silently.

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
- [ ] All classified files have documented reasoning