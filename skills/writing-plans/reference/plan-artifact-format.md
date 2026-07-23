# Plan Artifact Format — Living Canonical Specification

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

> **Status:** Living document. This is the single source of truth for the plan artifact format. All plan creation tools (`writing-plans`) and plan consumers (`implementation-pipeline`, `audit`) MUST conform to this specification.

---

## 1. Schema Versioning

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-07-23 | Initial canonical specification. Split-file format (index + phase files). Skill+Task dispatch references. |

The schema version is declared in the plan index YAML frontmatter:

```yaml
---
plan_schema_version: "1.0"
---
```

Plan consumers MUST check `plan_schema_version` before parsing. If the version is higher than the consumer supports, the consumer MUST return `BLOCKED` with `reason: UNSUPPORTED_PLAN_SCHEMA`.

---

## 2. File Layout

Plans use a split-file convention:

```
{issues_prefix}/{N}/
  plan.md                          — Plan index (required)
  plan-01-{slug}.md                — Phase 1 file (required for multi-phase)
  plan-02-{slug}.md                — Phase 2 file (optional)
  ...
```

| Term | Definition |
|------|------------|
| `{issues_prefix}` | Resolved from session-init `## Repo Information` entry (e.g., `.issues/` or `.opencode/.issues/`) |
| `{N}` | Issue number |
| `{slug}` | Short kebab-case phase name (e.g., `rename-observe`, `guideline-trims`) |

**Single-phase plans** MAY use `plan.md` as the sole file. **Multi-phase plans** MUST use the split format.

---

## 3. Plan Index (`plan.md`)

### 3.1 Frontmatter

```yaml
---
plan_schema_version: "1.0"
issue: N
title: "<short description>"
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_pr>
pr_strategy: <stacked|none>
phase_count: <integer>
---
```

### 3.2 Required Sections

| # | Section | Required | Content |
|---|---------|----------|---------|
| 1 | Title | Yes | `# Implementation Plan — #N — <description>` with issue URL |
| 2 | Goal | Yes | Single sentence describing what the plan achieves |
| 3 | Architecture | Yes | High-level approach, key design decisions |
| 4 | Files | Yes | List of files affected (sub-folder references, not individual files) |
| 5 | Phase Table | Yes | Table with columns: Phase, Skill, Task, Target, SCs, Depends On |
| 6 | Phase Details | Yes | One subsection per phase with Skill, Task, Target, SCs, Depends On, Context |
| 7 | Exit Criteria | Yes | Numbered checklist C1 through C{N} |

### 3.3 Phase Table

The phase table is the routing table. Each row maps a phase to a skill+task dispatch from the implementation pipeline.

| Column | Required | Description | Example |
|--------|----------|-------------|---------|
| Phase | Yes | Phase number and name | `1 — default.txt` |
| Skill | Yes | Skill name from `.opencode/skills/` | `test-driven-development` |
| Task | Yes | Task name from the skill's task files | `red` |
| Target | Yes | What the phase produces or modifies | `default.txt line 146` |
| SCs | Yes | SC IDs this phase covers | `SC-4, SC-11` |
| Depends On | Yes | Phase numbers this phase depends on | `—` or `1, 3` |

**Validation:** Every `Skill`+`Task` pair MUST exist in the `implementation-pipeline/SKILL.md` Trigger Dispatch Table. The plan writer MUST verify this by checking `ls .opencode/skills/<skill>/SKILL.md` and confirming the task is listed in the dispatch table.

### 3.4 Phase Details

Each phase detail section contains:

| Field | Required | Description |
|-------|----------|-------------|
| Skill | Yes | Skill name |
| Task | Yes | Task name |
| Target | Yes | What the phase produces or modifies |
| SCs | Yes | SC IDs this phase covers |
| Depends On | Yes | Phase dependencies |
| Context | No | Free-form input parameters (WHAT, not HOW) |

#### Context Block Rules

The Context block is a free-form YAML or prose block that specifies **input parameters** — what data the phase needs to begin. It MUST NOT contain procedural steps (how to do the work).

