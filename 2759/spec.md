# [SPEC] No-issue hash-permanence tag naming — branch-slug fallback; the release path never halts on deck-internal naming

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

## Intent

**Problem Statement.** The tagged-SHA pointer discipline names the
hash-permanence tag rigidly `<parent-repo>/<issue-number>-<submodule-dir>`
(`git-workflow-branch` rule 3). The release path mandates that tag for every
promoted pointer (`release-promoter` Phase C-0 step 8) and blocks the release
PR until it is verifiably on the submodule remote (`git-workflow-pr`
§2(d-2)); the release path simultaneously allows a release with no release
issue (`release-promoter` §1: "Closes lines only when a release issue
exists") and forbids minting an issue to satisfy provenance
(`git-workflow-branch` rule 5). When a release has no release issue, no
lawful tag name exists: inventing an issue number is forbidden, halting to
ask the developer is a deck-internal question — the agent asked it on
2026-11-20 and the developer's verdict was that the question is one only
the deck can answer. The same wall stands on any non-release pointer capture
whose work has no issue number.

**Root Cause / Motivation.** The restoration of the discipline
(michael-conrad/.opencode#2683) re-authored the tag name from the pre-rip
convention verbatim, and that convention's issue-number component was
satisfied by every historical use — every prior release and capture carried
an issue number (v0.3.0's pointer tag was `opencode-config/378-.opencode`,
named for parent release issue opencode-config#378). The rule set around
the naming never composed the issue-number component against the deck's own
no-issue allowances; the first no-release-issue release (2026-11-20,
opencode-config after v0.3.0) fired the deadlock and halted a live release
mid-composition. The fix must be naming-only and must reach every card that
restates the naming, or the next card pair re-creates the gap.

**Approach Chosen.** Generalize the tag name's issue-number component: when
the recording work has no issue number, the component falls back to the
recording work's **branch slug** — the branch name's final path component —
giving `<parent-repo>/<branch-slug>-<submodule-dir>`. The release instance
falls out structurally: the release branch `release/v{semver}` (repo
precedent: `release/v0.3.0`, merged release PR #379) yields slug `v{semver}`,
so a no-release-issue release records its promoted pointers with tag
`<parent-repo>/v{semver}-<submodule-dir>` (for the pending opencode-config
release: `opencode-config/v0.4.0-.opencode`, version per the release flow's
own next-version determination). A non-release no-issue capture names the
tag from its feature branch's slug the same way.

**Alternatives Considered & Why Discarded.**
1. *Mandatory release-issue provision* — every release files a parent-side
   release issue to name the tag (the #378 precedent, made universal).
   Discarded: the issue would exist to name a tag, which is provenance
   ceremony `git-workflow-branch` rule 5 forbids minting; it adds mandatory
   ceremony to a flow whose real content (changelog, version, tag-prep)
   already rides the release PR; and it leaves the non-release no-issue
   wall standing.
2. *Release-only version fallback, silence elsewhere* — name
   `<parent-repo>/v{semver}-<submodule-dir>` on the release path only.
   Discarded: it fixes the evidenced instance and leaves the same rigid
   component deadlocking any non-release no-issue capture — the defect
   re-fires as a second bug report.
3. *Scripted tag-naming validator* — a tool computing or enforcing the
   name. Discarded per the developer's standing ruling recorded in
   michael-conrad/.opencode#2664 and reaffirmed in #2683: scripted deck
   surfaces are the decks that get trashed and replaced; rule text at the
   decision moment is the deck's enforcement class.
4. *Dropping the tag discipline on no-issue paths* — no tag when no issue
   exists. Discarded: it destroys hash permanence for those pointers — the
   exact regression #2683 restored the discipline to close; every recorded
   pointer stays name-reachable through branch cleanups and release flows,
   unconditionally.

**Key Design Decisions.**
1. The fallback component is the branch slug (`feature/<slug>` →
   `<slug>`; `release/v0.4.0` → `v0.4.0`). Tradeoff: branch slugs are less
   globally unique than issue numbers; accepted — one-branch-per-scope
   keeps the live namespace collision-free, and a collision that does
   arise is caught by the discipline's own idempotence rule (a name
   existing elsewhere is reported, never silently re-created) and by the
   tag-pushed gate's SHA-peel verification.
2. The fallback's precondition is structural, not a new gate:
   branch-before-files (`git-workflow-branch` rule 1) and Phase C-0's
   fixed order (record the release branch, then capture) guarantee a
   branch exists at every pointer-capture decision moment — the fallback
   is never undefined, and no new machinery is introduced.
3. The amendment is naming-only: rule 3's machinery — idempotent
   create-if-untagged, push, `git ls-remote --tags` verification, tag
   targets the commit the gitlink records — is preserved and inherited
   unchanged by fallback-named tags.

**User Intent / Original Prompt.**
- "create a release PR" (developer, 2026-11-20) — the release whose
  composition fired the deadlock.
- "how in the fuck would I know? this must be a deck regression as you
  have asked me something only you can know. file a bug report."
  (developer, 2026-11-20, on being asked for the tag's issue number) —
  the observed failure: a developer-facing halt on a deck-internal naming
  decision.
- "triage .opencode#2759" (developer, 2026-11-20) — the report's
  work-entry conversion into this spec.
- Observed failure (2026-11-20 release composition, executed evidence):
  parent trunk `385a8a70d` at remote tip, no parent commits since
  `v0.3.0`; submodule `.opencode` at remote trunk tip `49b8f9f602`,
  recorded gitlink `7e50437bb`; Phase C-0 step 8 demands the tag for
  `49b8f9f602`; no release issue exists; agent halted on the naming
  question.

## Not Included

- No mandatory release-issue provision — discarded alternative 1; the
  release path keeps its no-release-issue allowance.
- No script, hook, or validator surface — discarded alternative 3; the
  standing no-scripts ruling governs.
- No change to the clean-room gate mechanics, the DRIFT/BUILD assertions,
  the plumbing capture mechanism, or the post-capture assertion — the
  deadlock is naming-only; those mechanics are untouched.
- No re-authoring of the issue-number naming path beyond the fallback
  clause — issue-number-named tags keep their existing discipline
  verbatim.
- The opencode-config release itself is not this spec's deliverable: it
  consumes the fix after merge; its flow belongs to the release-promoter
  card.

## Requirements

- **R-1**: When a parent commit records a submodule pointer whose recording
  work has no issue number, the recorded SHA's hash-permanence tag SHALL be
  named `<parent-repo>/<branch-slug>-<submodule-dir>`, `<branch-slug>` being
  the recording work's branch name's final path component — and the agent
  SHALL NOT halt to ask the developer for a tag-naming decision.
- **R-2**: The naming rule SHALL compose with `git-workflow-branch` rule 5
  and `release-promoter` §1's no-release-issue allowance: a release with no
  release issue and a pointer capture with no issue each name their tags
  lawfully, with no deadlock and no invented issue number.
- **R-3**: The fallback SHALL appear on every card carrying the naming
  discipline — `git-workflow-branch` rule 3, `release-promoter` Phase C-0
  step 8 (via the operating protocol), `git-workflow-pr` §2(d-2) and §4 —
  such that no card pair re-creates the gap.
- **R-4**: The amendment SHALL preserve rule 3's existing semantics
  unchanged for all tags, with fallback-named tags inheriting each:
  idempotent create-if-untagged (a present tag is verified, never
  re-created; a name that exists pointing elsewhere is reported, never
  silently re-created), push and `git ls-remote --tags` verification on the
  submodule remote, and the tag targeting the commit the gitlink records.

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | `git-workflow-branch` rule 3's tag-naming discipline names the fallback: when the recording work has no issue number, the issue-number component is the recording work's branch slug, in the `<parent-repo>/<branch-slug>-<submodule-dir>` form | structural | card-text inspection of rule 3: the fallback clause (branch-slug component + no-issue trigger condition) is present; grep for the clause, locate by its wording |
| SC-2 | `release-promoter`'s operating protocol (Phase C-0 step 8) names the release-path instance: a release with no release issue records its promoted pointers with tag `<parent-repo>/v{semver}-<submodule-dir>`, `v{semver}` derived from the release branch | structural | card-text inspection of the protocol's pointer-capture step: the release-instance naming is present |
| SC-3 | `git-workflow-pr` §2(d-2)'s tag-pushed gate and §4's Submodule-bump section carry the fallback form (or defer their naming to rule 3's amended discipline) at both sites | structural | card-text inspection of §2(d-2) and §4: neither site restates the issue-number form as the only lawful name |
| SC-4 | A no-release-issue release-composition run, executed under the amended rules, names the promoted pointer's hash-permanence tag `<parent-repo>/v{semver}-<submodule-dir>` from the release branch and proceeds to capture with no developer-facing naming question | behavioral | behavioral test scenario under `tests-v2/` (tier-2, per the behavioral-testing card), asserting the emitted tag name and the absence of a naming halt in the run's evidence |
| SC-5 | A non-release pointer capture whose work has no issue number, executed under the amended rules, names the recorded pointer's hash-permanence tag with the branch-slug component and proceeds with no developer-facing naming question | behavioral | behavioral test scenario under `tests-v2/` (tier-2), asserting the emitted tag name and the absence of a naming halt |
| SC-6 | Rule 3's post-amendment text preserves the discipline's machinery for all tags: idempotent create-if-untagged with the report-never-re-create clause, the `git ls-remote --tags` remote verification, and the tag-targets-gitlink rule | structural | card-text inspection of rule 3: all three clauses present in the amended text; grep for each clause |

## Dependencies

| Reference | Relationship | Status |
|-----------|---------------|--------|
| michael-conrad/.opencode#2683 (restored tagged-SHA pointer discipline) | provides the rule-3 text being amended | satisfied (merged; deck trunk `49b8f9f602`) |
| michael-conrad/.opencode#2753 (release composition mandate) | provides the Phase C-0 step-8 capture text the release instance joins | satisfied (merged) |
| `tests-v2/` behavioral harness (deck repo; behavioral-testing card) | verification instrument for SC-4/SC-5 | satisfied (carried #2753's tier-2 scenarios) |
| Deck-repo implementation session | the change lands in michael-conrad/.opencode through deck governance (skill-creator admission) and a human-merged PR; a consuming session's `.opencode` checkout is read-only | pending (post-approval) |
| opencode-config release following v0.3.0 | consumes the fix: composition re-syncs to the post-merge deck trunk tip and names the promotion tag under the amended rule | pending (blocked on this spec's implementation) |

## Traceability

| Requirement | Success criteria |
|-------------|------------------|
| R-1 | SC-1, SC-4, SC-5 |
| R-2 | SC-4 |
| R-3 | SC-1, SC-2, SC-3 |
| R-4 | SC-6 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `git-workflow-branch` rules 1, 3, 5 | deck card | `.opencode/skills/git-workflow-branch/SKILL.md` | read this session, 2026-11-20; rule 3 and rule 5 quoted in the Problem Statement |
| `release-promoter` §1 + operating protocol Phase C-0 | deck card + reference | `.opencode/skills/release-promoter/SKILL.md`, `references/operating-protocol.md` | read this session, 2026-11-20; step 8's capture mandate and §1's "Closes lines only when a release issue exists" quoted |
| `git-workflow-pr` §2(d-2), §4, §8 | deck card | `.opencode/skills/git-workflow-pr/SKILL.md` | read this session, 2026-11-20; §2(d-2)'s inline rigid naming, §4's per-bump tag naming, §8's bare `vX.Y.Z` release title token |
| Release-branch precedent `release/v0.3.0` | git history | opencode-config trunk, merge of release PR #379 | executed git log this session, 2026-11-20 |
| Prior pointer tag `opencode-config/378-.opencode` peeling to gitlink `7e50437bb` | remote evidence | deck repo remote | `git ls-remote --tags`, executed 2026-11-20 |
| #2683 restoration spec (R-1 naming, R-4 carve-out) | issue store | `.opencode/.issues/2683/spec.md` | read this session, 2026-11-20 |
| #2489 suffix rule ("issue title, phase name, or any ad-hoc string SHALL NOT be used") | issue store | `.opencode/.issues/2489/spec.md` | read this session, 2026-11-20 |
| No-scripts ruling | issue store | michael-conrad/.opencode#2664, cited by #2683 | read via #2683's spec this session, 2026-11-20 |
| 2026-11-20 release composition evidence | executed session output | parent trunk `385a8a70d`; submodule tip `49b8f9f602`; gitlink `7e50437bb`; developer verdict quoted in User Intent | executed this session (fetch-compare, ls-tree, ls-remote), 2026-11-20 |

## Cost Frame

- **SC-1, SC-2, SC-3, SC-6** — grep-cost card-text checks, seconds each.
  Skipping one leaves the gap live on that card pair: the defect this spec
  closes is exactly a card-pair composition, so each unverified site is a
  live regression vector.
- **SC-4, SC-5** — tier-2 scenario authoring plus one harness run each.
  Skipping them leaves the deadlock undetectable at runtime: the defect's
  own evidence is a live agent halt that no structural grep on the pre-fix
  cards can fail (the cards' rigid text is the defect surface, the halt is
  the failure).

## Edge Cases

- **Fallback name collision — a same-named tag exists pointing elsewhere.**
  Condition: two works share a branch slug, or a re-run reuses a version,
  and the earlier tag points at a different SHA. Expected: report, never
  silently re-create (rule 3's idempotence, inherited); the capture does
  not proceed on the unverified name. Resolution: the reporting agent
  names the colliding tag; the developer directs the disambiguation.
- **Fallback name exists pointing at the same SHA** (re-composition of an
  unchanged pointer). Expected: verify the present tag and proceed — the
  idempotent path; no re-creation.
- **Multiple submodules promoted in one release.** Expected: each promoted
  submodule carries its own tag — the `v{semver}` component is shared, the
  `-<submodule-dir>` suffix distinguishes the names.
- **No branch exists at the capture decision moment.** Condition: a pointer
  capture attempted before branch creation — an ordering violation of
  `git-workflow-branch` rule 1 or Phase C-0's fixed order. Expected: the
  fallback is undefined only because the sequence itself is defective; the
  ordering violation is the defect and is remediated by the owning cards'
  existing sequence, never by a naming decision.

## Completion gate

Every success criterion passes before this deliverable is complete;
partial implementation is not permitted.

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3)
