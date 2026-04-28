# Task: update-fragment

## Purpose

Update fragment master content and optionally sync to destinations. This is the primary mechanism for evolving shared content across skills while maintaining synchronization tracking.

## Entry Criteria

- Fragment ID specified
- Fragment exists in registry (`.opencode/.guidelines/registry.yaml`)
- New content provided (or user will edit manually)

## Exit Criteria

- Master file updated with new content
- Hash recalculated and recorded in registry
- Sync status updated (synchronized or drifted)
- Optional: destinations synced per user choice

## Procedure

### Step 1: Create Backup (MANDATORY)

Before any changes, create a timestamped backup:

```bash
mkdir -p .opencode/.backups/$(date +%Y%m%d)
cp .opencode/.guidelines/fragment-id.md .opencode/.backups/$(date +%Y%m%d)/fragment-id.md
```

Backups are permanent records — never stored in `tmp/`. The backup directory `.opencode/.backups/` is the canonical location for fragment backups per `000-critical-rules.md`.

### Step 2: Update Master Content

Update the master file in `.opencode/.guidelines/`:

The update may be:
- **Full replacement:** Entire content replaced with new version
- **Partial edit:** Specific section updated using edit tool
- **Append:** New section added to end of existing content

After editing, verify the file was saved correctly:

```bash
head -5 .opencode/.guidelines/fragment-id.md
wc -w .opencode/.guidelines/fragment-id.md
```

Update the metadata comment at the end of the file with the new word count and modification date.

### Step 3: Calculate New Hash

```bash
sha256sum .opencode/.guidelines/fragment-id.md
```

Record the new hash. Compare against the old hash to confirm the file actually changed.

### Step 4: Update Registry

Update registry entry in `.opencode/.guidelines/registry.yaml`:

```yaml
master:
  hash: sha256:new-hash...
  last_modified: YYYY-MM-DDTHH:MM:SSZ
  lines: new-count
content:
  estimated_words: new-word-count
```

The destinations section remains unchanged — their hashes are stale until sync.

### Step 5: Ask About Sync

Ask user: "Master updated. Sync to all destinations now?"

If YES:
- Proceed to `sync-fragment` task
- Sync will update all destination hashes after copying

If NO:
- Mark `sync_status: drifted` in registry
- Report: "Master updated but not synced. Destinations are now out of sync."
- HALT and report current state

### Step 6: Report Completion

```
✅ Fragment updated: {fragment-id}
- Master: .opencode/.guidelines/fragment-id.md
- Old hash: {old_hash}
- New hash: {new_hash}
- Sync status: {synchronized | drifted}
- Backup: .opencode/.backups/{date}/fragment-id.md
```

## Drift Management

When the master is updated but destinations are not synced:

| Status | Meaning | Action |
|--------|---------|--------|
| `synchronized` | All destinations match master | No action needed |
| `drifted` | Master updated, destinations stale | Run `sync-fragment` or `check-drift` |
| `conflicted` | Destinations have manual edits | Run `resolve-conflict` |

## Edge Cases

### Destinations Would Drift

If master updated but not synced:

1. Mark `sync_status: drifted` in registry
2. Report: "Master updated but not synced. Destinations now out of sync."
3. Recommend: Run `sync-fragment` to update destinations
4. The drift will be detected by `check-drift` on next scan

### Conflicting Changes

If destinations already have manual edits that differ from both old and new master:

1. STOP - do not overwrite manual edits
2. Run `check-drift` to see detailed drift analysis
3. Ask user: "Destinations have manual edits. Overwrite or update master from destinations?"
4. If overwrite: proceed with `sync-fragment` (destination edits will be lost)
5. If update master: extract destination edits into master first, then sync

### Master File Not Found

If the registry references a master file that doesn't exist:

1. STOP - cannot update a missing file
2. Ask user: "Master file missing. Recreate from destinations or remove fragment from registry?"
3. Recover from backup if available: `.opencode/.backups/{date}/fragment-id.md`

### Registry Entry Not Found

If the fragment ID doesn't exist in registry:

1. STOP - cannot update a non-existent fragment
2. Suggest: Use `create-fragment` to register the fragment first