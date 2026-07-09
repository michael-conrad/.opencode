# Phase 2 — Rewrite `115-branch-naming.md`

**Concern:** Complete rewrite of the branch naming guideline from three-branch model to trunk-based development.

**Files:** `.opencode/guidelines/115-branch-naming.md`

**SCs:** SC-6, SC-7

**Dependencies:** None

**Entry conditions:** Phase 1 complete

**Exit conditions:** `115-branch-naming.md` describes trunk-based development with zero `dev` references

---

- [ ] 14. **RED (**sub-agent**).** Write a behavioral enforcement test that verifies the agent follows trunk-based branch naming (single trunk, feature branches, short-lived branches) instead of the three-branch model. The test MUST FAIL because the current guideline still describes the three-branch model. **→ SC-6, SC-7**
- [ ] 15. **GREEN (**sub-agent**).** Rewrite `.opencode/guidelines/115-branch-naming.md` completely: replace `dev` (staging/integration) → trunk (single mainline), `feature → dev → main` → `feature → trunk` (single PR path), `release: dev → main` → `release: tag on trunk`, `hotfix: parallel branches to dev + main` → `hotfix: branch from trunk, PR to trunk`. Replace all `git checkout dev`, `git pull origin dev`, `git worktree add ... dev` with `$DEFAULT_BRANCH`. **→ SC-6, SC-7**
- [ ] 16. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/guidelines/115-branch-naming.md` — confirm zero matches for `dev` as a branch name (exclude `dev.name`, `dev.email`, `dev-pair`, `/dev/null`). **→ SC-6**
- [ ] 17. **GREEN doublecheck (**sub-agent**).** Read the rewritten file and verify it describes trunk-based development (single trunk, feature branches, short-lived branches). **→ SC-7**
- [ ] 18. **Checkpoint commit (**inline**).** Commit with message: `Phase 2: rewrite 115-branch-naming.md for trunk-based development`

#### Phase 2 VbC

- [ ] 19. **VbC (**clean-room**).** Verify: zero `dev` branch references, trunk-based development described, behavioral test passes. **→ SC-6, SC-7**

**Concern transition:** Leaving guideline conceptual rewrite → entering root file mechanical cleanup. Phase 3 depends on Phase 2 being complete (no dependency — independent concerns).
