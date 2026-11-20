# Plan — .opencode#2759

**Goal.** Implement spec `.opencode/.issues/2759/spec.md`: the hash-permanence
tag naming generalizes its issue-number component with a branch-slug fallback —
when the recording work has no issue number, the component is the recording
work's branch name's final path component, giving
`<parent-repo>/<branch-slug>-<submodule-dir>`; the release instance falls out
structurally (release branch `release/v{semver}` → slug `v{semver}`, tag
`<parent-repo>/v{semver}-<submodule-dir>`); the naming rule is single-sourced
in `git-workflow-branch` rule 3 and every other site that names the tag defers
by reference; rule 3's machinery — idempotent create-if-untagged,
push + `git ls-remote --tags` verification, tag-targets-gitlink — is preserved
verbatim for all tags. Surfaces: `skills/git-workflow-branch/SKILL.md`
(rule 3), `skills/release-promoter/references/operating-protocol.md`
(Phase C-0 step 8), `skills/git-workflow-commit/SKILL.md` (staging-time
tagged-SHA duty), `skills/git-workflow-cleanup/SKILL.md` (deletion backstop),
`skills/git-workflow-pr/SKILL.md` (§2(d-2), §4 Submodule bump),
`tests-v2/behaviors/` (two tier-2 scenarios + per-scenario fixtures).

**Execution surface.** Deck repository `michael-conrad/.opencode`, branch
`feature/2759-branch-slug-tag-fallback`, trunk tip `49b8f9f602` (verified at
branch time). Behavioral items run the `tests-v2` harness per the
behavioral-testing card.

## Items

### Item 1 — SC-1, SC-6: rule 3 carries the fallback clause, machinery preserved

- **Deliverable:** amend `skills/git-workflow-branch/SKILL.md` rule 3's
  tagged-SHA pointer discipline: the tag name is
  `<parent-repo>/<issue-number>-<submodule-dir>` with the issue-number
  component falling back to the recording work's branch slug — the branch
  name's final path component — when the recording work has no issue number
  (`feature/<slug>` → `<slug>`, `release/v0.4.0` → `v0.4.0`), and the agent
  never halts on the naming. The rule states it is the naming rule's single
  source (site ownership: other sites defer here by reference). The
  discipline's machinery text stays verbatim: idempotent create-if-untagged
  (a present tag is verified, never re-created; a name existing pointing
  elsewhere is reported, never silently re-created), push to the submodule's
  remote + `git ls-remote --tags` verification, tag targets the commit the
  gitlink records.
- **RED:** grep rule 3 → the naming sentence is issue-number-only
  (`<parent-repo>/<issue-number>-<submodule-dir>`) with no branch-slug
  fallback clause present.
- **GREEN:** add the fallback clause into rule 3's naming text; machinery
  clauses untouched.
- **Tier marks:** no authored test; instrument fact check (grep/read).
- **Instrument:** grep rule 3 — the fallback clause (branch-slug component +
  no-issue trigger) is present, and all three machinery clauses (idempotent
  create-if-untagged with the report-never-re-create wording, the
  `git ls-remote --tags` verification, the tag-targets-gitlink rule) remain
  in the amended text.

### Item 2 — SC-2: release-path instance in Phase C-0 step 8

- **Deliverable:** extend `skills/release-promoter/references/operating-protocol.md`
  Phase C-0 step 8: a release with no release issue records its promoted
  pointers with hash-permanence tags `<parent-repo>/v{semver}-<submodule-dir>`,
  the version component derived from the release branch's own name
  (`release/v{semver}` → `v{semver}`), per the fallback instance of rule 3's
  naming discipline — no issue invented, no developer-facing naming halt; a
  release with a release issue keeps the issue-number component.
- **RED:** read step 8 → it delegates to rule 3's tagged-SHA pointer
  discipline but carries no release-instance naming for the no-release-issue
  case.
- **GREEN:** add the release-instance sentence after the existing delegation
  sentence, deferring the naming rule to rule 3.
