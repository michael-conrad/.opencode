# Phase 4 — Placeholder template semantics

**Concern:** Convert the audit skill's placeholder dispatch links from path templates to semantic templates.

**Files:**
- `.opencode/skills/audit/SKILL.md`

**SCs:** SC-4

**Dependencies:** None

**Entry Conditions:**
- Spec #2296 is approved
- Feature branch exists
- Baseline check passed: the audit skill's 4 placeholder dispatch links use path templates in `[text]`

**Exit Conditions:**
- The audit skill's 4 placeholder dispatch links use semantic templates; URL path template unchanged

---

## Code Path Coverage

- `.opencode/skills/audit/SKILL.md` — 4 placeholder dispatch links (SC-4)

## Cross-Cutting SCs

- **URL/path integrity** (SC-4): the URL path template must remain unchanged — no routing breakage.
- **Audit DiMo role distinctiveness** (SC-4): the 4 placeholder links (investigator/validator/evaluator/arbiter) must remain distinguishable after semantic templating.

## Interface Boundaries

- **audit placeholder dispatch `[text]`** — modified, internal only: path template → semantic template in `[text]`; URL path template unchanged.

## State Transitions

- **SC-4:** `audit placeholder link [text] = path template` → `[text] = semantic template` (trigger: SC-4 rewrite; invariant: URL path template unchanged; DiMo roles distinguishable).

---

**Cost frame:** Verifying the 4 placeholder links use semantic templates and remain distinguishable costs one structural check over audit/SKILL.md. Skipping means the audit placeholder links ship as path templates, and the DiMo role dispatch links remain dead-weight. Correctness is the only success metric — there is no score for tool-call economy.

---

- [ ] 21. **RED (**sub-agent**).** Write a failing structural check asserting that the audit skill's 4 placeholder dispatch links use path templates in `[text]`. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-4, audit skill, 4 placeholder links, path templates
- [ ] 22. **GREEN (**sub-agent**).** Rewrite the 4 audit/SKILL.md placeholder dispatch links from path templates to semantic templates (e.g., `[investigate <audit-type>]`); the URL path template is unchanged. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-4, semantic templates, DiMo role distinctiveness, URL path template unchanged
- [ ] 23. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the audit dispatch links still resolve. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-4, post-GREEN regression
- [ ] 24. **verify (**sub-agent**).** Run the structural check that `[text]` no longer restates the path and the 4 DiMo roles remain distinguishable. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-4, semantic-template check, role distinctiveness
- [ ] 25. **commit-inline (**inline**).** Stage and commit audit/SKILL.md with semantic-template dispatch links. **→ SC-4**
  - Command: `git add audit/SKILL.md && git commit -m "<message>"`

#### Phase 4 VbC

- [ ] 26. **VbC (**clean-room**).** Verify SC-4 passes its structural check: the 4 audit placeholder links use semantic templates and the DiMo roles remain distinguishable. **→ SC-4**

**Concern transition:** Leaving placeholder template semantics → entering purpose-as-dispatch-anchor source. Phase 5 is independent of Phase 4 (a documentation concern defining the condensation SOURCE contract).
