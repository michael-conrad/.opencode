# Phase 1 — Content-type boundary

**Concern:** Establish the authoritative exclusions list declaring `.issues/` holds issue metadata only, never source/test/fixture/code. This is the content-type boundary — the reference every other text fix aligns to.

**Files:**
- `.opencode/.issues/AGENTS.md`

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2295 is approved
- Feature branch exists
- Baseline check passed: AGENTS.md lacks the exclusions-list marker (e.g., "never source/test/fixture/code")

**Exit Conditions:**
- `.opencode/.issues/AGENTS.md` contains an explicit exclusions list stating `.issues/` holds issue metadata only, never source/test/fixture/code

---

## Code Path Coverage

- `.opencode/.issues/AGENTS.md` — exclusions-list marker (SC-1)

## Cross-Cutting SCs

- **Content-type boundary fidelity** (SC-1): the exclusions list is the authoritative reference SC-2..SC-7 align to; it must declare `.issues/` holds issue metadata only, never source/test/fixture/code.
- **Exclusions-list unambiguity** (SC-1): the list must be explicit and unambiguous — an empty or vague list provides no boundary.

## Interface Boundaries

- **`.opencode/.issues/AGENTS.md`** — modified, backward compatible: exclusions-list addition preserves existing Authorization/workspace-guide semantics.

## State Transitions

- **SC-1:** `AGENTS.md lacks exclusions-list marker` → `AGENTS.md declares .issues/ is issue-metadata-only` (trigger: exclusions-list addition; invariant: workspace-guide semantics preserved; re-checkable via grep).

---

**Cost frame:** Verifying the exclusions-list marker exists in AGENTS.md costs one grep call. Skipping means the content-type boundary is never authoritatively declared, and agents continue to misroute source/tests/fixtures into `.issues/` — a defect discovered only when the lost work surfaces in production, costing 1000× more to fix. Correctness is the only success metric — there is no score for tool-call economy.

---

- [ ] 3. **RED (**sub-agent**).** Write a failing string test asserting that `.opencode/.issues/AGENTS.md` lacks the exclusions-list marker (e.g., "never source/test/fixture/code"). **→ SC-1**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-1, AGENTS.md, exclusions marker absent
- [ ] 4. **GREEN (**sub-agent**).** Add the explicit exclusions list to `.opencode/.issues/AGENTS.md` stating `.issues/` holds issue metadata only, never source/test/fixture/code. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-1, exclusions list, content-type boundary, intent preservation
- [ ] 5. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the exclusions-list addition did not alter the workspace-guide's semantics. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-1, post-GREEN regression
- [ ] 6. **verify (**sub-agent**).** Run the string grep check asserting the exclusions-list marker is present in AGENTS.md. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-1, exclusions-list marker present
- [ ] 7. **commit-inline (**inline**).** Stage and commit the AGENTS.md exclusions-list addition. **→ SC-1**
  - Command: `git add .opencode/.issues/AGENTS.md && git commit -m "<message>"`

#### Phase 1 VbC

- [ ] 8. **VbC (**clean-room**).** Verify SC-1 passes its string check: AGENTS.md contains the explicit exclusions list stating `.issues/` holds issue metadata only, never source/test/fixture/code. **→ SC-1**

**Concern transition:** Leaving content-type boundary → entering test-placement directive. Phase 2 (SC-2, SC-3) depends on Phase 1's boundary — the exclusions list is the authoritative content-type boundary the owning-repo placement directive references.
