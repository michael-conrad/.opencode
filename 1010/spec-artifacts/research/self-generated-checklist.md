# Research Card: Self-Generated vs Pre-Authored Checklists for Agent Workflow Execution

## Sources

1. **Tian Pan** (May 2026). "The LLM-as-Compiler Pattern: Separating Plan Generation from Execution." tianpan.co.
2. **Zylos Research** (Mar 2026). "AI Agent Goal Decomposition and Hierarchical Planning."
3. **TDAG** (2025). "A multi-agent framework based on dynamic Task Decomposition and Agent Generation." ScienceDirect.
4. **GoalAct** (2025). "Enhancing LLM-Based Agents via Global Planning and Hierarchical Execution."
5. **By AI Team** (Dec 2025). "AI Agent Planning: ReAct vs Plan and Execute for Reliability."
6. **LangChain** (2024-2025). "Plan-and-Execute Agents" — LangGraph documentation and reference implementations.
7. **Dev.to — James Li** (2025). "ReAct vs Plan-and-Execute: A Practical Comparison." Empirical metrics: ReAct 85%, Plan-and-Execute 92% task completion accuracy.
8. **Confident AI / DeepEval** (Jun 2026). "LLM Agent Evaluation Metrics 2026." — Plan quality and plan adherence as distinct evaluation dimensions.
9. **Del Rosario et al** (2025). "Architecting Resilient LLM Agents: A Guide to Secure Plan-then-Execute Implementations." arXiv:2509.08646.
10. **PlanVault** (2026). "Production LLM Agent Security & Runtime Checklist." GitHub — plan as immutable artifact for auditability.

---

## 1. The LLM-as-Compiler Pattern (Tian Pan, May 2026)

### The Headline Result

PlanCompiler-style agent vs direct LLM generation on 300 stratified multi-step tasks:

| Approach | Success Rate | Cost per Task |
|----------|-------------|---------------|
| PlanCompiler (structured plan) | **92.67%** | **$0.00128** |
| Free-form ReAct loop | 62% | $0.0106 |

**50% more accurate at 1/8 the cost.** Both approaches use the same model. The difference is architecture: one separates plan generation from execution; the other conflates them.

### The Compiler Analogy

Karpathy's framing: an LLM is a **compiler**, not an interpreter. A compiler takes unstructured human intent, produces a structured executable artifact, and a deterministic runtime executes it. The compiler's job ends at the artifact boundary. Most agentic systems break this separation — the LLM acts as both compiler and runtime simultaneously.

The LLM-as-compiler pattern restores:

| Phase | What Happens | LLM Involvement |
|-------|-------------|-----------------|
| Plan generation | LLM emits complete structured execution plan | Required (frontier model) |
| Execution | Deterministic engine runs plan step-by-step | None until verification |
| Verification | Validate intermediate outputs against expected schemas | Optional (cheaper model) |

### Production Requirements for Structured Plans

A production implementation requires at minimum:

1. **Typed node registry**: LLM selects from fixed set of named operations with known input/output types. Cannot invent new tools or ad-hoc operations.
2. **Static validation before execution**: Plan checked for structural validity before any step runs: nodes exist, edges type-compatible, dependency graph acyclic, all parameters present.
3. **Immutable plan versioning**: Plan is a first-class artifact stored, versioned, and associated with its execution trace. If a run fails on step 7 of 12, the system replays from last checkpoint.

### Failure Modes It Solves

| Failure Mode | ReAct | PlanCompiler |
|-------------|-------|-------------|
| Hallucination amplification | Wrong data at step 3 propagates through 4,5,6 | Intermediate validation checkpoints break chain |
| Tool misuse cascade | With 15 tools, wrong-tool probability per step is substantial | Plan-time classification problem, better handled |
| Auditability gaps | Probabilistic decision record | Immutable artifact + execution trace |
| State corruption mid-execution | Agent may take unintended actions mid-task | Pre-validated plan defines execution boundary |

### When to Use / Skip

**Use when**: 5+ sequential steps with stable tool set, accuracy above 90% matters, auditability required, running at volume.

**Skip when**: Exploratory paths (ReAct better), simple queries (plan overhead > execution), tool set changes frequently, sub-500ms response time required.

---

## 2. Empirical Comparison: ReAct vs Plan-and-Execute

### Accuracy and Token Cost

James Li (2025), Dev.to — empirical comparison on data analysis tasks:

| Metric | ReAct | Plan-and-Execute |
|--------|-------|-----------------|
| Task completion accuracy | 85% | **92%** |
| Token consumption per task | 2,000-3,000 | 3,000-4,500 |
| API calls per task | 3-5 | 5-8 |
| Cost per task (GPT-4) | $0.06-0.09 | $0.09-0.14 |
| Complex task handling | Medium | **Strong** |
| Response time | **Faster** | Slower (upfront planning) |

