---
plan_schema_version: 1
issue: 2449
title: "local-issues list/search/read stop fabricating ticket state for artifact-only dirs"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 4
dispatch:
  - "phase 1: test-driven-development/red, test-driven-development/green, test-driven-development/post-regression, verification-before-completion/verify (commit-inline direct)"
  - "phase 2: test-driven-development/red, test-driven-development/green, test-driven-development/post-regression, verification-before-completion/verify (commit-inline direct)"
  - "phase 3: test-driven-development/red, test-driven-development/green, test-driven-development/post-regression, verification-before-completion/verify (commit-inline direct)"
  - "phase 4: test-driven-development/red, test-driven-development/green, test-driven-development/post-regression, verification-before-completion/verify (commit-inline direct)"
  - "post: audit, finishing-a-development-branch/checklist, verification-before-completion/verify, test-driven-development/phase-4, git-workflow-pr/review-prep, git-workflow-pr/create, completion-core/completion (z3-check direct)"
---

# Implementation Plan — .opencode#2449

**Issue:** `.opencode/.issues/2449/spec.md`
**Spec:** `[SPEC] local-issues list reports [open] for artifact-only dirs without issue.yaml`

## Goal / Architecture / Files / Dispatch

- **Goal:** `local-issues` list/search/read SHALL NOT fabricate ticket state for directories without `issue.yaml`; such directories render the exact token `[artifact-only]` (list/search) or omit the status line (read). Well-formed tickets are untouched.
- **Architecture:** Sentinel-based. Readers (`_read_issue_title_status`, `_read_issue_data_in_repo`) detect `issue.yaml` absence and return a `None`-status sentinel / omit synthesized status. Presentation formatters (`_format_list_output`, `_format_search_results`, read output path) apply the shared fixed policy keyed solely on the sentinel.
- **Files:** `.opencode/tools/local-issues` (single-file tool); new sandbox pytest files under `.opencode/tests/test_local_issues/` following `test_yaml_load_warn_and_skip.py` conventions.
- **Dispatch:** sub-agent task cards for RED/GREEN/post-regression/verify and post-implementation gates; orchestrator-direct for coherence gate, baseline check, commits, z3-check.

## Blast Radius

- **Direct:** `.opencode/tools/local-issues` — `_read_issue_title_status` (sentinel on absent `issue.yaml`), `_read_issue_data_in_repo` (omit synthesized status), `_format_list_output` and `_format_search_results` (render `[artifact-only]`), read output path (omit status line). `_search_in_repo` passes reader data through unchanged.
- **Indirect:** all agents routing on list/search/read output — output shape changes only for yaml-less dirs.
- **Unaffected:** validate subcommand (`_validate_issue_dir` — excluded per Not Included); well-formed ticket rendering (SC-4 guard); mutation subcommands (create/update/comment/link/close/renumber).
- **Risk:** LOW.
- **Tests:** new sandbox pytest files in `.opencode/tests/test_local_issues/`.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | List formatter applies `[artifact-only]` marker | reader sentinel + list rendering | SC-1 | — | 5-9 | task-card (5-8) + direct (9) |
| 2 | Search results marked `[artifact-only]` | reader synthesis removal + search rendering | SC-2 | — | 10-14 | task-card (10-13) + direct (14) |
| 3 | Read omits fabricated status | sentinel consumption in read path | SC-3 | — | 15-19 | task-card (15-18) + direct (19) |
| 4 | Well-formed ticket preservation matrix | guard logic across all formatters | SC-4 | 1, 2, 3 | 20-24 | task-card (20-23) + direct (24) |
| — | Post-implementation | audit, gates, PR | all | 1-4 | 25-32 | task-card (25, 27-31) + direct (26, 32) |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Pre-Implementation

- [ ] 1. Coherence gate (**direct**)
  - Re-read this plan's ledger at `.opencode/.issues/2449/artifacts/plan-input-verification.md`; confirm the four SCs map one-to-one to phases 1-4 and no phase covers a foreign SC
  - Confirm the spec's single fixed presentation policy: marker token is exactly `[artifact-only]`; readers return sentinels, formatters render
