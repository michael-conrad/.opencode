<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: execute-phase

## Purpose

Executes a single phase of an approved plan in the orchestrator's own context, performing each step directly and dispatching a step's task card via `task()` ONLY where that step explicitly marks dispatch. The whole phase, the whole plan body, or a whole workflow body MUST NOT be forwarded to a sub-agent.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task except where a plan step explicitly marks dispatch (per-step dispatch mode `task-card`)
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Keep the orchestrator context lean: write evidence to disk and report only routing-significant results

## Dispatch Contract

- `issue_number` — the issue being implemented
- `phase` — the phase name to execute
- `plan_path` — the path to the plan file
- `project_root` — project root directory
- `phase_order` — the ordered list of phases from the read-plan step

## Entry Criteria

- The plan has been read and `phase_order` is available
- The `phase` being executed is the next phase in `phase_order`
- The plan's per-step dispatch modes are known (steps marked `direct` execute in own context; steps marked `task-card` dispatch that step's task card via `task()`)

## Procedure

- [ ] 1. Read the phase's steps from the plan file.
- [ ] 2. For each step in order: if the step's dispatch mode is `direct` (or unmarked — default `direct`), execute the step in the orchestrator's own context with own tool calls; if the step's dispatch mode is `task-card`, dispatch that step's task card via `task()` with a task-card dispatch string — never the plan body, phase body, or workflow body.
- [ ] 3. Verify each step's deliverable before marking the step complete (per `verification-before-completion`).
- [ ] 4. Write phase execution evidence to the artifact path.
- [ ] 5. Identify the next phase in dependency order and report the execution outcome.

## Exit Criteria

- Every step in the phase has been executed per its dispatch mode
- Steps marked `direct` were executed with orchestrator-own tool calls (no `task()`)
- Steps marked `task-card` were dispatched with task-card dispatch strings only
- No `task()` prompt contains the whole plan body, a whole phase body, or a whole workflow body
- Phase evidence has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED | OVERFLOW
finding_summary: "<1-3 sentences summarizing the phase execution outcome>"
artifact_path: "<path to execution evidence on disk>"
blocker_reason: "<reason if BLOCKED>"
```