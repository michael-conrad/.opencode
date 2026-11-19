<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Spec — release-promoter: composition promotes every registered submodule to its resolvable remote trunk tip; plumbing-first pointer capture gated by a post-commit gitlink assertion

**Issue:** michael-conrad/.opencode#2753

## 1. Intent and Executive Summary

**Problem Statement.** Release composition can ship a parent repository's
recorded submodule pointer that is behind that submodule's remote trunk tip —
and behind a pointer the clean-room gate cannot even fetch — and the
pointer-capture commit can silently revert a recorded promotion. Topology, so
the relational nouns bind: the release composes the **parent repository's**
release candidate; each **registered submodule** (per the parent's
`.gitmodules`) ships through the **parent's recorded pointer** (gitlink); a
submodule's **remote trunk tip** is the fetched tip of its tracked branch on
that submodule's own origin. Both failure modes fired twice inside one
release run (2026-11-19, `PM_Xml2Dbf_Feed`, batch 6, branch
`release/submodule-pointer-updates-6`):

1. **Stale, unfetchable pointer shipped at composition.** The `doaj`
   submodule checkout sat on feature branch `106-silence-migration-logging`
   (symbolic HEAD, no remote tip, dirty worktree). The executed comparison
   recorded `no-remote-tip`; composition left the recorded pointer `0ce8954b`
   in the release candidate. The clean-room gate DRIFT_FAILed on `doaj` — the
   pinned SHA is not fetchable from the remote (`Server does not allow
   request for unadvertised object`) — so the candidate was not consumable at
   all, while the doaj trunk tip (`origin/master` `67189c31`, behind-free and
   fetchable) did not enter the release.
2. **Capture commit silently dropped the promotion.** Recomposition recorded
   the promoted doaj gitlink through index plumbing (`git rm --cached` +
   `git update-index --add --cacheinfo`), but the recording commit then ran
   `git add CHANGELOG.md doaj` — which re-resolved the gitlink from the dirty
   checkout HEAD (`0ce8954b`), silently discarding the promotion (commit
   `888d664`, changelog only). The second clean-room run reproduced the
   identical DRIFT_FAIL before the cause was found. The final correct capture
   (`d7a174f`) was recorded via plumbing alone with a post-commit assertion
   (`git ls-tree HEAD doaj` == `67189c3`), no `git add` on the submodule.

