# Phase 1 — Generic DI principle section

**Concern:** Add the generic "Dependency Injection (generic mandate)" principle to `080-code-standards.md` stating the enforceable rule "use a DI approach, not framework X."

**Files:**
- `.opencode/guidelines/080-code-standards.md` (modify — add new section after "Libraries & Packages", before "Print Statements & Output")

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2249 is approved
- Coherence gate and baseline check passed
- #2243 (Python-specific mandate) has merged

**Exit Conditions:**
- The generic DI principle section exists in `080-code-standards.md`
- The section states the generic principle and the enforceable rule "use a DI approach," not "use framework X"
- SC-1 behavioral evidence produced via `opencode run` + clean-room `session.yaml` evaluation

---

- [ ] 2. **pre-regression** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`. Run regression test patterns before the first RED phase. Confirm the baseline behavioral and structural test suite is green.
- [ ] 3. **Verify pre-regression** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Confirm pre-regression results are clean before proceeding to RED.

### Item 1 — SC-1 (behavioral): generic DI principle section

- [ ] 4. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Write a behavioral enforcement test that FAILS because the generic DI principle does not yet exist. The test sends a real-domain prompt via `opencode run` and asserts, via `session.yaml`, that an agent writing code in a language where a DI approach exists hand-rolls manual wiring (defect present). RED must fail before GREEN begins.
- [ ] 5. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Make the RED test PASS by adding the generic "Dependency Injection (generic mandate)" section to `.opencode/guidelines/080-code-standards.md` after "Libraries & Packages" and before "Print Statements & Output". The section must state the generic principle: approach problem solving and unit tests from the point of view of having an available DI approach of some worth, and use it rather than hand-rolling manual wiring where such an approach exists. The enforceable rule SHALL be "use a DI approach," not "use framework X." This is a superset of #2243's Python mandate — Python remains in the "Clear standard" tier with `dependency-injector`. No scope creep — only the minimum change needed for SC-1.
- [ ] 6. **post-regression** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after the GREEN change.
- [ ] 7. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Verify SC-1 against its success criterion. Behavioral evidence: `opencode run` `session.yaml` shows the agent applying the generic DI principle (chose a DI approach) for a solution where a DI approach exists. PASS requires clean behavioral evidence — a non-clean pass (DONE_WITH_CONCERNS) is coerced to FAIL.
- [ ] 8. **commit-inline** (**inline**). Orchestrator runs `git add .opencode/guidelines/080-code-standards.md <test files> && git commit -m "<message>"`. Test and implementation committed as one atomic slice. No co-author trailer during implementation commits.

#### Phase 1 VbC

- [ ] 9. **VbC verification assertions** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert SC-1 (behavioral, clean) PASS. Any FAIL (including EVIDENCE_TYPE_MISMATCH for SC-1's behavioral requirement) halts the phase.

**Concern transition:** Leaving generic DI principle → entering curated framework table. Phase 2 depends on Phase 1's generic principle section.