Note: these numbers are from ~mid-2025 with GPT-4 pricing. The cost gap narrows with tiered execution (cheaper model for execution). The accuracy gap (85% vs 92%) is the persistent structural advantage.

### By AI Team (Dec 2025) — Hybrid Model

The most sophisticated systems today use **hybrid strategies**:

> "A common and powerful pattern is to use a high-level planner to outline the major stages of a task, and then use a ReAct-style executor to handle the fine-grained, adaptive execution of each individual stage. This creates a system with strategic coherence and tactical flexibility."

Key hybrid patterns identified:

| Pattern | Description |
|---------|-------------|
| **Continual planning** | Plan is a living document updated incrementally as new information emerges — avoids costly full replans while maintaining adaptability |
| **Tree-based exploration** | Generate and compare multiple candidate plans before committing — improves long-horizon task success |
| **Tool-aware RAG during planning** | Retrieve documentation on available tools and past successful workflows to ground proposed plan |
| **Multi-agent planning** | Specialized agents for planning, execution, and critique collaborate — mirrors expert human team |

---

## 3. Tiered Model Execution — The Cost Efficiency Mechanism

The key insight that makes Plan-and-Execute economically viable at scale:

> "One team reported using a frontier model for planning and a model 10× cheaper for execution, with accuracy degradation of less than 2%." — Tian Pan (2026)

**Why this works**: The planning phase is the cognitively hard part — decomposing goals, selecting tools, ordering steps. The execution phase is largely mechanical — run typed operations, pass outputs to inputs, validate at boundaries. Smaller models handle mechanical work nearly as well as frontier models.

Token economics are favorable because:
- Planner cost: paid once per task (frontier model, ~500-1500 tokens)
- Executor cost: paid per step (cheaper model, ~200-500 tokens per step)
- Total: amortized across N steps, planning overhead shrinks as steps increase

For our architecture: the orchestrator (frontier model) dispatches via checklist, and sub-agents (potentially cheaper models) execute against the tmp/ checklist decomposition.

---

## 4. Plan Caching and Reuse

Tian Pan (2026) — for workloads where similar tasks repeat:

> "Generated plans for common task patterns can be cached. The planning cost is paid once; subsequent runs skip directly to execution. Cache invalidation is straightforward: when the typed node registry changes, cached plans that reference modified nodes are invalidated."

This maps directly to our SKILL.md checklists — they ARE cached plans. The pre-authored checklist is the cache. The self-generated tmp/ decomposition is the runtime specialization.

For our architecture:
- SKILL.md checklist = permanent cache (version-controlled, reviewed)
- tmp/ decomposition = ephemeral cache (per-task specialization)
- When skill card changes → checklist cache invalidated (manifested by git diff)

---

## 5. Plan Quality and Plan Adherence as Evaluation Dimensions

Confident AI / DeepEval (Jun 2026) defines these as distinct agent evaluation metrics:

| Metric | What It Measures | How It's Evaluated |
|--------|-----------------|-------------------|
| **Plan quality** | Was the decomposition correct and complete before execution began? | LLM-as-judge: does plan cover all requirements? Are steps in correct order? No missing prerequisites? |
| **Plan adherence** | Did the agent stay aligned with the plan during execution, or did it deviate? | Trajectory-level: compare actual tool calls and steps against planned steps |

**Plan quality is evaluated at plan time** (before execution). **Plan adherence is evaluated at execution time** (during/after execution). These are two separate evaluation gates.

For our architecture:
- Plan quality gate: verify tmp/ checklist against task file + spec before execution begins
- Plan adherence check: verify sub-agent's actual execution against tmp/ checklist during/after execution

This creates the **verification loop**: generate → validate plan quality → execute → validate plan adherence → proceed to next step.

---

## 6. The "35-Minute Degradation Problem" and Checkpoints

Zylos (2026): "Agents that perform reliably on tasks up to ~35 minutes of elapsed execution time tend to degrade sharply beyond that threshold."

Causes:
- Context window saturation with accumulated tool outputs
- Error compounding across many steps
- Absence of robust checkpointing mechanisms

**Tian Pan (2026) confirms the checkpoint solution**: Immutable plan versioning means if a run fails on step N of M, the system knows exactly what plan was running and can replay from the last checkpoint rather than starting over.

For our architecture, the tmp/ checklist serves as the checkpoint artifact. Each checked item is a checkpoint boundary. If the agent degrades at step 9 of 12, the surviving checklist in tmp/ shows exactly what was completed and what remains. Next invocation starts from step 9, not step 1.

---

## 7. Self-Generated vs. Pre-Authored: Updated Comparison

Incorporating all new research:

