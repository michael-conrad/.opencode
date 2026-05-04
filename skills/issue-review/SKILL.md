---
name: issue-review
description: Use when reviewing a GitHub issue for comments, audits, or Q/A. Triggers on: review issue, review spec, check issue, issue review, audit issue.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: issue-review

## Overview

Unified review orchestrator for GitHub Issues. Gathers issue data, classifies review path via content analysis, delegates to downstream skills, handles Q/A for non-spec issues.

## Persona

Issue Review Orchestrator. Focus: gather context, classify path, delegate to correct downstream skill.

## Tasks

| Task | Words |
|------|-------|
| `gather` | ≈500 |
| `triage` | ≈600 |
| `audit` | ≈350 |
| `qa` | ≈500 |
| `analyze-and-spec` | ≈600 |
| `completion` | ≈200 |

## Invocation

`/skill issue-review --task gather` (collect data), `--task triage` (classify), `--task analyze-and-spec` (root cause + fix spec), `--task audit` (delegate to spec-auditor), `--task qa` (clarifying questions), `--task completion` (halt guarantee). Overview with no flag.

## Operating Protocol

1. **Gather first:** read body, ALL comments, labels, sub-issues, auth status before classification.
2. **Triage path:** bug report → analyze-and-spec. Spec → audit. Non-bug, non-spec → qa.
3. **Bug discovery ≠ authorization:** findings reported as bug issues; no code edits during analysis.
4. **Fix spec must target root cause, not symptom** per `000-critical-rules.md`.
5. **Audit findings are internal** — posted to chat, not GitHub comments.
6. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

## Sub-Agent Dispatch Audit

All tasks dispatch via `task(subagent_type="general")` with `{ issue_number, github.owner, github.repo }`. Exclusions: implementation context, agent memory, cached verification. `pre-analysis` receives only `{ issue_number, task_description }`. No inline work.

## Cross-References

Skills: `spec-auditor`, `brainstorming`, `spec-creation`, `issue-operations`, `approval-gate`. Guidelines: `000-critical-rules.md`, `067-context-completeness.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: issue-review-001
    title: "Bug discovery does NOT authorize fixing"
    conditions:
      all: ["bug_discovered_during_analysis == true", "fix_authorization_received == false"]
    actions: [HALT, CREATE(bug_report), INVOKE(analyze-and-spec)]
    source: "issue-review/SKILL.md"

  - id: issue-review-002
    title: "Fix spec must target root cause, not symptom"
    conditions:
      all: ["fix_spec_created == true", "fix_approach_targets_root_cause == false"]
    actions: [REJECT, HALT]
    source: "issue-review/SKILL.md"
