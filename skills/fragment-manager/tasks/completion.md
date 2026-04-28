# Task: completion

Idempotent completion subtask for fragment-manager. Ensures mandatory steps ran regardless of where the workflow halted. This task is the completion guarantee: NO fragment-manager workflow ends without a status message.

## Purpose

When a fragment-manager operation halts — whether fragment creation, update, sync, drift check, or deletion completed successfully, partially, or with errors — the completion task ensures that all mandatory reporting and state maintenance steps have been performed.

## State Check Phase

### Step 1: Registry Update Verification

Verify the fragment registry (`.opencode/.guidelines/registry.yaml`) was updated after the operation:
- Check if the registry file was modified with correct entries
- Verify that the fragment entry exists (for create/update) or is removed (for delete)
- If missing: update registry with current operation details as remediation

### Step 2: Destination Synchronization Verification

Verify all destinations listed in registry have been synchronized:
- For each destination, check that destination hash matches master hash
- If any destination not synced: invoke `sync-fragment` task as remediation
- Report drift status to user if destinations remain out of sync

### Step 3: Drift Check Verification

Verify zero drift between masters and destinations:
- Run `check-drift` to confirm all fragments are synchronized
- If drift found: invoke `resolve-conflict` or `sync-fragment` as remediation
- Report any persistent drift that cannot be automatically resolved

### Step 4: Backup Verification

Check that backups were preserved for any destructive operations:
- Verify `.opencode/.backups/` exists and contains expected backup files
- If backups are missing from a destructive operation (delete, overwrite): flag for developer attention
- Backups cannot be recreated once lost — this is a permanent gap

## Skill-Specific Completion

### Registry Update (Remediation)

If registry was not updated:
1. Read current registry state
2. Add or update the fragment entry with current hash and metadata
3. Write updated registry back to disk
4. Verify write succeeded

### Destination Sync (Remediation)

If destinations are out of sync:
1. Identify drifted destinations via hash comparison
2. Invoke `sync-fragment` for each drifted destination
3. Verify sync completed by checking updated hashes
4. Report any destinations that could not be synced

### Drift Resolution (Remediation)

If drift persists after sync attempts:
1. Run `resolve-conflict` task for conflicting fragments
2. If resolution requires manual intervention, report to developer
3. Never silently ignore drift — always surface it

## Shared Completion Delegation

Reference `.opencode/skills/completion-core/completion-core.md` for reporting:

1. Report executive summary in chat (always runs)
2. Action URL (issue URL or fragment registry path) as the URL (ALWAYS last)

## Completion Guarantee

**MANDATORY:** Regardless of workflow outcome (success, partial, error), produce a status message containing:
1. What was completed
2. What was attempted but not completed
3. Why the halt occurred

This guarantee is absolute — no fragment-manager workflow ends silently.

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
- [ ] Registry state verified (created/updated/deleted as expected)