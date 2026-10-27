## Problem

The live deck's `git-workflow-pr` §2(e)/(f) govern parent-repo PR creation but leave the pointer-currency window unguarded: (e) forbids pointer-only parent PRs and (f) blocks parent PR creation while a submodule PR is pending and directs that the parent PR carry "the pointer to the merged submodule trunk tip, re-synced with the parent's verification re-run ... before creation". What the deck does not state — and what produced a stale-pointer window this session — is what happens when the submodule pointer moves while a parent PR is already open, or between the parent branch's pointer capture and the PR's creation: the PR then represents a parent state whose recorded pointer no longer matches the submodule's reality, and nothing in the deck obliges the PR's update.

The developer's session ruling (2026-10-27): "PRs for root repos are always supposed to carry pointer commits. If a pointer moves before a PR is moved, the PR must be updated so it reflects reality and does not reflect bitrot."

Reading, per the developer's words: a parent-repo PR carries a pointer commit whenever the submodule's checked-out state has advanced relative to the parent's last recorded pointer — always (subject to (e): the pointer rides with real content, never alone). When the pointer moves while the parent PR is open, or between capture and creation, the PR is updated to the moved pointer (the same verification re-run (f) already requires for creation applies to the update at this moment) — the PR must reflect reality, not bitrot.

## Root cause in the deck

Parent-side pointer capture rules are all creation-time and merge-relative:
- The submodule pointer rides with real parent content (AGENTS.md; `git-workflow-commit`).
- (e) excludes pointer-only PRs.
- (f) times the parent PR strictly after submodule PR merges, with a re-verification before creation.

The moving-while-open case and the moves-again-before-creation case have no owner; and the PR surface affirmatively restricts updates: §6's HALT block states "update the PR only on review feedback". The currency rule therefore owns both windows in §2 and names itself as §6's second update trigger — a stale window and an affirmative restriction, not a bare gap.

## Scope (deck fix)

- `skills/git-workflow-pr/SKILL.md` §2 and §6 — the pointer-currency rule in the submodule block ((d)–(f)): a parent-repo PR always carries the pointer to the submodule's current trunk-referencing state the parent work ships (real content rides with it per (e)); when the submodule pointer moves while the parent PR is open — or moves between the parent branch's pointer capture and the PR's creation — the PR is updated to the moved pointer, with the parent's verification re-run against the composed state before the update, per the moving-while-open requirement above.
- The rule composes with (f): (f) continues to own the create-time ordering; the new rule owns currency while open (and the pointer-move-before-act window).

## Requirements

- **R-1** — The card §2 SHALL state the currency rule: a parent-repo PR always carries the submodule pointer the parent's state actually references (the existence of a bump is (d)'s fact — checked-out HEAD past the recorded gitlink; carrying it is mandatory, with (e)'s pointer-only exclusion unchanged); a submodule pointer move while the parent PR is open (or between pointer capture and PR creation) obliges the PR's update to the moved pointer, with the parent's verification re-run against the composed state before the update; a PR representing a stale pointer is the named defect (bitrot).
- **R-2** — The card §6's update clause SHALL state this rule as its second permitted update trigger: after PR creation the PR is updated only on review feedback or on submodule pointer movement under §2's currency rule — the two triggers named together, no other triggers added, the update mechanics unchanged.
- **R-3** — The rule SHALL state its composition with (f) and §6's named-triggers form and shall not alter (d) or (e), the PR-completion invariant, the HALT-after-creation boundary, or any other card rule.

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | The card §2 submodule block states the currency rule: the PR always carries the pointer the parent's state references (carrying mandatory, (e) unchanged), and a pointer move while the parent PR is open (or between capture and creation) obliges the PR update to the moved pointer with the parent's verification re-run before the update, naming the stale-PR defect | structural | Read the card; assert the always-carry statement, the currency rule, the re-verify-before-update step, and the defect naming present |
| SC-2 | The card §6's update clause names the currency rule as its second permitted update trigger (review feedback or submodule pointer movement under §2, no other triggers) | structural | Read §6; assert the two named triggers and the no-other-triggers statement present |
| SC-3 | Every other rule of the card is unchanged in operative content | structural | The change's diff; assert the edits are confined to the §2 submodule block and the §6 update clause, and no other rule changed |

## Out of scope

- (e) pointer-only prohibition and (f)'s create-time ordering gate — unchanged; the new rule composes with them. §6's update clause keeps its form: the currency trigger is stated as its second named trigger in place, superseding the review-feedback-only wording.
- Any scripted enforcement of pointer currency — agent judgment at the PR surface; mechanisms verify facts only.
- The corpus/parent repos of other deployments — deck rule only, root-agnostic.

## Impact

Consumers: every parent-repo PR alongside submodule work, and the developers who review them. Risk: an agent churning a parent PR on every submodule commit — bounded because the rule keys on the pointer moving (gitlink drift), not on submodule activity, and the update is one pointer bump plus the re-verification (f) already prescribes. Blast radius: two blocks of one card (the §2 submodule block and §6's update clause); no other rule-bearing file.

## Evidence trail (from the session)

- The developer ruling (2026-10-27, session): quoted in Problem.
- The gap (read 2026-10-27): `git-workflow-pr/SKILL.md` §2(e)/(f) — no currency rule for the moving-while-open window; this session's planned parent PR would carry the `.opencode` pointer while the same branch's submodule work continues (the #2678 fix lands on the same branch behind the #2665 rule edits).

