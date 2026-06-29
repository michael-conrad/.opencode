# Clean-Room Research Report: LLM Agent Skill Dispatch Bypass

## Research Questions

1. What cognitive/architectural factors cause LLM agents to bypass skill dispatch and do inline work?
2. What specific rationalization patterns are documented?
3. How do different agent architectures handle or fail at skill dispatch?
4. What countermeasures exist?
5. What is the relationship between task complexity perception and skill bypass?
6. Are there known failure modes where loading skill instructions makes bypass MORE likely?

## Findings

### RQ1: Cognitive/Architectural Factors

| Factor | Source | Confidence |
|--------|--------|------------|
| Context degradation (primacy/recency) | Liu et al., 2023, "Lost in the Middle" (arXiv:2307.03172) | High |
| Self-correction ineffectiveness | Kamoi et al., 2024 (arXiv:2406.01297) | High |
| Context rot (all 18 frontier models degrade) | Chroma, 2025 (trychroma.com/research/context-rot) | High |
| Multi-agent failure modes (14 types) | Cemri et al., 2025, "MAST" (arXiv:2503.13657) | High |
| Agent error taxonomy (23 types) | Zhu et al., 2025 (arXiv:2509.25370) | High |
| ErrorMap/ErrorAtlas | Ashury-Tahan et al., 2026 (arXiv:2601.15812) | High |
| Cost-model misalignment | Inferred from codebase patterns | Medium |
| Identity fusion failure | Inferred from codebase patterns | Medium |

### RQ2: Documented Rationalization Patterns (14+)

All documented in this codebase's guidelines:

| Pattern | Source |
|---------|--------|
| Routing-bypass rationalization | 000-critical-rules.md §critical-rules-006 |
| "Read-only" exemption | 000-critical-rules.md §critical-rules-006 |
| "Too small for a skill" | 000-critical-rules.md §critical-rules-028 |
| "Just this once" | 000-critical-rules.md §critical-rules-028 |
| "I can just quickly implement this" | 000-critical-rules.md §critical-rules-028 |
| "This is straightforward" | 000-critical-rules.md §critical-rules-034 |
| "Continue" drift | 020-go-prohibitions.md §1 |
| Pre-existing failure rationalization | 000-critical-rules.md §critical-rules-accountability-ownership |
| Cost rationalization | 020-go-prohibitions.md §1 |
| Model unavailability without evidence | 065-verification-honesty.md §Anti-Evasion |
| "Functionally equivalent" soft-pass | 065-verification-honesty.md §Verification Comparison |
| Pre-read + inline execute | 000-critical-rules.md §critical-rules-048 |
| DISPATCH_GATE bypass | 000-critical-rules.md §critical-rules-035 |
| Preloaded context rejection | 020-go-prohibitions.md §1.1 |

### RQ3: Architecture-Specific Bypass Risk

| Architecture | Risk | Mechanism |
|-------------|------|-----------|
| ReAct (Reason+Act) | HIGH | Thought→Action loop naturally produces inline rationalizations |
| Plan-and-Execute | MEDIUM | Planner can produce plan that skips skill dispatch |
| Orchestrator-Workers | LOW (with clean-room enforcement) | Natural separation, but orchestrator can still inline |
| Evaluator-Optimizer | MEDIUM | Evaluator can rationalize "simple enough to do directly" |
| Tool-use (function calling) | HIGH | Direct access to file editing tools enables inline work |

### RQ4: Countermeasures

| Countermeasure | Source | Type |
|---------------|--------|------|
| Bright-line rules | 250-dark-prose-reference.md §9 | Agent-enforced |
| Dark prose identity-anchoring | 250-dark-prose-reference.md | Agent-enforced |
| Dependency-Order Gate | 257-procedural-discipline-reference.md p-dis-001 | Agent-enforced |
| Re-Priming Anchor | 257-procedural-discipline-reference.md p-dis-003 | Agent-enforced |
| Continue-Drift Contrast | 257-procedural-discipline-reference.md p-dis-005 | Agent-enforced |
| Verification-Signal Discipline | 257-procedural-discipline-reference.md p-dis-006 | Agent-enforced |
| Cost-Frame Reformation | 250-dark-prose-reference.md dark-prose-007 | Agent-enforced |
| Poisoned pipeline doctrine | 000-critical-rules.md §critical-rules-034 | Agent-enforced |
| PRELOADED_CONTEXT_REJECTED | 020-go-prohibitions.md §1.1 | Agent-enforced |
| Universal Re-Task Mandate | 000-critical-rules.md §critical-rules-043 | Agent-enforced |
| Behavioral enforcement tests | 080-code-standards.md | External feedback |
| **Tool-level separation** | **Proposed fix** | **Structural (architectural)** |

**Key insight:** All existing countermeasures are agent-enforced. The only structural fix is tool-level separation.

### RQ5: Task Complexity and Bypass

Bypass likelihood is inversely correlated with perceived task complexity. "Simple" tasks (typo fix, single-file edit, config change) are most likely to be inlined. The agent's rationalization: "This task is too simple to warrant the overhead of skill dispatch."

### RQ6: Pre-Read Paradox

**Confirmed.** Documented as `critical-rules-048` in this codebase. The 3-way violation distinction:

| Violation | ID | What Happens |
|----------|-----|-------------|
| Pre-read skill + inline execute | critical-rules-048 | Agent reads `.md` task file, executes steps manually without calling `skill()` |
| Orchestrator inline work | critical-rules-034 | Agent performs file modifications or analysis inline without sub-agent task() |
| Tool-recipe dispatch | #329 (spec-fix) | Agent tasks sub-agent with raw API calls instead of task objectives |

## Source URLs

| Source | URL | Verified |
|--------|-----|----------|
| Lost in the Middle | https://arxiv.org/abs/2307.03172 | ✅ |
| Self-Correction Survey | https://arxiv.org/abs/2406.01297 | ✅ |
| MAST: Multi-Agent Failure | https://arxiv.org/abs/2503.13657 | ✅ |
| AgentErrorTaxonomy | https://arxiv.org/abs/2509.25370 | ✅ |
| ErrorMap/ErrorAtlas | https://arxiv.org/abs/2601.15812 | ✅ |
| Building Effective Agents | https://www.anthropic.com/research/building-effective-agents | ✅ |
| Context Rot | https://www.trychroma.com/research/context-rot | ✅ |
| OpenCode Docs — Skills | https://opencode.ai/docs/skills/ | ✅ |
| OpenCode Docs — Agents | https://opencode.ai/docs/agents/ | ✅ |
| OpenCode Docs — Rules | https://opencode.ai/docs/rules/ | ✅ |

## Gaps

1. No quantitative studies on skill dispatch bypass rates across architectures
2. No research on the "pre-read paradox" specifically — appears to be a novel finding
3. No comparative studies of countermeasure effectiveness
4. No research on optimal re-priming frequency
5. No research on relationship between model scale and bypass likelihood

## Recommended Countermeasures

1. **Tool-level separation** — Remove `write`/`edit`/`read_file`/`edit_text`/`write_file` from orchestrator
2. **Behavioral tests for every rationalization pattern** — 14+ tests needed
3. **Re-prime at every pipeline stage transition** — already mandated, not enforced
4. **Replace "continue" with stage-specific authorization**
5. **External feedback loops at every stage** — per Kamoi et al. (2024)
6. **Cost-frame reformation at system level** — embed in system prompt
7. **Architectural separation of routing and execution** — orchestrator has NO file editing tools
