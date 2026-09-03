# Preliminary Blast Radius — Orchestrator Dispatch Discipline Remediation

**Scope root:** `.opencode/` (submodule repo: michael-conrad/.opencode)

## Quantified Surface

| Layer | Files | Verified evidence |
|-------|-------|-------------------|
| SKILL.md cards | 51 | All 51 carry `ORCHESTRATOR_ONLY_SKILL_CARD` pre-flight guard; 284 `task(subagent_type=...)` dispatch strings; 49/51 TDTs route tasks to sub-agents |
| Task cards | 299 | Execution procedures for sub-agents; several contain Task Discipline forbidding internal `task()` (leaf-node assumption intentional and correct for most) |
| Guidelines | 35 | `022-orchestrator-context-discipline.md` (298 lines) is the architecture-defining doc; `000-critical-rules.md` carries the whole-card dispatch prohibition |
| Reference cards | 3 | task-card-structure-standards, skill-card-description-standards, skill-card-schema |
| System prompt | 1 | `.opencode/prompts/default.txt` (15,370 bytes) — loaded via opencode.jsonc `agent.build`/`agent.plan` |
| Plans (in-flight) | open issues 1208, 1210 | 1210 plan uses "orchestrator routes to general (blind)" gate table — a third dispatch vocabulary |

## Directly Affected Files (must change)

1. `.opencode/prompts/default.txt` — Sub-Agent Routing Boundary ("The orchestrator routes. It does not do."), "hand off to executing-plans via sub-agent", Pre-Response Gate forwarding language
2. `.opencode/guidelines/022-orchestrator-context-discipline.md` — "pure router", "inline work detected → HALT", allocation-by-context-cost framing
3. `.opencode/guidelines/000-critical-rules.md` — critical-rules-XXX (whole-card prohibition correct, keep); Infrastructure-Failure Carve-out; routing-bypass classifications
4. `.opencode/skills/executing-plans/SKILL.md` + `tasks/read-plan.md`, `tasks/dispatch-phase.md` — plan execution architecture (orchestrator reads plan + executes steps directly)
5. `.opencode/skills/writing-plans/SKILL.md` — 25+ task() strings; plan format must define orchestrator-executable steps
6. `.opencode/skills/audit/SKILL.md`, `spec-creation/SKILL.md`, `brainstorming/SKILL.md` — TDT/Invocation internal contradictions (TDT says `inline`, Invocation routes same tasks to `task()`)
7. All 51 SKILL.md — Invocation/Dispatch sections need normalization to one vocabulary
8. `.opencode/reference/task-card-structure-standards.md`, `skill-card-description-standards.md` — canonical definitions
9. `.opencode/AGENTS.md` — Development cycle section (quoted sentence "The orchestrator does NOT execute the task steps inline" actually lives at `prompts/default.txt:198`, not AGENTS.md; AGENTS.md carries the "Amateurs inline." header prose)
10. `.opencode/hooks/*` + `session-enforcement.ts` — enforcement surface if mechanical gates reference the old model

## Indirectly Affected

- `.opencode/tests-v2/behaviors/*` — behavioral tests asserting dispatch behavior
- Open spec #1208 / plan #1210 — overlapping scope (TDT format work); must coordinate
- `skildeck` validators — enforce card structure rules

## Out of Scope

- `.opencode/node_modules/`, `.venv/`, `.node/`, `tmp/`, `.issues/` data, `tests/`, `scripts/` Python tooling (no dispatch directives)