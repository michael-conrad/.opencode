# Phase 6 — Fix Hardcoded `main` → `$DEFAULT_BRANCH`

**Concern:** Replace all hardcoded `main` branch references in skill task files with `$DEFAULT_BRANCH` or "trunk" terminology.

**Files:**
- `skills/git-workflow/tasks/pre-work.md`
- `skills/git-workflow/tasks/check-pr.md`
- `skills/git-workflow/tasks/operating-protocol.md`
- `skills/git-workflow/tasks/pr-creation/create-pr.md`
- `skills/using-git-worktrees/tasks/reference.md`
- `skills/using-git-worktrees/tasks/create-worktree.md`

**SCs:** SC-11, SC-15, SC-16, SC-17, SC-18, SC-19

**Dependencies:** None

**Entry conditions:** Phase 5 complete

**Exit conditions:** All 6 files use `$DEFAULT_BRANCH` or "trunk" instead of hardcoded `main`

---

- [ ] 80. **RED (**sub-agent**).** Write a grep-based enforcement test that scans the 6 files plus `.opencode/guidelines/` and `.opencode/AGENTS.md`/`.opencode/README.md` for hardcoded `main` as a branch name (exclude `main` in non-branch contexts like function names, variable names, `main()`). The test MUST FAIL because all files still contain hardcoded `main`. **→ SC-11, SC-15, SC-16, SC-17, SC-18, SC-19**
- [ ] 81. **GREEN (**sub-agent**).** Edit `skills/git-workflow/tasks/pre-work.md` line 309: replace `git checkout main && git branch -D` with `git checkout "$DEFAULT_BRANCH" && git branch -D`. **→ SC-11**
- [ ] 82. **GREEN doublecheck (**inline**).** Run `grep -n 'git checkout main' .opencode/skills/git-workflow/tasks/pre-work.md` — confirm zero matches. **→ SC-11**
- [ ] 83. **Checkpoint commit (**inline**).** Commit with message: `Phase 6a: fix hardcoded main in pre-work.md`
- [ ] 84. **GREEN (**sub-agent**).** Edit `skills/git-workflow/tasks/check-pr.md` line 131: replace "Already on main → pull latest" with "Already on trunk → pull latest". **→ SC-11**
- [ ] 85. **GREEN doublecheck (**inline**).** Run `grep -n '"Already on main"' .opencode/skills/git-workflow/tasks/check-pr.md` — confirm zero matches. **→ SC-11**
- [ ] 86. **Checkpoint commit (**inline**).** Commit with message: `Phase 6b: fix hardcoded main in check-pr.md`
- [ ] 87. **GREEN (**sub-agent**).** Edit `skills/git-workflow/tasks/operating-protocol.md`: replace `compare/main...` with `compare/$DEFAULT_BRANCH...` in all compare URL patterns. **→ SC-11, SC-15**
- [ ] 88. **GREEN doublecheck (**inline**).** Run `grep -n 'compare/main' .opencode/skills/git-workflow/tasks/operating-protocol.md` — confirm zero matches. **→ SC-15**
- [ ] 89. **Checkpoint commit (**inline**).** Commit with message: `Phase 6c: fix hardcoded main in operating-protocol.md`
- [ ] 90. **GREEN (**sub-agent**).** Edit `skills/git-workflow/tasks/pr-creation/create-pr.md`: replace "annotated tag on main" → "annotated tag on trunk", "promote → main" → "promote → trunk", "tags from main" → "tags from trunk". **→ SC-11**
- [ ] 91. **GREEN doublecheck (**inline**).** Run `grep -n '\bmain\b' .opencode/skills/git-workflow/tasks/pr-creation/create-pr.md` — confirm zero branch-name `main` references (exclude non-branch contexts). **→ SC-11**
- [ ] 92. **Checkpoint commit (**inline**).** Commit with message: `Phase 6d: fix hardcoded main in create-pr.md`
- [ ] 93. **GREEN (**sub-agent**).** Edit `skills/using-git-worktrees/tasks/reference.md`: replace "Creating worktree from main" → "Creating worktree from trunk", "branch from main" → "branch from trunk". **→ SC-11, SC-16**
- [ ] 94. **GREEN doublecheck (**inline**).** Run `grep -n '\bmain\b' .opencode/skills/using-git-worktrees/tasks/reference.md` — confirm zero branch-name `main` references. **→ SC-16**
- [ ] 95. **Checkpoint commit (**inline**).** Commit with message: `Phase 6e: fix hardcoded main in worktrees reference.md`
- [ ] 96. **GREEN (**sub-agent**).** Edit `skills/using-git-worktrees/tasks/create-worktree.md` line 19: replace "typically main" → "typically the trunk". **→ SC-11, SC-16**
- [ ] 97. **GREEN doublecheck (**inline**).** Run `grep -n '\bmain\b' .opencode/skills/using-git-worktrees/tasks/create-worktree.md` — confirm zero branch-name `main` references. **→ SC-16**
- [ ] 98. **Checkpoint commit (**inline**).** Commit with message: `Phase 6f: fix hardcoded main in create-worktree.md`
- [ ] 99. **GREEN (**sub-agent**).** Run a comprehensive grep sweep across ALL `.opencode/guidelines/` files for hardcoded `main` as a branch name. Fix any remaining references. **→ SC-17**
- [ ] 100. **GREEN doublecheck (**inline**).** Run `grep -rn '\bmain\b' .opencode/guidelines/` — confirm zero branch-name `main` references (exclude non-branch contexts). **→ SC-17**
- [ ] 101. **Checkpoint commit (**inline**).** Commit with message: `Phase 6g: fix hardcoded main in guidelines sweep`
- [ ] 102. **GREEN (**sub-agent**).** Run a comprehensive grep sweep across ALL `.opencode/skills/` task files for hardcoded `main` as a branch name. Fix any remaining references. **→ SC-18**
- [ ] 103. **GREEN doublecheck (**inline**).** Run `grep -rn '\bmain\b' .opencode/skills/` — confirm zero branch-name `main` references (exclude non-branch contexts). **→ SC-18**
- [ ] 104. **Checkpoint commit (**inline**).** Commit with message: `Phase 6h: fix hardcoded main in skills sweep`
- [ ] 105. **GREEN (**sub-agent**).** Scan `.opencode/AGENTS.md` and `.opencode/README.md` for hardcoded `main` as a branch name. Fix any remaining references. **→ SC-19**
- [ ] 106. **GREEN doublecheck (**inline**).** Run `grep -n '\bmain\b' .opencode/AGENTS.md .opencode/README.md` — confirm zero branch-name `main` references. **→ SC-19**
- [ ] 107. **Checkpoint commit (**inline**).** Commit with message: `Phase 6i: fix hardcoded main in AGENTS.md and README.md`

#### Phase 6 VbC

- [ ] 108. **VbC (**clean-room**).** Verify: all 6 target files plus comprehensive sweeps across guidelines, skills, AGENTS.md, and README.md have zero hardcoded `main` branch references. Enforcement test passes. **→ SC-11, SC-15, SC-16, SC-17, SC-18, SC-19**

**Concern transition:** Leaving hardcoded `main` replacement → plan complete. All 19 SCs covered across 6 phases.
