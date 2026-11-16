# Plan — .opencode#2739 (floor: zero-repo target-set floor + act-and-record disposition)

**Spec:** `.opencode/.issues/2739/spec.md` (validated PASS, zero findings).
**Target:** `floor.md` target-entity-scoping paragraph (lines ~129–143) — deck repository.

## Item 1 — Restate the target-entity-scoping clause with the zero-repo floor and act+record disposition (SC-1, SC-3 scope guard)

- **Deliverable:** The clause states (a) a zero-repo target set cannot arise — the session's root repo is always fixed by session context; (b) when an ambiguous scope word arrives and session-init data enumerates one or more repositories, the agent acts on the enumerated members and records residual ambiguity about non-enumerated candidates (e.g. a nested deck checkout with its own `.git`) in its report, instead of halting pre-action while a fixed member is unprocessed; (c) the halt for a genuinely unfixed set (no enumeration, no target-binding token) stands verbatim in meaning. Floor provenance comment records `.opencode#2739`.
- **RED:** Grep the clause for zero-repo-floor / act-and-record framing — absent (line 135–140 carries only the halt-when-unfixed wording with no always-a-fixed-member statement).
- **GREEN:** Edit the ambiguous-scope-word sentence block per (a)–(c).
- **Instrument:** `grep` the clause for the zero-repo-floor sentence and the record-residue disposition (SC-1); `git diff` on `floor.md` touches only that block + provenance (SC-3).
- **Tier:** no authored test file — verification is structural instrument output recorded in the PR's Evidence section.

## Item 2 — Verification of the operative routing (SC-2)

- **Deliverable:** Recorded clean-room verification that the revised clause routes an ambiguous-scope-word request where session-init enumerates the root repo to acting on that member and recording residual ambiguity — not halting pre-action.
- **Instrument:** tier-1 clean-room dispatch per the behavioral-testing card's tier class for instruction-surface (floor) changes — fresh-context sub-agent judges the clause's operative routing; verdict persisted to `.opencode/.issues/2739/audit/`.
- **RED:** Current clause text reads an enumerated-but-submodule-less session as genuinely unfixed (observed failure).
- **GREEN:** Revised clause's always-a-fixed-member statement closes that reading.
- **Tier:** tier-1 clean-room dispatch; verdict record persisted (not an authored test file).

## Dependencies

Item 2 depends on Item 1. SC-3's instrument executes at Item 1's close and re-runs at PR-prep time on the final diff.

## Traceability

| Item | SC |
|------|-----|
| 1 | SC-1, SC-3 |
| 2 | SC-2 |

## Documentation Sources

- `floor.md` (target clause)
- `.opencode/.issues/2739/spec.md` (criteria source)

## Enforcement Gate

The clause's proceed-or-halt decision governs before any card dispatch; the genuinely-unfixed halt and the abort-reconstruction duty are out of scope (unchanged).

## Cost Frame

One file edited (scoping paragraph + provenance line); one tier-1 dispatch.

## Not Included

Authorization-vocabulary token semantics (`#2740`'s spec); session-init mechanics; deck-governance process.
