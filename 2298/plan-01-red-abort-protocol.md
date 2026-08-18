# Phase 1 — RED abort protocol

**Concern:** Add the classified-abort terminal state, RED classification set, abort-is-completion normative language, and per-card self-containment to `red.md`.

**Files:**
- `skills/test-driven-development/tasks/red.md`
- `skills/test-driven-development/tasks/green.md` (SC-5 adds abort-is-completion language to both cards)
- `skills/test-driven-development/tasks/operating-protocol.md` (SC-9 negative check — must remain unchanged)

**SCs:** SC-1, SC-3, SC-5, SC-9

**Dependencies:** None

**Entry Conditions:**
- Spec #2298 is approved
- Feature branch exists
- Pre-implementation steps complete

**Exit Conditions:**
- `red.md` defines a classified ABORT terminal state (`status: BLOCKED` + `blocker_reason`) — SC-1
- `red.md` enumerates ALREADY_GREEN, FALSE_PREMISE, NOT_RELEVANT, CONFLICT — SC-3
- Both `red.md` and `green.md` state abort-is-completion and forbid forcing, test-modification-to-fail, and looping — SC-5
- Abort protocol is self-contained per card; `operating-protocol.md` does not contain it — SC-9

---

- [ ] 4. **RED — Assert red.md has no abort terminal state (**sub-agent**).** Dispatch `test-driven-development --task red` to write a content assertion (grep-style) that `red.md` contains a classified abort terminal state, and confirm it fails because the terminal state does not yet exist. Test path: `.opencode/tests-v2/` content assertion for `skills/test-driven-development/tasks/red.md`. Context: `{issue_number: 2298, spec_context: "red.md classified abort terminal state", test_path: ".opencode/tests-v2/red-abort-terminal-state"}`. **SC-1**
- [ ] 5. **GREEN — Add abort terminal state to red.md (**sub-agent**).** Dispatch `test-driven-development --task green` to add to `skills/test-driven-development/tasks/red.md` a second valid terminal state: a classified ABORT returned as `status: BLOCKED` with a `blocker_reason` classification, alongside the existing confirmed-failing-test exit. Context: `{issue_number: 2298, spec_context: "add classified abort terminal state to red.md", test_path: ".opencode/tests-v2/red-abort-terminal-state"}`. **SC-1**
- [ ] 6. **GREEN doublecheck — Verify abort terminal state present (**clean-room**).** Dispatch a clean-room sub-agent to `grep` `red.md` for the abort terminal state (`status: BLOCKED` + `blocker_reason`), report PASS/FAIL. Context: `{issue_number: 2298, target_file: skills/test-driven-development/tasks/red.md}`. **SC-1**
- [ ] 7. **Checkpoint commit (**inline**).** Run `git add skills/test-driven-development/tasks/red.md && git commit -m "Phase 1: add classified abort terminal state to red.md"`. Context: `{issue_number: 2298}`. **SC-1**

- [ ] 8. **RED — Assert red.md lacks RED classifications (**sub-agent**).** Dispatch `test-driven-development --task red` to write a content assertion that `red.md` enumerates ALREADY_GREEN, FALSE_PREMISE, NOT_RELEVANT, CONFLICT, and confirm it fails. Test path: `.opencode/tests-v2/red-abort-classifications`. Context: `{issue_number: 2298, spec_context: "red.md RED classification identifiers", test_path: ".opencode/tests-v2/red-abort-classifications"}`. **SC-3**
- [ ] 9. **GREEN — Enumerate RED classifications in red.md (**sub-agent**).** Dispatch `test-driven-development --task green` to add the four classifications as `blocker_reason` values within `red.md`'s abort section. Context: `{issue_number: 2298, spec_context: "enumerate ALREADY_GREEN, FALSE_PREMISE, NOT_RELEVANT, CONFLICT as blocker_reason values", test_path: ".opencode/tests-v2/red-abort-classifications"}`. **SC-3**
- [ ] 10. **GREEN doublecheck — Verify classifications present (**clean-room**).** Dispatch a clean-room sub-agent to `grep` `red.md` for the four classification identifiers, report PASS/FAIL. Context: `{issue_number: 2298, target_file: skills/test-driven-development/tasks/red.md, classifications: [ALREADY_GREEN, FALSE_PREMISE, NOT_RELEVANT, CONFLICT]}`. **SC-3**
- [ ] 11. **Checkpoint commit (**inline**).** Run `git add skills/test-driven-development/tasks/red.md && git commit -m "Phase 1: enumerate RED abort classifications in red.md"`. Context: `{issue_number: 2298}`. **SC-3**

- [ ] 12. **RED — Assert abort-is-completion absent from both cards (**sub-agent**).** Dispatch `test-driven-development --task red` to write a content assertion that both `red.md` and `green.md` state abort-is-completion, and confirm it fails. Test path: `.opencode/tests-v2/abort-is-completion`. Context: `{issue_number: 2298, spec_context: "abort-is-completion normative language in both TDD cards", test_path: ".opencode/tests-v2/abort-is-completion"}`. **SC-5**
- [ ] 13. **GREEN — Add abort-is-completion language to both cards (**sub-agent**).** Dispatch `test-driven-development --task green` to add normative language to both `red.md` and `green.md`: returning a classified abort IS task completion; the sub-agent must not force the outcome, must not modify a test to make it fail, and must not loop. Context: `{issue_number: 2298, spec_context: "add abort-is-completion normative language to red.md and green.md", test_path: ".opencode/tests-v2/abort-is-completion"}`. **SC-5**
- [ ] 14. **GREEN doublecheck — Verify abort-is-completion present (**clean-room**).** Dispatch a clean-room sub-agent to `grep` both cards for abort-is-completion language, report PASS/FAIL. Context: `{issue_number: 2298, target_files: [skills/test-driven-development/tasks/red.md, skills/test-driven-development/tasks/green.md]}`. **SC-5**
- [ ] 15. **Checkpoint commit (**inline**).** Run `git add skills/test-driven-development/tasks/red.md skills/test-driven-development/tasks/green.md && git commit -m "Phase 1: add abort-is-completion normative language to both cards"`. Context: `{issue_number: 2298}`. **SC-5**

- [ ] 16. **Verify self-containment — operating-protocol.md unchanged (**clean-room**).** Dispatch a clean-room sub-agent to `grep` for the abort protocol in `red.md` and `green.md` (presence) and run a negative `grep` confirming `operating-protocol.md` does NOT contain the abort protocol. Report PASS/FAIL. This is a verification-only item; commit only if a change is required. Context: `{issue_number: 2298, presence_files: [skills/test-driven-development/tasks/red.md, skills/test-driven-development/tasks/green.md], absence_file: skills/test-driven-development/tasks/operating-protocol.md}`. **SC-9**

#### Phase 1 VbC

- [ ] 17. **VbC — Verify red.md abort protocol (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SC-1 (grep abort terminal state in red.md), SC-3 (grep four classifications), SC-5 (grep abort-is-completion in both cards), SC-9 (grep presence in both cards + negative grep in operating-protocol.md). Context: `{issue_number: 2298, sc_ids: [SC-1, SC-3, SC-5, SC-9]}`. **SC-1, SC-3, SC-5, SC-9**

**Concern transition:** Leaving RED abort protocol to entering GREEN abort contract. Phase 2 is independent of Phase 1 (red.md vs green.md) and may proceed; Phase 3 depends on both Phases 1 and 2.
