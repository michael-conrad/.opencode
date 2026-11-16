# Spec: .opencode#2744 — Land mandatory local spec/plan structure standards (post-rip layout mandate)

## 1. Intent and Executive Summary

- **Problem Statement.** Since the deck rewrite (#2490), no current-generation artifact owns the section layout of local `spec.md` or `plan.md` artifacts. Authoring sessions acquire structure from store neighbors by imitation; the developer reported this as the recurring regression — the deck is supposed to carry the mandatory spec layout requirements, and agents ignore them because, on the current deck, there is nothing to reference. As of 2026-11-16 the vacuum is verified: `skills/spec/references/` holds only the remote-body format and the content validation standards; no current artifact names the local layout.
- **Root Cause / Motivation.** The pre-rip deck single-sourced the layout in `reference/spec-structure-standards.md` and `reference/plan-structure-standards.md`, with producers and auditors reading them via `Read [Text](path)` directives (#2211 wired the auditors to derive their structural criteria from the references instead of hard-coding them). The rewrite retired those references without re-landing a successor. The retired form survives through store imitation: the 6-field preamble skeleton recurs across 34 parent-store specs with no deck owner, and an authoring session consulting a store prior for format inherits whatever era conventions that neighbor carries (observed specimen: parent-store #2431 citing pre-rip card vocabulary).
- **Approach Chosen.** Re-land both standards as current-generation references — `skills/spec/references/spec-structure-standards.md` and `skills/plan/references/plan-structure-standards.md` — adapted from the attic texts and rewritten as needed to match the current deck (developer directive, 2026-11-16: "adapt as needed to match the new deck. wholesale rewrite is fine."). The spec and plan cards gain `Read` directives plus the anti-imitation rule; both validation standards gain layout-conformance criteria derived from the standards; verification runs through tier-1 clean-room dispatches.
- **Alternatives Considered & Why Discarded.** (a) Fold a mandatory-section list into the validation standards — rejected: it merges the producer standard and the validator criteria into one file, undoing the single-source separation #2211 established. (b) Restore the attic texts verbatim — rejected: the old texts carry retired doctrine (spec-embedded Items; Phases-era traceability; orchestrator dispatch vocabulary) that conflicts with the current cards. (c) Rely on store convention — rejected by the observed failure: the store template lost its mandate with the standard that mandated it, which is exactly the cargo-culting under remediation. (d) Also repair the spec/plan card description triggers — dropped for this spec: three clean-room dispatch probes on 2026-11-16 showed the current router firing correctly on the probed entry intents (ticket-path, post-design proceed, pre-spec plan); no current observed failure remains.
- **Key Design Decisions.** (1) The producer standard and the validator criteria stay separate single sources: the structure references are owned by the cards; the reviewer reads the standard when verifying conformance. (2) Layout authority is adaptation to current doctrine, not historical verbatim. (3) The behavioral instrument is the tier-1 recorded clean-room dispatch (developer-directed, 2026-11-16: "you can test with sub-agent prompts"), with the verdict persisted per the behavioral-testing card. (4) Section vocabulary reconciles with the current remote-body-format reference where the sections overlap.
- **User Intent / Original Prompt.** Developer statements this session, 2026-11-16 (verbatim): "regression: the agent has taken to using cargo-culting and not the deck mandates when creating specs and plans. brainstorm a fix spec." · "analyze holistically. any time a spec is needed the agent goes duplicating previous specs and never references the correct workflow skill cards." · "the deck is supposed to have the mandatory spec layout requirements which are being ignored when the agent does the format imitation which is cargo culting" · "you can test with sub-agent prompts" · "adapt the attic text. file fix spec. implement fix spec. file PR." · "adapt as needed to match the new deck. wholesale rewrite is fine."

## 2. Not Included

- **Spec/plan card description-trigger repair** — the 2026-11-16 probes showed the router firing on the three probed entry intents; no current observed failure. Re-open if a future incident shows undertrigger.
- **task-card-structure-standards, skill-card-description-standards, cost-model-standards re-landing** — the stated regression covers spec and plan authoring only; other retired standards layers need their own observed failure.
- **remote-body-format changes** — a current-generation artifact that owns the remote summary's sections only; untouched.
- **Attic deletion timing** — the adapted standards snapshot the inventory they draw on; whether attic retires is a separate governance decision.

## 3. Requirements

R-1. The deck repository (michael-conrad/.opencode) SHALL own `skills/spec/references/spec-structure-standards.md` defining the mandatory section inventory of a local `spec.md` artifact, adapted from `attic/reference/spec-structure-standards.md` and reconciled to current-generation doctrine.

R-2. The deck repository SHALL own `skills/plan/references/plan-structure-standards.md` defining the mandatory structure of a local `plan.md` artifact, adapted from `attic/reference/plan-structure-standards.md` and reconciled to current-generation doctrine — item anatomy per the plan card rule 1 (deliverable, RED, GREEN, verification instrument, test-tier marks), no orchestrator-era dispatch vocabulary.

R-3. The spec card and the plan card SHALL each carry a `Read [Text](path)` directive to their structure standard, and SHALL state the anti-imitation rule: store artifacts are data, not templates; an artifact's layout comes from its structure standard, never from prior store artifacts.

R-4. The spec card's validation-standards reference and the plan card's validation-standards reference SHALL carry layout-conformance criteria that derive from the respective structure standard — the reviewer reads the standard and verifies conformance; the checker holds no hard-coded section list.

R-5. A clean-room session under the post-change deck, dispatched to author a spec or a plan, SHALL load the owning cards, produce the artifact conforming to the applicable structure standard, and consult no store artifact for format.

### Reconciliation register

The adaptation encodes these section-by-section rulings:

- **Retained from the attic inventory**, each purpose-anchored to a current validation family: the 6-field intent preamble (Problem Statement; Root Cause / Motivation; Approach Chosen; Alternatives Considered & Why Discarded; Key Design Decisions; User Intent / Original Prompt) — anchors validation class 1 (provenance) and the traceability, causal-sufficiency, problem-fit, and research-adequacy families; **Not Included** (exclusions, each with rationale); **Requirements** (R-x, RFC 2119 SHALL); **SC table** — columns ID / Criterion / Class / Instrument, the class vocabulary per the current spec card rule 4 (behavioral | structural); **Dependencies** (reference / relationship / status); **Traceability** (Requirement → SCs); **Documentation Sources** (source / type / location / verification — anchors the fabricated-claims family); **Cost Frame**; **Edge Cases** (gap-analysis family).
- **Dropped**: spec-embedded Items (the current plan card owns item anatomy; the spec carries SCs, the plan carries items); the Phases column in traceability (phase-era vocabulary); the attic four-way evidence-type taxonomy (superseded by the current two-class rule); the orchestrator Dispatch Indicators and Z3-contract vocabulary (retired machinery).
- **Enforcement Gate**: retained as a completion-gate statement — all SCs pass before the deliverable is complete — phrased as spec content, not a tracking indicator; the issue's validation record stays the loop history's owner.

## 4. Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | `skills/spec/references/spec-structure-standards.md` exists and states the mandatory `spec.md` section inventory per the reconciliation register | structural | read + grep the standard: each register-retained section present as a normative statement |
| SC-2 | `skills/plan/references/plan-structure-standards.md` exists; the `plan.md` structure carries item anatomy matching plan card rule 1; orchestrator-era dispatch vocabulary absent | structural | read + grep: rule-1 anatomy terms present; retired tokens (dispatch indicators, Z3 contract) absent |
| SC-3 | The spec card carries a `Read` directive to its structure standard plus the anti-imitation rule; the plan card carries the same | structural | read both SKILL.md files: directive line and anti-imitation sentence present in each |
| SC-4 | Both validation standards carry layout-conformance criteria that derive from their structure standards | structural | read both standards: the criteria name the standard as their source; no section list duplicated into the checker |
| SC-5 | A clean-room dispatched session loads the owning cards, authors an artifact conforming to the standard, and consults no store artifact for format | behavioral | tier-1 recorded clean-room dispatch; prompt, criterion, and verdict persisted to `.issues/2744/audit/` |

## 5. Traceability

| Requirement | SC(s) |
|-------------|-------|
| R-1 | SC-1 |
| R-2 | SC-2 |
| R-3 | SC-3 |
| R-4 | SC-4 |
| R-5 | SC-5 |

Every stated root cause is covered: the missing standard is landed by R-1/R-2, wired and enforced by R-3/R-4, and the authoring behavior is verified by R-5.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| attic/reference/spec-structure-standards.md | source text for R-1; must exist at adaptation time | satisfied as of 2026-11-16 (attic is pending deletion; the adapted standard is the snapshot) |
| attic/reference/plan-structure-standards.md | source text for R-2 | satisfied as of 2026-11-16 |
| skills/spec/SKILL.md, skills/plan/SKILL.md, both validation standards, remote-body-format | the current-generation surface the adaptation reconciles against | read this session, 2026-11-16 |
| skill-creator card | edit governance; the developer-directed carve-out applies (directive chain this session) | present |
| behavioral-testing card, tier-1 | instrument contract for SC-5 | present |

## 7. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Attic spec-structure-standards | reference | attic/reference/spec-structure-standards.md | read this session, 2026-11-16 |
| Attic plan-structure-standards (as cited by auditor task files and #2211 plan) | reference | attic/reference/plan-structure-standards.md | grep-located this session, 2026-11-16; full read at adaptation time |
| Current deck cards | config | skills/spec/SKILL.md, skills/plan/SKILL.md, spec/references/validation-standards.md, plan/references/plan-validation-standards.md, spec/references/remote-body-format.md | read this session, 2026-11-16 |
| Layout-imitation evidence | evidence | probe dispatches this session (three clean-room sessions, 2026-11-16); store sweep (validation-record counts; 34-spec skeleton finding) | executed this session, 2026-11-16 |

## 8. Impact

- Consumers: all agents authoring local specs and plans under this deck; the spec/plan validation dispatches (new criteria); the reference-integrity check (new `Read` links must resolve).
- Risk: low — additive deck content with card wiring; no code, no build, no store-schema change, no consuming-checkout change; the parent repository's submodule pointer is untouched (deck edits land via a clean clone and a deck-repo PR).
- Blast radius: michael-conrad/.opencode only, files under `skills/spec/` and `skills/plan/`.

## 9. Completion gate

All success criteria SHALL pass before this deliverable is complete; partial implementation is not permitted. The validation record at `.issues/2744/audit/validation.yaml` carries the loop history.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
