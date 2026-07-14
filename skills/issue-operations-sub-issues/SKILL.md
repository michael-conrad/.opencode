---
name: issue-operations-sub-issues
description: "Sub-issue management skill for linking and reading sub-issues. Dispatch when creating sub-issues under parent plan issues or reading sub-issue relationships. Also dispatch when verifying authorization cascade or closure order through sub-issue structure. Sub-issue tracking is REQUIRED for multi-task plans"
license: MIT
provenance: AI-generated
---

# Skill: issue-operations-sub-issues

## Overview

Sub-issue management for parent-child issue relationships. Handles linking sub-issues to parent plan issues and reading sub-issue structures for authorization cascade and closure order verification.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "link sub-issue" / "add sub-issue" | `link-sub-issue` | `sub-task` | {parent_issue, sub_issue} |
| "read-sub-issues" / "get sub-issues" | `read-sub-issues` | `sub-task` | {issue_number} |

## Persona

Sub-Issue Manager. Focus: parent-child relationships, authorization cascade, closure ordering.

## Tasks

| Task | Description |
|------|-------------|
| `link-sub-issue` | Create and link sub-issues to parent plan issues |
| `read-sub-issues` | Read sub-issues via dispatcher |

## Invocation

`skill({name: "issue-operations-sub-issues"})` — call the skill, then call via task():

| Task | Call via task() |
|------|-----------------|
| `link-sub-issue` | `task(..., prompt: "execute link-sub-issue task from issue-operations-sub-issues")` |
| `read-sub-issues` | `task(..., prompt: "execute read-sub-issues task from issue-operations-sub-issues")` |

## DISPATCH_GATE

The orchestrator MUST NOT preload execution context into `task()` prompts. Every sub-agent MUST independently discover scope and produce its own result contract.

### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read link-sub-issue.md then execute step 1" | "execute link-sub-issue task from issue-operations-sub-issues" |
| Preloaded step sequences | "Step 1: create sub-issue. Step 2: link." | "execute link-sub-issue task from issue-operations-sub-issues" |
| Preloaded expected outcomes | "Return { sub_issue_id, url }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The sub-issue needs to be linked because..." | Pure objective, no narrative |

### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains inline file paths, inline step definitions, expected outcome structures, or pre-loaded evidence. Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST use the exact `task(..., prompt: "...")` string from the table — NOT write a custom prompt with preloaded context.

## Cross-References

Skills: `github-mcp`, `gitbucket-api`, `local` (platform sub-skills). Guidelines: `010-approval-gate.md`, `000-critical-rules.md`.
