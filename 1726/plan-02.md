# Phase 2 — Verify

- **Concern:** Confirm all `yaml+symbolic` blocks removed, prose and frontmatter intact
- **Files:** `.opencode/guidelines/*.md`
- **SCs:** SC-1, SC-2, SC-3, SC-4
- **Dependencies:** Phase 1 complete
- **Entry:** Phase 1 committed, feature branch has all 30 file changes
- **Exit:** All SCs verified PASS

## Step-by-Step

- [ ] 31. (**sub-agent**) Run `grep -r 'yaml+symbolic' .opencode/guidelines/` — confirm zero matches (SC-1)
- [ ] 32. (**sub-agent**) Spot-check 5 files: read last 10 lines of each to confirm no `yaml+symbolic` fence remains and frontmatter is intact (SC-2, SC-4)
- [ ] 33. (**sub-agent**) Run `git diff --stat` against `dev` to confirm only deletions of YAML blocks, no prose modifications (SC-3)

## Phase Completion

- [ ] All SCs verified PASS
- [ ] Commit any verification artifacts
- [ ] Report completion with plan path
