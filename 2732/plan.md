# Plan — mandate semver versioning across release and dev PR tracks (.opencode#2732)

Spec: `.opencode/.issues/2732/spec.md`. All items trace to its SCs; all are
content edits to existing card sections (no new files, no floor change — the
always-loaded surface discipline keeps the mandate at card level). Item order
follows the spec's Approach: the version model is stated once in
version-manager and cited, not duplicated, by the other cards.

## Item 1 — practices.md: two-track mandate (SC-1; R-1)

- **Deliverable:** extend the "Versioning discipline (semver)" section of
  `skills/programming-principles/references/practices.md` with the mandate:
  every deck-managed repository carries semver versioning across both tracks —
  release PRs carry the release version, regular PRs carry the in-progress dev
  version — with operations deferred to `version-manager` /
  `release-promoter` (the section's existing defer pattern).
- **RED (structural, ephemeral):** read shows the section states only the
  bump-level expectation; no sentence names the two tracks or mandates semver
  for managed repos.
- **GREEN:** add a mandate sentence (both tracks named) plus one pointer to
  the owning cards; the section's "what and why, not operations" framing is
  preserved — no mechanics duplicated here.
- **Instrument (tier: smoke):** read the section; the mandate sentences naming
  both tracks are present (SC-1 instrument).

## Item 2 — version-manager: dev-line mechanics + numbering authority (SC-2, SC-6; R-2, R-6)

- **Deliverable:** new numbered rules in `skills/version-manager/SKILL.md`
  covering the dev-line mechanics and the numbering-authority rule.
- **RED (structural, ephemeral):** read shows the card has five rules, none of
  which states `X.Y.Z-dev.N`, the advance rule, the tag-derived counter, or
  the authority rule.
- **GREEN:** add (a) the dev-line rule: the canonical version declaration
  reads `X.Y.Z-dev.N` between releases; a merge changing the versioned
  surface (the surface rule 2 already bumps) advances N; docs-only and
  CI-only changes display the current version without advancing N; N derives
  from existing dev tags (highest `v<base>-dev.*` + 1), not stored state; the
  dev base targets the next release and is re-derived by the agent when
  accumulated changelog categories outgrow it; dev merges are tagged
  `v{base}-dev.N` post-merge, agent-applied. (b) The authority rule: the
  agent selects and justifies every version number — counter advance, base
  selection, first base — in the work record; an explicit developer version
  directive overrides any derivation.
- **Instrument (tier: smoke):** read `SKILL.md`; each mechanic of SC-2 and the
  authority rule of SC-6 stated.

## Item 3 — version-manager: first-semver adoption (SC-3; R-3)

- **Deliverable:** one numbered rule in the same card covering adoption.
- **RED (structural, ephemeral):** read shows no rule addresses a repo
  without semver history.
- **GREEN:** the adoption rule: a managed repo without a semver history
  adopts semver at its next versioned change or release; the agent selects
  and justifies the first version from repository evidence — 0.x for
  initial-development repos, 1.0.0-family for production-history repos — and
  an explicit developer version directive overrides the selection; date-based
  historical tags remain untouched.
- **Instrument (tier: smoke):** read `SKILL.md`; trigger, agent-justified
  selection, override, date-tag preservation each stated (SC-3 instrument).

## Item 4 — release-promoter: release conversion (SC-4; R-4)

- **Deliverable:** extend the "Tag and release" section of
  `skills/release-promoter/references/operating-protocol.md` with the release
  conversion, in place (no new section).
- **RED (structural, ephemeral):** read shows the section states the
  `v{semver}` format but nothing about a dev suffix or the dev base's claim.
- **GREEN:** add the conversion: the release PR strips the dev suffix and
  carries the bare version; the release number is re-derived from the
  changelog (authoritative over the dev base's claim); the `v{semver}` tag
  follows the human merge per the existing protocol (no change to the
  existing sequencing bullets).
- **Instrument (tier: smoke):** read the tag-and-release section; dev-suffix
  strip, changelog authority, tag format each stated (SC-4 instrument).

## Item 5 — git-workflow-pr: PR title version token (SC-5; R-5)

- **Deliverable:** a rule in `skills/git-workflow-pr/SKILL.md` stating the PR
  title form.
- **RED (structural, ephemeral):** read shows no PR-title convention anywhere
  in the card (grep for "title" returns no convention statement).
- **GREEN:** the form: the version token leads the PR title — bare `vX.Y.Z`
  on release PRs (the release indicator), `vX.Y.Z-dev.N` on dev PRs (the dev
  indicator) — with the remainder following the commit-message shape
  `type(#issue): summary` that `git-workflow-commit` defines for commit
  messages. Canonical cross-reference form (`Read [...]`) to the
  git-workflow-commit card.
- **Instrument (tier: smoke):** read `SKILL.md`; the form is stated
  (SC-5 instrument).

## Verification ordering

Items 1–5 run in order (item 2's single-sourced version model precedes items
4–5, which cite it). After all items, a full six-instrument read pass gates
the PR per the implement card; no heavy-tier items exist (all SCs are
content-class with read instruments), so no behavioral dispatch and no
default-suite run are required.
