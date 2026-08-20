---
plan_schema_version: "1.0"
issue: 2301
title: "import-remote must materialize missing mirror files instead of halting on directory existence"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — #2301 — import-remote completeness gate

**Goal:** Modify `import-remote` so that when the local issue directory exists, it checks all required mirror files and materializes any that are missing rather than halting on directory existence alone.

**Architecture:** Replace the directory-existence-only halt with a completeness gate. When the local issue directory exists, `import-remote` enumerates the required mirror files (`spec.md`, `comments.md`, `remote.md`, `state.md`, and frontmatter fields `github_issue`/`remote_url`) and materializes any that are absent (fetching the remote body/comments/frontmatter as needed), only halting when the directory is genuinely complete. A behavioral/structural test asserts that a pre-existing directory lacking `spec.md` results in `spec.md` being created (not a HALT). The Edge Cases table entry for "Issue already imported" is updated to reflect the new completeness-check behavior.

**Files:**
- `.opencode/skills/issue-operations-sync/tasks/import-remote.md`
- `.opencode/tests-v2/behaviors/2301-*.sh`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — import-remote completeness gate | `test-driven-development` | `red` | `.opencode/skills/issue-operations-sync/tasks/import-remote.md` | SC1 | — |
| 2 — behavioral test proving spec.md materialized | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/2301-*.sh` | SC2 | 1 |
| 3 — Edge Cases table update | `test-driven-development` | `red` | `.opencode/skills/issue-operations-sync/tasks/import-remote.md` | SC3 | — |

---

## Phase Details

### Phase 1 — import-remote completeness gate

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/issue-operations-sync/tasks/import-remote.md` |
| SCs | SC1 |
| Depends On | — |

**Context:**
```yaml
required_mirror_files:
  - spec.md
  - comments.md
  - remote.md
  - state.md
frontmatter_fields:
  - github_issue
  - remote_url
behavior: "when local issue directory exists, enumerate required mirror files and materialize any that are missing; only halt when directory is genuinely complete"
```

### Phase 2 — behavioral test proving spec.md materialized

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/2301-*.sh` |
| SCs | SC2 |
| Depends On | 1 |

**Context:**
```yaml
test_scenario: "a folder that exists without spec.md is completed (spec.md materialized) rather than halted"
assertion: "spec.md exists after run; no HALT on directory existence alone"
```

### Phase 3 — Edge Cases table update

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/issue-operations-sync/tasks/import-remote.md` |
| SCs | SC3 |
| Depends On | — |

**Context:**
```yaml
table: "Edge Cases"
row: "Issue already imported"
new_behavior: "reflect the new completeness-check behavior (materialize missing files rather than halt on directory existence)"
```

---

## Exit Criteria

- [ ] C1. `import-remote` checks all required mirror files (`spec.md`, `comments.md`, `remote.md`, `state.md`, frontmatter `github_issue`/`remote_url`) when the local issue directory exists
- [ ] C2. `import-remote` materializes any missing required mirror files rather than halting on directory existence alone
- [ ] C3. A behavioral/structural test proves a folder that exists without `spec.md` is completed (spec.md materialized) rather than halted
- [ ] C4. The Edge Cases table entry for "Issue already imported" reflects the new completeness-check behavior
