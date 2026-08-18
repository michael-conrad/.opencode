# Phase 3 — Orchestrator post-abort routing

**Concern:** Add post-abort routing guidance to both TDD task cards: cold-reading re-evaluation sub-agent, substantive vs non-substantive adjustment classification, and the retrigger ladder.

**Files:**
- `skills/test-driven-development/tasks/red.md`
- `skills/test-driven-development/tasks/green.md`

**SCs:** SC-6, SC-7, SC-8

**Dependencies:** Phase 1, Phase 2

**Entry Conditions:**
- Phase 1 complete: `red.md` abort protocol (terminal state, classifications, abort-is-completion) present
- Phase 1 VbC passed
- Phase 2 complete: `green.md` abort contract (terminal state, classifications, BAD_TEST_NEEDS_REVISION) present
- Phase 2 VbC passed

**Exit Conditions:**
- Both cards contain post-abort routing to a cold-reading re-evaluation sub-agent → `spec-creation --task revise` / `writing-plans --task revise` — SC-6
- Both cards contain substantive vs non-substantive classification guidance — SC-7
- Both cards contain the retrigger ladder (2 same-classification aborts → re-decomposition evaluation; spec-audit only if not the fix) — SC-8

---

- [ ] 32. **RED — Assert post-abort routing absent from both cards (**sub-agent**).** Dispatch `test-driven-development --task red` to write a content assertion that both `red.md` and `green.md` contain post-abort cold re-evaluation routing, and confirm it fails. Test path: `.opencode/tests-v2/abort-reevaluation-routing`. Context: `{issue_number: 2298, spec_context: "post-abort cold-reading re-evaluation routing in both TDD cards", test_path: ".opencode/tests-v2/abort-reevaluation-routing"}`. **SC-6**
- [ ] 33. **GREEN — Add post-abort routing to both cards (**sub-agent**).** Dispatch `test-driven-development --task green` to add to both `red.md` and `green.md` post-abort routing guidance: on `BLOCKED` + classification, the orchestrator dispatches a cold-reading re-evaluation sub-agent (no orchestrator preload) that identifies the defect and routes to `spec-creation --task revise` / `writing-plans --task revise`. Context: `{issue_number: 2298, spec_context: "add post-abort cold re-evaluation routing to red.md and green.md", test_path: ".opencode/tests-v2/abort-reevaluation-routing"}`. **SC-6**
- [ ] 34. **GREEN doublecheck — Verify routing guidance present (**clean-room**).** Dispatch a clean-room sub-agent to `grep` both cards for post-abort re-evaluation routing guidance (cold-reading sub-agent + revise targets), report PASS/FAIL. Context: `{issue_number: 2298, target_files: [skills/test-driven-development/tasks/red.md, skills/test-driven-development/tasks/green.md]}`. **SC-6**
- [ ] 35. **Checkpoint commit (**inline**).** Run `git add skills/test-driven-development/tasks/red.md skills/test-driven-development/tasks/green.md && git commit -m "Phase 3: add post-abort re-evaluation routing to both TDD cards"`. Context: `{issue_number: 2298}`. **SC-6**

- [ ] 36. **RED — Assert substantive/non-substantive guidance absent (**sub-agent**).** Dispatch `test-driven-development --task red` to write a content assertion that both `red.md` and `green.md` contain substantive/non-substantive classification guidance, and confirm it fails. Test path: `.opencode/tests-v2/abort-adjustment-classification`. Context: `{issue_number: 2298, spec_context: "substantive vs non-substantive adjustment classification guidance in both TDD cards", test_path: ".opencode/tests-v2/abort-adjustment-classification"}`. **SC-7**
- [ ] 37. **GREEN — Add classification guidance to both cards (**sub-agent**).** Dispatch `test-driven-development --task green` to add to both cards guidance that the re-evaluation sub-agent autonomously classifies the adjustment as substantive (revokes plan approval, requires re-auth) or non-substantive (auto-revise, no re-auth). Context: `{issue_number: 2298, spec_context: "add substantive vs non-substantive adjustment classification guidance to red.md and green.md", test_path: ".opencode/tests-v2/abort-adjustment-classification"}`. **SC-7**
- [ ] 38. **GREEN doublecheck — Verify classification guidance present (**clean-room**).** Dispatch a clean-room sub-agent to `grep` both cards for substantive/non-substantive classification guidance, report PASS/FAIL. Context: `{issue_number: 2298, target_files: [skills/test-driven-development/tasks/red.md, skills/test-driven-development/tasks/green.md]}`. **SC-7**
- [ ] 39. **Checkpoint commit (**inline**).** Run `git add skills/test-driven-development/tasks/red.md skills/test-driven-development/tasks/green.md && git commit -m "Phase 3: add substantive/non-substantive adjustment classification to both TDD cards"`. Context: `{issue_number: 2298}`. **SC-7**

- [ ] 40. **RED — Assert retrigger ladder absent (**sub-agent**).** Dispatch `test-driven-development --task red` to write a content assertion that both `red.md` and `green.md` contain the retrigger ladder, and confirm it fails. Test path: `.opencode/tests-v2/abort-retrigger-ladder`. Context: `{issue_number: 2298, spec_context: "retrigger ladder guidance in both TDD cards", test_path: ".opencode/tests-v2/abort-retrigger-ladder"}`. **SC-8**
- [ ] 41. **GREEN — Add retrigger ladder to both cards (**sub-agent**).** Dispatch `test-driven-development --task green` to add to both cards retrigger ladder guidance: after 2 aborts with the same classification, dispatch a re-decomposition/rework evaluation sub-agent; escalate to spec-audit only if re-decomposition is NOT the fix. Context: `{issue_number: 2298, spec_context: "add retrigger ladder guidance to red.md and green.md", test_path: ".opencode/tests-v2/abort-retrigger-ladder"}`. **SC-8**
- [ ] 42. **GREEN doublecheck — Verify retrigger ladder present (**clean-room**).** Dispatch a clean-room sub-agent to `grep` both cards for retrigger ladder guidance, report PASS/FAIL. Context: `{issue_number: 2298, target_files: [skills/test-driven-development/tasks/red.md, skills/test-driven-development/tasks/green.md]}`. **SC-8**
- [ ] 43. **Checkpoint commit (**inline**).** Run `git add skills/test-driven-development/tasks/red.md skills/test-driven-development/tasks/green.md && git commit -m "Phase 3: add retrigger ladder to both TDD cards"`. Context: `{issue_number: 2298}`. **SC-8**

#### Phase 3 VbC

- [ ] 44. **VbC — Verify orchestrator routing guidance (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SC-6 (grep post-abort routing in both cards), SC-7 (grep substantive/non-substantive guidance), SC-8 (grep retrigger ladder). Context: `{issue_number: 2298, sc_ids: [SC-6, SC-7, SC-8]}`. **SC-6, SC-7, SC-8**

**Concern transition:** Leaving orchestrator post-abort routing to entering the behavioral enforcement test. Phase 4 depends on Phase 1 (the ALREADY_GREEN scenario exercises red.md).
