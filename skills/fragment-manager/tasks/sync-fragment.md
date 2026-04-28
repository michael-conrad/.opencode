# Task: sync-fragment

## Purpose

Copy fragment master content to all registered destinations, ensuring content consistency across the codebase. This task is the primary synchronization mechanism for shared content blocks (fragments) that appear in multiple files — when the master changes, all destinations must be updated to match.

## Principles

### Master Is Authority

The master copy is the single source of truth. Destination content must match the master exactly. Any deviation in a destination is drift — intentional or not — and must be resolved before or during sync.

### Backup Before Mutation

Every destination file is backed up before any modification. If sync fails mid-operation, backups enable rollback to the pre-sync state. This is non-negotiable even when the destination appears unchanged.

### Idempotent Operation

Running sync-fragment multiple times with the same master content produces the same result. If all destinations already match the master, the task is a no-op (after drift detection confirms this).

### Atomic per Destination

Each destination is updated independently. Failure to update one destination does not prevent other destinations from being updated. The sync report distinguishes between successful and failed destinations.

## Entry Criteria

- Fragment ID specified (exact match to registry key)
- Fragment exists in `.opencode/.guidelines/registry.yaml` with `fragment_id` entry
- Master file path and destination list are defined in the registry
- `check-fragment` task has been run (or will be run as Step 1)

## Procedure

### Step 1: Run Drift Detection First

**MANDATORY: Check drift before syncing.**

Run `check-fragment` task:

- If all destinations synchronized → Proceed to Step 3
- If any destination drifted → Proceed to Step 2
- If conflict detected → STOP, run `resolve-conflict`

### Step 2: Handle Drift

If destinations have drifted from the master content, the sync task must resolve the drift before proceeding. Drift indicates that at least one destination no longer matches the master — either because the master was updated and destinations were not, or because a destination was independently modified.

**Drift resolution options:**

| Option | Behavior | Use When |
|--------|----------|----------|
| (a) Sync all | Overwrite ALL destinations with master, even drifted ones | Master is authoritative; drift is unintentional |
| (b) Sync synchronized only | Update destinations that already match master; preserve drifted content | Drift may be intentional; review before overwriting |
| (c) Review details | Display diff for each drifted destination before choosing | Need context before deciding |
| (d) Abort | Stop sync without any changes | Need to investigate further before proceeding |

**Mandatory before overwrite:** Create backups (Step 3) regardless of chosen option. Even option (a) requires backups — intentional drift may need to be restored.

**Conflict detection:** If a drifted destination contains content that conflicts with the master (e.g., both master and destination were independently modified with different changes), STOP and invoke `resolve-conflict` task. The sync task does not merge — it copies. Merging conflicting changes requires manual resolution.

### Step 3: Create Backups (MANDATORY)

Before modifying any destination file, create timestamped backups. This step is mandatory even when drift detection reports all destinations as synchronized — the backup provides rollback capability for unexpected failures.

**Backup directory structure:**
```
.opencode/.backups/YYYYMMDD/fragment-id/
```

Each destination file is copied to this backup directory with a `.bak` extension. The backup preserves the original filename for traceability.

**Backup verification:** After creating backups, verify each backup file exists and has the expected size (not zero bytes). A zero-byte backup means the destination file was empty or the copy failed — investigate before proceeding.

**Backup retention:** Backups are not automatically deleted. They accumulate in `.opencode/.backups/` and can be cleaned manually. The `status-report` task lists backup directories.

### Step 4: Read Master Content

Read the master fragment file using the `read` tool (TIER 1 priority per `060-tool-usage.md`). The master content is the authoritative source that all destinations must match exactly after sync.

**Verification after read:** Compute the SHA-256 hash of the master content. This hash serves as the reference for verifying that all destinations were updated correctly in Step 5.

**Master must exist:** If the master file is missing or empty, STOP. The fragment registry references a non-existent master, which indicates a registry inconsistency. Use `create-fragment` to create the master before syncing.

### Step 5: Update Each Destination

For each destination registered in the fragment registry:

1. **Read destination file** using the `read` tool.

