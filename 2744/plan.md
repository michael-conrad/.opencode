# Plan: .opencode#2744 — Land mandatory local spec/plan structure standards

## Execution surface

All file edits land on branch `feature/2744-structure-standards` in the clean clone of the deck repository (michael-conrad/.opencode) at `/tmp/opencode/deck-fix/opencode`; the clone's `main` is the trunk tip verified live on 2026-11-16 (`3642e2d5`) per the git-workflow-branch freshness step. Nothing edits the consuming checkout's `.opencode/` submodule worktree. Evidence persistence (SC-5/SC-6 verdicts) writes into `.opencode/.issues/2744/audit/` in the workspace store and syncs through the local-issues tool. Probes run from a probe home built under `/tmp/opencode/deck-fix/probe-home/` (construction specified in Item 5).

## Item 1 (SC-1) — spec structure standard

- **Deliverable:** `skills/spec/references/spec-structure-standards.md` in the deck clone — the mandatory `spec.md` section inventory, adapted from `attic/reference/spec-structure-standards.md` under the spec's reconciliation register (every register ruling applied).
- **RED:** the file does not exist in the clone (`test -f` fails) and no current file under `skills/` names the local-spec layout standard (grep for the file name returns nothing) — the assertion fails against current behavior as of 2026-11-16.
- **GREEN:** write the standard: mandatory sections in fixed order (6-field intent preamble; Not Included; Requirements; SC table with ID/Criterion/Class/Instrument; Dependencies; Traceability; Documentation Sources; Cost Frame; Edge Cases; the completion-gate statement; the adoption posture), each section's mandate stated normatively with its actor and scope named per the writing discipline; the dropped-content verdicts (spec-embedded Items, Phases column, four-way evidence taxonomy, Dispatch Indicators) recorded as prohibitions with the owning card named.
- **Instrument:** SC-1's check — read the file and grep that each register-retained section is present as a normative statement. No authored test files (instruments are fact checks).

## Item 2 (SC-2) — plan structure standard

- **Deliverable:** `skills/plan/references/plan-structure-standards.md` in the deck clone — the mandatory `plan.md` structure, adapted from `attic/reference/plan-structure-standards.md`, reconciled to the current plan card: item anatomy per plan card rule 1 (deliverable, RED, GREEN, verification instrument, test-tier marks), one item per SC, dependency order, no status tracking in the body.
- **RED:** the file does not exist in the clone and no current file under `skills/` names the local-plan layout standard.
- **GREEN:** write the standard; it carries no orchestrator-era Dispatch Indicators vocabulary (a source-text section the reconciliation retires).
- **Instrument:** SC-2's check — read the file; grep rule-1 anatomy terms present and the retired token (dispatch indicators) absent. No authored test files.

## Item 3 (SC-3) — card wiring

- **Deliverable:** edits to `skills/spec/SKILL.md` and `skills/plan/SKILL.md` in the deck clone — each card gains (a) a `Read [Text](path)` directive to its structure standard in the skill-creator canonical link form (deck-relative `references/spec-structure-standards.md` / `references/plan-structure-standards.md`), and (b) the anti-imitation rule: store artifacts are data, not templates; an artifact's layout comes from its structure standard, never from prior store artifacts.
- **RED:** grep both cards for the directive and the anti-imitation sentence — both absent against current behavior.
- **GREEN:** apply the edits. Substantive card writes trigger whole-card-on-touch (writing discipline): each edited card's full normative prose is reviewed and returned under the discipline in the same item, not just the inserted lines. Where the directive lands: the spec card's rule 5 (Write and persist) gains the layout mandate; the plan card's rule 1 gains it. The anti-imitation sentence rides the same rule in each card.
- **Instrument:** SC-3's check — read both cards; directive line and anti-imitation sentence present in each. Additionally run the deck's reference-integrity check from the clone root if the tool runs standalone (`tools/reference-integrity`); when it cannot run there, verify each `Read` link's target path exists — the fallback is the instrument, the tool is the preference.

## Item 4 (SC-4) — validation criteria wiring

