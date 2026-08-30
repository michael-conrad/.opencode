# Phase 1 — Verification-gate enforcement

**Concern:** Core verification gate changes — add test count assertion, all-passed assertion, and `tests-run.yaml` evidence artifact requirement to the verification-before-completion pipeline.

**Files:**
- `.opencode/skills/verification-before-completion/tasks/verify.md`
- `.opencode/skills/verification-before-completion/tasks/collect.md`
- `.opencode/skills/verification-before-completion/tasks/operating-protocol.md`

**SCs:** SC-1a, SC-1b, SC-2

**Dependencies:** None

**Entry Conditions:**
- Spec #2416 is approved
- Feature branch exists
- Pre-regression tests pass

**Exit Conditions:**
- verify.md Step 2 asserts `tests_run > 0` before accepting completion
- verify.md Step 2 asserts `all_passed == true` before accepting completion
- verify.md and collect.md reference `tests-run.yaml` evidence artifact
- operating-protocol.md cross-references include the test evidence assertion
- All structural checks pass (if applicable)
- Phase 1 VbC passes

---

**Cost frame:** Adding the test-count assertion and all-passed assertion each cost one verification-before-completion task edit. Adding the `tests-run.yaml` evidence requirement costs one pipeline config update. Skipping these means an agent can claim completion having run zero tests — the primary failure mode this spec is designed to prevent. Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

---

### Item: SC-1a — Add test-execution count assertion to verify.md

- [ ] 1. **Pre-regression (**sub-agent**).** Run regression test patterns before RED phase. Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`. **→ SC-1a, SC-1b, SC-2**
- [ ] 2. **Pre-regression verify (**sub-agent**).** Verify pre-regression results. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-1a, SC-1b, SC-2**

- [ ] 3. **RED (**sub-agent**).** Write a failing behavioral test that confirms completion can be claimed without test execution. Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-1a**
- [ ] 4. **GREEN (**sub-agent**).** Add `tests_run > 0` check to verify.md Step 2 (evidence check stage). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-1a**
- [ ] 5. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-1a**
- [ ] 6. **Verify (**sub-agent**).** Verify SC-1a implementation against success criteria. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-1a**
- [ ] 7. **Commit (**inline**).** Stage and commit changes for SC-1a. `git add .opencode/skills/verification-before-completion/tasks/ && git commit -m "verify.md: add tests_run > 0 assertion"`. **→ SC-1a**

### Item: SC-1b — Add all-passed assertion to verify.md

- [ ] 8. **Pre-regression (**sub-agent**).** Run regression test patterns before RED phase. **→ SC-1b**
- [ ] 9. **Pre-regression verify (**sub-agent**).** Verify pre-regression results. **→ SC-1b**

- [ ] 10. **RED (**sub-agent**).** Write a failing behavioral test that confirms completion can be claimed with a failing test. **→ SC-1b**
- [ ] 11. **GREEN (**sub-agent**).** Add `all_passed == true` check to verify.md Step 2. **→ SC-1b**
- [ ] 12. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ SC-1b**
- [ ] 13. **Verify (**sub-agent**).** Verify SC-1b implementation. **→ SC-1b**
- [ ] 14. **Commit (**inline**).** `git add .opencode/skills/verification-before-completion/tasks/ && git commit -m "verify.md: add all_passed assertion"`. **→ SC-1b**

### Item: SC-2 — Require tests-run.yaml evidence artifact

- [ ] 15. **Pre-regression (**sub-agent**).** Run regression test patterns before RED phase. **→ SC-2**
- [ ] 16. **Pre-regression verify (**sub-agent**).** Verify pre-regression results. **→ SC-2**

- [ ] 17. **RED (**sub-agent**).** Write a failing structural check that confirms no test evidence requirement in pipeline. **→ SC-2**
- [ ] 18. **GREEN (**sub-agent**).** Update verify.md and collect.md to require `tests-run.yaml` evidence artifact in the verification pipeline. Also update operating-protocol.md with a cross-reference to the test evidence assertion. **→ SC-2**
- [ ] 19. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ SC-2**
- [ ] 20. **Verify (**sub-agent**).** Verify task files contain evidence requirement. **→ SC-2**
- [ ] 21. **Commit (**inline**).** `git add .opencode/skills/verification-before-completion/tasks/ && git commit -m "verify.md+collect.md: require tests-run.yaml evidence artifact"`. **→ SC-2**

#### Phase 1 VbC

- [ ] 22. **VbC (**clean-room**).** Verify all SC-1a, SC-1b, SC-2 pass with evidence artifacts. **→ SC-1a, SC-1b, SC-2**

**Concern transition:** Leaving verification gate enforcement → entering documentation update. Phase 2 depends on Phase 1's gate changes to document accurately.
