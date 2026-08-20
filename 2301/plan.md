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
| 3 — Edge Cases table update | `test-driven-development` | `red` | `.opencode/skills/issue-operations-sync/tasks/import-remote.md` | SC3 | 1 |

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

**Procedure:**
- [ ] 1. **RED (**sub-agent**).** Write a failing enforcement test for the completeness gate (scenario 2301). **→ SC1**
- [ ] 2. **GREEN (**sub-agent**).** Implement the completeness gate in `import-remote.md`. **→ SC1**
- [ ] 3. **COMMIT (**inline**).** Stage and commit the test and change together as one atomic slice. **→ SC1**

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

**Procedure:**
- [ ] 4. **RED (**sub-agent**).** Write a failing behavioral test `2301-*.sh` asserting `spec.md` is materialized (no HALT). **→ SC2**
- [ ] 5. **GREEN (**sub-agent**).** Make the test pass (the gate materializes `spec.md`). **→ SC2**
- [ ] 6. **COMMIT (**inline**).** Stage and commit the test and change together as one atomic slice. **→ SC2**

### Phase 3 — Edge Cases table update

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/issue-operations-sync/tasks/import-remote.md` |
| SCs | SC3 |
| Depends On | 1 |

**Context:**
```yaml
table: "Edge Cases"
row: "Issue already imported"
new_behavior: "reflect the new completeness-check behavior (materialize missing files rather than halt on directory existence)"
```

**Procedure:**
- [ ] 7. **RED (**sub-agent**).** Write a failing doc-edit check for the Edge Cases row. **→ SC3**
- [ ] 8. **GREEN (**sub-agent**).** Update the Edge Cases "Issue already imported" row. **→ SC3**
- [ ] 9. **COMMIT (**inline**).** Stage and commit the doc edit. **→ SC3**

---

## Exit Criteria

- [ ] **SC1 (Phase 1).** `import-remote` checks all required mirror files (`spec.md`, `comments.md`, `remote.md`, `state.md`, frontmatter `github_issue`/`remote_url`) when the local issue directory exists, and materializes any that are missing rather than halting on directory existence alone.
- [ ] **SC2 (Phase 2).** A behavioral/structural test proves a folder that exists without `spec.md` is completed (spec.md materialized) rather than halted.
- [ ] **SC3 (Phase 3).** The Edge Cases table entry for "Issue already imported" reflects the new completeness-check behavior.