- [ ] 2. Baseline check (**direct**)
  - Confirm repo state: `.opencode` submodule on trunk tip, zero pending changes; current `local-issues list` reproduces the defect on a scratch fixture tree under `./tmp/` (yaml-less dir shows `[open]`)
  - Clean stale pipeline artifacts: `rm -f ./tmp/2449/artifacts/pipeline-*`
- [ ] 3. Pre-regression (**task-card**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`
  - Run existing regression test patterns for `.opencode/tests/test_local_issues/` before RED; record baseline results under `./tmp/2449/artifacts/`
- [ ] 4. Pre-regression verify (**task-card**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify pre-regression baseline is green before phase 1 RED begins

## Phase 1 — SC-1: list formatter applies the `[artifact-only]` marker for yaml-less dirs

**Concern:** list rendering. **Files:** `.opencode/tools/local-issues`; new test in `.opencode/tests/test_local_issues/`. **SCs:** SC-1. **Dependencies:** none.
**Entry:** baseline green (step 4). **Exit:** SC-1 test passing, committed.

**Code Path Coverage:** list dispatch → repo iteration → `_read_issue_title_status` (today returns `("", "open")` for yaml-less dir with `spec.md`) → `_format_list_output` renders `[open]`.
**Cross-Cutting SCs:** SC-1 spans reader-sentinel (C-1) and presentation-policy (C-2).
**Interface Boundaries:** `_read_issue_title_status` returns `tuple[str, Optional[str]]` — status element `None` when `issue.yaml` absent; single internal call-site (`_format_list_output`) updates.
**State Transitions:** yaml-less dir rendered as `[open]` with empty title → rendered as `[artifact-only]`; policy computed per invocation, never cached.

- [ ] 5. RED — write failing enforcement test (**task-card**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
  - Covers SC-1. Sandbox pytest: fixture tree with an artifact-only dir (`spec.md` only, no `issue.yaml`); run `list`; assert stdout contains `[artifact-only]` and does not contain `[open]` for that entry — test FAILS against current tool
- [ ] 6. GREEN — minimal implementation (**task-card**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
  - Covers SC-1. `_read_issue_title_status` returns a `None`-status sentinel when `issue.yaml` is absent (readers stay total functions — no exception); `_format_list_output` renders the exact token `[artifact-only]` for sentinel entries. Empty dirs remain excluded from enumeration. Well-formed tickets unaffected. No scope creep beyond SC-1
- [ ] 7. Post-regression (**task-card**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Run regression test patterns after GREEN — existing list tests in `.opencode/tests/test_local_issues/` still pass
- [ ] 8. Verify (**task-card**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Re-run SC-1 sandbox test plus existing list tests; behavioral evidence (pytest execution with stdout assertions) required — evidence type is behavioral, structural substitutes are EVIDENCE_TYPE_MISMATCH → FAIL
- [ ] 9. Commit (**direct**)
  - Orchestrator runs `git add` on the sentinel change, formatter change, and SC-1 test file, then commits — one atomic slice; no co-author trailers at implementation time

**Cost frame:** Verifying SC-1 costs one sandbox pytest run — minutes of execution time. Skipping means every future agent session routes on phantom `[open]` tickets — repeated misroutes and re-debugging of this defect family. Correctness is the only metric.

**Phase 1 completion:** VbC asserts SC-1 test green, existing list tests green, commit contains test + change together.

## Phase 2 — SC-2: search results marked `[artifact-only]` without synthesized status

**Concern:** search rendering. **Files:** `.opencode/tools/local-issues`; new test in `.opencode/tests/test_local_issues/`. **SCs:** SC-2. **Dependencies:** none (independent of phase 1 in the DAG; execute after phase 1 commit per daisy chain).
**Entry:** phase 1 committed. **Exit:** SC-2 test passing, committed.

**Code Path Coverage:** search dispatch → `_search_in_repo` → `_read_issue_data_in_repo` (today synthesizes `status: open` for yaml-less dirs) → `_format_search_results`.
**Cross-Cutting SCs:** SC-2 spans reader-sentinel (C-1) and presentation-policy (C-2).
**Interface Boundaries:** `_read_issue_data_in_repo` omits the synthesized status key for yaml-less dirs; `_search_in_repo` passes through; `_format_search_results` branches on the sentinel. Well-formed dicts unchanged in shape.
**State Transitions:** search result with synthesized `status: open` → result marked `[artifact-only]`, no synthesized status.

- [ ] 10. RED — write failing enforcement test (**task-card**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
  - Covers SC-2. Sandbox pytest: fixture tree with a yaml-less spec-only dir; run `search` against a matching query; assert the result block contains `[artifact-only]` and no synthesized `status: open` — test FAILS against current tool
- [ ] 11. GREEN — minimal implementation (**task-card**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
  - Covers SC-2. `_read_issue_data_in_repo` omits the synthesized status for yaml-less dirs; `_format_search_results` renders `[artifact-only]` for such results. Well-formed tickets unaffected. No scope creep beyond SC-2
- [ ] 12. Post-regression (**task-card**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Run regression test patterns after GREEN — existing search tests still pass
- [ ] 13. Verify (**task-card**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Re-run SC-2 sandbox test plus existing search tests; behavioral evidence required
- [ ] 14. Commit (**direct**)
  - Orchestrator runs `git add` on the reader change, search formatter change, and SC-2 test file, then commits — one atomic slice; no co-author trailers

**Cost frame:** Verifying SC-2 costs one sandbox pytest run — minutes of execution time. Skipping means silent fabricated state persists in search results, corrupting every downstream query consumer far from the cause. Correctness is the only metric.

**Phase 2 completion:** VbC asserts SC-2 test green, existing search tests green, commit contains test + change together.

## Phase 3 — SC-3: read subcommand omits fabricated status for yaml-less dirs

**Concern:** read path. **Files:** `.opencode/tools/local-issues`; new test in `.opencode/tests/test_local_issues/`. **SCs:** SC-3. **Dependencies:** none in DAG; daisy-chained after phase 2.
**Entry:** phase 2 committed. **Exit:** SC-3 test passing, committed.

**Code Path Coverage:** read dispatch → `_read_issue_data_in_repo` → output formatting.
**Cross-Cutting SCs:** SC-3 spans reader-sentinel (C-1) and presentation-policy (C-2).
**Interface Boundaries:** read path consumes the same sentinel from `_read_issue_data_in_repo` (set in phase 2); read output formatting omits the status line for yaml-less dirs.
**State Transitions:** read output containing `status: open` for yaml-less dir → read output omits the status line.

- [ ] 15. RED — write failing enforcement test (**task-card**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
  - Covers SC-3. Sandbox pytest: fixture tree with a yaml-less spec-only dir; run `read` on that number; assert output omits `status: open` — test FAILS against current tool
- [ ] 16. GREEN — minimal implementation (**task-card**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
  - Covers SC-3. Read path consumes the sentinel from `_read_issue_data_in_repo` and renders no status line for yaml-less dirs. No scope creep beyond SC-3
- [ ] 17. Post-regression (**task-card**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Run regression test patterns after GREEN — existing read tests still pass
- [ ] 18. Verify (**task-card**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Re-run SC-3 sandbox test plus existing read tests; behavioral evidence required
- [ ] 19. Commit (**direct**)
  - Orchestrator runs `git add` on the read-path change and SC-3 test file, then commits — one atomic slice; no co-author trailers

**Cost frame:** Verifying SC-3 costs one sandbox pytest run — minutes of execution time. Skipping means divergence between read and list/search views of the same directory — agents trust one view and get another. Correctness is the only metric.

**Phase 3 completion:** VbC asserts SC-3 test green, existing read tests green, commit contains test + change together.

## Phase 4 — SC-4: well-formed ticket status preservation matrix

**Concern:** guard logic across all three formatters. **Files:** `.opencode/tools/local-issues`; new matrix test in `.opencode/tests/test_local_issues/`. **SCs:** SC-4. **Dependencies:** phases 1, 2, 3.
**Entry:** phases 1-3 committed. **Exit:** SC-4 matrix passing, committed.

**Code Path Coverage:** same three paths as phases 1-3 with the `issue.yaml` present branch unchanged; guard applies the marker only when `issue.yaml` is absent.
**Cross-Cutting SCs:** SC-4 spans all three concerns (C-1 reader-sentinel, C-2 presentation-policy, C-3 well-formed-guard) — exercises list, search, and read with both sentinel branches.
**Interface Boundaries:** no new boundaries — the matrix pins the existing well-formed output contract (real status, no `[artifact-only]` marker).
**State Transitions:** none new — well-formed ticket real status is an invariant (T-5); edge transition T-4 (dir gains `issue.yaml` → marker disappears, real status renders) pinned by the matrix.

- [ ] 20. RED — write failing enforcement test (**task-card**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
  - Covers SC-4. Sandbox fixture matrix: well-formed control ticket (issue.yaml + spec.md) plus artifact-only, comments.yaml-only, links.yaml-only, and empty dir variants; assert control keeps its real status and no `[artifact-only]` marker, variants are marked, empty dir excluded — the control-with-no-marker assertion pins the non-regression
- [ ] 21. GREEN — minimal implementation (**task-card**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
  - Covers SC-4. Guard logic in all three formatters (`_format_list_output`, `_format_search_results`, read output path) applying `[artifact-only]` only when `issue.yaml` is absent; malformed `issue.yaml` (present but unparseable) is out of the trigger set — existing 2432 error-class handling governs. No scope creep beyond SC-4
- [ ] 22. Post-regression (**task-card**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Run regression test patterns after GREEN — full existing suite in `.opencode/tests/test_local_issues/` still passes
- [ ] 23. Verify (**task-card**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Run the full matrix test; assert control real status, variants marked, empty dir excluded per Edge Cases; behavioral evidence required
- [ ] 24. Commit (**direct**)
  - Orchestrator runs `git add` on the guard logic and SC-4 matrix test file, then commits — one atomic slice; no co-author trailers

**Cost frame:** Verifying SC-4 costs one sandbox pytest run with a small fixture tree — minutes of execution time. Skipping means the marker could leak onto well-formed tickets, corrupting the real issue-store view — the exact defect this spec exists to remove. Correctness is the only metric.

**Phase 4 completion:** VbC asserts matrix green, full suite green, commit contains test + change together.

## Post-Implementation

- [ ] 25. Adversarial audit (**task-card**)
  - Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence
  - Audit deliverable against spec fidelity and evidence-type honesty
- [ ] 26. Z3 constraint check (**direct**)
  - Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...` directly against the existing dependency contract and state artifacts
- [ ] 27. Structural checks (**task-card**)
  - Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
  - Finishing checklist (lint, typecheck, branch hygiene)
- [ ] 28. Pre-PR gate (**task-card**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Reads all SC verdicts (SC-1 through SC-4); BLOCKs if any FAIL — DONE_WITH_CONCERNS coerces to FAIL
- [ ] 29. Final regression check (**task-card**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Full regression run before PR creation
- [ ] 30. Review prep (**task-card**)
  - Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
- [ ] 31. Create PR (**task-card**)
  - Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`
  - Stacked PR targeting the trunk; one squashed commit per issue
- [ ] 32. Completion executive summary (**task-card**)
  - Dispatch `task(..., prompt: "execute completion task from completion-core")`
  - One `plan_created` lifecycle event with `plan_file` and `phase_count` already recorded at plan acceptance; final exec summary reported to chat; HALT

## Exit Criteria

- C1: SC-1 sandbox test passes — `list` emits `[artifact-only]`, not `[open]`, for yaml-less dirs
- C2: SC-2 sandbox test passes — `search` marks yaml-less dirs `[artifact-only]` with no synthesized `status: open`
- C3: SC-3 sandbox test passes — `read` omits `status: open` for yaml-less dirs with plain-markdown specs
- C4: SC-4 matrix passes — well-formed control keeps real status with no marker; variants marked; empty dir excluded
- C5: All four commits are atomic slices (test + change together); no co-author trailers at implementation time
- C6: Full existing suite in `.opencode/tests/test_local_issues/` passes at plan end
- C7: Adversarial audit verdict is clean; pre-PR gate shows all SC verdicts PASS

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.
