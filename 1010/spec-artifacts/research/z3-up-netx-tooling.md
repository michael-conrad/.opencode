# Research Card: Z3 + unified-planning + networkx Tooling Ecosystem for AI Agent Workflows

## Sources

1. **IRSB/Moat/Scout** (2026). "Z3 Formal Verification, the Three-Layer Stack." startaitools.com — Production Z3 verifier replacing LLM-as-a-judge with mathematical proofs. 9 constraints across 6 categories, fail-closed on UNKNOWN.
2. **z39** (2026). alejandroqh/z39 — Z3-powered reasoning for AI agents. Rust CLI + MCP server. 4 domain encoders (schedule, logic, config, safety) + raw SMT escape hatch. Ships as single binary.
3. **Z3Prover/z3** (2026). DeepWiki architecture overview — CDCL SAT solver core, SMT context with theory dispatch, AST management with hash-consing.
4. **ProofOfThought** (2025). Z3 theorem proving integrated with LLM reasoning — feedback loop: LLM generates, Z3 verifies, regenerate on inconsistency.
5. **unified-planning** (aiplan4eu, 2025-2026). Apache 2.0 Python library. v1.3.0 supports classical, temporal, numeric, multi-agent, hierarchical, scheduling, and TAMP planning. Factory-based engine auto-selection from ProblemKind classification.
6. **Z3 academic trends** (Mar 2026). Z3 GitHub discussions #9008 — Z3 is a foundational backend for security analysis, symbolic execution, and LLM-augmented verification, the three fastest-growing domains. Python API (z3py) dominates usage.
7. **LLM-Sym** (2024). arXiv:2409.09271 — LLM agent that automatically calls Z3 to solve execution path constraints in Python symbolic execution.
8. **A Logic-Driven Workflow Based on LLM Agents for SMT Code Generation** (2025). ACM — Z3 solver verification outcome used as core reward signal for MCTS-based code generation.
9. **GAP: Graph-based Agent Planning** (2025). arXiv:2510.25320 — Dependency-aware task graphs via networkx-compatible DAG planning. Parallel tool execution. 33.4% reduction in interaction turns.
10. **Zylos Research** (Apr 2026). "Agent Workflow Orchestration Patterns: DAG, Event-Driven, Actor." — DAG-based orchestration with networkx-like dependency management: determinism, automatic parallelization, strong observability.
11. **networkx** (2026) — Canonical Python library for graph/network analysis. Dependency DAG construction, cycle detection, topological sort, graph visualization via DOT output.

---

## Finding 1: Z3 is proven in production as an LLM-as-a-judge replacement

### IRSB/Moat/Scout (2026) — Production deployment

The most mature documented example. The `FormalAgentVerifier` uses Z3 to formally prove tool-call safety across 9 constraints (FILE_ACCESS, NETWORK, COMMAND_EXEC, DATA_EXFIL, RESOURCE_LIMIT, PERMISSION), returning one of three verdicts:

| Verdict | Meaning | Action |
|---------|---------|--------|
| PROVEN_SAFE | Z3 proved no constraint violation | Allow execution |
| PROVEN_UNSAFE | Z3 found a violation | Block execution |
| UNKNOWN | Solver timed out or inconclusive | Block execution (fail-closed) |

The system is **fail-closed**: UNKNOWN is treated as unsafe. This matches Saltzer and Schroeder's fail-safe defaults principle applied to formal verification — if you cannot prove it safe, treat it as unsafe.

**Key architectural pattern**: Z3 path traversal verification using string theory:
```python
solver = z3.Solver()
solver.set("timeout", self.config.solver_timeout_ms)
path_var = z3.String("path")
has_traversal = z3.Or(
    z3.Contains(path_var, z3.StringVal("..")),
    z3.Contains(path_var, z3.StringVal("//")),
)
solver.add(path_var == z3.StringVal(path))
solver.add(has_traversal)
result = solver.check()
```

> "A regex could be bypassed by encoding tricks. A Z3 proof cannot."

### z39 (2026) — Opensource CLI + MCP server

Single Rust binary bundling Z3 with four domain encoders + raw SMT escape hatch:

| Tool | Domain | Z3 Theory | Use Case |
|------|--------|-----------|----------|
| `z39 schedule` | Scheduling | QF_LIA | "Can I fit these meetings in my day?" |
| `z39 logic` | Boolean logic | QF_UF | "Are these rules equivalent?" |
| `z39 config` | Configuration | QF_LIA + enum | "Do these deployment rules conflict?" |
| `z39 safety` | Action precheck | Pure Rust | "Is it safe to delete this file?" |
| `z39 solve` | Raw SMT-LIB2 | Any | Arbitrary constraint solving |