2. **Locate the fragment marker region** in the destination file. Fragment markers define the start and end of shared content within a file. The registry records the `line_range` for each destination — use this to locate the marker region.

3. **Replace the content within the marker region** with the master content. Use the `edit` tool (TIER 1) to replace the old content between start and end markers with the master content. Preserve any content outside the marker region unchanged.

4. **Verify the update** by reading the destination file again and computing its SHA-256 hash of the fragment region. The fragment region hash must match the master hash computed in Step 4.

5. **Update the destination hash in the registry** with the new hash and current timestamp:

```yaml
destinations:
  - path: '...'
    hash: sha256:new-hash...
    verified_date: YYYY-MM-DDTHH:MM:SSZ
```

**Atomic per destination:** If a single destination fails (hash mismatch after edit, file not found, marker region missing), log the failure and proceed to the next destination. Do not abort the entire sync for a single destination failure.

**Marker region integrity:** If the fragment markers (start/end comments) in a destination file are missing or malformed, STOP updating that destination. Log the issue and proceed to the next destination. Missing markers indicate the destination file was manually edited in a way that removed the sync boundaries — this needs manual investigation.

### Step 6: Update Registry Status

After all destinations have been processed (successfully or not), update the fragment registry entry:

```yaml
sync_status: synchronized | partial | conflict
last_sync: YYYY-MM-DDTHH:MM:SSZ
master_hash: sha256:current-master-hash
```

**Status values:**

| Status | Meaning |
|--------|---------|
| `synchronized` | All destinations match master |
| `partial` | Some destinations updated, some failed |
| `conflict` | Conflict detected in at least one destination (requires manual resolution) |

If status is `partial`, include a `failed_destinations` list with paths and failure reasons.

### Step 7: Report Completion

Report sync results to chat:

```
✅ Sync complete: {fragment-id}
- Master hash: {master_hash}
- Destinations updated: {count}
- Destinations failed: {count} (if any)
- Sync status: {synchronized|partial|conflict}
- Backups saved: .opencode/.backups/{date}/{fragment-id}/
```

**If all destinations synchronized:** Report success and HALT.

**If partial sync:** Report which destinations failed and why. Offer to retry failed destinations.

**If conflict detected:** Report which destinations have conflicts. Recommend running `resolve-conflict` for each conflicted destination.

No GitHub Issue comment is needed for routine fragment sync — this is an operational task, not a stakeholder-visible change.

## Edge Cases

### Partial Sync Failure

If some destinations fail to update (hash mismatch, missing markers, file not found):

1. **Do not roll back successful destinations.** Completed syncs are valid.
2. Log each failure with the destination path and error reason.
3. Roll back failed destinations from backups (copy backup over the failed destination).
4. Report which destinations succeeded and which failed.
5. The registry status becomes `partial` — not `synchronized` and not `conflict`.
6. User decides whether to retry failed destinations or investigate further.

**Rollback procedure for a failed destination:**
- Copy the backup file from `.opencode/.backups/YYYYMMDD/fragment-id/dest-filename.bak` to the original destination path
- Verify the rollback by computing the hash and confirming it matches the pre-sync hash

### Line Range Changed

If a destination file's structure has changed since the registry was last updated, the stored `line_range` may no longer accurately locate the fragment markers:

1. STOP updating that destination. Using a stale line range will corrupt the file.
2. Re-scan the destination file for fragment start/end markers using `grep` or `read`.
3. Update the `line_range` in the registry with the new positions.
4. Retry the sync for that destination only.
5. If markers are completely missing, flag as a conflict — manual intervention needed.

### Master Hash Changed Mid-Sync

If the master file is modified during an active sync operation:

1. STOP immediately. Do not continue syncing with stale master content.
2. Do not roll back destinations that have already been updated — they received a valid version of the master (just not the latest).
3. Re-run from Step 1 with the updated master content.
4. Destinations that were already updated with the previous master version will be re-updated with the latest version.

**Why this matters:** Syncing a stale master creates inconsistency if some destinations got version A and others got version B. The safest approach is to stop and re-sync with the current master.
