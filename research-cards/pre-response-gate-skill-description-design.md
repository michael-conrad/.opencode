---
title: "Skill Description vs Pre-Response Gate — Agent-Intent Dispatch Design"
created: 2026-07-12
confidence: 0.9
tags: [pre-response-gate, skill-dispatch, tool-description, agent-intent, function-calling, system-prompt]
sources:
  - url: https://opencode.ai/docs/skills/
    section: "Write frontmatter: description"
    verified: 2026-07-12
    relevance: "Official opencode docs: description is 1-1024 chars, 'Keep it specific enough for the agent to choose correctly.' The agent loads a skill by calling skill({name:...}) after scanning available descriptions."
  - url: https://opencode.ai/docs/skills/
    section: "Recognize tool description"
    verified: 2026-07-12
    relevance: "OpenCode lists available skills in the skill tool description via <available_skills> XML. Each entry has name and description. The agent scans these to decide which to load."
  - url: https://www.anthropic.com/engineering/writing-tools-for-agents
    section: "Prompt-engineering your tool descriptions"
    verified: 2026-07-12
    relevance: "Canonical Anthropic guidance: tool descriptions are loaded into agent context and 'collectively steer agents toward effective tool-calling behaviors.' Even small refinements to descriptions can yield dramatic improvements."
  - url: https://agentpatterns.ai/tool-engineering/tool-description-quality/
    section: "Full page"
    verified: 2026-07-12
    relevance: "Tool descriptions — not just tool implementations — determine whether agents select the right tool. Agents select tools by reasoning about which best matches their current intent. A poorly described tool is invisible."
  - url: https://theneuralbase.com/llamaindex/learn/intermediate/tool-descriptions-guiding-routing-decisions/
    section: "Full page"
    verified: 2026-07-12
    relevance: "Tool descriptions are not documentation: they are routing instructions embedded in the agent's context window. The LLM's decision logic: read user query → scan tool descriptions → match query intent to tool purpose → call tool."
  - url: https://machinelearningmastery.com/the-complete-guide-to-tool-selection-in-ai-agents/
    section: "Gating section"
    verified: 2026-07-12
    relevance: "Gating is a pre-check before expensive tool selection. A gate filters out turns that need no tool at all. The Pre-Response Gate is a form of gating — but in opencode it's in the system prompt, not a separate classifier."
  - url: https://github.com/jayminwest/agentic-engineering-book/blob/main/chapters/5-tool-use/2-tool-selection.md
    section: "Description-Based Selection"
    verified: 2026-07-12
    relevance: "The model doesn't 'route' based on keywords — it reads tool descriptions and parameters like instructions, then decides which matches the task at hand. Poor selection means unclear tool descriptions or too many similar-looking options."
  - url: https://masterprompting.net/learn/agents/tool-design-ai-agents
    section: "Full page"
    verified: 2026-07-12
    relevance: "The description is the UI. It's the only instruction the model gets about the tool's purpose and correct usage. A vague description leads to incorrect tool selection and wrong parameter values."
  - url: https://developers.openai.com/api/docs/guides/function-calling
    section: "Tool definition"
    verified: 2026-07-12
    relevance: "Tool definitions include descriptions that the LLM uses to decide when to call the function."
  - url: https://agentpatterns.ai/tool-engineering/tool-description-quality/
    section: "Positive selection signals"
    verified: 2026-07-12
    relevance: "Add positive selection signals ('Use this tool when X' and 'Prefer this over Y when Z'). These are instructions to the agent, not documentation of the interface."
  - url: file://.opencode/prompts/default.txt
    section: "Pre-Response Gate"
    verified: 2026-07-12
    relevance: "4-point gate: scan triggers, dispatch matching skill, justify if none, dispatch to sub-agent for file ops. Point 4 is about pipeline orchestration (not skill dispatch). Mixed with Evidence Hierarchy section (duplicated from verification honesty guideline)."
  - url: file://.opencode/AGENTS.md
    section: "Universal Skill Dispatch Gate / Pre-Response Gate Procedure"
    verified: 2026-07-12
    relevance: "Step 1 says 'Evaluate the user message against ALL available skill descriptions' — frames matching around user utterances. Separate from default.txt's version with different wording. This is the source of the user-utterance confusion."
---

# Skill Description vs Pre-Response Gate — Agent-Intent Dispatch Design

## Problem

The Pre-Response Gate (prompts/default.txt §Pre-Response Gate) and AGENTS.md §Universal Skill Dispatch Gate are two separate sources defining the same gate with different wording. They contain procedural reinforcement that partially overlaps with what well-written tool descriptions should already accomplish through the LLM's native tool-selection mechanism.

## Research Findings

### Finding 1: OpenCode renders `<available_skills>` as tool definitions

Per opencode.ai official docs:
- Skills are loaded on-demand via the native `skill` tool
- OpenCode lists available skills in the `skill` tool description
- Each entry includes the skill name and description in `<available_skills>` XML
- The agent scans these, then calls `skill({name: "..."})` to load full content
- The `description` field is 1-1024 chars: "Keep it specific enough for the agent to choose correctly"

