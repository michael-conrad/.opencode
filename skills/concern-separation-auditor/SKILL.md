---
name: concern-separation-auditor
description: Use when auditing a spec for phase structure quality or concern separation. Triggers on: concern separation, phase structure, spec audit, mixed concerns.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: concern-separation-auditor

## Overview

Analyzes spec phase structures for deployment independence, risk profile, and blast radius. Report-only — no auto-fixes. Now invoked via spec-auditor as `concerns` subtask.

## Tasks

| Task | Words |
|------|-------|
| `audit-phases` | ≈400 |
| `check-independence` | ≈300 |
| `concern-coverage` | ≈350 |

## Invocation

NOT invoked directly. Called by spec-auditor via `/skill spec-auditor --issue N --task concerns`. Deprecated direct invocation: `/skill concern-separation-auditor --issue N`.

## Operating Protocol

1. **Report-only:** findings presented to agent, no auto-fixes.
2. **Deployment independence:** each phase must be independently deployable.
3. **Risk profiling:** blast radius and failure isolation per phase.
4. **Single Concern Principle** per `000-critical-rules.md` — phases address one concern each.
5. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ issue_number, github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

## Cross-References

Skills: `spec-auditor`. Guidelines: `000-critical-rules.md` (SCP).

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: cs-auditor-001
    title: "Report-only — findings presented to agent, no auto-fix"
    conditions:
      all: ["auto_fix_attempted == true"]
    actions: [REVERT, REPORT_ONLY]
    source: "concern-separation-auditor/SKILL.md"
