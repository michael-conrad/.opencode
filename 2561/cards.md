# Card Catalogue — .opencode#2561

| Card | Decision | Rationale |
|---|---|---|
| `issues/SKILL.md` §5 Closure | Amended | Verified-resolved/moot verdict added as closure trigger; closure includes remote-mirror reconciliation in the same workflow; tidy-up prohibition retained. |
| `issues/references/sync-mirroring.md` | Amended | New "Remote-state reconciliation" section: local store authoritative; verdict-backed local-closed/remote-open drift reconciles on the closure workflow without re-authorization; unexplained flips are drift to investigate. |
| `verify` card | Excluded | The closure trigger and disposition live in the issues card; restating a disposition step in `verify` duplicates another card's rule against the deck's no-restatement standard and adds surface. |
| `work` card | Excluded | Same rationale — the triage-to-closure path is owned by the issues card; `work` routing is unchanged. |

## Decision log

- Predicate classification held at intent-decidable: "evidence-backed
  verified-resolved/moot" is judgment; the only mechanical check permitted is
  the existence of a verdict record in the local store.
- floor.md untouched (SC-4) — the fix composes with the floor's
  dispatch-scope gate by defining mirror reconciliation as part of the
  verdict-backed closure workflow rather than a fresh destructive decision.
