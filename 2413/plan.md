---
plan_schema_version: "1.0"
issue: 2413
title: "Fix interface-compatibility.yaml: emit dependency_contract section from spec-creation pipeline"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — #2413 — Fix interface-compatibility.yaml dependency_contract emission

**Goal:** Ensure spec-creation-generated `interface-compatibility.yaml` always contains a `dependency_contract` section so writing-plans research step 9 does not hard-block with `DEPENDENCY_CONTRACT_NOT_FOUND`.

**Architecture:** Two complementary fixes: (1) the forward spec-creation artifact-generation step emits a `dependency_contract` section populated with concrete dependency data extracted from the existing `interfaces`/`removed_interfaces`/`breaking_changes` keys, and (2) `research.md` step 9 detects a missing `dependency_contract` and auto-backfills it from the existing artifact keys instead of hard-blocking. Phase 3 cross-verifies that both sides agree on the `interface-compatibility.yaml` schema.

**Files:**
- `.opencode/skills/spec-creation/tasks/analyze.md`
- `.opencode/skills/brainstorming/` (top-down-analysis artifact production)
- `.opencode/skills/writing-plans/tasks/research.md`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Forward spec-creation artifact | `test-driven-development` | `red` → `green` → `verify` → `commit-inline` | `.opencode/skills/spec-creation/tasks/analyze.md` | SC-1 | — |
| 2 — Research.md auto-backfill | `test-driven-development` | `red` → `green` → `verify` → `commit-inline` | `.opencode/skills/writing-plans/tasks/research.md` | SC-3 | — |
| 3 — Schema agreement verification | `test-driven-development` | `red` → `green` → `verify` → `commit-inline` | Contract templates | SC-2 | 1 |

---

## Phase Details

### Phase 1 — Forward spec-creation artifact generation — emit dependency_contract

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` → `green` → `verify` → `commit-inline` |
| Target | `.opencode/skills/spec-creation/tasks/analyze.md` |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```
issue_number: 2413
target_file: .opencode/skills/spec-creation/tasks/analyze.md
sc_id: SC-1
description: >
  Ensure spec-creation-generated interface-compatibility.yaml always contains a
  dependency_contract section with concrete dependency data extracted from the
  existing interface/removed_interfaces/breaking_changes keys.
contract_template_dir: .opencode/skills/writing-plans/contracts/
```

### Phase 2 — Research.md step 9 adaptation — validate or auto-backfill dependency_contract

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` → `green` → `verify` → `commit-inline` |
| Target | `.opencode/skills/writing-plans/tasks/research.md` |
| SCs | SC-3 |
| Depends On | — (independent of Phase 1) |

**Context:**
```
issue_number: 2413
target_file: .opencode/skills/writing-plans/tasks/research.md
sc_id: SC-3
description: >
  Modify research.md step 9 to detect missing dependency_contract section and
  auto-backfill from existing interface/removed_interfaces/breaking_changes keys
  instead of hard-blocking with DEPENDENCY_CONTRACT_NOT_FOUND.
```

### Phase 3 — Producer-consumer schema agreement verification

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` → `green` → `verify` → `commit-inline` |
| Target | Contract templates |
| SCs | SC-2 |
| Depends On | 1 |

**Context:**
```
issue_number: 2413
sc_id: SC-2
description: >
  Verify the dependency_contract section structure emitted by the spec-creation
  pipeline matches the contract schema templates expected by solve/plan tools.
  Run a RED test comparing the Phase 1 artifact output against writing-plans
  contracts/ templates.
```

---

## Exit Criteria

- [ ] C1. Phase 1 writes `dependency_contract` section to spec-creation-generated `interface-compatibility.yaml` (or Phase 2 research.md auto-backfills instead of hard-blocking)
- [ ] C2. Phase 2 research.md step 9 auto-backfills `dependency_contract` from existing keys when section is missing
- [ ] C3. Phase 3 confirms spec-creation producer and writing-plans research consumer agree on `interface-compatibility.yaml` schema
- [ ] C4. Plan creation for a spec with forward-spec-creation-generated `interface-compatibility.yaml` proceeds without `DEPENDENCY_CONTRACT_NOT_FOUND`
- [ ] C5. No regression of closed #2311 / PR #2316 backfill fix
