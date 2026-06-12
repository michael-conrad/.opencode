# Task: fallback

## Purpose

Manual validation procedures when Z3 solver is unavailable. Fallback methods provide correctness verification through graph theory and ordering logic — no SMT solver required. These methods are less expressive than Z3 but sufficient for simple acyclic DAG validation and dependency ordering checks.

## Entry Criteria

- Z3 solver confirmed unavailable (tool not found, import error, or timeout)
- Dependency graph or ordering constraints are defined

## Exit Criteria

- Acyclic graph check completed — cycle detected or confirmed acyclic
- Dependency ordering verified or conflict identified

## Procedure

### Step 1: Acyclic graph check

When Z3 is unavailable, verify that a directed dependency graph has no cycles using iterative topological sort:

```python
def is_acyclic(edges: list[tuple[str, str]]) -> bool:
    """Check directed graph for cycles. edges = [(from, to), ...]."""
    graph = {}
    in_degree = {}
    nodes = set()
    for src, dst in edges:
        nodes.add(src)
        nodes.add(dst)
        graph.setdefault(src, []).append(dst)
        if src not in in_degree:
            in_degree[src] = 0
        in_degree[dst] = in_degree.get(dst, 0) + 1
    queue = [n for n in nodes if in_degree.get(n, 0) == 0]
    visited = 0
    while queue:
        node = queue.pop(0)
        visited += 1
        for neighbor in graph.get(node, []):
            in_degree[neighbor] -= 1
            if in_degree[neighbor] == 0:
                queue.append(neighbor)
    return visited == len(nodes)
```

**Cycle detected:** Return BLOCKED with the cycle path. Example: `phase_3 -> phase_1 -> phase_2 -> phase_3`.

**Acyclic:** Return DONE with topological ordering.

### Step 2: Dependency ordering verification

When Z3 is unavailable, verify dependency ordering constraints manually:

```python
def verify_ordering(dependencies: list[tuple[str, str]], order: list[str]) -> bool:
    """Verify that for every (before, after) pair, before appears before after in order."""
    positions = {item: i for i, item in enumerate(order)}
    for before, after in dependencies:
        if positions.get(before, -1) >= positions.get(after, len(order)):
            return False
    return True
```

For each dependency constraint `A must complete before B`:
1. Verify A appears before B in the ordering
2. Report any violations

### Step 3: Dependency ordering conflict patterns

| Pattern | Detection | Resolution |
|---------|-----------|------------|
| Direct cycle | A → B and B → A in dependency list | HALT — circular dependency |
| Transitive cycle | A → B, B → C, C → A via topological sort | HALT — circular dependency |
| Missing dependency | B references A but A not in dependency list | FLAG — unregistered dependency |
| Partial order violation | A before B but B appears before A in order | FLAG — ordering constraint violated |
| Diamond dependency | A → B, A → C, B → D, C → D | Valid pattern — no conflict |
| Disconnected graph | A → B, C → D (no relation between groups) | Valid — independent subsystems |

### Step 4: Report

Return the fallback result contract:

```yaml
status: DONE|BLOCKED
method: acyclic_check|ordering_verification
result: acyclic|cycle_detected|ordering_valid|ordering_violation
details:
  - "<finding description>"
  - "<finding description>"
cycle_path: ["node_a", "node_b", "node_c"]  # if cycle detected
violations:
  - constraint: "<dependency before → after>"
    reason: "<why it's violated>"
```

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)