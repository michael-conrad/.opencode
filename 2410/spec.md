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

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The `git-workflow-branch` SKILL.md "Verify remote trunk tip" step Returns contract SHALL match the `trunk-tip-verification.md` Result Contract `{status, checks, blocker_reason}`. | structural | `./.opencode/tools/skildeck lint` shows zero `dispatch-contract-result-mismatch` findings for the git-workflow-branch "Verify remote trunk tip" step |
| SC-2 | The `git-workflow-branch` SKILL.md "Pair pre-work" and "Pair mode resume" Returns contracts SHALL match their task-card Result Contracts. | structural | `./.opencode/tools/skildeck lint` shows zero `dispatch-contract-result-mismatch` findings for the git-workflow-branch pair-mode steps |
| SC-3 | The `git-workflow-branch` SKILL.md "Pre-work" Context SHALL include the `approved` field required by `pre-work.md` Entry Criteria. | structural | `./.opencode/tools/skildeck lint` shows zero `dispatch-contract-incomplete` findings for the git-workflow-branch "Pre-work" step |
| SC-4 | The `git-workflow-cleanup` (pair-cleanup), `git-workflow-commit` (pair-commit), and `git-workflow-pr` (pair-pr-creation, completion) SKILL.md Returns contracts SHALL match their task-card Result Contracts. | structural | `./.opencode/tools/skildeck lint` shows zero `dispatch-contract-result-mismatch` findings for the named steps |
| SC-5 | The `git-workflow-conflict` SKILL.md "Rebase pending" Context SHALL include the `merged_at` field required by `rebase-pending.md` Entry Criteria. | structural | `./.opencode/tools/skildeck lint` shows zero `dispatch-contract-incomplete` findings for the git-workflow-conflict "Rebase pending" step |
| SC-6 | The `writing-plans/tasks/analyze.md` Entry Criteria SHALL be reworded so the `SPEC_NOT_FOUND` and `SPEC_NOT_APPROVED` BLOCK reason tokens are no longer flagged as required context parameters. | structural | `./.opencode/tools/skildeck lint` shows zero `dispatch-contract-incomplete` findings for the writing-plans "analyze" step |
| SC-7 | The `git-workflow-branch/tasks/pre-work.md` and `git-workflow-pr/tasks/pr-creation.md` task cards SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | structural | `./.opencode/tools/skildeck lint` shows zero `task-card-internal-dispatch` findings for these task cards |
| SC-8 | The `issue-operations-comments`, `issue-operations-core`, `issue-operations-sub-issues`, and `issue-operations-sync` task cards SHALL contain no embedded `task()`/`skill({)` dispatch instructions. | structural | `./.opencode/tools/skildeck lint` shows zero `task-card-internal-dispatch` findings for these task cards |
| SC-9 | The `issue-review/tasks/audit.md`, `sre-runbook/tasks/track.md`, `multimodal-dispatch/tasks/*.md`, `pre-analysis/tasks/analyze.md`, and `verification/tasks/verify.md` task cards SHALL contain no embedded `task()`/`skill({)` dispatch instructions and no prose that triggers the lint token pattern. | structural | `./.opencode/tools/skildeck lint` shows zero `task-card-internal-dispatch` findings for these task cards |

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

## 5. Items

### Item 1 (SC-1): Align git-workflow-branch "Verify remote trunk tip" Returns contract

- RED: `skildeck lint` shows `dispatch-contract-result-mismatch` for the git-workflow-branch "Verify remote trunk tip" step.
- GREEN: Update `git-workflow-branch/SKILL.md` "Verify remote trunk tip" Returns to `{status, checks, blocker_reason}`.
- verify: `./.opencode/tools/skildeck lint` shows zero `dispatch-contract-result-mismatch` findings for this step.
- commit: `git-workflow-branch/SKILL.md` Returns alignment.

### Item 2 (SC-2): Align git-workflow-branch pair-mode Returns contracts

- RED: `skildeck lint` shows `dispatch-contract-result-mismatch` for the git-workflow-branch pair-mode steps.
- GREEN: Update `git-workflow-branch/SKILL.md` "Pair pre-work" and "Pair mode resume" Returns to match their task-card Result Contracts.
- verify: `./.opencode/tools/skildeck lint` shows zero `dispatch-contract-result-mismatch` findings for these steps.
- commit: `git-workflow-branch/SKILL.md` pair-mode Returns alignment.

### Item 3 (SC-3): Add 'approved' to git-workflow-branch "Pre-work" Context

- RED: `skildeck lint` shows `dispatch-contract-incomplete` for the git-workflow-branch "Pre-work" step.
- GREEN: Add the `approved` field to the `git-workflow-branch/SKILL.md` "Pre-work" Context.
- verify: `./.opencode/tools/skildeck lint` shows zero `dispatch-contract-incomplete` findings for this step.
- commit: `git-workflow-branch/SKILL.md` Context alignment.

### Item 4 (SC-4): Resolve git-workflow-cleanup, git-workflow-commit, git-workflow-pr contract mismatches

- RED: `skildeck lint` shows `dispatch-contract-result-mismatch` for the named steps.
- GREEN: Align Returns contracts for `git-workflow-cleanup` (pair-cleanup), `git-workflow-commit` (pair-commit), `git-workflow-pr` (pair-pr-creation, completion).
- verify: `./.opencode/tools/skildeck lint` shows zero `dispatch-contract-result-mismatch` findings for these steps.
- commit: SKILL.md Returns alignment for the three skills.

