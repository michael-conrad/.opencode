# Task: delete-fragment

## Purpose

Delete fragment master and remove from registry. This is a destructive operation — the master file is permanently removed. Backups are created before deletion to enable rollback.

## ⚠️ DANGER: DESTRUCTIVE OPERATION

This operation permanently removes the fragment master file. Destinations are NOT automatically modified — they retain the content but it is no longer tracked for synchronization.

## Entry Criteria

- Fragment ID specified
- Fragment exists in registry
- User explicitly confirms deletion

## Procedure

### Step 1: Verify Fragment Exists

```bash
grep -A 30 "id: fragment-id" .opencode/.guidelines/registry.yaml
```

Show fragment details to the user:
- Fragment ID
- Master file path
- Number of destinations
- Last sync date
- Current sync status

### Step 2: REQUIRE EXPLICIT CONFIRMATION

**MUST ask user before proceeding.** Present a confirmation dialog showing what will be affected:

```
⚠️ CONFIRM DELETION

Fragment: {fragment-id}
Master: .opencode/.guidelines/fragment-id.md
Destinations: {count} destinations

This will:
1. DELETE the master file
2. REMOVE entry from registry
3. Leave destination copies unchanged in skills

Destinations will still have the content but will no longer be tracked.

Proceed with deletion?

Type 'DELETE {fragment-id}' to confirm:
```

**DO NOT proceed without explicit confirmation string.** The user must type the exact confirmation string matching the fragment ID.

### Step 3: Create Backup (MANDATORY)

Before any deletion, create a timestamped backup:

```bash
mkdir -p .opencode/.backups/$(date +%Y%m%d)
cp .opencode/.guidelines/fragment-id.md .opencode/.backups/$(date +%Y%m%d)/fragment-id-deleted.md
```

Backups are permanent records stored in `.opencode/.backups/` — never in `tmp/`. The backup preserves the master content for potential rollback.

### Step 4: Delete Master File

```bash
rm .opencode/.guidelines/fragment-id.md
```

Verify the file was deleted:
```bash
ls .opencode/.guidelines/fragment-id.md
# Expected: No such file or directory
```

### Step 5: Update Registry

Remove fragment entry from `.opencode/.guidelines/registry.yaml`:
- Delete entire fragment block from `fragments:` list
- Update `last_updated` date
- Decrement `total_fragments` count (if tracked)

### Step 6: Report Completion

```
✅ Fragment deleted: {fragment-id}
- Master file removed: .opencode/.guidelines/fragment-id.md
- Registry updated
- Backup saved: .opencode/.backups/{date}/fragment-id-deleted.md

⚠️ NOTE: Content still exists in {count} destination skills but is no longer tracked.
```

## Edge Cases

### Fragment in Use by Destinations

If destinations exist:

1. **WARN:** "Fragment has {count} destinations. Deleting will orphan these copies."
2. List all destinations with their file paths
3. Ask user to confirm they understand the orphaning consequence
4. The content remains in skill files but will no longer be synchronized
5. Future drift in these destinations will not be detected

### Delete Wrong Fragment

If user regrets deletion after confirming:

1. Restore from backup: `cp .opencode/.backups/{date}/fragment-id-deleted.md .opencode/.guidelines/fragment-id.md`
2. Re-add entry to registry manually
3. Alternatively, re-run `create-fragment` with the same fragment ID

**Important:** The backup directory is a permanent record per `000-critical-rules.md` §Audit Baselines in Temporary Storage. Backups are never stored in `tmp/` or `/tmp/`.

### Registry Entry Missing After File Deletion

If the registry update fails after the master file was deleted:

1. The backup preserves the content
2. Manually remove the fragment entry from registry
3. Or re-create the fragment from the backup and update the registry