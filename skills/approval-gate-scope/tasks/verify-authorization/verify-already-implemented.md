# Task: verify-authorization — Step 5d.4: Verify Already Implemented

## Purpose

Thin wrapper dispatching `tasks/verify-already-implemented.md` for terminal gate: auto-close or proceed.

## Entry Criteria

- Authorization verified (from Step 1)
- Codebase checked (from Step 5d.1)
- No blockers (from Step 5d.2)
- Main issue closure verified (from Step 5d.3)

## Exit Criteria

- Auto-close or proceed to implementation

## Procedure

Dispatch `tasks/verify-already-implemented.md` with the current issue context. Reads from work state `## verify-closed-issue-main`, writes to `## verify-already-implemented`.

## Work State I/O

- **Reads from:** `## verify-closed-issue-main`
- **Writes to:** `## verify-already-implemented`
