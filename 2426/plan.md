---
plan_schema_version: "1.0"
issue: 2426
title: "Reconcile commit co-author trailer and squash-to-one-commit rules across the .opencode skill deck"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — #2426 — Reconcile commit co-author trailer and squash-to-one-commit rules

**Goal:** Eliminate the contradictory commit co-author trailer and commit-count rules in the `.opencode` skill deck so agents consistently produce exactly one squashed commit per issue with dual co-author trailers (AI + human) at PR creation.

**Architecture:** Three reconciliation phases, each driven by a behavioral enforcement test. Phase 1 reconciles trailer placement (no trailers on implementation/WIP commits, dual trailers on the squashed commit). Phase 2 reconciles commit count (multiple WIP commits during dev, squash to one per issue at PR). Phase 3 establishes the canonical rule (one squashed commit per issue with dual trailers) consistently across the PR/squash/enforcement/finishing gates. Phases 1 and 2 are independent and may run in parallel; Phase 3 depends on both. The stacked-PR organization rule (one branch, N commits, one PR) is preserved unchanged.

**Files:**
- `.opencode/.guidelines/commit-workflow.md`
- `.opencode/skills/git-workflow-commit/tasks/commit-prep.md`
- `.opencode/skills/git-workflow-commit/tasks/implementation.md`
- `.opencode/skills/writing-plans/reference/implementation-workflow.md`
- `.opencode/guidelines/000-critical-rules.md`
- `.opencode/skills/git-workflow-commit/SKILL.md`
- `.opencode/skills/git-workflow-pr/tasks/pr-creation.md`
- `.opencode/skills/git-workflow-pr/tasks/review-prep.md`
- `.opencode/skills/git-workflow-branch/tasks/operating-protocol.md`
- `.opencode/guidelines/115-branch-naming.md`
- `.opencode/skills/git-workflow-pr/tasks/pr-creation/squash-push.md`
- `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md`
- `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`
- `.opencode/skills/finishing-a-development-branch/tasks/prepare.md`
- `.opencode/tests-v2/behaviors/commit-trailer-placement.sh` (new)
- `.opencode/tests-v2/behaviors/commit-count-squash-timing.sh` (new)
- `.opencode/tests-v2/behaviors/squash-dual-trailer.sh` (new)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Reconcile co-author trailer placement | `test-driven-development` | `red` → `green` → `verify` → `commit-inline` | `.guidelines/commit-workflow.md`, `git-workflow-commit/tasks/commit-prep.md`, `git-workflow-commit/tasks/implementation.md`, `writing-plans/reference/implementation-workflow.md` | SC-1a, SC-1b | — |
| 2 — Reconcile commit-count rule | `test-driven-development` | `red` → `green` → `verify` → `commit-inline` | `000-critical-rules.md`, `git-workflow-commit/tasks/implementation.md`, `git-workflow-commit/SKILL.md`, `git-workflow-pr/tasks/pr-creation.md`, `git-workflow-pr/tasks/review-prep.md`, `git-workflow-branch/tasks/operating-protocol.md`, `115-branch-naming.md` | SC-2a, SC-2b | — |
| 3 — Establish canonical rule consistency | `test-driven-development` | `red` → `green` → `verify` → `commit-inline` | `git-workflow-pr/tasks/pr-creation.md`, `squash-push.md`, `enforcement-gate.md`, `finishing-a-development-branch/tasks/checklist.md`, `prepare.md` | SC-3a, SC-3b | 1, 2 |

---

## Phase Details

### Phase 1 — Reconcile co-author trailer placement on implementation vs squashed commits

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` → `green` → `verify` → `commit-inline` |
| Target | `.guidelines/commit-workflow.md`, `git-workflow-commit/tasks/commit-prep.md`, `git-workflow-commit/tasks/implementation.md`, `writing-plans/reference/implementation-workflow.md` |
| SCs | SC-1a, SC-1b |
| Depends On | — |

**Context:**
```yaml
behavioral_test: .opencode/tests-v2/behaviors/commit-trailer-placement.sh
contradictory_sources:
  - .opencode/.guidelines/commit-workflow.md
  - .opencode/skills/git-workflow-commit/tasks/commit-prep.md
  - .opencode/skills/git-workflow-commit/tasks/implementation.md
  - .opencode/skills/writing-plans/reference/implementation-workflow.md
