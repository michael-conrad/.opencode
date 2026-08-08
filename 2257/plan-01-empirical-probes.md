# Phase 1 — Empirical Probes

**Concern:** Establish ground truth for issue-level vs repo-level label-ops capability against a live local GitBucket instance.

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh` (harness reuse — read only)
- `.opencode/tests-v2/behaviors/<new behavioral test script>` (new)

**SCs:** SC-1, SC-2, SC-3, SC-4

**Dependencies:** None

**Entry Conditions:**
- Spec #2257 is approved and `spec-cleared`
- Feature branch exists (for the `.opencode` submodule change)
- `gb` CLI v0.6.1 present (`gb --version` >= 0.6.1)
- Pre-implementation coherence gate and baseline check passed

**Exit Conditions:**
- Live GitBucket instance provisioned, reachable, authenticated, with test repo
- Issue-level label mutation behavior empirically determined (WORKING or BROKEN) with readback evidence
- Repo-level label CRUD confirmed WORKING
- Issue-level vs repo-level capability split synthesized

**Cost frame (dark-prose-007):** Verification cost is measured in defect-discovery-latency (DDL). SC-1/2/3 are behavioral live probes (~2min each) catching wrong capability claims at pre-PR — a wrong BROKEN/WORKING claim propagates to all four downstream skill cards, so the break point is pre-PR. No substitution of grep for behavioral evidence is permitted.

---

- [ ] 1. **Pre-regression (**sub-agent**).** Dispatch `execute phase-0 task from test-driven-development` to run regression test patterns before any RED phase. **→ baseline**
- [ ] 2. **Pre-regression verify (**sub-agent**).** Dispatch `execute verify task from verification-before-completion` to verify pre-regression results.

### Item SC-1 — Provision reachable, authed GitBucket instance + test repo

- [ ] 3. **RED (**sub-agent**).** Write a failing behavioral enforcement test invoking `__ensure_gitbucket` with `BEHAVIOR_NEEDS_REMOTE=1`, asserting `gb auth status` succeeds and `gb repo view O/R` returns the test repo. **→ SC-1**
- [ ] 4. **GREEN (**sub-agent**).** Run the behavioral test via `bash .opencode/tests-v2/with-test-home opencode run ...` (bash timeout >= 600000ms); provision the harness so the assertion passes. **→ SC-1**
- [ ] 5. **Post-regression (**sub-agent**).** Dispatch `execute phase-4 task from test-driven-development` to run regression patterns after GREEN. **→ SC-1**
- [ ] 6. **Verify (**sub-agent**).** Dispatch `execute verify task from verification-before-completion` confirming the instance is reachable, authenticated, and the test repo exists. **→ SC-1**
- [ ] 7. **Commit (**inline**).** Stage `.opencode/tests-v2/behaviors/` probe additions and commit test + implementation together.

### Item SC-2 — Empirically probe issue-level label mutation

- [ ] 8. **RED (**sub-agent**).** Write a failing behavioral probe asserting the actual issue-level label mutation behavior for `POST/PUT/DELETE /repos/{owner}/{repo}/issues/{number}/labels` via `gb api` with `{"labels":[...]}`, and `get_issue` readback after each write. **→ SC-2**
- [ ] 9. **GREEN (**sub-agent**).** Run the probe via `bash .opencode/tests-v2/with-test-home opencode run ...` (bash timeout >= 600000ms); record whether labels apply (WORKING) or return empty/no-op (BROKEN) with readback evidence. **→ SC-2**
- [ ] 10. **Post-regression (**sub-agent**).** Dispatch `execute phase-4 task from test-driven-development` to run regression patterns after GREEN. **→ SC-2**
- [ ] 11. **Verify (**sub-agent**).** Dispatch `execute verify task from verification-before-completion` confirming the WORKING/BROKEN classification is backed by `gb issue view` readback. **→ SC-2**
- [ ] 12. **Commit (**inline**).** Stage the probe and its evidence; commit test + implementation together.

### Item SC-3 — Empirically verify repo-level label CRUD

- [ ] 13. **RED (**sub-agent**).** Write a failing behavioral probe executing `gb label list/create/view/edit/delete` against the live instance, asserting each succeeds. **→ SC-3**
- [ ] 14. **GREEN (**sub-agent**).** Run the probe via `bash .opencode/tests-v2/with-test-home opencode run ...` (bash timeout >= 600000ms); confirm each `gb label` command succeeds. **→ SC-3**
- [ ] 15. **Post-regression (**sub-agent**).** Dispatch `execute phase-4 task from test-driven-development` to run regression patterns after GREEN. **→ SC-3**
- [ ] 16. **Verify (**sub-agent**).** Dispatch `execute verify task from verification-before-completion` confirming repo-level label CRUD works against the instance. **→ SC-3**
- [ ] 17. **Commit (**inline**).** Stage the probe and its evidence; commit test + implementation together.

### Item SC-4 — Synthesize issue-level vs repo-level capability split

- [ ] 18. **RED (**sub-agent**).** Write a failing assertion capturing the synthesized issue-level vs repo-level capability split derived from the SC-2 + SC-3 verified outcomes. **→ SC-4**
- [ ] 19. **GREEN (**sub-agent**).** Record the derived split (which label operations work at issue level, which only at repo level) as a structural artifact from the verified empirical results. **→ SC-4**
- [ ] 20. **Post-regression (**sub-agent**).** Dispatch `execute phase-4 task from test-driven-development` to run regression patterns after GREEN. **→ SC-4**
- [ ] 21. **Verify (**sub-agent**).** Dispatch `execute verify task from verification-before-completion` confirming the split is correctly derived from SC-2 + SC-3 results (no fabrication). **→ SC-4**
- [ ] 22. **Commit (**inline**).** Stage the synthesized capability split artifact; commit test + implementation together.

#### Phase 1 VbC

- [ ] 23. **VbC (**clean-room**).** Verify SC-1..SC-4 pass with correct evidence types (SC-1/2/3 behavioral live-evidence, SC-4 structural derivation). **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving empirical probe establishment → entering documentation edits. Phase 2 depends on Phase 1's synthesized capability split (SC-4).