### Item 5 (SC-5): Resolve git-workflow-conflict "Rebase pending" merged_at context

- RED: `skildeck lint` shows `dispatch-contract-incomplete` for the git-workflow-conflict "Rebase pending" step.
- GREEN: Add the `merged_at` field to the `git-workflow-conflict/SKILL.md` "Rebase pending" Context.
- verify: `./.opencode/tools/skildeck lint` shows zero `dispatch-contract-incomplete` findings for this step.
- commit: `git-workflow-conflict/SKILL.md` Context alignment.

### Item 6 (SC-6): Resolve writing-plans 'analyze' SPEC_NOT_FOUND/SPEC_NOT_APPROVED false-positives

- RED: `skildeck lint` shows `dispatch-contract-incomplete` for the writing-plans "analyze" step.
- GREEN: Reword `writing-plans/tasks/analyze.md` Entry Criteria to avoid backtick-quoting the BLOCK reason tokens.
- verify: `./.opencode/tools/skildeck lint` shows zero `dispatch-contract-incomplete` findings for this step.
- commit: `writing-plans/tasks/analyze.md` Entry Criteria rewording.

### Item 7 (SC-7): Remediate git-workflow-branch and git-workflow-pr task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for `git-workflow-branch/tasks/pre-work.md` and `git-workflow-pr/tasks/pr-creation.md`.
- GREEN: Replace embedded `task()` dispatch instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` shows zero `task-card-internal-dispatch` findings for these task cards.
- commit: One commit per task card.

### Item 8 (SC-8): Remediate issue-operations-* task-card internal dispatch

- RED: `skildeck lint` shows `task-card-internal-dispatch` for the issue-operations-* task cards.
- GREEN: Replace embedded `task()` routing instructions with orchestrator-routing markers.
- verify: `./.opencode/tools/skildeck lint` shows zero `task-card-internal-dispatch` findings for these task cards.
- commit: One commit per task card.

### Item 9 (SC-9): Remediate remaining task-card internal dispatch and prose mentions

- RED: `skildeck lint` shows `task-card-internal-dispatch` for the remaining task cards.
- GREEN: Replace embedded dispatch in `issue-review/tasks/audit.md` and `sre-runbook/tasks/track.md`; reword prose mentions in `multimodal-dispatch/tasks/*.md`, `pre-analysis/tasks/analyze.md`, `verification/tasks/verify.md`.
- verify: `./.opencode/tools/skildeck lint` shows zero `task-card-internal-dispatch` findings for these task cards.
- commit: One commit per task card.

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
| R-2 | SC-2 | Phase 1 |
| R-3 | SC-3 | Phase 1 |
| R-4 | SC-4 | Phase 1 |
| R-5 | SC-5 | Phase 1 |
| R-6 | SC-6 | Phase 1 |
| R-7 | SC-7, SC-8, SC-9 | Phase 2 |
| R-8 | SC-7, SC-8, SC-9 | Phase 2 |
| R-9 | SC-6, SC-9 | Phase 1, Phase 2 |

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
- **SC-2:** Verifying the pair-mode Returns contracts costs one `skildeck lint` run. Skipping means pair-mode routing defects ship to production and cost 1000× more to fix.
- **SC-3:** Verifying the `approved` context field costs one `skildeck lint` run. Skipping means sub-agents BLOCK or self-authorize without the required authorization context.
- **SC-4:** Verifying the Returns contracts for the three skills costs one `skildeck lint` run. Skipping means contract mismatches surface at review time.
- **SC-5:** Verifying the `merged_at` context field costs one `skildeck lint` run. Skipping means rebase-pending sub-agents lack the required timestamp context.
- **SC-6:** Verifying the Entry Criteria rewording costs one `skildeck lint` run. Skipping means the false-positive persists and masks genuine contract defects.
- **SC-7:** Verifying the task cards contain no internal dispatch costs one `skildeck lint` run. Skipping means sub-agents re-dispatch, wasting context and violating clean-room isolation.
- **SC-8:** Verifying the issue-operations task cards contain no internal dispatch costs one `skildeck lint` run. Skipping means platform-routing sub-agents re-dispatch instead of executing.
- **SC-9:** Verifying the remaining task cards contain no internal dispatch costs one `skildeck lint` run. Skipping means prose mentions continue to trigger false-positive findings.

## 11. Edge Cases

- **Input boundaries:** Empty Returns/Context sub-bullets in SKILL.md — the alignment must produce a non-empty contract matching the task card.
- **State transitions:** Each phase transitions the deck from a defective finding state to a clean state; the invariant is that the task-card Result Contract / Entry Criteria remain the authoritative source.
- **Failure modes:** If a task card's Result Contract is itself defective, the SKILL.md alignment must be justified by the task card as authoritative, or the task card corrected.
- **Concurrency:** Items 4-9 are independent and can be sequenced in any order; Items 1-3 are sequential (same SKILL.md file).
- **Recovery:** If `skildeck lint` re-run shows residual findings, the specific finding class is re-diagnosed and the corresponding item re-executed.

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
