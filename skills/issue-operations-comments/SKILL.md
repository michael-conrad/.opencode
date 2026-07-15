---
name: issue-operations-comments
description: "Issue comment gating and posting skill that enforces the substantive comment gate. Dispatch when posting comments to issues or PRs. Also dispatch when checking whether comment content is substantive enough to post. Comment posting is gated by the substantiveness check — non-substantive progress updates MUST NOT be posted to GitHub Issues"
license: MIT
provenance: AI-generated
---

# Skill: issue-operations-comments

## Overview

Comment gating and posting for issues/PRs. Enforces the substantive comment gate — only meaningful updates are posted as issue comments. Non-substantive progress updates (status updates, phase complete, implemented X) MUST NOT be posted to GitHub Issues.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "comment" / "add comment" / "post comment" | `comment` | `sub-task` | {issue_number, body} |

## Persona

Issue Comment Gatekeeper. Focus: substantiveness check, byline format, platform-aware routing.

## Tasks

| Task | Description |
|------|-------------|
| `comment` | Post comments to issues/PRs following the substantive comment gate and byline format |

## Invocation

`skill({name: "issue-operations-comments"})` — call the skill, then call via task():

| Task | Call via task() |
|------|-----------------|
| `comment` | `task(..., prompt: "execute comment task from issue-operations-comments")` |

## DISPATCH_GATE

The orchestrator MUST NOT preload execution context into `task()` prompts. Every sub-agent MUST independently discover scope and produce its own result contract.

### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read comment.md then execute step 1" | "execute comment task from issue-operations-comments" |
| Preloaded step sequences | "Step 1: check substantiveness. Step 2: post." | "execute comment task from issue-operations-comments" |
| Preloaded expected outcomes | "Return { comment_id, url }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The comment needs to be posted because..." | Pure objective, no narrative |

### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains inline file paths, inline step definitions, expected outcome structures, or pre-loaded evidence. Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST use the exact `task(..., prompt: "...")` string from the table — NOT write a custom prompt with preloaded context.

## Cross-References

Skills: `github-mcp`, `gitbucket-api`, `local` (platform sub-skills). Guidelines: `010-approval-gate.md`, `000-critical-rules.md`.