| Aspect | Self-generated tmp/ checklist | Pre-authored SKILL.md checklist |
|--------|------------------------------|--------------------------------|
| **Task completion accuracy** | ~92% (with typed registry + validation) | Depends on author quality |
| **Cost efficiency** | Frontier plan + cheap execute = 8x reduction | Pre-computed, zero planning cost |
| **Plan caching** | Per-task ephemeral — discarded after run | Permanent — version-controlled |
| **Plan quality gate** | Must evaluate before execution (adversarial check) | Pre-verified by author/review |
| **Plan adherence check** | Required — agent may deviate | Required — agent may skip items |
| **Audit trail** | tmp/ artifact + execution trace | Repo history + execution trace |
| **Tool set coupling** | Tight — registry must match available tools | Tight — task files must match skill |
| **Failure mode** | Hallucinated steps, wrong decomposition | Stale or superseded by code changes |
| **Scalability** | Custom per task — no reuse | Reusable across sessions |

---

## 8. Optimal Hybrid Pattern (Revised)

Incorporating all evidence, the optimal pattern is now clearer:

### Layer 1: Pre-authored SKILL.md checklist (permanent cache)
- Verified, reviewed, version-controlled dispatch queue
- Orchestrator executes against this without reading task files
- Plan quality gate: passes automatically (author-verified)
- Acts as permanent cache — planning cost paid once at authoring time

### Layer 2: Self-generated tmp/ checklist (ephemeral specialization)
- Sub-agent generates task-specific decomposition in clean-room context
- Sub-agent loads task file fresh — no pre-read contamination
- Plan quality gate: sub-agent verifies decomposition against task file + spec before execution
- Acts as ephemeral cache — planning cost paid per task, but amortized within task

### Layer 3: Behavioral enforcement (the guard)
- Orchestrator must not read task files (asserted by corrupt-success test)
- Sub-agent must follow tmp/ checklist (asserted by plan adherence check)
- Plan quality must be verified by a different agent than the generator (Zylos — separate verifier confirmation bias)

### Layer 4: Checkpoint recovery (the safety net)
- tmp/ checklist survives in filesystem — not in context window
- Each checked item is a checkpoint boundary
- If agent degrades or crashes, next invocation resumes from last checked item
- Addresses the 35-minute degradation problem

---

## 9. Key Differences to Added to Architecture

### 9.1 Plan Quality Gate is MANDATORY for self-generated checklists

The plan quality metric (Confident AI 2026) must be evaluated BEFORE the sub-agent begins executing against a self-generated tmp/ checklist. The sub-agent generates the checklist, then the same sub-agent verifies it against the task file and spec before executing. Per Zylos: ideally a separate agent evaluates, but within a single sub-agent context, a self-verification step is acceptable with the caveat that confirmation bias may reduce accuracy.

**Required**: After sub-agent writes tmp/ checklist → evaluate plan quality → if FAIL, regenerate → only then execute.

### 9.2 Plan Adherence is a Trajectory-Level Metric

Plan adherence compares actual execution against the tmp/ checklist. This is evaluated at task completion or at checkpoint boundaries. If the sub-agent deviates from the checklist without cause, that's a FAIL. If deviation is correct (environment changed, tool returned unexpected data), that's a replan trigger, not a FAIL.

### 9.3 Continual Planning vs Frozen Plan

The architecture supports both modes:
- **Frozen plan** (default): tmp/ checklist is immutable once verified. Execute against it faithfully. Required for auditability and predictable execution.
- **Continual planning** (advanced): tmp/ checklist is a living document updated as new information emerges. Requires explicit authorization per spec (not default behavior).

### 9.4 Tiered Model Economics

The tiered model execution pattern (frontier planner, cheap executor) maps naturally:
- Orchestrator = frontier model (reads SKILL.md checklist, dispatches sub-agents)
- Sub-agent (plan generation) = frontier or mid-tier (generates tmp/ checklist from task file)
- Sub-agent (execution) = cheaper model (executes against verified tmp/ checklist)

This means the architecture can run the execution layer on a cheaper model without significant accuracy degradation (<2%).

---

## 10. Summary of Quantitative Findings

| Source | Finding | Measurement |
|--------|---------|-------------|
| Tian Pan (May 2026) | PlanCompiler accuracy | 92.67% vs 62% (ReAct) |
| Tian Pan (May 2026) | Cost per task | $0.00128 vs $0.0106 — 8x cheaper |
| James Li (2025) | Plan-and-Execute accuracy | 92% vs 85% (ReAct) |
| James Li (2025) | Plan-and-Execute tokens | 3,000-4,500 per task |
| Tian Pan (2026) | Tiered model degradation | <2% accuracy loss — frontier plan + 10x cheaper execute |
| Zylos (2026) | Task decomposition improvement | 72% → 94% tool use accuracy |
| Zylos (2026) | 35-minute degradation threshold | Sharp decline after ~35 min elapsed |
| Confident AI (2026) | Plan quality + adherence | Distinct evaluation dimensions — both required |

---

## Verified

Sat Jun 06 2026 — fetched from tianpan.co, zylos.ai, dev.to, confident-ai.com, arxiv.org, ScienceDirect, byaiteam.com