---
issue: .opencode#2141
title: "[SPEC] Fix: Authorization Workflow — Record Session Authorization Before Verifying"
status: approved
approved: 2026-07-25
created: 2026-07-25
license: MIT
provenance: AI-generated
phase: 1
phase_name: Authorization Workflow Fix
authors:
  - OpenCode (deepseek-v4-flash)
---

> **Full spec and artifacts: [`.opencode/.issues/2141/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2141)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2141/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Intent and Executive Summary

### Problem Statement

The `approval-gate-scope` authorization workflow has a circular dependency: it checks for recorded authorization in persistent issue state (`.issues/{N}/comments.yaml`, `spec.md` frontmatter, `issue.yaml` labels) before it has written the session authorization (given in chat) to that same state. The agent receives valid authorization from the developer in chat, but the workflow deadlocks because it verifies against state that hasn't been written yet.

### Root Cause / Motivation

The current `verify-authorization` workflow in `approval-gate-scope` has a structural design defect:

1. **Step 0.5 (scope-auto-resolve):** Correctly parses session authorization from chat — resolves `for_implementation`, `for_pr`, etc. ✅
2. **Step 1 (verify-explicit-authorization):** Reads issue comments / `comments.yaml` for a pre-existing "approved"/"go" record — finds nothing because the authorization was just given in the chat session, not yet recorded ❌
3. **Step 3 (apply-label):** Would apply the label — but this runs AFTER verification, and verification already failed because the label wasn't there

**Result:** The agent is authorized (the developer said "approved" in chat) but the workflow deadlocks because it checks for recorded authorization that it hasn't been allowed to write yet. This is a **confused deputy variant**: the agent holds valid authority but its own workflow prevents it from exercising that authority.

**Research card:** `.issues/research-cards/authorization-session-vs-workflow-state.md` documents the industry research supporting the record-then-verify pattern.

### Approach Chosen

Reorder the `verify-authorization` workflow to a **record-then-verify** pattern: (1) scope-auto-resolve, (2) record-authorization, (3) verify-recording, (4) apply-label, (5) auto-dispatch. A new `record-authorization` task writes session authorization into persistent issue state before any verification step reads it. The existing `verify-explicit-authorization` task is replaced by a `verify-recording` task that reads back the recorded state and confirms it matches what was written.

### Alternatives Considered & Why Discarded

**(a) Modify `verify-explicit-authorization` instead of replacing it.** The existing task is tightly coupled to reading pre-existing authorization from issue comments. Adding write-then-read logic to the same task violates SRP — it would both record and verify, making the task responsible for two distinct concerns. A clean replacement (`verify-recording`) with a single responsibility (read-back confirmation) is simpler to implement, test, and audit.

**(b) Use a different persistence mechanism (e.g., in-memory cache, environment variable).** In-memory state is lost on session restart, which breaks the authorization continuity guarantee. Environment variables are process-scoped and invisible to sub-agents. The `.issues/` worktree is the canonical persistent state store for issue metadata — using it ensures authorization records survive session boundaries and are visible to all sub-agents.

**(c) Skip recording and check chat directly.** The chat transcript is ephemeral — it is not persisted in a structured, queryable format. Sub-agents cannot read the orchestrator's chat context. Recording to `.issues/` makes authorization visible to all pipeline stages, including clean-room sub-agents that have no access to the orchestrator's session.

### Key Design Decisions

- **Record before verify:** Authorization is written to persistent state before any verification step reads it, eliminating the circular dependency.
- **Single responsibility per task:** `record-authorization` writes; `verify-recording` reads back. No task does both.
- **Three-file consistency:** Authorization is recorded in three locations (`spec.md` frontmatter, `comments.yaml`, `issue.yaml` labels) and all three are verified independently.
- **Worktree commit:** The `.issues/` worktree is committed after recording, ensuring the authorization record survives session boundaries and is visible to sub-agents.

## Not Included

- Changes to the `gap-fill-cascade` checklist items (they work correctly once authorization is recorded)
- Changes to `spec-to-plan-cascade` (it works correctly once spec status is `approved`)
- Changes to `scope-auto-resolve.md` (it works correctly)
- Changes to the `apply-label` task (it works correctly — just needs to run at the right time)
- Changes to the `verify-explicit-authorization` task (it will be replaced by a `verify-recording` task)
- Changes to the `verify-authorization` workflow ordering in `approval-gate-scope/SKILL.md` Workflows section
- Changes to the `gap-fill-cascade` task files
- Changes to the `auto-dispatch` task

## Edge Cases

### `.issues/` Worktree Not Initialized

If the `.issues/` worktree has not been initialized (no orphan branch, no worktree checkout), the `record-authorization` task cannot write to `comments.yaml`, `spec.md` frontmatter, or `issue.yaml`. The task MUST check for worktree existence before writing and return BLOCKED with `reason: ISSUES_WORKTREE_NOT_INITIALIZED` if the worktree is missing. The `verify-recording` task MUST also check worktree existence and return BLOCKED if the worktree is absent.

### Malformed `spec.md` Frontmatter

If `spec.md` frontmatter is malformed (missing YAML delimiters, invalid YAML, missing `status` field), the `record-authorization` task MUST handle the parse failure gracefully — return BLOCKED with `reason: MALFORMED_FRONTMATTER` rather than silently failing to update the status field. The `verify-recording` task MUST also detect malformed frontmatter and return BLOCKED.

### Missing `comments.yaml`

If `comments.yaml` does not exist (first-time authorization, or file was deleted), the `record-authorization` task MUST create the file with the initial authorization record rather than failing. The `verify-recording` task MUST handle a missing `comments.yaml` as a FAIL (no authorization record exists) and return BLOCKED.

### Commit Failure

If `git commit` in the `.issues/` worktree fails (merge conflict, hook rejection, dirty index), the `record-authorization` task MUST return BLOCKED with `reason: COMMIT_FAILED` and include the git error output. The authorization data has been written to disk but is not yet committed — the task MUST NOT report success without a successful commit.

### Concurrent Authorization Attempts

If two agents or sessions attempt to record authorization for the same issue concurrently, the second commit will fail (the worktree state changed between write and commit). The `record-authorization` task MUST handle this by: (1) re-reading the current state, (2) verifying the existing authorization record is compatible (same scope or higher), (3) either skipping (if already authorized at same scope) or overwriting (if higher scope) and retrying the commit. If the existing record has a conflicting scope, return BLOCKED with `reason: CONCURRENT_AUTHORIZATION_CONFLICT`.

## Cost Frame

This spec's success criteria are verified using the DDL (defect-discovery-latency) cost model from `065-verification-honesty.md`. Cost is measured in defect-discovery-latency — the time between defect introduction and defect discovery. Shorter DDL means cheaper fixes; longer DDL means exponentially compounding cost.

**Death spiral dynamics:** Structural evidence (file exists, file non-empty) for a behavioral change (workflow reordering that affects agent dispatch decisions) produces a death spiral — the defect ships unchanged, is found in production, and the rework cycle costs 1000× more than the skipped behavioral test would have cost. Each rework cycle re-applies structural verification, which passes again for the next behavioral defect. Cost compounds exponentially.

**Break dynamics:** Behavioral FAIL at gate 1 (pre-commit / pre-RED) catches the defect immediately. The test costs minutes of execution time — a bounded delay. The fix costs the same bounded delay. There is no downstream rework, no CI queue delay, no PR re-review, no production incident. The total cost of the defect is the cost of running the behavioral test — zero compared to the death spiral alternative.

SCs that describe runtime-behavioral changes (workflow reordering, agent dispatch decisions) are classified as `behavioral` evidence type and verified via `opencode run` with stderr assertions. SCs that describe file existence are classified as `structural` and verified via file existence checks. This prevents the death spiral by catching behavioral defects at the earliest possible gate.

## SC Enforcement Gate

All success criteria MUST pass before this implementation is considered complete. Partial implementation is not accepted. Every SC has a declared evidence type and verification method — the verification MUST use at minimum the evidence type specified. Using evidence below the minimum type (e.g., structural evidence for a behavioral SC) is a CRITICAL VIOLATION per `080-code-standards.md` §Evidence Type Taxonomy.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | A new `record-authorization` task exists at `approval-gate-scope/tasks/record-authorization.md` that writes session authorization into persistent issue state | `structural` | File exists at `approval-gate-scope/tasks/record-authorization.md` |
| SC-2 | The `record-authorization` task updates `spec.md` frontmatter to add `status: approved` when the resolved scope is `for_implementation` or higher | `behavioral` | Dispatch the task with a mock session authorization → verify `spec.md` frontmatter contains `status: approved` |
| SC-3 | The `record-authorization` task appends an authorization record to `comments.yaml` with the authorization text, scope, timestamp, and human attribution | `behavioral` | Dispatch the task → verify `comments.yaml` contains a new entry with `author: "human"`, `scope: "for_implementation"`, and a timestamp |
| SC-4 | The `record-authorization` task updates `issue.yaml` to add the `approved-for-{scope}` label | `behavioral` | Dispatch the task → verify `issue.yaml` labels array contains `approved-for-implementation` (or matching scope) |
| SC-5 | The `record-authorization` task commits the `.issues/` worktree changes after writing | `behavioral` | Dispatch the task → verify `git -C .issues/ status` shows clean working tree |
| SC-6 | The `verify-authorization` fast-path workflow in `approval-gate-scope/SKILL.md` is reordered to the record-then-verify pattern: scope-auto-resolve → record-authorization → verify-recording → apply-label → auto-dispatch | `behavioral` | Run `opencode run` with a prompt that triggers the fast-path → assert stderr shows the new step order (record-authorization before verify-recording, apply-label after verify-recording). Reference: `approval-gate-scope/SKILL.md` Workflows section — fast-path workflow step sequence |
| SC-7 | The `verify-authorization` full-path workflow in `approval-gate-scope/SKILL.md` is reordered to the record-then-verify pattern: scope-auto-resolve → record-authorization → verify-recording → apply-label → item-decomposition → SC-traceability → sub-issues → spec-to-plan-cascade → gap-fill-cascade → verify-codebase → verify-blockers → verify-closed-issue → verify-already-implemented → auto-dispatch | `behavioral` | Run `opencode run` with a prompt that triggers the full-path → assert stderr shows record-authorization at position 2 and verify-recording at position 3. Reference: `approval-gate-scope/SKILL.md` Workflows section — full-path workflow step sequence |
| SC-8 | The `verify-explicit-authorization.md` task is replaced by a `verify-recording.md` task that reads back the recorded state and confirms it matches what was written | `structural` | File `verify-explicit-authorization.md` no longer exists; file `verify-recording.md` exists at `approval-gate-scope/tasks/verify-authorization/verify-recording.md` |
| SC-9 | The `verify-recording` task checks that `spec.md` frontmatter has `status: approved`, `comments.yaml` has the authorization record, and `issue.yaml` has the label — and returns BLOCKED if any are missing | `behavioral` | Dispatch the task after a successful record → verify PASS. Corrupt one of the three files → verify BLOCKED with specific reason |
| SC-10 | The `apply-label` task in the fast-path and full-path workflows is moved to AFTER `record-authorization` and `verify-recording` (it was previously step 3, now step 4) | `behavioral` | Run `opencode run` with a prompt that triggers either workflow → assert stderr shows apply-label dispatched after verify-recording. Reference: `approval-gate-scope/SKILL.md` Workflows section — apply-label step position in both workflows |
| SC-11 | The `verify-authorization` gap-fill-path workflow in `approval-gate-scope/SKILL.md` is reordered to the record-then-verify pattern: scope-auto-resolve → record-authorization → verify-recording → gap-fill-cascade → auto-dispatch | `behavioral` | Run `opencode run` with a prompt that triggers the gap-fill-path → assert stderr shows record-authorization at position 2 and verify-recording at position 3. Reference: `approval-gate-scope/SKILL.md` Workflows section — gap-fill-path workflow step sequence |
| SC-12 | All three workflows (fast-path, gap-fill-path, full-path) in `approval-gate-scope/SKILL.md` have the `record-authorization` step inserted at position 2, immediately after `scope-auto-resolve` | `behavioral` | Run `opencode run` with prompts that trigger each workflow → assert stderr shows record-authorization is step 2 in all three. Reference: `approval-gate-scope/SKILL.md` Workflows section — step numbering in all three workflows |
| SC-13 | The behavioral test harness MUST produce a `session.yaml` artifact containing the SQLite DB export from the test home. If the SQLite DB is missing from the test home, the harness MUST write `source_db: MISSING` (not `null`, not a fallback path). The evaluation pipeline MUST treat `source_db: MISSING` as a hard FAIL — no hunting for the DB elsewhere, no substitution with stderr/stdout grep, no synthesis, no fabrication. The only recovery mechanism is to verify the test does not violate clean-room separation (dedicated test home directory with the test project inside it) | `behavioral` | Run a behavioral test → verify `session.yaml` exists with `source_db:` pointing to a real path under `tmp/test-home-*/`. If `source_db: MISSING`, the test is FAIL — diagnose the test home setup, not the agent behavior |

## Requirements

1. The `record-authorization` task SHALL write session authorization into persistent issue state.
2. The `record-authorization` task SHALL update `spec.md` frontmatter to add `status: approved` when the resolved scope is `for_implementation` or higher.
3. The `record-authorization` task SHALL append an authorization record to `comments.yaml` with the authorization text, scope, timestamp, and human attribution.
4. The `record-authorization` task SHALL update `issue.yaml` to add the `approved-for-{scope}` label.
5. The `record-authorization` task SHALL commit the `.issues/` worktree changes after writing.
6. The `record-authorization` task SHALL NOT verify that authorization exists — that is the `verify-recording` task's responsibility.
7. The `verify-recording` task SHALL read back the recorded state and confirm it matches what was written.
8. The `verify-recording` task SHALL check `spec.md` frontmatter for `status: approved`, `comments.yaml` for the authorization record, and `issue.yaml` for the label.
9. The `verify-recording` task SHALL return BLOCKED if any of the three checks fail.
10. The `verify-explicit-authorization.md` task SHALL be removed and replaced by `verify-recording.md`.
11. The `apply-label` task SHALL be moved to AFTER `record-authorization` and `verify-recording` in all three workflows.
12. The `record-authorization` step SHALL be step 2 in all three workflows (fast-path, gap-fill-path, full-path), immediately after `scope-auto-resolve`.
13. The behavioral test harness `__export_sqlite_to_yaml` SHALL write `source_db: MISSING` (not `null`, not a fallback path) when the SQLite DB is not found in the test home.
14. The behavioral test harness SHALL NOT fall back to production XDG paths, environment variables, or any other location when the test home SQLite DB is missing.
15. The evaluation pipeline SHALL treat `source_db: MISSING` as a hard FAIL — no substitution, no synthesis, no fabrication.
13. The behavioral test harness `__export_sqlite_to_yaml` SHALL write `source_db: MISSING` (not `null`, not a fallback path) when the SQLite DB is not found in the test home.
14. The behavioral test harness SHALL NOT fall back to production XDG paths, environment variables, or any other location when the test home SQLite DB is missing.
15. The evaluation pipeline SHALL treat `source_db: MISSING` as a hard FAIL — no substitution, no synthesis, no fabrication.

## Pipeline Gates

- [ ] 1. Pre-work (git-workflow-branch) — sub-agent: create feature branch, verify trunk tip
- [ ] 2. SC-1, SC-8 (structural) — sub-agent: create `record-authorization.md`, remove `verify-explicit-authorization.md`, create `verify-recording.md`
- [ ] 3. SC-2, SC-3, SC-4, SC-5 (behavioral) — sub-agent: implement `record-authorization` task procedure
- [ ] 4. SC-9 (behavioral) — sub-agent: implement `verify-recording` task procedure
- [ ] 5. SC-6, SC-7, SC-10, SC-11, SC-12 (behavioral) — sub-agent: reorder three workflows in SKILL.md
- [ ] 6. Behavioral enforcement tests — sub-agent: write RED-phase tests for all behavioral SCs
- [ ] 6a. SC-13 (behavioral) — sub-agent: implement `source_db: MISSING` in harness, remove production fallback paths
- [ ] 7. Completeness gate — sub-agent: verify all SCs covered
- [ ] 8. Audit — sub-agent: adversarial audit of all deliverables
- [ ] 9. Finishing checklist — sub-agent: branch readiness, pre-PR checks
- [ ] 10. PR creation — sub-agent: create PR with evidence artifacts

## Items

1. **SC-1, SC-8** — Create `record-authorization.md` task file; remove `verify-explicit-authorization.md`; create `verify-recording.md` task file
2. **SC-2, SC-3, SC-4, SC-5** — Implement the `record-authorization` task procedure (write spec.md, comments.yaml, issue.yaml, commit)
3. **SC-9** — Implement the `verify-recording` task procedure (read back and confirm)
4. **SC-6, SC-7, SC-10, SC-11, SC-12** — Reorder the three workflows in `approval-gate-scope/SKILL.md`
5. **SC-13** — Implement `source_db: MISSING` in harness `__export_sqlite_to_yaml`, remove all production fallback paths

## Dependencies

- **Prerequisite:** Research card at `.issues/research-cards/authorization-session-vs-workflow-state.md`
- **Prerequisite skill:** `approval-gate-scope` — the skill being modified
- **Prerequisite skill:** `spec-creation` — for the task card format reference
- **Prerequisite skill:** `git-workflow-branch` — for branch creation and commit workflow
- **Prerequisite skill:** `test-driven-development` — for RED/GREEN cycles

## Traceability

| Requirement | SCs | Item |
|-------------|-----|------|
| REQ-1 | SC-1 | 1 |
| REQ-2 | SC-2 | 2 |
| REQ-3 | SC-3 | 2 |
| REQ-4 | SC-4 | 2 |
| REQ-5 | SC-5 | 2 |
| REQ-6 | SC-1 | 1 |
| REQ-7 | SC-8, SC-9 | 1, 3 |
| REQ-8 | SC-9 | 3 |
| REQ-9 | SC-9 | 3 |
| REQ-10 | SC-8 | 1 |
| REQ-11 | SC-6, SC-7, SC-10, SC-11, SC-12 | 4 |
| REQ-12 | SC-6, SC-7, SC-11, SC-12 | 4 |
| REQ-13, REQ-14, REQ-15 | SC-13 | 5 |

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-07-25 | Initial creation | — | — |
| 2026-07-25 | Added preamble (Intent and Executive Summary) with Problem Statement, Root Cause, Approach, Alternatives, Key Design Decisions | Spec-audit finding #1: missing preamble | Spec-audit pipeline |
| 2026-07-25 | Added Edge Cases section (5 failure modes) | Spec-audit finding #2: missing edge cases | Spec-audit pipeline |
| 2026-07-25 | Added Cost Frame section with DDL death spiral / break dynamics; added DDL cost-frame language to each SC | Spec-audit finding #3: missing cost-frame language | Spec-audit pipeline |
| 2026-07-25 | Added SC Enforcement Gate section | Spec-audit finding #4: missing enforcement gate | Spec-audit pipeline |
| 2026-07-25 | Reclassified SC-6, SC-7, SC-10, SC-11, SC-12 from `string` to `behavioral`; updated verification methods to use `opencode run` with stderr assertions | Spec-audit finding #5: evidence type mismatch (runtime-behavioral changes) | Spec-audit pipeline |
| 2026-07-25 | Replaced exact step sequences in SC-6, SC-7, SC-11 with file area references to SKILL.md Workflows section | Spec-audit finding #6: prescriptive code in SCs | Spec-audit pipeline |
| 2026-07-25 | Added Pipeline Gates section with canonical checklist format and dispatch mode indicators | Spec-audit finding #7: missing pipeline gate checklist | Spec-audit pipeline |
| 2026-07-25 | Added three alternatives to preamble with discard rationale | Spec-audit finding #8: missing alternatives considered | Spec-audit pipeline |
