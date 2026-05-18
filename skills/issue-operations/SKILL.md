---
name: issue-operations
description: Use when creating, commenting on, or closing GitHub Issues. Routes to GitHub MCP or GitBucket API based on github.platform. Triggers on: create issue, new issue, spec creation, submit issue, issue, bug report, comment, progress update, issue comment, PR comment, post to GitHub, byline, status indicator, sub-issue, phase issue, multi-task, create sub issue, link issue, task breakdown, subtask, parent issue, close issue, verify merge. Bypassing issue tracking produces untracked work that gets lost. Tracked work is the only work that matters.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: issue-operations

## Overview

Platform-agnostic Issue Operations router. Detects `github.platform` and routes all issue operations to the appropriate platform sub-skill (github-mcp, gitbucket-api, local).

## Persona

Issue Operations Router. Focus: spec-first workflow, validation, labeling, platform-aware routing.

## Tasks

| Task | Words | Description |
|------|-------|-------------|
| `pre-creation` | ≈240 | |
| `single-task-check` | ≈160 | |
| `creation` | ≈200 | |
| `post-creation` | ≈180 | |
| `comment` | ≈400 | |
| `close` | ≈250 | |
| `link-sub-issue` | ≈200 | |
| `verify-merge` | ≈200 | |
| `capabilities` | ≈150 | |
| `completion` | ≈200 | |
| `body-edit` | ≈200 | Edit remote.md body via 4-agent dispatch (fetch → transform → verify → post) — body edits without structural verification propagate corruption upstream; every remote edit requires verified integrity before propagation |
| `read-issue` | ≈120 | Read single issue via dispatcher — routes to platform sub-skill, no direct `github_*` calls |
| `read-comments` | ≈130 | Read issue comments via dispatcher — context completeness, all comments before action |
| `read-labels` | ≈100 | Read issue labels via dispatcher — authorization scope verification |
| `read-sub-issues` | ≈120 | Read sub-issues via dispatcher — authorization cascade and closure order verification |
| `list-issues` | ≈130 | List issues with filters via dispatcher — dedup checks, label search, overlap detection |
| `search-issues` | ≈130 | Search issues via dispatcher — title dedup, spec/plan overlap detection |
| `update-issue` | ≈160 | Update issue body/labels/state via dispatcher — body-preservation safeguard enforced |

## Invocation

`skill({name: "issue-operations"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `pre-creation` | `task(..., prompt: "execute pre-creation task from issue-operations")` |
| `creation` | `task(..., prompt: "execute creation task from issue-operations")` |
| `comment` | `task(..., prompt: "execute comment task from issue-operations")` |
| `close` | `task(..., prompt: "execute close task from issue-operations")` |
| `link-sub-issue` | `task(..., prompt: "execute link-sub-issue task from issue-operations")` |
| `verify-merge` | `task(..., prompt: "execute verify-merge task from issue-operations")` |
| `completion` | `task(..., prompt: "execute completion task from issue-operations")` |
| `read-issue` | `task(..., prompt: "execute read-issue task from issue-operations")` |
| `read-comments` | `task(..., prompt: "execute read-comments task from issue-operations")` |
| `read-labels` | `task(..., prompt: "execute read-labels task from issue-operations")` |
| `read-sub-issues` | `task(..., prompt: "execute read-sub-issues task from issue-operations")` |
| `list-issues` | `task(..., prompt: "execute list-issues task from issue-operations")` |
| `search-issues` | `task(..., prompt: "execute search-issues task from issue-operations")` |
| `update-issue` | `task(..., prompt: "execute update-issue task from issue-operations")` |

**CLI equivalent (for human TUI use):** `/skill issue-operations --task <task>`

## Operating Protocol

1. **Platform routing:** `github.platform` → appropriate sub-skill (github-mcp / gitbucket-api / local).
2. **Substantive comment gate:** only meaningful updates posted as issue comments. No status spam.
3. **spec.md mirror:** every `issue-operations -> read-issue (github_issue_read(method="get")` mirrored to `.issues/<N>/spec.md`. <!-- Routes through issue-operations per SPEC #683 -->
4. **Byline mandatory:** AI-authored comments must include `🤖 Co-authored with AI: <AgentName> (<ModelId>)`.
5. **Issue creation = no auth needed** per `010-approval-gate.md`.
6. **Adversarial-audit call:** after sub-issue creation, call `adversarial-audit --task concern-separation --issue <N>` with `audit_phase: sub_issue_creation`.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ issue_number, worktree.path, github.owner, github.repo, github.platform }`, excluding implementation context and agent memory. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

## Cross-References

Skills: `github-mcp`, `gitbucket-api`, `local` (platform sub-skills), `adversarial-audit --task concern-separation`. Guidelines: `010-approval-gate.md`, `000-critical-rules.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-18T00:00:00Z"
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

  - id: issue-ops-003
    title: "Issue read operations MUST route through dispatcher"
    conditions:
      all: ["issue_read_pending == true", "direct_github_call == true", "call_location_outside_platforms == true"]
    actions: [HALT]
    source: "issue-operations/SKILL.md"
