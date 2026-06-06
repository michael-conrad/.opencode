# Research Card: Self-Generated vs Pre-Authored Checklists for Agent Workflow Execution

## Sources

1. **Zylos Research** (Mar 2026). "AI Agent Goal Decomposition and Hierarchical Planning."
2. **TDAG** (2025). "A multi-agent framework based on dynamic Task Decomposition and Agent Generation." ScienceDirect.
3. **GoalAct** (2025). "Enhancing LLM-Based Agents via Global Planning and Hierarchical Execution."
4. **OpenAI o-series / Claude Extended Thinking** (2025-2026). Embedded planning via reasoning tokens/thinking blocks.

## Key Findings

### 1. Plan-then-Execute is the proven pattern for multi-step work

Zylos (2026): "Plan-then-Execute generates the complete plan first — a frozen list of steps — and then executes each step in sequence. The plan is a contract: the executor follows it faithfully."

Benefits over interleaved (ReAct) for implementation work:
- **Predictability**: "Because the plan is materialized before execution, users and governance layers can inspect it, approve it, or modify it before any real-world actions occur."
- **Cost efficiency**: "Routing execution to cheaper models — Planner-Worker architecture demonstrated up to 90% cost reduction."
- **Quality**: "Forcing an explicit planning step causes the model to 'think through' the full task before acting, which improves task completion rate versus reactive approaches."

The checklist-in-tmp is a Plan-then-Execute artifact — materialized plan, frozen, executed against.

### 2. Explicit task decomposition improves tool use accuracy

Zylos (2026), citing research: "Explicit task decomposition improves tool use accuracy from approximately 72% to 94% compared to direct execution."

This is a 22 percentage-point improvement. The mechanism: the materialized decomposition acts as a binding contract. The agent executes against a plan it can see, not against a plan in memory.

### 3. Self-generated vs. external: the key difference

Two modes exist, and the research distinguishes them:

| Mode | How Plan is Created | Strengths | Weaknesses |
|------|--------------------|-----------|------------|
| **Pre-authored** (SKILL.md checklist) | Authored by developer in skill card | Verified, stable, cross-referenced with task files | Inflexible to novel task compositions |
| **Self-generated** (agent writes checklist to tmp/) | Agent decomposes the specific goal at runtime | Adapts to actual task scope, goal-specific | Quality varies, may hallucinate steps |

The Zylos research is about self-generated plans. The TDAG and GoalAct research confirms that dynamic decomposition (agent generates plan at runtime) works and is the standard approach for complex multi-step tasks.

**But** — the critical distinction for our architecture: self-generated plans suffer from the same pre-read contamination problem as the current architecture. If the agent generates a plan at runtime, it generates it from cached knowledge — which for implementation work includes the task files it pre-read at session start. The self-generated checklist would be a restatement of cached content, not a fresh decomposition.

**However**, if self-generation happens AFTER the skill() call (in sub-agent context, where task files are clean-room loaded), it avoids the pre-read problem. The sub-agent reads the task file fresh, decomposes the actual work, writes a checklist to tmp/, and executes against it.

### 4. Failure modes of self-generated plans

Zylos (2026): "LLMs can generate confident but subtly wrong decomposition trees — missing a prerequisite step, creating a circular dependency, or decomposing at the wrong granularity."

For implementation work, these failure modes are critical:
- **Missing prerequisite**: Omits a verification step → corrupted output
- **Circular dependency**: Loops back to an earlier phase → infinite or redundant work
- **Wrong granularity**: Steps too large (monolithic) or too small (thrashing)

### 5. The "plan verification" gap in self-generated checklists

Zylos (2026): "Separate verifier models — rather than asking the same model to plan and verify, a distinct verifier model reduces confirmation bias."

This maps to our adversarial-audit pattern: the agent that writes the checklist to tmp/ should NOT be the same agent that verifies the checklist. In our architecture, the orchestrator generates the plan from the spec (approved-by-human step), and the execution sub-agents verify against it — maintaining the separation.

### 6. Dynamic decomposition for novel tasks

TDAG (2025): "Dynamically decomposes complex tasks into smaller subtasks and assigns each to a specifically generated sub-agent, thereby enhancing adaptability in diverse and unpredictable real-world tasks."

This supports the "multiple checklists per skill" design: a skill card might define 3 path templates, but for a novel task composition, the sub-agent generates a task-specific decomposition in tmp/ from the task file instructions.

### 7. The "35-minute degradation problem"

Zylos (2026): "Agents that perform reliably on tasks up to ~35 minutes of elapsed execution time tend to degrade sharply beyond that threshold. Causes: context window saturation, error compounding, absence of robust checkpointing."

Materialized checklists in tmp/ act as checkpoint artifacts. If the agent crashes or degrades, the tmp/ checklist survives. The next invocation can pick up from the checkpoint rather than restarting.

## Relevance to Checklist Dispatch Architecture

| Aspect | How self-generated tmp/ checklists help | How pre-authored SKILL.md checklists help |
|--------|----------------------------------------|------------------------------------------|
| Task-specific adaptation | ✅ Agent decomposes actual goal | ❌ Fixed template |
| Verifiability | ❌ Agent may hallucinate steps | ✅ Authored and reviewed |
| Cross-referencing | ❌ No link to task files | ✅ Links to sub-agent task files |
| Survivability (checkpoint) | ✅ Survives in tmp/ | ✅ Survives in repo |
| Pre-read contamination | ❌ If generated from cached knowledge | ✅ If skill() flushes cache |
| Clean-room generation | ✅ If sub-agent generates in context | ✅ Pre-authored, no generation needed |

## Optimal Pattern (Synthesis)

The research suggests a **hybrid** is optimal:

1. **Pre-authored SKILL.md checklist** provides the skeleton — the verified, cross-referenced dispatch queue for the orchestrator
2. **Self-generated tmp/ checklist** (in sub-agent context) provides the task-specific decomposition — the actual step-by-step execution plan for the sub-agent
3. The tmp/ checklist is ephemeral (cleaned up after task completion) but serves as a checkpoint artifact during execution
4. The tmp/ checklist is generated from the task file loaded fresh in sub-agent context — NOT from cached orchestrator knowledge

This avoids the contamination problem (sub-agent loads task file fresh) while retaining the adaptation benefit of self-generated decomposition.

## Verified

Sat Jun 06 2026 — fetched from zylos.ai, ScienceDirect, arxiv