# Task: status-report

## Purpose

Show sync status overview for all fragments. This task provides a comprehensive view of the fragment registry, showing which fragments are synchronized, which have drifted, and which need attention.

## Entry Criteria

- Registry exists (`.opencode/.guidelines/registry.yaml`)
- At least one fragment defined

## Procedure

### Step 1: Load Registry

```bash
cat .opencode/.guidelines/registry.yaml
```

Parse all fragments from the registry. For each fragment, extract:
- Fragment ID
- Master file path and hash
- Destination list with paths and hashes
- Sync status
- Last sync timestamp

### Step 2: Run Quick Drift Check

For each fragment:

- **Calculate master hash** from the current master file:
  ```bash
  sha256sum .opencode/.guidelines/fragment-id.md
  ```

- **Check if master hash matches registry** — compare calculated hash against stored hash
- **Flag fragments** where the master has changed since last sync (registry hash != file hash)
- **Check each destination** — calculate destination hash and compare to master

### Step 3: Categorize Fragments

Group fragments by their sync status:

| Status | Meaning | Icon |
|--------|---------|------|
| `synchronized` | All destinations match master | ✅ |
| `drifted` | One or more destinations differ from master | ⚠️ |
| `conflicted` | Destinations have manual edits that conflict with master | 🔴 |
| `unknown` | Hash comparison not yet performed | ❓ |

### Step 4: Generate Summary Report

```
Fragment Registry Status Report
==============================

Generated: YYYY-MM-DD HH:MM:SS
Registry version: 2
Schema version: 2.0.0

Summary
-------
Total fragments: 9
Synchronized: 8
Drifted: 1
Conflicted: 0

Fragments
---------

1. branch-first-protocol ✅
   Master: .opencode/.guidelines/branch-first-protocol.md
   Destinations: 1
   Last sync: 2026-04-06T21:15:00Z

2. commit-workflow ✅
   Master: .opencode/.guidelines/commit-workflow.md
   Destinations: 1
   Last sync: 2026-04-06T21:15:00Z

... (remaining fragments)

Drifted Fragments
-----------------

⚠️ pr-workflow (DRIFTED)
   Master hash: abc123...
   Destination 1 (git-workflow/tasks/pr-creation.md): def456... (MISMATCH)
   Destination 2 (pr-creation-workflow/SKILL.md): abc123... (match)

   Recommendation: Run 'sync-fragment pr-workflow' to synchronize

Actions Needed
--------------

1 fragment needs attention:
  - pr-workflow: Run check-drift for details, then sync or resolve conflict

Run '/skill fragment-manager --task check-drift' for detailed drift analysis.
```

## Output Formats

### Compact (default)

One-line per fragment with status emoji:

```
1. branch-first-protocol ✅ (1 dest, synced 2026-04-06)
2. commit-workflow ✅ (1 dest, synced 2026-04-06)
3. pr-workflow ⚠️ (2 dest, DRIFTED)
```

### Verbose

Full report including last modified dates, hash values, and line ranges for each destination. This is the default format shown above.

### JSON Export

For programmatic access, use the registry tool or write a script:

```bash
# Use the guidelines tool for structured output
./.opencode/tools/guidelines read registry.yaml
# For custom export, write a parser script to ./tmp/ and run it
```

## Edge Cases

### Empty Registry

If no fragments are defined:

```
Fragment Registry Status Report
==============================

Registry: EMPTY

No fragments tracked yet.
Run 'create-fragment' to add the first fragment master.
```

This is informational — not an error condition.

### Registry Corrupted

If YAML parsing fails:

1. STOP - do not proceed
2. Report: "Registry YAML parse error: {error}"
3. Recommend: Manual inspection and repair of `.opencode/.guidelines/registry.yaml`
4. Do NOT attempt to auto-repair the registry — this could cause data loss

### Master File Missing

If a fragment's master file path in the registry points to a file that doesn't exist:

1. WARN: "Master file missing for fragment '{fragment-id}'"
2. Show the registry entry with `❓` status
3. Recommend: Run `update-fragment` to recreate the master, or delete the registry entry

### Destination File Missing

If a destination path in the registry doesn't exist on disk:

1. Show the destination with `❌` status (deleted)
2. Recommend: Remove from registry or recreate the destination file