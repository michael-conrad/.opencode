# git-workflow-pr §2(f): submodule-first PR ordering must be stated positively

Source: converted from this record's filed bug report (2026-11-06, triage verdict: actionable work — a deck-text defect with a structural one-clause fix).

## Problem

`git-workflow-pr` §2(f) states the block — "parent-repo PR creation is blocked while any submodule PR is pending (filed and unmerged on the submodule's tracker)" — but states no positive ordering for a multi-repo change. In field use an agent derived an order from the gate's existence alone and got it backwards: it filed the parent PR first, citing §2(f) as its authority ("the parent PR is filed first per the submodule-PR ordering gate"). The agent reported compliance while violating the gate. The developer caught it by reading the PR filing order.

Worse composition: the incident occurred on GitBucket, where the agent cannot close an out-of-order parent PR non-interactively (`gb pr edit --state closed --web` requires the developer's terminal password). A single gate mis-read produced an undispellable artifact — the wrong-order parent PR (NewsRx parent `5-deploy-test-triage` #5, filed alongside Scraper-Shared #12 and NewsRxUI #93, SUDC#5 triage session 2026-11-05) still stands open.

## Incident record (evidence basis)

- Session 2026-11-05, SUDC#5 triage (NewsRx family repos).
- Filed: Scraper-Shared PR #12 and NewsRxUI PR #93 open → parent PR #5 filed the same turn, body asserting the inversion as gate-compliant.
- Expected shape seen in the same session's earlier SUDC#1 work: submodule branch + tag push, no parent PR — the compliant sequence.
- Related history: §2(f)/§2(g) provenance .opencode#2639, .opencode#2679.

## Scope

`git-workflow-pr` §2(f) text only — a positive-ordering statement added beside the existing block. No changes to §2(d-2) or §2(g), no tooling, no hook.

## Requirements

- R-1 (structural): §2(f) SHALL state positively that the submodule PRs of a multi-repo change are filed and merged first, and the parent PR is filed only after the submodule trunks carry the merged pointers the parent PR bumps.
- R-2 (structural): §2(f) SHALL note the GitBucket cost of the mis-read — an out-of-order parent PR cannot be closed by the filing agent on GitBucket, so the error is undispellable without developer action.
- R-3 (behavioral): an agent working a multi-repo change SHALL file submodule PRs first and halt parent-PR creation until the submodule PRs merge — the sequencing gate continues to bind parent-PR creation.

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | skill card §2(f) contains the positive ordering statement (submodule PRs filed and merged first; parent PR filed after the pointers it carries are merged) | structural | read git-workflow-pr/SKILL.md, locate the ordering sentence |
| SC-2 | skill card §2(f) contains the GitBucket undispellable-PR cost note | structural | read git-workflow-pr/SKILL.md, locate the cost sentence |
| SC-3 | In a simulated multi-repo change with open submodule PRs, the agent does not create a parent PR and reports the gate as the reason | behavioral | tests-v2 behavioral scenario |

## Out of scope

- §2(d-2) hash-permanence verification and §2(g) findings.
- GitBucket close-ability tooling (its own tracker capability gap).
- Hooks/scripts enforcing the order mechanically.

## Approach

Edit `git-workflow-pr` directly on the §2(f) sentence: append the positive ordering clause and the GitBucket cost note in the same passage (single-sourcing). Route through the deck's governance card via the deck repo's PR process (pull-only boundary respected; authoring happens upstream, PR merges human-only).
