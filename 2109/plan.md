---
plan_schema_version: "1.0"
issue: 2109
title: "Stop-command terminal halt, discussion boundary, solicitation gate, and behavioral enforcement tests"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 4
---

# Implementation Plan — #2109 — Stop-Command Terminal Halt and Solicitation Enforcement

**Goal:** Define and enforce a terminal halt state triggered by user "stop" commands, establish discussion/implementation boundary enforcement, add a solicitation detection gate, and verify all changes with behavioral enforcement tests.

**Architecture:** Add new Tier 1 critical rule sections to `.opencode/guidelines/000-critical-rules.md` and `.opencode/guidelines/020-go-prohibitions.md` defining stop semantics, discuss boundary, and solicitation gate. Create behavioral test files in `.opencode/tests-v2/behaviors/` that verify agent compliance. All guideline changes are structural (string evidence) with behavioral test corroboration.

**Files:**
- `.opencode/guidelines/000-critical-rules.md`
- `.opencode/guidelines/020-go-prohibitions.md`
- `.opencode/tests-v2/behaviors/stop-command.sh` (new)
- `.opencode/tests-v2/behaviors/discuss-boundary.sh` (new)
- `.opencode/tests-v2/behaviors/solicitation-gate.sh` (new)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — stop-terminal-halt | `test-driven-development` | `green` | `.opencode/guidelines/000-critical-rules.md`, `.opencode/guidelines/020-go-prohibitions.md` | SC-1, SC-5 | — |
| 2 — discuss-boundary | `test-driven-development` | `green` | `.opencode/guidelines/020-go-prohibitions.md` | SC-2 | 1 |
| 3 — solicitation-gate | `test-driven-development` | `green` | `.opencode/guidelines/020-go-prohibitions.md` | SC-3 | 2 |
| 4 — behavioral-test | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/` | SC-4 | 3 |

---

## Phase Details

### Phase 1 — stop-terminal-halt

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/guidelines/000-critical-rules.md`, `.opencode/guidelines/020-go-prohibitions.md` |
| SCs | SC-1, SC-5 |
| Depends On | — |

**Context:**
```yaml
scs: [SC-1, SC-5]
files_to_modify:
  - .opencode/guidelines/000-critical-rules.md
  - .opencode/guidelines/020-go-prohibitions.md
stop_semantics:
  - "stop" triggers terminal halt: zero further output, zero tool calls, zero proposals
  - No recovery from "stop" — user must explicitly restart with a new message
  - "stop" is a hard state transition, not "stop and try something else"
```

### Phase 2 — discuss-boundary

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/guidelines/020-go-prohibitions.md` |
| SCs | SC-2 |
| Depends On | 1 |

**Context:**
```yaml
scs: [SC-2]
files_to_modify:
  - .opencode/guidelines/020-go-prohibitions.md
discuss_semantics:
  - When user says "discuss," agent MUST NOT propose implementation
  - "discuss" triggers a hard gate blocking any "want me to implement" pattern
```

### Phase 3 — solicitation-gate

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/guidelines/020-go-prohibitions.md` |
| SCs | SC-3 |
| Depends On | 2 |

**Context:**
```yaml
scs: [SC-3]
files_to_modify:
  - .opencode/guidelines/020-go-prohibitions.md
solicitation_gate:
  - Before any output containing "want me to", "should I", "I can implement", or similar patterns
  - Agent checks: did the user ask for this?
  - If not, suppress the output
```

### Phase 4 — behavioral-test

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/` |
| SCs | SC-4 |
| Depends On | 3 |

**Context:**
```yaml
scs: [SC-4]
files_to_create:
  - .opencode/tests-v2/behaviors/stop-command.sh
  - .opencode/tests-v2/behaviors/discuss-boundary.sh
  - .opencode/tests-v2/behaviors/solicitation-gate.sh
test_patterns:
  - stop-command.sh: send "stop" prompt, assert terminal halt (zero tool calls after stop)
  - discuss-boundary.sh: send "discuss" prompt, assert no implementation proposal
  - solicitation-gate.sh: send complaint prompt, assert no solicitation output
```

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-07-24T19:30:00Z | plan_created | Plan written to `.opencode/.issues/2109/plan.md` with 4 phases, 5 SCs, 32 steps total. Authorization scope: for_pr. Pipeline phase: plan-creation. |

---

## Exit Criteria

- [ ] C1. SC-1: Guidelines define "stop" as terminal halt with zero output, zero tool calls, zero proposals
- [ ] C2. SC-5: Guidelines define no recovery from "stop" — explicit restart required
- [ ] C3. SC-2: Guidelines define discussion/implementation boundary — "discuss" blocks implementation proposals
- [ ] C4. SC-3: Guidelines define solicitation detection gate — pre-output check for "want me to" patterns
- [ ] C5. SC-4: Behavioral enforcement test exists for stop-command compliance
