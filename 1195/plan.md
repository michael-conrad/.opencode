# Plan — .opencode#1195: no-solicitation rule in floor.md

Source: `.opencode/.issues/1195/spec.md` (validated 2026-10-09, PASS). One item per SC; all three SCs are structural (`string` evidence — file facts), so every cycle is a text change verified by a runnable check, not a model run.

## Item 1 — SC-1: no-solicitation rule present in floor.md

- **Deliverable:** an explicit rule in `floor.md`'s authorization-vocabulary section stating that after authorized work completes, the agent reports and waits, and never solicits work, phases, steps, or assignments.
- **RED:** `rg -n "solicit" floor.md` in the `.opencode` repo returns only the unsolicited-decisions line (line ~56) — no rule stating that the agent never solicits the next assignment after reporting.
- **GREEN:** add the rule adjacent to the standing formula, per the spec's constraint text ("After completing authorized work: act within scope, report what was done, and wait. Never solicit the next assignment — …"). Final wording is an implementation decision within the spec's constraint; it must state the prohibition with examples and the unsure/done composition.
- **Verify:** `rg -n "Never solicit" floor.md` returns the new rule; content matches the spec's constraint scope (no work-, phase-, or step-seeking).

## Item 2 — SC-2: placement and composition with the standing formula

- **Deliverable:** the rule sits adjacent to the standing formula in the authorization-vocabulary section and composes with it — unsure → open-ended clarification request; done → report and wait without soliciting.
- **RED:** the standing formula's unsure branch exists ("when unsure, halt with an open-ended clarification request — never a constrained-choice prompt") with no done-branch complement nearby.
- **GREEN:** placement in the same section, immediately after (or adjacent to) the standing formula; wording references the unsure/done split without duplicating the formula verbatim.
- **Verify:** read the section — the new rule is within the same block as the standing formula; both branches of the composition are present and non-contradictory.

## Item 3 — SC-3: deck consistency (no restatement, no contradiction)

- **Deliverable:** confirmation that no other deck file restates or contradicts the rule; existing citations remain consistent.
- **RED/GREEN:** no change expected — this is a consistency gate over the whole deck after Item 1. If any card contradicts, the contradiction is a finding to report, not an edit beyond the spec's non-goals (explore/discuss/research cards are off-limits per the spec).
- **Verify:** `rg -ni "solicit|what would you like|should i proceed|ready for the next" skills/ routing.md AGENTS.md` — matches must be consistent with the rule (the floor's own lines, explore's pointer to the floor ruling); zero contradictions.

## Dependency order

Item 1 → Item 2 (placement decided with the edit) → Item 3 (sweep over the edited deck).

## Process notes

- Deck edit: `skill-creator` admission gate — the spec carries the trace; the implementation records the admission decision in the deck-debt issue.
- Branch work per `git-workflow-branch`; commits per `git-workflow-commit`; PR per `git-workflow-pr`.
