---
issue: .opencode#2419
title: "[SPEC-FIX] Remove blanket 'No echo or printf' rule from 020-go-prohibitions.md"
status: open
phase: spec_created
created: 2026-08-30
---

## Problem

The blanket prohibition "No `echo` or `printf` commands — ever" at line 14 of `guidelines/020-go-prohibitions.md` is:

1. **Redundant** — The three sub-concerns it addresses (output for narration, file operations bypassing tools, script injection) are already covered by:
   - Five-tier tool hierarchy (`guidelines/060-tool-usage.md`)
   - API Client Mandate (`guidelines/060-tool-usage.md`)
   - Orchestrator inline-work prohibitions
   - Self-Simulation Prohibition (`guidelines/117-session-trigger-behavior.md`)
   - Silent Halt and Silent Agent Termination rules

2. **Self-contradictory** — The project's own infrastructure uses `echo` and `printf` extensively (pre-push hooks at `hooks/pre-push:40`, behavioral test scripts, enforcement gate files at `skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md:92`).

3. **Overly broad** — Prevents legitimate uses (progress reporting in test scripts, verification scripts, diagnostic output in enforcement gates).

## Scope

**Single-rule removal only.** Remove lines 14-17 of `guidelines/020-go-prohibitions.md` (the "No `echo` or `printf` commands — ever" bullet with its 3 sub-bullets). No other section in `020-go-prohibitions.md` is modified.

**Do NOT modify `guidelines/117-session-trigger-behavior.md`.** The mention of `echo`/`printf` as examples under the Self-Simulation Prohibition serves a distinct purpose (preventing the write→consume cycle) and is retained.

## Affected Files

- `guidelines/020-go-prohibitions.md` (lines 14-17 removed)

## Success Criteria

| SC | Evidence Type | Description |
|----|---------------|-------------|
| SC-1 | structural | Line 14 of `guidelines/020-go-prohibitions.md` no longer contains "No `echo` or `printf` commands — ever" or its 3 sub-bullets. |
| SC-2 | structural | No other section of `guidelines/020-go-prohibitions.md` has been modified. |
| SC-3 | structural | `guidelines/117-session-trigger-behavior.md` is unmodified — its mention of `echo`/`printf` as examples under Self-Simulation Prohibition is preserved. |

## Evidence Plan

- SC-1: `git diff` shows lines 14-17 removed from `020-go-prohibitions.md`
- SC-2: `git diff` shows no other changes in `020-go-prohibitions.md`
- SC-3: `git diff` shows no changes to `117-session-trigger-behavior.md`