- **Tier marks:** no authored test; instrument fact check (grep/read).
- **Instrument:** grep the protocol — the release-instance naming
  (`v{semver}` derived from the release branch) is present in step 8; no
  rigid form is restated.
- Item 2 lands after item 1: the instance defers to rule 3's fallback clause;
  the referenced text exists before the reference.

### Item 3 — SC-3: the four non-owner sites defer by reference

- **Deliverable:** at each of the four enumerated sites, replace the inline
  issue-number-only name with deferral wording that names the tag by
  reference to `git-workflow-branch` rule 3's naming discipline, preserving
  each site's own procedural content untouched —
  `skills/git-workflow-commit/SKILL.md`'s staging-time tagged-SHA duty (the
  never-staged-while-untagged gate stays), `skills/git-workflow-cleanup/SKILL.md`'s
  deletion backstop (the tag-if-untagged backstop behavior stays),
  `skills/git-workflow-pr/SKILL.md` §2(d-2) (the tag-pushed-gate blocking
  semantics stay), and `skills/git-workflow-pr/SKILL.md` §4's Submodule bump
  (the per-bump tag-naming duty stays).
- **RED:** grep each site → an inline
  `<parent-repo>/<issue-number>-<submodule-dir>` restatement is present in
  each of the four card texts: the commit card's staging-time tagged-SHA
  duty, the cleanup card's deletion backstop, `git-workflow-pr` §2(d-2), and
  `git-workflow-pr` §4's Submodule bump.
- **GREEN:** replace the inline form with the rule-3 naming reference at
  each of the four sites.
- **Tier marks:** no authored test; instrument fact check (grep).
- **Instrument:** grep the four sites — no inline rigid-form restatement
  remains and each carries the rule-3 naming reference; then a deck-wide
  sweep (`grep -rn '<issue-number>-<submodule-dir>'` over `skills/`,
  `guidelines/`, `floor.md`) confirms the issue-number rigid form survives
  only in rule 3's own naming text (the single source) — the release
  instance item 2 adds (`<parent-repo>/v{semver}-<submodule-dir>`) names no
  issue-number form and is not a match.
- Item 3 lands after item 1: the deferral target must exist before the
  references.

### Item 4 — SC-4: tier-2 behavioral scenario, no-release-issue release names the tag from the release branch

- **Deliverable:** scenario `tests-v2/behaviors/2759-release-no-issue-tag.sh`
  with per-scenario fixture `fixtures/setup/2759-release-no-issue-tag.sh`
  (reusing the `2753-family-common.sh` family base): a parent repo whose
  registered submodule pointer is behind the submodule's remote trunk tip,
  release work riding on branch `release/v0.4.0`, no release issue anywhere;
  the session composes the release candidate per the release-promoter card's
  Phase C-0 (promote, record, capture with the hash-permanence tag).
  Clean-room evaluation asserts from `session.yaml`: the promoted pointer's
  pushed tag is named `parent/v0.4.0-doaj` (the fixture's
  `<parent-repo>/v{semver}-<submodule-dir>` instance, facts pre-supplied) and
  no developer-facing naming halt appears in the run's evidence — no
  invented issue number, no halt question on the tag name.
