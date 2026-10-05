<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
---
trigger_on: pre-flight guard, task-tool probe, sub-agent identity, orchestrator detection, ORCHESTRATOR_ONLY_SKILL_CARD, ORCHESTRATOR_ONLY_PLAN, routing metadata guard
tier: 2
load_when: sub-agent
---

# 023-pre-flight-guard.md — Mechanical Pre-Flight Guard (Canonical Reference Definition)

## Overview

The mechanical Pre-Flight Guard is the single canonical signal an agent uses to determine its dispatch role — orchestrator or sub-agent — before consuming orchestrator-level routing metadata (SKILL.md Pre-Flight Guard sections, Trigger Dispatch Tables, plan files). The signal is mechanical: the presence or absence of a tool named `task` in the agent's own tool list. Empirical probes (2026-09-02, spec `.opencode#2430`) established that a sub-agent context carries the `skill` tool yet no `task` tool — 96 tools, zero `task` — so tool-list inspection is the only observable discriminator, and prose-only self-identification ("if you are a sub-agent...") provides none. The `skill` tool's presence is therefore not an orchestrator signal; `task`-tool absence is the sole discriminator.

This document is the single reference definition for the guard (R-2, `.opencode#2430`). Every guard-embedding surface — skill cards, `writing-plans` plan files, deck lint (`skildeck-lint` / `validate_skill_cards.py`), and the plan-fidelity audit path — copies the canonical block below verbatim and defers semantics to this definition. Divergent inline guard variants are defects: lint flags them as deviant, and an agent that encounters one applies the canonical semantics from this document.

## Canonical Guard Block (Reference Definition)

Every guarded artifact embeds this block verbatim:

```markdown
## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.
```

## Semantic Note — The Guard Governs ACTION, Not Perception

Content is already in the agent's context when the guard runs; a "do not read" directive is unenforceable after delivery. The guard therefore governs ACTION ("do NOT execute"), not perception ("do not read"). Reading happened — execution is what the guard stops.

## Reason Codes

The reason code identifies the artifact class whose routing metadata was handed to a sub-agent, giving lint, audit, and behavioral tests a precise assertion target per class:

| Code | Artifact Class | Expected Sub-Agent Behavior |
|------|---------------|-----------------------------|
| `ORCHESTRATOR_ONLY_SKILL_CARD` | SKILL.md skill cards (top-level and nested platform cards) | Return `BLOCKED` with this code; execute no instruction below the guard; make no dispatch attempt |
| `ORCHESTRATOR_ONLY_PLAN` | Plan files produced by `writing-plans` | Return `BLOCKED` with this code; execute no phase; make no dispatch attempt |

## Pipeline Position

Dependency order: the guard runs FIRST — before any Trigger Dispatch Table evaluation, before any plan-phase execution, and before any dispatch attempt. An orchestrator (a tool named `task` is present in its tool list) proceeds normally and the guard produces no output on the orchestrator path — the no-false-halt behavioral scenario (SC-5, `.opencode#2430`) is the recovery gate for any guard variant that over-fires. Routing metadata consumed below an unfired guard by an agent lacking the `task` tool bypasses the gate every downstream quality check assumes.

## Related

- Read [Orchestrator Context Discipline](022-orchestrator-context-discipline.md) — why cards and plans are orchestrator-only documents and why a sub-agent cannot execute routing metadata (no `task()` capability).
- Spec `.opencode#2430` — Mechanical Pre-Flight Guard (task-tool probe) for skill cards and plan files.

---

*Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)*