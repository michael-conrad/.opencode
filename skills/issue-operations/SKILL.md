---
name: issue-operations
description: Use when creating, commenting on, or closing GitHub Issues. Routes to GitHub MCP or GitBucket API based on github.platform. Triggers on: create issue, new issue, spec creation, submit issue, issue, bug report, comment, progress update, issue comment, PR comment, post to GitHub, byline, status indicator, sub-issue, phase issue, multi-task, create sub issue, link issue, task breakdown, subtask, parent issue, close issue, verify merge.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: issue-operations

## Overview

Platform-agnostic Issue Operations dispatcher. Detects `github.platform` and routes all issue operations to the appropriate platform sub-skill (github-mcp, gitbucket-api, local).

## Persona

Issue Operations Dispatcher. Focus: spec-first workflow, validation, labeling, platform-aware routing.

## Tasks

| Task | Words |
|------|-------|
| `pre-creation` | ≈240 |
| `single-task-check` | ≈160 |
| `creation` | ≈200 |
| `post-creation` | ≈180 |
| `comment` | ≈400 |
| `close` | ≈250 |
| `link-sub-issue` | ≈200 |
| `verify-merge` | ≈200 |
| `capabilities` | ≈150 |
| `completion` | ≈200 |

## Invocation

`/skill issue-operations --task pre-creation` (validate before create), `--task creation` (create with labels/byline), `--task comment` (post substantive comment), `--task close` (post-merge closure), `--task link-sub-issue` (sub-issue hierarchy), `--task verify-merge` (verify PR merge), `--task completion` (halt guarantee). Overview with no flag.

## Operating Protocol

1. **Platform routing:** `github.platform` → appropriate sub-skill (github-mcp / gitbucket-api / local).
2. **Substantive comment gate:** only meaningful updates posted as issue comments. No status spam.
3. **spec.md mirror:** every `github_issue_read(method="get")` mirrored to `.issues/<N>/spec.md`.
4. **Byline mandatory:** AI-authored comments must include `🤖 Co-authored with AI: <AgentName> (<ModelId>)`.
5. **Issue creation = no auth needed** per `010-approval-gate.md`.
6. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

## Sub-Agent Dispatch Audit

All tasks dispatch via `task(subagent_type="general")` with `{ issue_number, github.owner, github.repo, github.platform }`, excluding implementation context and agent memory. `pre-analysis` receives only `{ issue_number, task_description }`. No inline work.

## Cross-References

Skills: `github-mcp`, `gitbucket-api`, `local` (platform sub-skills). Guidelines: `010-approval-gate.md`, `000-critical-rules.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: issue-ops-001
    title: "Issue creation does not require authorization"
    conditions:
      all: ["issue_creation_pending == true", "agent_deliberating_auth == true"]
    actions: [PROCEED]
    source: "issue-operations/SKILL.md"

  - id: issue-ops-002
    title: "AI-authored comments require byline"
    conditions:
      all: ["ai_authored_comment == true", "byline_present == false"]
    actions: [APPEND_BYLINE]
    source: "issue-operations/SKILL.md"
