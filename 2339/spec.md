---
title: "[SPEC] Skill card pre-flight guard for sub-agent dispatch"
status: draft
created: 2026-08-26
license: MIT
provenance: AI-generated
issue: 2339
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
remote_issue: 2339
remote_url: https://github.com/michael-conrad/.opencode/issues/2339
promoted_at: 2026-08-26T14:30:00Z
---

## Problem

Skill cards (SKILL.md) are orchestrator-routing metadata — they contain Trigger Dispatch Tables, DISPATCH_GATE protocols, and Invocation sections that only the orchestrator can execute. When a sub-agent receives a skill card, it cannot act on this routing metadata (sub-agents cannot call `task()`), so it must halt immediately rather than attempt to follow orchestrator-level instructions.

## Scope

- Add a pre-flight guard to all skill cards: when a sub-agent receives a skill card, it halts with `BLOCKED` + `ORCHESTRATOR_ONLY_SKILL_CARD`
- Update the skill card linting to enforce the guard's presence
- Update the skill card requirements documentation to mandate the guard

**Out of scope:** Task card structure, behavioral enforcement test authoring, and the canonical skill card template redesign (tracked separately in #2052).

## Approach

Implement a uniform guard across the skill deck. Each SKILL.md gains a pre-flight entry check that detects sub-agent context and returns `BLOCKED` with the `ORCHESTRATOR_ONLY_SKILL_CARD` reason before any routing metadata is consumed. The linting rules and the skill card requirements documentation are updated in lockstep so the guard is both enforced and specified.

## Impact

- **Risk:** Guard may be bypassed by sub-agents that ignore the halt — mitigated by linting enforcement and documentation mandate.
- **Risk:** False positives if the guard fires in legitimate orchestrator context — mitigated by context detection that distinguishes orchestrator from sub-agent.
- **Risk:** Inconsistent guard wording across 37+ skill cards — mitigated by a single canonical guard definition in the requirements doc.
- **Dependencies:** None blocking; complements #2052 (template) and #1992 (task() prohibition).
- **Call to action:** Approve this spec to begin implementation.

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created
