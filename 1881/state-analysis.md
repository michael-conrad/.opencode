# State Analysis — Migration from Overloaded Skills to Dispatcher + Sub-Skills

## State Model

Each skill has a lifecycle state. The migration transitions each overloaded skill from a **monolithic state** to a **dispatcher + sub-skills state**.

### State Definitions

| State | Description |
|---|---|
| `MONOLITHIC` | Single SKILL.md with all task files in `tasks/` directory |
| `DISPATCHER` | SKILL.md with routing table only, no task files, delegates to sub-skills |
| `SUB_SKILL` | Focused SKILL.md with <15 task files, single concern |
| `MIGRATING` | Both old and new structures exist temporarily (transition state) |
| `DELETED` | Old task files removed after migration verified |

## Migration State Transitions

### issue-operations: MONOLITHIC → DISPATCHER + 4 SUB_SKILL

```
State: MONOLITHIC
  ├─ SKILL.md (44 tasks, 591 chars)
  ├─ tasks/ (21 files)
  └─ platforms/ (3 sub-skills, unchanged)

  │  Phase 1: Create sub-skills
  ▼
State: MIGRATING
  ├─ SKILL.md (monolithic, still active)
  ├─ tasks/ (21 files, still active)
  ├─ platforms/ (3 sub-skills, unchanged)
  ├─ issue-operations-core/SKILL.md + tasks/  [NEW]
  ├─ issue-operations-sub-issues/SKILL.md + tasks/  [NEW]
  ├─ issue-operations-sync/SKILL.md + tasks/  [NEW]
  └─ issue-operations-comments/SKILL.md + tasks/  [NEW]

  │  Phase 2: Convert to dispatcher
  ▼
State: DISPATCHER + 4 SUB_SKILL
  ├─ SKILL.md (dispatcher, routing only)
  ├─ tasks/ (DELETED — migrated to sub-skills)
  ├─ platforms/ (3 sub-skills, unchanged)
  ├─ issue-operations-core/ (SUB_SKILL, ~12 tasks)
  ├─ issue-operations-sub-issues/ (SUB_SKILL, ~8 tasks)
  ├─ issue-operations-sync/ (SUB_SKILL, ~8 tasks)
  └─ issue-operations-comments/ (SUB_SKILL, ~6 tasks)
```

### approval-gate: MONOLITHIC → DISPATCHER + 4 SUB_SKILL

```
State: MONOLITHIC
  ├─ SKILL.md (40 tasks, 625 chars)
  └─ tasks/ (16 files + 3 dirs)

  │  Phase 1: Create sub-skills
  ▼
State: MIGRATING
  ├─ SKILL.md (monolithic, still active)
  ├─ tasks/ (16 files + 3 dirs, still active)
  ├─ approval-gate-scope/SKILL.md + tasks/  [NEW]
  ├─ approval-gate-labels/SKILL.md + tasks/  [NEW]
  ├─ approval-gate-revision/SKILL.md + tasks/  [NEW]
  └─ approval-gate-bug-discovery/SKILL.md + tasks/  [NEW]

  │  Phase 2: Convert to dispatcher
  ▼
State: DISPATCHER + 4 SUB_SKILL
  ├─ SKILL.md (dispatcher, routing only)
  ├─ tasks/ (DELETED — migrated to sub-skills)
  ├─ approval-gate-scope/ (SUB_SKILL, ~10 tasks)
  ├─ approval-gate-labels/ (SUB_SKILL, ~8 tasks)
  ├─ approval-gate-revision/ (SUB_SKILL, ~8 tasks)
  └─ approval-gate-bug-discovery/ (SUB_SKILL, ~6 tasks)
```

### git-workflow: MONOLITHIC → DISPATCHER + 5 SUB_SKILL

```
State: MONOLITHIC
  ├─ SKILL.md (30 tasks, 530 chars)
  └─ tasks/ (16 files + 4 dirs)

  │  Phase 1: Create sub-skills
  ▼
State: MIGRATING
  ├─ SKILL.md (monolithic, still active)
  ├─ tasks/ (16 files + 4 dirs, still active)
  ├─ git-workflow-branch/SKILL.md + tasks/  [NEW]
  ├─ git-workflow-commit/SKILL.md + tasks/  [NEW]
  ├─ git-workflow-pr/SKILL.md + tasks/  [NEW]
  ├─ git-workflow-cleanup/SKILL.md + tasks/  [NEW]
  └─ git-workflow-conflict/SKILL.md + tasks/  [NEW]

  │  Phase 2: Convert to dispatcher
  ▼
State: DISPATCHER + 5 SUB_SKILL
  ├─ SKILL.md (dispatcher, routing only)
  ├─ tasks/ (DELETED — migrated to sub-skills)
  ├─ git-workflow-branch/ (SUB_SKILL, ~6 tasks)
  ├─ git-workflow-commit/ (SUB_SKILL, ~6 tasks)
  ├─ git-workflow-pr/ (SUB_SKILL, ~6 tasks)
  ├─ git-workflow-cleanup/ (SUB_SKILL, ~6 tasks)
  └─ git-workflow-conflict/ (SUB_SKILL, ~6 tasks)
```

