# Preliminary Concern Map — Orchestrator Dispatch Discipline Remediation

## Concern 1: Directive Layer (what the agent is told to do)

Files that instruct orchestrator behavior:
- `prompts/default.txt` — system prompt loaded into every session
- `guidelines/000-critical-rules.md` (Tier 1), `022-orchestrator-context-discipline.md`, `060-tool-usage.md`
- `AGENTS.md` sections (Development cycle, Universal Skill Dispatch Gate)
- `reference/task-card-structure-standards.md`, `skill-card-description-standards.md`

**Conflict found:** Two architectures coexist:
- **Architecture A (current text):** orchestrator = pure router; never executes task steps inline; HALT on inline work
- **Architecture B (target):** orchestrator loads skill card, executes workflow directly; dispatches task cards via task() only where the workflow marks it; same for plan steps

`prompts/default.txt` contains BOTH: "The orchestrator routes. It does not do." (A) AND "The orchestrator MUST read the SKILL.md's Trigger Dispatch Table... then dispatch the task card" (B). The 022 guideline is written entirely in A. The 000-critical-rules whole-card prohibition is written in B.

## Concern 2: Deck Layer (the 51 skill cards + 299 task cards)

- 284 `task(subagent_type=...)` strings in SKILL.md files — these are CORRECT for task-card dispatch but must be unambiguous
- 3 cards (audit, brainstorming, spec-creation) have TDT rows marked `inline` while Invocation routes same tasks to `task()` — internal contradiction
- 46 cards mention `inline` somewhere; 49 route to sub-agents — vocabulary inconsistency
- 42 SKILL.md carry "Each step must be dispatched to a sub-agent via task() unless explicitly marked as inline/orchestrator" — blanket clause readable as "dispatch everything"
- 3 skills (git-workflow, issue-operations, reference) have NO tasks/ dir — pure routing cards

## Concern 3: Plan Layer (how plans are executed)

- `executing-plans` SKILL.md routes read-plan and dispatch-phase to sub-agents — the orchestrator never touches the plan itself
- No directive anywhere states "orchestrator reads plan and executes steps directly, dispatching task() only where steps require it"
- Plan format (writing-plans create) doesn't define per-step dispatch mode explicitly enough to prevent wholesale forwarding
- Open plan #1210 uses a third vocabulary: "orchestrator routes to general (blind)" per gate

## Concern 4: Enforcement Layer (what catches violations)

- Pre-flight guard in all 51 cards (catches whole-card forwarding at sub-agent entry — defensive backstop, works)
- No pre-flight guard on plans — nothing rejects a whole plan arriving at a leaf sub-agent
- skildeck validators enforce card structure; unknown whether any check dispatch-string validity
- Behavioral tests in tests-v2 assert current dispatch behavior; may need updates

## Concern Boundaries

- Directive-layer changes are text rewrites in guidelines/prompts — no code
- Deck-layer changes are bulk edits across 51 files + reference standards
- Enforcement-layer changes touch skildeck (Python) and possibly session-enforcement.ts
- Plan-layer changes touch executing-plans skill + writing-plans templates
- Concerns 1-2 interact: guideline rewrites must match deck vocabulary exactly