# Phase 2 — GREEN abort contract

**Concern:** Add the classified-abort terminal state, GREEN classification set, abort-is-completion normative language, BAD_TEST_NEEDS_REVISION shuffle-to-RED routing, and per-card self-containment to `green.md`.

**Files:**
- `skills/test-driven-development/tasks/green.md`
- `skills/test-driven-development/tasks/operating-protocol.md` (self-containment negative check — must remain unchanged)

**SCs:** SC-2, SC-4, SC-11

**Dependencies:** None (independent of Phase 1; both must complete before Phase 3)

**Entry Conditions:**
- Spec #2298 is approved
- Feature branch exists
- Pre-implementation steps complete

**Exit Conditions:**
- `green.md` defines a classified ABORT terminal state (`status: BLOCKED` + `blocker_reason`) — SC-2
- `green.md` enumerates NO_PURPOSE, IMPOSSIBLE, CONFLICT, SCOPE_CREEP, BAD_TEST_NEEDS_REVISION — SC-4
- `green.md` defines BAD_TEST_NEEDS_REVISION with shuffle-to-RED routing — SC-11

---

- [ ] 18. **RED — Assert green.md has no abort terminal state (**sub-agent**).** Dispatch `test-driven-development --task red` to write a content assertion that `green.md` contains a classified abort terminal state, and confirm it fails. Test path: `.opencode/tests-v2/green-abort-terminal-state`. Context: `{issue_number: 2298, spec_context: "green.md classified abort terminal state", test_path: ".opencode/tests-v2/green-abort-terminal-state"}`. **SC-2**
- [ ] 19. **GREEN — Add abort terminal state to green.md (**sub-agent**).** Dispatch `test-driven-development --task green` to add to `skills/test-driven-development/tasks/green.md` a second valid terminal state: a classified ABORT returned as `status: BLOCKED` with a `blocker_reason` classification, alongside the existing passing-implementation exit. Context: `{issue_number: 2298, spec_context: "add classified abort terminal state to green.md", test_path: ".opencode/tests-v2/green-abort-terminal-state"}`. **SC-2**
- [ ] 20. **GREEN doublecheck — Verify abort terminal state present (**clean-room**).** Dispatch a clean-room sub-agent to `grep` `green.md` for the abort terminal state (`status: BLOCKED` + `blocker_reason`), report PASS/FAIL. Context: `{issue_number: 2298, target_file: skills/test-driven-development/tasks/green.md}`. **SC-2**
- [ ] 21. **Checkpoint commit (**inline**).** Run `git add skills/test-driven-development/tasks/green.md && git commit -m "Phase 2: add classified abort terminal state to green.md"`. Context: `{issue_number: 2298}`. **SC-2**

- [ ] 22. **RED — Assert green.md lacks GREEN classifications (**sub-agent**).** Dispatch `test-driven-development --task red` to write a content assertion that `green.md` enumerates NO_PURPOSE, IMPOSSIBLE, CONFLICT, SCOPE_CREEP, BAD_TEST_NEEDS_REVISION, and confirm it fails. Test path: `.opencode/tests-v2/green-abort-classifications`. Context: `{issue_number: 2298, spec_context: "green.md GREEN classification identifiers", test_path: ".opencode/tests-v2/green-abort-classifications"}`. **SC-4**
- [ ] 23. **GREEN — Enumerate GREEN classifications in green.md (**sub-agent**).** Dispatch `test-driven-development --task green` to add the five classifications as `blocker_reason` values within `green.md`'s abort section. Context: `{issue_number: 2298, spec_context: "enumerate NO_PURPOSE, IMPOSSIBLE, CONFLICT, SCOPE_CREEP, BAD_TEST_NEEDS_REVISION as blocker_reason values", test_path: ".opencode/tests-v2/green-abort-classifications"}`. **SC-4**
- [ ] 24. **GREEN doublecheck — Verify classifications present (**clean-room**).** Dispatch a clean-room sub-agent to `grep` `green.md` for the five classification identifiers, report PASS/FAIL. Context: `{issue_number: 2298, target_file: skills/test-driven-development/tasks/green.md, classifications: [NO_PURPOSE, IMPOSSIBLE, CONFLICT, SCOPE_CREEP, BAD_TEST_NEEDS_REVISION]}`. **SC-4**
- [ ] 25. **Checkpoint commit (**inline**).** Run `git add skills/test-driven-development/tasks/green.md && git commit -m "Phase 2: enumerate GREEN abort classifications in green.md"`. Context: `{issue_number: 2298}`. **SC-4**