- **RED:** executed supervised run with the deck pinned to the pre-card
  commit (`BEHAVIOR_SUBMODULE_COMMIT` = pre-card trunk tip): the run agent
  hits the naming deadlock under the pre-card cards — a naming halt
  question, an invented issue number, or no lawful tag; the executed run
  records the observed naming failure. The field halt (2026-11-20 release
  composition, developer verdict in the spec's User Intent) corroborates
  only.
- **GREEN:** after items 1–3 (the card set complete — the run agent's
  always-load surfaces include the commit card's staging-time tagged-SHA
  duty, live at the capture commit, so a surviving rigid restatement would
  re-fire the naming wall), evaluation asserts the `v0.4.0`-component tag
  name and the absence of a naming halt; generator exits 0; evaluation is
  the clean-room dispatch's job.
- **Tier marks:** tier-2 behavioral (heavy, supervised, cycle-time RED+GREEN
  runs; on demand thereafter).
- **Instrument:** executed manifest + clean-room evaluation verdict against
  `session.yaml`.

### Item 5 — SC-5: tier-2 behavioral scenario, non-release no-issue capture names the tag from the branch slug

- **Deliverable:** scenario
  `tests-v2/behaviors/2759-capture-branch-slug-tag.sh` with per-scenario
  fixture `fixtures/setup/2759-capture-branch-slug-tag.sh`
  (`2683-sc5-pointer-capture-tagged-sha.sh`-style boundary state): a parent
  repo whose recorded submodule pointer is a deep ancestor with a sandbox
  rewired submodule remote; the recording work rides on a feature branch
  carrying no issue number (e.g. `feature/pointer-capture-scenario`), no
  issue number anywhere in the work; the session performs the branch-level
  pointer-capture commit per the branch card's rules 2–3. Clean-room
  evaluation asserts from `session.yaml`: the recorded SHA's pushed tag is
  named `parent/pointer-capture-scenario-.opencode` (the fixture's
  `<parent-repo>/<branch-slug>-<submodule-dir>` instance, the branch slug
  pre-supplied as a fixture fact) and no developer-facing naming halt
  appears.
- **RED:** executed supervised run with the deck pinned to the pre-card
  commit: the run agent faces the same naming wall — no lawful tag name is
  produced (halt question, invented issue number, or issue-number-form name
  fabricated); the executed run records the observed naming failure.
- **GREEN:** after items 1 and 3 (the set item 5's surfaces need — rule 3's
  fallback plus the commit card's deferral swap; the commit card is the
  always-load surface live at the capture commit, so item 3 must have
  replaced its rigid restatement), evaluation
  asserts the branch-slug tag name and no naming halt; generator exits 0.
- **Tier marks:** tier-2 behavioral (heavy, supervised, cycle-time RED+GREEN
  runs; on demand thereafter).
- **Instrument:** executed manifest + clean-room evaluation verdict against
  `session.yaml`.

## Dependency order

Items 1 → 2 → 3 → 4/5. Item 1 delivers the naming rule's single source (rule
3) — item 2's release instance and item 3's four deferrals reference it, so
both follow it. Item 2 extends the same release surface rule 3's discipline
composes with; item 3 is an independent restatement sweep that lands after
item 1. Items 4–5 are the behavioral set: their RED runs execute against the
pre-card deck pinned via `BEHAVIOR_SUBMODULE_COMMIT` (the harness's
sanctioned pin, verified against the remote) — the scenario scripts and
fixtures authored on this branch run host-side while the run agent's cloned
deck comes from the pinned pre-card commit; among them the scenarios are
independent, executed in either order; their GREEN evaluation requires the
card set complete (all three card items delivered) — the run agent's
always-load surfaces include the commit card's staging-time tagged-SHA duty,
live at the capture commit in both scenarios, so any surviving rigid
restatement re-fires the naming wall the GREEN asserts absent; item 4
additionally carries item 2's release instance.

## Traceability

| Item | SCs |
|------|------|
| 1 | SC-1, SC-6 |
| 2 | SC-2 |
| 3 | SC-3 |
| 4 | SC-4 |
| 5 | SC-5 |

## Verification summary

- Items 1–3: fact checks (grep/read of card text) at cycle time, mapped to
  their SCs above; `./.opencode/tools/reference-integrity --scan` runs clean
  before each commit touching agent-facing markdown (the tests-v2 §6c
  standing gate).
- Items 4–5: tier-2 behavioral scenarios — fixture family + executed
  supervised RED runs pinned to the pre-card commit + clean-room evaluation
  dispatches; heavy, run once this cycle (RED and GREEN each), on demand
  thereafter.
- Suite: the deck tool unit suite (`cd .opencode && uv run pytest`, through
  the parent's declared commands) runs at PR-check time.

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