**MCP server integration**: `z39 mcp` starts an MCP server over STDIO, exposing all domain tools plus async solve tools (solve_async, job_status, job_result, job_cancel). This allows any MCP-capable agent to call Z3 directly as a tool.

**Implication for our architecture**: The z39 pattern proves that Z3-as-an-agent-tool is viable and production-ready. A sub-agent could call `solve check` (our existing `.opencode/tools/solve`) or a future `z39`-like tool directly from its execution context to verify plan invariants before executing a step.

---

## Finding 2: Z3 + LLM integration has a documented pattern (ProofOfThought)

ProofOfThought (2025) defines a feedback loop:

```
User Input → LLM generates response → Z3 verifies consistency → if FAIL, LLM regenerates → if PASS, output
```

This is a **generate-verify-regenerate loop**. The Z3 result is not advisory — it's a gate that determines whether the LLM's output proceeds.

**The same pattern applies to our self-generated tmp/ checklists**:

```
Sub-agent reads task file → Sub-agent generates planning-problem YAML in tmp/
→ tools/solve check verifies invariants (Z3) → if UNSAT, regenerate problem definition
→ if SAT, execute against verified plan
```

This is already partially implemented with `tools/solve`. The missing piece (which #980 would provide) is the action sequence *generation* step, which `unified-planning` handles.

---

## Finding 3: unified-planning provides a planner-independent API (Apache 2.0)

### Capabilities (v1.3.0)

| Problem Type | Supported? | How the agent uses it |
|-------------|-----------|----------------------|
| Classical planning | ✅ | Define actions, preconditions, effects → get action sequence |
| Temporal planning | ✅ | Add duration constraints to actions |
| Numeric planning | ✅ | Track resource consumption across steps |
| Multi-agent planning | ✅ | Define agent-specific actions and coordination |
| Hierarchical planning | ✅ | Define compound tasks decomposed into primitives |
| Scheduling | ✅ | Timelines, resource allocation |
| Task and Motion Planning | ✅ | Combined symbolic + continuous planning |

### Engine Auto-Selection

The `ProblemKind` classifier automatically determines which planning engines can solve a given problem based on its feature profile (action types, fluent types, effect patterns). The factory pattern selects compatible engines without manual configuration.

### For our architecture

When a sub-agent needs to generate an execution plan from a task file:

1. Sub-agent defines the workflow as a `unified-planning` Problem (Python API)
2. Problem is grounded/converted via library transformations
3. Engine auto-selects and generates the plan
4. Plan is validated for goal achievement
5. Sub-agent executes the validated plan step-by-step

The YAML problem schema in #980's spec is a serialization format that maps to `unified-planning`'s internal representation. The tool wraps the Python API behind a CLI for sub-agent invocation.

---

## Finding 4: networkx enables DAG-based dependency analysis for agent workflows

### Research evidence

**GAP (2025)**: "Graph-based Agent Planning explicitly models inter-task dependencies through graph-based planning to enable adaptive parallel and serial tool execution." Achieved 33.4% reduction in interaction turns through parallelization of independent subtasks.

**Zylos (Apr 2026)**: DAG-based orchestration is one of three dominant patterns (DAG, event-driven, actor). Core strengths: determinism (same inputs = same execution order), automatic parallelization of independent branches, strong observability (node-level failure tracking). Limitation: static topology, acyclicity constraint.

**Multi-Agent Orchestration Framework** (Emergent Mind, 2026): "Decomposes tasks into dependency-annotated DAGs, assigns roles with agent hierarchies, and employs dynamic scheduling. Empirical benchmarks demonstrate 12-23% accuracy improvements and significant cost/latency reductions."

### networkx capabilities for workflow planning

| Capability | What it provides | Use in our architecture |
|-----------|-----------------|----------------------|
| Dependency DAG construction | Build graph from action preconditions/effects | Plan structure validation |
| Cycle detection | `nx.find_cycle()` or `nx.is_directed_acyclic_graph()` | Reject invalid plans with circular dependencies |
| Topological sort | `nx.topological_sort()` | Determine valid execution order |
| Parallel branch identification | Nodes with no shared dependencies | Sub-agent parallelization opportunities |
| Graph visualization | DOT output, `nx.draw()` | Debugging plan structure |
| Longest path | `nx.dag_longest_path()` | Critical path analysis (minimum execution time) |

---

## Finding 5: The three tools form a complementary stack

### Current state (.opencode/tools/)

| Tool | Status | What it does | GAP (missing) |
|------|--------|-------------|---------------|
| `solve` | ✅ Exists | Z3 constraints checking, theorem proving, state management | Cycle detection is manual; needs networkx integration |
| (none) | ❌ #980 proposed | `unified-planning` action sequence generation | Needs `tools/plan` to be built |
| (none) | ❌ Not proposed | networkx DAG analysis | Not yet proposed as standalone tool |

### Proposed three-tool stack

| Layer | Tool | Deterministic? | What it verifies |
|-------|------|---------------|-----------------|
| Plan generation | `tools/plan` (#980) | ✅ Classical planning | Generate action sequence from problem definition |
| Plan validation | `tools/plan validate` | ✅ networkx + UP | Cycle-free, goals achievable, topological order valid |
| Invariant checking | `tools/solve` | ✅ Z3 | State invariants hold across all plan steps |

### How agents invoke the stack

```
Sub-agent receives task
  │
  ▼
1. Define planning problem (YAML or unified-planning Python API)
  │
  ▼
2. tools/plan plan --problem tmp/problem.yaml → tmp/plan.yaml (action sequence)
  │
  ▼
3. tools/plan validate --problem tmp/problem.yaml --plan tmp/plan.yaml → PASS/FAIL
  │  (networkx: cycle detection, topological sort, dependency validation)
  │
  ▼
4. tools/solve check --contract tmp/contract.yaml --state tmp/state.yaml → PASS/FAIL (Z3 invariant checking)
  │
  ▼
5. If all PASS → execute plan step-by-step
   If any FAIL → refine problem definition, regenerate
```

All three tools are **deterministic** — no LLM-as-judge required for plan quality or plan adherence.

---

## Finding 6: Z3 ecosystem maturity — production-ready for agent workflows

### Academic validation

- Z3 is the most-cited SMT solver for LLM-augmented verification (GitHub Z3 discussions #9008, Mar 2026)
- The Python API (z3py) dominates usage across security analysis, symbolic execution, and LLM verification
- ProofOfThought (2025), LLM-Sym (2024), and Logic-Driven Workflow (2025) all independently validate the Z3+LLM integration pattern

### Production deployments

- **IRSB/Moat/Scout**: FormalAgentVerifier in production for AI agent tool-call safety — Z3 used as the decision engine with fail-closed semantics
- **z39**: Single-binary CLI + MCP server, auto-provisioning Z3, 4 domain encoders — proving the tool-as-agent-interface pattern works
- **solve**: Already exists in our `.opencode/tools/` directory and is used for workflow contract validation

### No external dependency concerns

- Z3 is MIT-licensed (Microsoft Research)
- unified-planning is Apache 2.0 (AIPlan4EU project)
- networkx is BSD-3-Clause
- All three are well-maintained, have active communities, and have published academic papers validating their approaches

---

## Finding 7: Implications for the checklist dispatch architecture

### Current (without #980/tools/plan)

```
Orchestrator dispatches sub-agent via SKILL.md checklist row
  │
  ▼
Sub-agent loads task file (clean-room)
  │
  ▼
Sub-agent writes markdown checklist to tmp/ (LLM-generated, probabilistic)
  │
  ▼
Plan quality gate: LLM-as-judge (probabilistic, confirmation bias risk)
  │
  ▼
Sub-agent executes against tmp/ checklist
```

### Proposed (with tools/plan + tools/solve + (optional networkx tool))

```
Orchestrator dispatches sub-agent via SKILL.md checklist row
  │
  ▼
Sub-agent loads task file (clean-room)
  │
  ▼
Sub-agent defines unified-planning problem (YAML in tmp/)
  │
  ▼
tools/plan plan → deterministic action sequence (classical planning)
  │
  ▼
tools/plan validate → networkx cycle check + topological sort + goal verification
  │
  ▼
tools/solve check → Z3 invariant proof
  │
  ▼
All deterministic PASS → execute (or FAIL → refine problem definition)
```

**The probabilistic step narrows dramatically**: from "LLM generates full execution sequence" to "LLM translates task file to planning-problem definition." This is a fundamentally simpler cognitive task — define what exists (objects, fluents), what can happen (actions, preconditions, effects), and what success looks like (goals). The planning itself is deterministic.

---

## Verified

Sat Jun 06 2026 — fetched from startaitools.com, github.com/alejandroqh/z39, deepwiki.com (Z3Prover/z3), dev.to/proofofthought, unified-planning.readthedocs.io, arxiv.org, deepwiki.com (aiplan4eu/unified-planning), zylos.ai, github.com/Z3Prover/z3/discussions/9008, acm.org

## Related Tools Already in .opencode/tools/

| Tool | Exists? | Purpose |
|------|---------|---------|
| `solve` | ✅ | Z3 constraint solving for workflow contract/state validation |
| `plan` | ❌ (#980) | unified-planning action sequence generation |
| See also: `run-texted-mcp` | ✅ | Text editing MCP server |
| See also: `local-issues` | ✅ | Local issue tracking in .issues/ |