# Phase 4 — Artifact-copy disambiguation

**Concern:** Disambiguate the analytical-artifacts copy target in `create.md` Step 6 so only analysis artifacts (not source/test/fixture) are copied to `.issues/{N}/artifacts/`.

**Files:**
- `.opencode/skills/spec-creation/tasks/create.md`

**SCs:** SC-5

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `.opencode/.issues/AGENTS.md` declares the content-type boundary
- Baseline check passed: `create.md` Step 6 copy target is ambiguous (does not restrict to analysis artifacts)

**Exit Conditions:**
- `.opencode/skills/spec-creation/tasks/create.md` Step 6 disambiguates the analytical-artifacts copy target to analysis-artifacts-only

---

## Code Path Coverage

- `.opencode/skills/spec-creation/tasks/create.md` — Step 6 analytical-artifacts copy target (SC-5)

## Cross-Cutting SCs

- **Analysis-artifacts-only copy target** (SC-5): Step 6 must copy only analysis artifacts (not source/test/fixture) to `.issues/{N}/artifacts/`.
- **Boundary consistency** (SC-5 → SC-1): the boundary disambiguates what is metadata vs source/test/fixture, which SC-5's copy-target clarification references.

## Interface Boundaries

- **`.opencode/skills/spec-creation/tasks/create.md`** — modified, backward compatible: Step 6 copy-target disambiguation preserves the valid analysis-artifact persistence.

## State Transitions

- **SC-5:** `Step 6 copy target ambiguous` → `Step 6 copy target disambiguated to analysis-artifacts-only` (trigger: Step 6 disambiguation; invariant: analysis-artifact persistence preserved; re-checkable via grep for unambiguous copy-target description).

---

**Cost frame:** Verifying Step 6 disambiguates the copy target costs one grep call. Skipping means the ambiguous "analytical artifacts" term continues to permit copying source/test/fixture content into `.issues/{N}/artifacts/` — a defect discovered only when non-deployable content ships, costing 1000× more to fix. Correctness is the only success metric — there is no score for tool-call economy.

---

- [ ] 26. **RED (**sub-agent**).** Write a grep test asserting that `create.md` Step 6 lacks an unambiguous copy-target description (only analysis artifacts, not source/test/fixture). **→ SC-5**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-5, create.md Step 6, unambiguous copy-target absent
- [ ] 27. **GREEN (**sub-agent**).** Disambiguate Step 6 so only analysis artifacts (not source/test/fixture) are copied to `.issues/{N}/artifacts/`. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-5, disambiguated copy-target scope, intent preservation
- [ ] 28. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the copy-target disambiguation is consistent. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-5, post-GREEN regression
- [ ] 29. **verify (**sub-agent**).** Run the string grep asserting Step 6's copy target is disambiguated to analysis-artifacts-only. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-5, unambiguous copy-target present
- [ ] 30. **commit-inline (**inline**).** Stage and commit the create.md Step 6 disambiguation. **→ SC-5**
  - Command: `git add .opencode/skills/spec-creation/tasks/create.md && git commit -m "<message>"`

#### Phase 4 VbC

- [ ] 31. **VbC (**clean-room**).** Verify SC-5 passes its string check: Step 6's copy target is disambiguated to analysis artifacts only. **→ SC-5**

**Concern transition:** Leaving artifact-copy disambiguation → entering PR auto-commit removal. Phase 5 (SC-6) depends on Phase 1's boundary — the boundary clarifies that `.issues/` is metadata-only, which SC-6's auto-commit removal is consistent with.
