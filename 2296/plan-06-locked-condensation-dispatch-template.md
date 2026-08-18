# Phase 6 — Locked condensation dispatch template

**Concern:** Specify the locked condensation dispatch template in the skill-card description standards.

**Files:**
- `.opencode/reference/skill-card-description-standards.md`

**SCs:** SC-7

**Dependencies:** None

**Entry Conditions:**
- Spec #2296 is approved
- Feature branch exists
- Baseline check passed: the base prompt format in `reference/skill-card-description-standards.md` lacks the locked condensation dispatch template

**Exit Conditions:**
- `reference/skill-card-description-standards.md` specifies the locked condensation dispatch template, consistent with SC-6

---

## Code Path Coverage

- `.opencode/reference/skill-card-description-standards.md` (SC-7)

## Cross-Cutting SCs

- **Normative source consistency** (SC-6, SC-7, SC-5): the condensation SOURCE (purpose, SC-6) and FORMAT (`<condensation>`, SC-7) must be consistent with the skill-creator validation gate (SC-5).

## Interface Boundaries

- **skill-card-description-standards.md base prompt template** — modified, internal only: adds locked condensation dispatch template `[<condensation>](<path>)`.

## State Transitions

- **SC-7:** `no locked dispatch template` → `locked template: 'You are a sub-agent. Follow the instructions in [<condensation>](<path>). <context-fields>'` (trigger: SC-7 doc update; invariant: consistent with ITEM-6 purpose-source spec).

---

**Cost frame:** Verifying the template update is internally consistent costs one structural doc review. Skipping means the condensation FORMAT contract is never specified, and the SC-5 gate has no format to validate against. Correctness is the only success metric — there is no score for tool-call economy.

---

- [ ] 33. **RED (**sub-agent**).** Write a failing structural doc review asserting that the base prompt format in `reference/skill-card-description-standards.md` lacks the locked condensation dispatch template. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-7, skill-card-description-standards.md, no locked template
- [ ] 34. **GREEN (**sub-agent**).** Add to `reference/skill-card-description-standards.md` the locked dispatch template: `You are a sub-agent. Follow the instructions in [<condensation>](<path>). <context-fields>`. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-7, locked condensation dispatch template
- [ ] 35. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the template update is internally consistent. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-7, post-GREEN regression
- [ ] 36. **verify (**sub-agent**).** Run the structural doc review; cross-reference check with the SC-6 purpose-source spec for consistency. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-7, locked template present, SC-6 consistency
- [ ] 37. **commit-inline (**inline**).** Stage and commit `reference/skill-card-description-standards.md`. **→ SC-7**
  - Command: `git add reference/skill-card-description-standards.md && git commit -m "<message>"`

#### Phase 6 VbC

- [ ] 38. **VbC (**clean-room**).** Verify SC-7 passes its structural doc review: the locked condensation dispatch template is present and consistent with the SC-6 purpose-source spec. **→ SC-7**

**Concern transition:** Leaving locked condensation dispatch template → entering condensation-format validation gate. Phase 7 depends on Phase 1's SC-1 condensation format (the format to validate against) and on Phase 5/6's SC-6/SC-7 normative condensation source (the rule the gate enforces).
