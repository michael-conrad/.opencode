---
name: issue-operations-sync
description: "Issue synchronization skill for reconciling remote and local issue tracking. Dispatch when syncing issues from remote to local, mirroring remote issue bodies to local spec files, or retroactively importing pre-existing remote issues into local tracking. Sync is REQUIRED maintenance for multi-platform issue workflows"
license: MIT
provenance: AI-generated
---

# Skill: issue-operations-sync

## Overview

Issue synchronization between remote platforms and local `.issues/` tracking. Handles reconciling remote issues against local state, mirroring remote issue bodies to local spec files, and retroactively importing pre-existing remote issues.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "sync-from-remote" / "reconcile" | `sync-from-remote` | `sub-task` | {platform} |
| "sync-pull-to-local" / "mirror to local" | `sync-pull-to-local` | `sub-task` | {issue_number} |
| "import-remote" / "retroactive import" | `import-remote` | `sub-task` | {issue_number} |

## Persona

Issue Sync Manager. Focus: bidirectional reconciliation, spec.md mirror mandate, retroactive import.

## Tasks

| Task | Description |
|------|-------------|
| `sync-from-remote` | Reconcile remote issues against local `.issues/` |
| `sync-pull-to-local` | Mirror remote issue body to `.issues/<N>/spec.md` |
| `import-remote` | Retroactively import pre-existing remote issue into local `.issues/` |

## Invocation

`skill({name: "issue-operations-sync"})` — call the skill, then call via task():

| Task | Call via task() |
|------|-----------------|
| `sync-from-remote` | `task(..., prompt: "execute sync-from-remote task from issue-operations-sync")` |
| `sync-pull-to-local` | `task(..., prompt: "execute sync-pull-to-local task from issue-operations-sync")` |
| `import-remote` | `task(..., prompt: "execute import-remote task from issue-operations-sync")` |

## DISPATCH_GATE

The orchestrator MUST NOT preload execution context into `task()` prompts. Every sub-agent MUST independently discover scope and produce its own result contract.

### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read sync-from-remote.md then execute step 1" | "execute sync-from-remote task from issue-operations-sync" |
| Preloaded step sequences | "Step 1: sync. Step 2: reconcile." | "execute sync-from-remote task from issue-operations-sync" |
| Preloaded expected outcomes | "Return { synced_count, stale_count }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The sync is needed because..." | Pure objective, no narrative |

### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains inline file paths, inline step definitions, expected outcome structures, or pre-loaded evidence. Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST use the exact `task(..., prompt: "...")` string from the table — NOT write a custom prompt with preloaded context.

## Cross-References

Skills: `github-mcp`, `gitbucket-api`, `local` (platform sub-skills). Guidelines: `010-approval-gate.md`, `000-critical-rules.md`.
