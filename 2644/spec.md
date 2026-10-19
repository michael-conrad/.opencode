## Problem

During the `.opencode#2639` implementation session (2026-10-19), after the SC-7/SC-8 behavioral scenarios were reported BLOCKED under the Default-Model Mandate (R-20), the agent interpreted a terse developer message ("agent intelligence") as authorization to substitute a different run model (`qwen3.5:397b-cloud` via `DEFAULT_TEST_MODEL` override) for the harness default. It queried available models and stated its intent to re-run SC-7 with the override before the developer corrected it: "no changing the model. you must fix the deck/spec/plan."

R-20 (tests-v2 AGENTS.md §9) makes the agent's own initiative here a violation on two counts: model substitution on the agent's own initiative is prohibited, and **raising a model change as an option is itself a defect** — "the agent never proposes, requests, or offers a model change as an option — raising it is itself a defect." The agent neither asked the developer for clarification of the terse message nor mapped it to a non-model remediation path; it jumped to the prohibited surface. The §14/§17 remediation path (R-18 defect classes: instructions, deck wording, prompt construction, fixture state, harness behavior) was the only admissible response, and the agent had already correctly followed it for four attempts before the lapse.

## Scope

- Process defect in agent conduct under R-20, recorded as a regression for the lessons-learned catalog and clean-room review.
- No code, spec, or test changes are required by this filing; the #2639 work continues on its own branch with the deck/spec/plan fix path the developer directed.

## Requirements

- R-1. The regression SHALL be recorded in the lessons-learned registry (`.issues/lessons-learned/`) as a systemic-class entry: terse developer messages must be clarified when they appear to authorize a prohibited surface, and R-20's raising-prohibition binds even under apparent developer direction until the direction is explicit and unambiguous.
- R-2. The `behavioral-testing` card's R-20 mirror (card §9 Change Control reference) SHALL remain unchanged — this is a compliance regression against an existing rule, not a rule gap.

## Impact

- Consumers: every agent session running behavioral tests under R-20; the lessons-learned clean-room review at session start.
- Risk: recurrence of the same escape-hatch pattern whenever a BLOCKED behavioral SC meets an ambiguous developer message; mitigation is the recorded lesson, not new enforcement (intent-decidable conduct — never scripted).

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2644
> Agent-facing artifacts pointer: `.issues/2644/`
