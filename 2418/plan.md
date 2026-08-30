---
plan_schema_version: "1.0"
issue: 2418
title: "[SPEC-FIX] git-workflow-cleanup: orchestrator pre-investigation reverses submodule-first ordering"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — #2418 — Fix git-workflow-cleanup orchestrator pre-investigation and submodule-first ordering

**Goal:** Eliminate orchestrator inline git/gh investigation before cleanup sub-agent dispatch, add guard notes against the pattern, and reinforce submodule-first result contract ordering.

**Architecture:** Three independent-but-sequential changes: (1) replace the `concat()` dispatch prompt in SKILL.md with a `pr_merged_event: true` flag, (2) add a guard note in `cleanup.md` Step 0 plus a behavioral enforcement test, (3) reinforce submodule-first ordering in the result contract reporting sections.

**Files:**
- `.opencode/skills/git-workflow-cleanup/SKILL.md`
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md`
- `.opencode/tests-v2/behaviors/` (new behavioral test file)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — DISPATCH_PROTOCOL | `test-driven-development` | `red` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | SC-1 | — |
| 2 — ORCHESTRATOR_GUARD | `test-driven-development` | `green` | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md`, `.opencode/tests-v2/behaviors/` | SC-2, SC-4 | 1 |
| 3 — RESULT_ORDERING | `test-driven-development` | `verify` | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` | SC-3 | 2 |

---

## Phase Details

### Phase 1 — DISPATCH_PROTOCOL

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/git-workflow-cleanup/SKILL.md` |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```yaml
files_to_modify:
  - .opencode/skills/git-workflow-cleanup/SKILL.md
change: "Replace concat() dispatch prompt with pr_merged_event: true flag"
removals:
  - pr_merge_status from Workflows context
  - branch_name from Workflows context
sc_ids: [SC-1]
```

### Phase 2 — ORCHESTRATOR_GUARD

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md`, `.opencode/tests-v2/behaviors/` |
| SCs | SC-2, SC-4 |
| Depends On | 1 |

**Context:**
```yaml
files_to_modify:
  - .opencode/skills/git-workflow-cleanup/tasks/cleanup.md
  - .opencode/tests-v2/behaviors/ (new file)
sc_ids: [SC-2, SC-4]
guard_note: "Step 0: explicit guard note against orchestrator pre-investigation"
behavioral_test: "Verify no git/gh tool calls appear before dispatch (opencode run + stderr inspection)"
```

### Phase 3 — RESULT_ORDERING

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `verify` |
| Target | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` |
| SCs | SC-3 |
| Depends On | 2 |

**Context:**
```yaml
files_to_modify:
  - .opencode/skills/git-workflow-cleanup/tasks/cleanup.md
ordering_change: "Reinforce submodule-first ordering in result contract reporting sections"
sc_ids: [SC-3]
```

---

## Exit Criteria

- [ ] C1. SC-1: SKILL.md dispatch prompt uses `pr_merged_event: true` instead of `concat()` with pre-resolved values — verified by grep
- [ ] C2. SC-2: Behavioral test passes — verified by `opencode run` + stderr inspection showing no git/gh calls before dispatch
- [ ] C3. SC-3: Cleanup.md result contract sections list submodules before parent repo — verified by reading cleanup.md
- [ ] C4. SC-4: cleanup.md Step 0 contains explicit guard note against orchestrator pre-investigation — verified by grep
