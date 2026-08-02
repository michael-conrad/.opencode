---
plan_schema_version: "1.0"
issue: 2220
title: "Reduce approval-gate ceremony: 53 files → ~6 files"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 6
---

# Implementation Plan — #2220 — Reduce approval-gate ceremony: 53 files → ~6 files

**Goal:** Consolidate the approval-gate skill hierarchy from 53 files across 4 directory levels to ~6 files in 1 flat directory, eliminating ceremony and redundant concern boundaries.

**Architecture:** Merge `approval-gate-scope/SKILL.md` content into `approval-gate/SKILL.md`, delete all 47 task/enforcement files that belong to other concerns, keep only the core 3-step path (resolve scope → apply label → route), and update all cross-references. The merged SKILL.md retains the authorization scope model, bug discovery protocol, and DISPATCH_GATE protocol as inline sections.

**Files:**
- `.opencode/skills/approval-gate/SKILL.md`
- `.opencode/skills/approval-gate-scope/` (entire directory — deleted)
- `.opencode/guidelines/000-critical-rules.md`
- `.opencode/guidelines/010-approval-gate.md`
- `.opencode/tests-v2/behaviors/approval-gate-scope-routing.sh`
- `.opencode/tests-v2/behaviors/fast-path-workflow-reorder.sh`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1a — Merge SKILL.md content | `test-driven-development` | `red`/`green` | `approval-gate/SKILL.md` | SC-1 | — |
| 1b — Update dispatch calls | `test-driven-development` | `red`/`green` | dispatch calls in guidelines | SC-3 | 1a |
| 2 — Delete files | `test-driven-development` | `red`/`green` | `approval-gate-scope/` directory | SC-2, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9 | 1b |
| 3a — Update cross-references | `test-driven-development` | `red`/`green` | cross-references | SC-10 | 2 |
| 3b — Update behavioral tests | `test-driven-development` | `red`/`green` | behavioral tests | SC-11 | 3a |
| 3c — Final sweep | `test-driven-development` | `red`/`green` | final verification | SC-12 | 3b |

---

## Phase Details

### Phase 1a — Merge SKILL.md Content

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | `approval-gate/SKILL.md` |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```yaml
merge_source: .opencode/skills/approval-gate-scope/SKILL.md
merge_target: .opencode/skills/approval-gate/SKILL.md
required_sections:
  - routing_metadata: [Trigger Dispatch Table, Invocation section, DISPATCH_GATE protocol]
  - scope_model: [Authorization Scope Model table, verb-prefix parsing table, halt_at values]
  - bug_discovery_protocol: [Bug Discovery Protocol section]
  - dispatch_gate_protocol: [Orchestrator Entry Criteria, DISPATCH_GATE Checkpoint Procedure]
```

**Procedure:**

- [ ] 1. Read `approval-gate-scope/SKILL.md` to extract all 4 required section groups (routing metadata, scope model, bug discovery protocol, DISPATCH_GATE protocol)
- [ ] 2. Read `approval-gate/SKILL.md` to identify insertion points for each section group
- [ ] 3. Merge routing metadata section (Trigger Dispatch Table, Invocation, DISPATCH_GATE) into `approval-gate/SKILL.md`
- [ ] 4. Merge scope model section (Authorization Scope Model table, verb-prefix parsing table, halt_at values) into `approval-gate/SKILL.md`
- [ ] 5. Merge bug discovery protocol section into `approval-gate/SKILL.md`
- [ ] 6. Merge DISPATCH_GATE protocol section (Orchestrator Entry Criteria, Checkpoint Procedure) into `approval-gate/SKILL.md`
- [ ] 7. Verify all 4 section groups are present in the merged `approval-gate/SKILL.md`
- [ ] 8. Run content-verification enforcement tests to confirm no regressions

### Phase 1b — Update Dispatch Calls

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | dispatch calls in guidelines |
| SCs | SC-3 |
| Depends On | 1a |

**Context:**
```yaml
dispatch_update_files:
  - .opencode/skills/approval-gate/SKILL.md
  - .opencode/guidelines/000-critical-rules.md
```

**Procedure:**

- [ ] 1. Search for all `skill({name: 'approval-gate-scope'})` patterns in `.opencode/` files
- [ ] 2. Update each occurrence to `skill({name: 'approval-gate'})` in the merged `approval-gate/SKILL.md`
- [ ] 3. Update each occurrence in `.opencode/guidelines/000-critical-rules.md`
- [ ] 4. Update each occurrence in `.opencode/guidelines/010-approval-gate.md`
- [ ] 5. Verify no remaining `skill({name: 'approval-gate-scope'})` calls exist in any `.opencode/` file

### Phase 2 — Delete Files

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | `approval-gate-scope/` directory |
| SCs | SC-2, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9 |
| Depends On | 1b |