**Root Cause / Motivation.** The composition phase's delivered text
(`.opencode#2750`) allows a `no-remote-tip` outcome to be recorded while
composition proceeds — the operating protocol's step 3 reads *"no-remote-tip
is synced when a branch resolves, else recorded as the instrument's own
outcome"*, and its step 4 halts only on an unreachable submodule remote —
and the phase's branch-resolution chain (restating `git-workflow-branch`
rule 2(b')) resolves the trunk tip from the submodule checkout's **current
checked-out branch** when `.gitmodules` carries no branch field, which for a
feature-branch checkout has no remote tip at all. The pointer-capture step
mandates no recording mechanism and no post-capture assertion, so a
`git add <submodule-path>` over a dirty foreign-HEAD checkout silently
reverts the recorded promotion. It must be solved now: every family release
composes through this phase; the field run burned two clean-room gate cycles
in one day and nearly filed a release PR whose recorded pointer every future
shallow clone would fail on.

**Approach Chosen.** Make promotion universal and blocking: the composition
phase promotes every registered submodule to its resolved remote trunk tip —
the `.gitmodules` `submodule.<name>.branch` field, else the submodule
remote's default branch (`refs/remotes/origin/HEAD`), never the checkout's
current branch — and a registered submodule whose remote trunk tip cannot be
resolved or fetched halts composition for developer direction. Composition
is done when the executed per-submodule comparison returns `at-tip` for every
registered submodule, and that outcome is the success evidence. The capture
commit records via index plumbing (or a checked-out promoted SHA) and is
gated before push by a mandatory `git ls-tree HEAD <path>` == promoted SHA
assertion per promoted submodule. The gate's `DRIFT_FAIL` triage gains the
composition-defect/candidate-defect distinction, and the
`git-workflow-branch` rule-2 release carve-out is cross-referenced so the
two cards do not drift.

**Alternatives Considered & Why Discarded.**

1. Keep the recorded-and-continue posture and teach the clean-room gate to
   fetch harder (for example, deepen the shallow submodule fetch). Discarded:
   an unfetchable pinned SHA is not a fetch-depth artifact — the remote's
   `Server does not allow request for unadvertised object` means the remote
   does not serve the object at all; composing from a pointer the remote will
   not serve ships a candidate every future clone fails on. The mandate is
   at-tip pointers, not better retrieval of stale ones.
2. Resolve the trunk tip from the checkout's current branch when that branch
   has a remote tip (keep rule 2(b')'s chain, halt only when it lacks one).
   Discarded: a feature-branch checkout with its own remote tip would then
   promote a feature branch into a release — the mandate is the remote trunk
   tip; the release path must not resolve tips from whatever branch happens
   to be checked out.
3. Fix capture by always checking out the promoted SHA before recording (no
   plumbing path). Discarded: a dirty checkout with uncommitted work cannot
   always be moved; index plumbing records the promoted gitlink without
   touching the checkout — the field run's final correct capture used exactly
   that. The post-capture assertion gates the recording either way.

**Key Design Decisions.**

1. The release path's resolution chain drops the checkout's-current-branch
   fallback and diverges from `git-workflow-branch` rule 2(b')'s general chain
   deliberately (as the composition phase already diverges from rule 2's
   bounded posture on unreachable remotes). Tradeoff: two chains to keep
   aligned — R-5's cross-reference does that; in exchange, the release path
   cannot land on a feature branch.
2. Unresolvable or unfetchable trunk tips halt composition rather than
   recording. Tradeoff: composition can block on a broken submodule remote —
   intended; the alternative ships unverifiable pointers, which is the exact
   field failure.
3. Capture records via index plumbing with a mandatory post-capture `git
   ls-tree` equality assertion; `git add <submodule-path>` is prohibited
   when the submodule checkout's HEAD differs from the promoted SHA.
   Tradeoff: one extra assertion command per capture — it catches the silent
   re-resolution class the field run hit twice.
4. `DRIFT_FAIL` triage gains the fetchability distinction. Tradeoff: the
   gate's no-retry rule is untouched (out of scope) — the triage only names
   which failure class fired and its route: recompose (composition defect)
   versus release blocked (candidate defect).

**User Intent / Original Prompt.** The developer's statements and the filed
report this spec derives from, quoted verbatim:

- Developer statement, 2026-11-19 (recorded in the filed report): *"every
  registered repo is pulled to its remote trunk tip for a release PR —
  always."* and *"Composition is done when the executed per-submodule
  comparison returns `at-tip` for every registered submodule; a repo whose
  remote trunk tip cannot be resolved blocks composition for developer
  direction."*
- The filed report's Requirements section (R-1..R-5, 2026-11-19) — this
  spec's §3 carries them, with R-1's resolution chain restated to name the
  release path's deliberate divergence from rule 2(b')'s general chain.
- Observed failures: the two field failure modes above (2026-11-19,
  `PM_Xml2Dbf_Feed` batch 6; commits `888d664`, `d7a174f`; two DRIFT_FAIL
  clean-room runs).

## 2. Not Included

- The clean-room gate's no-retry rule for assertion failures (`DRIFT_FAIL`,
  `BUILD_FAIL`) — unchanged.
- Human-merge boundaries; submodule push policies (the pull-only delivery
  clause); nested-submodule promotion (registered top-level pointers only).
- `git-workflow-branch` rule 2's branch-decision posture outside the release
  carve-out — the general branch path keeps its bounded
  recorded-not-remediated posture; R-5 aligns only the release carve-out's
  cross-reference.
- The `doaj#106` feature-branch work itself — its pointer lands in a release
  only when its trunk tip moves.
- Backfilling already-merged releases (batches 1–5) — the regression was
  caught in-room both times before filing.

## 3. Requirements

- **R-1:** The composition phase SHALL promote every registered submodule's
  recorded pointer to that submodule's remote trunk tip before any gate runs.
  The trunk tip resolves through the `submodule.<name>.branch` field of the
  parent repository's `.gitmodules`, else the submodule remote's default
  branch (`refs/remotes/origin/HEAD`, ref existence guarded before use); the
  release path never resolves the trunk tip from the submodule checkout's
  current checked-out branch.
- **R-2:** Composition SHALL NOT proceed with any registered submodule whose
  remote trunk tip cannot be resolved or fetched: the composition halts for
  developer direction. The release path carries no recorded-and-continue
  posture for `no-remote-tip` — an outcome recorded as "the instrument's own
  outcome" while composition proceeds does not exist on the release path —
  and the composition outcome states `at-tip` for every registered submodule
  as its success evidence.
- **R-3:** Release pointer recording SHALL NOT pass through
  `git add <submodule-path>` when the submodule checkout's HEAD differs from
  the promoted SHA; the recording SHALL use index plumbing (`git rm --cached`
  + `git update-index --add --cacheinfo`) or check out the promoted SHA
  first. A mandatory post-capture assertion — `git ls-tree HEAD <path>` ==
  promoted SHA for every promoted submodule — SHALL gate the capture commit
  before push.
- **R-4:** Clean-room `DRIFT_FAIL` diagnosis SHALL distinguish a pinned SHA
  that is not fetchable remotely (composition defect → recompose) from a
  fetchable-but-mismatched pointer (candidate defect → release blocked).
- **R-5:** The card text — `release-promoter` SKILL.md and
  operating-protocol.md, with the `git-workflow-branch` rule-2 release
  carve-out cross-referenced accordingly — SHALL state the trunk-tip mandate
  and blocking disposition in structure: all registered repos at remote
  trunk tips in a release PR, always; no partial composition; and the
  carve-out's cross-reference SHALL name the composition phase's mandate and
  its release-path resolution chain so the two cards do not drift.

## 4. Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | The release-promoter card's composition surfaces (SKILL.md rule 0 and the operating protocol's Phase C-0) state the trunk-tip mandate and the blocking disposition, and no recorded-and-continue posture remains on the release composition path. | Structural | Card-text fact check: read both surfaces; grep the mandate clause and the resolution chain; the check fails if "recorded as the instrument's own outcome" (or equivalent recorded-and-continue language) remains anywhere on the release composition path. |
| SC-2 | A registered submodule checkout behind its remote trunk tip — including one checked out on a no-remote-tip feature branch — is promoted to the resolved remote trunk tip in the composed candidate. | Behavioral | Tier-2 tests-v2 behavioral scenario with a fixture family seeding the field state (parent repo + submodule repo; parent's recorded pointer behind the submodule's `origin/HEAD` trunk tip; submodule checkout on a no-remote-tip feature branch with a dirty worktree); the session composes per the revised card; the evaluator asserts the composed parent's recorded gitlink SHA == the submodule's remote trunk-tip SHA. |
| SC-3 | A registered submodule whose remote trunk tip cannot be resolved or fetched halts composition before any gate runs and before any release branch or PR is filed. | Behavioral | Behavioral scenario with a fixture seeding an unresolvable trunk tip (no `.gitmodules` branch field, no `origin/HEAD` default ref); the evaluator asserts the composition aborts with the named halt outcome for developer direction and that no release branch or PR exists. |
| SC-4 | Pointer recording over a checkout whose HEAD differs from the promoted SHA yields the promoted SHA in the capture commit. | Behavioral | Tier-2 tests-v2 behavioral scenario with a fixture seeding the field failure's state (dirty foreign-HEAD submodule checkout; promoted SHA recorded via the revised card's capture step); the evaluator asserts the capture commit's recorded gitlink — `git ls-tree HEAD <path>` — equals the promoted SHA. |
| SC-5 | A capture commit whose gitlink differs from the promoted SHA fails the mandatory pre-push assertion. | Behavioral | Tier-2 tests-v2 behavioral scenario with a tampered candidate (recorded gitlink ≠ promoted SHA); the session runs the revised card's capture step, whose mandatory assertion gates the push; the evaluator asserts a non-zero exit naming the mismatching submodule and that no push occurred. |
| SC-6 | The gate's `DRIFT_FAIL` triage distinguishes the two failure classes: a pinned SHA not fetchable remotely (composition defect → recompose) and a fetchable-but-mismatched pointer (candidate defect → release blocked). | Structural | Card-text fact check: read the operating protocol's `DRIFT_FAIL` triage; the check fails if the triage names neither class or assigns them the same route. |
| SC-7 | The `git-workflow-branch` rule-2 release carve-out's cross-reference names the composition phase's mandate — the blocking posture and the release-path resolution chain — so the two cards do not drift. | Structural | Card-text fact check: read the carve-out sentence in `git-workflow-branch` rule 2(c); the check fails if it references the composition phase without the mandate's blocking disposition or names the general chain where the release path's chain diverges. |

