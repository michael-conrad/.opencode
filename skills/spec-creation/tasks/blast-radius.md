# Task: blast-radius

## Purpose

Analyze the dependency impact of changed code by traversing the call graph, mapping data flow, and identifying all downstream consumers. Produce a blast radius artifact that classifies every affected symbol by impact severity and documents the propagation path.

## Entry Criteria

- Decomposition completed (units identified with interfaces defined)
- Changed symbols identified from the spec's scope

## Exit Criteria

- Dependency graph traversed from each changed symbol outward
- Every affected symbol classified by impact severity
- Blast radius artifact produced with propagation paths
- No downstream consumer is missed (coverage verified)

## Procedure

### Step 1: Identify Changed Symbols

From the spec's scope and decomposition, identify the set of symbols (functions, classes, modules, configuration keys, data schemas) that are directly modified by the change. These are the root nodes of the blast radius analysis.

### Step 2: Traverse the Dependency Graph

For each changed symbol, walk the dependency graph outward:

- **Direct consumers:** Symbols that directly call, import, or reference the changed symbol. These are the first ring of impact.
- **Indirect consumers:** Symbols that consume a direct consumer. These form the second ring and beyond.
- **Data-flow dependents:** Symbols that depend on data produced by the changed symbol, even if they do not call it directly. These are found by tracing data flow paths (outputs → consumers → their outputs → further consumers).

Continue traversing until no new affected symbols are found, or until the traversal reaches a natural boundary (module boundary, service boundary, public API surface).

### Step 3: Classify Each Affected Symbol

For every symbol found in the traversal, classify by impact severity:

| Classification | Definition | Example |
|---------------|------------|---------|
| **Direct consumer** | Symbol directly calls, imports, or references the changed symbol | A function that calls the modified function |
| **Indirect consumer** | Symbol consumes a direct consumer but not the changed symbol directly | A function that calls a function that calls the modified function |
| **Data-flow dependent** | Symbol depends on data produced by the changed symbol through a chain of transformations | A report generator that reads data written by the modified module |

Document the propagation path for each affected symbol: the chain of symbols through which the impact reaches it.

### Step 4: Produce Blast Radius Artifact

Create a structured artifact containing:

- **Root symbols:** The set of directly changed symbols
- **Affected symbols table:** Every symbol found in the traversal, with impact classification and propagation path
- **Boundary symbols:** Symbols at the edge of the blast radius where impact stops (module boundaries, service boundaries)
- **Coverage verification:** Confirmation that no downstream consumer was missed — cross-reference against the full dependency graph

### Step 5: Verify Coverage

Cross-reference the blast radius artifact against the full dependency graph of the affected area. Verify that:

- Every direct consumer of a changed symbol is listed
- Every indirect consumer reachable through a direct consumer is listed
- Every data-flow dependent reachable through a data chain is listed
- No symbol within the natural boundary is omitted

## Content Coverage

Does the blast radius analysis cover:

- All changed symbols as root nodes?
- Direct consumers (first ring of impact)?
- Indirect consumers (second ring and beyond)?
- Data-flow dependents (data chain consumers)?
- Impact classification for every affected symbol?
- Propagation path for every affected symbol?
- Coverage verification against the full dependency graph?

**Any format that communicates these concerns clearly is acceptable.** A structured table with root symbols, affected symbols, classifications, and propagation paths works well. The agent chooses the format that best serves the spec's complexity.

## Context Required

- Preceded by: `decompose`
- Feeds into: `traceability`, `pipeline-readiness-gate`
