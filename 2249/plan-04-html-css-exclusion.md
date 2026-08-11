# Phase 4 — HTML/CSS exclusion

**Concern:** Add the explicit HTML/CSS exclusion to the generic DI section, stating that markup and styling are not programming languages and DI guidance does not apply.

**Files:**
- `.opencode/guidelines/080-code-standards.md` (modify — add HTML/CSS exclusion within the generic DI section)

**SCs:** SC-4

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: generic DI principle section exists
- Phase 1 VbC passed

**Exit Conditions:**
- The explicit HTML/CSS exclusion exists within the generic DI section
- The exclusion states markup and styling are not programming languages and DI guidance does not apply
- SC-4 behavioral evidence produced via `opencode run` + clean-room `session.yaml` evaluation

---

### Item 4 — SC-4 (behavioral): HTML/CSS exclusion

- [ ] 22. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Write a behavioral enforcement test that FAILS because the HTML/CSS exclusion does not yet exist. The test sends a real-domain prompt via `opencode run` and asserts, via `session.yaml`, that an agent encountering markup/styling attempts a DI approach (defect present). RED must fail before GREEN begins.
- [ ] 23. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Make the RED test PASS by adding the explicit HTML/CSS exclusion to the generic DI section in `.opencode/guidelines/080-code-standards.md`. The exclusion states that markup and styling are not programming languages and DI guidance does not apply. No scope creep — only the minimum change needed for SC-4.
- [ ] 24. **post-regression** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after the GREEN change.
- [ ] 25. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Verify SC-4 against its success criterion. Behavioral evidence: `opencode run` `session.yaml` shows the agent did NOT attempt a DI approach on markup/styling. PASS requires clean behavioral evidence — a non-clean pass (DONE_WITH_CONCERNS) is coerced to FAIL.
- [ ] 26. **commit-inline** (**inline**). Orchestrator runs `git add .opencode/guidelines/080-code-standards.md <test files> && git commit -m "<message>"`. Test and implementation committed as one atomic slice. No co-author trailer during implementation commits.

#### Phase 4 VbC

- [ ] 27. **VbC verification assertions** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert SC-4 (behavioral, clean) PASS. Any FAIL (including EVIDENCE_TYPE_MISMATCH for SC-4's behavioral requirement) halts the phase.

**Concern transition:** Leaving HTML/CSS exclusion → entering INDEX.md trigger patterns. Phase 5 depends on Phase 4's fully documented section.
