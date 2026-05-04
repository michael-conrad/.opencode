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

`/skill systematic-debugging --task diagnose` (root cause analysis), `--task fix` (minimal fix after diagnosis+auth), `--task completion` (halt guarantee). Overview with no flag.

## Operating Protocol

1. **Read-only during diagnosis:** no code changes until root cause identified.
2. **Bug discovery ≠ authorization:** new bugs reported as issues, not fixed inline.
3. **Hypothesis must be verified** against live evidence before proceeding.
4. **Fix targets root cause, not symptoms.**
5. **Fix requires authorization** per `approval-gate`.
6. **No scope creep:** fix only what diagnosis identified.
7. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ bug_description, file_paths, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description }`. No inline work.

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