- [ ] 26. **RED — Assert BAD_TEST_NEEDS_REVISION absent (**sub-agent**).** Dispatch `test-driven-development --task red` to write a content assertion that `green.md` defines the BAD_TEST_NEEDS_REVISION classification with shuffle-to-RED routing, and confirm it fails. Test path: `.opencode/tests-v2/green-bad-test-needs-revision`. Context: `{issue_number: 2298, spec_context: "green.md BAD_TEST_NEEDS_REVISION classification and shuffle-to-RED routing", test_path: ".opencode/tests-v2/green-bad-test-needs-revision"}`. **SC-11**
- [ ] 27. **GREEN — Add BAD_TEST_NEEDS_REVISION to green.md (**sub-agent**).** Dispatch `test-driven-development --task green` to add the `BAD_TEST_NEEDS_REVISION` classification to `green.md`'s abort section, with routing guidance that the GREEN sub-agent aborts via `status: BLOCKED, blocker_reason: BAD_TEST_NEEDS_REVISION` and shuffles the defective test back to the RED phase for revision, and SHALL NOT implement against the defective test. Context: `{issue_number: 2298, spec_context: "add BAD_TEST_NEEDS_REVISION classification and shuffle-to-RED routing to green.md", test_path: ".opencode/tests-v2/green-bad-test-needs-revision"}`. **SC-11**
- [ ] 28. **GREEN doublecheck — Verify BAD_TEST_NEEDS_REVISION present (**clean-room**).** Dispatch a clean-room sub-agent to `grep` `green.md` for the classification identifier and shuffle-to-RED routing, report PASS/FAIL. Context: `{issue_number: 2298, target_file: skills/test-driven-development/tasks/green.md, classification: BAD_TEST_NEEDS_REVISION}`. **SC-11**
- [ ] 29. **Checkpoint commit (**inline**).** Run `git add skills/test-driven-development/tasks/green.md && git commit -m "Phase 2: add BAD_TEST_NEEDS_REVISION shuffle-to-RED abort to green.md"`. Context: `{issue_number: 2298}`. **SC-11**

- [ ] 30. **Verify self-containment — operating-protocol.md unchanged (**clean-room**).** Dispatch a clean-room sub-agent to `grep` for the abort protocol in `green.md` (presence) and run a negative `grep` confirming `operating-protocol.md` does NOT contain the abort protocol. Report PASS/FAIL. This is a verification-only item; commit only if a change is required. Context: `{issue_number: 2298, presence_file: skills/test-driven-development/tasks/green.md, absence_file: skills/test-driven-development/tasks/operating-protocol.md}`. **SC-9**

#### Phase 2 VbC

- [ ] 31. **VbC — Verify green.md abort contract (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SC-2 (grep abort terminal state in green.md), SC-4 (grep five classifications), SC-11 (grep BAD_TEST_NEEDS_REVISION + shuffle-to-RED routing). Context: `{issue_number: 2298, sc_ids: [SC-2, SC-4, SC-11]}`. **SC-2, SC-4, SC-11**

**Concern transition:** Leaving GREEN abort contract to entering orchestrator post-abort routing. Phase 3 depends on both Phase 1 (red.md) and Phase 2 (green.md) being complete.