## 5. Dependencies

| Reference | Relationship | Status |
|-----------|---------------|--------|
| `.opencode#2750` | The prior spec whose delivered composition phase this spec amends: its operating-protocol step-3 "else recorded" clause and its rule-2(b') chain restatement are the defect surfaces R-1/R-2 replace. | satisfied (delivered on trunk; card text read 2026-11-19) |
| `git-workflow-branch` rule 2 + rule 3 | The comparison instrument and the tagged-SHA pointer discipline the composition phase references; the rule-2 release carve-out is the cross-reference R-5 aligns. | satisfied (present; read 2026-11-19) |
| `behavioral-testing` card | The behavioral SCs' instrument surface — the tier-2 tests-v2 harness and clean-room evaluator dispatch. | satisfied (present; `tests-v2/` in the deck) |

## 6. Traceability

| Requirement | Success criteria |
|-------------|-------------------|
| R-1 | SC-1, SC-2 |
| R-2 | SC-1, SC-3 |
| R-3 | SC-4, SC-5 |
| R-4 | SC-6 |
| R-5 | SC-1, SC-7 |

## 7. Documentation Sources

| Source | Type | Location | Verification |
|---------|------|----------|--------------|
| release-promoter SKILL.md | deck card | `skills/release-promoter/SKILL.md` | Read and grepped 2026-11-19: rule 0 carries "`no-remote-tip` is synced when a branch resolves, else recorded". |
| release-promoter operating protocol | card reference | `skills/release-promoter/references/operating-protocol.md` | Read 2026-11-19: step 2 restates rule 2(b')'s chain including the checkout's current checked-out branch; step 3 carries "else recorded as the instrument's own outcome"; step 4 halts only on an unreachable submodule remote; step 8's pointer-capture text mandates no recording mechanism and no post-capture assertion. |
| git-workflow-branch SKILL.md | deck card | `skills/git-workflow-branch/SKILL.md` | Read 2026-11-19: rule 2(b') resolution chain, the release carve-out, and the bounded recorded-not-remediated posture; rule 3's tagged-SHA pointer discipline. |
| `.opencode#2750` spec | prior spec | `.opencode/.issues/2750/spec.md` | Read 2026-11-19: the delivered composition phase's intent, requirements, and SC set. |
| Filed report `.opencode#2753` | field report | remote tracker (`github.com/michael-conrad/.opencode/issues/2753`) | Read via `gh` CLI 2026-11-19: the 2026-11-19 field failure record (`PM_Xml2Dbf_Feed` batch 6; doaj case; commit SHAs `0ce8954b`, `67189c31`, `888d664`, `d7a174f`; two DRIFT_FAIL gate runs). |

## 8. Cost Frame

- **SC-1, SC-6, SC-7 (card-text checks):** acting costs read/grep passes over
  three card files; skipping costs mandate drift between the composition
  phase and the rule-2 carve-out — the drift class that let the regression
  ship as compliant behavior.
- **SC-2..SC-5 (behavioral):** acting costs fixture-family provisioning
  (parent and submodule repos, drift and tamper states), supervised runs,
  and evaluation dispatches; skipping costs the composition defect recurring
  — the field run burned two clean-room gate cycles in one day and a stale
  pointer nearly shipped in a filed PR that every future shallow clone would
  fail on.

## 9. Edge Cases

| Condition | Expected behavior | Resolution |
|-----------|-------------------|------------|
| Checkout on a feature branch with symbolic HEAD and no remote tip (the doaj field state). | The release path's resolution chain falls back to the remote default branch (`origin/HEAD`); the trunk tip promotes; no recorded-and-continue outcome exists. | R-1's chain and R-2's blocking disposition. |
| No `.gitmodules` branch field; detached checkout. | `origin/HEAD` resolves the default branch; ref existence is guarded before use. | R-1's chain, unchanged guard. |
| The submodule remote carries no `origin/HEAD` and the `.gitmodules` branch field's tip is unresolvable. | Composition halts for developer direction — never a fallback to the checkout's current branch, never a recorded-and-continue outcome. | R-2's halt. |
| The tracked branch resolves but its tip is not fetchable (unadvertised object — the field gate error). | Composition halts at resolution (R-2); when such a pointer nonetheless reaches the gate, the `DRIFT_FAIL` triage names it a composition defect → recompose. | R-2 + R-4. |
| Dirty submodule checkout at capture time (HEAD ≠ promoted SHA, uncommitted changes present). | Plumbing-only recording; `git add <submodule-path>` never touches the gitlink; the post-capture assertion verifies the recorded SHA. | R-3. |
| All registered submodules at-tip; the parent trunk has commits since the last release tag (plain parent-only release). | The composition is a pointer no-op and the release proceeds on parent content — the phase never blocks a plain parent-only release by invention (preserved behavior). | Preserved from the delivered phase (`.opencode#2750`). |
| Nested submodules below a registered submodule. | Never promoted — registered top-level pointers only; operations stay per-path and non-recursive. | Unchanged scope. |
| Pull-only submodule origin. | The tagged-SHA pointer discipline and the pull-only clause per `git-workflow-branch` rule 3 govern, unchanged. | Unchanged scope. |

## 10. Completion gate

Every success criterion passes before the deliverable is complete; partial
implementation is not permitted — a revision that makes promotion blocking
but leaves the capture step unasserted, keeps a recorded-and-continue clause
anywhere on the release path, or aligns the composition phase without the
rule-2 carve-out, is not a complete deliverable.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
