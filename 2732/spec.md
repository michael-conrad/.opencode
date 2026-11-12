<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored bug report, filed 2026-11-12 by the developer
     (michael-newsrx) on the remote tracker; triaged 2026-11-12 under the
     developer dispatch "triage .opencode#2732" and converted in place into
     this governing spec under the work-entry conversion (issues card §5,
     .opencode#2707 mechanics), per the worked precedent .opencode#2704.
     Developer clarifications recorded during triage: the two-track scope
     statement (semver covers both release PRs, tagged with a release
     indicator, and regular PRs, tagged with a dev indicator), the
     indicator-as-version-carrier carrier model, and the numbering delegation
     ("you are managing the semver numbering" — agent-owned selection,
     developer directive overrides). Triage evidence:
     research/triage-2026-11-12.md. -->

# [SPEC] Mandate semver versioning across release and dev PR tracks for managed repos

## Problem

The deck mandates a semver tag format for releases (`v{semver}`,
release-promoter operating protocol) but never mandates that managed
repositories carry semver or adopt it. A managed parent repository with no
semver release history (observed: DoiUpdaterCurrent — only date-based tags
`v-2020-09-21-1600702240`, no version property in build metadata, changelog
entirely under `[Unreleased]`) reaches its release run with an undefined
release version: release-promoter's tag format assumes a version exists,
version-manager derives the bump level from the changelog (requires a prior
release), and programming-principles' versioning discipline is general
practice, not a mandate. No card settles the first-semver numbering, so the
release halts mid-pipeline for a decision the deck should produce by rule.
Verified by deck-wide grep 2026-11-12 (triage evidence:
`research/triage-2026-11-12.md`).

The developer's triage clarification widens the intended scope: semver
governs both release PRs (tagged with a release indicator) and regular PRs
(tagged with a dev indicator), with the indicator carrying the version —
regular PRs display the in-progress version (`X.Y.Z-dev.N`), not merely a
classification. No OSS convention stamps literal versions on ordinary PRs
(verified 2026-11-12 against release-please, changesets, Conventional
Commits, PEP 440, Maven, Cargo, Go modules); the documented precedent keeps
the dev version in-tree, which this spec adopts as the canonical-state model
while placing the version display on the PR title per the developer's
indicator statement.

## Scope

- `skills/programming-principles/references/practices.md` — the
  versioning-discipline section gains the two-track mandate (R-1).
- `skills/version-manager/SKILL.md` — gains the dev-line mechanics, the
  first-semver adoption rule, and the numbering-authority rule (R-2, R-3,
  R-6).
- `skills/release-promoter/references/operating-protocol.md` — gains the
  release-conversion rule (R-4).
- `skills/git-workflow-pr/SKILL.md` — gains the PR title version-token form
  (R-5).

Out of scope:

- changelog-generator content — release-scoped entries unchanged; squashed
  commit titles carrying the version token require no card change.
- Historical tag migration or epoch machinery (PEP 440-style) — date-based
  tags remain as history; sort-order compatibility with dead tags is not
  required.
- Build or publish tooling for dev builds — the dev track tags commits; no
  artifact publishing is specced.
- The human-merge boundary — unchanged (floor structural rule).
- Any change outside the `.opencode` repository (single-repo scope; managed
  repos consume the deck, they are not edited by it).

## Requirements

- R-1: The deck SHALL mandate that every repository it manages carries
  semver versioning covering both tracks: release PRs carry the release
  version, regular PRs carry the in-progress dev version. Owner:
  programming-principles, versioning-discipline section.
- R-2: version-manager SHALL carry the dev-line mechanics: the repo's
  canonical version declaration carries `X.Y.Z-dev.N` between releases; a
  merge that changes the versioned surface (the surface version-manager
  already bumps) advances N; docs-only and CI-only changes display the
  current version without advancing N; N is derived from existing dev tags
  (highest `v<base>-dev.*` tag + 1), not stored separately; the dev base
  targets the next release and is re-derived by the agent when accumulated
  changelog categories outgrow it.
- R-3: version-manager SHALL carry the first-semver adoption rule: a managed
  repo without a semver history adopts semver at its next versioned change
  or release; the agent selects and justifies the first version from
  repository evidence — 0.x for initial-development repos, 1.0.0-family for
  production-history repos — and an explicit developer version directive
  overrides the selection. Date-based historical tags remain untouched.
- R-4: release-promoter SHALL carry the release conversion: the release PR
  strips the dev suffix and carries the bare version; the release number is
  re-derived from the changelog (authoritative over the dev base's claim);
  the release tag `v{semver}` follows the human merge per the existing
  protocol.
- R-5: git-workflow-pr SHALL carry the PR title form: the version token
  leads the title — bare `vX.Y.Z` on release PRs (the release indicator),
  `vX.Y.Z-dev.N` on dev PRs (the dev indicator) — followed by the existing
  title conventions.
- R-6: version-manager SHALL carry the numbering-authority rule: the agent
  selects and justifies every version number — counter advance, base
  selection, first base — in the work record; an explicit developer version
  directive overrides any derivation.

## Approach

The delegated numbering design (agent-owned per the triage addendum; any
part falls to developer directive):

1. **One version line, two states.** The canonical declaration reads
   `X.Y.Z-dev.N` between releases; the suffix state is the indicator (bare =
   release, `-dev.N` = dev); no separate indicator vocabulary.
2. **The tree owns the number; PRs display it.** Canonical state in-tree
   (Maven SNAPSHOT / PEP 440 / Cargo precedent), so parallel PRs cannot
   collide; the PR title leads with the version token, and squash-merge
   carries it into the commit message where changelog-generator already
   reads.
3. **Advance rule.** A merge changing the versioned surface advances N (the
   same surface version-manager bumps); docs/CI-only merges do not.
4. **Derivable counter.** Next N = highest existing `v<base>-dev.*` tag + 1;
   the declaration and tags are the only state; drift self-heals by
   recomputation.
5. **Dev merges get tagged.** `v1.3.0-dev.N` on the squashed merge commit,
   agent-applied post-merge (same sequencing as release-promoter's tag step,
   which also follows the human merge), making points diffable
   (`git diff v1.3.0-dev.5 v1.3.0-dev.6`).
6. **Base = next-release target** (Maven semantics). A line opens targeting
   the next release; the agent re-derives the base when accumulated
   changelog categories outgrow it; the release PR's changelog-derived
   number is the verdict over the dev base's claim.
7. **First-semver adoption.** The agent establishes the line at the repo's
   next versioned change or release; the base is justified from repo
   evidence (0.x initial-development; 1.0.0-family production history — the
   repro case, 2020-era date tags, selects `1.0.0-dev.0`); date tags remain
   history.
8. **Authority.** The agent selects and justifies every number in the work
   record; a developer version directive overrides.

Design evidence: semver.org §9–§11 (pre-release syntax and precedence —
numeric identifiers compare numerically so `dev.10 > dev.2`; a pre-release
ranks below its release, making the conversion semver-native);
release-please's Maven snapshot strategy (in-tree dev state); Go's
date-tag-to-1.0.0 precedent (stability-commitment ground) against the 0.1.0
initial-development convention (semver FAQ, npm, Cargo, changesets); PEP
440's epoch mechanism considered and rejected as unnecessary.

## Success criteria

- SC-1 (content): `skills/programming-principles/references/practices.md`'s
  versioning-discipline section states the mandate that every deck-managed
  repository carries semver versioning across both tracks — release PRs
  carry the release version, regular PRs carry the in-progress dev version.
  Instrument: read the section; the mandate sentences naming both tracks are
  present.
- SC-2 (content): `skills/version-manager/SKILL.md` states the dev-line
  mechanics of R-2 — in-tree `X.Y.Z-dev.N` declaration, versioned-surface
  advance rule, docs/CI-only non-advance, tag-derived counter, base
  targeting with agent re-derivation. Instrument: read the file; each
  mechanic is stated.
- SC-3 (content): `skills/version-manager/SKILL.md` states the first-semver
  adoption rule of R-3 — adoption trigger, agent-justified selection from
  repo evidence, developer-directive override, date tags untouched.
  Instrument: read the file; each element is stated.
- SC-4 (content): `skills/release-promoter/references/operating-protocol.md`
  states the release conversion of R-4 — dev-suffix strip, changelog-derived
  release number authoritative over the dev base claim, `v{semver}` tag.
  Instrument: read the protocol's tag-and-release section; each element is
  stated.
- SC-5 (content): `skills/git-workflow-pr/SKILL.md` states the PR title form
  of R-5 — version token leading, bare on release PRs, `-dev.N` on dev PRs.
  Instrument: read the file; the form is stated.
- SC-6 (content): the numbering-authority rule of R-6 is stated where R-2
  and R-3 land — the agent selects and justifies every version number in the
  work record; a developer version directive overrides. Instrument: read
  version-manager SKILL.md; the authority rule is stated.

## Success-criteria table

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | Two-track semver mandate in the versioning discipline | content | read `practices.md` versioning section |
| SC-2 | Dev-line mechanics in version-manager | content | read `version-manager/SKILL.md` |
| SC-3 | First-semver adoption rule in version-manager | content | read `version-manager/SKILL.md` |
| SC-4 | Release conversion in release-promoter protocol | content | read `operating-protocol.md` tag-and-release section |
| SC-5 | PR title version-token form in git-workflow-pr | content | read `git-workflow-pr/SKILL.md` |
| SC-6 | Numbering-authority rule stated with override | content | read `version-manager/SKILL.md` |

## Impact

- Every managed repo's PR surface gains a leading version token — mechanical
  title churn on every PR from adoption onward.
- The release pipeline's first-semver halt is removed: the agent selects and
  justifies instead of halting.
- Agents gain version-selection authority bounded by developer directive
  override — the delegation the triage addendum states.
- The deck's own repository adopts at its next release under the same rule
  (its tags today are parent-pointer and date tags).
- Risk: a stale dev base can misstate the target between re-derivations —
  bounded by R-4: the release PR's changelog-derived number is authoritative.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
