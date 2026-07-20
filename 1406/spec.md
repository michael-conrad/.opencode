## Summary

The orchestrator bypassed the entire workflow pipeline when processing `.opencode#1401` — reading task files inline, editing files directly, and skipping all sub-agent dispatches. This is not a one-time mistake; it is a structural gap in enforcement. All four layers of the current enforcement stack (critical-rules-034, critical-rules-048, critical-rules-dispatch-gate-canonical, PRELOADED_CONTEXT_REJECTED protocol) rely on **agent self-enforcement** — the orchestrator must recognize it is doing inline work and stop. An agent that bypasses the skill dispatch gate also bypasses the rules designed to catch the bypass.

## Root Cause Analysis

### Layer 1: No `verify-authorization` dispatch
The `approval-gate` skill's Trigger Dispatch Table maps `"approved for pr"` to `auto-dispatch`. The orchestrator read the skill, parsed the scope, and jumped directly to reading the target file — never calling `task()` for any approval-gate task.

### Layer 2: Pre-read + inline execution (critical-rules-048)
The orchestrator read `verification-audit.md` directly with the `read` tool instead of dispatching a sub-agent. The skill dispatch mandate says: load skill → read dispatch table → use canonical dispatch string verbatim. The orchestrator read the dispatch table, then ignored it.

### Layer 3: Orchestrator inline edits (critical-rules-034)
After reading the file, the orchestrator edited it with `edit` instead of tasking a sub-agent. The orchestrator is a pure router — it tasks sub-agents and receives result contracts. File modifications in the orchestrator's own context poison the pipeline.

### Layer 4: The enforcement gap
The four enforcement layers are:

| Layer | Mechanism | Enforcer |
|-------|-----------|----------|
| 1. Orchestrator Self-Discipline | critical-rules-034, -048, -dispatch-gate-canonical | Orchestrator agent (self-enforcement) |
| 2. Sub-Agent Gate | PRELOADED_CONTEXT_REJECTED protocol | Sub-agent receiving task() |
| 3. Pipeline Structure | assemble-work.md as mandatory entry point | Orchestrator following procedure |
| 4. Poison Recovery | Full restart from verify-authorization | Orchestrator (self-detection) |

**All four layers rely on agent self-enforcement.** There is no external runtime enforcement — no pre-commit hook, no session-enforcement.ts watchdog, no behavioral test that runs automatically — that detects orchestrator inline work at the moment it happens. An agent that bypasses the skill dispatch gate (critical-rules-048) also bypasses the very rules designed to catch the bypass.

## Fix Required

### Phase 1: Pre-commit hook — detect orchestrator inline file reads

Add a pre-commit hook check that detects when the orchestrator reads skill task files (`.opencode/skills/*/tasks/*.md`) without having dispatched a sub-agent first. The hook cannot distinguish orchestrator from sub-agent context, so this must be a **runtime watchdog** in `session-enforcement.ts` that:

1. Monitors `read` tool calls targeting `.opencode/skills/*/tasks/*.md` files
2. Checks whether a `task()` call was made in the preceding exchange
3. If a task file is read without a prior `task()` call: inject a warning into the next user message

### Phase 2: Pre-commit hook — detect orchestrator inline edits to skill/guideline files

Add a pre-commit hook check that detects when the orchestrator edits `.opencode/skills/` or `.opencode/guidelines/` files without having dispatched a sub-agent. Same mechanism as Phase 1.

### Phase 3: Behavioral enforcement test

Create a behavioral test that:
1. Sends a prompt that triggers the orchestrator to process an approved spec
2. Verifies the orchestrator dispatches sub-agents (stderr shows `task()` calls) rather than reading/editing files inline
3. Fails if the orchestrator performs inline file operations on skill task files

### Phase 4: Documentation — add "first dispatch" gate to approval-gate auto-dispatch

Update `approval-gate/tasks/verify-authorization/auto-dispatch.md` to include an explicit "first dispatch" gate: before any file read or edit, the orchestrator MUST dispatch at least one sub-agent. This is a procedural reminder embedded in the task file itself.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | session-enforcement.ts watchdog detects `read` calls on `.opencode/skills/*/tasks/*.md` without prior `task()` call | `behavioral` |
| SC-2 | Watchdog injects warning into next user message when violation detected | `behavioral` |
| SC-3 | Pre-commit hook blocks commits containing orchestrator inline edits to `.opencode/skills/` or `.opencode/guidelines/` files | `behavioral` |
| SC-4 | Behavioral test verifies orchestrator dispatches sub-agents (not inline work) when processing approved spec | `behavioral` |
| SC-5 | auto-dispatch.md includes "first dispatch" gate procedural reminder | `string` |

## Non-Goals

- This spec does NOT change the verification-audit pre-flight gate (that is `.opencode#1401`'s scope)
- This spec does NOT change the PRELOADED_CONTEXT_REJECTED protocol
- This spec does NOT add new critical rules — it adds enforcement for existing ones

## Dependencies

This spec modifies session-enforcement.ts and pre-commit hooks — no file overlap with #1561 (37 SKILL.md files) or #1407 (39 SKILL.md files). Independent implementation — can be done in any order relative to those specs.