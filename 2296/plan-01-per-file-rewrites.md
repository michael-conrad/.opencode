# Phase 1 — Per-file rewrites/conversions

**Concern:** Rewrite every dispatch link `[text]` as a purpose-statement condensation, correct purpose statements that fail the audit, convert the two legacy-format skills to canonical checklist format, and convert the audit skill's placeholder links to semantic templates.

**Files:**
- `.opencode/skills/*/SKILL.md` (48 files — dispatch link `[text]` values)
- `.opencode/skills/*/tasks/*.md` (Purpose sections of flagged task cards)
- `.opencode/skills/playwright-cli/SKILL.md`
- `.opencode/skills/completion-core/SKILL.md`
- `.opencode/skills/audit/SKILL.md`

**SCs:** SC-1, SC-2, SC-3, SC-4

**Dependencies:** None

**Entry Conditions:**
- Spec #2296 is approved
- Feature branch exists
- Baseline check passed: working tree clean, affected files present, current `[text]` values are path-restatements

**Exit Conditions:**
- All 255 dispatch link `[text]` values are purpose condensations; URL unchanged
- Purpose statements failing the audit are corrected
- playwright-cli and completion-core use canonical checklist format
- audit placeholder links use semantic templates

---

## Code Path Coverage

- `.opencode/skills/*/SKILL.md` (48 files) — dispatch link `[text]` values (SC-1)
- `.opencode/skills/*/tasks/*.md` — Purpose sections of flagged task cards (SC-2)
- `.opencode/skills/playwright-cli/SKILL.md`, `.opencode/skills/completion-core/SKILL.md` (SC-3)
- `.opencode/skills/audit/SKILL.md` — 4 placeholder dispatch links (SC-4)

## Cross-Cutting SCs

- **URL/path integrity** (SC-1, SC-4): every `[text]` rewrite must preserve the link URL (the task path). No routing breakage.
- **Purpose-statement semantic fidelity** (SC-2): corrected purposes must remain faithful to the task's core outcome — no semantic drift.
- **Condensation distinctiveness** (SC-1, SC-2): condensations must be distinctive from sibling tasks within the same skill.
- **Canonical dispatch format consistency** (SC-3, SC-1): playwright-cli/completion-core converted to canonical checklist (SC-3) and must then carry condensation links (SC-1).
- **Audit DiMo role distinctiveness** (SC-4): the 4 placeholder links (investigator/validator/evaluator/arbiter) must remain distinguishable after semantic templating.

## Interface Boundaries

- **dispatch link `[text]`** — modified, backward compatible: link text changes; the link target/URL unchanged. Agents relying on the URL still resolve; agents reading the `[text]` get more semantic context.
- **dispatch link URL/path** — unchanged, backward compatible: path stays identical — no routing change.
- **task card Purpose section** — modified, backward compatible: purpose reworded for condensability/outcome-subject/distinctiveness; semantics preserved.
- **dispatch format (table → checklist)** — modified, internal only: internal skill-card structure conversion. Dispatch contracts (task names, context fields) preserved; orchestration behavior unchanged.
- **audit placeholder dispatch `[text]`** — modified, internal only: path template → semantic template in `[text]`; URL path template unchanged.

## State Transitions

