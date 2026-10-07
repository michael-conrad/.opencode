# Spec: .opencode#2550 — Spec-validation discipline restoration: card-level validate step, plan/implement fidelity mandates, judgment-only enforcement

Provenance: observed regression reported by the developer 2026-10-07 — production-impacting. The #2490 deck rip (stage 4a, commit `08112303`, landed 2026-10-04) removed the prior deck's spec-validation and pre-implementation audit machinery (preserved under `attic/`, tag `pre-rip`: `skills/spec-creation/tasks/validate.md`, the `skills/audit/` DiMo chains); the replacement slim cards instruct authoring but never verify what was authored. Git history shows roughly twenty specs authored under the no-validation regime in the 2026-10-04 → 10-07 window (#2494, #2496, #2499, #2500, #2504, #2509, #2516, #2517, #2518, #2527, #2528, #2531, #2532, #2541, #2543, #2548, #2549, #811, #601, #1011; parent store: opencode-config#374), and many already reached merged PRs (#2543, #1011, #2538, #811, #601, #582, #2532, #169, #2527) — defective-criteria risk is in shipped deck behavior. Corroborating systemic antecedent: lessons-learned 2026-06-20 lesson 6 — advisory text without an enforcement mechanism does not change behavior.

## Problem

Three developer-observed defect classes, all traced to one structural cause — the rip removed verification and its replacements carry none:

1. **Defective specs.** The spec card has no validate step. "Every SC is testable" is an instruction to the author; nothing checks the result, so defective criteria flow straight into plan and implement.
2. **Either/or logic in criteria.** The prior deck's determinism check and disjunctive-pattern sub-check — which flagged criteria presenting alternatives as one requirement — were dropped in the rip and restored nowhere.
3. **Audits not happening.** Pre-implementation spec-audit is gone. The only remaining check is the verify card's single post-deliverable reviewer, whose churn rule suppresses the breadth that used to surface spec defects before implementation.

Developer constraints that shape the fix (stated this session):

- The discipline is incorporated directly into the skill cards and skill detail cards — not globally. Zero growth of the always-injected surface: no repeat of floor fattening.
- No static scripted checks. Lexical pattern checks are gamed — agents phrase around trigger words, the check passes, and the defect survives. Enforcement is judgment, exercised by fresh context.
- Forward-only. The window specs are not swept by this fix; the developer will request on-demand audits when reviewing prior specs for approval. The design keeps the audit criteria stable and restatable so those future audits run on the same bar as spec-time validation.

## Fix shape