### writing-plans: MONOLITHIC → DISPATCHER + 3 SUB_SKILL

```
State: MONOLITHIC
  ├─ SKILL.md (19 tasks, 795 chars)
  └─ tasks/ (18 files + 1 dir)

  │  Phase 1: Create sub-skills
  ▼
State: MIGRATING
  ├─ SKILL.md (monolithic, still active)
  ├─ tasks/ (18 files + 1 dir, still active)
  ├─ writing-plans-creation/SKILL.md + tasks/  [NEW]
  ├─ writing-plans-holistic/SKILL.md + tasks/  [NEW]
  └─ writing-plans-retroactive/SKILL.md + tasks/  [NEW]

  │  Phase 2: Convert to dispatcher
  ▼
State: DISPATCHER + 3 SUB_SKILL
  ├─ SKILL.md (dispatcher, routing only)
  ├─ tasks/ (DELETED — migrated to sub-skills)
  ├─ writing-plans-creation/ (SUB_SKILL, ~7 tasks)
  ├─ writing-plans-holistic/ (SUB_SKILL, ~6 tasks)
  └─ writing-plans-retroactive/ (SUB_SKILL, ~6 tasks)
```

### spec-creation: MONOLITHIC → DISPATCHER + 4 SUB_SKILL

```
State: MONOLITHIC
  ├─ SKILL.md (17 tasks, 898 chars)
  └─ tasks/ (17 files)

  │  Phase 1: Create sub-skills
  ▼
State: MIGRATING
  ├─ SKILL.md (monolithic, still active)
  ├─ tasks/ (17 files, still active)
  ├─ spec-creation-requirements/SKILL.md + tasks/  [NEW]
  ├─ spec-creation-decomposition/SKILL.md + tasks/  [NEW]
  ├─ spec-creation-validation/SKILL.md + tasks/  [NEW]
  └─ spec-creation-change-control/SKILL.md + tasks/  [NEW]

  │  Phase 2: Convert to dispatcher
  ▼
State: DISPATCHER + 4 SUB_SKILL
  ├─ SKILL.md (dispatcher, routing only)
  ├─ tasks/ (DELETED — migrated to sub-skills)
  ├─ spec-creation-requirements/ (SUB_SKILL, ~5 tasks)
  ├─ spec-creation-decomposition/ (SUB_SKILL, ~5 tasks)
  ├─ spec-creation-validation/ (SUB_SKILL, ~4 tasks)
  └─ spec-creation-change-control/ (SUB_SKILL, ~3 tasks)
```

## Migration Order (Dependency Chain)

```
Phase 1: Prerequisite Fix
  └─ skill-creator/tasks/validate.md REQ-2
      └─ Must accept Agent-Intent Pattern as valid format
          └─ Without this, new sub-skill SKILL.md files fail validation

Phase 2: Create Sub-Skills (in any order — no cross-dependencies)
  ├─ issue-operations-* (4 sub-skills)
  ├─ approval-gate-* (4 sub-skills)
  ├─ git-workflow-* (5 sub-skills)
  ├─ writing-plans-* (3 sub-skills)
  └─ spec-creation-* (4 sub-skills)

Phase 3: Convert Originals to Dispatchers
  ├─ issue-operations/SKILL.md → dispatcher
  ├─ approval-gate/SKILL.md → dispatcher
  ├─ git-workflow/SKILL.md → dispatcher
  ├─ writing-plans/SKILL.md → dispatcher
  └─ spec-creation/SKILL.md → dispatcher

Phase 4: Update Cross-References
  ├─ implementation-pipeline SKILL.md
  ├─ audit SKILL.md
  ├─ AGENTS.md (root + .opencode)
  ├─ INDEX.md
  └─ Enforcement test scenarios

Phase 5: Delete Old Task Files
  ├─ issue-operations/tasks/* (after verifying all routes work)
  ├─ approval-gate/tasks/* (after verifying all routes work)
  ├─ git-workflow/tasks/* (after verifying all routes work)
  ├─ writing-plans/tasks/* (after verifying all routes work)
  └─ spec-creation/tasks/* (after verifying all routes work)

Phase 6: Verification
  ├─ Behavioral tests: all original trigger phrases still work
  ├─ Content-verification: all sub-skills registered in skill deck
  └─ Cross-reference audit: no stale references to old task paths
```

## Rollback Plan

If migration fails at any phase:
1. **Phase 1-2 failure**: Delete new sub-skill directories. Original skills untouched.
2. **Phase 3 failure**: Revert dispatcher SKILL.md to monolithic version. Sub-skills remain but are unused.
3. **Phase 4 failure**: Revert cross-references. Sub-skills and dispatchers remain but external callers use old paths.
4. **Phase 5 failure**: Do NOT delete old task files. Revert to Phase 3 state.
5. **Phase 6 failure**: Full rollback — revert all changes, restore from backup branch.