```yaml
# ✅ CORRECT — input parameters (what)
Context:
  files_to_modify:
    - .opencode/default.txt
    - .opencode/AGENTS.md
  rename_pattern: "investigate- → observe-"
  sc_ids: [SC-9]

# 🚫 FORBIDDEN — procedural steps (how)
Context:
  step_1: "grep for investigate-"
  step_2: "sed replace"
  step_3: "commit"
```

---

## 4. Phase Files (`plan-{NN}-{slug}.md`)

### 4.1 Required Sections

| # | Section | Required | Content |
|---|---------|----------|---------|
| 1 | Title | Yes | `# Phase {NN} — {name}` |
| 2 | Concern | Yes | Single concern this phase addresses |
| 3 | Files | Yes | Files this phase modifies |
| 4 | SCs | Yes | SC IDs this phase covers |
| 5 | Dependencies | Yes | Phase dependencies |
| 6 | Entry Conditions | Yes | What must be true before this phase starts |
| 7 | Exit Conditions | Yes | What must be true after this phase completes |
| 8 | Step-by-step | Yes | Checkbox steps with dispatch indicators |
| 9 | Phase Completion Block | Yes | VbC verification assertions |

### 4.2 Dispatch Indicators

Every step MUST use one of three dispatch indicators:

| Indicator | Meaning | Consumer |
|-----------|---------|----------|
| `(**inline**)` | Orchestrator executes directly | Orchestrator |
| `(**sub-agent**)` | Dispatch via `task()` with phase context | Sub-agent |
| `(**clean-room**)` | Dispatch via `task()` with routing metadata only | Clean-room sub-agent |

### 4.3 Global Sequential Numbering

Steps are numbered sequentially across ALL phase files. Phase 2's first step continues from Phase 1's last step. This ensures no ambiguity about ordering.

---

## 5. Validation Rules

### 5.1 Structural Rules

| # | Rule | Enforcement |
|---|------|-------------|
| R1 | Title matches issue number and description | `writing-plans --task validate` |
| R2 | Goal, Architecture, Files present and non-empty | `writing-plans --task validate` |
| R3 | At least one phase section | `writing-plans --task validate` |
| R4 | Each phase has Concern, Files, SCs, Dependencies | `writing-plans --task validate` |
| R5 | Each phase has checkbox steps (`- [ ] N.`) | `writing-plans --task validate` |
| R6 | Each step has a dispatch indicator | `writing-plans --task validate` |
| R7 | Exit criteria present and numbered C1-C{N} | `writing-plans --task validate` |
| R8 | Phase completion block present after last step | `writing-plans --task validate` |
| R9 | Concern transition present between phases | `writing-plans --task validate` |

### 5.2 Semantic Rules

| # | Rule | Enforcement |
|---|------|-------------|
| R10 | Every Skill+Task reference exists in `implementation-pipeline/SKILL.md` Trigger Dispatch Table | `writing-plans --task validate` (dispatch marker check) |
| R11 | Every SC maps to at least one phase | `audit --task plan-fidelity` |
| R12 | Dependencies form a valid DAG (no circular dependencies) | `solve --task check` (Z3 verification) |
| R13 | Each phase addresses exactly one concern | `audit --task plan-fidelity` |
| R14 | Context blocks contain input parameters only (no procedural steps) | `audit --task plan-fidelity` |
| R15 | No TBD/TODO — all file paths, function names, and commands must be exact | `writing-plans --task validate` |
| R16 | No zero-indexed numbering — phases start at 1, steps start at 1 | `writing-plans --task validate` |
| R17 | No line number references — use stable anchors (function names, section headers) | `writing-plans --task validate` |
| R18 | No multi-dispatch steps — every step dispatches exactly one sub-agent or executes inline | `writing-plans --task validate` |
| R19 | No omitted mandatory gates — all implementation-pipeline gate steps are mandatory | `audit --task plan-fidelity` |

### 5.3 Dispatch Marker Validation

Every `Skill`+`Task` pair in the phase table MUST be verified against the filesystem:

```bash
# Verify skill exists
ls .opencode/skills/<skill-name>/SKILL.md

# Verify task exists in the skill's dispatch table
grep "<task-name>" .opencode/skills/<skill-name>/SKILL.md
```

If either check fails, the plan is INVALID and MUST be rejected.

