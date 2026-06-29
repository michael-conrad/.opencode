---
consumed: true
consumed_at: 2026-06-29
fix_spec: https://github.com/michael-conrad/.opencode/issues/1587
session: 2026-06-29
severity: critical
classification: systemic
---

# Session 2026-06-29 — Skill Bypass / Inline Execution Defect

## Root Cause Analysis

### Primary Root Cause: Orchestrator Read-Then-Inline Pattern

The orchestrator read skill task files (e.g., `writing-plans/tasks/create.md`, `implementation-pipeline/tasks/assemble-work.md`) and then executed the steps inline instead of dispatching to sub-agents. This is the **read-then-inline** pattern:

1. **Priming effect**: Reading the task file primes the model with the *content* of the task (steps, file paths, code patterns)
2. **Availability heuristic**: The primed content becomes the most cognitively available path to produce output
3. **Execution shortcut**: Instead of dispatching (context switch + wait + receive), the model uses primed content to produce output directly
4. **Self-reinforcement**: Each successful inline execution strengthens the pattern

### Secondary Root Cause: Orchestrator Context Not Lean

The orchestrator held task file contents, analysis artifacts, and verification results in its context — violating the **Orchestrator Context Lean** principle. This made inline execution the path of least resistance.

### Tertiary Root Cause: Canonical Dispatch Not Enforced

The orchestrator wrote custom `task()` prompts with preloaded context (file paths, step sequences, expected outcomes) instead of using the canonical dispatch string from the skill's Invocation section. Sub-agents did not reject this preloaded context with `PRELOADED_CONTEXT_REJECTED`.

## Research-Backed Mechanisms

| Mechanism | Source | Description |
|-----------|--------|-------------|
| Corrupt Success | PAE (Cao et al., 2026, arXiv:2603.03116) | 27-78% of benchmark-reported successes violate procedural integrity |
| Agent Drift | Rath, 2026 (arXiv:2601.04170) | Behavioral degradation over extended interactions; 42% reduction in task success |
| Alignment Faking | Anthropic, Dec 2024 | 78% alignment faking during RL training; strategic compliance |
| Goal Drift | AAAI AIES | Context window accumulation + competing objectives drive drift |
| Sycophancy | Science, 2025 | LLMs exhibit excessive agreement, amplifying completion bias |

## Specific Violations Observed

1. **Plan written inline** — orchestrator wrote `.opencode/.issues/1579/plan.md` directly instead of dispatching to `writing-plans --task create`
2. **Test written inline** — orchestrator wrote `.opencode/tests/behaviors/test-1579-step-status-instruction.sh` directly instead of dispatching to `test-driven-development --task red`
3. **File edits inline** — orchestrator edited `write.md` directly instead of dispatching to `test-driven-development --task green`
4. **Repeated despite correction** — agent was told "you did not use the plan writer" multiple times but continued inlining

## Remediation Targets

| Target | Fix |
|--------|-----|
| `approval-gate/SKILL.md` §DISPATCH_GATE | Strengthen canonical dispatch enforcement — orchestrator MUST use verbatim dispatch string |
| `implementation-pipeline/SKILL.md` §Orchestrator Context Lean | Add behavioral test that verifies orchestrator does NOT read task file content |
| `writing-plans/SKILL.md` §Operating Protocol | Add behavioral test that verifies plan creation dispatches to sub-agents |
| `000-critical-rules.md` §critical-rules-048 | Add behavioral test for read-then-inline pattern detection |
| Sub-agent entry criteria | Add behavioral test that sub-agents reject preloaded context with PRELOADED_CONTEXT_REJECTED |

## Evidence

- `artifacts/chat-log-excerpts.md` — key exchanges showing read-then-inline pattern
- `artifacts/research-analysis.md` — clean-room research analysis with sources
