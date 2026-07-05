# Phase 3 — write.md Structural Renumbering + Plan Format Requirements

**Concern:** `write.md` has duplicate Step 1a/1b labels, 7r before 7a ordering, Pre-Step/Step 0.x naming, content templates as numbered steps, numbering gaps, and lacks a mandate that plan steps must route to implementation skill task cards rather than inlining procedure text.

**Files:**
- `.opencode/skills/spec-creation/tasks/write.md`

**SCs:** SC-8, SC-9, SC-10, SC-11, SC-12, SC-13, SC-14

**Dependencies:** Phase 2 (same file — `write.md` is the write task referenced by the dispatch table)

**Entry conditions:** Phase 2 committed

**Exit conditions:** All 5 numbering defects fixed, Plan Format Requirements updated with skill/task routing mandate and full pipeline enumeration, behavioral test for SC-14 passes

---

### Global Pre-Steps

- [ ] 23. **Coherence gate (**clean-room**).** `skill({name: "pre-analysis"})` → `task(..., prompt: "execute pre-analysis task from pre-analysis")` for `write.md`. Verify current step numbering, content template structure, 7r ordering, and Plan Format Requirements section before making changes.

- [ ] 24. **Pre-red-baseline (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for SC-8 through SC-14. Confirm current state fails.

### Phase 3 Steps

- [ ] 25. **RED (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute red task from test-driven-development")` for SC-14 (local-issues sync discipline). Write behavioral test: `opencode-cli run` with spec creation prompt → stderr shows `local-issues sync` before `.issues/` writes and after spec folder content changes. Confirm FAIL.

- [ ] 26. **GREEN (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute green task from test-driven-development")` for SC-10. Fix C3 (Pre-Step / Step 0.x naming): Rename `Pre-Step` to `Step 1`, `Pre-Step 0.8` to `Step 2`, `Step 0.5` to `Step 3`, `Step 0.5a` to `Step 4`.

- [ ] 27. **GREEN (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute green task from test-driven-development")` for SC-11. Fix C4 (content templates as numbered steps): Move Decision Ledger, Risk Traceability, Revision Policy, Decomposition Classification, Spec Family Annotation, Non-Goals, Regression Invariants, and Cross-Cutting SC Designation from numbered steps to sub-bullets under the Assemble Spec step.

- [ ] 28. **GREEN (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute green task from test-driven-development")` for SC-8. Fix C1 (duplicate Step 1a/1b): Rename second `Step 1a` (Forward-Looking Mandate) to `Step 1c`. Rename second `Step 1b` (Sub-Folder References) to `Step 1d`. Fix C5 (numbering gap 19a → 20): Re-number all step labels to a consistent scheme.

- [ ] 29. **GREEN (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute green task from test-driven-development")` for SC-9. Fix C2 (7r before 7a ordering): Move `Step 7r` (Remote Issue Body Format) before `Step 7` (Create Issue). Renumber `7a`/`7b`/`7c`/`7d` to sequential sub-steps.

- [ ] 30. **GREEN (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute green task from test-driven-development")` for SC-12 and SC-13. Update write.md Plan Format Requirements section:

    - Add mandate: every dispatch step in a plan MUST use the canonical `skill({name: "..."})` → `task(..., prompt: "execute <task> task from <skill>")` form. Plan steps MUST NOT contain inline procedure text — the plan is a routing document, not a re-implementation of skill task cards.
    - Add mandate: the full implementation pipeline MUST be enumerated with no skipped or combined steps. Each step must reference the correct skill/task combination for the appropriate implementation skill task card. The pipeline includes: coherence gate, pre-red-baseline, RED per item, GREEN per item, GREEN doublecheck per item, checkpoint commit per item, VbC per phase, adversarial audit, cross-validate, regression check, finishing checklist, review-prep, cleanup.
    - Add validation rule: any step containing inline procedure text (code snippets, bash commands, file edit instructions) instead of a `skill({name: "..."})` → `task()` reference is a FORMAT-VIOLATION.

- [ ] 31. **GREEN (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute green task from test-driven-development")` for SC-14. Add `local-issues sync` discipline to write.md: add step requiring `local-issues sync` before any `.issues/` changes, and a step requiring `local-issues sync` immediately after the local spec folder's contents are created or updated.

- [ ] 32. **GREEN doublecheck (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for SC-8 through SC-13. Verify: no duplicate Step 1a/1b, 7r before 7, no Pre-Step/Step 0.x, content templates under Assemble Spec, Plan Format Requirements has skill/task routing mandate and full pipeline enumeration.

- [ ] 33. **Checkpoint commit (**inline**).** `skill({name: "git-workflow"})` → `task(..., prompt: "execute commit task from git-workflow")` with message: `Phase 3: renumber write.md — fix duplicate labels, 7r ordering, Pre-Step naming, content templates, numbering gaps; add plan routing mandate and local-issues sync discipline`.

### Global Post-Steps

- [ ] 34. **Behavioral test (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for SC-14. Run behavioral test: `opencode-cli run` with spec creation prompt → stderr shows `local-issues sync` before `.issues/` writes and after spec folder content changes. Confirm PASS.

- [ ] 35. **Lint check (**inline**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for markdown formatting. Run `uvx pymarkdownlnt scan -r .opencode/skills/spec-creation/tasks/write.md` (advisory). Fix any issues.

- [ ] 36. **Regression check (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for existing spec-creation functionality. Run existing enforcement tests to confirm no regressions.

#### Phase 3 VbC

- [ ] 37. **VbC (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute completion task from verification-before-completion")` for SC-8 through SC-14. Verify all seven SCs pass.

**Concern transition:** Leaving write.md renumbering → entering writing-plans execution model fix. Phase 4 is independent (different skill file).
