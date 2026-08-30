---
plan_schema_version: "1.0"
issue: 2416
title: "Enforce verifiable test execution before completion claims"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — #2416 — Enforce Verifiable Test Execution Before Completion Claims

**Goal:** Add hard gate assertions to the verification-before-completion pipeline requiring `tests_run > 0` and `all_passed == true`, plus a `tests-run.yaml` evidence artifact, then update `.opencode/AGENTS.md` and write a behavioral enforcement test.

**Architecture:** Three-phase approach: (1) verification gate enforcement — modify `verify.md`, `collect.md`, and `operating-protocol.md` to require test evidence, (2) documentation — add mandatory test-execution language to `.opencode/AGENTS.md`, (3) behavioral enforcement test — write a behavioral test scenario that verifies an agent attempting to bypass the gate is BLOCKED.

**Files:**
- `.opencode/skills/verification-before-completion/tasks/verify.md`
- `.opencode/skills/verification-before-completion/tasks/collect.md`
- `.opencode/skills/verification-before-completion/tasks/operating-protocol.md`
- `.opencode/AGENTS.md`
- `.opencode/tests-v2/behaviors/2416-bypass-gate.sh` (new)
- `.opencode/tests-v2/behaviors/helpers.sh` (if new assertion helpers needed)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Verification-gate enforcement | `test-driven-development` | `red` | verification-before-completion task files | SC-1a, SC-1b, SC-2 | — |
| 2 — Documentation | `test-driven-development` | `red` | `.opencode/AGENTS.md` | SC-3 | 1 |
| 3 — Behavioral enforcement test | `test-driven-development` | `red` | new behavioral test scenario | SC-4 | 1 |

---

## Phase Details

### Phase 1 — Verification-gate enforcement

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | verification-before-completion task files |
| SCs | SC-1a, SC-1b, SC-2 |
| Depends On | — |

**Context:**
```yaml
target_files:
  - .opencode/skills/verification-before-completion/tasks/verify.md
  - .opencode/skills/verification-before-completion/tasks/collect.md
  - .opencode/skills/verification-before-completion/tasks/operating-protocol.md
items:
  - sc_id: SC-1a
    description: Add tests_run > 0 assertion to verify.md Step 2
  - sc_id: SC-1b
    description: Add all_passed == true assertion to verify.md Step 2
  - sc_id: SC-2
    description: Require tests-run.yaml evidence artifact in verification pipeline
```

### Phase 2 — Documentation

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/AGENTS.md` |
| SCs | SC-3 |
| Depends On | 1 |

**Context:**
```yaml
file: .opencode/AGENTS.md
requirement: Add explicit mandatory test-execution language stating that
  verifiable test execution (not just command exit codes) is required
  before any completion claim
```

### Phase 3 — Behavioral enforcement test

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | new behavioral test scenario |
| SCs | SC-4 |
| Depends On | 1 |

**Context:**
```yaml
new_behavioral_test: .opencode/tests-v2/behaviors/2416-bypass-gate.sh
scenario: Agent attempts to claim completion without running tests
assertion: gate BLOCKs the bypass attempt
```

---

## Exit Criteria

- [ ] C1. SC-1a PASS: verify.md Step 2 asserts `tests_run > 0` before accepting completion
- [ ] C2. SC-1b PASS: verify.md Step 2 asserts `all_passed == true` before accepting completion
- [ ] C3. SC-2 PASS: verify.md and collect.md reference `tests-run.yaml` evidence artifact
- [ ] C4. SC-3 PASS: `.opencode/AGENTS.md` contains mandatory test-execution language
- [ ] C5. SC-4 PASS: behavioral test asserts gate BLOCKs on bypass attempt
- [ ] C6. No circular dependencies in phase DAG
- [ ] C7. Every task enumerates all steps from the implementation-workflow reference card per-task cycle
