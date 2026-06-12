# Task: fallback

## Purpose

Perform a manual acyclic check when the `plan` tool is unavailable. Use this fallback when the planner itself is the subject of a spec fix or when infrastructure constraints prevent planner invocation.

## Entry Criteria

- `plan` tool is unavailable or inapplicable
- Phases and their dependencies are enumerated

## Procedure

### Step 1: Collect Phases and Dependencies

List all phases and their dependencies. Format: each phase has zero or more prerequisite phases.

### Step 2: Build Directed Graph

Construct a directed graph where edge from phase A to phase B indicates A depends on B:

```
A → B  means "A depends on B" (B must complete before A)
```

### Step 3: Topological Sort

Run topological sort on the dependency graph. If the sort succeeds, no cycles exist. If the sort fails, a cycle is detected.

For small graphs, manual inspection suffices. For larger graphs, use Python/networkx:

```python
import networkx as nx
G = nx.DiGraph()
G.add_edges_from([("A", "B"), ("B", "C")])
list(nx.topological_sort(G))  # Raises NetworkXUnfeasible if cycle
```

### Step 4: Verify Dependency Validity

Confirm every dependency references a valid existing phase. Orphan dependencies (dependencies on nonexistent phases) are equivalent to cycles.

## Exit Criteria

- Dependency graph has no cycles
- Every dependency references a valid phase

## When to Use

Use this fallback instead of `plan plan` when the `plan` tool itself is the subject of a spec fix or is unavailable due to infrastructure constraints.