---

## 6. Full Example

### 6.1 Plan Index (`plan.md`)

```yaml
---
plan_schema_version: "1.0"
issue: 42
title: "Add input validation to user registration endpoint"
authorization_scope: for_implementation
pr_strategy: stacked
phase_count: 3
---
```

# Implementation Plan — #42 — Add Input Validation to User Registration

**Goal:** Add server-side input validation to the `/api/register` endpoint to reject malformed payloads before they reach the database layer.

**Architecture:** Add a validation middleware layer between the route handler and the controller. Validation rules are defined as Pydantic models in a new `validators/` module. Existing tests are updated to cover invalid input paths.

**Files:**
- `src/routes/register.py`
- `src/controllers/user_controller.py`
- `src/validators/registration.py` (new)
- `test/test_register.py`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Pydantic model | `test-driven-development` | `red` | `src/validators/registration.py` | SC-1, SC-2 | — |
| 2 — Middleware integration | `test-driven-development` | `green` | `src/routes/register.py` | SC-3 | 1 |
| 3 — Test coverage | `test-driven-development` | `patterns` | `test/test_register.py` | SC-4 | 1, 2 |

---

## Phase Details

### Phase 1 — Pydantic Model

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `src/validators/registration.py` |
| SCs | SC-1, SC-2 |
| Depends On | — |

**Context:**
```yaml
model_name: RegistrationInput
fields:
  - name: email
    type: EmailStr
    required: true
  - name: password
    type: str
    min_length: 8
    required: true
  - name: age
    type: int
    ge: 18
    le: 120
    required: false
```

### Phase 2 — Middleware Integration

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `src/routes/register.py` |
| SCs | SC-3 |
| Depends On | 1 |

**Context:**
```yaml
integration_point: "src/routes/register.py:RegistrationHandler.post()"
validation_call: "RegistrationInput(**payload)"
error_response_format:
  status: 422
  body:
    error: "validation_failed"
    details: "<field_errors>"
```

### Phase 3 — Test Coverage

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `patterns` |
| Target | `test/test_register.py` |
| SCs | SC-4 |
| Depends On | 1, 2 |

**Context:**
```yaml
test_cases:
  - description: "missing email field"
    payload: { "password": "secret123", "age": 25 }
    expected_status: 422
  - description: "password too short"
    payload: { "email": "a@b.com", "password": "short" }
    expected_status: 422
  - description: "age out of range"
    payload: { "email": "a@b.com", "password": "secret123", "age": 17 }
    expected_status: 422
  - description: "valid payload"
    payload: { "email": "a@b.com", "password": "secret123", "age": 25 }
    expected_status: 200
```

---

## Exit Criteria

- [ ] C1. `RegistrationInput` Pydantic model exists with all specified fields and validation rules
- [ ] C2. Model rejects invalid email, short password, and out-of-range age
- [ ] C3. Route handler returns 422 with structured error body on validation failure
- [ ] C4. All 4 test cases pass (3 invalid, 1 valid)

---

### 6.2 Phase 1 File (`plan-01-pydantic-model.md`)

# Phase 1 — Pydantic Model

**Concern:** Define the validation schema for registration input.

**Files:**
- `src/validators/registration.py` (new)

**SCs:** SC-1, SC-2

**Dependencies:** None

**Entry Conditions:**
- Spec #42 is approved
- Feature branch exists

**Exit Conditions:**
- `RegistrationInput` model exists with email, password, age fields
- Model rejects invalid inputs per validation rules

---

- [ ] 1. **RED (**sub-agent**).** Write failing test asserting `RegistrationInput` model exists and validates fields. **→ SC-1, SC-2**
- [ ] 2. **GREEN (**sub-agent**).** Create `src/validators/registration.py` with `RegistrationInput` Pydantic model. **→ SC-1, SC-2**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify model rejects invalid email, short password, out-of-range age. **→ SC-1, SC-2**
- [ ] 4. **Checkpoint commit (**inline**).** Commit model creation.

#### Phase 1 VbC

- [ ] 5. **VbC (**clean-room**).** Verify `RegistrationInput` exists, all fields present, validation rules correct. **→ SC-1, SC-2**