sc_ids: [SC-1a, SC-1b]
```

- [ ] Step 1: Read the four contradictory sources to identify where each currently states the co-author trailer requirement on implementation commits.
- [ ] Step 2: Write a RED behavioral enforcement test at `.opencode/tests-v2/behaviors/commit-trailer-placement.sh` that runs `bash .opencode/tests-v2/with-test-home opencode run '<message>'` and asserts stderr shows the agent does NOT add co-author trailers to an implementation commit (SC-1a) and DOES add dual co-author trailers (AI + human) to the squashed commit (SC-1b). The test must fail initially because the contradictory sources require trailers on implementation commits.
- [ ] Step 3: Implement the GREEN change — update the four contradictory sources to state that no co-author trailers are required on intermediate implementation/WIP commits and that dual co-author trailers (AI + human) are required on the final squashed commit.
- [ ] Step 4: Run `verify` on the GREEN change — confirm the RED test now passes for both SC-1a and SC-1b.
- [ ] Step 5: Squash-commit via `commit-inline` with message `fix(git-workflow): reconcile co-author trailer placement on implementation vs squashed commits (#2426 SC-1a SC-1b)`.

### Phase 2 — Reconcile commit-count rule (multiple WIP commits acceptable, squash at PR)

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` → `green` → `verify` → `commit-inline` |
| Target | `000-critical-rules.md`, `git-workflow-commit/tasks/implementation.md`, `git-workflow-commit/SKILL.md`, `git-workflow-pr/tasks/pr-creation.md`, `git-workflow-pr/tasks/review-prep.md`, `git-workflow-branch/tasks/operating-protocol.md`, `115-branch-naming.md` |
| SCs | SC-2a, SC-2b |
| Depends On | — (independent of Phase 1) |

**Context:**
```yaml
behavioral_test: .opencode/tests-v2/behaviors/commit-count-squash-timing.sh
commit_count_sources:
  - .opencode/guidelines/000-critical-rules.md
  - .opencode/skills/git-workflow-commit/tasks/implementation.md
  - .opencode/skills/git-workflow-commit/SKILL.md
  - .opencode/skills/git-workflow-pr/tasks/pr-creation.md
  - .opencode/skills/git-workflow-pr/tasks/review-prep.md
  - .opencode/skills/git-workflow-branch/tasks/operating-protocol.md
  - .opencode/guidelines/115-branch-naming.md
sc_ids: [SC-2a, SC-2b]
```

- [ ] Step 1: Read the seven commit-count sources to identify where each currently states the commit-count rule.
- [ ] Step 2: Write a RED behavioral enforcement test at `.opencode/tests-v2/behaviors/commit-count-squash-timing.sh` that runs `bash .opencode/tests-v2/with-test-home opencode run '<message>'` and asserts stderr shows the agent makes multiple WIP commits during development (SC-2a) and defers squash to PR creation (SC-2b). The test must fail initially because the sources conflict on commit count.
- [ ] Step 3: Implement the GREEN change — update the seven commit-count sources to state that multiple WIP commits during development are acceptable and that squash to exactly one commit per issue occurs at PR creation.
- [ ] Step 4: Run `verify` on the GREEN change — confirm the RED test now passes for both SC-2a and SC-2b.
- [ ] Step 5: Squash-commit via `commit-inline` with message `fix(git-workflow): reconcile commit-count rule to multiple WIP commits with squash at PR (#2426 SC-2a SC-2b)`.

### Phase 3 — Establish canonical rule (one squashed commit per issue with dual trailers) consistently across gates

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` → `green` → `verify` → `commit-inline` |
| Target | `git-workflow-pr/tasks/pr-creation.md`, `squash-push.md`, `enforcement-gate.md`, `finishing-a-development-branch/tasks/checklist.md`, `prepare.md` |
| SCs | SC-3a, SC-3b |
| Depends On | 1, 2 |

**Context:**
```yaml
behavioral_test: .opencode/tests-v2/behaviors/squash-dual-trailer.sh
canonical_gate_files:
  - .opencode/skills/git-workflow-pr/tasks/pr-creation.md
  - .opencode/skills/git-workflow-pr/tasks/pr-creation/squash-push.md
  - .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md
  - .opencode/skills/finishing-a-development-branch/tasks/checklist.md
  - .opencode/skills/finishing-a-development-branch/tasks/prepare.md
sc_ids: [SC-3a, SC-3b]
```

- [ ] Step 1: Read the five canonical gate files to identify where each currently states the one-squashed-commit-per-issue and dual-trailer rules.
- [ ] Step 2: Write a RED behavioral enforcement test at `.opencode/tests-v2/behaviors/squash-dual-trailer.sh` that runs `bash .opencode/tests-v2/with-test-home opencode run '<message>'` and asserts stderr shows the agent produces exactly one squashed commit per issue (SC-3a) and adds dual co-author trailers (AI + human) to the squashed commit (SC-3b). The test must fail initially because the canonical rule is not stated consistently across the gates.
- [ ] Step 3: Implement the GREEN change — ensure the canonical rule (exactly one squashed commit per issue with dual co-author trailers) is stated consistently across the five gate files.
- [ ] Step 4: Run `verify` on the GREEN change — confirm the RED test now passes for both SC-3a and SC-3b.
- [ ] Step 5: Squash-commit via `commit-inline` with message `fix(git-workflow): state canonical one-squashed-commit-per-issue with dual trailers consistently across gates (#2426 SC-3a SC-3b)`.

---

## Exit Criteria

| Criterion | Description | Phase |
|-----------|-------------|-------|
| C1 | The four contradictory sources state no co-author trailers on implementation/WIP commits and dual trailers on the squashed commit | 1 |
| C2 | The seven commit-count sources state multiple WIP commits during dev and squash to one per issue at PR | 2 |
| C3 | The five canonical gate files state the one-squashed-commit-per-issue rule consistently | 3 |
| C4 | The five canonical gate files state the dual-trailer-on-squashed-commit rule consistently | 3 |
| C5 | All three behavioral tests pass (commit-trailer-placement, commit-count-squash-timing, squash-dual-trailer) | 1, 2, 3 |
| C6 | The stacked-PR organization rule (one branch, N commits, one PR) is preserved unchanged | 1, 2, 3 |

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-31T23:00:00Z | `plan_created` | Plan index at `.opencode/.issues/2426/plan.md` — 3 phases, 6 SCs |
| 2026-09-01T03:55:57Z | `plan_created` | Plan verified at `.opencode/.issues/2426/plan.md` — 3 phases, 6 SCs |

Co-authored with AI: OpenCode (deepseek-v4-flash)
