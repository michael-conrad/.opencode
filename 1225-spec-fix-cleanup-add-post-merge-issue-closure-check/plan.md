---
number: 1225
title: "[PLAN] cleanup: add post-merge issue closure check"
status: draft
created: 2026-06-15
---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Plan: cleanup: add post-merge issue closure check

**Spec:** #1225
**Authorization scope:** `for_plan` | `halt_at: plan_created` | `pr_strategy: none`
**Type:** Separate (single-phase, single-concern enhancement)

## Summary

Add a post-merge issue-closure sweep to the git-workflow cleanup task that checks all open issues in the repository, verifies whether their linked PRs are merged, and proposes closure for closable candidates. Parent issues with open children are skipped.

**SCs covered:**
| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | cleanup task (or sub-task) checks open issues for closable candidates after PR merge | behavioral |
| SC-2 | Only closes issues whose linked PRs are confirmed merged | behavioral |
| SC-3 | Parent issues with open children are NOT closed | behavioral |
| SC-4 | Reports findings to chat before closing | behavioral |

**Affected files:**
- `.opencode/skills/git-workflow/tasks/cleanup.md` — add step referencing new sweep
- `.opencode/skills/git-workflow/tasks/cleanup/issue-closure.md` — add Step ~1.5 for cross-repo closure sweep, or new sub-task file `cleanup/issue-closure-sweep.md`

---

## Pre-Work (before pipeline)

1. Create feature branch from dev: `feature/1225-cleanup-issue-closure-sweep`
2. Tag `.opencode` submodule: `.opencode/checkpoint/1225/pre`
3. Initialize pipeline state: `solve state init ./tmp/1225/state/`
4. Set initial state: `solve state update ./tmp/1225/state/ --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml --var-name previous_step --var-value init --var-name current_step --var-value sc-coherence-gate --var-name pipeline_state --var-value running`

## RED Assertions

- **SC-1 RED:** Read `cleanup/issue-closure.md` → verify no post-merge sweep step exists for cross-repo open issue checking
- **SC-2 RED:** grep for `check_issue_closures` or `sweep` in git-workflow tasks → expect 0 matches
- **SC-3 RED:** grep for "open children" or "parent issues with open children" in issue-closure.md → expect no parent-child guard for cross-repo sweep
- **SC-4 RED:** Confirm no existing logic that reports cross-repo closure findings to chat before closing

## Verification Methods

- **SC-1 (behavioral):** `opencode-cli run` with cleanup trigger → verify agent checks open issues for closable candidates
- **SC-2 (behavioral):** `opencode-cli run` → verify agent confirms linked PRs are merged before closing
- **SC-3 (behavioral):** `opencode-cli run` with parent issue having open children → verify agent does NOT close parent
- **SC-4 (behavioral):** `opencode-cli run` → verify agent reports findings to chat before closing

---

## Phase 1: Add Post-Merge Issue Closure Sweep

**Concern:** Add post-merge issue-closure sweep to cleanup that checks all open issues for closable candidates (SC-1 through SC-4).

