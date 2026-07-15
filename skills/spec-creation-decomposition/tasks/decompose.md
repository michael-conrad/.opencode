# Task: decompose

## Purpose

Break the problem into discrete units with defined interfaces, inputs, outputs, invariants, and failure modes. Define APIs, data contracts, and schemas before implementation.

## Entry Criteria

- Requirements extraction completed (or explicitly skipped for trivial specs)

## Exit Criteria

- Problem decomposed into discrete units
- Interfaces defined for each unit (APIs, data contracts, schemas)
- Invariants and failure modes documented
- For multi-phase specs: three-tier phase structure defined — global pre-phase, per-file RED/GREEN phases, global post-phase (SC-30)

## Procedure

### Step 1: Identify Discrete Units

Break the problem into logical units where each unit:
- Has a single clear purpose
- Has well-defined inputs and outputs
- Can be understood independently
- Can be tested independently

### Step 2: Define Interfaces First (Interface-First Thinking)

For each unit, define:
- **Interface Requirements:** What the unit must accept, return, and guarantee (function names, responsibilities, input/output contracts)
- **Data Boundaries:** What data exists, what constraints it satisfies, what invariants hold (table names, constraint tables, ownership boundaries)
- **Boundary conditions:** What crosses the unit boundary, in what format

**Why first:** Interface definitions constrain implementation correctly. Code written against undefined interfaces tends to couple to implementation details.

**Boundary discipline:**

| ✅ Spec-Level (WHAT) | ❌ Plan-Level (HOW) |
|-----------------------|----------------------|
| "validate_user() accepts user_id, returns bool" | `def validate_user(user_id: int) -> bool: ...` |
| "users table has unique email constraint" | `CREATE TABLE users (email TEXT UNIQUE)` |
| "processing must complete within 2s" | "use batch processing with chunk size 100" |
| "layer must not depend on presentation" | "use dependency injection pattern" |

### Step 3: Document Invariants

For each unit:
- What must always be true (preconditions, postconditions)
- What must never happen (safety invariants)
- What the unit guarantees to callers

### Step 4: Identify Failure Modes

For each unit:
- How can it fail? (input errors, dependency failures, resource exhaustion)
- What happens when it fails? (error propagation, fallback behavior, recovery)
- How is failure detected? (logging, metrics, alerts)

### Step 5: Define Three-Tier Phase Structure (SC-30 — multi-phase specs only)

For multi-phase specs, define a three-tier phase structure that the plan writer uses to organize the implementation plan:

| Tier | Section | Purpose | Example |
|------|---------|---------|---------|
| 1 — Global Pre-Phase | Before all per-file phases | Setup, pre-flight, coherence gate, baseline checks | "Phase 1 — Global Pre-Phase" |
| 2 — Per-File RED/GREEN Phases | One phase per file or concern | Each phase has its own RED/GREEN cycle with z3-check gates | "Phase 2 — Fix create.md", "Phase 3 — Fix write.md" |
| 3 — Global Post-Phase | After all per-file phases | Adversarial audit, cross-validate, regression, review prep, exec summary | "Phase N — Global Post-Phase" |

**Rules:**
- Tier 1 runs once at the start — steps are NOT duplicated in per-file phases
- Tier 2 phases are independent — each targets a specific file or concern with its own RED/GREEN cycle
- Tier 3 runs once at the end — steps are NOT duplicated in per-file phases
- The phase count in the spec's Phase section MUST match the number of Tier 2 phases + 2 (one pre, one post)
- Single-task specs (one phase total) do NOT need three-tier structure — they use a flat phase list

**Document the phase structure in the spec's Phase section:**

```markdown
## Phases

| Phase | Tier | Target | SCs |
|-------|------|--------|-----|
| Phase 1 — Global Pre-Phase | 1 (pre) | Setup, pre-flight, coherence | SC-1, SC-2 |
| Phase 2 — Fix create.md | 2 (per-file) | `.opencode/skills/writing-plans/tasks/create.md` | SC-3, SC-4 |
| Phase 3 — Global Post-Phase | 3 (post) | Audit, cross-validate, review | SC-5 |
```

## Content Coverage

Does the decomposition define clear units with:
- A single purpose for each unit?
- Defined interfaces (what goes in, what comes out)?
- Known invariants that must hold?
- Failure modes (how it fails, what happens)?

**Any format that communicates these concerns clearly is acceptable** — structured per-unit sections, tables, prose descriptions, or diagrams. The agent chooses the format that best serves the spec's complexity.

## Decomposition-Depth Mandate (MANDATORY)

**Decompose until each unit is a single independently verifiable claim whose PASS/FAIL cannot be split across two assertions.**

### Depth Rule

A unit is at the correct depth when:

- It asserts exactly one behavioral, structural, or semantic property
- A PASS verdict for the unit means exactly one thing is true
- A FAIL verdict for the unit identifies exactly one thing that is wrong
- The unit's PASS/FAIL cannot be meaningfully subdivided into two sub-claims that would each need their own assertion

### Stopping Criterion

Stop decomposing when ALL of the following are true:

1. **Atomicity:** The unit cannot be split into two independently verifiable sub-claims without losing meaning
2. **Single assertion:** A single test or verification step can produce a definitive PASS/FAIL for this unit
3. **No hidden conjunction:** The unit does not contain "and", "or", or implicit conjunction that bundles multiple claims
4. **Traceable:** The unit maps to exactly one SC in the spec's success criteria table

If any of these is false, decompose further.

### Reference to Incremental-Build Discipline

This decomposition-depth mandate is the spec-level expression of the incremental-build discipline defined in `091-incremental-build.md`. The per-item TDD cycle (RED → GREEN → REFACTOR → COMMIT) requires items at this decomposition depth. A spec whose units are not at this depth produces implementation items that violate the monolithic implementation prohibition in `000-critical-rules.md` §Monolithic Implementation.

**Cross-reference:** `091-incremental-build.md` §Per-Item TDD Cycle, `000-critical-rules.md` §Monolithic Implementation.

## Context Required

- Preceded by: `requirements`
- Feeds into: `traceability`, `risk`, `write`