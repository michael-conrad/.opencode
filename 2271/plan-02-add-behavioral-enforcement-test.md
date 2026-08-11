# Phase 2 — Add behavioral enforcement test

**Concern:** behavioral-enforcement

**Files:**
- `.opencode/tests-v2/behaviors/stacked-pr-organization.sh` (new)

**SCs:** SC-2

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `critical-rules-PR-ORG` exists in `000-critical-rules.md`
- Phase 1 VbC passed
- Fixture spec `100-stacked-branch-for-pr` SC-4 exists (requires `stacked-pr-organization.sh`)

**Exit Conditions:**
- `stacked-pr-organization.sh` exists under `.opencode/tests-v2/behaviors/`
- The test dispatches a real-domain prompt via `opencode run` requiring the agent to implement multiple issues under a single `for_pr` authorization
- The test asserts exactly ONE feature branch and ONE PR (stacked commits, one per issue)

---

- [ ] 6. **RED (**sub-agent**).** Write a failing behavioral enforcement test `stacked-pr-organization.sh` that dispatches a real-domain prompt via `opencode run` requiring the agent to implement multiple issues under a single `for_pr` authorization. **→ SC-2**
- [ ] 7. **GREEN (**sub-agent**).** Implement the test to assert the agent creates exactly ONE feature branch and ONE PR (stacked commits, one per issue), following the `behavior_run` harness pattern from `helpers.sh` and the fixture spec `100-stacked-branch-for-pr` SC-4. **→ SC-2**
- [ ] 8. **GREEN doublecheck (**clean-room**).** Verify the test uses the `with-test-home` harness, dispatches via `opencode run`, and asserts single-branch/single-PR creation. **→ SC-2**
- [ ] 9. **Checkpoint commit (**inline**).** Commit the behavioral test.

#### Phase 2 VbC

- [ ] 10. **VbC (**clean-room**).** Run the scenario via `with-test-home`; a clean-room sub-agent reads `session.yaml` and confirms single-branch/single-PR creation. **→ SC-2**

**Concern transition:** Leaving behavioral-enforcement → entering cross-reference. Phase 3 depends on Phase 1's rule existing so the reference resolves.
