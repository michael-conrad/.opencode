# Phase 3 — Dispatch format structure

**Concern:** Convert the two legacy-format skills to the canonical checklist format.

**Files:**
- `.opencode/skills/playwright-cli/SKILL.md`
- `.opencode/skills/completion-core/SKILL.md`

**SCs:** SC-3

**Dependencies:** None

**Entry Conditions:**
- Spec #2296 is approved
- Feature branch exists
- Baseline check passed: playwright-cli and completion-core use the legacy table dispatch format

**Exit Conditions:**
- playwright-cli and completion-core use the canonical numbered-checkbox sub-bullets format, no legacy Trigger Dispatch Table / Invocation sections

---

## Code Path Coverage

- `.opencode/skills/playwright-cli/SKILL.md`, `.opencode/skills/completion-core/SKILL.md` (SC-3)

## Cross-Cutting SCs

- **Canonical dispatch format consistency** (SC-3): playwright-cli/completion-core converted to canonical checklist (SC-3) and must then carry condensation links (SC-1).

## Interface Boundaries

- **dispatch format (table → checklist)** — modified, internal only: internal skill-card structure conversion. Dispatch contracts (task names, context fields) preserved; orchestration behavior unchanged.

## State Transitions

- **SC-3:** `playwright-cli/completion-core legacy table format` → `canonical checklist sub-bullets format` (trigger: SC-3 conversion; invariant: dispatch contracts preserved — same tasks, context).

---

**Cost frame:** Verifying the conversion preserved dispatch contracts costs one structural format check against the canonical Workflows template. Skipping means the legacy table format ships unchanged, and the two skills remain inconsistent with the rest of the deck. Correctness is the only success metric — there is no score for tool-call economy.

---

- [ ] 15. **RED (**sub-agent**).** Write a failing structural format check asserting that playwright-cli and completion-core use the legacy table dispatch format. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-3, playwright-cli, completion-core, legacy table format
- [ ] 16. **GREEN (**sub-agent**).** Convert both skills to the canonical numbered-checkbox list with sub-bullet dispatch contracts (Prompt, Context, Returns, Execution mode). **→ SC-3**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-3, canonical checklist format, dispatch contracts preserved
- [ ] 17. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the conversion preserved dispatch contracts. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-3, post-GREEN regression
- [ ] 18. **verify (**sub-agent**).** Run the structural format check against the canonical Workflows template; confirm no legacy Trigger Dispatch Table / Invocation sections remain. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-3, canonical format check
- [ ] 19. **commit-inline (**inline**).** Stage and commit playwright-cli/SKILL.md and completion-core/SKILL.md converted to canonical format. **→ SC-3**
  - Command: `git add playwright-cli/SKILL.md completion-core/SKILL.md && git commit -m "<message>"`

#### Phase 3 VbC

- [ ] 20. **VbC (**clean-room**).** Verify SC-3 passes its structural format check: playwright-cli and completion-core use the canonical checklist, no legacy Trigger Dispatch Table / Invocation sections remain. **→ SC-3**

**Concern transition:** Leaving dispatch format structure → entering placeholder template semantics. Phase 4 is independent of Phase 3 (a distinct concern — only the audit skill's 4 placeholder links).
