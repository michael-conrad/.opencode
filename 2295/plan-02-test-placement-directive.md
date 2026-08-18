# Phase 2 — Test-placement directive

**Concern:** Remove the explicit `.issues/{N}/tests/` authorization from `red.md` and direct test placement by the owning-repo principle.

**Files:**
- `.opencode/skills/test-driven-development/tasks/red.md`

**SCs:** SC-2, SC-3

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `.opencode/.issues/AGENTS.md` declares the content-type boundary
- Baseline check passed: `red.md` lists `.issues/{N}/tests/` as a valid test storage path

**Exit Conditions:**
- `.opencode/skills/test-driven-development/tasks/red.md` no longer lists `.issues/{N}/tests/` as a valid test storage path
- `.opencode/skills/test-driven-development/tasks/red.md` directs test placement by the owning-repo principle

---

## Code Path Coverage

- `.opencode/skills/test-driven-development/tasks/red.md` — `.issues/{N}/tests/` removal (SC-2) and owning-repo directive (SC-3)

## Cross-Cutting SCs

- **Test-storage-path authorization removal** (SC-2): `.issues/{N}/tests/` must be removed so RED-phase agents no longer route tests to a non-deployable path.
- **Owning-repo placement** (SC-3): test placement resolves the repo owning the code under test, then places per that repo's conventions; never defaults to `.issues/`.
- **SC-2 → SC-3 sequencing** (both modify `red.md`): the `.issues/{N}/tests/` removal must be applied before the owning-repo directive to avoid edit conflicts on the same file.
- **Boundary consistency** (SC-2, SC-3 → SC-1): both reference the Phase 1 content-type boundary.

## Interface Boundaries

- **`.opencode/skills/test-driven-development/tasks/red.md`** — modified twice, backward compatible: removal and directive preserve RED task semantics.

## State Transitions

- **SC-2:** `red.md lists .issues/{N}/tests/` → `red.md no longer lists .issues/{N}/tests/` (trigger: SC-2 removal; invariant: RED task semantics preserved; re-checkable via grep for absence).
- **SC-3:** `red.md lacks owning-repo directive` → `red.md directs placement by owning-repo principle` (trigger: SC-3 directive; invariant: RED task semantics preserved; re-checkable via grep for presence).

---

**Cost frame:** Verifying `.issues/{N}/tests/` is removed and the owning-repo principle is present costs one grep call each. Skipping means the explicit authorization to misroute test files remains and placement reverts to a fixed-path rule — a defect discovered only when the tests never reach the build, costing 1000× more to fix. Correctness is the only success metric — there is no score for tool-call economy.

---

## SC-2 — Remove `.issues/{N}/tests/` as a test storage path

- [ ] 9. **RED (**sub-agent**).** Write a failing grep test asserting that `.opencode/skills/test-driven-development/tasks/red.md` still contains `.issues/{N}/tests/` as a valid test storage path. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-2, red.md, `.issues/{N}/tests/` present
- [ ] 10. **GREEN (**sub-agent**).** Remove `.issues/{N}/tests/` as a valid test storage path from `red.md`. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-2, remove `.issues/{N}/tests/`, intent preservation
- [ ] 11. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the test-storage-path removal did not break the RED task card's semantics. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-2, post-GREEN regression
- [ ] 12. **verify (**sub-agent**).** Run the string test grep asserting `.issues/{N}/tests/` is ABSENT from red.md. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-2, `.issues/{N}/tests/` absent
- [ ] 13. **commit-inline (**inline**).** Stage and commit the red.md test-storage-path removal. **→ SC-2**
  - Command: `git add .opencode/skills/test-driven-development/tasks/red.md && git commit -m "<message>"`

## SC-3 — Owning-repo placement directive

- [ ] 14. **RED (**sub-agent**).** Write a grep test asserting that `red.md` lacks the owning-repo placement reference. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-3, red.md, owning-repo reference absent
- [ ] 15. **GREEN (**sub-agent**).** Add the owning-repo principle directive to `red.md` directing test placement by resolving the repo owning the code under test, then placing per that repo's conventions. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-3, owning-repo principle, no default to `.issues/`
- [ ] 16. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the owning-repo directive is consistent with the SC-2 removal. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-3, post-GREEN regression
- [ ] 17. **verify (**sub-agent**).** Run the string test grep asserting the owning-repo reference is PRESENT in red.md. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-3, owning-repo reference present
- [ ] 18. **commit-inline (**inline**).** Stage and commit the red.md owning-repo principle addition. **→ SC-3**
  - Command: `git add .opencode/skills/test-driven-development/tasks/red.md && git commit -m "<message>"`

#### Phase 2 VbC

- [ ] 19. **VbC (**clean-room**).** Verify SC-2 and SC-3 pass: `.issues/{N}/tests/` is absent from red.md and the owning-repo principle is present. **→ SC-2, SC-3**

**Concern transition:** Leaving test-placement directive → entering artifact-retention framing. Phase 3 (SC-4) depends on Phase 1's boundary — the metadata-only boundary is the framing SC-4's Rule 1 clarification aligns to.
