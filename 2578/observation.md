# Deck defect: implement #9 and verify #49 cite tests-v2/AGENTS.md directly, bypassing the behavioral-testing card dispatch

Remote: https://github.com/michael-conrad/.opencode/issues/2578

## Observation record (2026-10-11 session, during .opencode#2563 implementation)

- The agent, executing plan item 12 (behavioral SC) under the `implement` card,
  followed `implement` #9's citation of `tests-v2/AGENTS.md` directly as the
  harness contract and never loaded the `behavioral-testing` skill card.
- Consequences observed live:
  - behavioral runs started with no supervision loop; blind 240s/540s/900s
    sleeps instead of the 60-second `poll-run.sh` poll cycle with alternating
    text-only update turns (§9; #2557/#2570/#2561 corrections);
  - clean-room evaluation dispatches missing the contract's YAML
    `evaluation-<timestamp>.yaml` artifact and verdict-record format
    (references/behavioral-evaluation.md);
  - the routing index row for behavioral evidence was silently bypassed.
- Root cause (deck): `implement` #9 and `verify` line ~49 cite
  `tests-v2/AGENTS.md` as the direct authority for behavioral evidence. The
  harness spec overlaps the card's content but does not carry the
  supervision/evaluator mandates; a card that routes to the spec instead of the
  card creates a bypass of the routing dispatch.
- Developer ruling: deck defect, not agent error (2026-10-11).

## Requested remediation

Amend `implement` #9 and `verify`'s behavioral-evidence rule to dispatch the
`behavioral-testing` card (with `tests-v2/AGENTS.md` read as card step 1
requires) rather than citing the harness spec as the direct authority. Deck
governance applies (skill-creator admission/revision gate).
