<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: read-plan

## Purpose

Reads an approved implementation plan file and inventories its phases in dependency order to produce the phase dispatch sequence.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`,
         `blocker_reason`. Full evidence goes to disk.

## Dispatch Contract

- `issue_number` — the issue number whose plan is being executed
- `plan_path` — path to the approved plan file
- `project_root` — project root directory

## Entry Criteria

- The plan file must exist at `plan_path`
- The plan must be approved (per the authorization gate) before execution
- The `issue_number` and `project_root` must be provided

## Procedure

- [ ] 1. Read the plan file at `plan_path` in full.
- [ ] 2. Extract every phase from the plan body in the order it appears.
- [ ] 3. Determine each phase's dependency order from the plan's phase structure.
- [ ] 4. Record the ordered phase list to the artifact path as evidence.
- [ ] 5. Return the result contract with the phase order.

## Exit Criteria

- The plan file has been read in full
- Every phase has been extracted in dependency order
- The ordered phase list has been written to the artifact path
- The result contract includes the phase order

## Result Contract

```yaml
status: DONE | BLOCKED | OVERFLOW
finding_summary: "<1-3 sentences summarizing the plan's phases and dependency order>"
artifact_path: "<path to the phase inventory evidence>"
blocker_reason: "<reason if BLOCKED>"
phase_order: "<ordered list of phase names>"
```
