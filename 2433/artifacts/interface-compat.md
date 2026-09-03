# Preliminary Interface Compatibility — Dispatch Discipline Remediation

## Interfaces under change

### 1. skill() → orchestrator contract (unchanged)
- `skill({name: "..."})` loads SKILL.md into orchestrator context — no change proposed
- Orchestrator Entry Criteria, TDT, Invocation sections remain the routing surface

### 2. task() → sub-agent contract (REDEFINED, breaking for orchestrators)
Current: orchestrator may forward any content, including whole cards/plans
Target: `task()` accepts ONLY task-card dispatch strings:
  - Canonical form: `execute <task> from <skill>. Read <skill>/tasks/<task>.md first`
  - Context object per DISPATCH_GATE: `{worktree.path, github.owner, github.repo, authorization_scope, halt_at, pipeline_phase}` + skill-specific fields
  - FORBIDDEN: card content, plan bodies, preloaded reasoning

### 3. Sub-agent result contract (unchanged)
`{status, finding_summary, artifact_path, blocker_reason}` — leaf nodes keep returning this

### 4. Plan file format (EXTENDED, breaking for new plans)
Add per-step dispatch mode to canonical plan schema:
- `direct` — orchestrator executes step in own context (default)
- `task()` — orchestrator dispatches step's task card to sub-agent
- Old plans (e.g., #1210's gate table) remain readable; new plans must carry explicit modes

### 5. Pre-flight guard semantics (EXTENDED)
- SKILL.md guard: unchanged (51/51 coverage verified)
- NEW: plan pre-flight guard — a sub-agent receiving a whole plan body MUST reject with
  `ORCHESTRATOR_ONLY_PLAN` (analogous to card guard). Plan steps routed to sub-agents
  travel as task cards or step-scoped prompts, never as the full plan document.

### 6. TDT vocabulary (NORMALIZED)
TDT `Dispatch` column values collapse to a closed set:
- `inline` → renamed to `orchestrator` (direct execution by orchestrator) — retire ambiguous term
- `sub-task` / `task()` → `task-card` (dispatch to sub-agent via task())
- `blind sub-task` → `task-card blind` (no context beyond the Context column)
Old values rejected by validator once migration completes.

## Compatibility assessment

| Consumer | Impact | Mitigation |
|----------|--------|-----------|
| Orchestrator agent | Prompt/guideline rewrites — no code API | New prompt text loaded at session start |
| Sub-agents (leaf) | Receive tighter prompts; guard unchanged for cards; NEW plan guard | Pre-flight guard addition to standards docs; behavioral tests |
| skildeck validators | New checks (TDT vocabulary, plan step modes) | Additive validator rules |
| session-enforcement.ts | Optional: detect whole-card/whole-plan forwarding in task() prompts | Additive, can be phase 2 |
| Existing open plans (#1210) | Third-vocabulary gate tables predate change | Coordinate/supersede in spec |
| Behavioral tests | Expectations updated to target model | Test updates accompany each GREEN |

No external (outside-repo) consumers depend on these interfaces — all changes are internal to the agent config deck.