---
plan_schema_version: "1.0"
issue: 2232
title: "Fix writing-plans task cards: spec-is-not-tracking mandate, dependency-contract generation"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — #2232 — Fix writing-plans task cards

**Goal:** Fix two defects in `writing-plans` task cards that violate the spec-is-not-tracking-document mandate and create circular dependency deadlocks.

**Architecture:** (1) Replace `approved` frontmatter check in `analyze.md` with a check against `issue.yaml` labels. (2) Replace `dependency-contract.yaml` BLOCK in `research.md` with generation from `interface-compatibility.yaml` `dependency_contract` section. (3) Audit all task cards across `.opencode/skills/` for tracking-state-in-spec violations.

**Files:**
- `.opencode/skills/writing-plans/tasks/analyze.md`
- `.opencode/skills/writing-plans/tasks/research.md`
- `.opencode/skills/*/tasks/*.md` (audit scope)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — analyze.md frontmatter fix | `test-driven-development` | `red` | `.opencode/skills/writing-plans/tasks/analyze.md` | SC-1, SC-4 | — |
| 2 — research.md dependency-contract generation | `test-driven-development` | `red` | `.opencode/skills/writing-plans/tasks/research.md` | SC-2 | 1 |
| 3 — cross-skill audit for tracking-state violations | `audit` | `verification-audit` | All `.opencode/skills/*/tasks/*.md` | SC-3 | 1, 2 |

---

## Phase Details

### Phase 1 — analyze.md frontmatter fix

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/writing-plans/tasks/analyze.md` |
| SCs | SC-1, SC-4 |
| Depends On | — |

**Context:**
```yaml
files_to_modify:
  - .opencode/skills/writing-plans/tasks/analyze.md
sc_ids: [SC-1, SC-4]
change_pattern:
  - replace "spec frontmatter `approved` field" with "issue.yaml labels for `approved-for-*`"
  - remove all references to frontmatter `approved` in Entry Criteria and Procedure
```

**Procedure:**
1. In `analyze.md` Entry Criteria, replace the check for spec frontmatter `approved: true` with a check for `{issues_prefix}/{N}/issue.yaml` containing an `approved-for-*` label.
2. In `analyze.md` Procedure, replace all references to spec frontmatter `approved` field with references to `issue.yaml` label state.
3. Remove any remaining references to frontmatter `approved` in Entry Criteria, Procedure, or Exit Criteria — verify zero matches via grep.

### Phase 2 — research.md dependency-contract generation

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/writing-plans/tasks/research.md` |
| SCs | SC-2 |
| Depends On | 1 |

**Context:**
```yaml
files_to_modify:
  - .opencode/skills/writing-plans/tasks/research.md
sc_ids: [SC-2]
change_pattern:
  - replace Step 9 BLOCK-if-missing with generation from interface-compatibility.yaml dependency_contract section
  - ensure generated dependency-contract.yaml is consumed in Z3 steps 10-12
```

**Procedure:**
1. In `research.md` Step 9, replace the BLOCK-if-missing logic with a generation step that reads `interface-compatibility.yaml` `dependency_contract` section and writes `dependency-contract.yaml`.
2. Verify that Z3 steps 10-12 in `research.md` consume the generated `dependency-contract.yaml` (update references if needed).
3. Remove the `DEPENDENCY_CONTRACT_NOT_FOUND` BLOCK condition from Step 9 Entry Criteria or error handling.

### Phase 3 — cross-skill audit for tracking-state violations

| Field | Value |
|-------|-------|
| Skill | `audit` |
| Task | `verification-audit` |
| Target | All `.opencode/skills/*/tasks/*.md` |
| SCs | SC-3 |
| Depends On | 1, 2 |

**Context:**
```yaml
audit_scope: ".opencode/skills/*/tasks/*.md"
sc_ids: [SC-3]
violation_patterns:
  - "frontmatter `approved` fields in spec/plan task files"
  - "status markers: `status.*completed`, `status.*pending`, `status.*in_progress`"
  - "completion indicators in spec/plan documents"
```

**Procedure:**
1. Glob all `.opencode/skills/*/tasks/*.md` files to build the audit scope.
2. For each file, grep for `approved` in frontmatter (between `---` delimiters) — record any matches.
3. For each file, grep for tracking-state patterns: `status.*completed`, `status.*pending`, `status.*in_progress` — record any matches.
4. For each file, grep for completion indicators in spec/plan documents — record any matches.
5. Compile audit results into a report at `{issues_prefix}/2232/artifacts/audit-report.md` with per-file findings.
6. For each violation found, file a SPEC-FIX issue targeting the affected task card.

---

## Exit Criteria

- [ ] C1. `analyze.md` checks `issue.yaml` labels for `approved-for-*` instead of spec frontmatter `approved` field
- [ ] C2. `analyze.md` Entry Criteria and Procedure no longer reference spec frontmatter `approved` field
- [ ] C3. `research.md` generates `dependency-contract.yaml` from `interface-compatibility.yaml` `dependency_contract` section instead of BLOCKing if missing
- [ ] C4. All task cards in `.opencode/skills/` are audited for tracking-state-in-spec violations — zero matches for `approved` in `tasks/analyze.md` across all skills, zero matches for tracking-state patterns in spec/plan task files

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-02T22:08:00Z | `plan_created` | Path: `.opencode/.issues/2232/plan.md`, Phases: 3 |
