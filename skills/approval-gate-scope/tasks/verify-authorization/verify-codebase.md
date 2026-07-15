# Task: verify-authorization — Step 5d.1: Verify Codebase

## Purpose

Thin wrapper dispatching `tasks/verify-codebase.md` for staleness detection and superseding issue check.

## Entry Criteria

- Authorization verified (from Step 1)
- Sub-issues verified (from Step 5)

## Exit Criteria

- Files exist, code valid, no superseding issues, no staleness

## Procedure

Dispatch `tasks/verify-codebase.md` with the current issue context. Reads from work state `## sub-issue-verification`, writes to `## verify-codebase`.

## Work State I/O

- **Reads from:** `## sub-issue-verification`
- **Writes to:** `## verify-codebase`
