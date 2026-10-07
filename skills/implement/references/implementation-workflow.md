<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 (restructured from the pre-rip reference, tag pre-rip) -->

# Implementation Workflow Reference

Consult at implementation start and before every mid-cycle change.
Work is performed in the agent's own context unless a scoped task genuinely
benefits from a clean-room dispatch — judgment, not ritual.

## Pre-implementation

| Step | How | Purpose |
|------|-----|---------|
| baseline | run the smoke tier (plus regression for the target area); record results | confirm a green baseline — a failing baseline is a defect to report, not code around |
| authorization | check floor vocabulary + current session state | confirm the change's scope is authorized before modifying files |
| branch | `git-workflow-branch` conventions | feature branch exists before the first file modification |

## RED-GREEN chain (per plan item / SC)

| Step | How | Purpose |
|------|-----|---------|
| red | write or run the failing assertion; confirm it fails for the stated reason | the defect is demonstrated, not assumed |
| green | minimal change that turns it green | no speculative additions |
| post-regression | re-run the affected tiers (smoke + changed-area regression) | nothing previously working broke |
| verify-inline | the executed check's output is the evidence | never assert success without a run |
| commit | stage the item's files; atomic, descriptive message | one item, one commit |

## Test tiers

Default per implementation cycle and per PR: smoke + regression. The full
suite is never the default — running everything every cycle leaves no
capacity for the work itself.

| Tier | Contents | When |
|------|----------|------|
| smoke | fastest end-to-end signals: the system builds/boots and the touched path basically works | every cycle, before commit |
| regression | tests covering the changed area and its direct dependents | every cycle, before commit and PR |
| full | the entire suite | release boundaries, explicit developer request, or when tiered runs cannot isolate a failure |

Choosing tiers for a given change is judgment — what changed decides what
regression covers. No script decides scope.

## Post-implementation

| Step | How | Purpose |
|------|-----|---------|
| structural | project-local lint/typecheck/build commands | cheap mechanical facts first |
| verify pass | dispatch the `verify` card's single fresh-context reviewer | one bounded review; churn rule applies |
| PR prep | `git-workflow-pr` conventions | review context for the human gate |

Escalation: any step that cannot complete honestly stops the cycle — report
the state, the blocker, and what is needed; never fabricate a pass.
