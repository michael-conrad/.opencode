# Phase 1 — Dispatch anchor semantics

**Concern:** Rewrite every dispatch link `[text]` as a purpose-statement condensation.

**Files:**
- `.opencode/skills/*/SKILL.md` (48 files — dispatch link `[text]` values)

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2296 is approved
- Feature branch exists
- Baseline check passed: working tree clean, affected files present, current `[text]` values are path-restatements

**Exit Conditions:**
- All 255 dispatch link `[text]` values are purpose condensations; URL unchanged

---

## Code Path Coverage

- `.opencode/skills/*/SKILL.md` (48 files) — dispatch link `[text]` values (SC-1)

## Cross-Cutting SCs

- **URL/path integrity** (SC-1): every `[text]` rewrite must preserve the link URL (the task path). No routing breakage.
- **Condensation distinctiveness** (SC-1): condensations must be distinctive from sibling tasks within the same skill.

## Interface Boundaries

- **dispatch link `[text]`** — modified, backward compatible: link text changes; the link target/URL unchanged. Agents relying on the URL still resolve; agents reading the `[text]` get more semantic context.
- **dispatch link URL/path** — unchanged, backward compatible: path stays identical — no routing change.

## State Transitions

- **SC-1:** `dispatch link [text] = path-restatement` → `dispatch link [text] = purpose condensation` (trigger: SC-1 rewrite pass; invariant: URL/path unchanged, link always resolves, condensation faithful to purpose). `condensation rewrite flags non-condensable purpose` → `purpose routed to ITEM-2 correction` (trigger: audit finding during rewrite; invariant: no silent skip — flagged purposes must be corrected).

---

**Cost frame:** Verifying the 255 dispatch link `[text]` values are purpose condensations costs one rg/regex scan over the 48 files. Skipping means dead-weight link text ships unchanged, and the next sub-agent dispatched through it receives zero semantic context until it opens the file — a defect that surfaces at every dispatch, compounding across the deck. Correctness is the only success metric — there is no score for tool-call economy.

---

- [ ] 3. **RED (**sub-agent**).** Write a failing structural condensation-format check asserting that dispatch link `[text]` values across the 48 SKILL.md files are path-restatements (not condensations). **→ SC-1**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-1, 48 SKILL.md files, current `[text]` = path-restatement
- [ ] 4. **GREEN (**sub-agent**).** Rewrite every dispatch link `[text]` across the 48 affected SKILL.md files as a condensation of the linked task card's Purpose statement; the URL remains the path. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-1, condensation source = task card Purpose, URL preserved
- [ ] 5. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm no dispatch behavior regressed. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-1, post-GREEN regression
- [ ] 6. **verify (**sub-agent**).** Run the structural condensation-format check against the purpose source; review the manifest diff to confirm every `[text]` is a condensation and the URL is unchanged. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-1, condensation-format check, manifest diff review
- [ ] 7. **commit-inline (**inline**).** Stage and commit the 48 SKILL.md files with rewritten dispatch link `[text]` values. **→ SC-1**
  - Command: `git add <48 SKILL.md files> && git commit -m "<message>"`

#### Phase 1 VbC

- [ ] 8. **VbC (**clean-room**).** Verify SC-1 passes its structural check: all 255 `[text]` values are purpose condensations with URL unchanged. **→ SC-1**

**Concern transition:** Leaving dispatch anchor semantics → entering purpose statement quality. Phase 2 depends on Phase 1's SC-1 condensation rewrite (the flagged purposes it corrects come from the SC-1 rewrite pass).
