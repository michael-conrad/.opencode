---
name: verification-enforcement
description: Use when generating content that makes factual claims — specs, plans, runbooks, docs, or correspondence — to enforce live-source verification before generation. Triggers on: verify before generation, content generation, evidence collection, unverified claims, verification gate, prose structure check. Content generation without verification produces unsubstantiated claims. Every unverified claim in generated content is a trust deficit.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Verification Enforcement

## Overview

Shared verification gate for ALL content-generating skills. Pre-generation: task section-based sub-agents to collect evidence artifacts for every claim. Post-generation: scan for unverified markers, attempt resolution, escalate unresolvable claims. Orchestrator level: reject sub-agent output without evidence artifacts.

Spec content that makes factual claims must include a **Documentation Sources** section documenting live-source verification used for each claim. This section is mandatory for standard and complex specs and is enforced by `adversarial-audit --task spec-audit` criterion SC-11. Simple specs may omit it.

## Persona

Verification Gatekeeper. Not the content author — the evidence collector running before and after generation. Treats memory/training data as insufficient; tool calls and live documentation as sufficient. Marks what cannot be verified, escalates what cannot be resolved.

## Tasks

| Task | Words |
|------|-------|
| `verify` | ≈300 |
| `revisit` | ≈250 |
| `enforce` | ≈200 |
| `completion` | ≈150 |

## Invocation

`skill({name: "verification-enforcement"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `verify` | `task(..., prompt: "execute verify task from verification-enforcement")` |
| `revisit` | `task(..., prompt: "execute revisit task from verification-enforcement")` |
| `enforce` | `task(..., prompt: "execute enforce task from verification-enforcement")` |
| `completion` | `task(..., prompt: "execute completion task from verification-enforcement")` |

**CLI equivalent (for human TUI use):** `/skill verification-enforcement --task <task>`

## Operating Protocol

1. **Pre-generation:** collect section evidence table, task per-section verification sub-agents.
2. **Post-generation:** scan for ⚠️ UNVERIFIED markers, attempt resolution, escalate remaining.
3. **Orchestrator enforcement:** reject sub-agent output lacking evidence artifacts; re-task.
4. **Audience separation:** classify content audience (stakeholder/operator); filter internal artifacts from stakeholder tier.
5. **All factual claims require live-source verification.**

## Sub-Agent Routing

`verify` runs with `{ section_evidence_table, claim_list, worktree.path, github.owner, github.repo }`. `revisit` receives `{ generated_content, ⚠️ UNVERIFIED markers, worktree.path, github.owner, github.repo }`. `enforce` receives `{ sub_agent_output, evidence_artifact_list, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory, prior verification. When routing auditor sub-agents, include `audit_phase` in task context per SC-6. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

## Cross-References

Guidelines: `065-verification-honesty.md`, `000-critical-rules.md`. Skills: `spec-creation`, `writing-plans`, `sre-runbook`, `skill-creator`, `correspondence`, `adversarial-audit --task guideline-audit`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: verification-enforcement-001
    title: "Content generation requires verification gate"
    conditions:
      all: ["content_generation_requested == true", "verification_invoked == false"]
    actions: [HALT]
    source: "verification-enforcement/SKILL.md"

  - id: verification-enforcement-004
    title: "Sub-agent output without evidence artifacts is rejected"
    conditions:
      all: ["sub_agent_returned == true", "evidence_artifacts_present == false"]
    actions: [REJECT, RE_TASK]
    source: "verification-enforcement/SKILL.md"
