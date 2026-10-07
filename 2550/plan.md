# Plan: .opencode#2550 — Spec-validation discipline restoration

Derived entirely from `.opencode/.issues/2550/spec.md`. One item per SC; structural items first (dependency order: cards must exist and be pushed before behavioral runs can exercise them).

## Item 1 — SC-2 + SC-8: spec card validate step

- **Deliverable:** `skills/spec/SKILL.md` gains a validate step: one fresh-context validation dispatch after authoring, before the developer approval gate; bounded FAIL → targeted revision → re-validate loop; halt-on-persistent-FAIL naming the failing criteria; reference to `references/validation-standards.md` as the single criteria source, also binding the revision path and on-demand audits (criteria restated verbatim from the same reference). Provenance line cites #2550.
- **RED:** `grep -n "validat" skills/spec/SKILL.md` → no validation-dispatch mandate present (only unverified authoring instructions).
- **GREEN:** insert the validate item before the approval-gate item.
- **Verify:** read the card; dispatch mandate, loop, halt rule, and detail-card reference present (SC-2); the revision-path sentence binds the same reference and no second criteria source exists (SC-8).

## Item 2 — SC-3: validation-standards reference

- **Deliverable:** new `skills/spec/references/validation-standards.md` stating the validation criteria as defect descriptions for reviewer judgment, the bounded-loop discipline, the verdict contract (PASS/FAIL naming criteria + defect class), the anti-churn binding (same as the verify reviewer), and criteria invariance for on-demand audits.
- **RED:** file does not exist; `test -f` fails.
- **GREEN:** create the reference; judgment-only content.
- **Verify:** read the file; defect descriptions present; no keyword-list/trigger-word/lexical-scan machinery present.

## Item 3 — SC-6: plan card consume mandate

- **Deliverable:** `skills/plan/SKILL.md` gains the consume-only-validated-specs mandate: plan items trace to SCs; a defective or ambiguous criterion discovered at plan time produces BLOCKED naming the criterion and the defect. Provenance cites #2550.
- **RED:** `grep -n "BLOCKED" skills/plan/SKILL.md` → 0 matches.
- **GREEN:** add the mandate item.
- **Verify:** read the card; BLOCKED response named, no detection-pattern machinery.

## Item 4 — SC-7: implement card fidelity mandate

- **Deliverable:** `skills/implement/SKILL.md` gains the SC-fidelity mandate: no weakening, skipping, deferring, or reinterpreting a criterion to make it passable; an unimplementable criterion produces BLOCKED with the root cause. Provenance cites #2550.
- **RED:** `grep -n "BLOCKED" skills/implement/SKILL.md` → 0 matches.
- **GREEN:** add the mandate item.
- **Verify:** read the card; mandate present, no detection-pattern machinery.

## Item 5 — SC-9: governance compliance

- **Deliverable:** deck-debt ledger entry (comment on `.opencode#2534`) documenting predicate classification (intent-decidable, judgment-only) and what the change replaces (the validation gap left by the #2490 attic retirement); frontmatter `name`/`description`/`license` + provenance present on all touched cards; all new links resolve.
- **RED:** `.opencode/.issues/2534` has no entry citing #2550; `./.opencode/tools/reference-integrity --scan` unverified.
- **GREEN:** post the ledger comment; run the integrity scan.
- **Verify:** ledger entry readable in the store; scan exits 0.

## Item 6 — SC-1: scope containment

- **Deliverable:** diff evidence that the deck change touches only the four spec-listed paths.
- **RED:** (baseline) branch has no deck changes yet.
- **GREEN:** items 1–4 land as deck-content commits.
- **Verify:** `git -C .opencode diff --stat origin/main -- skills/` shows exactly `skills/spec/SKILL.md`, `skills/spec/references/validation-standards.md`, `skills/plan/SKILL.md`, `skills/implement/SKILL.md` and no others. Test-harness scenario/fixture files (items 7–11) are evidence instruments riding the branch, per #2518 SC-5 precedent — SC-1 is verified over the deck-content change.

## Item 7 — SC-4: behavioral — validation FAILs a defective probe spec

- **Deliverable:** scenario script `tests-v2/behaviors/2550-sc4-validate-defective-spec.sh` + fixture issue carrying a spec with a planted defective criterion (an alternative presented as one requirement); run through the harness (commit → push → fetch/verify → run, monitored per tests-v2 §14); artifacts produced.
- **RED:** on the pre-change deck, no validation dispatch exists (behavior absent).
- **GREEN:** with the new cards on the effective commit, the run agent executes the validation dispatch against the fixture spec.
- **Verify:** artifact directory contains `session.yaml` (PRIMARY source) + monitoring evidence; clean-room evaluation is Item 8.

## Item 8 — SC-4 clean-room evaluation

- **Deliverable:** clean-room evaluator dispatch (artifact directory + SC criterion only) producing `evaluation-<timestamp>.yaml`.
- **Verify:** verdict confirms the FAIL names the planted criterion and its defect class.

## Item 9 — SC-5: behavioral — validation PASSes a clean probe spec (+ clean-room evaluation)

- **Deliverable:** scenario `2550-sc5-validate-clean-spec.sh` + fixture spec with sound criteria; run + clean-room evaluation confirming PASS and no style-only findings (anti-churn binding held).

## Item 10 — SC-6: behavioral — plan BLOCKs on a defective spec (+ clean-room evaluation)

- **Deliverable:** scenario `2550-sc6-plan-blocks-defective-spec.sh` reusing the defective fixture; run + clean-room evaluation confirming BLOCKED naming the criterion and defect, with no plan items routing around it.

## Item 11 — SC-7: behavioral — implement preserves SC fidelity (+ clean-room evaluation)

- **Deliverable:** scenario `2550-sc7-implement-blocked-unimplementable.sh` + fixture whose criterion cannot be satisfied within the scenario; run + clean-room evaluation confirming BLOCKED with root cause and no criterion modification.

## Item 12 — Post-implementation gates

- **Verify:** full `test-enforcement.sh` content-verification suite green; `./.opencode/tools/reference-integrity --scan` exit 0; fresh-context `verify` dispatch over SC-1..SC-9; then PR per `git-workflow-pr`.
