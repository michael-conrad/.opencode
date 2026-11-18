<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Spec — release-promoter: release-candidate composition promotes submodule pointers to remote trunk tips before the release PR

**Issue:** michael-conrad/.opencode#2750

## 1. Intent and Executive Summary

**Problem Statement.** The deck's release workflow never promotes the parent
repository's submodule pointers to the submodules' remote trunk tips before
preparing a release PR. The `release-promoter` card starts at Phase A entry
criteria that presuppose a pushed release branch with already-recorded
pointers; every "pointer capture" mention in the card and its operating
protocol verifies pointers the release branch already records — none
performs capture against the submodules' remote trunk tips. No card wires
the trunk-tip pointer promotion into the release entry path:
`git-workflow-branch` rule 2(b) mandates the sync in general — at branch
creation — but the reported failure halts before any branch exists, and no
card instructs promoting pointers to trunk tips before release analysis and
gate.
In a consumer repo whose real deliverables live in git submodules, an agent
asked to create a release PR surveys the parent trunk, finds zero
parent-repo commits since the last release tag, and halts with "there's
nothing to put in a release PR" — or, had it proceeded, would have filed a
release PR re-verifying stale bitrotted pointers.

**Root Cause / Motivation.** Three gaps compose into the failure:

1. `release-promoter` (SKILL.md rule 0 and the operating protocol) has no
   candidate-composition phase: its Phase A verifies whatever the release
   branch records, and the clean-room gate's drift assertion compares the
   resolved SHA against the pinned SHA — both derived from the parent's
   recorded gitlinks — so the gate verifies stale pointers clean and cannot
   establish currency.
