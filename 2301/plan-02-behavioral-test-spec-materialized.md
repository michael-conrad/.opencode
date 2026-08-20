# Phase 2 — behavioral test proving spec.md materialized

**Concern:** Add a behavioral/structural test proving a folder that exists without `spec.md` is completed (spec.md materialized) rather than halted.

**Files:**
- `.opencode/tests-v2/behaviors/2301-*.sh`

**SCs:** SC2

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: the completeness gate exists in `import-remote.md`
- Phase 1 VbC passed

**Exit Conditions:**
- A behavioral/structural test proves a folder that exists without `spec.md` is completed (spec.md materialized) rather than halted
- The test passes

---

- [ ] 9. **Pre-regression (**sub-agent**).** Run regression test patterns before the RED phase. **→ SC2**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-pre-regression-*`
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`
- [ ] 10. **Pre-regression verify (**sub-agent**).** Verify pre-regression results. **→ SC2**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-pre-regression-verify-*`
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 11. **RED (**sub-agent**).** Write a failing behavioral test `2301-*.sh` asserting `spec.md` is materialized (no HALT). **→ SC2**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-red-*`
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
  - The test asserts a folder that exists without `spec.md` is completed (spec.md materialized) rather than halted
- [ ] 12. **GREEN (**sub-agent**).** Make the test pass (the gate materializes `spec.md`). **→ SC2**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-green-*`
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
  - Confirm the completeness gate materializes `spec.md` for a pre-existing directory lacking it
- [ ] 13. **Post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase. **→ SC2**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-post-regression-*`
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 14. **Verify (**sub-agent**).** Verify implementation against success criteria. **→ SC2**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-verify-*`
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Confirm the test proves `spec.md` is materialized for a folder that exists without it
- [ ] 15. **Commit (**inline**).** Stage and commit the test and change together as one atomic slice. **→ SC2**
  - Orchestrator runs `git add <files> && git commit -m "<message>"`
  - No co-author trailers during implementation commits

#### Phase 2 VbC

- [ ] 16. **VbC (**clean-room**).** Verify the behavioral test proves `spec.md` is materialized for a folder that exists without it. **→ SC2**

**Concern transition:** Leaving the behavioral test → entering the Edge Cases table update. Phase 3 is independent of the gate behavior but is sequenced after Phase 1 to avoid same-file edit conflicts on `import-remote.md`.
