<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Plan — Restore the submodule tag-pointer discipline in the impacted git-workflow cards (.opencode#2683)

Derives entirely from `.opencode/.issues/2683/spec.md`. One item per SC. Branch:
`feature/2683-tag-pointer-discipline` in `.opencode` (base `b43833f59`). Deck edits
are developer-directed (spec-approved); the skill-creator gate's content standards
(fact-decidable predicates where any, root-agnostic text, lean bodies) bind, and R-5's
deletion rides the retirement gate (lost consumer — no card, hook, or tool invokes
either script; orphaned since #2490).

## Item 1 — SC-1: tagged-SHA pointer-capture rule in `git-workflow-branch` and `git-workflow-commit`

- **Deliverable:** `skills/git-workflow-branch/SKILL.md` — both the rule 2 (trunk
  freshness / submodule sync) and rule 3 (real-work sequence) surfaces carry the
  tagged-SHA pointer flow: a synced pointer's recorded tip is tagged-and-pushed as part
  of the sync (rule 2), and the pointer captured for the feature branch is a pushed
  tagged SHA (rule 3). `skills/git-workflow-commit/SKILL.md` §5 gains the staging-time duty.
  Rule text states: annotated tag `<parent-repo>/<issue-number>-<submodule-dir>` on the
  commit the gitlink records (the recorded SHA, not the submodule working-tree HEAD);
  create if untagged (a present tag is verified, never re-created; a name collision is
  reported, not silently resolved); push it; verify on the remote
  (`git ls-remote --tags`) — all before the parent commit recording the pointer.
- **RED:** card-text inspection of the two cards finds zero occurrences of the tag
  convention, `hash-permanence`, or any push-and-verify duty (the F-3 state).
- **GREEN:** the two rule additions above.
- **Instrument:** re-inspection of the card text against R-1's stated content
  (create/push/verify + gitlink-target clarification + naming format).

## Item 2 — SC-2: pre-PR tag gate and Submodule-bump tag naming in `git-workflow-pr`; carve-out on both release surfaces

- **Deliverable:** `skills/git-workflow-pr/SKILL.md` — §2 gains a checklist item
  (bump-bearing PRs block until every recorded pointer SHA's tag is verifiably on the
  submodule's remote, `git ls-remote --tags`); §4's `## Submodule bump` bullet
  requirements gain per-bump tag naming; §3's release carve-out sentence gains the
  two-way clarification (hash-permanence discipline tags are agent duty, not release
  artifacts — the prohibition targets release artifacts only). `skills/release-promoter/SKILL.md`
  §0's "never hosts its own release PR or tag" sentence gains the same clarification.
- **RED:** inspection finds no tag-presence item in §2, no per-bump tag naming in §4,
  and a bare "or tag" that points away from the discipline.
- **GREEN:** the additions and clarifications above.
- **Instrument:** card-text inspection against R-2 and R-4.

## Item 3 — SC-3: idempotent tag backstop in `git-workflow-cleanup`

- **Deliverable:** `skills/git-workflow-cleanup/SKILL.md` — before §2's branch-deletion
  step, an idempotent tag-if-untagged check against every submodule commit the branch
  work recorded, plus push reconciliation for any discipline tag found local-only.
- **RED:** inspection finds no tag check in the cleanup sequence.
- **GREEN:** the backstop step added to the sequence (numbered as part of or adjacent
  to rule 2, before deletion).
- **Instrument:** card-text inspection against R-3.

## Item 4 — SC-4: retirement of the two orphaned validator scripts

- **Deliverable:** delete `scripts/validate-release-tags.sh` and
  `scripts/validate-submodule-refs.sh`; delete the two `README.md` table rows
  (lines 126–127 — the only README references, verified). No other file
  under `scripts/`, `tools/`, `hooks/` added or modified; `floor.md`, `guidelines/`,
  parent `AGENTS.md`, and all other parent tracked files untouched.
- **RED:** both scripts exist under `scripts/` and README references them.
- **GREEN:** the deletions.
- **Instrument:** worktree changed-file list (only the five cards, README, the two
  deleted scripts, and tests-v2 scenarios below) + file-tree check.

## Item 5 — SC-5: behavioral scenario — supervised pointer capture tags, pushes, records tagged SHA, pre-PR gate verifies

- **Deliverable:** `tests-v2/behaviors/2683-sc5-supervised-pointer-capture-tagging.sh`
  on the existing harness (per the `behavioral-testing` card — a real `opencode run`,
  GitBucket container provisioned by the harness, scenario authoring per §references
  there). RED is executed **before Items 1–3 land** (the deck under test is the
  pre-change trunk, where the discipline is absent); the scenario is then re-run for
  GREEN after Items 1–3 land. Verdicts from the run transcripts.
- **RED (pre-change run baseline):** the run shows the agent recording an untagged
  pointer / never tagging or pushing (the F-1 state).
- **GREEN (post-change run):** the run shows: submodule commit annotated-tagged with
  the convention name, tag pushed to the submodule remote, recorded pointer = the tagged
  SHA, and the pre-PR gate verifying tag presence on the remote.
- **Instrument:** harness run transcript + verdict (RED baseline + GREEN rerun).

## Item 6 — SC-6: behavioral negative scenario — untagged pointer caught at the pre-PR gate and remediated

- **Deliverable:** `tests-v2/behaviors/2683-sc6-untagged-pointer-caught-at-gate.sh` —
  same harness, tagged-packet withheld (scenario arranges a pointer capture whose tag
  was never pushed); expected: the gate catches the gap, the agent creates and pushes
  the tag before PR creation. RED (pre-change baseline run) is executed **before Items
  1–3 land**; GREEN rerun after.
- **RED (pre-change run baseline):** current deck has no gate — the run sails through.
- **GREEN (post-change run):** verdict from the run transcript showing catch +
  remediation.
- **Instrument:** harness run transcript + verdict (RED baseline + GREEN rerun).

## Item 7 — SC-7: current-state repair — backfill tag and push reconciliation

- **Deliverable:** in `.opencode` (the submodule repository): annotated tag
  `opencode-config/2683-.opencode` on `e1b41776` (the parent's currently recorded
  pointer), pushed to the submodule remote; the seven F-6 local-only tags
  (`opencode-config/1156`, `opencode-config/1712`, `opencode-config/2334-opencode`,
  `opencode-config/checkpoint/2334/phase-1-opencode`, `feature/1784-routing-dispatch-gate`,
  `pre-numbering-fix-20261007`, `pre-rip` — exact local names as `git tag` reports
  them) pushed to the submodule remote. No parent
  file changes; no parent commit or branch (rule 2(c) — parent contributes no content
  beyond pointer drift).
- **RED:** `git ls-remote --tags` lacks all eight names (verified: exactly the seven
  F-6 tags are local-only, nothing else).
- **GREEN:** annotated tag created (idempotent-verify first: if a name exists, verify it
  points at `e1b41776`'s peel — mismatch reported, never re-tagged); tags pushed;
  remote verified.
- **Instrument:** `git ls-remote --tags` on the submodule origin compared against all
  eight names — none local-only remains.

## Order and dependencies

Execution order:

1. **Behavioral RED baselines first:** author both scenarios (Items 5–6's deliverable
   scripts) against the pre-change trunk and execute their RED runs — the pre-change
   deck is the RED baseline, so this phase must precede Items 1–3.
2. **Items 1–3** (rule text), each GREEN verified by card-text inspection before the
   next begins.
3. **Items 5–6 GREEN reruns** against the changed deck.
4. **Item 4** (script deletions) and **Item 7** (tag backfill/pushes) are independent
   of everything above; each lands before the PR with its own instrument evidence.
5. Final: structural gates + full suite + verify dispatch + PR (see Verification).

## Verification at PR time

Structural: reference-integrity tool run (cross-references), changed-file list vs SC-4.
Behavioral: SC-5/SC-6 run transcripts with pass verdicts. SC-7 ls-remote output.
All recorded in the PR body's Evidence section.