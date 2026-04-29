# Task: check-drift

## Purpose

Detect when destination copies diverge from the fragment master. Drift indicates that one or more skill files contain outdated or modified versions of shared content, requiring synchronization or conflict resolution.

## Entry Criteria

- Fragment ID specified (or 'all' to check all fragments)
- Registry exists with fragment entries (`.opencode/.guidelines/registry.yaml`)

## Exit Criteria

- All destinations checked against master
- Registry sync_status updated for each fragment
- Drift report generated showing synchronized vs drifted fragments

## Procedure

### Step 1: Load Registry

```bash
cat .opencode/.guidelines/registry.yaml
```

Parse all fragments or the specified fragment. Extract:
- Master file path and hash for each fragment
- Destination paths and line ranges
- Last sync timestamp

### Step 2: Calculate Master Hash

```bash
sha256sum .opencode/.guidelines/fragment-id.md
```

Compare to registry `master.hash`. If they differ:
- The master file has changed since last registry update
- This is a "registry stale" condition that should be resolved first

### Step 3: Check Each Destination

For each destination in the fragment's registry entry:

1. **Calculate destination hash:**
   ```bash
   sha256sum "$dest_path"
   ```

2. **Compare to master hash:**
   - If exact match → `synchronized`
   - If mismatch → `drifted`

3. **Update status in memory:**
   ```
   Fragment: {fragment-id}
   Destination: skill/SKILL.md
   Master hash: {abc123...}
   Dest hash: {def456...}
   Status: DRIFTED ⚠️
   ```

4. **Extract and compare content** (when hashes differ):
   - Read lines from destination file at the specified line_range
   - Read entire master file
   - Compare content to determine the nature of the drift

### Step 4: Update Registry Status

Update sync_status for each fragment:

- If all destinations match master → `synchronized`
- If any destination differs → `drifted`
- If destinations have manual edits → `conflicted`

### Step 5: Generate Drift Report

Display for each fragment:

```
Fragment Status Report
======================

Fragment: branch-first-protocol
Master: .opencode/.guidelines/branch-first-protocol.md
Hash: sha256:abc123...
Status: synchronized ✅

Destinations:
  1. git-workflow/tasks/pre-work.md
     Hash: sha256:abc123... (MATCH) ✅
     Lines: 7-84

Fragment: commit-workflow
Master: .opencode/.guidelines/commit-workflow.md
Hash: sha256:abc123...
Status: drifted ⚠️

Destinations:
  1. git-workflow/tasks/commit-prep.md
     Hash: sha256:def456... (MISMATCH) ⚠️
     Lines: 7-39
     Drifted since: 2026-04-05

DRIFT DETECTED: 1 of 9 fragments have drifted
```

### Step 6: Recommendations

For each drifted fragment, recommend an action:

| Drift Type | Recommendation |
|-----------|---------------|
| Minor formatting drift | Run `sync-fragment` to overwrite with master |
| Substantive manual edits | Run `resolve-conflict` to merge changes |
| Master newer than destinations | Run `sync-fragment` to push updates |
| Destination newer than registry | Run `update-fragment` to pull changes into master |

## Exit Criteria

- All destinations checked against master
- Registry sync_status updated
- Drift report generated with actionable recommendations

## Edge Cases

### Master Hash Mismatch

If master file hash differs from registry:

```
⚠️ REGISTRY STALE

Fragment: {fragment-id}
Registry hash: {reg_hash}
Actual master hash: {file_hash}

Which is correct?
a) Registry is stale (update from file) — most common
b) File is stale (sync from registry's expected content) — rare
c) Both changed (manual investigation needed)
```

Resolution: In most cases, (a) is correct — the file was updated and registry was not. Run `update-fragment` to recalculate.

### Destination File Missing

If destination file doesn't exist at the specified path:

1. WARN: "Destination file missing: {path}"
2. Mark destination as `deleted`
3. Possible resolutions:
   - Remove from registry (fragment no longer needed in that skill)
   - Recreate file from master content
   - Ask user: "Remove from registry or recreate file?"

### Line Range Invalid

If destination file has fewer lines than `line_range.end`:

1. Content may have been deleted or moved within the file
2. Report: "Line range exceeds file length"
3. Possible resolutions:
   - Re-scan file to find the content at a new location
   - Update registry with new line_range
   - Recreate destination from master

### Empty Registry

If no fragments are defined in the registry:

```
Fragment Status Report
======================

Registry: EMPTY

No fragments tracked yet.
Run 'create-fragment' to add the first fragment master.
```

This is informational — not an error condition.