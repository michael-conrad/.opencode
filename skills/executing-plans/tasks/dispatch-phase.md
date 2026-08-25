<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: dispatch-phase

## Purpose

Dispatches a single phase of an approved plan through the implementation pipeline, routing it to the implementation skill for that phase in the plan's dependency order.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`,
         `blocker_reason`. Full evidence goes to disk.

## Dispatch Contract

- `issue_number` — the issue being implemented
- `phase` — the phase name to dispatch
- `plan_path` — the path to the plan file
- `project_root` — project root directory
- `phase_order` — the ordered list of phases from the read-plan step

## Entry Criteria

- The plan has been read and `phase_order` is available
- The `phase` being dispatched is the next phase in `phase_order`
- The implementation pipeline for the phase is identified

## Exit Criteria

- The phase has been dispatched through the implementation pipeline
- The next phase in dependency order has been identified
- The result contract reflects the dispatch outcome

## Result Contract

```yaml
status: DONE | BLOCKED | OVERFLOW
finding_summary: "<1-3 sentences summarizing the phase dispatch outcome>"
artifact_path: "<path to dispatch evidence on disk>"
blocker_reason: "<reason if BLOCKED>"
```
