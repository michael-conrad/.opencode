---
name: issue-operations-core
description: "Core issue CRUD operations dispatcher that routes to GitHub MCP or GitBucket API based on github.platform. Dispatch when creating, reading, updating, closing, or listing issues. Also dispatch when editing issue bodies, verifying merge status, checking single-task plans, pushing spec artifacts, or running pre/post-creation validation. Issue tracking is REQUIRED"
license: MIT
provenance: AI-generated
---

# Skill: issue-operations-core

## Overview

Core CRUD operations for issue management. Routes all operations to the appropriate platform sub-skill (github-mcp, gitbucket-api, local). Handles creation, reading, updating, closing, listing, searching, body editing, merge verification, single-task checks, artifact pushing, and pre/post-creation validation.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "pre-creation" / "prepare issue" | `pre-creation` | `sub-task` | {issue_context} |
| "single-task-check" / "check single task" | `single-task-check` | `sub-task` | {issue_number} |
| "create issue" / "new issue" | `creation` | `sub-task` | {issue_body} |
| "post-creation" / "after create" | `post-creation` | `sub-task` | {issue_number} |
| "close issue" | `close` | `sub-task` | {issue_number} |
| "verify merge" / "check merged" | `verify-merge` | `sub-task` | {issue_number} |
| "capabilities" / "list capabilities" | `capabilities` | `sub-task` | {platform} |
| "body-edit" / "edit body" | `body-edit` | `sub-task` | {issue_number, new_body} |
| "read-issue" / "get issue" | `read-issue` | `sub-task` | {issue_number} |
| "read-comments" / "get comments" | `read-comments` | `sub-task` | {issue_number} |
| "read-labels" / "get labels" | `read-labels` | `sub-task` | {issue_number} |
| "list-issues" / "list with filters" | `list-issues` | `sub-task` | {filters} |
| "search-issues" / "search" | `search-issues` | `sub-task` | {query} |
| "update-issue" / "edit issue" | `update-issue` | `sub-task` | {issue_number, updates} |
| "push-artifacts" / "push spec artifacts" | `push-artifacts` | `sub-task` | {issue_number} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

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

`skill({name: "issue-operations-core"})` — call the skill, then call via task():

| Task | Call via task() |
|------|-----------------|
| `pre-creation` | `task(..., prompt: "execute pre-creation task from issue-operations-core")` |
| `creation` | `task(..., prompt: "execute creation task from issue-operations-core")` |
| `close` | `task(..., prompt: "execute close task from issue-operations-core")` |
| `verify-merge` | `task(..., prompt: "execute verify-merge task from issue-operations-core")` |
| `completion` | `task(..., prompt: "execute completion task from issue-operations-core")` |
| `read-issue` | `task(..., prompt: "execute read-issue task from issue-operations-core")` |
| `read-comments` | `task(..., prompt: "execute read-comments task from issue-operations-core")` |
| `read-labels` | `task(..., prompt: "execute read-labels task from issue-operations-core")` |
| `list-issues` | `task(..., prompt: "execute list-issues task from issue-operations-core")` |
| `search-issues` | `task(..., prompt: "execute search-issues task from issue-operations-core")` |
| `update-issue` | `task(..., prompt: "execute update-issue task from issue-operations-core")` |
| `push-artifacts` | `task(..., prompt: "execute push-artifacts task from issue-operations-core")` |

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

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains inline file paths, inline step definitions, expected outcome structures, or pre-loaded evidence. Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST use the exact `task(..., prompt: "...")` string from the table — NOT write a custom prompt with preloaded context.

## Cross-References

Skills: `github-mcp`, `gitbucket-api`, `local` (platform sub-skills). Guidelines: `010-approval-gate.md`, `000-critical-rules.md`.
