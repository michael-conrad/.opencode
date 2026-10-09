<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 (restructured from the pre-rip reference, tag pre-rip); #2557 build-verification row + language/toolchain row -->

# Implementation Workflow Reference

Consult at implementation start and before every mid-cycle change.
Work is performed in the agent's own context unless a scoped task genuinely
benefits from a clean-room dispatch — judgment, not ritual.

## Pre-implementation

| Step | How | Purpose |
|------|-----|---------|
| baseline | run the project's existing test suite; record results | confirm a green baseline — a failing baseline is a defect to report, not code around |
| language/toolchain | identify the languages and build tools of the files about to be modified; load their cards (where cards exist) and `programming-principles` | language standards shape the change before the first edit, not after the first defect |
| authorization | check floor vocabulary + current session state | confirm the change's scope is authorized before modifying files |
| branch | `git-workflow-branch` conventions | feature branch exists before the first file modification |

## RED-GREEN chain (per plan item / SC)

| Step | How | Purpose |
|------|-----|---------|
| red | write or run the failing assertion; confirm it fails for the stated reason | the defect is demonstrated, not assumed |
| green | minimal change that turns it green | no speculative additions |
| post-regression | re-run the suite | nothing previously working broke |
| verify-inline | the executed check's output is the evidence | never assert success without a run |
| commit | stage the item's files; atomic, descriptive message | one item, one commit |

## Post-implementation

| Step | How | Purpose |
|------|-----|---------|
| test-contract currency | a behavior change updates its dependent tests in the same cycle — when behavior is spec-removed, the stale tests are removed/updated on the same branch | tests contract on behavior; a merged behavior change that leaves its old tests behind re-breaks the suite for every later PR |
| structural | project-local lint/typecheck commands | cheap mechanical facts first |
| build verification | when the change affects build configuration or packaging (or the deliverable is a build artifact): a shallow temp-copy checkout (`git clone --depth 1`) of the tree; the repo's canonical build command sourced from the repo's declared build manifest (ask rather than guess when the manifest does not declare one, and record the confirmed command); assertion that the final outputs exist and are sound (e.g. the built artifact present, its contents inspected) | "lint passed" is not "build works" — the built artifact is the deliverable, verified in a pristine checkout, never asserted from the working tree alone |
| suite-green | run the full test suite; every failure is remediated or dispositioned via a filed fix — never passed through as "pre-existing" (#2553) | a red suite at the PR boundary ships the regression forward |
| verify pass | dispatch the `verify` card's single fresh-context reviewer | one bounded review; churn rule applies |
| PR prep | `git-workflow-pr` conventions | review context for the human gate |

Escalation: any step that cannot complete honestly stops the cycle — report
the state, the blocker, and what is needed; never fabricate a pass.
