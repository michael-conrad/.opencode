---
issue_number: 1615
title: "[PLAN] Document BEHAVIOR_SUBMODULE_COMMIT precondition in behavioral test harness"
status: draft
labels:
  - PLAN
created: 2026-06-30
---

# [PLAN] Document BEHAVIOR_SUBMODULE_COMMIT precondition in behavioral test harness

## Goal

Add a "Submodule Commit Precondition" subsection to `.opencode/tests/AGENTS.md` documenting `BEHAVIOR_SUBMODULE_COMMIT`, the push-before-test workflow, and the consequence of not meeting the precondition.

## Architecture

Documentation-only change. A new subsection under §5 (Infrastructure Details) in the behavioral test harness specification. No code changes to `helpers.sh` or `behavior_run()`.

## Files

| File | Change | Anchor |
|------|--------|--------|
| `.opencode/tests/AGENTS.md` | Add new subsection | After §5 "Infrastructure Details" (line 291) |

## Phase Table

| Phase | Description | Files | SCs |
|-------|-------------|-------|-----|
| 1 | Add "Submodule Commit Precondition" subsection | `.opencode/tests/AGENTS.md` | SC-1, SC-2, SC-3 |

## Step-by-Step Instructions

### Phase 1 — Add Submodule Commit Precondition Section

1. Open `.opencode/tests/AGENTS.md`
2. Locate the end of §5 "Infrastructure Details" (after the "Isolated Test Repo Construction" subsection, before §6)
3. Insert a new subsection `### Submodule Commit Precondition` documenting:
   - **`BEHAVIOR_SUBMODULE_COMMIT`**: environment variable set in `helpers.sh` that pins the `.opencode` submodule checkout to a specific SHA. When set, the isolated test repo clones the submodule at that commit rather than remote HEAD.
   - **Push-before-test workflow**: feature branch commits must be pushed to remote before `behavior_run()` is called. The test repo clones `.opencode` from remote — unpushed commits are invisible to the test harness.
   - **Consequence of unmet precondition**: if the feature branch commit is not pushed, the test repo clones the submodule at the pinned SHA (or remote HEAD if unset), using stale submodule state. The test runs against old code, not the feature branch changes.
4. Update the Table of Contents to include the new subsection

## Exit Criteria

| SC ID | Criterion | Verification |
|-------|-----------|-------------|
| SC-1 | `.opencode/tests/AGENTS.md` documents the push-before-test requirement | `grep -q "push" .opencode/tests/AGENTS.md` |
| SC-2 | `.opencode/tests/AGENTS.md` documents `BEHAVIOR_SUBMODULE_COMMIT` and its purpose | `grep -q "BEHAVIOR_SUBMODULE_COMMIT" .opencode/tests/AGENTS.md` |
| SC-3 | `.opencode/tests/AGENTS.md` documents the workflow sequence (push → run test) | `grep -q "workflow\|sequence" .opencode/tests/AGENTS.md` |

## Compliance Notice

All steps in this plan MUST be followed in order. This is a single-phase, single-file documentation change. No code modifications are authorized. Verification gates (grep checks) MUST pass before marking the phase complete.
