# Phase 7 — Clean-room session.yaml evaluation

**Concern:** A clean-room sub-agent evaluates the `session.yaml` artifact (from SC-6) and confirms the agent applied the DI mandate — selected a DI approach rather than hand-rolling manual wiring — covering at least one "Clear standard" language and one "Contested"/"Non-idiomatic" language, and confirming the HTML/CSS exclusion.

**Files:**
- `.opencode/tests-v2/behaviors/` (add — clean-room `session.yaml` evaluation)

**SCs:** SC-7

**Dependencies:** Phase 6

**Entry Conditions:**
- Phase 6 complete: `session.yaml` artifact produced
- Phase 6 VbC passed

**Exit Conditions:**
- A clean-room sub-agent reads the `session.yaml` artifact and verifies DI-mandate compliance
- The evaluation covers at least one "Clear standard" language and one "Contested"/"Non-idiomatic" language, plus the HTML/CSS exclusion
- SC-7 behavioral evidence produced via clean-room `session.yaml` evaluation

---

### Item 7 — SC-7 (behavioral): clean-room session.yaml evaluation

- [ ] 40. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Write a behavioral enforcement test that FAILS because the clean-room `session.yaml` evaluation does not yet exist. The test asserts, via `session.yaml`, that no clean-room evaluation confirms DI-mandate compliance (defect present). RED must fail before GREEN begins.
- [ ] 41. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Make the RED test PASS by adding a clean-room sub-agent evaluation of the `session.yaml` artifact (from SC-6) that confirms the agent applied the DI mandate — selected a DI approach rather than hand-rolling manual wiring — covering at least one "Clear standard" language and one "Contested"/"Non-idiomatic" language, and confirming the HTML/CSS exclusion. The evaluation sub-agent receives ONLY the artifact path and the SC criterion — no orchestrator context, no expected outcomes. No scope creep — only the minimum change needed for SC-7.
- [ ] 42. **post-regression** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after the GREEN change.
- [ ] 43. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Verify SC-7 against its success criterion. Behavioral evidence: clean-room sub-agent produces a PASS verdict on `session.yaml` (from SC-6) confirming DI-mandate compliance. PASS requires clean behavioral evidence — a non-clean pass (DONE_WITH_CONCERNS) is coerced to FAIL.
- [ ] 44. **commit-inline** (**inline**). Orchestrator runs `git add .opencode/tests-v2/behaviors/ <test files> && git commit -m "<message>"`. Test and implementation committed as one atomic slice. No co-author trailer during implementation commits.

#### Phase 7 VbC

- [ ] 45. **VbC verification assertions** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert SC-7 (behavioral, clean) PASS. Any FAIL (including EVIDENCE_TYPE_MISMATCH for SC-7's behavioral requirement) halts the phase.

**Concern transition:** Leaving clean-room session.yaml evaluation → plan complete. All 7 SCs delivered.