**Concern transition:** Leaving validation schema definition → entering middleware integration. Phase 2 depends on Phase 1's `RegistrationInput` model.

---

### 6.3 Phase 2 File (`plan-02-middleware-integration.md`)

# Phase 2 — Middleware Integration

**Concern:** Integrate the validation model into the route handler.

**Files:**
- `src/routes/register.py`

**SCs:** SC-3

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `RegistrationInput` model exists
- Phase 1 VbC passed

**Exit Conditions:**
- Route handler validates input before processing
- Invalid input returns 422 with structured error body

---

- [ ] 6. **RED (**sub-agent**).** Write failing test asserting route returns 422 for invalid payload. **→ SC-3**
- [ ] 7. **GREEN (**sub-agent**).** Add validation call to route handler, return 422 on failure. **→ SC-3**
- [ ] 8. **GREEN doublecheck (**clean-room**).** Verify 422 response body contains `error` and `details` fields. **→ SC-3**
- [ ] 9. **Checkpoint commit (**inline**).** Commit middleware integration.

#### Phase 2 VbC

- [ ] 10. **VbC (**clean-room**).** Verify route returns 422 for invalid payload with correct error structure. **→ SC-3**

**Concern transition:** Leaving middleware integration → entering test coverage. Phase 3 depends on Phase 1's model and Phase 2's route integration.

---

### 6.4 Phase 3 File (`plan-03-test-coverage.md`)

# Phase 3 — Test Coverage

**Concern:** Cover all validation paths with behavioral tests.

**Files:**
- `test/test_register.py`

**SCs:** SC-4

**Dependencies:** Phase 1, Phase 2

**Entry Conditions:**
- Phase 1 complete: `RegistrationInput` model exists
- Phase 2 complete: route handler validates input

**Exit Conditions:**
- All 4 test cases pass
- Regression tests pass

---

- [ ] 11. **RED (**sub-agent**).** Write failing tests for all 4 test cases. **→ SC-4**
- [ ] 12. **GREEN (**sub-agent**).** Implement test cases, wire up to route handler. **→ SC-4**
- [ ] 13. **GREEN doublecheck (**clean-room**).** Verify all 4 test cases pass. **→ SC-4**
- [ ] 14. **Checkpoint commit (**inline**).** Commit test coverage.
- [ ] 15. **Regression check (**sub-agent**).** Run full test suite, verify no regressions. **→ SC-4**

#### Phase 3 VbC

- [ ] 16. **VbC (**clean-room**).** Verify all 4 test cases pass, regression suite clean. **→ SC-4**

---

## 7. DAG Validation

Dependencies MUST form a valid directed acyclic graph. The Z3 solver (`solve --task check`) validates this property.

### Valid DAG Example

```
Phase 1 — PREREQ: none
Phase 2 — PREREQ: Phase 1
Phase 3 — PREREQ: Phase 1, Phase 2
```

### Invalid DAG Examples

```
# Circular dependency
Phase 1 — PREREQ: Phase 3
Phase 2 — PREREQ: Phase 1
Phase 3 — PREREQ: Phase 2

# Missing dependency
Phase 2 — PREREQ: Phase 1  (but Phase 1 does not exist)
```

---

## 8. SC Coverage Matrix

Every SC from the spec MUST map to at least one phase. The SC coverage matrix is a validation artifact:

```yaml
# sc-coverage.yaml
coverage:
  SC-1: [Phase 1]
  SC-2: [Phase 1]
  SC-3: [Phase 2]
  SC-4: [Phase 3]
uncovered: []
```

An SC that maps to zero phases is a defect — the plan is incomplete.

---

## 9. Cross-References

| Document | Purpose |
|----------|---------|
| `writing-plans/tasks/create.md` | Plan file writing procedure |
| `writing-plans/tasks/create.md` | Phase structure definition |
| `writing-plans/tasks/validate.md` | Plan validation procedure |
| `implementation-pipeline/SKILL.md` | Trigger Dispatch Table (canonical skill+task references) |
| `audit/tasks/plan-fidelity.md` | Plan fidelity audit |
| `solve/tasks/check.md` | Z3 dependency DAG validation |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
