## Problem

During `.opencode#2646`'s SC-8 behavioral run (2026-10-20), the supervising agent's poll intervals drifted to ~143–146 seconds between consecutive polls — computed from recorded poll timestamps (1792501178 → 1792501321 → 1792501467) — against the 60-second ceiling of the Agent-Supervisor Mandate (behavioral-testing card; tests-v2 AGENTS.md §14 mirror). The drift came from `sleep 120` inside the poll tool calls plus per-call overhead: an escalation of the interval, exactly the #2619-class defect (interval is a ceiling, never escalates while the supervised operation is pending). Recurrence chain: #2557, #2561, #2570, #2594, #2619, now this.

The developer corrected mid-run ("regression, the agent is not following mandatory polling discipline") and directed an SC-level fix plus compliance going forward.

## Scope

- Process regression in agent supervision conduct, recorded for the lessons-learned catalog; an SC addition to the open `.opencode#2646` spec makes cadence compliance a verified deliverable of that spec's behavioral evidence (computed from recorded poll timestamps — fact-decidable on the record), so the class stops being unenforceable prose at the verification surface.

## Requirements

- R-1. The regression SHALL be recorded in the lessons-learned registry as a systemic-class entry (interval-escalation recurrence).
- R-2. The `.opencode#2646` spec SHALL carry an SC making supervised-run cadence compliance verifiable from recorded poll timestamps (60-second ceiling, computed never estimated).

## Impact

- Consumers: every session supervising a behavioral run; the #2646 verification evidence.
- Risk: low — verification-side addition, no new enforcement script (the check reads recorded timestamps).

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2647
> Agent-facing artifacts pointer: `.issues/2647/`
