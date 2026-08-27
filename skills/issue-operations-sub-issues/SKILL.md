---
name: issue-operations-sub-issues
description: "Sub-issue management for linking and reading sub-issue relationships. Load via skill() when creating sub-issues under parent plan issues or reading sub-issue relationships. Also load when verifying authorization cascade or closure order through sub-issue structure. Sub-issue tracking is REQUIRED for multi-task plans. User phrases: create sub-issue, link sub-issue, read sub-issues, verify hierarchy"
license: MIT
provenance: AI-generated
---

# Skill: issue-operations-sub-issues

## Overview

Sub-issue management for parent-child issue relationships. Handles linking sub-issues to parent plan issues and reading sub-issue structures for authorization cascade and closure order verification.

## Pre-Flight Guard (Mandatory)

**This skill card is orchestrator-only routing metadata.**

If you are a sub-agent (dispatched via `task()`), you MUST NOT consume the routing metadata below. Sub-agents cannot call `task()` and cannot execute orchestrator-level dispatch instructions. Return `BLOCKED` with reason `ORCHESTRATOR_ONLY_SKILL_CARD` and halt.

If you are the orchestrator (loaded this card via `skill({name: "..."})`), proceed to the Workflows section.

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
| `link-sub-issue` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [link sub-issues](.opencode/skills/issue-operations-sub-issues/tasks/link-sub-issue.md). "))` |
| `read-sub-issues` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [read sub-issues](.opencode/skills/issue-operations-sub-issues/tasks/read-sub-issues.md). "))` |

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

### Orchestrator Entry Criteria

Reading the Trigger Dispatch Table and Invocation section in the orchestrator's own context is small, necessary, routing-relevant work assigned to the orchestrator by allocation-by-context-cost: the skill card is routing metadata the orchestrator must hold, and sub-agents cannot call `skill()` or load skills. The no-preloaded-context substance below is unchanged.

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST use the exact `task(..., prompt: "...")` string from the table — NOT write a custom prompt with preloaded context.

## Cross-References

Skills: `github-mcp`, `gitbucket-api`, `local` (platform sub-skills). Guidelines: `010-approval-gate.md`, `000-critical-rules.md`.

### [critical-rules-018] Sub-issue Structure Bypass — multi-task plans
Phases require sub-issue linkage. Read [issue-operations skill](skills/issue-operations/SKILL.md) → `link-sub-issue` task.


### [critical-rules-018] Sub-issue Linkage Verification — phase count mismatch
Read [approval-gate --task verify-authorization](skills/approval-gate/SKILL.md) Step 5.
