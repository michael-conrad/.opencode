# Task: read-fragment

## Purpose

Read fragment master content and show metadata including sync status across all destinations. This is a read-only operation — no files are modified.

## Entry Criteria

- Fragment ID specified
- Fragment exists in registry (`.opencode/.guidelines/registry.yaml`)

## Exit Criteria

- Fragment content displayed
- All destination status shown with hash comparison
- Sync status summary reported

## Procedure

### Step 1: Load Registry

```bash
grep -A 30 "id: fragment-id" .opencode/.guidelines/registry.yaml
```

Extract from registry entry:
- Master file path
- Hash
- Content type
- Estimated words
- Description
- Sync status
- Last sync timestamp
- All destination paths with their line ranges and hashes

If the fragment ID is not found, proceed to Edge Cases.

### Step 2: Read Master File

```bash
cat .opencode/.guidelines/fragment-id.md
```

Display full content with line numbers. The master file contains the authoritative version of the fragment content plus metadata comments at the end.

### Step 3: Show Destination Status

For each destination listed in the registry:

```bash
# Calculate actual destination hash
sha256sum "$dest_path"

# Compare to registry hash
```

Display per-destination status:

| Field | Source |
|-------|--------|
| Path | Registry `destinations[].path` |
| Lines | Registry `destinations[].line_range` |
| Registry Hash | Registry `destinations[].hash` |
| Actual Hash | Live `sha256sum` |
| Status | MATCH or MISMATCH |

### Step 4: Report

Display consolidated report:

- Fragment ID
- Master file path and hash
- Content (full, with line numbers)
- Destinations (list with hashes and line ranges)
- Sync status summary (synchronized / drifted / conflicted)
- Recommendation if drift detected

### Step 5: Drift Analysis (Automatic)

If any destination hash differs from master hash, report drift:

```
⚠️ DRIFT DETECTED

Fragment: {fragment-id}
Drifted destinations: {count}
Total destinations: {count}

Recommend: Run 'check-drift {fragment-id}' for detailed analysis
```

## Key Principles

### Read-Only Guarantee

This task never modifies any file. It reads the master, reads destinations, and reports status. If drift is detected, it recommends `check-drift` or `sync-fragment` tasks — it does not modify destinations directly.

### Master as Authority

The master file hash is the reference point for all drift comparisons. The `registry.yaml` stores the last-known master hash, and the live `sha256sum` of the master file is the current authoritative hash. If these differ, the registry itself needs updating via `update-fragment`.

### Content Reading Is Mandatory

This task reads the actual content of the master file and each destination file using the `read` tool. It does not rely solely on hash comparisons — the content must be displayed so the operator can verify what the fragment contains and whether destinations contain the expected content. Hash-only comparison would miss structural issues like comment corruption or marker deletion.

## Output Formats

| Format | Use Case |
|--------|---------|
| Default (text) | Interactive fragment inspection — shows content, hashes, and drift |
| Verbose | Include full destination content comparison — for detailed auditing |
| JSON | Programmatic access via scripts — structured data for automation |

## Result Contract

```yaml
status: DONE | NOT_FOUND | ERROR
task: read-fragment
fragment_id: <str>
master_path: <str>
master_hash: <str>
destinations_count: <int>
drift_detected: bool
drifted_destinations: [<path>, ...]
sync_status: <synchronized|drifted|conflicted>
```

## Edge Cases

### Fragment Not Found

If fragment ID not in registry:

1. STOP - fragment does not exist
2. Report: "Fragment with ID '{id}' not found in registry."
3. Suggest: "Use 'create-fragment' to create it, or check the ID spelling."

### Master File Missing

If registry entry exists but master file is missing from disk:

1. WARN: "Master file missing at {path}"
2. Report the registry entry still exists
3. Suggest: "Registry references missing file. Recreate from destinations or remove fragment from registry?"
4. Do NOT delete the registry entry automatically

### Destination File Missing

If a destination file in the registry no longer exists:

1. WARN: "Destination file missing: {path}"
2. Mark destination as `deleted` in report
3. Suggest: "Remove from registry or recreate file"

### Registry Corrupted

If YAML parsing fails:

1. STOP - do not proceed
2. Report: "Registry YAML parse error: {error}"
3. Recommend: Manual inspection and repair of registry.yaml