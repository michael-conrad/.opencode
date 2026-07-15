# Task: interface-compatibility

## Purpose

Verify that the interfaces of decomposed units are compatible with each other. For each pair of connected units, compare input/output types, verify preconditions of the consumer are satisfied by postconditions of the producer, and flag type mismatches and contract violations.

## Entry Criteria

- Decomposition completed (units identified with interfaces defined)
- Concern analysis completed (unit responsibilities known)

## Exit Criteria

- Every connected unit pair analyzed for interface compatibility
- Input/output types compared and verified compatible
- Pre/postconditions verified (consumer preconditions satisfied by producer postconditions)
- Type mismatches flagged and documented
- Contract violations flagged and documented
- Interface compatibility artifact produced

## Procedure

### Step 1: Identify Connected Unit Pairs

From the decomposition, identify all pairs of units that have a producer-consumer relationship:

- **Direct connection:** Unit A calls Unit B directly — A is the consumer, B is the producer
- **Data-flow connection:** Unit A produces data that Unit B consumes through an intermediate channel (database, message queue, file, API response)
- **Event-driven connection:** Unit A emits events that Unit B handles

For each pair, document the connection type and the direction of data flow.

### Step 2: Compare Input/Output Types

For each connected pair, compare the types:

- **Producer output type:** What type does the producer return or emit?
- **Consumer input type:** What type does the consumer accept?
- **Compatibility check:** Can the producer's output be assigned to the consumer's input? Consider:
  - Exact type match
  - Subtype compatibility (consumer accepts a supertype of what producer returns)
  - Coercion compatibility (implicit conversion exists)
  - Structural compatibility (duck typing, structural subtyping)
- **Mismatch flag:** Any type mismatch must be flagged with the specific type difference

### Step 3: Verify Pre/Postconditions

For each connected pair, verify contract compatibility:

- **Producer postconditions:** What does the producer guarantee after execution? (return value constraints, state invariants, side effect guarantees)
- **Consumer preconditions:** What does the consumer require before execution? (input constraints, state requirements, dependency availability)
- **Satisfaction check:** Does every producer postcondition satisfy the corresponding consumer precondition?
- **Contract violation flag:** Any precondition that is not guaranteed by a postcondition must be flagged as a contract violation

### Step 4: Document Interface Compatibility

Create a structured artifact containing:

- **Connected pairs table:** Every producer-consumer pair with connection type
- **Type compatibility matrix:** For each pair, the producer output type, consumer input type, and compatibility verdict (compatible / mismatch)
- **Contract verification table:** For each pair, the producer postconditions, consumer preconditions, and satisfaction verdict (satisfied / violation)
- **Mismatch report:** All type mismatches with specific type differences
- **Violation report:** All contract violations with specific precondition/postcondition gaps

### Step 5: Verify Coverage

Cross-reference the interface compatibility analysis against the decomposition. Verify that:

- Every unit in the decomposition appears in at least one connected pair (no isolated units)
- Every connection type (direct, data-flow, event-driven) is covered
- Every type mismatch is documented with a specific type difference
- Every contract violation is documented with a specific precondition/postcondition gap

## Content Coverage

Does the interface compatibility analysis cover:

- All connected unit pairs identified?
- Input/output type comparison for each pair?
- Pre/postcondition verification for each pair?
- Type mismatches flagged with specific differences?
- Contract violations flagged with specific gaps?
- Coverage verification against the decomposition?

**Any format that communicates these concerns clearly is acceptable.** A connected-pairs table with type and contract verification columns works well. The agent chooses the format that best serves the spec's complexity.

## Context Required

- Preceded by: `decompose`, `concern-analysis`
- Feeds into: `pipeline-readiness-gate`
