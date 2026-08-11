# Phase 6 — Behavioral test artifact generation

**Concern:** Add a behavioral enforcement test under `tests-v2/behaviors/` that dispatches a real-domain prompt via `opencode run` requiring the agent to design a solution/unit test where a DI approach exists, producing `session.yaml` artifacts.

**Files:**
- `.opencode/tests-v2/behaviors/` (add — new behavioral enforcement test script)

**SCs:** SC-6

**Dependencies:** Phase 5

**Entry Conditions:**
- Phase 5 complete: INDEX.md routes agents to the fully documented generic DI section
- Phase 5 VbC passed

**Exit Conditions:**
- A behavioral enforcement test exists under `tests-v2/behaviors/`
- The test dispatches a real-domain prompt via `opencode run` and produces a `session.yaml` artifact
- SC-6 behavioral evidence produced via `opencode run`

---

### Item 6 — SC-6 (behavioral): behavioral test artifact generation

- [ ] 34. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Write a behavioral enforcement test that FAILS because the generic DI mandate is not yet fully documented and routed. The test sends a real-domain prompt via `opencode run` and asserts, via `session.yaml`, that an agent writing code where a DI approach exists hand-rolls manual wiring (defect present). RED must fail before GREEN begins.
- [ ] 35. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Make the RED test PASS by adding a behavioral enforcement test under `.opencode/tests-v2/behaviors/` using the Two-SC pattern (SC-6 artifact generation + SC-7 clean-room `session.yaml` evaluation) per §6a of `tests-v2/AGENTS.md`. The test dispatches a real-domain prompt via `opencode run` requiring the agent to design a solution/unit test where a DI approach exists, producing `session.yaml` artifacts. The prompt MUST be real-domain (natural behavior), not prose-recall, per §11 Prompt Construction Mandate. No scope creep — only the minimum change needed for SC-6.
- [ ] 36. **post-regression** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after the GREEN change.
- [ ] 37. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Verify SC-6 against its success criterion. Behavioral evidence: `opencode run` produces a `session.yaml` artifact recording agent tool calls and decisions. PASS requires clean behavioral evidence — a non-clean pass (DONE_WITH_CONCERNS) is coerced to FAIL.
- [ ] 38. **commit-inline** (**inline**). Orchestrator runs `git add .opencode/tests-v2/behaviors/ <test files> && git commit -m "<message>"`. Test and implementation committed as one atomic slice. No co-author trailer during implementation commits.

#### Phase 6 VbC

- [ ] 39. **VbC verification assertions** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert SC-6 (behavioral, clean) PASS. Any FAIL (including EVIDENCE_TYPE_MISMATCH for SC-6's behavioral requirement) halts the phase.

**Concern transition:** Leaving behavioral test artifact generation → entering clean-room session.yaml evaluation. Phase 7 depends on Phase 6's `session.yaml` artifact.
