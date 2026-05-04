---
name: pr-creation-workflow
description: Use when asking about when to create a PR or whether PR creation is authorized. Triggers on: create PR, make PR, pull request, PR timing, when to PR, PR authorized. Feature branch PRs targeting dev only. Release PRs handled by git-workflow --task release-promotion.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# PR Creation Workflow

## Overview

PR creation is a DISTINCT phase requiring EXPLICIT instruction — NOT automatic after implementation. "Approved"/"go" authorize implementation only, not PR creation (unless `authorization_scope >= for_pr`).

Feature PRs target `dev` only. Release PRs (dev→main) handled by `git-workflow --task release-promotion`.

## Tasks

| Task | Words |
|------|-------|
| `pre-pr-checklist` | ≈500 |
| `sub-issue-collection` | ≈300 |
| `completion` | ≈200 |

## Invocation

`/skill pr-creation-workflow --task pre-pr-checklist` (mandatory checks), `--task sub-issue-collection` (sub-issue autoclose), `--task completion` (halt guarantee). Overview with no flag.

## Operating Protocol

1. **Explicit instruction required** unless `authorization_scope >= for_pr`.
2. **Base branch = dev** for feature PRs.
3. **Squash verified** before PR (single commit for single-issue).
4. **Changelog generated** before PR.
5. **No agent merge** — human-only operation.
6. **Work branch guard:** no individual PRs during work execution (single stacked PR).
7. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ branch_name, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description }`. No inline work.

## Cross-References

Skills: `git-workflow`, `changelog-generator`. Guidelines: `000-critical-rules.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: pr-workflow-001
    title: "PR requires explicit instruction — approved does NOT authorize PR"
    conditions:
      all: ["pr_creation_attempted == true", "authorization_scope < for_pr"]
    actions: [HALT]
    source: "pr-creation-workflow/SKILL.md"

  - id: pr-workflow-002
    title: "Base branch must be dev for feature PRs"
    conditions:
      all: ["pr_type == 'feature'", "base_branch != 'dev'"]
    actions: [HALT]
    source: "pr-creation-workflow/SKILL.md"
