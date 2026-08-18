# Phase 2 — Dispatch anchor semantics

**Concern:** Rewrite every dispatch link `[text]` as a condensation of the linked task card's corrected Purpose statement.

**Files:**
- `.opencode/skills/*/SKILL.md` (48 files — dispatch link `[text]` values)

**SCs:** SC-1

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: purpose statements failing the audit criteria are corrected (SC-2)
- Phase 1 VbC passed
- The corrected purposes are available as the condensation source

**Exit Conditions:**
- All 255 dispatch link `[text]` values are purpose condensations; URL unchanged

---

## Code Path Coverage

- `.opencode/skills/*/SKILL.md` (48 files) — dispatch link `[text]` values (SC-1)

## Cross-Cutting SCs

- **URL/path integrity** (SC-1): every `[text]` rewrite must preserve the link URL (the task path). No routing breakage.
- **Condensation distinctiveness** (SC-1): condensations must be distinctive from sibling tasks within the same skill.
- **Condensation SOURCE correctness** (SC-1 ← SC-2): SC-1's condensations are derived from the corrected purposes produced in Phase 1 — Phase 1 must be complete first.

## Interface Boundaries

- **dispatch link `[text]`** — modified, backward compatible: link text changes; the link target/URL unchanged. Agents relying on the URL still resolve; agents reading the `[text]` get more semantic context.
- **dispatch link URL/path** — unchanged, backward compatible: path stays identical — no routing change.

## State Transitions

- **SC-1:** `dispatch link [text] = path-restatement` → `dispatch link [text] = purpose condensation` (trigger: SC-1 rewrite pass; invariant: URL/path unchanged, link always resolves, condensation faithful to purpose). `condensation rewrite flags non-condensable purpose` → `purpose routed back to Phase 1 correction` (trigger: audit finding during rewrite; invariant: no silent skip — flagged purposes must be corrected).

---

**Cost frame:** Verifying the 255 dispatch link `[text]` values are purpose condensations costs one rg/regex scan over the 48 files. Skipping means dead-weight link text ships unchanged, and the next sub-agent dispatched through it receives zero semantic context until it opens the file — a defect that surfaces at every dispatch, compounding across the deck. Correctness is the only success metric — there is no score for tool-call economy.

---

- [ ] 9. **RED (**sub-agent**).** Write a failing structural condensation-format check asserting that dispatch link `[text]` values across the 48 SKILL.md files are path-restatements (not condensations). **→ SC-1**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-1, 48 SKILL.md files, current `[text]` = path-restatement, condensation source = corrected purposes (Phase 1)
- [ ] 10. **GREEN (**sub-agent**).** Rewrite every dispatch link `[text]` across the 48 affected SKILL.md files as a condensation of the linked task card's corrected Purpose statement; the URL remains the path. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-1, condensation source = corrected task card Purpose, URL preserved
- [ ] 11. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm no dispatch behavior regressed. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-1, post-GREEN regression
- [ ] 12. **verify (**sub-agent**).** Run the structural condensation-format check against the corrected purpose source; review the manifest diff to confirm every `[text]` is a condensation and the URL is unchanged. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-1, condensation-format check, manifest diff review, corrected purposes source
- [ ] 13. **commit-inline (**inline**).** Stage and commit the 48 SKILL.md files with rewritten dispatch link `[text]` values. **→ SC-1**
  - Command: `git add <48 SKILL.md files> && git commit -m "<message>"`

#### Phase 2 VbC

- [ ] 14. **VbC (**clean-room**).** Verify SC-1 passes its structural check: all 255 `[text]` values are purpose condensations with URL unchanged. **→ SC-1**

**Concern transition:** Leaving dispatch anchor semantics → entering dispatch format structure. Phase 3 is independent of Phase 2 (a structural conversion of the dispatch presentation, not the link text).
