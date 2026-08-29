# Task: fragment-management

## Purpose

Manages duplicate content blocks (fragments) across skills: performs CRUD on fragment masters in `.opencode/.guidelines/`, syncs masters to destination copies, and runs drift detection against the fragment registry.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- Fragment name (`{fragment_name}`) provided in context
- Destination paths (`{destination_paths}`) provided in context
- Operation (`{operation}`) provided in context (create, read, update, delete, sync, drift-check)
- Worktree path (`{worktree.path}`) provided in context (prefix all paths when set)

If any entry criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Procedure

- [ ] 1. Read the fragment registry at `.opencode/.guidelines/registry.yaml` to load the fragment master paths, destination paths, hashes, and sync status.
- [ ] 2. **Master copy is the single source of truth:** edit the fragment master first — never edit a destination copy directly.
- [ ] 3. Perform the requested CRUD operation on the fragment master:
   - [ ] a. `create` — create the fragment master file under `.opencode/.guidelines/` and register it in `registry.yaml` with its destinations
   - [ ] b. `read` — read the fragment master content and its destinations
   - [ ] c. `update` — edit the master content, then propagate the change to all destination copies
   - [ ] d. `delete` — remove the fragment master and its destinations, and unregister it from `registry.yaml`
- [ ] 4. **Sync:** propagate the master content to each destination path, preserving the destination's line-range placement.
- [ ] 5. **Drift detection:** compare each destination copy against the master (hash comparison). Report any destination whose hash differs from the master as drift.
- [ ] 6. Update `registry.yaml` with the new hashes, `sync_status`, and `last_sync` timestamp after a successful sync.
- [ ] 7. Validate fragment references with `skill-creator/scripts/validate_skill_cards.py` where applicable.
- [ ] 8. Write the drift report and sync results to the evidence artifact.
- [ ] 9. Return the result contract.

## Exit Criteria

- Fragment CRUD operation complete on the master
- Master changes propagated to all destination copies (for create/update/delete)
- Drift report produced (empty = no drift)
- `registry.yaml` updated with current hashes and sync status
- Result contract returned

If any exit criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences of routing-significant output>"
artifact_path: "<path to the drift report / sync evidence on disk>"
blocker_reason: "<reason if BLOCKED>"
```

## Context Required

- Registry: `.opencode/.guidelines/registry.yaml` (fragment masters, destinations, hashes, sync status)
- Related task: `skill-creator/tasks/operating-protocol.md` (rule 4 master-copy discipline, rule 9 fragment registry)
- Related script: `skill-creator/scripts/validate_skill_cards.py` (fragment reference validation)
- Related guideline: `080-code-standards.md` (no hardcoded identity values, attribution)
