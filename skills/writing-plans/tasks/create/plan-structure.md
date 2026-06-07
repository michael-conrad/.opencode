# Task: create/plan-structure

## Purpose

Structure the implementation plan from approved spec: verification gate, combined/separate decision, file structure mapping, and TDD task definition with RED verification checkpoints.

## Entry Criteria

- Approved spec (verified by approval-gate)
- Spec stored as GitHub Issue
- Spec has explicit approval

## Exit Criteria

- Combined/separate decision made and documented
- Duplicate plan check completed
- File structure mapped with clear boundaries
- Item decomposition verified with dependency ordering
- TDD tasks defined with mandatory RED checkpoints

## Procedure

### Pre-Step: Verification Gate (MANDATORY FIRST)

Before reading approved spec: `/skill verification-enforcement --task verify`

Collects evidence artifacts for factual claims. Unverified claims marked with `⚠️ UNVERIFIED`.

### Step 1: Read Approved Spec

- Query GitHub Issue for spec content
- Extract objectives, constraints, success criteria
- Extract the all-or-nothing gate statement from the spec's SC section. The plan MUST preserve this gate language in its task structure — each TDD RED checkpoint is a sub-gate in the all-or-nothing chain. If the spec lacks the gate statement, flag as `SPEC_GAP`: the spec must be revised to include the gate before the plan proceeds.
- Identify affected sub-folders (not individual file paths — agents glob to discover content)
- Extract the spec's repo owner and repo from the issue URL for use in full-URL references

<!-- Fragment ID: sc-enforcement-gate -->

### Step 1.5: Combined vs Separate Plan Decision Gate

**Evaluate:** `single_task_determination` passed from post-creation (single-task/multi-task)

| Condition | Outcome |
| -- | -- |
| Multi-task spec (mixed concerns or independence) | **Always separate** — create [PLAN] issue with sub-issues |
| Single-task spec AND spec body can absorb plan content | **Candidate for combined** — agent evaluates readability |
| Single-task AND combining makes document hard to read | **Separate** — create [PLAN] issue |

**Decision output (MANDATORY):**
```
Plan structure decision: combined/separate
Reason: <justification referencing evaluation criteria>
```

**If COMBINED:**
- Append `## Implementation Plan` section to spec issue body
- Retain `[SPEC]` title prefix (not changed to `[PLAN]`)
- Proceed to Step 2 — plan content appended to spec body

**If SEPARATE:**
- Proceed to Step 2 — plan content stored in separate [PLAN] issue

### Step 1.6: Duplicate Plan Check

Search for existing plans referencing the same spec:
```python
plans = issue-operations -> search-issues (github_search_issues(query="label:plan", owner=<owner>, repo=<repo>, state="open") <!-- Routes through issue-operations per [spec #683](https://github.com/michael-conrad/opencode-config/issues/683) -->
```

For each plan found with `Spec: #<spec_number>`, present choice:
- Proceed with new plan (reference existing as full URL: `[Supersedes #N](https://github.com/<owner>/<repo>/issues/<N>)`)
- HALT and review existing plan

### Step 2: Map File Structure (Sub-Folder References — SC-9)

- List sub-folders to create or modify (e.g., `skills/writing-plans/tasks/create/`), not individual files
- Agents glob `spec-artifacts/*` or `tasks/create/*` to discover content
- Define each sub-folder's responsibility and concern boundary
- Ensure decomposition has clear boundaries across sub-folders
- **NO hardcoded file lists** — stale on every edit; agents discover by globbing

### Step 3: Item Decomposition (per `091-incremental-build.md`)

**Verify before writing:**
| Requirement | Verification |
| -- | -- |
| Item enumeration | Every unit listed with name, scope, deliverable |
| Dependency ordering | Items ordered so dependencies satisfied |
| Acceptance criteria per item | Each has testable criteria |
| Concern boundary annotations | Cross-architectural items flagged |

**Failure:** Plan will fail `approval-gate --task verify-authorization` Step 4.5

### Step 3.5: RED/GREEN Condition Language (SC-2, SC-4 — Forward-Looking Stance)

Each item's RED/GREEN conditions MUST describe requirements, not implementation:

