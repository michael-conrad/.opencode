---
name: test-driven-development
description: "Use when writing tests before implementation, or when adopting a test-first development approach. Triggers on: TDD, test first, red green refactor, write test, test-driven, unit test, regression. Writing code before tests is the oldest shortcut in engineering. TDD produces testable, correct code."
type: discipline-enforcing
license: MIT
provenance: Derived from majiayu000/claude-skill-registry (MIT)
compatibility: opencode
---

# Skill: test-driven-development

## Five Core Principles

1. **FAIL=FAIL** — No soft-passing. Verify against live sources. Report PASS/FAIL truthfully.
2. **RED/GREEN separation** — RED and GREEN must be separate phases. They may NEVER be combined into a single phase or step. RED must complete (test written and confirmed FAIL) before GREEN begins. This is a hard gate — no authorization or developer instruction may override it.
3. **TDD discipline** — RED phase tests before GREEN phase implementation. REFACTOR is mandatory, not optional.
4. **Clean-room** — No inline fallback. Sub-agents receive only scoped context. No pre-determined findings.
5. **Independent intelligence** — Autonomous analysis. If the task contains excessive instruction where your own analysis should apply, HALT and notify parent.
6. **Verify LIVE** — Never trust training data, memory, or metadata. Verify against live docs, source code, and test results.

## TDD Heading Format Requirement

All TDD task headings in plan documents MUST use the SC-ID parenthetical format:

```text
### TDD-<N>: <description> (SC-<ID>, SC-<ID>, ...)
```

### Examples

**✅ CORRECT:**

```text
### TDD-1: Update sc-coherence-gate with evidence-type uplift scan (SC-6)
### TDD-4: Add post-red-enforcement to routing table (SC-1, SC-5)
```

**🚫 INCORRECT:**

```text
### TDD-1: Update sc-coherence-gate with evidence-type uplift scan  ← missing SC-ID
### TDD-4: Add post-red-enforcement: SC-1, SC-5  ← wrong format
```

### Enforcement

The `pre-red-baseline` sub-agent parses plan TDD headings, extracts SC-IDs, and cross-references against the spec SC table. If any TDD heading references an SC-ID that does not exist in the spec, the gate returns BLOCKED with `MISSING-TRACEABILITY`.

### SC-ID Extraction Contract

| Field | Format | Required |
|-------|--------|----------|
| Prefix | `### TDD-<N>:` | Yes |
| Description | Any text | Yes |
| SC-ID reference | `(SC-<ID>, SC-<ID>, ...)` | Yes — must match spec SC table |
| Multiple SC-IDs | Comma-separated | Optional |
| Whitespace | Space after comma | Recommended |