**Files:**
- `.opencode/skills/git-workflow/tasks/cleanup.md` — optionally reference new sweep step
- `.opencode/skills/git-workflow/tasks/cleanup/issue-closure.md` — add sweep step or new sub-task

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"issue":1225,"phase":1,"task":"verify SC-1 through SC-4 are coherent with git-workflow cleanup structure — read cleanup.md and issue-closure.md, confirm existing closure logic only handles issues explicitly referenced in PR body, does NOT perform cross-repo sweep of all open issues"}` | SC-1, SC-2, SC-3, SC-4 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"issue":1225,"phase":1,"task":"capture baseline: read cleanup/issue-closure.md — confirm no cross-repo open-issue sweep step exists; confirm existing closure steps only handle PR-body-referenced issues"}` | SC-1, SC-2 |
| G3: red-phase | sub-task | yes (blind) | general | `{"issue":1225,"phase":1,"remediation":true,"task":"write RED enforcement tests: (1) grep for 'issue-closure-sweep' in cleanup tasks → expect 0 matches, (2) read issue-closure.md → confirm no 'check all open issues for closable candidates' step; tests MUST fail before implementation"}` | SC-1 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"issue":1225,"phase":1,"task":"verify RED tests actually fail: run each RED assertion, confirm expected output; log results to tmp/1225/red-verified.json"}` | SC-1 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"issue":1225,"phase":1,"task":"confirm RED phase complete: all RED tests written, all verified failing; report BLOCKED if any RED test passes unexpectedly"}` | SC-1 |
| G6: green-phase | sub-task | yes (blind) | general | `{"issue":1225,"phase":1,"remediation":true,"task":"implement: (1) add new sub-task file cleanup/issue-closure-sweep.md that: queries all open issues, checks each for linked PRs (via body Fixes/Implements references), verifies linked PRs are merged, checks parent-child relationships (skip parents with open children), reports findings to chat before closing (2) add reference step in cleanup.md Step 2.5 or as part of Step 2 (3) update issue-closure.md entry/exit criteria"}` | SC-1, SC-2, SC-3, SC-4 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"issue":1225,"phase":1,"task":"verify GREEN changes applied: new sub-task file exists, cleanup.md references the sweep step, issue-closure.md mentions cross-repo sweep"}` | SC-1 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"issue":1225,"phase":1,"task":"structural verification: (1) cleanup/issue-closure-sweep.md exists, (2) cleanup.md has reference to sweep step, (3) sweep step queries open issues, (4) sweep step checks PR merge status before closing, (5) sweep step checks parent-child"}` | SC-1, SC-2, SC-3 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"issue":1225,"phase":1,"task":"independent re-verification: re-run all RED tests (now expect new file present), confirm all pass"}` | SC-1 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"issue":1225,"phase":1,"task":"verification-before-completion: for each SC (SC-1 through SC-4), collect evidence artifact, report PASS/FAIL with tool-call evidence"}` | SC-1, SC-2, SC-3, SC-4 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"issue":1225,"phase":1,"task":"adversarial audit: audit sweep logic for correctness: does it correctly query all open issues? does it correctly verify linked PR merge status? does it correctly skip parents with open children? are edge cases handled (no linked PRs, multiple PRs, cross-repo PRs)?"}` | SC-1, SC-2, SC-3, SC-4 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"issue":1225,"phase":1,"task":"cross-validate: compare G11 VbC results against G12 audit results; report consensus per SC"}` | SC-1, SC-2, SC-3, SC-4 |
| G14: regression-check | sub-task | yes (blind) | general | `{"issue":1225,"phase":1,"task":"regression check: verify existing cleanup behavior unaffected — run cleanup with normal PR merge, confirm existing issue closure (via PR body references) still works"}` | SC-1, SC-2 |
| G15: review-prep | sub-task | yes (blind) | general | `{"issue":1225,"phase":1,"task":"prepare review: generate diff summary, list files modified, produce compare URL"}` | SC-1, SC-2, SC-3, SC-4 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"issue":1225,"phase":1,"task":"produce executive summary: what was done, SC PASS/FAIL table, any blockers or concerns"}` | SC-1, SC-2, SC-3, SC-4 |

---

## SC-ID Traceability

| SC | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | cleanup checks open issues for closable candidates after PR merge | behavioral |
| SC-2 | Only closes issues with confirmed merged linked PRs | behavioral |
| SC-3 | Parent issues with open children are NOT closed | behavioral |
| SC-4 | Reports findings to chat before closing | behavioral |

---

## Post-All-Phases Sweep

1. Tag submodule: `.opencode/checkpoint/1225/post`
2. Run enforcement tests: `bash .opencode/tests/test-enforcement.sh --changed`
3. Run finish-checklist: `skill({name: "finishing-a-development-branch"})`

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.