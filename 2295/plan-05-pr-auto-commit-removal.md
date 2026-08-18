# Phase 5 — PR auto-commit removal

**Concern:** Remove the unconditional `git add .issues/` auto-commit from `review-prep.md` Step 0 so arbitrary dirty `.issues/<N>/` files are not committed into feature PRs.

**Files:**
- `.opencode/skills/git-workflow-pr/tasks/review-prep.md`

**SCs:** SC-6

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `.opencode/.issues/AGENTS.md` declares the content-type boundary
- Baseline check passed: `review-prep.md` Step 0 contains the unconditional `git add .issues/` auto-commit

**Exit Conditions:**
- `.opencode/skills/git-workflow-pr/tasks/review-prep.md` Step 0 no longer auto-commits arbitrary dirty `.issues/<N>/` files into feature PRs; the unconditional `git add .issues/` auto-commit is removed entirely

---

## Code Path Coverage

- `.opencode/skills/git-workflow-pr/tasks/review-prep.md` — Step 0 `git add .issues/` auto-commit (SC-6)

## Cross-Cutting SCs

- **Auto-commit removal** (SC-6): the unconditional auto-commit of dirty `.issues/<N>/` files into feature PRs is removed entirely — a single deterministic outcome, no either/or escape hatch.
- **Boundary consistency** (SC-6 → SC-1): the boundary clarifies that `.issues/` is metadata-only, which SC-6's auto-commit removal is consistent with.

## Interface Boundaries

- **`.opencode/skills/git-workflow-pr/tasks/review-prep.md`** — modified, backward compatible: the auto-commit removal preserves the intentional PR scoping for real source files.

## State Transitions

- **SC-6:** `Step 0 auto-commits .issues/` → `Step 0 no longer auto-commits .issues/` (trigger: auto-commit removal; invariant: intentional PR scoping preserved; re-checkable via grep for absence of the unconditional `git add .issues/`).

---

**Cost frame:** Verifying Step 0 no longer auto-commits `.issues/` files costs one grep call. Skipping means feature PRs continue to auto-include arbitrary dirty `.issues/` files — a defect discovered only when a PR carries unintended content, costing 1000× more to fix. Correctness is the only success metric — there is no score for tool-call economy.

---

- [ ] 32. **RED (**sub-agent**).** Write a grep test asserting that `review-prep.md` Step 0 contains the unconditional `git add .issues/` auto-commit. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-6, review-prep.md Step 0, unconditional auto-commit present
- [ ] 33. **GREEN (**sub-agent**).** Remove the unconditional auto-commit of dirty `.issues/<N>/` files from `review-prep.md` Step 0 entirely. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-6, remove unconditional auto-commit, intent preservation
- [ ] 34. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the review-prep workflow semantics are preserved. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-6, post-GREEN regression
- [ ] 35. **verify (**sub-agent**).** Run the string test grep asserting the unconditional `git add .issues/` auto-commit is REMOVED from Step 0. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-6, unconditional auto-commit absent
- [ ] 36. **commit-inline (**inline**).** Stage and commit the review-prep.md Step 0 auto-commit removal. **→ SC-6**
  - Command: `git add .opencode/skills/git-workflow-pr/tasks/review-prep.md && git commit -m "<message>"`

#### Phase 5 VbC

- [ ] 37. **VbC (**clean-room**).** Verify SC-6 passes its string check: Step 0 no longer contains the unconditional `git add .issues/` auto-commit. **→ SC-6**

**Concern transition:** Leaving PR auto-commit removal → entering behavioral enforcement. Phase 6 (SC-7) depends on Phase 1's boundary — SC-7's behavioral test asserts the `.issues/` content-type boundary established by SC-1.
