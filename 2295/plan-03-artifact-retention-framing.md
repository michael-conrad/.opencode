# Phase 3 — Artifact-retention framing

**Concern:** Correct the misleading permanent/never-delete framing in `implementation-workflow.md` Rule 1 to metadata-only.

**Files:**
- `.opencode/skills/writing-plans/reference/implementation-workflow.md`

**SCs:** SC-4

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `.opencode/.issues/AGENTS.md` declares the content-type boundary
- Baseline check passed: `implementation-workflow.md` Rule 1 lacks metadata-only language

**Exit Conditions:**
- `.opencode/skills/writing-plans/reference/implementation-workflow.md` Rule 1 states `.issues/{N}/` holds issue metadata only, not arbitrary source/test/fixture artifacts

---

## Code Path Coverage

- `.opencode/skills/writing-plans/reference/implementation-workflow.md` — Artifact Retention Rule 1 (SC-4)

## Cross-Cutting SCs

- **Metadata-only retention framing** (SC-4): Rule 1 must clarify that `.issues/{N}/` holds issue metadata only, not arbitrary source/test/fixture artifacts — the "permanent / never delete" framing is corrected.
- **Boundary consistency** (SC-4 → SC-1): the Rule 1 clarification aligns to Phase 1's metadata-only boundary.

## Interface Boundaries

- **`.opencode/skills/writing-plans/reference/implementation-workflow.md`** — modified, backward compatible: Rule 1 clarification preserves the artifact-retention guidance for legitimate metadata.

## State Transitions

- **SC-4:** `Rule 1 lacks metadata-only language` → `Rule 1 clarifies .issues/{N}/ holds issue metadata only` (trigger: Rule 1 reframing; invariant: retention semantics for valid artifacts preserved; re-checkable via grep for presence of metadata-only language).

---

**Cost frame:** Verifying Rule 1 clarifies metadata-only retention costs one grep call. Skipping means the "permanent / never delete" framing continues to invite arbitrary artifact persistence in `.issues/` — a defect discovered only when the build misses source artifacts, costing 1000× more to fix. Correctness is the only success metric — there is no score for tool-call economy.

---

- [ ] 20. **RED (**sub-agent**).** Write a grep test asserting that `implementation-workflow.md` Rule 1 lacks the metadata-only clarification. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-4, implementation-workflow.md Rule 1, metadata-only language absent
- [ ] 21. **GREEN (**sub-agent**).** Reframe Rule 1 to state `.issues/{N}/` holds issue metadata only, not arbitrary source/test/fixture artifacts. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-4, metadata-only framing, intent preservation
- [ ] 22. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the Rule 1 clarification is internally consistent. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-4, post-GREEN regression
- [ ] 23. **verify (**sub-agent**).** Run the string test grep asserting the metadata-only language is PRESENT in Rule 1. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-4, metadata-only language present
- [ ] 24. **commit-inline (**inline**).** Stage and commit the implementation-workflow.md Rule 1 clarification. **→ SC-4**
  - Command: `git add .opencode/skills/writing-plans/reference/implementation-workflow.md && git commit -m "<message>"`

#### Phase 3 VbC

- [ ] 25. **VbC (**clean-room**).** Verify SC-4 passes its string check: Rule 1 states `.issues/{N}/` holds issue metadata only, not arbitrary source/test/fixture artifacts. **→ SC-4**

**Concern transition:** Leaving artifact-retention framing → entering artifact-copy disambiguation. Phase 4 (SC-5) depends on Phase 1's boundary — the boundary disambiguates what is metadata vs source/test/fixture, which SC-5's copy-target clarification references.
