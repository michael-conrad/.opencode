# Plan — .opencode#2760: git-workflow-pr stacked-PR term anchor, precedent stance, create-time enumeration, companion disposition

## Goal

Amend `skills/git-workflow-pr/SKILL.md` (the deck's `git-workflow-pr` card) so four decision-time surfaces are defended: the "stacked PR" token binds to rule 3's one-trunk-PR definition at token arrival, an open per-layer PR is named a violation rather than precedent, the rule-2 pre-create checklist gains the same-scope PR enumeration, and rule 3's scope provision gains the companion-PR disposition. Confined to that card; one provenance entry; no other clause rewritten. Delivers spec SC-1 … SC-7.

## Execution surface

Repository: the deck submodule (`.opencode/`, remote `michael-conrad/.opencode`). Branch `2760-stacked-pr-term-anchor`, cut from the trunk tip (`a91e8bbff5`) verified against remote `main` this session. Edits target one file: `skills/git-workflow-pr/SKILL.md`. Behavioral scenario (item 7) runs under tests-v2 per the deck's existing scenario layout (`tests-v2/`), executed via the behavioral-testing card's harness.

## Items — one item per SC

**Item 1 — SC-1 (rule 1 term anchor).**
- **Deliverable:** a pointer appended to rule 1's not-done-default paragraph stating that a card-scoped token reading "stacked PR" carries rule 3's definition (one PR against the trunk, one squashed commit per issue in the scope) and that the ecosystem's per-layer reading does not govern the token.
- **RED:** reading current rule 1 shows no stacked-PR term anchor anywhere in the token-arrival step.
- **GREEN:** the addition in rule 1 only.
- **Tier marks:** no authored test; instrument class is fact check.
- **Instrument:** read the amended rule 1; assert the pointer names rule 3's definition with its content and states per-layer non-governance (SC-1's instrument).

**Item 2 — SC-2 (rule 3 contrast).**
- **Deliverable:** beside rule 3's stacked-PR definition, the explicit contrast: the ecosystem pattern — a series of PRs where each targets the branch of the PR below it, forming a chain that lands on the trunk (GitHub's documented form) — is the per-layer shape this rule names as the violation.
- **RED:** rule 3 states its definition once with no contrast where the token is read.
- **GREEN:** the contrast sentences added beside the definition.
- **Tier marks:** no authored test; fact check.
- **Instrument:** read the amended rule 3; assert both halves stated and the ecosystem form marked prohibited (SC-2).

**Item 3 — SC-3 (precedent stance).**
- **Deliverable:** rule 3 gains the precedent stance: an existing open per-layer PR is a violation, not precedent or house style; the creating agent halts for developer direction on its disposition and neither imitates its shape nor closes it agent-side.
- **RED:** no card text classifies an already-open per-layer PR as a violation.
- **GREEN:** the stance sentences appended to rule 3.
- **Tier marks:** no authored test; fact check.
- **Instrument:** read amended rule 3; assert the stance and halt-for-direction disposition (SC-3).

**Item 4 — SC-4 (checklist same-scope enumeration).**
- **Deliverable:** one new checklist item in rule 2: before creating any PR, enumerate the repository's open pull requests intersecting the authorization scope — by head or base branch, by closing-keyword reference to a scope issue, or by stacked-chain membership — using the platform CLI (`gh pr list` / `gb` equivalent); resolve each intersecting PR against rule 3 before creation; creation is blocked until every find is dispositioned.
- **RED:** rule 2's checklist verifies commits, tests, verify, and pointer state but never enumerates same-scope PRs.
- **GREEN:** one checklist item appended; no existing item rewritten.
- **Tier marks:** no authored test; fact check.
- **Instrument:** read amended rule 2; assert all four elements — what is enumerated, the CLI fact source, resolution against rule 3, block until dispositioned (SC-4).

