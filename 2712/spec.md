<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2712; regression report + store evidence 2026-11-04 -->

# Spec — single-repo spec scoping with per-repo split for spanning requirements

## Problem

Specs authored under the deck fail repo-boundary discipline in two shapes.
The deck's spec→plan chain carries no repo-scoping rule: the spec card's
scope-creep guard (`skills/spec/SKILL.md` §1) targets invented criteria, not
repo scope; the chain's only repo-boundary language is a reactive
validation-loop trigger in `skills/spec/references/validation-standards.md`
(reactive structural re-evaluation, fired only on non-convergence or
revision-count — never at authoring); the `plan` card derives wholly from the
spec, so a bundled spec yields a bundled plan unchecked.

Observed failures in the stores (dated evidence), one per failure shape:

- **Bundled scope** — one spec carrying work for more than one repository:
  `opencode-config#2161` (parent-store spec whose SCs demand work on the
  `.opencode` repo and GitBucket) and `.opencode#2683` (deck-store spec
  whose R-6 repairs parent-repository state).
- **Misfiled home** — a single-repo spec filed in the wrong repo's store:
  `opencode-config#1447`, `#1448`, `#1589` (parent-store specs whose entire
  affected-file sets sit under `.opencode/` — deck-repo work in the parent
  store).

History check: the pre-rip deck's repo-awareness guard
(`attic/skills/issue-operations-core/tasks/creation.md:326`) guarded issue
*filing routing* only — no spec-scope rule existed even pre-rip. This is new
deck content, not a restoration.

## Scope

Repository: `.opencode` (this deck repo). Deliverables:

- `skills/spec/SKILL.md` — the authoring-time rule (R-1, R-2).
- `skills/spec/references/validation-standards.md` — the proactive
  validation check (R-3).
- The tests-v2 behavioral scenario (and its fixture) files SC-1 and SC-5
  require, under `tests-v2/behaviors/` — exact paths fixed at plan time per
  the deck's scenario conventions.

No parent-repo (`opencode-config`) file changes. This spec practices the
single-repo rule it proposes: the deck card is the deliverable, and the deck
repo owns deck-card paths.

## Requirements

- R-1: The spec card SHALL carry a normative single-repo scope rule: a
  spec's scope covers exactly one repository — the repository owning the
  files the requirements touch, resolved via the session-init `path`-prefix
  routing — and the spec is filed in that repository's issue store (the
  home-store rule: scope repo and filing home coincide). Card text stays
  root-agnostic (no repository names, owners, or absolute paths).
- R-2: The spec card SHALL state the split discipline for spanning
  requirements: when a spec's requirements touch files under more than one
  repo's session-init `path` prefix — a fact-decidable determination from
  the paths, never a judgment call — the spec stage produces one spec per
  repository, each filed in its own repo's issue store per the issues
  card's creation flow, each naming its siblings by qualified `owner/repo#N`
  reference, rather than one bundled spec. Prohibition is explicitly not
  the design: some spanning work is legitimately one job (e.g.
  `.opencode#2683`'s pointer repair); the rule splits it, it does not
  forbid it.
- R-3: The validation standards reference SHALL carry repo-boundary
  containment as a proactive check applied at every fresh-context spec
  validation dispatch — where containment covers both the spec's scope
  (its requirements touch exactly one repo's `path` prefix) and its home
  (it is filed in that repo's issue store) — in addition to the existing
  reactive structural re-evaluation trigger (which is retained, not
  replaced).
- R-4: The work SHALL NOT modify `floor.md`.

## Impact

Consumers: agents running the spec stage in any repo (the card text stays
root-agnostic). The issues card's recomposition protocol remains the reactive
split mechanism inside validation loops; this rule adds the authoring-time
gate. Risk: low — card-text change; the behavioral SC requires harness
coverage. Blast radius on the deck's own test suite, verified 2026-11-04: no
tests-v2 scenario asserts the spec card's or the validation-standards
reference's text content — the only two hits referencing those paths
(`tests-v2/behaviors/2657-sc5-directed-deck-edit-open-choice.sh` and its
fixture) use the card as an edit subject in a scenario prompt, not as a
content assertion — so the card edit breaks no existing assertion.

## Success criteria

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | Given a spec request whose requirements span both repos, the agent produces per-repo sibling specs — one per repo, each filed in its own store, cross-referenced by `owner/repo#N` — not one bundled spec | behavioral | clean-room dispatch per the behavioral-testing card's tier-1 path: a fresh-context reviewer reads the spec card's rule text and the recorded session evidence from the harness runs (2026-11-05, six runs) and judges whether the stated rule mandates the per-repo split for a spanning request. Instrument note 2026-11-05: the harness scenario could not produce a RED — in every run the environment's own routing facts (session-init repo table) supplied the correct destination pre-change, and seven fixture iterations kept failing on store-worktree mechanics (provenance in the scenario files' re-scope blocks); tier-1 is the behavioral-testing card's sanctioned evidence path for simple card changes |
| SC-2 | The spec card's text carries R-1 and R-2 | structural | read `.opencode/skills/spec/SKILL.md` post-implementation and verify the clauses state the single-repo rule and the fact-decidable split discipline as R-1/R-2 require |
| SC-3 | The validation standards reference carries the proactive repo-boundary check | structural | read `.opencode/skills/spec/references/validation-standards.md` and verify the reference directs the fresh-context dispatch to examine repo-boundary containment proactively at every spec validation |
| SC-4 | `floor.md` is unmodified by the work | structural | PR diff against trunk shows no `.opencode/floor.md` delta |
| SC-5 | Given a spec request whose requirements touch only one repo's `path` prefix, the agent files the spec in that repo's issue store — not the other repo's store | behavioral | clean-room dispatch per the behavioral-testing card's tier-1 path: a fresh-context reviewer reads the spec card's rule text and the recorded session evidence from the harness runs (2026-11-05 — the runs
recorded under `tmp/behavioral-evidence-2712-*` and the polled test homes;
every run's routing decision reached the deck store from the environment's
routing facts) and judges whether the stated rule mandates the home-store filing for a single-repo request. Same instrument note as SC-1 |
| SC-6 | The validation standards reference retains the existing reactive structural re-evaluation trigger, per R-3's retention clause | structural | read `.opencode/skills/spec/references/validation-standards.md` post-implementation and verify the reactive trigger machinery — the structural re-evaluation opened by the non-convergence judgment and the count trigger — is still present in the reference |

## Evidence types

Behavioral SC-1 and SC-5 assert the spec-stage filing behavior; their
instruments are clean-room dispatches (tier-1 per the behavioral-testing
card) over the card text and the recorded harness-run session evidence —
re-instrumented 2026-11-05 after seven harness attempts could not isolate
the rule's behavioral delta from the environment's own routing facts (the
scenario files' re-scope blocks carry the run-by-run provenance). Structural
SC-2, SC-3, SC-4, SC-6 are fact-decidable text/diff checks — no runtime
needed.

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
(spec card §1 addition, next to the existing scope-creep guard); a
requirement whose paths span repos splits into per-repo sibling specs, each
filed in its own repo's store, cross-referenced with the qualified
`owner/repo#N` form (the attic's closing-keyword formatting precedent). The
validation standards reference gains the proactive check so a bundled spec
fails validation rather than slipping through to plan; the existing reactive
trigger stays.

Traceability: R-1, R-2 ← the regression report and the store evidence above
(R-1's home-store clause ← the misfiled-home evidence; R-2's split ← the
bundled-scope evidence); R-3 ← the brainstorm's enforcement decision
(proactive over reactive-only); R-4 ← the developer's stated constraint
(2026-11-04).

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