**Context:**
```yaml
delete_targets:
  - .opencode/skills/approval-gate-scope/SKILL.md
  - .opencode/skills/approval-gate-scope/tasks/ (22 files)
  - .opencode/skills/approval-gate-scope/enforcement/ (5 files)
  - .opencode/skills/approval-gate-scope/tasks/verify-authorization/ (13 files)
  - .opencode/skills/approval-gate-scope/tasks/screen/ (2 files)
  - .opencode/skills/approval-gate-scope/tasks/gap-fill-cascade/ (3 files)
  - .opencode/skills/approval-gate-scope/tasks/pre-impl/ (6 files)
```

**Procedure:**

- [ ] 1. Delete `approval-gate-scope/SKILL.md`
- [ ] 2. Delete all 22 task files under `approval-gate-scope/tasks/`
- [ ] 3. Delete all 5 enforcement files under `approval-gate-scope/enforcement/`
- [ ] 4. Delete all 13 verify-authorization sub-task files
- [ ] 5. Delete all 2 screen sub-task files
- [ ] 6. Delete all 3 gap-fill-cascade sub-task files
- [ ] 7. Delete all 6 pre-impl sub-task files
- [ ] 8. Verify the `approval-gate-scope/` directory no longer exists
- [ ] 9. Run `git status` to confirm all deletions are staged correctly

### Phase 3a — Update Cross-References

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | cross-references |
| SCs | SC-10 |
| Depends On | 2 |

**Context:**
```yaml
cross_reference_files:
  - .opencode/guidelines/000-critical-rules.md
  - .opencode/skills/approval-gate/SKILL.md
```

**Procedure:**

- [ ] 1. Search for all references to deleted task file paths (e.g., `approval-gate-scope/tasks/`) in `.opencode/` files
- [ ] 2. Update each reference in `.opencode/guidelines/000-critical-rules.md` to point to the merged location or remove it
- [ ] 3. Update each reference in `.opencode/skills/approval-gate/SKILL.md` to point to the merged location or remove it
- [ ] 4. Verify no remaining references to deleted `approval-gate-scope/tasks/` paths exist

### Phase 3b — Update Behavioral Tests

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | behavioral tests |
| SCs | SC-11 |
| Depends On | 3a |

**Context:**
```yaml
behavioral_test_files:
  - .opencode/tests-v2/behaviors/approval-gate-scope-routing.sh
  - .opencode/tests-v2/behaviors/fast-path-workflow-reorder.sh
```

**Procedure:**

- [ ] 1. Read `approval-gate-scope-routing.sh` and update all `skill({name: 'approval-gate-scope'})` assertions to `skill({name: 'approval-gate'})`
- [ ] 2. Read `fast-path-workflow-reorder.sh` and update any references to the old skill name
- [ ] 3. Run both behavioral tests to confirm they pass with the merged skill dispatch
- [ ] 4. Fix any test failures and re-run until all pass

### Phase 3c — Final Sweep

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | final verification |
| SCs | SC-12 |
| Depends On | 3b |

**Context:**
```yaml
final_sweep_pattern: approval-gate-scope
```

**Procedure:**

- [ ] 1. Search for pattern `approval-gate-scope` across all `.opencode/` files
- [ ] 2. For each remaining occurrence, determine if it is a false positive (e.g., changelog entry) or a missed reference
- [ ] 3. Fix any missed references found in step 2
- [ ] 4. Re-run the search to confirm zero remaining actionable references
- [ ] 5. Run the full enforcement test suite to confirm no regressions

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-02T01:21:00Z | `plan_created` | Plan file: `.opencode/.issues/2220/plan.md`, Phase count: 6 |

## Exit Criteria

- [ ] C1. Phase 1a complete: `approval-gate/SKILL.md` contains all 4 section groups from `approval-gate-scope/SKILL.md` (routing metadata, scope model, bug discovery protocol, DISPATCH_GATE protocol)
- [ ] C2. Phase 1b complete: all `skill({name: 'approval-gate-scope'})` calls updated to `skill({name: 'approval-gate'})`
- [ ] C3. Phase 2 complete: `approval-gate-scope/SKILL.md` deleted
- [ ] C4. Phase 2 complete: all 22 task files under `approval-gate-scope/tasks/` deleted
- [ ] C5. Phase 2 complete: all 5 enforcement files under `approval-gate-scope/enforcement/` deleted
- [ ] C6. Phase 2 complete: all 13 verify-authorization sub-task files deleted
- [ ] C7. Phase 2 complete: all 2 screen sub-task files deleted
- [ ] C8. Phase 2 complete: all 3 gap-fill-cascade sub-task files deleted
- [ ] C9. Phase 2 complete: all 6 pre-impl sub-task files deleted
- [ ] C10. Phase 3a complete: all cross-references to deleted task files updated or removed
- [ ] C11. Phase 3b complete: behavioral enforcement tests updated to use merged skill dispatch
- [ ] C12. Phase 3c complete: no remaining references to `approval-gate-scope` in any `.opencode/` file
