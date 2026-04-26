---
name: fragment-manager
description: Use when managing duplicate content blocks (fragments) across guidelines or skills. Triggers on: fragment, duplicate content, sync content, content block, shared content, master copy, synchronize.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: fragment-manager

## Overview

Fragment Manager handles duplicate text blocks (fragments) that appear in multiple skills. It provides:

- CRUD operations on fragment master files in `.opencode/.guidelines/`
- Synchronization from masters to destination copies
- Drift detection between masters and copies
- Conflict resolution when changes diverge

## Architecture

**Fragment Registry Schema:**

- `.opencode/.guidelines/registry.yaml` - Tracks fragment masters and destinations
- `.opencode/.guidelines/*.md` - Fragment master files (golden copies)
- `.opencode/skills/*/SKILL.md` - Destination copies (embedded in skills)

**Key Principles:**

- Skills remain self-contained (copies, not references)
- Masters are minimal (content blocks only, no context)
- Syncs require verification (hash matching)
- Conflicts require human intervention

## Tasks

| Task | Purpose | When to Use |
| -- | -- | -- |
| `create-fragment` | Create new fragment master from existing content | When duplicate content is found in skills |
| `read-fragment` | Read fragment master content | When inspecting fragment details |
| `update-fragment` | Update master content | When master needs changes |
| `delete-fragment` | Delete fragment master and registry entry | When fragment is obsolete |
| `sync-fragment` | Copy master to all destinations | When masters are updated |
| `check-drift` | Detect drift between masters and copies | Periodic validation, before syncs |
| `status-report` | Show sync status for all fragments | Overview of fragment health |
| `resolve-conflict` | Handle merge conflicts | When drift is detected |
| `completion` | Ensure mandatory terminal-state dispatch occurred; remediate if not; report status | ≈200 |

## Invocation

- `/skill fragment-manager --task create-fragment` - Create new fragment
- `/skill fragment-manager --task sync-fragment` - Sync master to destinations
- `/skill fragment-manager --task check-drift` - Detect drift
- `/skill fragment-manager --task status-report` - Overview
- `/skill fragment-manager --task completion` - Invoke when workflow halts at any point
- `/skill fragment-manager` - Skill overview only

## Operating Protocol

1. **Read registry first**: Always load `.opencode/.guidelines/registry.yaml`
2. **Verify hashes**: Compare SHA256 of master vs destinations
3. **Stop on conflicts**: If drift detected, ASK before proceeding
4. **Preserve backups**: Keep `.opencode/.backups/` before dangerous operations
5. **Update registry**: After any operation, update timestamp and status

## Conflict Resolution Protocol

**When to STOP and ASK:**

1. Destination content differs from master AND master unchanged
2. File structure changed (lines shifted, sections reorganized)
3. Registry has conflicts (ambiguous ID, cyclic dependency)
4. Sync fails for any destination

**Confirmation Format:**

```
⚠️ CONFLICT DETECTED

Fragment: {fragment_id}
Conflict: {edge_case_description}

Detection:
- Master hash: {master_hash}
- Destination hash: {dest_hash}
- Line range: {start}-{end}

Options:
a) Overwrite destination with master
b) Keep destination version (update master?)
c) Mark for manual resolution
d) Abort operation

Your choice:
```

## Registry Schema (v2)

```yaml
version: 2
schema_version: 2.0.0
last_updated: YYYY-MM-DD

fragments:
  - id: fragment-name
    master:
      path: .opencode/.guidelines/fragment-name.md
      hash: sha256:abc123...
      last_modified: YYYY-MM-DDTHH:MM:SSZ
      lines: NN
    content:
      type: text-block
      estimated_words: NNN
      description: Fragment description
    destinations:
      - path: .opencode/skills/skill-name/SKILL.md
        hash: sha256:abc123...
        line_range:
          start: N
          end: N
        verified_date: YYYY-MM-DDTHH:MM:SSZ
    sync_status: synchronized
    last_sync: YYYY-MM-DDTHH:MM:SSZ
    notes: Fragment notes
```

## Cross-References

- Related skills: `skill-creator` (fragment registration prompt)
- Related files: `.opencode/.guidelines/registry.yaml`, `.opencode/dispatch-table.yaml`

## Edge Cases

See individual task files for edge case handling protocols.

**⚠️ COMPLETION GUARANTEE:** If this workflow halts at ANY point — including error, failure, or early termination — you MUST invoke `--task completion` before halting. The completion subtask ensures mandatory steps are never skipped. It is idempotent and safe to invoke multiple times.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: fragment-mgr-001
    title: "Shared content blocks MUST have a master copy in .opencode/.guidelines/"
    conditions:
      all:
        - "duplicate_content_detected == true"
        - "master_copy_exists == false"
    actions:
      - INVOKE(create-fragment)
    conflicts_with: []
    requires: []
    triggers: []
    source: "fragment-manager/SKILL.md §Architecture"

  - id: fragment-mgr-002
    title: "Drift between master and destination MUST be resolved before sync"
    conditions:
      all:
        - "drift_detected == true"
        - "resolution_confirmed == false"
    actions:
      - HALT
      - ASK_BEFORE_PROCEEDING
    conflicts_with: []
    requires: []
    triggers: []
    source: "fragment-manager/SKILL.md §Conflict Resolution Protocol"

  - id: fragment-mgr-003
    title: "Registry MUST be updated after any fragment operation"
    conditions:
      all:
        - "fragment_operation_completed == true"
        - "registry_updated == false"
    actions:
      - UPDATE_REGISTRY
    conflicts_with: []
    requires: []
    triggers: []
    source: "fragment-manager/SKILL.md §Operating Protocol"

tasks:
  - id: create-fragment
    skill: fragment-manager
    preconditions:
      - "duplicate_content_found == true"
      - "no_existing_master == true"
    postconditions:
      - "master_file_created == true"
      - "registry_entry_created == true"
      - "destinations_registered == true"
    mandatory: false
    bypass_violation: "fragment created without master or registry"
    source: "fragment-manager/SKILL.md §Tasks"

  - id: sync-fragment
    skill: fragment-manager
    preconditions:
      - "master_exists == true"
      - "registry_loaded == true"
    postconditions:
      - "all_destinations_synchronized == true"
      - "hashes_verified == true"
    mandatory: false
    bypass_violation: "sync completed with hash mismatches"
    source: "fragment-manager/SKILL.md §Tasks"

  - id: check-drift
    skill: fragment-manager
    preconditions:
      - "registry_loaded == true"
    postconditions:
      - "all_fragments_checked == true"
      - "drift_report_generated == true"
    mandatory: false
    bypass_violation: "drift check incomplete"
    source: "fragment-manager/SKILL.md §Tasks"

decomposition: []
gates:
  - id: drift-resolution-gate
    type: precondition
    check: "no unresolved drift between master and destinations"
    on_fail: HALT
    source: "fragment-manager/SKILL.md §Conflict Resolution Protocol"
evidence_artifacts:
  - "registry.yaml updated timestamps"
  - "SHA256 hash comparison output"
```
