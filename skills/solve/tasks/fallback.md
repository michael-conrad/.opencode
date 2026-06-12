# Task: fallback — Manual Validation When Z3 Unavailable

## Purpose

Perform structural validation when Z3 is unavailable. Manual techniques: acyclic graph check for dependency cycles, dependency chain verification, and dependency ordering verification. These cover the most common workflow constraint patterns without a SAT solver.

## Entry Criteria

- Contract or dependency structure needs validation
- Z3 solver is unavailable (not installed, import fails, or timeout)
- Dependency relationships are known (manually specified or derived from contract variables)

## Procedure

### 1. Acyclic Graph Check

Verify the dependency graph has no cycles. A cycle means two or more items depend on each other, making the ordering unsolvable.

**Algorithm:**
1. Build adjacency list: for each dependency `A → B`, add edge from A to B
2. Run DFS with visited/in_stack tracking
3. If any back-edge found (node in current recursion stack reached again), report CYCLE DETECTED

**Cycle detection output:**
```
CYCLE DETECTED: <item1> → <item2> → <item3> → <item1>
```

**For each node in the cycle, report:**
- Node name
- Its dependencies
- How it participates in the cycle

**Acyclic result:**
```
ACYCLIC: <count> nodes, <edge_count> edges, no cycles found
```

### 2. Dependency Chain Verification

Verify that a linear chain of dependencies is complete and well-ordered.

**Procedure:**
1. Collect the ordered list of items: `[item_1, item_2, ..., item_N]`
2. For each adjacent pair `(item_i, item_{i+1})`, verify the dependency `item_i → item_{i+1}` exists
3. Check for missing dependencies (gap in the chain)
4. Check for transitive violations (indirect dependency exists but direct is missing)

**Chain verification output:**
```
CHAIN VALID: <N> items, all dependencies present
CHAIN BROKEN: missing dependency <item_i> → <item_{i+1}> at position <i>
```

### 3. Dependency Ordering Verification

Verify a given ordering against a set of dependency constraints.

**Procedure:**
1. Collect the ordered list of items
2. For each dependency constraint `A must precede B`:
   a. Find positions of A and B in the ordering
   b. Verify `position(A) < position(B)`
3. Report all violations

**Ordering output:**
```
ORDERING VALID: <N> constraints satisfied
ORDERING VIOLATION: <A> must precede <B> but <B> appears at position <pos_B> before <pos_A>
```

### 4. Contract Variable Dependency Analysis (String-typed Only)

When a contract exists (but Z3 is unavailable), analyze string-typed variables with domain constraints for ordering properties:

1. Extract string-typed variables with domain declarations
2. Identify any ordering semantics implied by the domain (e.g., pipeline phases: analysis < planning < implementation < verification)
3. Verify no state assigns values that violate ordering

This is limited to string-domain ordering and does not replace full Z3 constraint solving.

### 5. Limitations

| Z3 Capability | Fallback Equivalent | Limitation |
|---------------|-------------------|------------|
| SAT solving | Not available | Cannot find satisfying assignments for complex logical constraints |
| Unsat core | Not available | Cannot identify minimal conflicting constraint set |
| Theorem proving | Not available | Cannot prove logical theorems |
| Branching constraints | Not available | Cannot handle disjunctions or implications |
| Dependency cycle | Acyclic graph check | Available — structural only |
| Dependency chain | Chain verification | Available — structural only |
| Dependency ordering | Ordering verification | Available — structural only |

## Exit Criteria

- Acyclic check completed (cycle detected or acyclic confirmed)
- Dependency chain verified (valid or broken identified)
- Dependency ordering constraints verified (valid or violations reported)
- Limitations clearly stated when reporting results

## Cross-References

- `tools/solve` — Full Z3 implementation (check/model/prove)
- `tasks/contract.md` — Contract schema (preconditions, invariants for structural extraction)
- `tasks/check.md` — Z3-based state validation (preferred when Z3 available)
- `tasks/model.md` — Z3-based SAT query (preferred when Z3 available)
- `000-critical-rules.md` — Verification requirements that may need fallback