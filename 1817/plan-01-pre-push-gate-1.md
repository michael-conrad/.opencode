# Phase 1 — Pre-push Gate 1 Redesign

**Concern:** Pre-push hook Gate 1 logic — replace `origin/dev` with `origin/$DEFAULT_BRANCH`, remove release promotion branch exemption, add open-PR detection.

**Files:** `.githooks/pre-push`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** None

**Entry conditions:** Feature branch exists, spec approved

**Exit conditions:** Gate 1 checks against `origin/$DEFAULT_BRANCH`, release promotion exemption removed, open-PR detection added

---

- [ ] 1. **RED (**sub-agent**).** Write a behavioral enforcement test that verifies the pre-push Gate 1 script checks against `origin/$DEFAULT_BRANCH` instead of `origin/dev`. The test MUST FAIL because the current code still uses `origin/dev`. **→ SC-1, SC-4**
- [ ] 2. **GREEN (**sub-agent**).** Edit `.githooks/pre-push` Gate 1 logic: replace `origin/dev` with `origin/$DEFAULT_BRANCH` in the merged-branch topology check. **→ SC-1, SC-4**
- [ ] 3. **GREEN doublecheck (**inline**).** Run `grep -n 'origin/dev' .githooks/pre-push` — confirm zero matches. **→ SC-4**
- [ ] 4. **Checkpoint commit (**inline**).** Commit with message: `Phase 1a: replace origin/dev with origin/$DEFAULT_BRANCH in pre-push Gate 1`
- [ ] 5. **RED (**sub-agent**).** Write a behavioral enforcement test that verifies the pre-push Gate 1 script has NO release promotion branch exemption (`release/dev-to-main-*`). The test MUST FAIL because the exemption still exists. **→ SC-5**
- [ ] 6. **GREEN (**sub-agent**).** Edit `.githooks/pre-push` Gate 1 logic: remove the release promotion branch exemption pattern. **→ SC-5**
- [ ] 7. **GREEN doublecheck (**inline**).** Run `grep -n 'release/dev-to-main' .githooks/pre-push` — confirm zero matches. **→ SC-5**
- [ ] 8. **Checkpoint commit (**inline**).** Commit with message: `Phase 1b: remove release promotion branch exemption from pre-push Gate 1`
- [ ] 9. **RED (**sub-agent**).** Write a behavioral enforcement test that verifies the pre-push Gate 1 script allows force-push to branches with open PRs against the trunk, and blocks force-push to branches with no open PR whose commits are in the trunk's history. The test MUST FAIL because the open-PR detection logic doesn't exist yet. **→ SC-2, SC-3**
- [ ] 10. **GREEN (**sub-agent**).** Edit `.githooks/pre-push` Gate 1 logic: add open-PR detection — query for open PRs against the trunk for the pushed branch. If open PR exists, allow force-push. If no open PR and commits are in trunk history, block. **→ SC-2, SC-3**
- [ ] 11. **GREEN doublecheck (**inline**).** Run behavioral test from step 9 — confirm PASS. **→ SC-2, SC-3**
- [ ] 12. **Checkpoint commit (**inline**).** Commit with message: `Phase 1c: add open-PR detection to pre-push Gate 1`

#### Phase 1 VbC

- [ ] 13. **VbC (**clean-room**).** Verify: Gate 1 checks `origin/$DEFAULT_BRANCH` (not `origin/dev`), no release promotion exemption, open-PR detection present. Run grep sweeps and behavioral tests. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

**Concern transition:** Leaving pre-push hook logic → entering guideline conceptual rewrite. Phase 2 depends on Phase 1 being complete (no dependency — independent concerns).
