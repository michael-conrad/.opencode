# Phase 5 — Purpose-as-dispatch-anchor source

**Concern:** Specify the purpose statement as the dispatch-anchor source in the task-card structure standards.

**Files:**
- `.opencode/reference/task-card-structure-standards.md`

**SCs:** SC-6

**Dependencies:** None

**Entry Conditions:**
- Spec #2296 is approved
- Feature branch exists
- Baseline check passed: `reference/task-card-structure-standards.md` §4 lacks purpose-as-dispatch-anchor-source normative language

**Exit Conditions:**
- `reference/task-card-structure-standards.md` §4 specifies the purpose statement as the dispatch-anchor source (condensable, outcome-as-subject, distinctive)

---

## Code Path Coverage

- `.opencode/reference/task-card-structure-standards.md` (SC-6)

## Cross-Cutting SCs

- **Normative source consistency** (SC-6, SC-7, SC-5): the condensation SOURCE (purpose, SC-6) and FORMAT (`<condensation>`, SC-7) must be consistent with the skill-creator validation gate (SC-5).

## Interface Boundaries

- **task-card-structure-standards.md §4** — modified, internal only: adds purpose-as-dispatch-anchor-source normative spec.

## State Transitions

- **SC-6:** `§4 no purpose-source spec` → `§4 purpose = dispatch-anchor source (condensable, outcome-subject, distinctive)` (trigger: SC-6 doc update; invariant: consistent with ITEM-7 template).

---

**Cost frame:** Verifying the §4 update is internally consistent costs one structural doc review. Skipping means the condensation SOURCE contract is never specified, and the SC-5 gate has no normative rule to enforce. Correctness is the only success metric — there is no score for tool-call economy.

---

- [ ] 27. **RED (**sub-agent**).** Write a failing structural doc review asserting that `reference/task-card-structure-standards.md` §4 lacks purpose-as-dispatch-anchor-source normative language. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-6, task-card-structure-standards.md §4, no purpose-source spec
- [ ] 28. **GREEN (**sub-agent**).** Add to `reference/task-card-structure-standards.md` §4 the normative spec that the purpose statement is the dispatch-anchor source (condensable, outcome-as-subject, distinctive). **→ SC-6**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-6, purpose-as-dispatch-anchor-source, condensable/outcome-subject/distinctive
- [ ] 29. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the §4 update is internally consistent. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-6, post-GREEN regression
- [ ] 30. **verify (**sub-agent**).** Run the structural doc review; cross-reference check with the SC-7 template for consistency. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-6, §4 purpose-source spec, SC-7 template consistency
- [ ] 31. **commit-inline (**inline**).** Stage and commit `reference/task-card-structure-standards.md`. **→ SC-6**
  - Command: `git add reference/task-card-structure-standards.md && git commit -m "<message>"`

#### Phase 5 VbC

- [ ] 32. **VbC (**clean-room**).** Verify SC-6 passes its structural doc review: §4 specifies the purpose statement as the dispatch-anchor source, consistent with the SC-7 template. **→ SC-6**

**Concern transition:** Leaving purpose-as-dispatch-anchor source → entering locked condensation dispatch template. Phase 6 is independent of Phase 5 (a documentation concern defining the condensation FORMAT contract).
