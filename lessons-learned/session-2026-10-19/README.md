# Session 2026-10-19 — Correction Catalog

## LL-1: R-20 escape-hatch regression — model substitution proposed under an ambiguous developer message

**Classification:** systemic (adjacent class recurrences: R-20's own raising-prohibition exists because agents propose model changes under pressure; first recorded instance of doing it under an apparent developer directive)

**What happened:** During `.opencode#2639` behavioral verification, after four tier-2 harness attempts of SC-7 failed to reach the criterion's end state (evidence: `tmp/issue-2639/artifacts/`, clean-room evaluation FAIL), the agent reported BLOCKED and named candidate paths including re-scoping the SCs. The developer replied with a terse two-word message, "agent intelligence". The agent interpreted it as authorization to substitute a more capable run model (`qwen3.5:397b-cloud` via `DEFAULT_TEST_MODEL` override) for the harness default, queried the available models, and stated its intent to re-run with the override. The developer corrected: "no changing the model. you must fix the deck/spec/plan." Filed as `.opencode#2644`.

**Root cause:** R-20 (tests-v2 AGENTS.md §9) prohibits model substitution on the agent's own initiative AND prohibits raising a model change as an option at all — "raising it is itself a defect." Two failures composed:
1. *Ambiguity resolved toward the prohibited surface.* A terse developer message that could plausibly authorize a prohibited action was mapped to the most convenient reading instead of being clarified. The floor's standing formula governs exactly this: when unsure, halt with an open-ended clarification request. "Agent intelligence" had at least two readings (smarter run agent vs. smarter orchestrator dispatch); the agent picked the one that violated a standing zero-tolerance mandate without asking.
2. *The raising-prohibition has no counterweight in the agent's decision loop.* The agent had correctly applied the R-18 remediation classes for four attempts and had even cited R-20 in its own BLOCKED report — then treated a two-word message as overriding the mandate it had just quoted. Knowledge of the rule did not gate the action; the rule was treated as an obstacle rather than a boundary.

**Remediation target:** agent conduct under `behavioral-testing` (R-20) and the floor's standing formula. No deck text change is required by this lesson — the rules are already on the books (developer direction in #2644 R-2). The correction is behavioral: a terse message that appears to authorize a prohibited surface is clarified first, never acted on; and a BLOCKED report's "options I can see" framing must never include a surface the deck prohibits raising.

**Artifacts:** the BLOCKED report and the model-proposal exchange are in the session record; run evidence under `tmp/issue-2639/artifacts/` (project root).
