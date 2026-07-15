# Task: cross-cutting

## Purpose

Discover concerns that span multiple phases or components, produce a propagation map showing which phases each cross-cutting concern touches, and create a concern-to-phase matrix. Ensure cross-cutting concerns are explicitly identified and accounted for in every affected phase.

## Entry Criteria

- Decomposition completed (units identified)
- Concern analysis completed (concern-to-unit mapping available)

## Exit Criteria

- All cross-cutting concerns identified
- Propagation map produced for each cross-cutting concern
- Concern-to-phase matrix created
- Every cross-cutting concern has a designated handling strategy
- No cross-cutting concern is missed (coverage verified)

## Procedure

### Step 1: Scan Units for Recurring Concern Patterns

After decomposition and concern analysis, scan all units for recurring patterns that appear across multiple units. Common cross-cutting concern categories:

| Category | Examples |
|----------|----------|
| **Error handling** | Error propagation, exception translation, retry logic, fallback behavior |
| **Logging and observability** | Structured logging, metrics emission, trace propagation, audit trails |
| **Validation** | Input validation, authorization checks, data integrity verification |
| **Configuration** | Feature flags, environment-specific behavior, runtime configuration |
| **Security** | Authentication gates, permission checks, data sanitization, encryption |
| **Transaction management** | Atomicity, rollback, commit, distributed transaction coordination |
| **Caching** | Cache invalidation, cache warming, cache-aside patterns |
| **Bylines and attribution** | AI co-authored attribution, provenance headers, copyright notices |

For each recurring pattern, determine whether it is a cross-cutting concern (appears in multiple units) or a coincidental pattern (appears in multiple units but is not a concern — just a shared implementation detail).

### Step 2: Classify Each Cross-Cutting Concern

For each identified cross-cutting concern, classify:

- **Scope:** Which phases or components does it touch?
- **Uniformity:** Is the concern handled identically across all affected units, or does it vary per unit?
- **Centralization:** Is there a central mechanism (middleware, decorator, base class) that handles this concern, or is it handled ad-hoc in each unit?

### Step 3: Produce Propagation Map

For each cross-cutting concern, create a propagation map showing:

- **Entry points:** Where the concern first appears in the execution flow
- **Propagation path:** How the concern flows through the system (which units it touches, in what order)
- **Exit points:** Where the concern leaves the system boundary
- **Handling points:** Where the concern is explicitly handled (logged, validated, authorized, etc.)

### Step 4: Create Concern-to-Phase Matrix

Create a matrix mapping each cross-cutting concern to the phases it affects:

| Cross-Cutting Concern | Phase 1 | Phase 2 | Phase 3 | ... | Handling Strategy |
|-----------------------|---------|---------|---------|-----|-------------------|
| Error handling | ✅ | ✅ | ❌ | ... | Central error middleware |
| Logging | ✅ | ✅ | ✅ | ... | Decorator pattern |
| Validation | ❌ | ✅ | ❌ | ... | Per-unit validation |

### Step 5: Verify Coverage

Cross-reference the cross-cutting analysis against the full set of units and phases. Verify that:

- Every cross-cutting concern is listed in the matrix
- Every phase that touches a cross-cutting concern has it marked
- Every cross-cutting concern has a designated handling strategy
- No cross-cutting concern is missed (scan all units for unclassified recurring patterns)

## Content Coverage

Does the cross-cutting analysis cover:

- All recurring patterns identified across units?
- Cross-cutting concerns distinguished from coincidental patterns?
- Propagation map for each cross-cutting concern?
- Concern-to-phase matrix?
- Handling strategy for each cross-cutting concern?
- Coverage verification against all units?

**Any format that communicates these concerns clearly is acceptable.** A concern-to-phase matrix with propagation maps works well. The agent chooses the format that best serves the spec's complexity.

## Context Required

- Preceded by: `decompose`, `concern-analysis`
- Feeds into: `traceability`, `pipeline-readiness-gate`
