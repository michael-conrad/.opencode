---
name: issue-operations-core
description: "Core issue CRUD operations that routes to GitHub MCP or `.opencode/tools/gitbucket-api` based on github.platform. Load via skill() when creating, reading, updating, closing, or listing issues. Also load when editing issue bodies, verifying merge status, checking single-task plans, pushing spec artifacts, or running pre/post-creation validation. Issue tracking is REQUIRED. User phrases: create issue, read issue, update issue, close issue, list issues, edit body"
license: MIT
provenance: AI-generated
---

# Skill: issue-operations-core

## Overview

Core CRUD operations for issue management. Routes all operations to the appropriate platform sub-skill (github-mcp, gitbucket-api, local). Handles creation, reading, updating, closing, listing, searching, body editing, merge verification, single-task checks, artifact pushing, and pre/post-creation validation.

## Pre-Flight Guard (Mandatory)

**This skill card is orchestrator-only routing metadata.**

If you are a sub-agent (dispatched via `task()`), you MUST NOT consume the routing metadata below. Sub-agents cannot call `task()` and cannot execute orchestrator-level dispatch instructions. Return `BLOCKED` with reason `ORCHESTRATOR_ONLY_SKILL_CARD` and halt.

If you are the orchestrator (loaded this card via `skill({name: "..."})`), proceed to the Workflows section.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "pre-creation" / "prepare issue" | `pre-creation` | `task-card` | {issue_context} |
| "single-task-check" / "check single task" | `single-task-check` | `task-card` | {issue_number} |
| "create issue" / "new issue" | `creation` | `task-card` | {issue_body} |
| "post-creation" / "after create" | `post-creation` | `task-card` | {issue_number} |
| "close issue" | `close` | `task-card` | {issue_number} |
| "verify merge" / "check merged" | `verify-merge` | `task-card` | {issue_number} |
| "capabilities" / "list capabilities" | `capabilities` | `task-card` | {platform} |
| "body-edit" / "edit body" | `body-edit` | `task-card` | {issue_number, new_body} |
| "read-issue" / "get issue" | `read-issue` | `task-card` | {issue_number} |
| "read-comments" / "get comments" | `read-comments` | `task-card` | {issue_number} |
| "read-labels" / "get labels" | `read-labels` | `task-card` | {issue_number} |
| "list-issues" / "list with filters" | `list-issues` | `task-card` | {filters} |
| "search-issues" / "search" | `search-issues` | `task-card` | {query} |
| "update-issue" / "edit issue" | `update-issue` | `task-card` | {issue_number, updates} |
| "push-artifacts" / "push spec artifacts" | `push-artifacts` | `task-card` | {issue_number} |
| completion / workflow end | `completion` | `task-card` | {workflow_state} |

## Persona

Issue Operations Core Router. Focus: spec-first workflow, validation, labeling, platform-aware routing.

## Tasks

| Task | Description |
|------|-------------|
| `pre-creation` | |
| `single-task-check` | |
| `creation` | |
| `post-creation` | |
| `close` | |
| `verify-merge` | |
| `capabilities` | |
| `completion` | |
| `body-edit` | Edit remote.md body via 4-agent dispatch (fetch → transform → verify → post) |
| `read-issue` | Read single issue via dispatcher |
| `read-comments` | Read issue comments via dispatcher |
| `read-labels` | Read issue labels via dispatcher |
| `list-issues` | List issues with filters via dispatcher |
| `search-issues` | Search issues via dispatcher |
| `update-issue` | Update issue body/labels/state via dispatcher |
| `push-artifacts` | Push spec artifacts directory to issues-data |

## Invocation

`skill({name: "issue-operations-core"})` — call the skill, then dispatch each task-card row via task():

| Task | Call via task() |
|------|-----------------|
| `pre-creation` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [validate spec before issue creation](.opencode/skills/issue-operations-core/tasks/pre-creation.md). "))` |
| `creation` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [create issue](.opencode/skills/issue-operations-core/tasks/creation.md). "))` |
| `close` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [close issue after merge](.opencode/skills/issue-operations-core/tasks/close.md). "))` |
| `verify-merge` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [verify PR merge before close](.opencode/skills/issue-operations-core/tasks/verify-merge.md). "))` |
| `completion` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [complete issue operation](.opencode/skills/issue-operations-core/tasks/completion.md). "))` |
| `read-issue` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [read issue](.opencode/skills/issue-operations-core/tasks/read-issue.md). "))` |
| `read-comments` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [read issue comments](.opencode/skills/issue-operations-core/tasks/read-comments.md). "))` |
| `read-labels` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [read issue labels](.opencode/skills/issue-operations-core/tasks/read-labels.md). "))` |
| `list-issues` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [list issues](.opencode/skills/issue-operations-core/tasks/list-issues.md). "))` |
| `search-issues` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [search issues](.opencode/skills/issue-operations-core/tasks/search-issues.md). "))` |
| `update-issue` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [update issue](.opencode/skills/issue-operations-core/tasks/update-issue.md). "))` |
| `push-artifacts` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [push spec artifacts to issues-data](.opencode/skills/issue-operations-core/tasks/push-artifacts.md). "))` |

## DISPATCH_GATE

The orchestrator MUST NOT preload execution context into `task()` prompts. Every sub-agent MUST independently discover scope and produce its own result contract.

### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read creation.md then execute step 1" | "execute creation task from issue-operations-core" |
| Preloaded step sequences | "Step 1: validate. Step 2: create." | "execute creation task from issue-operations-core" |
| Preloaded expected outcomes | "Return { issue_number, url }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The issue needs to be created because..." | Pure objective, no narrative |

### Sub-Agent Entry Criteria

### Orchestrator Entry Criteria

Reading the Trigger Dispatch Table and Invocation section in the orchestrator's own context is small, necessary, routing-relevant work assigned to the orchestrator by allocation-by-context-cost: the skill card is routing metadata the orchestrator must hold, and sub-agents cannot call `skill()` or load skills. The no-preloaded-context substance below is unchanged.

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST use the exact `task(..., prompt: "...")` string from the table — NOT write a custom prompt with preloaded context.

## Cross-References

Skills: `github-mcp`, `gitbucket-api`, `local` (platform sub-skills). Guidelines: `010-approval-gate.md`, `000-critical-rules.md`.
