# Phase 2 — Purpose statement quality

**Concern:** Correct purpose statements that fail the audit criteria.

**Files:**
- `.opencode/skills/*/tasks/*.md` (Purpose sections of flagged task cards)

**SCs:** SC-2

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: all 255 dispatch link `[text]` values are purpose condensations (SC-1)
- Phase 1 VbC passed
- Flagged purposes from the SC-1 rewrite pass are identified

**Exit Conditions:**
- Purpose statements failing the audit criteria are corrected (condensable, outcome-as-subject, distinctive from siblings)

---

## Code Path Coverage

- `.opencode/skills/*/tasks/*.md` — Purpose sections of flagged task cards (SC-2)

## Cross-Cutting SCs

- **Purpose-statement semantic fidelity** (SC-2): corrected purposes must remain faithful to the task's core outcome — no semantic drift.
- **Condensation distinctiveness** (SC-2): corrected purposes must be distinctive from sibling tasks within the same skill.

## Interface Boundaries

- **task card Purpose section** — modified, backward compatible: purpose reworded for condensability/outcome-subject/distinctiveness; semantics preserved.

## State Transitions

- **SC-2:** `purpose fails audit criteria` → `purpose corrected (condensable, outcome-as-subject, distinctive)` (trigger: SC-2 correction pass; invariant: semantics preserved; re-checkable via condensation audit).

---

**Cost frame:** Verifying corrected purposes pass the audit costs one structural audit run over the flagged task cards. Skipping means non-condensable purposes ship unchanged, and the SC-1 condensations derived from them remain dead-weight. Correctness is the only success metric — there is no score for tool-call economy.

---

- [ ] 9. **RED (**sub-agent**).** Write a failing structural audit asserting that purpose statements failing the audit criteria (not condensable, not outcome-as-subject, not distinctive from siblings) are identified. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-2, audit criteria, flagged purposes from SC-1 rewrite
- [ ] 10. **GREEN (**sub-agent**).** Correct the flagged purpose statements in the affected task cards so they are condensable, outcome-as-subject, and distinctive from siblings. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-2, corrected purposes, intent preservation
- [ ] 11. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm purpose corrections did not alter task semantics. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-2, post-GREEN regression
- [ ] 12. **verify (**sub-agent**).** Run the structural audit of corrected purpose statements; re-run the SC-1 condensation check on corrected purposes. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-2, condensability/outcome-subject/distinctiveness audit, SC-1 re-check
- [ ] 13. **commit-inline (**inline**).** Stage and commit the corrected Purpose sections in the affected task cards. **→ SC-2**
  - Command: `git add <task cards> && git commit -m "<message>"`

#### Phase 2 VbC

- [ ] 14. **VbC (**clean-room**).** Verify SC-2 passes its structural audit: corrected purposes are condensable, outcome-as-subject, and distinctive from siblings. **→ SC-2**

**Concern transition:** Leaving purpose statement quality → entering dispatch format structure. Phase 3 is independent of Phase 2 (a structural conversion of the dispatch presentation, not the link text).
