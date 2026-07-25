# Plan: #2139 — Flatten verify-authorization

## Spec: .opencode#2139

## Items

### Item 1: Delete broken task card and work-state-schema
- **Scope:** DELETE
- **Files:** `skills/approval-gate-scope/tasks/verify-authorization.md`, `skills/approval-gate-scope/enforcement/work-state-schema.md`
- **Acceptance:** SC-1, SC-2
- **TDD:** structural (test ! -f)

### Item 2: Create apply-label.md and verify-explicit-authorization.md
- **Scope:** CREATE
- **Files:** `skills/approval-gate-scope/tasks/apply-label.md`, `skills/approval-gate-scope/tasks/verify-authorization/verify-explicit-authorization.md`
- **Acceptance:** Referenced in Workflows section
- **TDD:** structural (file exists)

### Item 3: Add Workflows section to approval-gate-scope SKILL.md
- **Scope:** MODIFY
- **Files:** `skills/approval-gate-scope/SKILL.md`
- **Acceptance:** SC-3 (3 workflow entries with numbered lists and sub-bullets)
- **TDD:** string (grep for headings)

### Item 4: Replace Work State I/O with Result Contract in 11 sub-task files
- **Scope:** MODIFY
- **Files:** All 11 files in `verify-authorization/`
- **Acceptance:** SC-4 (11 files preserved), SC-5 (no "Work State I/O"), SC-6 (no "work.md")
- **TDD:** string (grep)

### Item 5: Update approval-gate/SKILL.md canonical dispatch strings
- **Scope:** MODIFY
- **Files:** `skills/approval-gate/SKILL.md`
- **Acceptance:** 4 dispatch strings updated (verify-authorization, apply-label, revision-revocation, bug-discovery-protocol)
- **TDD:** string (grep)

### Item 6: Update cross-referencing files
- **Scope:** MODIFY
- **Files:** 5 cross-referencing files
- **Acceptance:** SC-7 (no references to verify-authorization.md)
- **TDD:** string (grep)

### Item 7: Remove work state file reads from verify-blockers.md and verify-sub-issues.md
- **Scope:** MODIFY
- **Files:** `verify-blockers.md`, `verify-sub-issues.md`
- **Acceptance:** SC-8 (no work.md references in these files)
- **TDD:** string (grep)

## Dependency Order
Item 1 → Item 2 → Item 3 → Item 4 → Item 5 → Item 6 → Item 7
(Items 2-7 can be parallelized after Item 1)