2. `changelog-generator` rule 1's source of truth is `git log
   <last-tag>..HEAD` — parent commits only. Submodule work shipped since
   the last tag is invisible to release analysis, producing the fabricated
   nothing-to-release verdict.
3. `git-workflow-branch` rule 2(b) already mandates the sync of each
   submodule pointer to its remote trunk tip — but rule 2(c) defers
   pointer-only parent changes to "the next real parent change", which in
   a release flow never arrives, and nothing wires rule 2's instrument into
   the release entry path. The deck already sanctions pointer-only release
   PRs (`git-workflow-pr` §2(e) exempts release PRs from the
   no-pointer-only-PR prohibition) yet never instructs composing them.

It must be solved now: every release request in a submodule-deliverables
consumer repo hits the false negative, and the deck's own
`git-workflow-pr` §2(g) already names stale-pointer PRs as the bitrot
defect — the release path is the one flow that never received the same
currency mandate.

**Approach Chosen.** Add a release-candidate composition phase to the
`release-promoter` card — carried on the SKILL.md rule inventory, the
SKILL.md description, and the operating protocol — ordered before Phase A
entry criteria: pull the parent trunk to its remote tip; sync every
registered submodule's pointer to that submodule's remote trunk tip using
`git-workflow-branch` rule 2's executed per-submodule remote-tip
comparison (per-path, non-recursive); record the promoted bumps in the
release branch as the release's real content under rule 3's tagged-SHA
pointer discipline; compose the changelog from the parent range plus the
per-submodule ranges between recorded pointers and promoted tips; then run
the clean-room gate on the composed tree; then file the release PR. Add
the release carve-out to `git-workflow-branch` rule 2(c), and compose
`changelog-generator`'s source of truth for parent/submodule families.

**Alternatives Considered & Why Discarded.**

- *Assert currency inside the clean-room gate:* rejected — the gate is a
  read-only verification of the release branch from a clean-room clone; it
  has no authority to move the release branch's pointers, and mixing
  composition into verification would break the gate's own
  never-modifies-the-source-tree boundary.
- *Extend `git-workflow-branch` rule 2 into the release path without
  touching `release-promoter`:* rejected — rule 2 loads at branch
  creation, and the reported failure halts before any branch exists (the
  nothing-to-release survey precedes branching); the release card owns
  the release entry flow, so the composition phase must live there. The
  2(c) carve-out is still required so the two cards do not contradict.
- *Teach only the changelog to see submodule ranges:* rejected — it fixes
  the analysis half but leaves no instruction to promote and record the
  pointers, so the release branch still carries stale gitlinks and the
  gate still verifies them clean.
- *Let the consumer repo file pointer-update PRs outside the release
  flow:* rejected — the deck forbids pointer-only parent PRs except for
  releases (`git-workflow-pr` §2(e)); the historical
  "release-submodule-pointer-updates" release branches the report
  documents are exactly the release exemption doing this work, which the
  deck never codified.

**Key Design Decisions.**

- The composition phase lives in `release-promoter` (the entry card), not
  in the gate — composition writes in the working flow, verification stays
  read-only in the clean room. Tradeoff: the release card grows a pre-gate
  phase; the gate's mechanics stay untouched.
- The promotion reuses `git-workflow-branch` rule 2's comparison by
  reference, single-sourcing the instrument. Tradeoff: the reference
  depends on that rule's numbering staying stable, or being updated in
  the same change.
- The 2(c) carve-out is minimal — release preparation is named as the real
  parent change that carries the drift — rather than repealing the
  deferral, which stays correct for non-release pointer-only drift.
  Tradeoff: two cards reference the release case.
- Behavioral evidence is a tier-2 harness run (GitBucket container), not
  a tier-1 text-judging dispatch: the regression was witnessed runtime
  behavior in a consumer repo, and card-text judgment is the evidence
  class that stood by while it shipped.

**User Intent / Original Prompt.** The bug report (remote issue
michael-conrad/.opencode#2750, filed 2026-11-18) states: "The `.opencode`
deck's release/dispatch workflow does not include the mandatory step of
updating the parent repository's submodule pointers to each submodule's
remote trunk tip before preparing any release PR"; expected behavior:
"For any release PR, the workflow must first pull/record all submodule
pointers at the submodules' remote trunk tips (pointer capture against
trunk tip, not stale recorded pointers), then run the clean-room gate on
the composed tree, then file the release PR"; actual behavior: "The agent
surveyed the parent trunk, found zero parent-repo commits since the last
release, and stopped with 'there's nothing to put in a release PR' —
regressing into broken behavior instead of promoting the submodule
pointer updates into a release PR." The developer's triage dispatch
(session, 2026-11-18), verbatim: "PRs are supposed to be pulled to remote
trunk tip as a standard matter of course, not be ignored and used as a
fabricated reason to not file a release PR or to file a PR using stale
bitrotted code."

## 2. Not Included

- Regular (non-release) parent-PR pointer currency — owned by
  `git-workflow-pr` §2(g); no new rules.
- The clean-room gate's internal mechanics (drift assertion, build/test
  command discovery, failure taxonomy) — unchanged.
- Phase B post-merge re-check, tag creation, and GitHub Release mechanics
  — unchanged.
- `ci-boundary` — no CI, runner, or checkout-configuration change.
- The reporting consumer repo's own stale-pointer state — its next release
  exercises the fixed workflow; the consumer repo's repository state is
  not this deck change's deliverable.

## 3. Requirements

- **R-1:** The `release-promoter` card SHALL carry a release-candidate
  composition phase on each of its three surfaces — the SKILL.md rule
  inventory, the SKILL.md description, and the operating protocol — that,
  for every release PR, pulls the parent repository's trunk to its remote
  tip and syncs every registered submodule's pointer to that submodule's
  remote trunk tip (the tracked-branch tip per `.gitmodules`, fetched from
  the remote, not the recorded pointer), using `git-workflow-branch`
  rule 2's executed per-submodule remote-tip comparison as the evidence
  instrument, per-path and non-recursive.
- **R-2:** The `release-promoter` card SHALL state the fixed order —
  compose (promote pointers at trunk tips), record the release branch,
  run the clean-room gate on the composed tree, file the release PR — and
  SHALL state that a release PR is never filed from pointers that were
  not promoted at composition time.
- **R-3:** The `release-promoter` card SHALL state that promoted pointer
  bumps are the release's real content and are recorded in the release
  branch as pointer-capture commits under `git-workflow-branch` rule 3's
  tagged-SHA pointer discipline (the release exemption
  `git-workflow-pr` §2(e) already states).
- **R-4:** `git-workflow-branch` rule 2(c) SHALL carry a release
  carve-out: the pointer-only deferral ("drift rides with the next real
  parent change") SHALL NOT apply while the session is preparing a
  release — release preparation is itself the real parent change that
  carries the drift.
- **R-5:** `changelog-generator`'s source-of-truth rule SHALL compose,
  in a parent/submodule repository family, the parent repository's commit
  range since the last release tag with each submodule's commit range
  between the recorded pointer and the promoted trunk tip.

## 4. Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | The `release-promoter` card's three surfaces (SKILL.md rule inventory, SKILL.md description, operating protocol) carry the release-candidate composition phase: parent trunk pulled to its remote tip and every registered submodule pointer synced to its remote trunk tip via `git-workflow-branch` rule 2's executed per-submodule remote-tip comparison, per-path and non-recursive. | Structural | Card-text fact check: read the three surfaces and verify the phase's presence, its promotion mechanics, and the instrument reference; the check fails if any surface lacks the phase or names the recorded pointer where the remote tip is required. |
| SC-2 | The card states the fixed order (compose → record → clean-room gate → release PR) and the prohibition on filing a release PR from pointers not promoted at composition time. | Structural | Card-text fact check: read the SKILL.md rule inventory and the operating protocol for the ordering statement and the un-promoted-pointer prohibition. |
| SC-3 | The card states that promoted pointer bumps are the release's real content and are recorded in the release branch under `git-workflow-branch` rule 3's tagged-SHA pointer discipline. | Structural | Card-text fact check: read the composition-phase text for the real-content statement and the rule 3 discipline reference. |
| SC-4 | `git-workflow-branch` rule 2(c) carries the release carve-out: the pointer-only deferral does not apply while the session is preparing a release. | Structural | Card-text fact check: read rule 2(c) and verify the carve-out names release preparation as the carrying change. |
| SC-5 | `changelog-generator`'s source-of-truth rule composes the parent commit range with each submodule's commit range between the recorded pointer and the promoted trunk tip. | Structural | Card-text fact check: read the source-of-truth rule and verify the composed ranges for parent/submodule families. |
| SC-6 | Under the revised deck, an agent asked to create a release PR in a consumer repo whose parent trunk has no commits since the last release tag while a registered submodule's remote trunk tip is ahead of the parent's recorded pointer: executes the per-submodule remote-tip comparison, promotes the submodule pointer to the trunk tip, composes the release branch carrying the bump, and proceeds into the clean-room gate — and does not halt with a nothing-to-release conclusion. | Behavioral | Tier-2 tests-v2 behavioral scenario (SCENARIO_TIER=2, BEHAVIOR_NEEDS_REMOTE=1 — the harness's self-contained GitBucket container per tests-v2 AGENTS.md §12) with a fixture seeding a parent repo and a submodule repo carrying the drift state and a prior release tag; the standard clean-room evaluator dispatch (behavioral-testing card §5) reads session.yaml against this criterion. |

## 5. Dependencies

| Reference | Relationship | Status |
|-----------|---------------|--------|
| `git-workflow-branch` rule 2 (executed per-submodule remote-tip comparison) | The composition phase references this instrument; the rule's numbering must remain stable or the reference must be updated in the same change. | Satisfied — card read 2026-11-18. |
| `git-workflow-pr` §2(e) (release exemption), §2(d-2) (tag-pushed gate), §2(g) (pointer currency) | R-3 relies on §2(e)'s existing exemption; pull-only and tag-push interactions stay owned by §2(d-2); non-release currency stays owned by §2(g). | Satisfied — card read 2026-11-18. |
| `.opencode/tests-v2/` harness, AGENTS.md §12 (GitBucket container) | SC-6's behavioral evidence runs on this harness with its provisioned remote. | Satisfied — harness present, container mechanism grep-verified 2026-11-18. |
| `skill-creator` (deck governance admission gate) | The implementation edits `skills/` content and goes through the gate and the deck repo's PR process. | Satisfied — gate exists; loads at implementation. |

## 6. Traceability

| Requirement | Success criteria |
|-------------|------------------|
| R-1 | SC-1, SC-6 |
| R-2 | SC-2, SC-6 |
| R-3 | SC-3 |
| R-4 | SC-4 |
| R-5 | SC-5 |

## 7. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| michael-conrad/.opencode#2750 (remote issue body) | Bug report | github.com/michael-conrad/.opencode/issues/2750 | Read via `gh issue view`, 2026-11-18. |
| Developer triage dispatch | Developer statement | This session, 2026-11-18 | Received verbatim; quoted in §1. |
| `skills/release-promoter/SKILL.md`, `references/operating-protocol.md` | Deck card + protocol | Deck repo (`.opencode/`) | Read in full 2026-11-18; grep of pointer-capture mentions shows all verification-side, none composition-side. |
| `skills/git-workflow-branch/SKILL.md` | Deck card | Deck repo | Read in full 2026-11-18 (rule 2 instrument, rule 2(c) deferral, rule 3 discipline). |
| `skills/git-workflow-pr/SKILL.md` | Deck card | Deck repo | Read in full 2026-11-18 (§2(e) release exemption, §2(f) ordering gate, §2(g) currency). |
| `skills/changelog-generator/SKILL.md` | Deck card | Deck repo | Read in full 2026-11-18 (rule 1 source of truth, rule 6 pointer capture). |
| `skills/behavioral-testing/SKILL.md` | Deck card | Deck repo | Read 2026-11-18 (tier classes, clean-room evaluator contract). |
| `tests-v2/AGENTS.md` §12 | Harness reference | Deck repo | Grep-verified 2026-11-18 (BEHAVIOR_NEEDS_REMOTE, GitBucket container). |

## 8. Cost Frame

- **SC-6 (tier-2 run):** acting costs one supervised harness cycle —
  fixture authoring (parent and submodule repos on the GitBucket
  container, drift state, prior release tag), a supervised model run, and
  a clean-room evaluation dispatch. Skipping it costs shipping the fix
  verified only by text judgment — the same evidence class that stood by
  while the reported regression shipped; no card-text check can observe
  the nothing-to-release halt, and the defect's consumers are every
  release request in a submodule-deliverables consumer repo.
- **SC-1..SC-5 (card-text checks):** acting costs read/grep checks over
  four card files; skipping costs surface drift — a card whose body
  carries a phase its description omits misroutes agents at load time,
  and `release-promoter`, `git-workflow-branch`, and
  `changelog-generator` must not contradict one another on the release
  case.

## 9. Edge Cases

| Condition | Expected behavior | Resolution |
|-----------|-------------------|------------|
| A submodule's remote is unreachable at composition time. | The composition cannot establish trunk-tip currency; the agent halts for developer direction per `git-workflow-branch` rule 2's unreachable-remote handling — never a nothing-to-release verdict. | The composition-phase text names the unreachable-remote outcome as a halt, not a skip. |
| A registered submodule's trunk tip equals its recorded pointer (at-tip). | No promotion for that submodule; the release proceeds; the changelog carries no section for it. | The composition treats at-tip as a no-op for that pointer. |
| A pull-only submodule origin (http/https). | The promotion records the fetched trunk tip; the tagged-SHA push cannot succeed and is reported per `git-workflow-branch` rule 3's pull-only clause; `git-workflow-pr` §2(d-2)'s tag-pushed gate governs PR creation. | No new path — existing rules govern. |
| Nested submodules below a registered submodule. | Composition promotes only registered top-level pointers; operations stay per-path and non-recursive (floor + rule 3 prohibition). | Unchanged existing rule. |
| The parent trunk has commits since the last release tag while submodules also moved. | Both compose the release: the release branch carries parent commits and pointer bumps; the changelog composes both ranges. | The composition phase and the composed source of truth cover both. |
| All submodules at-tip; the parent has commits since the tag. | The composition phase is a pointer no-op; the release proceeds on parent content — the new phase never blocks plain parent-only releases. | The composition phase states the no-op outcome explicitly. |

## 10. Completion gate

Every success criterion passes before the deliverable is complete;
partial implementation is not permitted — a revision that adds the
composition phase to some surfaces, leaves rule 2(c)'s deferral intact,
or keeps the changelog source of truth parent-only is not a complete
deliverable.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
