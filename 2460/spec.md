> **Full spec and artifacts: [`.issues/2460/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2460/)** — authoritative spec, `issues-data` branch.
>
> **Remote issue:** https://github.com/michael-conrad/.opencode/issues/2460

# Spec: Rewrite playwright-cli description as agent-intent semantic router

## Intent and Executive Summary

**Problem Statement.** The `playwright-cli` skill description (SKILL.md frontmatter `description` field) uses the deprecated meta-instruction format — `Load via skill() when`, `Also load when`, and `User phrases:` — that [skill-card-description-standards.md](../../reference/skill-card-description-standards.md) prohibits and `validate_skill_cards.py` (REQ-1, SC-LINT-001) flags. Because the description is the sole Level-1 dispatch signal, the defect is behavioral: the description offers user-utterance phrases instead of stating the agent-intent capability class, so browser-appropriate capture intents (JavaScript-rendered pages, bot-blocked sites, login-gated pages) do not activate the skill.

**Root Cause / Motivation.** The description predates the enforced deck standard and was never migrated. The stale open ticket #1520 quotes pre-#1855 text and proposes a no-op, so it cannot fix the defect and is superseded by this spec. This is the scoped first entry of the deck-wide description-compliance wave tracked by umbrella #1384.

**Approach Chosen.** Replace the description with the approved 665-char agent-intent draft stating the escalation capability class (browser-grade rendering vs static HTTP fetching; JS-rendered, bot-blocked, login-gated, interactive verification flows), and extend the Browse-the-web workflow When clause with the same escalation intent family so body-level routing agrees with the description. Verify with a grep-based content test (SC-1..SC-4) and with behavioral probes + clean-room session.yaml evaluations (SC-5..SC-8) scoped to the dispatch decision.

**Alternatives Considered & Why Discarded.**

- **Fix all 50 non-compliant cards in one spec** — discarded: violates the approved scope ruling (developer directive recorded in the brainstorming handoff); deck-wide remediation remains the #1384 umbrella wave.
- **Patch #1520 instead of superseding it** — discarded: #1520 quotes pre-#1855 description text, so implementing its proposal is a no-op against the current defect.
- **Change `validate_skill_cards.py` to also ban `Also load when`** — discarded: validator changes are out of the blast radius per the approved design; SC-1's stricter rule is enforced by the new content test.

**Key Design Decisions.**

- **Description as classifier boundary:** the draft states the escalation capability class rather than trigger phrases — tradeoff: slightly longer description (~665 chars vs the old ~590) in exchange for intent-based activation on browser-appropriate tasks and no false activation on static fetches (enforced by SC-7/SC-8).
- **When-clause extension without dispatch-contract change:** the Browse-the-web When clause gains escalation-family coverage while the `task()` prompt strings stay byte-identical — tradeoff: body text and description must be kept consistent manually (SC-4 asserts it).
- **Behavioral scope = dispatch decision, not execution:** execution binaries (`playwright-cli`, `npx`) are absent in this environment, so behavioral evidence covers the skill-load event, not end-to-end page capture — tradeoff: weaker end-to-end guarantee now, in exchange for a testable dispatch gate; binary provisioning is a recorded non-goal and future spec.
- **Negative control as a full SC:** no optional SCs — the false-activation boundary is a first-class success criterion (developer ruling).
- **Two-SC pattern for behavioral tests:** artifact generation (probe runs) strictly separated from clean-room evaluation; evaluations read exported session.yaml only — never stdout/stderr prose.

**User Intent / Original Prompt.** Developer directive: rewrite the playwright-cli description as an agent-intent semantic router per the approved brainstorming design (handoff: `tmp/2460/artifacts/preliminary/handoff.yaml`), with behavioral verification of the dispatch decision, negative control included as a full SC, and early test-session termination permitted once evidence of correct operation is confirmed in the live session DB (directive dated 2026-09-23).

## Not Included

- **Deck-wide description compliance (other non-compliant cards)** — umbrella #1384 wave; this spec resolves only the playwright-cli entry per the developer scope ruling.
- **Escalation wiring in research/verification/audit/mcp-tool-usage pipelines** — those pipelines referencing the browser tier is a separate integration concern, descoped.
- **Environment provisioning of the playwright-cli binary / node toolchain** — behavioral SCs are scoped to the dispatch decision; binary provisioning is a future spec.
- **#1959 task-card reconciliation with upstream** — adjacent ticket, explicitly not superseded, state unchanged.
- **`validate_skill_cards.py` changes** — the existing validator already prohibits the removed patterns; no validator edit is in the blast radius.
- **Guidelines/reference-document changes** — [skill-card-description-standards.md](../../reference/skill-card-description-standards.md) and [skill-card-schema.md](../../reference/skill-card-schema.md) already codify the target format.

## Success Criteria

(placeholder)

## Requirements

(placeholder)

## Items

(placeholder)

## Dependencies

(placeholder)

## Traceability

(placeholder)

## Documentation Sources

(placeholder)

## Enforcement Gate

(placeholder)

## Cost Frame

(placeholder)

## Edge Cases

(placeholder)
