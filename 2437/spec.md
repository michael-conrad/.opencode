> **Full spec and artifacts: [`.opencode/.issues/2437/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2437/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.

# [SPEC] pr-creation workflow execution mode conflicts with orchestrator-context discipline

## Intent and Executive Summary

1. **Problem Statement:** The `git-workflow-pr` skill card marks the `pr-creation` workflow step `Execution mode: sub-agent dispatch` with a `task()` prompt, while the same card's Mandatory Task Discipline clause already defines the Architecture B contract (orchestrator executes each workflow step in its own context; `task()` only where Dispatch value is `task-card`). An orchestrator following the marker dispatches skill-card routing content to a sub-agent — the critical-rules category error.
2. **Root Cause / Motivation:** The Workflows sections and `tasks/pr-creation.md` step routing were written under an older "dispatch everything" model and never re-classified against the canonical dispatch-vocabulary table. Verified live: `git-workflow-pr/SKILL.md` carries the contradictory marker; `git-workflow/SKILL.md` carries the same prompt in its "Create a PR" entry; `tasks/pr-creation.md` uses ambiguous "Route to" prose with no per-step dispatch classification. The same defect pattern exists on all 5 git-workflow-pr workflow steps, but this spec scopes to the reported `pr-creation` step.
3. **Approach Chosen:** Re-mark the affected skill-card and task-card routing text to the canonical classification per the dispatch-vocabulary table (inline vs `task-card`), resolving the internal contradiction by editing the contradictory markers — not by adding another overriding clause (precedent: writing-plans-skill-contradiction research card, confidence 0.95).
4. **Alternatives Considered & Why Discarded:** (a) Adding an exception clause overriding the execution-mode markers — rejected: stacks another clause onto the contradiction instead of removing its cause. (b) Expanding the spec to reclassify all 5 git-workflow-pr workflow steps — rejected for this spec: the bug report names `pr-creation`; the remaining steps are filed as a follow-up if the deck-wide sweep is desired.
5. **Key Design Decisions:** (a) Dispatch classification source of truth is the canonical dispatch-vocabulary table in the skill-card-description-standards reference — no ad-hoc vocabulary in the edited files. (b) The PR pipeline's mandatory gates (squash-per-issue, human-only merge, Step 9 reconciliation) are untouched invariants. (c) SC-1 is behavioral-evidence-gated: reclassification alters dispatch decisions, a runtime-behavioral effect.
6. **User Intent / Original Prompt:** [BUG] pr-creation workflow 'execution mode: sub-agent dispatch' conflicts with orchestrator-context discipline (michael-conrad/.opencode#2437).

## Not Included

- **Deck-wide reclassification of the other 4 git-workflow-pr workflow steps (review-prep, pair-pr-creation, post-implementation, completion)** — the bug report scopes `pr-creation`; a deck-wide sweep is a separate follow-up issue if desired.
- **Runtime/code changes to enforcement plugins or hooks** — the defect is routing-metadata text, not enforcement code.
- **Changes to PR body format or the authorization scope model** — the PR pipeline's semantics and gates are unchanged invariants.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The `git-workflow-pr` skill card's `pr-creation` workflow step no longer carries the `Execution mode: sub-agent dispatch` marker and its classification cites the canonical dispatch-vocabulary table, consistent with the Mandatory Task Discipline clause | behavioral | tests-v2 enforcement scenario via `with-test-home opencode run`: assert the orchestrator does not dispatch the skill card's pr-creation routing content to a sub-agent; content-verification assertions on stderr agent actions |
| SC-2 | `tasks/pr-creation.md` explicitly classifies each procedure step (Steps 0-1, 2-4, 5-7) as orchestrator-direct or `task-card` dispatch, and the nested `pr-creation/*` sub-task routing is aligned (explicitly classified task-card dispatches or folded into orchestrator-direct execution) | semantic | Clean-room sub-agent reads the task card and judges each step's dispatch classification as unambiguous per the canonical table |
| SC-3 | The `git-workflow` skill card's "Create a PR" workflow entry carries the same classification vocabulary as the `git-workflow-pr` card | string | grep: the entry no longer contains the sub-agent-dispatch prompt and references the canonical classification |

## Requirements

R-1. The `pr-creation` workflow step in the `git-workflow-pr` skill card SHALL be marked with its canonical dispatch classification (orchestrator-direct or `task-card` per the dispatch-vocabulary table) instead of `Execution mode: sub-agent dispatch`.

R-2. `tasks/pr-creation.md` SHALL explicitly state orchestrator-direct vs `task-card` dispatch for each procedure step, per the canonical dispatch-vocabulary table.

R-3. The `git-workflow` skill card's "Create a PR" workflow entry SHALL use the same classification vocabulary as R-1.

R-4. The fix SHALL resolve the internal contradiction with the Mandatory Task Discipline clause by removing/rewriting the contradictory markers — it SHALL NOT add another overriding clause.

R-5. The nested `pr-creation/*` sub-task cards SHALL be either explicitly classified as task-card dispatch points or absorbed into orchestrator-direct execution; routing SHALL be unambiguous either way.

R-6. Edited files SHALL preserve and append existing bylines/provenance per the code-standards attribution rules.

## Items

### Item 1 (SC-1): Reclassify the pr-creation workflow step in the git-workflow-pr skill card

- RED: tests-v2 behavioral scenario asserting the orchestrator still dispatches the pr-creation skill-card routing content to a sub-agent — fails before the change
- GREEN: replace the `Execution mode: sub-agent dispatch` marker and `task()` prompt on the `pr-creation` step with the canonical classification citing the dispatch-vocabulary table, consistent with the Mandatory Task Discipline clause
- verify: behavioral scenario run passes; content check confirms no contradictory marker remains
- commit: `.opencode/skills/git-workflow-pr/SKILL.md`

### Item 2 (SC-2): Classify step routing in the pr-creation task card

- RED: content check for explicit per-step dispatch classification fails (only ambiguous "Route to" prose exists)
- GREEN: add explicit orchestrator-direct vs `task-card` classification for Steps 0-1, 2-4, 5-7; align nested `pr-creation/{enforcement-gate,squash-push,create-pr}.md` routing (classify or absorb)
- verify: clean-room sub-agent read judges every step's classification unambiguous
- commit: `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` (+ `pr-creation/*.md` as needed)

### Item 3 (SC-3): Sync the parent git-workflow skill card

- RED: grep finds the sub-agent-dispatch prompt still present in the parent card's "Create a PR" entry
- GREEN: align the entry's prompt/execution mode with the same canonical vocabulary
- verify: grep confirms the old prompt is gone and the canonical classification is present
- commit: `.opencode/skills/git-workflow/SKILL.md`

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| Canonical dispatch-vocabulary table (`.opencode/reference/skill-card-description-standards.md`) | Must be read before implementation — sole source of truth for classification vocabulary | Satisfied |
| writing-plans-skill-contradiction research card (`.issues/research-cards/`) | Precedent for the resolution pattern (confidence 0.95, incorporated) | Satisfied |
| Bug report michael-conrad/.opencode#2437 | Source issue; spec lands in the same issue | Satisfied |
| tests-v2 enforcement framework | Must exist for SC-1 behavioral verification | Satisfied |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | 1 |
| R-2 | SC-2 | 1 |
| R-3 | SC-3 | 1 |
| R-4 | SC-1 | 1 |
| R-5 | SC-2 | 1 |
| R-6 | SC-1, SC-2, SC-3 | 1 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| git-workflow-pr skill card | code (agent-facing text) | `.opencode/skills/git-workflow-pr/SKILL.md` | Read — contradictory marker and Mandatory Task Discipline clause confirmed live |
| git-workflow skill card | code (agent-facing text) | `.opencode/skills/git-workflow/SKILL.md` | Read — duplicate "Create a PR" prompt confirmed live |
| pr-creation task card + sub-tasks | code (agent-facing text) | `.opencode/skills/git-workflow-pr/tasks/pr-creation.md`, `pr-creation/*.md` | Read — ambiguous "Route to" prose confirmed live |
| Skill-card description standards | doc | `.opencode/reference/skill-card-description-standards.md` | Read — canonical dispatch-vocabulary table |
| Research cards | doc | `.issues/research-cards/writing-plans-skill-contradiction.md` et al. | Read — precedent incorporated |
| Tests-v2 framework | config | `.opencode/tests-v2/` | Read — behavioral scenario harness present |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Running the behavioral enforcement scenario costs minutes of execution time — the defect is caught at the pre-commit gate where the fix costs the same bounded delay. Skipping costs a death spiral: a structural/string PASS lets the orchestrator keep dispatching skill-card content to sub-agents, and the critical-rules category error resurfaces on every PR run at 1000× the fix cost.
- SC-2: The clean-room semantic read costs minutes of sub-agent execution — ambiguous step routing is caught before any orchestrator follows it. Skipping costs days-to-weeks of DDL: each ambiguous "Route to" line is a fresh dispatch-decision defect discovered only when an orchestrator mis-routes mid-PR.
- SC-3: The grep verification costs seconds — parent-card drift is caught before the deck ships inconsistent. Skipping costs the full contradiction again: an orchestrator loading the parent card re-introduces the exact defect SC-1 removed.

## Edge Cases

- **Input boundaries (classification ambiguity):** A step that plausibly fits both orchestrator-direct and `task-card` — the canonical table maps every step to exactly one value; an unclassifiable step is escalated, not guessed.
- **State transitions:** Reclassification is a one-time text edit; no runtime state machine is affected. PR pipeline states (`for_pr`, `approved-for-pr`) are invariants.
- **Failure modes:** A tests-v2 scenario that greps the old marker (string check) is insufficient for SC-1 — behavioral evidence is required per the runtime-behavioral classification gate; a structural substitute is EVIDENCE_TYPE_MISMATCH and FAILs.
- **Concurrency:** No concurrent writers — single-branch edit in the `.opencode` submodule.
- **Recovery:** If behavioral harness infrastructure fails, remediation-first applies (diagnose, re-run); the only valid outcomes are PASS or FAIL with remediation — never a structural downgrade.
