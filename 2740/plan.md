# Plan — .opencode#2740 (floor: closed-set token precedence + N/A-surface disposition)

**Spec:** `.opencode/.issues/2740/spec.md` (validated PASS, zero findings).
**Target:** `floor.md` authorization-vocabulary area — the terse-message clause (lines ~80–84) and the closed-token-set / standing-formula block — deck repository.

## Item 1 — State closed-set token precedence and the N/A-surface disposition (SC-1, SC-3 scope guard)

- **Deliverable:** (a) In the terse-message clause: a recognized closed-vocabulary token proceeds — the clarification clause applies only to utterances whose token status is genuinely undecided; it never defeats a token that matches the vocabulary. (b) A new N/A-surface disposition adjacent to the standing formula: when a terminal-phase token's named phase has no surface for the deliverable (e.g. an `approved for pr` over a wiki-only, direct-publish deliverable), the agent runs any missing upstream stages, delivers through the surface the work actually has per the owning card, and records the N/A disposition in the completion report — this is a stage-mismatch disposition, not the unsure branch, not a clarification halt. (c) The halting surface narrows to token-undecided / target-set-unfixed. Floor provenance comment records `.opencode#2740`.
- **RED:** Grep for token-precedence / N/A-surface disposition wording — absent; the terse-message clause (lines 80–84) currently reconciles against any terse message with no token-recognition carve-out.
- **GREEN:** Edit the terse-message clause block and add the N/A-surface disposition at the standing-formula / closed-token-set area.
- **Instrument:** `grep` the vocabulary area for the token-precedence sentence and the N/A-surface disposition + report-recording (SC-1); `git diff` on `floor.md` touches only those blocks + provenance (SC-3).
- **Tier:** no authored test file.

## Item 2 — Verification of the operative routing (SC-2)

- **Deliverable:** Recorded clean-room verification that the revised floor text routes an `approved for pr` session over a wiki-only deliverable through the missing upstream stages and the owning card's publish path, recording the disposition — never a halt.
- **Instrument:** tier-1 clean-room dispatch (behavioral-testing card, instruction-surface change class) — fresh-context sub-agent judges the floor text's operative routing; verdict persisted to `.opencode/.issues/2740/audit/`.
- **RED:** Current text leaves a recognized token with no N/A-surface route, with the terse-message clause and unsure branch reachable against it (observed failure — three corrections needed).
- **GREEN:** Revised text's precedence + disposition close those routes for recognized tokens.
- **Tier:** tier-1 clean-room dispatch; verdict record persisted.

## Dependencies

Item 2 depends on Item 1. The #2741-delivered git-workflow-pr rule-1 text is composed with, not restated — check only that the floor edit does not contradict it (structural review at Item 1's close).

## Traceability

| Item | SC |
|------|-----|
| 1 | SC-1, SC-3 |
| 2 | SC-2 |

## Documentation Sources

- `floor.md` (authorization vocabulary, terse-message clause)
- `.opencode/.issues/2740/spec.md` (criteria source)
- `skills/git-workflow-pr/SKILL.md` rule 1 (#2741 text — composition-only reference)

## Enforcement Gate

The human merge boundary, PR-completion gates, and the genuinely-unfixed-set halt are out of scope and stand unchanged.

## Cost Frame

One file edited (two blocks + provenance line); one tier-1 dispatch.

## Not Included

Target-entity scoping (`#2739`'s spec); wiki-operations mechanics; deck-governance process.
