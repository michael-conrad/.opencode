# Research Card: Sub-Agent Architecture Patterns — Industry Validation

## Sources

1. **Martin Uke** (2025). "Sub-Agents in LLM Systems: Architecture, Execution Model, and Design Patterns." martinuke0.github.io.
2. **Azure Architecture Center** (2026). "AI Agent Orchestration Patterns." learn.microsoft.com.
3. **Future AGI** (2026). "LLM Agent Architectures 2026: Components and Patterns."

## Key Findings

### Finding 1: Sub-agents are the canonical scaling strategy

Martin Uke: "By 2025, most production-grade AI systems no longer rely on a single monolithic agent. Instead, they are composed of multiple specialized sub-agents, each responsible for a narrow slice of reasoning, execution, or validation."

Benefits: cognitive load partitioning, independent reasoning streams, parallel execution, fault isolation, deterministic interfaces.

### Finding 2: Context isolation is the primary benefit

> "Each sub-agent receives only the information required for its task. No global conversation history. A narrow instruction prompt."

Benefits: reduced hallucinations, lower token usage, higher determinism.

### Finding 3: Sequential pipeline is validated for multi-step implementation

Azure Architecture Center (2026): "The sequential orchestration pattern chains AI agents in a predefined, linear order. Each agent processes the output from the previous agent in the sequence."

**When to use**: multistage processes with clear linear dependencies, data transformation pipelines, workflow stages that can't be parallelized, progressive refinement (draft, review, polish).

**When to avoid**: Embarrassingly parallel stages, processes a single agent can handle, need for collaboration rather than handoff, dynamic routing needs.

### Finding 4: Orchestration patterns mapped to complexity

Future AGI (2026): Five shapes cover most production workloads:

| Pattern | Structure | Use Case |
|---------|-----------|----------|
| Single-agent ReAct | One model, one tool set, one loop | Simple tool use |
| Plan-and-Execute | Planner (frontier) + Executor (cheap) | Long-horizon tasks |
| Hierarchical supervisor | Supervisor routes to specialized workers | Complex workflows |
| Maker-checker | Actor produces, verifier scores/rewrites | High-stakes, cuts hallucinations |
| Network/swarm | Peer agents share scratchpad | Exploration, synthesis |

### Finding 5: When NOT to use sub-agents

Martin Uke: "Task is short and linear, latency is critical, compute budget is tight, determinism is mandatory."

### Finding 6: Tool isolation is critical

> "Sub-agents are commonly restricted to one or two tools, read-only or write-only access, predefined schemas. This dramatically reduces tool misuse."

Martin Uke cites: Tool use safety research (arXiv:2401.05561).

### Finding 7: Planner → Executor is the standard pattern

Martin Uke: "Planner agent decomposes the task. Executor sub-agents perform steps. Used for: long-horizon tasks, code generation, research workflows."

## Relevance

Our architecture is a hierarchical supervisor pattern (Azure: approved for complex workflows). The orchestrator (supervisor) dispatches to specialized sub-agents (executors). This is not novel architecture — it's industry-standard. The defect is solely that the orchestrator inlines instead of dispatching. The sub-agent architecture itself is validated.

**For implementation work specifically**, the Azure sequential pipeline pattern is the right model: clear linear dependencies, progressive refinement, multiple specializations. The checklist format enforces the sequence that Azure recommends.

## Verified

Sat Jun 06 2026 — fetched from martinuke0.github.io, learn.microsoft.com, futureagi.com