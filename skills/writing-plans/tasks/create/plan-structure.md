# Task: create/plan-structure

## Purpose

Structure the implementation plan from approved spec: verification gate, combined/separate decision, file structure mapping, and TDD task definition with RED verification checkpoints. Produces the new multi-file format: master ToC (`plan.md`) + per-phase sub-plans (`plan-phase-N.md`) with dispatch contracts, commit boundaries, and explicit checkpoint tag creation steps.

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

### Phase Dependency Solve Contract (SC-1)

After defining the phase structure, create a dependency-ordering solve contract:

1. Create `.issues/{issue-N}/dependency-ordering-verification/` directory
1. Write `phase-order.yaml` with Z3 variables for each phase position and ordering constraints
1. Run `solve model --contract-path ... --query "phase_1 < phase_2 and phase_1 < phase_3"`
1. Confirm SAT — the phase ordering is valid

### Plan Utility Validation (SC-3)

After phase dependency contract is confirmed SAT, validate phase solvability:

1. Create `./tmp/{issue-N}/artifacts/phase-plan-problem.yaml` with phase structure as planning problem
1. Run `.opencode/tools/plan plan --problem ./tmp/{issue-N}/artifacts/phase-plan-problem.yaml`
1. Confirm planner returns SOLVED_SATISFICING or SOLVED_OPTIMALLY
1. Save result to `./tmp/{issue-N}/artifacts/phase-plan-validated.yaml`
1. If utility unavailable: **HALT** with blocker report — refer to `plan` skill → `fallback.md` task for manual acyclic check procedure

### SC-ID Mapping (SC-4)

After phase structure validated, consume `sc-summary.yaml`:

1. Read `.issues/{issue-N}/sc-summary.yaml`
1. Map each SC to its corresponding plan item by SC-ID
1. Verify all SCs from the spec are covered
1. Flag orphan SCs (in YAML but not mapped) and missing SCs (in spec but not in YAML)

### Pre-Step: Verification Gate (MANDATORY FIRST)

Before reading approved spec: `/skill verification-enforcement --task verify`

Collects evidence artifacts for factual claims. Unverified claims marked with `⚠️ UNVERIFIED`.

### Step 0.5: Pipeline-Readiness Gate Check (HARD GATE)

Before any plan content is written, verify that the spec has passed pipeline-readiness validation:

1. Read `.issues/{issue-N}/sc-pipeline-readiness.yaml`
1. Assert `status: PASS`
1. If status is FAIL or file does not exist: **HALT** with `SPEC_NOT_READY_FOR_PIPELINE` — the spec must pass the pipeline-readiness gate before plan creation
1. If PASS: extract `sc_summary` (total_scs, atomic, with_dependencies, single_concern) and phase dependency declarations for use in plan generation

This is a hard gate — the plan-writer MUST NOT proceed without a PASS from the pipeline-readiness gate. No exceptions, no "proceed anyway" path.

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
| Multi-task spec (mixed concerns or independence) | **Always separate** — multi-file format: master ToC (`plan.md`) + per-phase sub-plans (`plan-phase-N.md`) |
| Single-task spec AND spec body can absorb plan content | **Candidate for combined** — agent evaluates readability |
| Single-task AND combining makes document hard to read | **Separate** — multi-file format |

**Decision output (MANDATORY):**

```
Plan structure decision: combined/separate
Format: multi-file (master ToC + sub-plans) / single-file
Reason: <justification referencing evaluation criteria>
```

**If COMBINED (single-file):**

- Write to `.issues/{N}/plan.md`, reference spec content inline
- Retain `[SPEC]` title prefix
- Proceed to Step 2

**If SEPARATE (multi-file):**

- Write master ToC to `.issues/{N}/plan.md` (≤50 lines, phase list table with Depends On and Exit Criteria columns)
- Write per-phase sub-plans to `.issues/{N}/plan-phase-{N}.md` (one per phase)
- Each sub-plan includes: YAML header (phase, concern, depends_on, scs, checkpoint_tag), three-section structure (Pre-RED Common, Per-Item RED/GREEN Chains, Post-RED/green), dispatch contract fields (must_receive/must_not_receive), commits:true declarations, and explicit checkpoint tag creation step
- Proceed to Step 2

### Step 1.6: Duplicate Plan Check

Look for existing plan artifacts in `.issues/` workspace:

```bash
ls .issues/*/plan.md 2>/dev/null
```

For each plan found referencing the same spec, present choice:

- Proceed with new plan (override existing local artifact)
- HALT and review existing plan

### Step 2: Map File Structure (Sub-Folder References — SC-9)

- List sub-folders to create or modify (e.g., `skills/writing-plans/tasks/create/`), not individual files
- Agents glob `*` or `tasks/create/*` to discover content
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

### Step 3.3: Phase Dependency-Ordering Solve Contract Creation (SC-1)

For multi-phase specs, create a dependency-ordering solve contract from the phase structure:

```bash
./.opencode/tools/solve model \
  --contract-path .issues/{issue-N}/dependency-ordering-verification/ \
  --state phase_dependencies
```

The contract declares phase-ordering constraints as Z3 variables, where each phase's start depends on its dependencies being satisfied:

```yaml
# .issues/{issue-N}/dependency-ordering-verification/ordering.yaml
phase_dependencies:
  - phase: <phase_name>
    depends_on: [<phase_name>, ...]
    constraints:
      - "phase_N_starts_after_phase_M_completes"
```