| Card | Change |
|---|---|
| `skills/spec/SKILL.md` | Gains a validate step in its definition of done: one fresh-context validation dispatch after authoring; FAIL → targeted revision → re-validate; still failing → halt to the developer naming the failing criteria. The developer approval gate is unchanged and follows validation. |
| `skills/spec/references/validation-standards.md` (new) | The validation criteria set as defect descriptions — judgment targets, not patterns — plus the bounded-loop discipline. On-demand audits restate it verbatim (criteria invariance per #2518 semantics). |
| `skills/plan/SKILL.md` | Consume-only-validated-specs mandate: plan items trace to SCs; a defective or ambiguous criterion discovered at plan time produces BLOCKED naming the defect. |
| `skills/implement/SKILL.md` | SC fidelity mandate: no weakening, skipping, deferring, or reinterpreting a criterion to make it passable; an unimplementable criterion produces BLOCKED with root cause. |

Untouched by this fix: `floor.md`, `routing.md`, `skills/verify/SKILL.md` (it already mandates one fresh-context reviewer with an invariant bar), `skills/work`, `skills/explore`, `skills/behavioral-testing` (the validate step lives inside the spec card's done, so no stage gate is needed elsewhere), and the tests-v2 harness (used as-is).

Enforcement posture (normative): every new check is intent-decidable and judgment-only — no keyword lists, no lexical scans, no scripted pattern matching anywhere in the new content. Inspecting this change's own artifacts for compliance remains a fact check about files; that is not a runtime scripted check on future specs.

## Success criteria

### SC-1 (structural) — scope containment

The change touches only `skills/spec/SKILL.md`, `skills/spec/references/validation-standards.md`, `skills/plan/SKILL.md`, and `skills/implement/SKILL.md`. `floor.md`, `routing.md`, and every other card are byte-identical to their pre-change state.

- **Verify:** `git diff --stat` for the change shows exactly those four paths and no others.

### SC-2 (structural) — validate step is the spec card's definition of done

`skills/spec/SKILL.md` states that a completed spec includes one fresh-context validation dispatch executed before the developer approval gate, with the bounded FAIL → revise → re-validate loop and the halt-on-persistent-FAIL rule, referencing `references/validation-standards.md` as the criteria source.

- **Verify:** read `skills/spec/SKILL.md`; the dispatch mandate, the loop, the halt rule, and the detail-card reference are present.

### SC-3 (structural) — judgment-only enforcement content

`skills/spec/references/validation-standards.md` states the validation criteria as defect descriptions for reviewer judgment. It contains no keyword lists, no trigger-word tables, no lexical scan instructions, and no scripted checks. The plan and implement card mandates name BLOCKED responses, not detection patterns.

- **Verify:** read the three files; defect descriptions present; no keyword, trigger-word, or lexical-scan machinery present.

### SC-4 (behavioral) — validation FAILs a defective probe spec

A spec containing a planted defective criterion — an alternative presented as one requirement — receives a FAIL verdict from the validation dispatch that names the criterion and the defect class.

- **Verify:** two-SC pattern per `tests-v2/AGENTS.md` — artifact-generating behavioral run via a scenario in `tests-v2/behaviors/` with a fixture spec carrying the planted defect; clean-room evaluation of `session.yaml` confirms the FAIL verdict names the planted criterion and its defect class.

### SC-5 (behavioral) — validation PASSes a clean probe spec

A spec whose criteria are all sound receives a PASS verdict from the validation dispatch, with no spurious findings — the validator is bound by the same anti-churn discipline as the verify reviewer.

- **Verify:** two-SC pattern per `tests-v2/AGENTS.md` — behavioral run with a fixture spec whose criteria are sound; clean-room evaluation confirms PASS and the absence of style-only findings.

### SC-6 (behavioral) — plan BLOCKs on a defective spec

An agent executing the plan card against a spec with a defective criterion returns BLOCKED naming the criterion and the defect, rather than producing plan items that route around it.

- **Verify:** two-SC pattern per `tests-v2/AGENTS.md` — behavioral run dispatching plan work against the defective fixture spec; clean-room evaluation confirms BLOCKED with the named defect.

### SC-7 (behavioral) — implement preserves SC fidelity

An agent executing the implement card that cannot satisfy a criterion returns BLOCKED with the root cause; it does not weaken, skip, defer, or reinterpret the criterion to make it passable.

- **Verify:** two-SC pattern per `tests-v2/AGENTS.md` — behavioral run on a fixture whose criterion cannot be satisfied within the scenario; clean-room evaluation confirms BLOCKED with root cause and no criterion modification.

### SC-8 (structural) — on-demand audits run on the same bar

The spec card's revision path validates an existing spec against the same criteria set restated verbatim; no second criteria source exists in the deck.

- **Verify:** read `skills/spec/SKILL.md` and `skills/spec/references/validation-standards.md`; the revision path mandates the same criteria reference; exactly one criteria source exists.

### SC-9 (structural) — governance compliance

The change passes the deck's own admission gate: the deck-debt ledger entry documents the predicate classification (intent-decidable, judgment-only) and what the change replaces (the validation gap left by the #2490 attic retirement); every touched card meets the card standards (frontmatter `name`/`description`/`license`, provenance line, description stating when to load); all links added by the change resolve.

- **Verify:** the deck-debt ledger entry exists with the required content; frontmatter and provenance present on every touched card; `./.opencode/tools/reference-integrity --scan` exits 0.

## Out of scope

- Sweeping the window specs through validation — the developer will request on-demand audits per spec when reviewing for approval.
- Restoring the retired DiMo investigator/evaluator/arbiter chains, the 11-dimension holistic matrix, or artifact-chain verdicts — the trimmed judgment core only.
- Restructuring the verify card — its single-reviewer shape and criteria-invariance rule already match this design.
- Changes to `floor.md`, `routing.md`, or the tests-v2 harness.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
