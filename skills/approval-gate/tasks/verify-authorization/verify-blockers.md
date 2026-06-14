# Task: verify-authorization — Step 5d.2: Verify Blockers

## Purpose

Thin wrapper dispatching `tasks/verify-blockers.md` for blocking dependency check.

## Entry Criteria

- Authorization verified (from Step 1)
- Sub-issues verified (from Step 5)
- Codebase verified (from Step 5d.1)

## Exit Criteria

- No blocking issues, no unresolved dependencies

## Procedure

Dispatch `tasks/verify-blockers.md` with the current issue context. Reads from work state `## verify-codebase`, writes to `## verify-blockers`.

## Work State I/O

- **Reads from:** `## verify-codebase`
- **Writes to:** `## verify-blockers`
