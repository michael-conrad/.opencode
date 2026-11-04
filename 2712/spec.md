<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2712; regression report + store evidence 2026-11-04 -->

# Spec — single-repo spec scoping with per-repo split for spanning requirements

## Problem

Specs authored under the deck bundle work spanning multiple repositories. The
deck's spec→plan chain carries no repo-scoping rule: the spec card's
scope-creep guard (`skills/spec/SKILL.md` §1) targets invented criteria, not
repo scope; the deck's only "repo boundaries" language is a reactive
validation-loop trigger in `skills/spec/references/validation-standards.md`
(reactive structural re-evaluation, fired only on non-convergence or
revision-count — never at authoring); the `plan` card derives wholly from the
spec, so a bundled spec yields a bundled plan unchecked.

Observed failures in the stores (dated evidence):

- Parent-store specs carrying deck-repo deliverables: `opencode-config#1447`,
  `#1448`, `#1589` (entire affected-file sets under `.opencode/`),
  `opencode-config#2161` (SCs demanding work on the `.opencode` repo and
  GitBucket).
- Deck-store spec carrying parent-repo work: `.opencode#2683` (R-6 repairs
  parent-repository state).

History check: the pre-rip deck's repo-awareness guard
(`attic/skills/issue-operations-core/tasks/creation.md:326`) guarded issue
*filing routing* only — no spec-scope rule existed even pre-rip. This is new
deck content, not a restoration.

## Scope

Repository: `.opencode` (this deck repo). Deliverables:

- `skills/spec/SKILL.md` — the authoring-time rule (R-1, R-2).
- `skills/spec/references/validation-standards.md` — the proactive
  validation check (R-3).

No parent-repo (`opencode-config`) file changes. This spec practices the
single-repo rule it proposes: the deck card is the deliverable, and the deck
repo owns deck-card paths.

## Requirements

- R-1: The spec card SHALL carry a normative single-repo scope rule: a
  spec's scope covers exactly one repository — the repository owning the
  files the requirements touch, resolved via the session-init `path`-prefix
  routing. Card text stays root-agnostic (no repository names, owners, or
  absolute paths).
- R-2: The spec card SHALL state the split discipline for spanning
  requirements: when the developer's requirement genuinely spans more than
  one repository, the spec stage produces one spec per repository — each
  filed in its own repo's issue store per the issues card's creation flow,
  each naming its siblings by qualified `owner/repo#N` reference — rather
  than one bundled spec. Prohibition is explicitly not the design: some
  spanning work is legitimately one job (e.g. `.opencode#2683`'s pointer
  repair); the rule splits it, it does not forbid it.
- R-3: The validation standards reference SHALL carry repo-boundary
  containment as a proactive check applied at every fresh-context spec
  validation dispatch, in addition to its existing reactive structural
  re-evaluation trigger (which is retained, not replaced).
- R-4: The work SHALL NOT modify `floor.md`.

## Success criteria

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | Given a spec request whose requirements span both repos, the agent produces per-repo sibling specs — one per repo, each filed in its own store, cross-referenced by `owner/repo#N` — not one bundled spec | behavioral | tests-v2 behavioral harness scenario (per the behavioral-testing card and the tests-v2 scope anchor): `opencode run` dispatching a spanning spec request; session evidence asserts sibling filings across both stores and no bundled spec artifact |
| SC-2 | The spec card's text carries R-1 and R-2 | structural | read `.opencode/skills/spec/SKILL.md` post-implementation; both normative clauses present |
| SC-3 | The validation standards reference carries the proactive repo-boundary check | structural | read `.opencode/skills/spec/references/validation-standards.md`; the proactive check language present |
| SC-4 | `floor.md` is unmodified by the work | structural | PR diff against trunk shows no `.opencode/floor.md` delta |

## Evidence types

Behavioral SC-1 asserts agent behavior at runtime (spec-stage output shape)
— harness-provisioned per the behavioral-testing card. Structural SC-2,
SC-3, SC-4 are fact-decidable text/diff checks — no runtime needed.

## Out of scope

- Any `floor.md` change (developer constraint, 2026-11-04: "be sure to not
  fatten floor.md").
- A work-card backstop rule — the validation check is the enforcement;
  a second gate is redundant layering.
- Changes to the issues card's recomposition protocol — it remains the
  reactive split mechanism inside validation loops, unchanged.
- Remediation of the historical specs listed as evidence — existing
  artifacts stand as filed.

## Approach

Permit-and-split. The single-repo scope rule is the authoring-time default
(spec card §1 addition, next to the existing scope-creep guard); a genuinely
spanning requirement splits into per-repo sibling specs, each filed in its
own repo's store, cross-referenced with the qualified `owner/repo#N` form
(the attic's closing-keyword formatting precedent). The validation standards
reference gains the proactive check so a bundled spec fails validation rather
than slipping through to plan; the existing reactive trigger stays.

Traceability: R-1, R-2 ← the regression report and the store evidence above;
R-3 ← the brainstorm's enforcement decision (proactive over reactive-only);
R-4 ← the developer's stated constraint (2026-11-04).

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
