---
plan_schema_version: "1.0"
issue: 2303
title: "Tighten requires-python constraint in .opencode/tools/plan to exclude CPython 3.14"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 2
dispatch:
  - phase: 1
    skill: test-driven-development
    task: "execute red task from test-driven-development"
  - phase: 2
    skill: test-driven-development
    task: "execute red task from test-driven-development"
---

# Implementation Plan — #2303 — Tighten requires-python in .opencode/tools/plan

**Goal:** Tighten the `requires-python` constraint in the PEP 723 header of `.opencode/tools/plan` from `~=3.12` to `>=3.12,<3.14` so uv selects a Python version with available pytamer wheels, and verify the tool still resolves and executes under CPython 3.12.

**Architecture:** The fix is a one-line change to the PEP 723 header of `.opencode/tools/plan` (line 7, `requires-python = "~=3.12"` → `requires-python = ">=3.12,<3.14"`), plus a usage note documenting `UV_PYTHON=3.12` as an optional workaround. The bash guard at the top of the file (line 3) must remain intact. Phase 1 applies the constraint change (SC-1, structural). Phase 2 verifies resolution and execution under CPython 3.12 via `uv run --script` (SC-2, behavioral).

**Files:**
- `.opencode/tools/plan`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Tighten requires-python | `test-driven-development` | `red` | `.opencode/tools/plan` PEP 723 header | SC-1 | — |
| 2 — Verify CPython 3.12 | `test-driven-development` | `red` | `.opencode/tools/plan` under `uv run --script` | SC-2 | 1 |

---

## Phase Details

### Phase 1 — Tighten requires-python

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tools/plan` PEP 723 header |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```yaml
file_to_modify: .opencode/tools/plan
current_constraint: "~=3.12"
target_constraint: ">=3.12,<3.14"
sc_ids: [SC-1]
evidence_type: structural
```

### Phase 2 — Verify CPython 3.12

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tools/plan` under `uv run --script` |
| SCs | SC-2 |
| Depends On | 1 |

**Context:**
```yaml
file_to_invoke: .opencode/tools/plan
invocation: "uv run --script .opencode/tools/plan"
interpreter: "CPython 3.12"
expected_exit_code: 0
absent_error: "No solution found when resolving script dependencies"
sc_ids: [SC-2]
evidence_type: behavioral
```

---

## Exit Criteria

- [ ] C1. The `requires-python` constraint in the PEP 723 header of `.opencode/tools/plan` is exactly `>=3.12,<3.14`, excluding CPython 3.14.
- [ ] C2. Invoking `.opencode/tools/plan` via `uv run --script` under CPython 3.12 completes dependency resolution and execution with exit code 0 and no pytamer resolution error in output.
- [ ] C3. The fix is confined to the PEP 723 header and an accompanying usage note; no `up-tamer`/`pytamer` resolution logic was modified and no cp314 wheels were built.
- [ ] C4. The bash guard at the top of `.opencode/tools/plan` remains intact.

---

## Lifecycle Events

| Timestamp (UTC) | Event | Details |
|-----------------|-------|---------|
| 2026-08-20T03:46:16Z | `plan_created` | Plan path: `.issues/2303/plan.md`; phase count: 2 |
