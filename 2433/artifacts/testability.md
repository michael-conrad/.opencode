# Preliminary Testability Assessment — Dispatch Discipline Remediation

## Existing coverage of affected paths

### 1. Behavioral enforcement tests (tests-v2/behaviors/)
- Suite exercises agent dispatch behavior via `opencode run` with real models
- Scenarios assert skill-dispatch discipline (e.g., tier1-mandate-enforcement.sh)
- **Gap:** no verified scenario asserts "orchestrator does NOT forward whole SKILL.md / whole plan to a sub-agent"
- **Gap:** no scenario asserts "orchestrator executes plan steps directly, dispatching task() only where required"

### 2. Structural tests
- `skildeck-lint` / `validate_skill_cards.py` verify card structure (guards, frontmatter)
- **Gap:** unknown whether any check rejects SKILL.md-path references in task() dispatch strings (whole-card forwarding invitations)
- **Gap:** no TDT vocabulary validator (closed-set Dispatch column values)

### 3. Unit tests (.opencode/tests/)
- Cover session-init, skill-creator tooling — not dispatch semantics

## Required new test surface for this spec

### Structural (cheap, per-commit)
1. Grep-gate: no `task(subagent_type=...)` string in any SKILL.md references a SKILL.md path as its target
2. TDT Dispatch column values ∈ closed set {orchestrator, task-card, task-card blind}
3. Every SKILL.md retains pre-flight guard (existing check, keep)
4. Plan format validator: every plan step carries explicit dispatch mode

### Behavioral (real model, opencode run)
1. RED: prompt orchestrator with a skill trigger → assert stderr shows orchestrator
   executing workflow steps directly (e.g., reading files itself) rather than
   dispatching the whole card; assert no SKILL.md content appears in task() prompt
2. RED: prompt orchestrator with an approved plan → assert plan steps executed by
   orchestrator (tool calls visible in its own session), task() only at step-marked points
3. GREEN: after remediation, same probes pass with correct dispatch pattern
4. Negative: leaf sub-agent receiving a whole plan rejects with ORCHESTRATOR_ONLY_PLAN

## Testability risks

- Behavioral tests depend on local model availability (qwen3.8:27b-256k-gguf4 verified working; timeout discipline documented in tests-v2/AGENTS.md)
- Grep-based assertions on prompts can only verify directive text, not runtime behavior — behavioral evidence required per critical-rules-BEH-EV (this change IS runtime-behavioral: agent dispatch decisions are runtime behavior)
- Each SC needs behavioral evidence; plan must budget opencode run cycles per SC

## Verdict
Testable with existing harness + additions. Evidence type for all SCs: **behavioral** (substrate-determined — dispatch decisions are runtime agent behavior).