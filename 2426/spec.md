---
title: "[SPEC] Reconcile commit co-author trailer and squash-to-one-commit rules"
remote_issue: 2426
remote_url: https://github.com/michael-conrad/.opencode/issues/2426
promoted_at: 2026-08-31T22:50:00Z
labels:
  - needs-approval
  - spec-draft
---

> **Full spec and artifacts: [`.opencode/.issues/2426/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2426)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2426/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The `.opencode` skill deck contains contradictory rules about (a) when co-author trailers are required vs forbidden on commits, and (b) how many commits a PR/branch should have (ONE clean commit vs one-per-item vs one-per-issue). These contradictions cause agents to enter deliberation loops during PR creation and to skip the squash-to-one-commit-per-issue step. |
| 2 | **Root Cause / Motivation** | `.guidelines/commit-workflow.md:23` and `git-workflow-commit/tasks/commit-prep.md:34` require TWO co-author trailers on every implementation commit, while `git-workflow-commit/tasks/implementation.md:60` and `writing-plans/reference/implementation-workflow.md:51` state no trailers are required during implementation (added at squash). Similarly, `000-critical-rules.md:173` states one commit per issue while `implementation.md:105-115` permits multiple implementation commits during dev. The canonical rule (dual trailers on the squashed commit, one squashed commit per issue) already exists in the PR-creation files but is not propagated to the contradictory sources. |
| 3 | **Approach Chosen** | Reconcile the contradictory sources to align with the canonical rule: no co-author trailers on intermediate implementation/WIP commits; dual co-author trailers (AI + human) on the final squashed commit; multiple WIP commits during dev acceptable, squashed to exactly one commit per issue at PR creation. Consolidate the canonical rule consistently across the PR/squash/enforcement/finishing gates. |
| 4 | **Alternatives Considered & Why Discarded** | **Alternative: require trailers on every implementation commit.** Discarded because it contradicts the established squash-at-PR workflow and the existing `implementation.md:110` table (implementation=None, squash=Full), and would add trailer noise to every WIP commit. |
| 5 | **Key Design Decisions** | (1) Trailer placement is a binary distinction: implementation commits carry no trailers, the squashed commit carries dual trailers. (2) Commit count is a timing distinction: multiple WIP commits during dev, exactly one squashed commit per issue at PR. (3) The stacked-PR organization rule (one branch, N commits, one PR) is orthogonal and preserved unchanged. |
| 6 | **User Intent / Original Prompt** | Reconcile the contradictory commit co-author trailer and squash-to-one-commit rules in the `.opencode` skill deck so agents stop deliberating and consistently produce one squashed commit per issue with dual co-author trailers. |

## 2. Not Included

- **[Implementation of the reconciliation]** — This spec defines the reconciliation; editing the affected files is a separate downstream implementation step.
- **[Stacked-PR organization rule]** — The `critical-rules-PR-ORG` rule (one branch, N commits, one PR) is orthogonal and must be preserved unchanged.
- **[Application source code]** — Changes are confined to the `.opencode` skill deck (guidelines, skill task files, reference files); no application source code is touched.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1a | The four contradictory sources (`.guidelines/commit-workflow.md`, `git-workflow-commit/tasks/commit-prep.md`, `git-workflow-commit/tasks/implementation.md`, `writing-plans/reference/implementation-workflow.md`) SHALL state that no co-author trailers are required on intermediate implementation/WIP commits. | behavioral | Run `.opencode/tests-v2/behaviors/commit-trailer-placement.sh` via `bash .opencode/tests-v2/with-test-home opencode run '<message>'`; assert stderr shows the agent does NOT add co-author trailers to an implementation commit. |
| SC-1b | The four contradictory sources (`.guidelines/commit-workflow.md`, `git-workflow-commit/tasks/commit-prep.md`, `git-workflow-commit/tasks/implementation.md`, `writing-plans/reference/implementation-workflow.md`) SHALL state that dual co-author trailers (AI + human) are required on the final squashed commit. | behavioral | Run `.opencode/tests-v2/behaviors/commit-trailer-placement.sh` via `bash .opencode/tests-v2/with-test-home opencode run '<message>'`; assert stderr shows the agent DOES add dual co-author trailers (AI + human) to the squashed commit. |
| SC-2a | The commit-count sources (`000-critical-rules.md`, `git-workflow-commit/tasks/implementation.md`, `git-workflow-commit/SKILL.md`, `git-workflow-pr/tasks/pr-creation.md`, `git-workflow-pr/tasks/review-prep.md`, `git-workflow-branch/tasks/operating-protocol.md`, `115-branch-naming.md`) SHALL state that multiple WIP commits during development are acceptable. | behavioral | Run `.opencode/tests-v2/behaviors/commit-count-squash-timing.sh` via `with-test-home opencode run`; assert stderr shows the agent makes multiple WIP commits during development. |
| SC-2b | The commit-count sources (`000-critical-rules.md`, `git-workflow-commit/tasks/implementation.md`, `git-workflow-commit/SKILL.md`, `git-workflow-pr/tasks/pr-creation.md`, `git-workflow-pr/tasks/review-prep.md`, `git-workflow-branch/tasks/operating-protocol.md`, `115-branch-naming.md`) SHALL state that squash to exactly one commit per issue occurs at PR creation. | behavioral | Run `.opencode/tests-v2/behaviors/commit-count-squash-timing.sh` via `with-test-home opencode run`; assert stderr shows the agent defers squash to PR creation. |
| SC-3a | The canonical rule (exactly one squashed commit per issue) SHALL be stated consistently across the PR/squash/enforcement/finishing gates (`git-workflow-pr/tasks/pr-creation.md`, `squash-push.md`, `enforcement-gate.md`, `finishing-a-development-branch/tasks/checklist.md`, `prepare.md`). | behavioral | Run `.opencode/tests-v2/behaviors/squash-dual-trailer.sh` via `with-test-home opencode run`; assert stderr shows the agent produces exactly one squashed commit per issue (commit-count dimension). |
| SC-3b | The canonical rule (dual co-author trailers on the squashed commit) SHALL be stated consistently across the PR/squash/enforcement/finishing gates (`git-workflow-pr/tasks/pr-creation.md`, `squash-push.md`, `enforcement-gate.md`, `finishing-a-development-branch/tasks/checklist.md`, `prepare.md`). | behavioral | Run `.opencode/tests-v2/behaviors/squash-dual-trailer.sh` via `with-test-home opencode run`; assert stderr shows the agent adds dual co-author trailers (AI + human) to the squashed commit (trailer-placement dimension). |

## 4. Requirements

- R-1. The system SHALL require no co-author trailers on intermediate implementation/WIP commits.
- R-2. The system SHALL require dual co-author trailers (AI + human) on the final squashed commit.
- R-3. The system SHALL permit multiple WIP/implementation commits during development.
- R-4. The system SHALL squash to exactly one commit per issue at PR creation.
- R-5. The system SHALL preserve the stacked-PR organization rule (one branch, N commits, one PR) unchanged.
- R-6. The system SHOULD state the canonical rule consistently across all PR/squash/enforcement/finishing gates.

## 5. Items

### Item 1 (SC-1a, SC-1b): Reconcile co-author trailer requirement on implementation commits

- RED: Behavioral test asserts the agent does NOT add co-author trailers to implementation commits (currently fails because contradictory sources require them).
- GREEN: Update the four contradictory sources to state no trailers on implementation commits, dual trailers on the squashed commit.
- verify: Run `commit-trailer-placement.sh`; assert stderr shows the agent omits trailers on implementation commits (SC-1a) and adds dual co-author trailers to the squashed commit (SC-1b).
- commit: The four affected source files plus the behavioral test.

### Item 2 (SC-2a, SC-2b): Reconcile commit-count rule (one-per-issue squash)

- RED: Behavioral test asserts the agent does NOT squash during implementation (currently fails because sources conflict on commit count).
- GREEN: Update the commit-count sources to state multiple WIP commits during dev, squash to one per issue at PR.
- verify: Run `commit-count-squash-timing.sh`; assert stderr shows the agent makes multiple WIP commits during dev (SC-2a) and defers squash to PR creation (SC-2b).
- commit: The seven affected source files plus the behavioral test.

### Item 3 (SC-3a, SC-3b): Establish canonical rule: exactly 1 squashed commit per issue with dual co-author trailers

- RED: Behavioral test asserts the agent produces exactly one squashed commit with dual co-author trailers (currently fails because the canonical rule is not consistently stated).
- GREEN: Ensure the canonical rule is stated consistently across the PR/squash/enforcement/finishing gates.
- verify: Run `squash-dual-trailer.sh`; assert stderr shows one squashed commit per issue (SC-3a) and dual co-author trailers on the squashed commit (SC-3b).
- commit: The five affected gate files plus the behavioral test.

## 6. Dependencies

- **Reference:** `multi-feature-branch-main-with-submodules` research card (confidence 0.7)
- **Relationship:** Confirms the stacked-PR pattern and squash-at-PR mechanism; partially supports the canonical one-squashed-commit-per-issue rule.
- **Status:** Satisfied (incorporated into the decomposition).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1a | Phase 1 |
| R-2 | SC-1b | Phase 1 |
| R-3 | SC-2a | Phase 2 |
| R-4 | SC-2b | Phase 2 |
| R-5, R-6 | SC-3a, SC-3b | Phase 3 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| commit-workflow guideline | code | `.opencode/.guidelines/commit-workflow.md` | read (contradictory source) |
| commit-prep task | code | `.opencode/skills/git-workflow-commit/tasks/commit-prep.md` | read (contradictory source) |
| implementation task | code | `.opencode/skills/git-workflow-commit/tasks/implementation.md` | read (aligned source) |
| implementation-workflow reference | code | `.opencode/skills/writing-plans/reference/implementation-workflow.md` | read (aligned source) |
| critical-rules commit-count | code | `.opencode/guidelines/000-critical-rules.md` | read (commit-count source) |
| git-workflow-commit SKILL.md | code | `.opencode/skills/git-workflow-commit/SKILL.md` | read (commit-count source) |
| pr-creation task | code | `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` | read (canonical-aligned) |
| squash-push task | code | `.opencode/skills/git-workflow-pr/tasks/pr-creation/squash-push.md` | read (canonical-aligned) |
| enforcement-gate task | code | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` | read (canonical-aligned) |
| finishing checklist/prepare | code | `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`, `prepare.md` | read (canonical-aligned) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1a: Running the behavioral trailer-placement test costs minutes of execution time. Skipping means the contradictory trailer rule ships unchanged and agents keep adding trailers to WIP commits, surfacing as a behavioral defect in production at 1000× the fix cost.
- SC-1b: Running the behavioral trailer-placement test costs minutes of execution time. Skipping means the dual-trailer-on-squashed-commit rule is not enforced and agents ship squashed commits without proper co-author trailers, surfacing as a behavioral defect at 1000× the fix cost.
- SC-2a: Running the behavioral commit-count test costs minutes of execution time. Skipping means the commit-count contradiction persists and agents keep squashing during dev, surfacing as a behavioral defect at 1000× the fix cost.
- SC-2b: Running the behavioral commit-count test costs minutes of execution time. Skipping means the per-issue squash step is skipped and agents produce multiple commits per issue, surfacing as a behavioral defect at 1000× the fix cost.
- SC-3a: Running the behavioral squash-dual-trailer test costs minutes of execution time. Skipping means the canonical one-squashed-commit-per-issue rule is not consistently enforced and agents produce multiple commits per issue, surfacing as a behavioral defect at 1000× the fix cost.
- SC-3b: Running the behavioral squash-dual-trailer test costs minutes of execution time. Skipping means the canonical dual-trailer-on-squashed-commit rule is not consistently enforced and agents ship squashed commits without proper co-author trailers, surfacing as a behavioral defect at 1000× the fix cost.

## 11. Edge Cases

- **Input boundaries:** Empty commit message, single-commit branch, and multi-commit branch all SHALL resolve to exactly one squashed commit per issue at PR.
- **State transitions:** `implementation-commit` (no trailers) → `squashed-commit` (dual trailers) → `merged-commit` (dual trailers preserved). The transition trigger is PR creation (squash-push).
- **Failure modes:** If a source still requires trailers on implementation commits after reconciliation, the behavioral test SHALL fail, surfacing the residual contradiction.
- **Concurrency:** Phase 1 (trailer placement, SC-1a/SC-1b) and Phase 2 (commit count, SC-2a/SC-2b) are independent and may run in parallel; Phase 3 (canonical rule, SC-3a/SC-3b) depends on both.
- **Recovery:** If a behavioral test fails, the affected source is re-reconciled and the test re-run until it passes.

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-31 | Decomposed SC-1 into SC-1a (no trailers on implementation/WIP commits) and SC-1b (dual AI + human trailers on the squashed commit); decomposed SC-2 into SC-2a (multiple WIP commits during dev acceptable) and SC-2b (squash to one commit per issue at PR creation). Each atomic SC now has its own verification method. Updated Items, Traceability, Cost Frame, Edge Cases, and sc-summary.yaml accordingly. | Validation finding: SC-1 and SC-2 were compound SCs bundling two distinct verification targets via 'and'; SC-1's verification method only covered the implementation-commit trailer claim, leaving the squashed-commit dual-trailer claim unverified. | spec-creation validation gate |
| 2026-08-31 | Decomposed SC-3 into SC-3a (canonical rule stated consistently across gates — commit-count dimension) and SC-3b (canonical rule stated consistently across gates — trailer-placement dimension), each with its own verification method. Updated Items, Traceability, Cost Frame, Edge Cases, and sc-summary.yaml accordingly. | Validation finding: SC-3 was a compound SC re-bundling commit-count and trailer-placement verification targets via 'with' — the same pattern the Change Control note decomposed SC-1/SC-2 for. SC-3 failed Atomicity and Coverage decomposition criteria. | spec-creation validation gate |

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
