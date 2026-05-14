---
name: systematic-debugging
description: Use when encountering a bug, error, or unexpected behavior, or before making code changes to fix an issue. Triggers on: bug, error, fix, debug, diagnose, crash, failure, unexpected behavior, vibe debugging.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: systematic-debugging

## Overview

Enforces root cause analysis, hypothesis testing, and minimal fixes. Prevents "vibe debugging" — random changes without understanding. Diagnose before fixing, fixes must be minimal and targeted.

## Tasks

| Task | Words |
|------|-------|
| `diagnose` | ≈400 |
| `fix` | ≈350 |
| `completion` | ≈200 |

## Invocation

`skill({name: "systematic-debugging"})` — call the skill, then dispatch a task:

| Task | Dispatch |
|------|----------|
| `diagnose` | `task(..., prompt: "execute diagnose task from systematic-debugging")` |
| `fix` | `task(..., prompt: "execute fix task from systematic-debugging")` |
| `completion` | `task(..., prompt: "execute completion task from systematic-debugging")` |

**CLI equivalent (for human TUI use):** `/skill systematic-debugging --task <task>`

## Operating Protocol

1. **Read-only during diagnosis:** no code changes until root cause identified.
2. **Bug discovery ≠ authorization:** new bugs reported as issues, not fixed inline.
3. **Hypothesis must be verified** against live evidence before proceeding.
4. **Fix targets root cause, not symptoms.**
5. **Fix requires authorization** per `approval-gate`.
6. **No scope creep:** fix only what diagnosis identified.

## Sub-Agent Dispatch Audit

Sub-agents dispatch via `task(subagent_type="general")` with `{ bug_description, file_paths, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. When dispatching auditor sub-agents, include `audit_phase` in dispatch context per SC-6. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

## Cross-References

Skills: `issue-review`, `approval-gate`, `verification-before-completion`. Guidelines: `000-critical-rules.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: sys-debug-001
    title: "Read-only analysis mandate during diagnosis"
    conditions:
      all: ["current_task == 'diagnose'", "code_modification_attempted == true"]
    actions: [HALT, REVERT]
    source: "systematic-debugging/SKILL.md"

  - id: sys-debug-002
    title: "Bug discovery does NOT authorize fixing"
    conditions:
      all: ["bug_found_during_diagnosis == true", "fix_authorization_received == false"]
    actions: [HALT, CREATE(bug_report), INVOKE(issue-review)]
    source: "systematic-debugging/SKILL.md"