## ASCII Cycle Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    TDD CYCLE (per item)                  │
│                                                         │
│   PHASE 0 ──► RED ──► GREEN ──► REFACTOR ──► PHASE 4    │
│   (baseline)   │        │          │         (verify)    │
│       ▲        │  fails │ passes   │            │        │
│       │        ▼        ▼          ▼            ▼        │
│       │     BLOCKED  BLOCKED    REVERT       BLOCKED      │
│       │     (fix or  (fix or    (bad        (2x fail     │
│       │      halt)    halt)     refactor)    = halt)      │
│       │                                                  │
│       └──────────── CYCLE RESET ──────────────────────────┘
│                                                          │
│   Next item ──► back to Phase 0                         │
└──────────────────────────────────────────────────────────┘
```

## Sequential Pair Mandate

**RED/GREEN pairs execute sequentially.** When multiple RED/GREEN pairs exist (multiple implementation items), each RED must be immediately followed by its GREEN before the next RED begins. Running RED for multiple items before any GREEN starts is prohibited. The cycle is:

```
item-1-RED → item-1-GREEN → item-2-RED → item-2-GREEN → ...
```

Never `RED-ALL → GREEN-ALL`.

## Tasks

|------|-------|---------|
| `red` | Execution-only: write failing test |
| `green` | Execution-only: minimal impl |
| `refactor` | Execution-only: clean while green |
| `patterns` | 4-pattern decision matrix |
| `anti-patterns` | 5 anti-patterns with alternatives |
| `checklist` | Quality checklists, timing, step-size |
| `phase-0` | Pre-regression baseline gate |
| `phase-4` | Post-regression verification gate |

## Invocation

`skill({name: "test-driven-development"})` — call the skill, then call via task():

| Task | Call via task() |

| (use task name) | `task(..., prompt: "execute <task> task from test-driven-development")` |

**CLI equivalent (for human TUI use):** `/skill test-driven-development --task <name>`

## Gate Descriptions

### Phase 0 — Pre-Regression Baseline

Invoked before the first RED phase. AI-driven dependency analysis (`srclight_get_dependents`), full test suite execution. BLOCKED on test failure — cycle cannot start until existing failures are resolved. Empty blast radius = silent proceed.

### Phase 4 — Post-Regression Verification

Invoked after REFACTOR completes. Re-computes blast radius, runs full suite. Remediation loop: first failure returns to GREEN, second consecutive failure = BLOCKED with halt.

### Completeness Gate (After TDD Cycle, Before Audit)

After Phase 4 passes and before routing to adversarial audit, the orchestrator MUST run `completeness-gate --task check` on the deliverable. This gate verifies the deliverable covers all spec success criteria and is structurally sound. The gate is non-adversarial and read-only — it checks presence and coverage, not correctness depth. See `completeness-gate` skill for routing decisions.

## Cycle-Reset Discipline

### Normal Completion

After Phase 4 PASSES:
1. Commit the cycle (test + implementation + refactor as one working slice)
2. Reset to Phase 0 for the next item
3. Never carry state across cycles

### Mid-Cycle Restart

If at ANY point within RED/GREEN/REFACTOR a step exceeds its timing target (30s RED / 2-5min GREEN / 1-3min REFACTOR) or produces unexpected test failures, the agent MUST restart the full RED→GREEN→REFACTOR cycle from the beginning — not limp forward on a broken foundation:

1. Discard all uncommitted changes from the current cycle
2. Restart from RED with zero state carryover
3. If Phase 0 elapsed > 1 full cycle since last baseline, re-execute Phase 0

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ spec_context, test_path, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase }`. Exclusions: implementation context, agent memory, prior test results. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow" |
| Preloaded step sequences | "Step 1: sync dev. Step 2: delete branch." | "execute cleanup task from git-workflow" |
| Preloaded expected outcomes | "Return { cleanup_status, branch_deleted }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..." | Pure objective, no narrative |

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pr_strategy`
- `pipeline_phase`

Plus skill-specific fields per the `## Sub-Agent Routing` section above.

Exclusions (MUST NOT be in prompt):
- `orchestrator_reasoning`
- `expected_outcomes`
- `inline_file_paths`
- `agent_memory`
- `cached_verification_results`

#### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains:
- Inline file paths to task files
- Inline step or procedure definitions
- Expected outcome structures or schema constraints
- Pre-loaded evidence or orchestrator-derived conclusions

Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

### Authorization Context
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Routing Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Provenance

Derived from [majiayu000/claude-skill-registry](https://github.com/majiayu000/claude-skill-registry) (MIT).

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-11T00:00:00Z"
rules:
  - id: tdd-001
    title: "RED phase must produce evidence of test failure"
    conditions:
      all: ["red_phase_started == true", "test_failure_evidence_missing == true"]
    actions: [HALT, COLLECT_EVIDENCE]
    source: "test-driven-development/SKILL.md"

  - id: tdd-002
    title: "Phase 0 must complete before RED phase"
    conditions:
      all: ["tdd_cycle_started == true", "phase_0_completed == false"]
    actions: [HALT, TASK(phase-0)]
    source: "test-driven-development/SKILL.md"

  - id: tdd-003
    title: "Phase 4 must complete before cycle reset"
    conditions:
      all: ["refactor_phase_completed == true", "phase_4_completed == false"]
    actions: [HALT, TASK(phase-4)]
    source: "test-driven-development/SKILL.md"
