<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# [SPEC] Root-repo PRs include every dirty submodule pointer — pre-create disposition gate

## Problem

On 2026-10-22, in parent repo **Butter** (PR #386, branch `feature/flyway-pin-conflict-note`), the agent staged only the two submodule pointers its own work intended (`ButterApi` → `c7e5c95`, `DaoCore2` → `64f75e4`) and left **19 other dirty submodule pointers unstaged**, narrating them in the run record as "pre-existing workspace residue, untouched". `git status --short` at PR time showed 21 modified submodule paths; the PR carried 2. The developer's correction:

> dirty pointers are NOT allowed when create a root repo PR, the pointers are always supposed to be included. This is a regression.

Per that correction: when a parent-repo PR (a PR in the repository that consumes the submodules — the repository whose PRs record submodule gitlinks) is created, **all** currently-dirty submodule pointers are included — the recorded pointer state equals the workspace state at PR time; a parent-repo PR is never filed while any submodule pointer is left dirty, and leaving them is a regression **regardless of which session or sub-agent introduced the dirty state**. The repo history confirms the pattern is established, not exceptional: the prior parent PR (#385, `feature/56-pointer-promotion-playwright-doc`, issue-recorded evidence) was itself a pointer-promotion PR carrying multiple submodule pointer bumps, and the sampled drift pointers all sat on the tagged deployment lineage (`Butter/NN-…` describe output, issue-recorded). The correction was applied in-session after filing (issue-recorded): all pointers staged, `./gradlew build -xtest` → BUILD SUCCESSFUL (236 tasks), body re-edited.

**What the deck carried at incident time.** `git-workflow-pr` §2(d) states the inclusion mandate and pre-dates the incident — it landed 2026-10-11 (`.opencode` #2563, verified in deck git history): *"a parent-repo PR includes pending submodule pointer bumps — a bump exists when the submodule's checked-out HEAD differs from the recorded gitlink."* The failure is therefore not a missing requirement but a requirement that did not bind. Three mechanisms, verified against the live deck text (deck main at this session, 2026-10-31):

- **M-1 — no stated instrument.** Every sibling §2 checklist item carries a concrete check — (d-2) verifies tags by `git ls-remote --tags`, (f) turns on pending-submodule-PR facts, (g) turns on pointer movement. (d) names the inclusion duty but no way to check it; the enumeration of dirty pointers was left to inference, and the un-inferred check is where conduct failed. Whether the incident session ran this deck version is not established by available evidence — the failure's mechanism is the spec's subject either way (no Butter checkout is available to this workspace).
- **M-2 — the residue loophole.** No deck text defines or forbids a "pre-existing residue" classification. `git-workflow-branch` rule 2(c) states a deferral without its collection moment: *"when the parent has nothing to contribute beyond pointer bumps, create no branch and make no commit — the drift rides with the next real parent change."* An agent standing at PR creation with pre-existing drift reads deferral as exemption; the ride-along's collection point — the PR the agent is itself preparing — is unnamed, so the drift never rides. The incident's residue narration is this loophole executed.
- **M-3 — no disposition semantics.** For a dirty pointer whose lineage is unknown the deck says nothing: include or halt is undirected. And no text forbids the checkout-away failure mode — a session "tidying" the workspace by reverting submodules to recorded SHAs, which destroys the deferred promotions the workspace carries.

## Scope

Deck surfaces in the `michael-conrad/.opencode` repository:

- `skills/git-workflow-pr/SKILL.md` — §2(d) strengthened into the pre-create dirty-pointer disposition gate (enumeration instrument, zero-unaccounted requirement, the two dispositions, the no-residue statement, the ride-along collection clause). The gate composes with the existing (d-2) tag-pushed gate, (e) no-pointer-only-PR rule, (f) ordering gate, (g) currency rule, and the commit card's staged-pointer duties — none of which change in operative content.
- `tests-v2/behaviors/` — two behavioral scenarios (positive inclusion, negative gate-catch) on the existing harness, named per the Success criteria's fixture shapes.

Constraint frame:

1. **No scripted enforcement** — no new script instrument or hook. Standing developer ruling on scripted deck surfaces (recorded in `.opencode/.issues/2664/spec.md` §Approach, applied again by #2683): an agent that has misread an utterance will route around an interlock; rule text lives at the decision surface, backed by behavioral evidence.
2. **Single-card rule work** — the rule change is confined to `git-workflow-pr` §2. The branch card's 2(c) deferral sentence and the commit card's staging rules are untouched: the strengthened (d) is the collection point their deferral already points at, and every extra touched card multiplies the whole-card-on-touch conversion cost (the writing-discipline guideline obligates returning the entire card's normative prose on any substantive write).
3. **Compose, don't rewrite** — the strengthened (d) keeps every existing submodule rule's operative content; the added machinery is the enumeration and the disposition vocabulary, not new gates.

## Requirements

- **R-1** — `git-workflow-pr` §2(d) SHALL carry, for every parent-repo PR, a pre-create dirty-pointer enumeration with a stated fact check: every registered submodule (entries tracked by the parent's submodule mechanism per `.gitmodules`) whose checkout state differs from its recorded gitlink — observed on the parent's submodule status listing (each `+` row of `git submodule status`). The rule SHALL require zero unaccounted dirty pointers at PR creation: the PR's staged-and-recorded pointer set equals the workspace's dirty pointer set at create time.
- **R-2** — The strengthened rule SHALL state that a dirty pointer left out of a parent-repo PR is a regression regardless of which session or sub-agent introduced the dirty state, and that "pre-existing" names no disposition and no deck category — no exemption class for pre-existing drift exists anywhere in the rule.
- **R-3** — The strengthened rule SHALL state the two dispositions a dirty pointer receives before PR creation: (a) **include** — the default; the pointer is staged and recorded into the PR's per-issue commit content, satisfying the existing staged-pointer machinery (the (d-2) tag-pushed gate, the commit card's tagged-SHA duty) and the parent's existing composed-state verification; (b) **halt for developer clarification** — an open-ended request per the floor's standing formula, used when the pointer's lineage cannot be established from the session's own record and the submodules' recorded state (tags, branches, trunk tips) — doubt establishes nothing, so it routes to this branch; no third disposition exists. The rule SHALL state that drift is never resolved by checkout-away cleanup: a session does not revert submodules to recorded SHAs to tidy the workspace.
- **R-4** — The strengthened rule SHALL state its composition with the ride-along deferral: drift deferred by `git-workflow-branch` rule 2(c) ("the drift rides with the next real parent change") lands in the PR of that next real parent change — the session preparing that PR performs the inclusion at creation time under this gate; the deferral is a destination, never an exemption. The rule's zero-unaccounted requirement holds over the pointer set assembled at creation time; pointer movement between the branch's capture and PR creation stays (g)'s window — (g)'s update obligation and (d)'s zero-unaccounted read on the same assembled set. R-1..R-3's additions alter no other card rule's operative content and compose with (d-2), (e), (f), (g) as they stand.

## Success criteria

| ID | Class | Criterion | Instrument |
|----|-------|-----------|------------|
| SC-1 | structural | §2(d) states the enumeration instrument (submodule status listing, `+` rows filtered to registered submodules per `.gitmodules`), the zero-unaccounted requirement at PR creation, and the inclusion default — per R-1 | card-text inspection of `git-workflow-pr` §2 against R-1's stated content |
| SC-2 | structural | §2 states the regression naming and the no-residue-category statement with attribution independence, and the remaining deck surface carries no pre-existing-drift exemption language — per R-2 | card-text inspection against R-2 + scoped absence check: grep of `skills/`, `guidelines/`, `floor.md` for dirty-pointer exemption or residue-class wording surviving outside the strengthened rule |
| SC-3 | structural | §2 states the two dispositions (include by default after the parent's composed-state verification; halt with an open-ended clarification when lineage is unestablishable) and the no-checkout-away-cleanup rule — per R-3 | card-text inspection against R-3 |
| SC-4 | structural | The strengthened rule states the 2(c) collection clause, and (d-2), (e), (f), (g) plus every other rule of the card keep their operative content — per R-4 | the change's diff (confined to §2's submodule-pointer block) + read-back of the four items' operative content |
| SC-5 | behavioral | A supervised run prepares a parent-repo PR in a workspace holding both the session's own bump and pre-seeded pre-existing drift (a registered submodule left checked out past its recorded gitlink, the drift SHA covered by a pushed tag on the submodule's remote): the created PR's recorded gitlinks carry **all** dirty pointers — zero unaccounted at create time | a real harness run of a new scenario under `tests-v2/` (the `opencode run` instrument per the `behavioral-testing` card — no grep or static-analysis substitute); evidence is the run transcript and its verdict |
| SC-6 | behavioral (negative) | A dirty pointer the run agent leaves unaccounted (the residue-classified omission the incident shows) is caught at the pre-create gate: the PR is not created until every enumerated pointer carries a disposition; a run omitting one fails the scenario | the same harness, same fixture class, evaluated from the run transcript's disposition enumeration and the created PR's pointer set |

## Traceability

| Observed failure / mechanism | Dispositioned by |
|------------------------------|------------------|
| M-1 (no stated instrument) | R-1, SC-1, SC-5 |
| M-2 (residue loophole — deferral without collection moment) | R-2, R-4, SC-2, SC-4, SC-6 |
| M-3 (no disposition semantics / cleanup failure mode) | R-3, SC-3 |
| The incident's 19 excluded pointers (SC shape) | SC-5, SC-6 |

Every root cause is covered: the missing instrument (R-1/SC-1), the loophole that let "pre-existing" narrate away the requirement (R-2/R-4/SC-2/SC-4), and the missing disposition semantics including the cleanup failure mode (R-3/SC-3). The behavioral criteria test the incident's actual shape — a parent PR amid pre-existing drift.

## Approach

1. **`git-workflow-pr` §2(d)** — rewritten as the disposition gate at the same position, keeping (d)'s original inclusion duty as the head of the strengthened rule: enumerate (the fact check), disposition (include / halt-clarify), create at zero-unaccounted. The strengthened rule references the existing machinery it composes with rather than restating it: (d-2) applies to every recorded pointer including the enlarged set; (e), (f), (g) unchanged.
2. **Whole-card-on-touch duty** — the substantive §2 write obligates returning the entire card's normative prose under the writing discipline (`guidelines/ainglish-writing-discipline.md` adoption rules); the edit is planned with that conversion cost inside it, not deferred.
3. **Deck governance** — the card edit passes through the skill-creator card's gates (admission/retention review of the strengthened rule against the deck's criteria).
4. **`tests-v2/behaviors/`** — two scenarios on the existing harness, following the established fixture patterns (e.g. `2683-sc5-pointer-capture-tagged-sha.sh`, `2683-sc6-untagged-pointer-caught-at-gate.sh`): a parent repo with registered submodules, pre-seeded drift on one of them, a real parent change in flight; assertions read the created PR's gitlinks and the transcript's disposition record. Scenario mechanics follow the `behavioral-testing` card.

The discarded alternative — a pre-PR hook or validator script enumerating dirty pointers — is disposed by the constraint frame's standing ruling (as in #2664, applied in #2683): the gate is rule text the agent reads at the decision moment.

## Edge cases

- **Dirty pointer from a promotion whose submodule PR is still pending:** the (f) ordering gate already blocks parent PR creation until that submodule PR merges — the parent PR waits; no pointer is excluded; the (d) gate's zero-unaccounted holds at creation, after (f)'s precondition resolves.
- **A dirty pointer whose included state fails the parent's composed verification:** the failure is that pointer's state question, not a licence to exclude: the halt-clarify branch disposes the pointer when its state cannot be established as intended (an accidental checkout whose lineage fails verification is unestablished lineage), and in-scope remediation disposes it when the session's own work causes the failure. The parent's own test failures remain governed by the existing §2(b) gate (#2553) — a pointer is never unrecorded to make a red build green: recording the workspace's pointer truth is (d)'s fact, not the build's verdict.
- **Pointer facts vs content dirt:** `git submodule status` (R-1's instrument) reports pointer state only — its `+` prefix is the whole difference fact — and reports no in-worktree content changes at all. The distinction the incident's `git status --short` listing raises is real but lives on the cross-check listing: there, ` M` marks a new submodule commit (pointer change) and ` m` marks modified content inside the submodule — a content modification is not a pointer fact and stays out of this gate's enumeration; that submodule's workspace hygiene belongs to the session working inside it per its own cards.
- **Untagged drift SHA:** the included pointer's SHA satisfies the (d-2) tag-pushed gate before PR creation — the tag is created and pushed by the existing tagged-SHA duty. Tag naming follows the existing format's issue-number slot taking the owning issue the pointer's lineage establishes (read from the submodule's existing tag/branch state, as the incident's `Butter/NN` lineage evidence exemplifies); an owner that cannot be established routes to the halt-clarify branch before any tag is created.
- **Pull-only submodule origin (#2667):** a tag duty that cannot push is reported per that rule — no improvised push, no silent omission; the disposition then follows the halt-clarify branch or the developer's direction.
- **Discovery after creation:** this spec governs the creation moment; the open-PR window stays (g)'s domain (pointer movement obliges the update). A residue case surfacing on an already-open PR is named here as (g)'s window, not this gate's.
- **Large drift sets (the incident's 19-pointer shape):** the enumeration is per-registered-submodule — bounded by `.gitmodules`' content; the composed-state verification runs once for the assembled set, not per pointer.

## Impact

- **Consumers:** every agent session preparing a parent-repo PR in every parent/submodule family the git-workflow cards serve — multi-submodule families like Butter directly; the developer reviewers whose PRs stop under-carrying promotions.
- **Cost:** one enumeration + disposition pass per parent-PR prep (a status listing plus per-pointer staging decisions); the staged-set machinery (tags, per-bump body section) already exists and now receives the full workspace set — the §4 per-bump body contract covers the enlarged set as it stands (one line per bump), no body-contract change required.
- **Risk:** a parent PR could carry a pointer whose submodule work is unexpected — bounded by the existing gates (the (f) ordering gate holds submodule PRs ahead of parent PRs; the (d-2) tag gate makes every recorded SHA name-reachable, so a carried pointer is inspectable, not anonymous) and by the halt-clarify branch for unestablishable lineage.
- **Blast radius:** one rule of one card + two test scenarios; no other deck file's operative content changes.
- **Recovery:** text changes are revertible; scenarios are additive; no git state in any repo is modified by this change beyond the deck repo's own PR flow.

## Out of scope

- `git-workflow-branch` rule 2(c) and `git-workflow-commit` rule 1/5 — their operative content unchanged; the strengthened (d) is their collection point.
- The open-PR window for pointers discovered or moved after creation — governed by (g) as it stands.
- Scripted enforcement: no hook, validator script, or new tool surface.
- Any follow-up work in the Butter family — the incident's PR was already corrected in-session per the issue's recorded evidence; this spec fixes the deck's future behavior.
- Thresholds or part counts for the disposition loop — judgment at the gate moment; none are scripted.

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2656/

Artifacts for agents: `.opencode/.issues/2656/`.