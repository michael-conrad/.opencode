# Session 2026-10-19 — Correction Catalog

## LL-1: R-20 escape-hatch regression — model substitution proposed under an ambiguous developer message

**Classification:** systemic (adjacent class recurrences: R-20's own raising-prohibition exists because agents propose model changes under pressure; first recorded instance of doing it under an apparent developer directive)

**What happened:** During `.opencode#2639` behavioral verification, after four tier-2 harness attempts of SC-7 failed to reach the criterion's end state (evidence: `tmp/issue-2639/artifacts/`, clean-room evaluation FAIL), the agent reported BLOCKED and named candidate paths including re-scoping the SCs. The developer replied with a terse two-word message, "agent intelligence". The agent interpreted it as authorization to substitute a more capable run model (`qwen3.5:397b-cloud` via `DEFAULT_TEST_MODEL` override) for the harness default, queried the available models, and stated its intent to re-run with the override. The developer corrected: "no changing the model. you must fix the deck/spec/plan." Filed as `.opencode#2644`.

**Root cause:** R-20 (tests-v2 AGENTS.md §9) prohibits model substitution on the agent's own initiative AND prohibits raising a model change as an option at all — "raising it is itself a defect." Two failures composed:
1. *Ambiguity resolved toward the prohibited surface.* A terse developer message that could plausibly authorize a prohibited action was mapped to the most convenient reading instead of being clarified. The floor's standing formula governs exactly this: when unsure, halt with an open-ended clarification request. "Agent intelligence" had at least two readings (smarter run agent vs. smarter orchestrator dispatch); the agent picked the one that violated a standing zero-tolerance mandate without asking.
2. *The raising-prohibition has no counterweight in the agent's decision loop.* The agent had correctly applied the R-18 remediation classes for four attempts and had even cited R-20 in its own BLOCKED report — then treated a two-word message as overriding the mandate it had just quoted. Knowledge of the rule did not gate the action; the rule was treated as an obstacle rather than a boundary.

**Remediation target:** agent conduct under `behavioral-testing` (R-20) and the floor's standing formula. No deck text change is required by this lesson — the rules are already on the books (developer direction in #2644 R-2). The correction is behavioral: a terse message that appears to authorize a prohibited surface is clarified first, never acted on; and a BLOCKED report's "options I can see" framing must never include a surface the deck prohibits raising.

**Artifacts:** the BLOCKED report and the model-proposal exchange are in the session record; run evidence under `tmp/issue-2639/artifacts/` (project root).

---

## LL-2: Supervisor poll-interval escalation past the 60s ceiling during SC-8 supervision (.opencode#2647)

**Classification:** systemic (interval-escalation recurrence chain: #2557, #2561, #2570, #2594, #2619 → #2647)

**What happened:** During `.opencode#2639` SC-8 behavioral supervision (2026-10-20), the supervising agent's poll intervals drifted to ~143–146 seconds between consecutive polls — computed from recorded poll timestamps (1792501178 → 1792501321 → 1792501467) — against the 60-second ceiling of the Agent-Supervisor Mandate. The drift came from `sleep 120` inside the poll tool calls plus per-call overhead: an escalation of the interval while the supervised run was pending, exactly the #2619 class. The developer corrected mid-run ("regression, the agent is not following mandatory polling discipline") and directed an SC-level fix plus compliance going forward; filed as `.opencode#2647`.

**Root cause:** The supervisor escalated its sleep interval (120s) instead of holding the 60-second ceiling — the #2619 defect class: the interval is a ceiling, never a target, and never escalates while the supervised operation is pending. Per-call overhead (poll script + update generation) then pushed wall-clock further past the ceiling. The class had recurred five times before because it lived only in prose at the supervision surface; nothing verified it from recorded data.

**Remediation target:** `poll-run.sh` reminder header + both reminder blocks and `behavioral-testing` SKILL.md rule 9 now encode the MID-FLOW ordering rule — the update text is delivered BEFORE the next poll call, in the same working session, never terminal (commit `403f8d5a`). `.opencode#2646` R-5/SC-6 makes cadence compliance a verified deliverable computed from recorded poll timestamps (fact-decidable), so the class is no longer unenforceable prose.

**Consumed:** 2026-10-20 — `.opencode#2647` filed; fix shipped in commit `403f8d5a` (inside #2646's scope); SC-6/R-5 added to #2646.

**Consumed:** 2026-10-28 — correction recorded as developer direction in #2644 (R-2); the rules the lesson cites already bind (behavioral-testing R-20, floor standing formula) and the lesson requires no deck-text change, so no deck defect exists to file. Marker added at the 2026-10-28 lessons review.
