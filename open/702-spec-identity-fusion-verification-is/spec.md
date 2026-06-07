---
number: 702
title: "[SPEC] Identity Fusion: Verification IS Completion (Goal Hijacking Weave)"
status: "open"
labels: [spec]
created: "2026-05-20T19:25:25.417547Z"
updated: "2026-05-20T19:29:33.897793Z"
github_issue: 626
author: "Michael Conrad"
github_url: "https://github.com/michael-conrad/.opencode/issues/626"
promoted_at: "2026-05-20T19:19:55Z"
remote_issue: "626"
remote_url: "https://github.com/michael-conrad/.opencode/issues/626"
---

# [SPEC] Identity Fusion: Verification IS Completion (Goal Hijacking Weave)

## Prerequisites

- **#625** — Skill body confirmshaming (Persona sections must be deployed before Change 7 applies)
- **#622** — Routing confirmshaming (co-deliverable — establishes identity-frame pattern)
- **#624** — Tier recalibration (co-deliverable — ensures Tier 1/2/3 labels are correct)

## Problem

The agent system has a structural vulnerability: it treats "implementation" and "verification" as separate pipeline stages. This separation creates a natural shortcut — the agent can declare "implementation complete" and stop, treating verification as a downstream step that can be deferred, skipped, or assumed.

This is not a prose problem. It is a **conceptual model problem**. The pipeline is built on a false premise: that there exists a valid state called "implemented but unverified." Once that state exists in the agent's mental model, it becomes a destination. Every time the agent reaches "implemented" it can rationally stop, because the model says that verification is a *subsequent* step, not a *constituent* part of completion.

## Solution

Redefine the conceptual model so that **verification IS completion**.

### Changes (summary)

1. verification-before-completion Overview — fusion prose
2. finishing-a-development-branch Overview — fusion prose
3. completion-core — Entry Gate requiring verification-before-completion PASS
4. approval-gate — rename `implementation_complete` to `verification_complete` across skills/guidelines
5. divide-and-conquer — rule 9: no acceptance without verification evidence
6. AGENTS.md — add "Verify before completing" to ALWAYS list
7. 3 Persona sections (#625 dependent)
8. Result contract field consolidation (`implementation_complete` → `verification_passed`)

## Success Criteria

| SC-ID | Criterion | Verification |
|-------|-----------|-------------|
| SC-1 | verification-before-completion Overview leads with "Verification IS completion" | Read Overview |
| SC-2 | finishing-a-development-branch Overview leads with "Branch readiness IS verification completion" | Read Overview |
| SC-3 | completion-core has Entry Gate as FIRST section after intro paragraph | Read completion-core/SKILL.md |
| SC-4 | approval-gate halt_at uses `verification_complete` — no `implementation_complete` remaining in target files | grep returns empty |
| SC-5 | divide-and-conquer Sub-Agent Routing contains rule 9 requiring verification evidence | Read rule 9 |
| SC-6 | AGENTS.md ALWAYS list contains "Verify before completing" | Read ALWAYS list |
| SC-7a | verification-before-completion Persona contains identity-fusion language | Conditional on #625 Phase 1 |
| SC-7b | completion-core and finishing-a-development-branch Personas contain fusion language | Conditional on #625 Phase 2 |
| SC-8 | Behavioral: agent prompted to mark complete without verification declines | opencode-cli run test |
| SC-8b | Behavioral: agent at verification_complete halt_at runs verification before halting | opencode-cli run test |
| SC-8c | Behavioral: agent calling completion-core without verification PASS is blocked | opencode-cli run test |
| SC-9 | No `implementation_complete` remains across all target files | Targeted grep returns zero |

## Accountability Model Alignment (per #763)

This spec is a **blocking dependency** of #763. #763 Principle 4 (bad/incomplete implementation is on the agent) directly depends on this spec's "Verification IS Completion" identity fusion.

**Required addition — Identity Fusion Extension:** After this spec's "Verification IS Completion" fusion is implemented, #763 adds a second identity fusion layer: "Remediation IS agent-owned."

**Dependency chain:** This issue MUST merge before #763 Phase 1. #763 Phase 2 will add the "Remediation IS agent-owned" identity fusion layer.

## Change Control

| Version | Date | Change | Author |
|---------|------|--------|--------|
| 1.0 | 2026-05-16 | Initial spec | |

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)