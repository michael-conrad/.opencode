# Phase 3 — Selection guidance

**Concern:** Add selection guidance to the generic DI section stating that framework choice is driven by code analysis and spec requirements, not a fixed pin, with combinations allowed when the framework table documents two or more idiomatic DI options for the same language.

**Files:**
- `.opencode/guidelines/080-code-standards.md` (modify — add selection guidance within the generic DI section)

**SCs:** SC-3

**Dependencies:** Phase 1, Phase 2

**Entry Conditions:**
- Phase 1 complete: generic DI principle section exists
- Phase 2 complete: curated framework table exists
- Phase 1 and Phase 2 VbC passed

**Exit Conditions:**
- The selection guidance exists within the generic DI section
- The guidance states framework choice is driven by code analysis and spec requirements, not a fixed pin
- The guidance permits combinations when the framework table documents two or more idiomatic DI options for the same language
- SC-3 behavioral evidence produced via `opencode run` + clean-room `session.yaml` evaluation

---

### Item 3 — SC-3 (behavioral): selection guidance

- [ ] 16. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Write a behavioral enforcement test that FAILS because the selection guidance does not yet exist. The test sends a real-domain prompt via `opencode run` and asserts, via `session.yaml`, that an agent writing code in a language with multiple idiomatic DI options makes an arbitrary or fixed-pin framework choice (defect present). RED must fail before GREEN begins.
- [ ] 17. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Make the RED test PASS by adding the selection guidance to the generic DI section in `.opencode/guidelines/080-code-standards.md`. The guidance states that framework choice is driven by code analysis and spec requirements, not a fixed pin, and that combinations of DI approaches are allowed when the framework table documents two or more idiomatic DI options for the same language. No scope creep — only the minimum change needed for SC-3.
- [ ] 18. **post-regression** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after the GREEN change.
- [ ] 19. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Verify SC-3 against its success criterion. Behavioral evidence: `opencode run` `session.yaml` shows the agent selecting a DI approach based on code/spec context rather than a fixed pin. PASS requires clean behavioral evidence — a non-clean pass (DONE_WITH_CONCERNS) is coerced to FAIL.
- [ ] 20. **commit-inline** (**inline**). Orchestrator runs `git add .opencode/guidelines/080-code-standards.md <test files> && git commit -m "<message>"`. Test and implementation committed as one atomic slice. No co-author trailer during implementation commits.

#### Phase 3 VbC

- [ ] 21. **VbC verification assertions** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert SC-3 (behavioral, clean) PASS. Any FAIL (including EVIDENCE_TYPE_MISMATCH for SC-3's behavioral requirement) halts the phase.

**Concern transition:** Leaving selection guidance → entering HTML/CSS exclusion. Phase 4 depends on Phase 1's generic DI principle section.