**RED** = "what must be false before this item starts" — the failure condition that would exist if this item were not implemented. NO line numbers, NO exact import strings, NO exact assertion code, NO file paths.

**GREEN** = "what must be true when done" — the condition that proves completion. Uses "must be true" language. NO "implemented", "complete", or past-tense status language.

```
✅ CORRECT RED: "The agent produces a plan with RED/GREEN conditions instead of prescriptive code"
✅ CORRECT GREEN: "Plans must describe what must be true, not how to achieve it"
❌ WRONG: "Replace line 42 with from mcp.server.fastmcp import FastMCP"
❌ WRONG: "Implemented RED/GREEN conditions for all items"
```

**Behavioral RED/GREEN for rule-changing items:**
When changing guidelines or skills, use behavioral TDD:
1. **Behavioral RED:** Write test sending agent prompt, verify agent does NOT follow new rule yet
2. **Behavioral GREEN:** Make change, re-run test — now agent follows rule

### Step 4: Plan Phase Structure

Organize by concern flow:
- Determine phases needed
- Write prose for phase descriptions
- Prose-driven, not template-driven

### Step 5: Define Tasks Within Each Phase (Per-Unit Gates — SC-3)

- Each step is one action (2-5 minutes)
- RED/GREEN condition descriptions per Step 3.5 — NO exact code, commands, or file paths
- **Step 2 RED checkpoint is MANDATORY** — plans without it fail validation

#### Per-Unit Pipeline Gate Table (SC-3 — MUST be embedded in EACH unit)

Every unit gets its own 14-row pipeline gate table with unit-specific exit criteria. NOT a single shared cross-reference. Each table MUST have:

```
| Gate | Name | Exit Criterion (unit-specific) |
|------|------|-------------------------------|
| 1 | sc-coherence-gate | <what must pass for THIS unit> |
| 2 | pre-red-baseline | <what must pass for THIS unit> |
| 3 | red-phase | <what must pass for THIS unit> |
| 4 | red-doublecheck | <what must pass for THIS unit> |
| 5 | green-phase | <what must pass for THIS unit> |
| 6 | checkpoint-commit | <what must pass for THIS unit> |
| 7 | structural-checks | <what must pass for THIS unit> |
| 8 | green-doublecheck | <what must pass for THIS unit> |
| 9 | green-vbc | <what must pass for THIS unit> |
| 10 | adversarial-audit | <what must pass for THIS unit> |
| 11 | cross-validate | <what must pass for THIS unit> |
| 12 | regression-check | <what must pass for THIS unit> |
| 13 | review-prep | <what must pass for THIS unit> |
| 14 | exec-summary | <what must pass for THIS unit> |
```

#### Z3 Contract Generation (SC-7 — Per-Unit, No Preconditions)

Each unit's Z3 contract declares:
- 14 boolean variables per unit representing pipeline gate states (e.g., `P1_p1..p14`)
- 1 domain variable per unit (e.g., `D_P1`) that MUST be `False` unless all 14 gates are `True`
- 13 serial-ordering invariants: `Implies(pN, pN-1)` for N = 2..14
- NO preconditions — invariants + postconditions only

Contract structure:
```
(declare-const P1_p1 Bool) ... (declare-const P1_p14 Bool)
(declare-const D_P1 Bool)

; Serial ordering: each gate implies the prior gate passed
(assert (=> P1_p2 P1_p1))
...
(assert (=> P1_p14 P1_p13))

; Domain variable is True only when all 14 gates pass
(assert (=> D_P1 (and P1_p1 ... P1_p14)))

; Domain variable is False when any gate is false
(assert (=> (not (and P1_p1 ... P1_p14)) (not D_P1)))

; Verification: initial state (all false) → SAT expected
; Verification: defective state (D_P1=true, p1=false) → UNSAT expected
```

Verification steps after contract generation:
1. Assert all-false state: run Z3 solver — MUST return SAT
2. Assert D_P1=True but p1=False: run Z3 solver — MUST return UNSAT

## Context Required

- Related tasks: `create/create-and-validate`
- Related skills: `verification-enforcement` (Step 0), `approval-gate` (Step 4.5)