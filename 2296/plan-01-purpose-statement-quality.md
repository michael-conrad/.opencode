# Phase 1 — Purpose statement quality

**Concern:** Correct purpose statements that fail the audit criteria. This is the condensation SOURCE — SC-1's condensations are derived from these corrected purposes, so they must be corrected first.

**Files:**
- `.opencode/skills/*/tasks/*.md` (Purpose sections of flagged task cards)

**SCs:** SC-2

**Dependencies:** None

**Entry Conditions:**
- Spec #2296 is approved
- Feature branch exists
- Baseline check passed: purpose statements failing the audit criteria (not condensable, not outcome-as-subject, not distinctive from siblings) are identified

**Exit Conditions:**
- Purpose statements failing the audit criteria are corrected (condensable, outcome-as-subject, distinctive from siblings)

---

## Code Path Coverage

- `.opencode/skills/*/tasks/*.md` — Purpose sections of flagged task cards (SC-2)

## Cross-Cutting SCs

- **Purpose-statement semantic fidelity** (SC-2): corrected purposes must remain faithful to the task's core outcome — no semantic drift.
- **Condensation distinctiveness** (SC-2): corrected purposes must be distinctive from sibling tasks within the same skill.
- **Condensation SOURCE readiness** (SC-2 → SC-1): the corrected purposes are the source SC-1's dispatch-link condensations are derived from — SC-1 depends on these corrected purposes.

## Interface Boundaries

- **task card Purpose section** — modified, backward compatible: purpose reworded for condensability/outcome-subject/distinctiveness; semantics preserved.

## State Transitions

- **SC-2:** `purpose fails audit criteria` → `purpose corrected (condensable, outcome-as-subject, distinctive)` (trigger: SC-2 correction pass; invariant: semantics preserved; re-checkable via condensation audit).

---

**Cost frame:** Verifying corrected purposes pass the audit costs one structural audit run over the flagged task cards. Skipping means non-condensable purposes ship unchanged, and the SC-1 condensations derived from them remain dead-weight. Correctness is the only success metric — there is no score for tool-call economy.

---

- [ ] 3. **RED (**sub-agent**).** Write a failing structural audit asserting that purpose statements failing the audit criteria (not condensable, not outcome-as-subject, not distinctive from siblings) are identified. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-2, audit criteria, flagged purposes (fail condensable/outcome-subject/distinctive)
- [ ] 4. **GREEN (**sub-agent**).** Correct the flagged purpose statements in the affected task cards so they are condensable, outcome-as-subject, and distinctive from siblings. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-2, corrected purposes, intent preservation
- [ ] 5. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm purpose corrections did not alter task semantics. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-2, post-GREEN regression
- [ ] 6. **verify (**sub-agent**).** Run the structural audit of corrected purpose statements; confirm the corrected purposes are condensable, outcome-as-subject, and distinctive (the source SC-1 will condense). **→ SC-2**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-2, condensability/outcome-subject/distinctiveness audit
- [ ] 7. **commit-inline (**inline**).** Stage and commit the corrected Purpose sections in the affected task cards. **→ SC-2**
  - Command: `git add <task cards> && git commit -m "<message>"`

#### Phase 1 VbC

- [ ] 8. **VbC (**clean-room**).** Verify SC-2 passes its structural audit: corrected purposes are condensable, outcome-as-subject, and distinctive from siblings. **→ SC-2**

**Concern transition:** Leaving purpose statement quality → entering dispatch anchor semantics. Phase 2 (SC-1) depends on Phase 1's corrected purposes — the corrected purposes are the source the SC-1 dispatch condensations are derived from.