### Step 3.4: SC-ID Mapping Substep (SC-4 Consumption)

After defining phase structure, consume the `sc-summary.yaml` from spec artifacts to map SCs to plan items:

1. Read `.issues/{issue-N}/sc-summary.yaml`
1. For each phase in the plan, verify its SC assignments match `sc_summary.phases[].sc_ids`
1. For each plANNED item, annotate with the corresponding SC-ID(s)
1. Flag orphan SCs (in YAML but not mapped to any plan item) as MISSING-TRACEABILITY
1. Flag extra SCs (in plan but not in YAML) as SCOPE-CREEP

### Step 3.5: RED/GREEN Condition Language (SC-2, SC-4 — Forward-Looking Stance)

Each item's RED/GREEN conditions MUST describe requirements, not implementation:

**RED** = "what must be false before this item starts" — the failure condition that would exist if this item were not implemented. NO line numbers, NO exact import strings, NO exact assertion code, NO file paths.

**GREEN** = "what must be true when done" — the condition that proves completion. Uses "must be true" language. NO "implemented", "complete", or past-tense status language.

**RED/GREEN MUST be defined as separate phases.** RED and GREEN may NEVER be combined into a single phase or step. RED describes the failure condition (what must be false), and GREEN describes the satisfaction condition (what must be true). They are separate concerns and MUST appear as separate entries in the plan structure.

```
✅ CORRECT RED: "The agent produces a plan with RED/GREEN conditions instead of prescriptive code"
✅ CORRECT GREEN: "Plans must describe what must be true, not how to achieve it"
❌ WRONG: "Replace line 42 with from mcp.server.fastmcp import FastMCP"
❌ WRONG: "Implemented RED/GREEN conditions for all items"
```

**Behavioral RED/GREEN for rule-changing items:**
When changing guidelines or skills, use behavioral TDD:

1. **Behavioral RED:** Write test sending agent prompt, verify agent does NOT follow new rule yet
1. **Behavioral GREEN:** Make change, re-run test — now agent follows rule

### Step 4: Plan Phase Structure — Dispatch Table Template (PRIMARY)

Every plan phase MUST include a dispatch table using EXACTLY the following 6-column format. The dispatch table is the PRIMARY section template — it MUST appear FIRST in each phase section, before concern boundaries, file references, and SC references.

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G{N}: {step-label} | sub-task or inline | yes (blind) or N/A | general or N/A | JSON context or — | SC-N |

#### Dispatch Table Rules

1. **One row per gate.** Every gate in the sequence must have exactly one row. No merged cells, no multi-step rows.
2. **Dispatch Type is binary:** `sub-task` (orchestrator tasks a clean-room sub-agent) or `inline` (orchestrator executes directly — restricted to CHECKPOINT-COMMIT only).
3. **Blind? column:** `yes (blind)` means the sub-agent receives only the Receives Context JSON — no other context from prior gates. `N/A` for inline gates.
4. **Sub-Agent Type:** Use `general` for sub-task gates. Use `N/A` for inline gates.
5. **Receives Context:** A JSON object with task instruction, issue number, phase number. For sub-task gates this is the EXACT prompt passed to `task()`. For inline gates this is `—` (em dash, no context).
6. **SCs column:** Lists the SCs this gate verifies (e.g., `SC-1, SC-2`). Must match SC IDs from the spec.
7. **Standard gate set is dynamic.** The gate labels and step sequence MUST be pulled from `implementation-pipeline/SKILL.md` §Dispatch Routing Table at the time of plan creation. Do NOT hardcode gate names — reference the canonical source.

#### Concern Boundary Annotations

When transitioning between architectural concerns, describe:
- What concern being left (prior scope)
- What concern being entered (new scope)
- What information the new concern needs from prior (handoff point)

#### File References

List the files affected by this phase. Agents glob to discover content — use sub-folder references, not individual file paths.

#### SC References

List the SCs covered by this phase. Each SC must be traceable to a spec success criterion.

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

### Step 5.5: `plan` Utility Invocation for Phase Solvability

After Z3 contract generation, invoke the `plan` utility to validate phase solvability. Load the `plan` skill for subcommand details and status code interpretation:

```bash
skill({name: "plan"})   # load reference for plan subcommands, status codes, and fallback procedures
```

Then run the phase solvability check:

```bash
./.opencode/tools/plan plan \
  --problem ./tmp/{issue-N}/artifacts/phase-plan-problem.yaml \
  --output ./tmp/{issue-N}/artifacts/phase-plan-validated.yaml
```

Refer to `plan` skill → `plan.md` task for SOLVED_SATISFICING/OPTIMALLY/UNSOLVABLE interpretation. Refer to `fallback.md` task when planner is unavailable.

Verification steps after contract generation:

1. Assert all-false state: run Z3 solver — MUST return SAT
1. Assert D_P1=True but p1=False: run Z3 solver — MUST return UNSAT

### Step 6: Generate Implementation Checklist — REMOVED

Implementation checklist generation has been removed. The dispatch table template (Step 4) and per-unit pipeline gate tables (Step 5) provide sufficient execution guidance. No separate checklist artifact is needed.

## Context Required

- Related tasks: `create/create-and-validate`
- Related skills: `verification-enforcement` (Step 0), `approval-gate` (Step 4.5)
