# Phase 5 — Fix Prose/Command Mismatches

**Concern:** Update prose in 9 skill task files where prose says "dev" but commands already use `$DEFAULT_BRANCH`. Prose must say "trunk" or "default branch" to match the commands.

**Files:**
- `skills/finishing-a-development-branch/tasks/prepare.md`
- `skills/git-workflow/tasks/rebase-pending.md`
- `skills/git-workflow/tasks/review-prep/push-and-cleanup.md`
- `skills/git-workflow/tasks/check-pr.md`
- `skills/git-workflow/tasks/cleanup/branch-cleanup.md`
- `skills/git-workflow/tasks/pr-creation.md`
- `skills/git-workflow/tasks/review-prep.md`
- `skills/git-workflow/tasks/pr-creation/enforcement-gate.md`
- `skills/finishing-a-development-branch/tasks/checklist.md`

**SCs:** SC-10

**Dependencies:** None

**Entry conditions:** Phase 4 complete

**Exit conditions:** All 9 files have prose updated to say "trunk" or "default branch" instead of "dev"

---

- [ ] 51. **RED (**sub-agent**).** Write a grep-based enforcement test that scans the 9 files for prose references to "dev" as a branch name (excluding `dev.name`, `dev.email`, `dev-pair`, `/dev/null`, and command contexts where `dev` is already replaced). The test MUST FAIL because all 9 files still contain "dev" in prose. **→ SC-10**
- [ ] 52. **GREEN (**sub-agent**).** Edit `skills/finishing-a-development-branch/tasks/prepare.md`: replace "Sync Dev Branch" → "Sync Trunk Branch", "local dev" → "local trunk", "dev fast-forwards" → "trunk fast-forwards", "on dev" → "on trunk". **→ SC-10**
- [ ] 53. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/skills/finishing-a-development-branch/tasks/prepare.md` — confirm zero branch-name `dev` in prose. **→ SC-10**
- [ ] 54. **Checkpoint commit (**inline**).** Commit with message: `Phase 5a: fix prose/command mismatch in prepare.md`
- [ ] 55. **GREEN (**sub-agent**).** Edit `skills/git-workflow/tasks/rebase-pending.md`: replace "rebase against dev" → "rebase against trunk", "rebase onto updated dev" → "rebase onto updated trunk", "updated dev state" → "updated trunk state". **→ SC-10**
- [ ] 56. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/skills/git-workflow/tasks/rebase-pending.md` — confirm zero branch-name `dev` in prose. **→ SC-10**
- [ ] 57. **Checkpoint commit (**inline**).** Commit with message: `Phase 5b: fix prose/command mismatch in rebase-pending.md`
- [ ] 58. **GREEN (**sub-agent**).** Edit `skills/git-workflow/tasks/review-prep/push-and-cleanup.md`: replace "rebase on current dev" → "rebase on current trunk", "Commits ahead of dev" → "Commits ahead of trunk", "Dev-based SHA" → "Trunk-based SHA". **→ SC-10**
- [ ] 59. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/skills/git-workflow/tasks/review-prep/push-and-cleanup.md` — confirm zero branch-name `dev` in prose. **→ SC-10**
- [ ] 60. **Checkpoint commit (**inline**).** Commit with message: `Phase 5c: fix prose/command mismatch in push-and-cleanup.md`
- [ ] 61. **GREEN (**sub-agent**).** Edit `skills/git-workflow/tasks/check-pr.md`: replace "local dev history" → "local trunk history", "dev tip" → "trunk tip", "Switch to dev and sync" → "Switch to trunk and sync". **→ SC-10**
- [ ] 62. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/skills/git-workflow/tasks/check-pr.md` — confirm zero branch-name `dev` in prose. **→ SC-10**
- [ ] 63. **Checkpoint commit (**inline**).** Commit with message: `Phase 5d: fix prose/command mismatch in check-pr.md`
- [ ] 64. **GREEN (**sub-agent**).** Edit `skills/git-workflow/tasks/cleanup/branch-cleanup.md`: replace "target branch (dev)" → "target branch (trunk)". **→ SC-10**
- [ ] 65. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md` — confirm zero branch-name `dev` in prose. **→ SC-10**
- [ ] 66. **Checkpoint commit (**inline**).** Commit with message: `Phase 5e: fix prose/command mismatch in branch-cleanup.md`
- [ ] 67. **GREEN (**sub-agent**).** Edit `skills/git-workflow/tasks/pr-creation.md`: replace "rebases on current dev" → "rebases on current trunk". **→ SC-10**
- [ ] 68. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/skills/git-workflow/tasks/pr-creation.md` — confirm zero branch-name `dev` in prose. **→ SC-10**
- [ ] 69. **Checkpoint commit (**inline**).** Commit with message: `Phase 5f: fix prose/command mismatch in pr-creation.md`
- [ ] 70. **GREEN (**sub-agent**).** Edit `skills/git-workflow/tasks/review-prep.md`: replace "rebase on current dev" → "rebase on current trunk". **→ SC-10**
- [ ] 71. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/skills/git-workflow/tasks/review-prep.md` — confirm zero branch-name `dev` in prose. **→ SC-10**
- [ ] 72. **Checkpoint commit (**inline**).** Commit with message: `Phase 5g: fix prose/command mismatch in review-prep.md`
- [ ] 73. **GREEN (**sub-agent**).** Edit `skills/git-workflow/tasks/pr-creation/enforcement-gate.md`: replace "Rebase branch on dev" → "Rebase branch on trunk". **→ SC-10**
- [ ] 74. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/skills/git-workflow/tasks/pr-creation/enforcement-gate.md` — confirm zero branch-name `dev` in prose. **→ SC-10**
- [ ] 75. **Checkpoint commit (**inline**).** Commit with message: `Phase 5h: fix prose/command mismatch in enforcement-gate.md`
- [ ] 76. **GREEN (**sub-agent**).** Edit `skills/finishing-a-development-branch/tasks/checklist.md`: replace "Local dev branch synced" → "Local trunk branch synced". **→ SC-10**
- [ ] 77. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/skills/finishing-a-development-branch/tasks/checklist.md` — confirm zero branch-name `dev` in prose. **→ SC-10**
- [ ] 78. **Checkpoint commit (**inline**).** Commit with message: `Phase 5i: fix prose/command mismatch in checklist.md`

#### Phase 5 VbC

- [ ] 79. **VbC (**clean-room**).** Verify: all 9 files have zero `dev` branch references in prose, grep sweep passes, enforcement test passes. **→ SC-10**

**Concern transition:** Leaving prose/command mismatch fixes → entering hardcoded `main` replacement. Phase 6 depends on Phase 5 being complete (no dependency — independent concerns).