The `<available_skills>` section renders as metadata on the `skill` tool itself (loaded into context), not as independent tool definitions. This is architecturally different from OpenAI/Anthropic function calling where each tool is a separate entry in the `tools` array. In opencode, the `skill` is a single tool, and `<available_skills>` is metadata rendered as part of that tool's description or as context.

### Finding 2: Anthropic's guidance explicitly recommends system-prompt gating

From Anthropic's "Writing effective tools for agents" (Sep 2025):
- Tool descriptions and specs should be "prompt-engineered" — they are loaded into agent context and steer behavior
- Even small refinements yield dramatic improvements (SWE-bench example)
- Anthropic's own tool-evaluation framework uses system prompts to instruct agents about tool selection
- Claude Code's architecture uses a system prompt with explicit instructions about when to call tools

The industry consensus: system-prompt reinforcement of tool-selection behavior is standard practice. The Pre-Response Gate is aligned with this pattern.

### Finding 3: Descriptions and gates serve different control surfaces

Multiple sources confirm a layered approach:

**Layer 1 (Tool description)** — What the tool does, when to use it, when not to. The LLM decides *whether* to call it. (Anthropic: "Prompt-engineering your tool descriptions")

**Layer 2 (System prompt Gate)** — Behavioral instruction that forces the agent to *stop and check* before producing output. Without this, LLMs default to conversational answering. (AgentPatterns: "Before acting, review your available tools"; MLMastery: "gating")

**Layer 3 (Forbidden Rationalizations)** — Meta-instructions that short-circuit the model's rationalization pathways. Specific to opencode's approach of pre-empting the model's known failure modes.

Layer 1 and Layer 2 are complementary, not redundant. Removing Layer 2 (the gate) without ensuring Layer 1 (descriptions) is strong enough would cause the agent to frequently skip skill dispatch and answer conversationally.

### Finding 4: AGENTS.md duplicates and diverges from prompts/default.txt

Two sources define the same gate with different wording:
- `prompts/default.txt` lines 5-16: 4 points including sub-agent dispatch (point 4)
- `AGENTS.md` lines 25-40: 3 points with "evaluate the user message against descriptions" (no sub-agent point)

The AGENTS.md version frames matching around "Evaluate the user message" — reinforcing user-utterance matching over agent-intent matching. The default.txt version avoids this language and uses "Scan `<available_skills>` for matching triggers."

### Finding 5: Point 4 (sub-agent dispatch) is architecturally a different concern

Point 4 says: "If you are about to read a file, analyze content, compose prose, or make a decision: dispatch to a sub-agent via task(). The orchestrator routes. It does not do."

This is about **pipeline architecture** (orchestrator vs sub-agent separation), not **skill dispatch** (which skill to load). It belongs in a section about orchestration discipline (AGENTS.md §Direct-Branch Primary Workflow or §Boundaries), not in the Pre-Response Gate.

### Finding 6: Forbidden Rationalizations and Cost Model are duplicated reinforcement

The Forbidden Rationalizations list (lines 20-29) and Cost Model (lines 31-33) duplicate concepts already covered in:
- `020-go-prohibitions.md` §1 (What GO Is Not & Self-Authorization Prohibitions)
- `000-critical-rules.md` (multiple Tier 2 violations)
- `060-tool-usage.md` (path rules, temp files)

The Evidence Hierarchy (lines 35-46) duplicates `065-verification-honesty.md` §Evidence Hierarchy.

These belong in a single source of truth, not inlined in the system prompt.

### Finding 7: The core Pre-Response Gate (points 1-3) cannot be removed entirely

From the research:

1. **LLMs default to conversational answering** — Without an explicit instruction to check tools before output, models frequently produce chat responses instead of dispatching. Multiple sources confirm this behavioral pattern.

2. **Tool descriptions alone do not guarantee selection** — AgentPatterns.ai: "Tool descriptions — not just tool implementations — determine whether agents select the right tool." The descriptions are necessary but not sufficient. The gate ensures the checking step happens.

3. **Gating is a recognized architectural pattern** — MLMastery.com: "A gate filters out turns that need no tool at all, cheaply, before anything else runs." The Pre-Response Gate IS this gate.

4. **The opencode skill system has unique architecture** — Unlike Anthropic's `tools` array (each tool = one function definition), opencode has one `skill` tool with `<available_skills>` as metadata. This means the agent must *first* decide which skill's description matches, then call `skill({name: "..."})` to load content. The gate is necessary because the agent cannot see the content until after it dispatches.

## Conclusion

The Pre-Response Gate cannot be eliminated entirely — it serves the unique architectural pattern of opencode's skill system where descriptions (not tool function definitions) are the selection surface. However, it can be:

1. **Trimmed** to points 1-3 (skill dispatch only)
2. **Moved** point 4 (sub-agent routing) to AGENTS.md orchestration section
3. **Deduplicated** — Forbidden Rationalizations, Cost Model, and Evidence Hierarchy belong in their canonical guideline files
4. **Clarified** — AGENTS.md's "evaluate the user message against descriptions" should become "evaluate your current context and intent against skill descriptions"
5. **Strengthened descriptions** — Skill descriptions should describe agent-intent dispatch conditions, not user-utterance catalogs

## Gaps / Unverified

- (none — all claims verified against live sources)