- **SC-1:** `dispatch link [text] = path-restatement` → `dispatch link [text] = purpose condensation` (trigger: SC-1 rewrite pass; invariant: URL/path unchanged, link always resolves, condensation faithful to purpose). `condensation rewrite flags non-condensable purpose` → `purpose routed to ITEM-2 correction` (trigger: audit finding during rewrite; invariant: no silent skip — flagged purposes must be corrected).
- **SC-2:** `purpose fails audit criteria` → `purpose corrected (condensable, outcome-as-subject, distinctive)` (trigger: SC-2 correction pass; invariant: semantics preserved; re-checkable via condensation audit).
- **SC-3:** `playwright-cli/completion-core legacy table format` → `canonical checklist sub-bullets format` (trigger: SC-3 conversion; invariant: dispatch contracts preserved — same tasks, context).
- **SC-4:** `audit placeholder link [text] = path template` → `[text] = semantic template` (trigger: SC-4 rewrite; invariant: URL path template unchanged; DiMo roles distinguishable).

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
- [ ] 8. **RED (**sub-agent**).** Write a failing structural audit asserting that purpose statements failing the audit criteria (not condensable, not outcome-as-subject, not distinctive from siblings) are identified. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-2, audit criteria, flagged purposes from SC-1 rewrite
- [ ] 9. **GREEN (**sub-agent**).** Correct the flagged purpose statements in the affected task cards so they are condensable, outcome-as-subject, and distinctive from siblings. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-2, corrected purposes, intent preservation
- [ ] 10. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm purpose corrections did not alter task semantics. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-2, post-GREEN regression
- [ ] 11. **verify (**sub-agent**).** Run the structural audit of corrected purpose statements; re-run the SC-1 condensation check on corrected purposes. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-2, condensability/outcome-subject/distinctiveness audit, SC-1 re-check
- [ ] 12. **commit-inline (**inline**).** Stage and commit the corrected Purpose sections in the affected task cards. **→ SC-2**
  - Command: `git add <task cards> && git commit -m "<message>"`
- [ ] 13. **RED (**sub-agent**).** Write a failing structural format check asserting that playwright-cli and completion-core use the legacy table dispatch format. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-3, playwright-cli, completion-core, legacy table format
- [ ] 14. **GREEN (**sub-agent**).** Convert both skills to the canonical numbered-checkbox list with sub-bullet dispatch contracts (Prompt, Context, Returns, Execution mode). **→ SC-3**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-3, canonical checklist format, dispatch contracts preserved
- [ ] 15. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the conversion preserved dispatch contracts. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-3, post-GREEN regression
- [ ] 16. **verify (**sub-agent**).** Run the structural format check against the canonical Workflows template; confirm no legacy Trigger Dispatch Table / Invocation sections remain. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-3, canonical format check
- [ ] 17. **commit-inline (**inline**).** Stage and commit playwright-cli/SKILL.md and completion-core/SKILL.md converted to canonical format. **→ SC-3**
  - Command: `git add playwright-cli/SKILL.md completion-core/SKILL.md && git commit -m "<message>"`
- [ ] 18. **RED (**sub-agent**).** Write a failing structural check asserting that the audit skill's 4 placeholder dispatch links use path templates in `[text]`. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-4, audit skill, 4 placeholder links, path templates
- [ ] 19. **GREEN (**sub-agent**).** Rewrite the 4 audit/SKILL.md placeholder dispatch links from path templates to semantic templates (e.g., `[investigate <audit-type>]`); the URL path template is unchanged. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-4, semantic templates, DiMo role distinctiveness, URL path template unchanged
- [ ] 20. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the audit dispatch links still resolve. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-4, post-GREEN regression
- [ ] 21. **verify (**sub-agent**).** Run the structural check that `[text]` no longer restates the path and the 4 DiMo roles remain distinguishable. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-4, semantic-template check, role distinctiveness
- [ ] 22. **commit-inline (**inline**).** Stage and commit audit/SKILL.md with semantic-template dispatch links. **→ SC-4**
  - Command: `git add audit/SKILL.md && git commit -m "<message>"`

#### Phase 1 VbC

- [ ] 23. **VbC (**clean-room**).** Verify all four SCs (SC-1, SC-2, SC-3, SC-4) pass their structural checks: all 255 `[text]` values are purpose condensations with URL unchanged; corrected purposes pass the audit; playwright-cli/completion-core use canonical checklist; audit links use semantic templates. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving per-file rewrites/conversions → entering post-rewrite normative/enforcement. Phase 2 depends on Phase 1's SC-1 condensation format (the format to validate against) and on SC-6/SC-7's normative condensation source (the rule the gate enforces).
