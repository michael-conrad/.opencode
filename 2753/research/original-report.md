<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: original bug-report body of michael-conrad/.opencode#2753 (remote
     tracker), preserved verbatim at work-entry conversion (2026-11-19). The record
     this body filed now reads as the spec (spec.md, same folder); this file is the
     field-evidence record, not the governing artifact. -->

# Original bug report — .opencode#2753 (filed 2026-11-19, title as filed)

`release-promoter: composition must promote every registered submodule to its
remote trunk tip — no-remote-tip pointers and git-add re-resolution shipped
unfetchable gitlinks twice in one release (2026-11-19)`

## Problem

Release composition in `release-promoter` can ship a parent's recorded submodule
pointer that is **behind the submodule's remote trunk tip** — and behind a
pointer that clean-room tooling cannot even fetch — and the pointer-capture
commit can **silently revert a recorded promotion**. Both failure modes fired
twice inside one release run today (2026-11-19, `PM_Xml2Dbf_Feed`, batch 6,
branch `release/submodule-pointer-updates-6`):

1. **Stale, unfetchable pointer shipped at composition.** The `doaj` checkout
   sat on feature branch `106-silence-migration-logging` (symbolic HEAD, no
   remote tip, dirty worktree). The executed comparison recorded
   `no-remote-tip`; composition left the recorded pointer `0ce8954b` in the
   release candidate. The clean-room gate DRIFT_FAILed on `doaj` — the pinned
   SHA is not fetchable from the remote (`Server does not allow request for
   unadvertised object`) — so the candidate was not consumable at all. The doaj
   trunk tip (`origin/master` `67189c31`, its v2.0.2 release commit) was
   behind-free and fetchable and did **not** enter the release.
2. **Capture commit silently dropped the promotion.** Recomposition recorded
   the promoted doaj gitlink through index plumbing (`git rm --cached` +
   `git update-index --add --cacheinfo 160000,<sha>,doaj`), but the recording
   commit then ran `git add CHANGELOG.md doaj` — which **re-resolved the
   gitlink from the dirty checkout HEAD (`0ce8954b`)**, silently discarding the
   promotion. Commit `888d664` shipped with the pointer unchanged (1 file
   changed: changelog only). The second clean-room run reproduced the identical
   DRIFT_FAIL before the cause was found. The final correct capture
   (`d7a174f`) was recorded via plumbing alone with a post-commit assertion
   (`git ls-tree HEAD doaj` == `67189c3`), no `git add` on the submodule.

**Governing rule as stated by the developer (2026-11-19): every registered
repo is pulled to its remote trunk tip for a release PR — always.** Composition
is done when the executed per-submodule comparison returns `at-tip` for every
registered submodule; a repo whose remote trunk tip cannot be resolved blocks
composition for developer direction. The current card text
(`git-workflow-branch` rule 2 / release-promoter Phase C-0) allows
`no-remote-tip` to be *recorded and the composition to proceed anyway* — that
recorded-and-continue posture is the regression's root.

## Scope

Amend the deck's release composition and pointer-capture procedure so a release
candidate can never be composed from a non-trunk-tip pointer, and a capture
commit can never ship without the promoted SHA verified in the commit.

## Requirements

- **R-1** — The composition phase SHALL promote every registered submodule's
  recorded pointer to that submodule's remote trunk tip (tracked branch per
  `.gitmodules` branch field, else the remote default branch via `origin/HEAD`)
  before any gate runs.
- **R-2** — Composition SHALL NOT proceed with any registered submodule whose
  remote trunk tip cannot be resolved or fetched: halt for developer direction.
  The release path has no recorded-and-continue posture for `no-remote-tip`.
- **R-3** — Release pointer recording SHALL NOT pass through
  `git add <submodule-path>` when the submodule checkout's HEAD differs from
  the promoted SHA; record via index plumbing or check out the promoted SHA
  first. A mandatory post-capture assertion — `git ls-tree HEAD <path>` ==
  promoted SHA for every promoted submodule — SHALL gate the capture commit
  before push.
- **R-4** — Clean-room `DRIFT_FAIL` diagnosis SHALL distinguish a pinned SHA
  that is not fetchable remotely (composition defect → recompose) from a
  fetchable-but-mismatched pointer (candidate defect → release blocked).
- **R-5** — The card text (`release-promoter` SKILL.md + operating-protocol.md,
  with the `git-workflow-branch` rule-2 release carve-out referenced
  accordingly) SHALL state the trunk-tip mandate and blocking disposition
  verbatim in structure: all repos at remote trunk tips in a release PR, always;
  no partial composition.

## Impact

- **Consumers:** every family repo running `release-promoter`
  (PM_Xml2Dbf_Feed and siblings); release PR correctness.
- **Risk:** composition now blocks on unresolvable submodule tips (intended);
  the capture-commit assertion adds one cheap pre-push check. No
  runtime/production code affected — deck procedure only.
- **Blast Radius of the defect today:** two burned clean-room gate runs on one
  release; a release PR could have been filed with an unfetchable doaj pointer
  that every future clone would fail on (`submodule update --init` on a shallow
  clone).

## Approach

- Update `release-promoter` Phase C-0: promotion is universal (every registered
  submodule), `no-remote-tip` with a resolvable default branch is promoted to
  it, an unresolvable/unfetchable tip halts composition; composition outcome
  states at-tip for all 16/N submodules as the success evidence.
- Update the pointer-capture step: plumbing-first recording, followed by the
  mandatory `git ls-tree` equality assertion per promoted submodule (push gated
  on it).
- Update the gate's DRIFT_FAIL triage table (R-4).
- Cross-reference `git-workflow-branch` rule 2's release carve-out so the two
  cards do not drift.

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | Card text states the trunk-tip mandate and blocking disposition; no recorded-and-continue posture remains on the release composition path | structural | grep `release-promoter/SKILL.md` + `operating-protocol.md` for the mandate clause; assert zero "recorded as the instrument's own outcome" language remains on the release composition path |
| SC-2 | A submodule checkout behind its remote trunk tip (or detached on a feature branch) is promoted to the remote trunk tip in the composed candidate | behavioral | fixture run of composition; assert parent gitlink SHA == submodule remote trunk-tip SHA after promotion |
| SC-3 | An unresolvable/unfetchable submodule trunk tip halts composition before any gate or PR | behavioral | fixture with unreachable ref; assert composition aborts with the named halt outcome and no release branch/PR filed |
| SC-4 | Pointer recording with checkout HEAD ≠ promoted SHA yields the promoted SHA in the capture commit | behavioral | fixture capture commit over a dirty foreign-HEAD checkout; assert `git ls-tree HEAD <path>` == promoted SHA |
| SC-5 | A capture commit whose gitlink ≠ promoted SHA fails the pre-push assertion | behavioral | run the asserted capture step on a tampered candidate; assert non-zero exit naming the mismatching submodule before any push |

## Out of scope

- Changing the clean-room gate's no-retry rule for assertion failures
  (`DRIFT_FAIL`, `BUILD_FAIL`).
- Human-merge boundaries; submodule push policies (pull-only delivery clause);
  nested-submodule promotion (registered top-level pointers only).
- The `doaj#106` feature-branch work itself — its pointer lands in a release
  only when its trunk tip moves.
- Backfilling already-merged releases (batches 1–5) — the regression was caught
  in-room both times before filing.
