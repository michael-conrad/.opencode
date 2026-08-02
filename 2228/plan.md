---
plan_schema_version: "1.0"
issue: 2228
title: "Add structured result contract to pre-work 'Already Implemented' edge case"
authorization_scope: for_implementation
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — #2228 — Add Structured Result Contract to Pre-Work "Already Implemented" Edge Case

**Goal:** Add `already_implemented` to the yield-back contract status enum, add a YAML result contract block to the edge case section, and add a yield-back step before HALT so the orchestrator receives a clear structured signal when pre-work detects all changes are already present.

**Architecture:** Three additive changes to `.opencode/skills/git-workflow-branch/tasks/pre-work.md`:
1. Extend the yield-back contract status enum from `success | failure` to `success | failure | already_implemented`
2. Add a YAML result contract block (`status`, `issue`, `finding_summary`) to the edge case section
3. Add a yield-back step before the HALT step in the edge case procedure

All changes are additive — existing `success`/`failure` values and procedural steps remain unchanged.

**Files:**
- `.opencode/skills/git-workflow-branch/tasks/pre-work.md`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Status enum | `test-driven-development` | `red` | `pre-work.md` yield-back section | SC-1 | — |
| 2 — YAML contract | `test-driven-development` | `green` | `pre-work.md` edge case section | SC-2 | 1 |
| 3 — Yield-back step | `test-driven-development` | `green` | `pre-work.md` edge case procedure | SC-3 | — |

---

## Phase Details

### Phase 1 — Status Enum

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `pre-work.md` yield-back section (~line 452-453) |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```yaml
file: .opencode/skills/git-workflow-branch/tasks/pre-work.md
change: "Add `already_implemented` to yield-back contract status enum"
current_enum: "status: success | failure"
new_enum: "status: success | failure | already_implemented"
evidence_type: string
```

### Phase 2 — YAML Contract

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `pre-work.md` edge case section (~line 464-505) |
| SCs | SC-2 |
| Depends On | 1 |

**Context:**
```yaml
file: .opencode/skills/git-workflow-branch/tasks/pre-work.md
section: "edge case section (after 'Example Comment', before step 4)"
yaml_block:
  status: already_implemented
  issue: "<issue-number>"
  finding_summary: "All proposed changes already present. No modifications needed."
evidence_type: structural
```

### Phase 3 — Yield-Back Step

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `pre-work.md` edge case procedure (~line 503) |
| SCs | SC-3 |
| Depends On | — |

**Context:**
```yaml
file: .opencode/skills/git-workflow-branch/tasks/pre-work.md
section: "edge case procedure"
action: "Insert yield-back step before HALT step"
step_text: |
  - [ ] 4. **Yield result contract:**
     - Yield structured result contract to orchestrator
     - Include status, issue, finding_summary
renumber: "Existing step 4 (HALT) becomes step 5"
evidence_type: structural
```

---

## Exit Criteria

- [ ] C1. Yield-back contract status enum includes `already_implemented` alongside `success` and `failure`
- [ ] C2. Edge case section contains a YAML result contract block with `status: already_implemented` and fields (status, issue, finding_summary)
- [ ] C3. Edge case procedure includes a yield-back step before the HALT step
- [ ] C4. Existing `success` and `failure` status values remain unchanged
- [ ] C5. Phase 1 completes before Phase 2 (status enum must exist before YAML block references `already_implemented`)
