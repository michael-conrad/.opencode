# Phase 1 — Remove Global Prohibition

**Concern:** Remove the submodule-only-PR prohibition (critical-rules-049) from the global guideline `020-go-prohibitions.md` resident in every agent's context.

**Files:**
- `guidelines/020-go-prohibitions.md`

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2293 is approved (label `approved-for-pr`)
- Feature branch exists
- Phase 1 is the first phase in the DAG — nothing precedes it

**Exit Conditions:**
- The `critical-rules-049` submodule-only-PR prohibition block is absent from `020-go-prohibitions.md`
- The rule is no longer resident in the global guideline

---

- [ ] 1. **Coherence gate (**inline**).** Verify the spec is coherent and the structure artifact phase DAG is acyclic. **→ SC-1**
- [ ] 2. **Baseline check (**inline**).** Confirm `guidelines/020-go-prohibitions.md` exists and contains the `critical-rules-049` block (live read). **→ SC-1**
- [ ] 3. **Pre-cleanup (**inline**).** `rm -f {project_root}/tmp/2293/artifacts/pipeline-red-* pipeline-green-* pipeline-verify-* pipeline-post-regression-*`. **→ SC-1**
- [ ] 4. **Pre-regression (**sub-agent**).** `task(..., prompt: "execute phase-0 task from test-driven-development")`. Run regression test patterns before the RED phase. **→ SC-1**
- [ ] 5. **Pre-regression verify (**clean-room**).** `task(..., prompt: "execute verify task from verification-before-completion")`. Verify the pre-regression results. **→ SC-1**
- [ ] 6. **RED (**sub-agent**).** `task(..., prompt: "execute red task from test-driven-development")`. Write a failing behavioral test asserting the `critical-rules-049` block is absent from `020-go-prohibitions.md` (must FAIL on the current global wording). **→ SC-1**
- [ ] 7. **GREEN (**sub-agent**).** `task(..., prompt: "execute green task from test-driven-development")`. Remove the `critical-rules-049` block from `020-go-prohibitions.md`. No scope creep — only the minimum removal. **→ SC-1**
- [ ] 8. **GREEN doublecheck (**clean-room**).** Verify the block is fully removed with no residual "in ANY context" global wording. **→ SC-1**
- [ ] 9. **Post-regression (**sub-agent**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression patterns after GREEN. **→ SC-1**
- [ ] 10. **Checkpoint commit (**inline**).** `git add guidelines/020-go-prohibitions.md && git commit -m "<message>"`. Commit the RED test and GREEN change as one atomic slice. **→ SC-1**

#### Phase 1 VbC

- [ ] 11. **VbC (**clean-room**).** `task(..., prompt: "execute verify task from verification-before-completion")`. Verify SC-1 against the spec success criterion and evidence type. If the behavioral test cannot execute, report FAIL — never substitute structural evidence. **→ SC-1**

**Concern transition:** Leaving the global guideline removal → entering the surviving task-card rewording. Phase 2 depends on Phase 1 removing the global block so the surviving references are read against the post-removal state.
