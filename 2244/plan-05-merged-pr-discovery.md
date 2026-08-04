# Phase 5 — Merged-PR Discovery

**Concern:** Verify that, with the GitBucket origin wired, `gh pr list` in the isolated test env discovers merged branches and open issues without GitHub auth and the agent does not halt for missing PR context.

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh` (gh pr list in isolated env)

**SCs:** SC3

**Dependencies:** Phase 4

**Entry Conditions:**
- Phase 4 complete: GitBucket origin wired; VbC passed.
- `gh pr list` behavior against the wired origin understood.

**Exit Conditions:**
- `gh pr list` in the isolated env returns merged-branch/issue results without GitHub auth.
- The agent does not halt for missing PR/branch context.

---

- [ ] 21. **RED (**sub-agent**).** Write a failing behavioral test: `opencode run` with `BEHAVIOR_NEEDS_REMOTE=1` fails to produce `gh pr list` output or halts for missing PR context. **→ SC3**

- [ ] 22. **GREEN (**sub-agent**).** No source change beyond Phase 4's origin wiring is expected — discovery depends on the wired origin. Only adjust if Phase 4's wiring proves insufficient for discovery. **→ SC3**

- [ ] 23. **GREEN doublecheck (**clean-room**).** Run `opencode run` with `BEHAVIOR_NEEDS_REMOTE=1`; clean-room evaluation of `session.yaml` confirms `gh pr list` returns merged-branch/issue results and the agent does not halt for missing PR context. **→ SC3**

- [ ] 24. **Checkpoint commit (**inline**).** Commit verification evidence only (no source change unless Phase 4 was insufficient). (No co-author trailer — added at squash time.)

#### Phase 5 VbC

- [ ] 25. **VbC (**clean-room**).** Verify SC3: clean-room `session.yaml` evaluation confirms `gh pr list` returned merged branches/open issues without GitHub auth and no PR-context halt. **→ SC3**

**Concern transition:** Leaving merged-PR discovery → entering 2242-sc6 full-env opt-in. Phase 6 depends on Phase 4's wired origin.

---
