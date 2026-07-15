# Task: code-path-analysis

## Purpose

Enumerate all execution paths through affected code, map data flow through each path (inputs → transformations → outputs → side effects), and mandate path-level test coverage. Produce a path inventory with coverage requirements for every identified path.

## Entry Criteria

- Decomposition completed (units identified with interfaces defined)
- Blast radius analysis completed (affected symbols known)

## Exit Criteria

- All execution paths enumerated for each changed function
- Data flow mapped through each path (inputs, transformations, outputs, side effects)
- Path inventory produced with coverage requirements
- Every path has at least one corresponding test requirement
- No path is missed (coverage verified)

## Procedure

### Step 1: Enumerate Execution Paths

For each changed function or unit, enumerate all distinct execution paths:

- **Happy path:** The primary success path — inputs are valid, dependencies are available, no errors occur
- **Conditional branches:** Each branch of every conditional (if/else, switch/case, match arms, ternary expressions)
- **Error paths:** Each distinct error condition and how it is handled (return error, throw exception, fallback, retry)
- **Edge cases:** Boundary conditions (empty inputs, null values, maximum values, minimum values, type boundaries)
- **Early returns:** Each early return or early exit point and the condition that triggers it
- **Loop paths:** Zero-iteration, single-iteration, multi-iteration, and infinite-loop guard paths

For each path, document:

- **Trigger condition:** What input or state causes this path to execute
- **Path description:** A concise description of what happens along this path

### Step 2: Map Data Flow Through Each Path

For each enumerated path, trace the data flow:

- **Inputs:** What data enters the path (function parameters, global state, database reads, external API calls)
- **Transformations:** How the data is transformed along the path (calculations, conversions, mutations, enrichments)
- **Outputs:** What data leaves the path (return values, database writes, external API calls, file writes)
- **Side effects:** What state changes occur outside the data flow (logging, metrics, cache invalidation, event emission, UI updates)

Document the data flow as a sequence: Input → Transformation 1 → ... → Transformation N → Output + Side Effects.

### Step 3: Produce Path Inventory

Create a structured artifact containing:

- **Path inventory table:** Every enumerated path with trigger condition, description, and data flow
- **Coverage requirements:** For each path, the minimum test coverage required (at least one test that exercises this path)
- **Path-to-SC mapping:** Which spec success criteria exercise each path
- **Gap analysis:** Paths that have no corresponding SC — these are coverage gaps

### Step 4: Mandate Path-Level Test Coverage

For every path in the inventory, verify that at least one SC or test requirement exercises it. Paths without coverage are defects:

- **Happy path:** Must have at least one SC that verifies the primary success behavior
- **Conditional branches:** Each branch must have at least one SC that exercises it
- **Error paths:** Each error condition must have at least one SC that verifies correct error handling
- **Edge cases:** Each edge case must have at least one SC that verifies correct behavior at the boundary
- **Early returns:** Each early return must have at least one SC that verifies the return condition
- **Loop paths:** Zero-iteration, single-iteration, and multi-iteration must each have at least one SC

### Step 5: Verify Coverage

Cross-reference the path inventory against the spec's SC table. Verify that:

- Every path has at least one corresponding SC
- Every SC exercises at least one path
- No path is orphaned (no SC covers it)
- No SC is orphaned (it exercises no path — possible scope creep)

## Content Coverage

Does the code path analysis cover:

- All execution paths enumerated (happy, conditional, error, edge case, early return, loop)?
- Data flow mapped for each path (inputs, transformations, outputs, side effects)?
- Path inventory with coverage requirements?
- Path-level test coverage mandated for every path?
- Coverage verification against the SC table?

**Any format that communicates these concerns clearly is acceptable.** A structured path inventory table with data flow sequences and coverage mappings works well. The agent chooses the format that best serves the spec's complexity.

## Context Required

- Preceded by: `decompose`, `blast-radius`
- Feeds into: `traceability`, `pipeline-readiness-gate`