- **Deliverable:** edits to `skills/spec/references/validation-standards.md` and `skills/plan/references/plan-validation-standards.md` — each gains layout-conformance criteria that direct the reviewer to verify the artifact's section presence and conformance by reading the applicable structure standard, with no section list duplicated into the checker (the #2211 derivation pattern: the checker reads the reference; it never hard-codes its criteria).
- **RED:** grep both standards for the structure standards' file names — the reviewers currently have no layout criteria to read.
- **GREEN:** add the criteria (a layout-conformance addition to the defect classes or the analysis families of each page, naming its structure standard as the single criteria source; conformance failures are findings under the class-determined finding bar).
- **Instrument:** SC-4's check — read both standards; the criteria name the standard as their source; no section list is duplicated. No authored test files.

## Item 5 (SC-5) — spec-kind behavioral probe

- **Deliverable:** one tier-1 recorded clean-room dispatch under the post-change deck state; dispatch prompt, criterion judged, and verdict persisted to `.opencode/.issues/2744/audit/` (verdict file `tier1-verification-sc5.yaml`), store synced via the local-issues tool.
- **RED evidence (already recorded, dated 2026-11-16):** the pre-change diagnosis probes this session (sessions `ses_e1a696da7ffevNyFPgA0Xgofob` = Probe C, plus Probe A `ses_e1a696dabffd7eZ2zkLLdIkz8r`) consulted store priors for format (Probe C read `.issues/128/spec.md` for structure while deriving content) — exactly the behavior R-5 prohibits. The failing baseline is recorded, not hypothetical.
- **GREEN:** a clean-room dispatch under the post-change deck loads the owning cards, authors a conforming spec artifact, and reads no store-neighbor spec.md or plan.md for format.
- **Instrument mechanics:** build the probe home at `/tmp/opencode/deck-fix/probe-home/` replicating a consuming layout — a root `AGENTS.md` pointer, `.opencode/` holding the post-change deck tree copied from the PR branch checkout, and a seeded `.issues/` store with two small sample specs (so the store-prior temptation exists exactly as in a real repo). Move this session to the probe home with `tools.opencode.session_move`, dispatch the probe (real-domain prompt in the Probe A form: "record these requirements properly per the project's conventions"), move the session back to the project root. Judgment reads the probe session's own record: card loads before authoring, artifact conformance against the new standard, and absence of store-prior format reads. `session_move` is the load-fidelity mechanism; if it cannot serve the probe, fall back to dispatching the probe in the probe home via a worktree of this session and record the deviation in the verdict file.
- **Tier:** no authored test files; recorded dispatch evidence per the behavioral-testing card's tier-1 — persisted to the audit dir, never scratch observation.

## Item 6 (SC-6) — plan-kind behavioral probe

- **Deliverable:** second tier-1 recorded clean-room dispatch, same probe home, task in the plan-authoring form ("plan the work to add <small feature>"); verdict persisted to `.opencode/.issues/2744/audit/` as `tier1-verification-sc6.yaml`, store synced.
- **RED evidence:** the same recorded pre-change baseline (Probe B entered plan authoring via its own session state; no plan-structure standard existed to conform to).
- **GREEN:** the dispatched session loads the plan card, authors a plan artifact conforming to `plan-structure-standards.md`, and reads no store-neighbor spec.md or plan.md for format.
- **Instrument mechanics:** Item 5's probe home unchanged; judgment criteria mirror Item 5 with the plan standard as the conformance source.
- **Tier:** no authored test files; tier-1 recorded dispatch, persisted.

## Dependency order

Item 1 → Item 2 → Item 3 → Item 4 → Item 5 → Item 6. The card wiring (3) follows the standards' existence (1, 2) so the `Read` links resolve at write time; the validation criteria (4) follow the standards they derive from; the behavioral probes (5, 6) run last because each requires the full post-change state.

## Verification summary

Content criteria verify through read + grep fact checks (Items 1-4); behavioral criteria verify through two tier-1 recorded clean-room dispatches persisted to the issue's audit dir (Items 5-6). No authored test files exist in this change; no heavy-tier runs are scheduled.