**Item 5 — SC-5 (companion disposition).**
- **Deliverable:** rule 3's scope provision gains the companion disposition: an approved spec that explicitly names a second PR-shaped deliverable — its head, base, and sequencing — is the developer's named split (a distinct deliverable, not a stacked-PR layer, filed per the stated sequencing); without that explicit naming, and outside spec mandates, the one-PR default holds.
- **RED:** the scope provision's split condition does not state whether a spec-named second PR shape satisfies "the developer named the split."
- **GREEN:** the companion provision added; the delivered #2639 scope-boundary text extended, not rewritten.
- **Tier marks:** no authored test; fact check.
- **Instrument:** read amended rule 3 scope provision; assert both branches — named-split permission and the default (SC-5).

**Item 6 — SC-6 (confinement check, provenance entry).**
- **Deliverable:** the card's provenance line gains exactly one entry citing .opencode#2760 (addition only, no existing entry rewritten); then the confinement verification over items 1–6's diff; correction of any out-of-scope edit found.
- **RED:** running the diff against the card's trunk state before items 1–5 shows the four additions and the new provenance entry absent; after items 1–6 it must show changes confined to rule 1's pointer, rule 3's three appended provisions, rule 2's single new item, and the exactly-one provenance entry.
- **GREEN:** the provenance entry authored; items 1–5 verified confined; diff text contains no repository names and no absolute paths.
- **Tier marks:** no authored test; fact check.
- **Instrument:** `git diff` of the amended card against trunk; assert the SC-6 confinement clauses clause by clause.

**Item 7 — SC-7 (behavioral scenario).**
- **Deliverable:** a tests-v2 behavioral scenario provisioned and executed under the harness: a stacked branch chain, an open per-layer PR filed by a prior session, and the terminal token (`approved for stacked PR`); the run's agent performs the same-scope enumeration, halts for developer direction on the prior per-layer PR, and files no PR this run — the scope's trunk-PR step is held for developer direction pending on the halted finding's disposition.
- **RED:** under the current card text a live run either files no trunk-anchored single PR or imitates the per-layer shape — the scenario's assertions fail on the pre-amendment card.
- **GREEN:** the scenario passes against the amended card.
- **Tier marks:** authored behavioral scenario — tier `pr-validation` (heavy instrument: container provisioning plus a live run; on-demand routing only, never a default run — dispatched under the behavioral-testing card at implementation time).
- **Instrument:** assert from the container's PR API state and the session record: zero new PRs beyond the provisioned violation; the provisioned violation PR remains open and unmodified; the session record shows both the same-scope enumeration and the halt-for-direction. (Revised in place, 2026-11-21: SC-7's original trunk-PR clause was unimplementable against the scenario — R-3's block and the spec's own Edge Cases row prescribe halt-before-creating on a discovered prior-session violation; run 1 observed exactly that, and the discovery is recorded in the spec's revision note and the run's verdict-confirmation record.)

## Dependency order

Items 1–4 are independent text additions to one file; items 3, 2, and 5 each touch rule 3 — three sequential rule-3-touch edits, kept sequential to keep each edit atomic. Item 6 authors the provenance entry and then runs last over the assembled diff — it cannot precede the text items, and item 7's live run asserts behavior of the completed amended card, so it follows item 6. Order: 1 → 3 → 2 → 5 → 4 → 6 → 7 (items 1–5 may be committed in any order; the stated order keeps per-file rule-touch edits sequential).

## Traceability

| Item | SC(s) |
|---|---|
| 1 | SC-1 |
| 2 | SC-2 |
| 3 | SC-3 |
| 4 | SC-4 |
| 5 | SC-5 |
| 6 | SC-6 |
| 7 | SC-7 |

No orphans in either direction.

## Verification summary

Items 1–6 verify through fact checks (read-assertions on the amended file plus the confinement diff) — no authored structural test files. Item 7 authors one test: a behavioral scenario script under tests-v2, tier `pr-validation`, run once at cycle time under the behavioral-testing card's harness; its disposition at merge is per the test-discipline card. Cycle-time runs: the fact checks and the diff after each item; the behavioral run after item 6. No runs are deferred to PR-check time beyond the standard structural gates (lint/format over the touched markdown, if the deck registers any).

## Status boundary

Implementation state lives in the pipeline; this body carries none.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
