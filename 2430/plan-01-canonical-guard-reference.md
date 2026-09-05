# Phase 1 — Canonical guard reference doc + guideline cross-link

**Concern:** Define the mechanical Pre-Flight Guard exactly once as a single reference definition under `.opencode/guidelines/` with an `INDEX.md` cross-link (R-2 infrastructure). No SC completes in this phase — it is the preparatory single-source-of-truth phase. Every later phase consumes the canonical text: the phase-2 lint pattern, the phase-3 card sweep, the phase-4 template emission, and the phase-5 behavioral assertions and audit finding class all derive from it.

**Files:**

- `.opencode/guidelines/` (new canonical guard reference document)
- `.opencode/guidelines/INDEX.md`

**SCs:** None (preparatory — R-2 infrastructure)

**Dependencies:** None

**Entry Conditions:**

- Pre-implementation steps 1–4 complete (coherence gate PASS, baseline check PASS, pre-regression PASS, pre-regression verify PASS)
- Feature branch checked out in the `.opencode` submodule

**Exit Conditions:**

- The canonical guard reference document exists under `.opencode/guidelines/` carrying the guard block verbatim from the spec Approach Chosen: task-tool probe as sole discriminator, two reason codes (`ORCHESTRATOR_ONLY_SKILL_CARD` for cards, `ORCHESTRATOR_ONLY_PLAN` for plans), and the action-not-perception semantic note
- `INDEX.md` carries the cross-link registration
- The item's commit is landed

**Code Path Coverage:**

- `.opencode/guidelines/` (new file: canonical-guard reference) — create the canonical guard reference document (guard text from the spec Intent preamble: task-tool present/absent check, `ORCHESTRATOR_ONLY_SKILL_CARD` + `ORCHESTRATOR_ONLY_PLAN` reason codes, action-not-perception semantic note) and register a cross-link in `INDEX.md`
- Consumers of this change: all 51 SKILL.md cards (phase 3 embeds the guard verbatim), the writing-plans plan template (phase 4 embeds the guard with `ORCHESTRATOR_ONLY_PLAN`), and deck lint + skill-creator validation + audit plan-fidelity (phase 2 verifies against the canonical text)

**Cross-Cutting SCs:**

- Single canonical definition (no variant drift) — the guard text is defined exactly once here; any wording divergence between this reference doc and embedded copies is a defect lint must catch (high impact — variant drift recreates the prose-guard problem with a mechanical-sounding imposter)
- Two artifact classes, two reason codes — this document is the single source of truth for both `ORCHESTRATOR_ONLY_SKILL_CARD` and `ORCHESTRATOR_ONLY_PLAN`

**Interface Boundaries:**

- New content interface: the canonical guard block text. Every downstream consumer (lint pattern, card sweep, plan template, audit finding class, behavioral assertions) reads the guard text from this document — the rule pattern is derived from the canonical guard text exactly (SC-1 verbatim semantics)

**State Transitions:**

- Before: no canonical mechanical guard definition exists anywhere; consumers would each invent wording
- After: exactly one canonical definition exists; all guard consumers reference it
- Failure mode to foreclose: a consumer keys on the `skill` tool (present in sub-agent context) instead of `task` absence — the canonical text must name `task` as the sole discriminator (probe `ses_f9ac0f59bffetMsE6s3sQOHoQ8`)

**Cost frame:** Writing and cross-linking the canonical reference doc costs minutes — a bounded authoring step that gives every later phase its verbatim source. Skipping costs the whole rollout — phases 2–5 would each derive guard wording independently, and the first wording drift between any two consumers recreates the prose-guard problem with a mechanical-sounding imposter, discovered only when lint and embedded copies disagree in CI.

---

## Step-by-step

- [ ] 5. **RED (**task-card**).** Write a failing enforcement test for the canonical guard reference document. **→ item-0 (preparatory, R-2)**
  - RED describes what fails: no reference document under `.opencode/guidelines/` carries the canonical mechanical guard block (task-tool probe heading, present/absent branches, both reason codes, action-not-perception semantic note), and `INDEX.md` carries no cross-link to it.
  - RED must fail before GREEN begins.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-red-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`.

- [ ] 6. **GREEN (**task-card**).** Create the canonical guard reference document and the `INDEX.md` cross-link. **→ item-0 (preparatory, R-2)**
  - GREEN describes what must be true: the reference document exists under `.opencode/guidelines/` with the guard block verbatim from the spec Approach Chosen (task-tool probe, two reason codes, semantic note), and `INDEX.md` registers the cross-link. No scope creep — only the minimum change needed.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-green-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`.

- [ ] 7. **Verify (**task-card**).** Verify implementation against the success criteria for the preparatory item. **→ item-0 (preparatory, R-2)**
  - Verify the document text matches the spec's canonical guard block verbatim and the `INDEX.md` cross-link resolves to the new document.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-verify-*` before dispatch.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`.

- [ ] 8. **Commit (**direct**).** Stage and commit changes — orchestrator runs `git add <files> && git commit -m "<message>"` directly, no sub-agent dispatch. **→ item-0 (preparatory, R-2)**
  - The test and its implementation are committed as one atomic slice.
  - No co-author trailers during implementation commits — those are added during squash at PR time.

#### Phase 1 Completion Block

- [ ] 9. **VbC (**task-card**).** Verification-before-completion assertions for phase 1. **→ item-0 (preparatory, R-2)**
  - Canonical guard reference document exists under `.opencode/guidelines/` with the guard block verbatim from the spec.
  - `INDEX.md` cross-link resolves to the new document.
  - All exit conditions hold before phase 2 begins.

**Concern transition:** Leaving guard-definition infrastructure → entering guard-verification tooling. Phase 2 depends on phase 1's canonical text — the lint rule's verbatim pattern is derived from the canonical guard text and cannot check conformance before the reference doc exists.