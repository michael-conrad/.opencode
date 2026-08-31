---
title: '[SPEC-FIX] Skill deck workflow/contract defects: dispatch contract mismatches and task-card-internal-dispatch'
status: open
labels:
- needs-approval
- spec-draft
---

> **Full spec and artifacts: [`.opencode/.issues/2410/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2410)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2410/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Skill Deck Workflow/Contract Defects Remediation

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The `skildeck lint` scan of the skill deck confirms two classes of workflow/contract defects that break orchestrator→sub-agent routing: (1) dispatch contract mismatches where SKILL.md dispatch steps declare a Returns/Context contract that disagrees with the target task card's actual Result Contract / required context, and (2) task-card-internal-dispatch (22 findings) where task cards embed internal `task()`/`skill({)` dispatch instructions. |
| 2 | **Root Cause / Motivation** | SKILL.md Workflows Returns/Context sub-bullets were authored independently of the task-card Result Contract / Entry Criteria, so they drifted. Task cards were written with embedded dispatch instructions that violate the clean-room unit rule and the skill-card/task-card division of labor. These defects must be fixed now because they cause orchestrator routing failures and sub-agent re-dispatch loops that waste context and produce defective work. |
| 3 | **Approach Chosen** | Align each mismatched SKILL.md dispatch contract with its target task card's authoritative Result Contract / required Context — the task card is the execution procedure, so it is the source of truth — or vice versa where the SKILL.md is correct. Add missing required context fields (`approved`, `merged_at`). For task-card-internal-dispatch findings, replace embedded `task()`/`skill({)` dispatch instructions with orchestrator-routing markers so sub-agents execute single clean-room units and the orchestrator alone performs dispatch. |
| 4 | **Alternatives Considered & Why Discarded** | **Alternative: modify the skildeck lint to suppress the finding classes.** Discarded — the lint correctly detects genuine contract mismatches and internal dispatch; suppressing the signal would mask real defects and violate the test-integrity mandate. The correct fix is to repair the skill deck, not weaken the gate. |
| 5 | **Key Design Decisions** | (1) The task card is the authoritative source for the execution procedure; SKILL.md Workflows Returns/Context must match it. (2) Lint false-positives (BLOCK reasons, git remote names, prose mentions of `task(`) are remediated by rewording, not by adding context or changing behavior. (3) Each task-card fix lands as one commit per task card. |
| 6 | **User Intent / Original Prompt** | Bug report #2410: "Skill deck workflow/contract defects: dispatch contract mismatches (git-workflow-*, writing-plans) and task-card-internal-dispatch (22 findings)". |

## 2. Not Included

- **[skildeck CLI tooling defects (#2408)]** — tracked separately; out of scope for this remediation.
- **[Broken dispatch references (#2409)]** — tracked separately.
- **[TDT/Invocation incompleteness (#2407)]** — tracked separately.
- **[Guideline broken references (#2406)]** — tracked separately.
- **[git-workflow-conflict dispatch context contract mismatch (#2381)]** — already reported; out of scope.
- **[writing-plans create→validate contract mismatch (#2343)]** — already reported; out of scope.
- **[Skill card content restructuring]** — beyond the contract/context fields and internal-dispatch lines flagged here; out of scope.

## 3. Success Criteria

The SC table uses exactly the 4 canonical columns (ID, Criterion, Evidence Type, Verification Method) mandated by `spec-structure-standards.md`. Documentation sources are covered by the separate section 8, not by an additional SC-table column. Each SC is atomic — it maps to exactly one step or one task-card group and is independently verifiable. All SCs declare evidence type `behavioral` because verification is `skildeck lint` output inspection (test execution with output inspection), per the canonical evidence type taxonomy in `cost-model-standards.md`.

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The `git-workflow-branch` SKILL.md "Verify remote trunk tip" step Returns contract SHALL match the `trunk-tip-verification.md` Result Contract `{status, checks, blocker_reason}`. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for the git-workflow-branch "Verify remote trunk tip" step |
| SC-2 | The `git-workflow-branch` SKILL.md "Pair pre-work" step Returns contract SHALL match its task-card Result Contract. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for the git-workflow-branch "Pair pre-work" step |
| SC-3 | The `git-workflow-branch` SKILL.md "Pair mode resume" step Returns contract SHALL match its task-card Result Contract. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for the git-workflow-branch "Pair mode resume" step |
| SC-4 | The `git-workflow-branch` SKILL.md "Pre-work" Context SHALL include the `approved` field required by `pre-work.md` Entry Criteria. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-incomplete` findings for the git-workflow-branch "Pre-work" step |
| SC-5 | The `git-workflow-cleanup` SKILL.md "pair-cleanup" step Returns contract SHALL match its task-card Result Contract. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for the git-workflow-cleanup "pair-cleanup" step |
| SC-6 | The `git-workflow-commit` SKILL.md "pair-commit" step Returns contract SHALL match its task-card Result Contract. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for the git-workflow-commit "pair-commit" step |
| SC-7 | The `git-workflow-pr` SKILL.md "pair-pr-creation" step Returns contract SHALL match its task-card Result Contract. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for the git-workflow-pr "pair-pr-creation" step |
| SC-8 | The `git-workflow-pr` SKILL.md "completion" step Returns contract SHALL match its task-card Result Contract. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for the git-workflow-pr "completion" step |
| SC-9 | The `git-workflow-conflict` SKILL.md "Rebase pending" Context SHALL include the `merged_at` field required by `rebase-pending.md` Entry Criteria. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-incomplete` findings for the git-workflow-conflict "Rebase pending" step |
| SC-10 | The `writing-plans/tasks/analyze.md` Entry Criteria SHALL be reworded so the `SPEC_NOT_FOUND` and `SPEC_NOT_APPROVED` BLOCK reason tokens are no longer flagged as required context parameters. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-incomplete` findings for the writing-plans "analyze" step |
| SC-11 | The `git-workflow-branch/tasks/pre-work.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `git-workflow-branch/tasks/pre-work.md` |
| SC-12 | The `git-workflow-pr/tasks/pr-creation.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `git-workflow-pr/tasks/pr-creation.md` |
| SC-13 | The `issue-operations-comments` task cards SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for the `issue-operations-comments` task cards |
| SC-14 | The `issue-operations-core/tasks/body-edit.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `issue-operations-core/tasks/body-edit.md` |
| SC-15 | The `issue-operations-core/tasks/close.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `issue-operations-core/tasks/close.md` |
| SC-16 | The `issue-operations-core/tasks/creation.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `issue-operations-core/tasks/creation.md` |
| SC-17 | The `issue-operations-core/tasks/list-issues.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `issue-operations-core/tasks/list-issues.md` |
| SC-18 | The `issue-operations-core/tasks/read-comments.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `issue-operations-core/tasks/read-comments.md` |
| SC-19 | The `issue-operations-core/tasks/read-issue.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `issue-operations-core/tasks/read-issue.md` |
| SC-20 | The `issue-operations-core/tasks/read-labels.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `issue-operations-core/tasks/read-labels.md` |
| SC-21 | The `issue-operations-core/tasks/search-issues.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `issue-operations-core/tasks/search-issues.md` |
| SC-22 | The `issue-operations-core/tasks/update-issue.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `issue-operations-core/tasks/update-issue.md` |
| SC-23 | The `issue-operations-sub-issues/tasks/link-sub-issue.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `issue-operations-sub-issues/tasks/link-sub-issue.md` |
| SC-24 | The `issue-operations-sub-issues/tasks/read-sub-issues.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `issue-operations-sub-issues/tasks/read-sub-issues.md` |
| SC-25 | The `issue-operations-sync/tasks/import-remote.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `issue-operations-sync/tasks/import-remote.md` |
| SC-26 | The `issue-operations-sync/tasks/sync-pull-to-local.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `issue-operations-sync/tasks/sync-pull-to-local.md` |
| SC-27 | The `issue-review/tasks/audit.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions and no prose that triggers the lint token pattern. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `issue-review/tasks/audit.md` |
| SC-28 | The `sre-runbook/tasks/track.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions and no prose that triggers the lint token pattern. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `sre-runbook/tasks/track.md` |
| SC-29 | The `multimodal-dispatch/tasks/completion.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions and no prose that triggers the lint token pattern. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `multimodal-dispatch/tasks/completion.md` |
| SC-30 | The `multimodal-dispatch/tasks/dispatch.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions and no prose that triggers the lint token pattern. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `multimodal-dispatch/tasks/dispatch.md` |
| SC-31 | The `pre-analysis/tasks/analyze.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions and no prose that triggers the lint token pattern. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `pre-analysis/tasks/analyze.md` |
| SC-32 | The `verification/tasks/verify.md` task card SHALL contain no embedded `task()`/`skill({)` dispatch instructions and no prose that triggers the lint token pattern. | behavioral | `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for `verification/tasks/verify.md` |

## 4. Requirements

- R-1. The `git-workflow-branch` SKILL.md "Verify remote trunk tip" step SHALL declare a Returns contract matching the `trunk-tip-verification.md` Result Contract.
- R-2. The `git-workflow-branch` SKILL.md "Pair pre-work" and "Pair mode resume" steps SHALL declare Returns contracts matching their task-card Result Contracts.
- R-3. The `git-workflow-branch` SKILL.md "Pre-work" step SHALL pass the `approved` context field required by `pre-work.md` Entry Criteria.
- R-4. The `git-workflow-cleanup`, `git-workflow-commit`, and `git-workflow-pr` SKILL.md steps SHALL declare Returns contracts matching their task-card Result Contracts.
- R-5. The `git-workflow-conflict` SKILL.md "Rebase pending" step SHALL pass the `merged_at` context field required by `rebase-pending.md` Entry Criteria.
- R-6. The `writing-plans/tasks/analyze.md` Entry Criteria SHALL be reworded to avoid backtick-quoting the `SPEC_NOT_FOUND` and `SPEC_NOT_APPROVED` BLOCK reason tokens.
- R-7. Task cards SHALL NOT embed `task()`/`skill({)` dispatch instructions; the orchestrator alone SHALL perform dispatch.
- R-8. Each task-card fix SHALL land as one commit per task card, with a RED/GREEN behavioral check where the contract shape is observable.
- R-9. Lint false-positives (BLOCK reasons, git remote names, prose mentions of `task(`) SHALL be remediated by rewording, not by adding context or changing behavior.
- R-10. Each task-card-internal-dispatch remediation SHALL be tracked as one SC per task-card file, so each fix is individually verifiable and reviewable as a single deliverable.

## 5. Items

### Item 1 (SC-1): Align git-workflow-branch "Verify remote trunk tip" Returns contract

- RED: `skildeck lint` shows `dispatch-contract-result-mismatch` for the git-workflow-branch "Verify remote trunk tip" step.
- GREEN: Update `git-workflow-branch/SKILL.md` "Verify remote trunk tip" Returns to `{status, checks, blocker_reason}`.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for this step.
- commit: `git-workflow-branch/SKILL.md` Returns alignment.

### Item 2 (SC-2): Align git-workflow-branch "Pair pre-work" Returns contract

- RED: `skildeck lint` shows `dispatch-contract-result-mismatch` for the git-workflow-branch "Pair pre-work" step.
- GREEN: Update `git-workflow-branch/SKILL.md` "Pair pre-work" Returns to match its task-card Result Contract.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for this step.
- commit: `git-workflow-branch/SKILL.md` "Pair pre-work" Returns alignment.

### Item 3 (SC-3): Align git-workflow-branch "Pair mode resume" Returns contract

- RED: `skildeck lint` shows `dispatch-contract-result-mismatch` for the git-workflow-branch "Pair mode resume" step.
- GREEN: Update `git-workflow-branch/SKILL.md` "Pair mode resume" Returns to match its task-card Result Contract.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for this step.
- commit: `git-workflow-branch/SKILL.md` "Pair mode resume" Returns alignment.

### Item 4 (SC-4): Add 'approved' to git-workflow-branch "Pre-work" Context

- RED: `skildeck lint` shows `dispatch-contract-incomplete` for the git-workflow-branch "Pre-work" step.
- GREEN: Add the `approved` field to the `git-workflow-branch/SKILL.md` "Pre-work" Context.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-incomplete` findings for this step.
- commit: `git-workflow-branch/SKILL.md` Context alignment.

### Item 5 (SC-5): Align git-workflow-cleanup "pair-cleanup" Returns contract

- RED: `skildeck lint` shows `dispatch-contract-result-mismatch` for the git-workflow-cleanup "pair-cleanup" step.
- GREEN: Align the `git-workflow-cleanup/SKILL.md` "pair-cleanup" Returns contract with its task-card Result Contract.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for this step.
- commit: `git-workflow-cleanup/SKILL.md` Returns alignment.

### Item 6 (SC-6): Align git-workflow-commit "pair-commit" Returns contract

- RED: `skildeck lint` shows `dispatch-contract-result-mismatch` for the git-workflow-commit "pair-commit" step.
- GREEN: Align the `git-workflow-commit/SKILL.md` "pair-commit" Returns contract with its task-card Result Contract.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for this step.
- commit: `git-workflow-commit/SKILL.md` Returns alignment.

### Item 7 (SC-7): Align git-workflow-pr "pair-pr-creation" Returns contract

- RED: `skildeck lint` shows `dispatch-contract-result-mismatch` for the git-workflow-pr "pair-pr-creation" step.
- GREEN: Align the `git-workflow-pr/SKILL.md` "pair-pr-creation" Returns contract with its task-card Result Contract.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for this step.
- commit: `git-workflow-pr/SKILL.md` Returns alignment.

### Item 8 (SC-8): Align git-workflow-pr "completion" Returns contract

- RED: `skildeck lint` shows `dispatch-contract-result-mismatch` for the git-workflow-pr "completion" step.
- GREEN: Align the `git-workflow-pr/SKILL.md` "completion" Returns contract with its task-card Result Contract.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-result-mismatch` findings for this step.
- commit: `git-workflow-pr/SKILL.md` Returns alignment.

### Item 9 (SC-9): Resolve git-workflow-conflict "Rebase pending" merged_at context

- RED: `skildeck lint` shows `dispatch-contract-incomplete` for the git-workflow-conflict "Rebase pending" step.
- GREEN: Add the `merged_at` field to the `git-workflow-conflict/SKILL.md` "Rebase pending" Context.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-incomplete` findings for this step.
- commit: `git-workflow-conflict/SKILL.md` Context alignment.

### Item 10 (SC-10): Resolve writing-plans 'analyze' SPEC_NOT_FOUND/SPEC_NOT_APPROVED false-positives

- RED: `skildeck lint` shows `dispatch-contract-incomplete` for the writing-plans "analyze" step.
- GREEN: Reword `writing-plans/tasks/analyze.md` Entry Criteria to avoid backtick-quoting the BLOCK reason tokens.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `dispatch-contract-incomplete` findings for this step.
- commit: `writing-plans/tasks/analyze.md` Entry Criteria rewording.

### Item 11 (SC-11): Remediate git-workflow-branch pre-work task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `git-workflow-branch/tasks/pre-work.md`.
- GREEN: Replace embedded `task()` dispatch instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `git-workflow-branch/tasks/pre-work.md`.

### Item 12 (SC-12): Remediate git-workflow-pr pr-creation task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `git-workflow-pr/tasks/pr-creation.md`.
- GREEN: Replace embedded `task()` dispatch instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `git-workflow-pr/tasks/pr-creation.md`.

### Item 13 (SC-13): Remediate issue-operations-comments task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for the `issue-operations-comments` task cards.
- GREEN: Replace embedded `task()` routing instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for these task cards.
- commit: One commit per task card.

### Item 14 (SC-14): Remediate issue-operations-core body-edit task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/body-edit.md`.
- GREEN: Replace embedded `task()` routing instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `issue-operations-core/tasks/body-edit.md`.

### Item 15 (SC-15): Remediate issue-operations-core close task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/close.md`.
- GREEN: Replace embedded `task()` routing instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `issue-operations-core/tasks/close.md`.

### Item 16 (SC-16): Remediate issue-operations-core creation task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/creation.md`.
- GREEN: Replace embedded `task()` routing instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `issue-operations-core/tasks/creation.md`.

### Item 17 (SC-17): Remediate issue-operations-core list-issues task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/list-issues.md`.
- GREEN: Replace embedded `task()` routing instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `issue-operations-core/tasks/list-issues.md`.

### Item 18 (SC-18): Remediate issue-operations-core read-comments task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/read-comments.md`.
- GREEN: Replace embedded `task()` routing instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `issue-operations-core/tasks/read-comments.md`.

### Item 19 (SC-19): Remediate issue-operations-core read-issue task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/read-issue.md`.
- GREEN: Replace embedded `task()` routing instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `issue-operations-core/tasks/read-issue.md`.

### Item 20 (SC-20): Remediate issue-operations-core read-labels task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/read-labels.md`.
- GREEN: Replace embedded `task()` routing instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `issue-operations-core/tasks/read-labels.md`.

### Item 21 (SC-21): Remediate issue-operations-core search-issues task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/search-issues.md`.
- GREEN: Replace embedded `task()` routing instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `issue-operations-core/tasks/search-issues.md`.

### Item 22 (SC-22): Remediate issue-operations-core update-issue task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-core/tasks/update-issue.md`.
- GREEN: Replace embedded `task()` routing instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `issue-operations-core/tasks/update-issue.md`.

### Item 23 (SC-23): Remediate issue-operations-sub-issues link-sub-issue task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-sub-issues/tasks/link-sub-issue.md`.
- GREEN: Replace embedded `task()` routing instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `issue-operations-sub-issues/tasks/link-sub-issue.md`.

### Item 24 (SC-24): Remediate issue-operations-sub-issues read-sub-issues task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-sub-issues/tasks/read-sub-issues.md`.
- GREEN: Replace embedded `task()` routing instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `issue-operations-sub-issues/tasks/read-sub-issues.md`.

### Item 25 (SC-25): Remediate issue-operations-sync import-remote task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-sync/tasks/import-remote.md`.
- GREEN: Replace embedded `task()` routing instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `issue-operations-sync/tasks/import-remote.md`.

### Item 26 (SC-26): Remediate issue-operations-sync sync-pull-to-local task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `issue-operations-sync/tasks/sync-pull-to-local.md`.
- GREEN: Replace embedded `task()` routing instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `issue-operations-sync/tasks/sync-pull-to-local.md`.

### Item 27 (SC-27): Remediate issue-review audit task-card internal dispatch and prose mentions

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `issue-review/tasks/audit.md`.
- GREEN: Replace embedded dispatch in `issue-review/tasks/audit.md`; reword prose mentions that trigger the lint token pattern.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `issue-review/tasks/audit.md`.

### Item 28 (SC-28): Remediate sre-runbook track task-card internal dispatch and prose mentions

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `sre-runbook/tasks/track.md`.
- GREEN: Replace embedded dispatch in `sre-runbook/tasks/track.md`; reword prose mentions that trigger the lint token pattern.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `sre-runbook/tasks/track.md`.

### Item 29 (SC-29): Remediate multimodal-dispatch completion task-card internal dispatch and prose mentions

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `multimodal-dispatch/tasks/completion.md`.
- GREEN: Replace embedded dispatch in `multimodal-dispatch/tasks/completion.md`; reword prose mentions that trigger the lint token pattern.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `multimodal-dispatch/tasks/completion.md`.

### Item 30 (SC-30): Remediate multimodal-dispatch dispatch task-card internal dispatch and prose mentions

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `multimodal-dispatch/tasks/dispatch.md`.
- GREEN: Replace embedded dispatch in `multimodal-dispatch/tasks/dispatch.md`; reword prose mentions that trigger the lint token pattern.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `multimodal-dispatch/tasks/dispatch.md`.

### Item 31 (SC-31): Remediate pre-analysis analyze task-card internal dispatch and prose mentions

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `pre-analysis/tasks/analyze.md`.
- GREEN: Replace embedded dispatch in `pre-analysis/tasks/analyze.md`; reword prose mentions that trigger the lint token pattern.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `pre-analysis/tasks/analyze.md`.

### Item 32 (SC-32): Remediate verification verify task-card internal dispatch and prose mentions

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `verification/tasks/verify.md`.
- GREEN: Replace embedded dispatch in `verification/tasks/verify.md`; reword prose mentions that trigger the lint token pattern.
- verify: `./.opencode/tools/skildeck lint` output inspection shows zero `task-card-internal-dispatch` findings for this task card.
- commit: One commit for `verification/tasks/verify.md`.

## 6. Dependencies

- **Reference:** `skildeck` lint tool (`.opencode/tools/skildeck`)
  - **Relationship:** The `dispatch-contract-*` and `task-card-internal-dispatch` checks are the verification gate for every SC.
  - **Status:** Satisfied (tool present and runnable).
- **Reference:** `000-critical-rules.md` (skill-card/task-card division of labor)
  - **Relationship:** Governs the contract-alignment direction and the internal-dispatch remediation approach.
  - **Status:** Satisfied.
- **Reference:** `020-go-prohibitions.md` §1.1 (result contract frugality)
  - **Relationship:** Defines the canonical result-contract shape `{status, finding_summary, artifact_path, blocker_reason}`.
  - **Status:** Satisfied.

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2, SC-3 | Phase 1 |
| R-3 | SC-4 | Phase 1 |
| R-4 | SC-5, SC-6, SC-7, SC-8 | Phase 1 |
| R-5 | SC-9 | Phase 1 |
| R-6 | SC-10 | Phase 1 |
| R-7 | SC-11, SC-12, SC-13, SC-14, SC-15, SC-16, SC-17, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26, SC-27, SC-28, SC-29, SC-30, SC-31, SC-32 | Phase 2 |
| R-8 | SC-11, SC-12, SC-13, SC-14, SC-15, SC-16, SC-17, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26, SC-27, SC-28, SC-29, SC-30, SC-31, SC-32 | Phase 2 |
| R-9 | SC-10, SC-27, SC-28, SC-29, SC-30, SC-31, SC-32 | Phase 1, Phase 2 |
| R-10 | SC-14, SC-15, SC-16, SC-17, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26, SC-27, SC-28, SC-29, SC-30, SC-31, SC-32 | Phase 2 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| skildeck lint tool | code | `.opencode/tools/skildeck` | Live run `./.opencode/tools/skildeck lint` |
| skill-card/task-card division of labor | guideline | `.opencode/guidelines/000-critical-rules.md` | Read |
| result contract frugality | guideline | `.opencode/guidelines/020-go-prohibitions.md` §1.1 | Read |
| affected SKILL.md files | config | `.opencode/skills/*/SKILL.md` | Read / glob |
| affected task cards | config | `.opencode/skills/*/tasks/*.md` | Read / glob |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the Returns contract matches the task-card Result Contract costs one `skildeck lint` run. Skipping means the orchestrator routes with the wrong contract shape and downstream routing fails at review time.
- **SC-2:** Verifying the "Pair pre-work" Returns contract costs one `skildeck lint` run. Skipping means pair-mode routing defects ship to production and cost 1000× more to fix.
- **SC-3:** Verifying the "Pair mode resume" Returns contract costs one `skildeck lint` run. Skipping means pair-mode routing defects ship to production and cost 1000× more to fix.
- **SC-4:** Verifying the `approved` context field costs one `skildeck lint` run. Skipping means sub-agents BLOCK or self-authorize without the required authorization context.
- **SC-5:** Verifying the `git-workflow-cleanup` "pair-cleanup" Returns contract costs one `skildeck lint` run. Skipping means contract mismatches surface at review time.
- **SC-6:** Verifying the `git-workflow-commit` "pair-commit" Returns contract costs one `skildeck lint` run. Skipping means contract mismatches surface at review time.
- **SC-7:** Verifying the `git-workflow-pr` "pair-pr-creation" Returns contract costs one `skildeck lint` run. Skipping means contract mismatches surface at review time.
- **SC-8:** Verifying the `git-workflow-pr` "completion" Returns contract costs one `skildeck lint` run. Skipping means contract mismatches surface at review time.
- **SC-9:** Verifying the `merged_at` context field costs one `skildeck lint` run. Skipping means rebase-pending sub-agents lack the required timestamp context.
- **SC-10:** Verifying the Entry Criteria rewording costs one `skildeck lint` run. Skipping means the false-positive persists and masks genuine contract defects.
- **SC-11:** Verifying the `git-workflow-branch` pre-work task card contains no internal dispatch costs one `skildeck lint` run. Skipping means sub-agents re-dispatch, wasting context and violating clean-room isolation.
- **SC-12:** Verifying the `git-workflow-pr` pr-creation task card contains no internal dispatch costs one `skildeck lint` run. Skipping means sub-agents re-dispatch, wasting context and violating clean-room isolation.
- **SC-13:** Verifying the `issue-operations-comments` task cards contain no internal dispatch costs one `skildeck lint` run. Skipping means platform-routing sub-agents re-dispatch instead of executing.
- **SC-14:** Verifying the `issue-operations-core` body-edit task card contains no internal dispatch costs one `skildeck lint` run. Skipping means platform-routing sub-agents re-dispatch instead of executing.
- **SC-15:** Verifying the `issue-operations-core` close task card contains no internal dispatch costs one `skildeck lint` run. Skipping means platform-routing sub-agents re-dispatch instead of executing.
- **SC-16:** Verifying the `issue-operations-core` creation task card contains no internal dispatch costs one `skildeck lint` run. Skipping means platform-routing sub-agents re-dispatch instead of executing.
- **SC-17:** Verifying the `issue-operations-core` list-issues task card contains no internal dispatch costs one `skildeck lint` run. Skipping means platform-routing sub-agents re-dispatch instead of executing.
- **SC-18:** Verifying the `issue-operations-core` read-comments task card contains no internal dispatch costs one `skildeck lint` run. Skipping means platform-routing sub-agents re-dispatch instead of executing.
- **SC-19:** Verifying the `issue-operations-core` read-issue task card contains no internal dispatch costs one `skildeck lint` run. Skipping means platform-routing sub-agents re-dispatch instead of executing.
- **SC-20:** Verifying the `issue-operations-core` read-labels task card contains no internal dispatch costs one `skildeck lint` run. Skipping means platform-routing sub-agents re-dispatch instead of executing.
- **SC-21:** Verifying the `issue-operations-core` search-issues task card contains no internal dispatch costs one `skildeck lint` run. Skipping means platform-routing sub-agents re-dispatch instead of executing.
- **SC-22:** Verifying the `issue-operations-core` update-issue task card contains no internal dispatch costs one `skildeck lint` run. Skipping means platform-routing sub-agents re-dispatch instead of executing.
- **SC-23:** Verifying the `issue-operations-sub-issues` link-sub-issue task card contains no internal dispatch costs one `skildeck lint` run. Skipping means platform-routing sub-agents re-dispatch instead of executing.
- **SC-24:** Verifying the `issue-operations-sub-issues` read-sub-issues task card contains no internal dispatch costs one `skildeck lint` run. Skipping means platform-routing sub-agents re-dispatch instead of executing.
- **SC-25:** Verifying the `issue-operations-sync` import-remote task card contains no internal dispatch costs one `skildeck lint` run. Skipping means platform-routing sub-agents re-dispatch instead of executing.
- **SC-26:** Verifying the `issue-operations-sync` sync-pull-to-local task card contains no internal dispatch costs one `skildeck lint` run. Skipping means platform-routing sub-agents re-dispatch instead of executing.
- **SC-27:** Verifying the `issue-review` audit task card contains no internal dispatch costs one `skildeck lint` run. Skipping means prose mentions continue to trigger false-positive findings.
- **SC-28:** Verifying the `sre-runbook` track task card contains no internal dispatch costs one `skildeck lint` run. Skipping means prose mentions continue to trigger false-positive findings.
- **SC-29:** Verifying the `multimodal-dispatch` completion task card contains no internal dispatch costs one `skildeck lint` run. Skipping means prose mentions continue to trigger false-positive findings.
- **SC-30:** Verifying the `multimodal-dispatch` dispatch task card contains no internal dispatch costs one `skildeck lint` run. Skipping means prose mentions continue to trigger false-positive findings.
- **SC-31:** Verifying the `pre-analysis` analyze task card contains no internal dispatch costs one `skildeck lint` run. Skipping means prose mentions continue to trigger false-positive findings.
- **SC-32:** Verifying the `verification` verify task card contains no internal dispatch costs one `skildeck lint` run. Skipping means prose mentions continue to trigger false-positive findings.

## 11. Edge Cases

- **Input boundaries:** Empty Returns/Context sub-bullets in SKILL.md — the alignment must produce a non-empty contract matching the task card.
- **State transitions:** Each phase transitions the deck from a defective finding state to a clean state; the invariant is that the task-card Result Contract / Entry Criteria remain the authoritative source.
- **Failure modes:** If a task card's Result Contract is itself defective, the SKILL.md alignment must be justified by the task card as authoritative, or the task card corrected.
- **Concurrency:** Items 5-32 are independent and can be sequenced in any order; Items 1-4 are sequential (same SKILL.md file).
- **Recovery:** If `skildeck lint` re-run shows residual findings, the specific finding class is re-diagnosed and the corresponding item re-executed.

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-31 | Decomposed compound SCs (SC-2, SC-4, SC-7, SC-8, SC-9) into atomic SCs — one per step / per task-card group. SC set expanded from 9 to 21. | Validation finding: COMPOUND SCs — bundled multiple independently-verifiable targets. | spec-creation validation pipeline |
| 2026-08-31 | Corrected all SC evidence types from `structural` to `behavioral`. | Validation finding: EVIDENCE_TYPE_MISMATCH — verification is `skildeck lint` output inspection, which is `behavioral` per the canonical evidence type taxonomy in `cost-model-standards.md`. | spec-creation validation pipeline |
| 2026-08-31 | Reconciled SC-table column structure: kept exactly the 4 canonical columns (ID, Criterion, Evidence Type, Verification Method) per `spec-structure-standards.md`; documentation sources remain in the separate section 8. | Validation finding: DOCUMENTATION SOURCES COLUMN — resolved the reference conflict by keeping the mandated 4-column SC table and the existing section 8. | spec-creation validation pipeline |
| 2026-08-31 | Updated Requirements, Items, Traceability, and Cost Frame sections to match the decomposed 21-SC set. | Consequence of SC decomposition. | spec-creation validation pipeline |
| 2026-08-31 | Decomposed compound SCs SC-14 (issue-operations-core, 9 task cards), SC-15 (sub-issues, 2), SC-16 (sync, 2), SC-19 (multimodal-dispatch, 2) into per-task-card SCs — one SC per task-card file. SC set expanded from 21 to 32. Added R-10. | Validation finding: Aggregate FAIL on decomposition criteria — SC-14/SC-15/SC-16/SC-19 bundled multiple task-card files and multiple commits into a single SC, violating Single Deliverable and PR-Gate Viability. | spec-creation validation pipeline |
| 2026-08-31 | Restored the analytical artifacts directory (`.opencode/.issues/2410/artifacts/`) from `tmp/2410/artifacts/` so blast-radius, concern-map, interface-compatibility, and testability-assessment artifacts are cross-checkable. | Validation finding: WARNING — artifact_cross_reference — artifacts/ directory was missing. | spec-creation validation pipeline |
| 2026-08-31 | Documented the provenance evidence source for the asserted lint findings (22 internal-dispatch, contract mismatches): `tmp/2410/skildeck-lint-full.txt` (166 findings, 22 task-card-internal-dispatch, 19 dispatch-contract-result-mismatch, 5 dispatch-contract-incomplete). | Validation finding: WARNING — provenance — asserted lint findings must be cross-verifiable against evidence. | spec-creation validation pipeline |

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
