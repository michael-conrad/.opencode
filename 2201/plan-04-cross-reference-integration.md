# Phase 4 — Cross-Reference Integration

**Concern:** Wire the gb-cli skill into existing skills and AGENTS.md.

**Files:**
- `.opencode/skills/git-workflow/SKILL.md` (modify)
- `.opencode/skills/issue-operations/SKILL.md` (modify)
- `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md` (modify)
- `.opencode/skills/release-promoter/SKILL.md` (modify)
- `.opencode/AGENTS.md` (modify)

**SCs:** SC-18

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: gb-cli skill exists to reference

**Exit Conditions:**
- `gb-cli` cross-references appear in git-workflow, issue-operations, gitbucket-api, and release-promoter SKILL.md files
- `.opencode/AGENTS.md` gb CLI tool documentation section references the gb-cli skill

---

## Code Path Coverage

| Code Path | Coverage |
|-----------|----------|
| `.opencode/skills/git-workflow/SKILL.md` | Add gb-cli cross-reference entry (gb handles gb-specific commands; git-workflow handles git operations) |
| `.opencode/skills/issue-operations/SKILL.md` | Add gb-cli cross-reference entry |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md` | Add gb-cli cross-reference entry |
| `.opencode/skills/release-promoter/SKILL.md` | Add gb-cli cross-reference entry |
| `.opencode/AGENTS.md` | Add gb-cli to gb CLI tool documentation section |

## Cross-Cutting SCs

| SC | Cross-Cutting Concern |
|----|----------------------|
| SC-18 | Cross-reference integration — gb-cli referenced in 4 target SKILL.md files (verification gate: pre-commit) |

## Interface Boundaries

| Boundary | Status |
|----------|--------|
| git-workflow | UNCHANGED — sole owner of git operations; gains gb-cli cross-reference |
| issue-operations | UNCHANGED — dispatcher entry point; gains gb-cli cross-reference |
| gitbucket-api | MINOR — gains gb-cli cross-reference (delegation description updated in Phase 6) |
| release-promoter | UNCHANGED — retains release workflow ownership; gains gb-cli cross-reference |

## State Transitions

| Entity | Before | After |
|--------|--------|-------|
| `.opencode/skills/git-workflow/SKILL.md` | No gb-cli reference | Adds gb-cli cross-reference entry |
| `.opencode/skills/issue-operations/SKILL.md` | No gb-cli reference | Adds gb-cli cross-reference entry |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md` | No gb-cli reference | Adds gb-cli cross-reference entry |
| `.opencode/skills/release-promoter/SKILL.md` | No gb-cli reference | Adds gb-cli cross-reference entry |
| `.opencode/AGENTS.md` | gb CLI documented without gb-cli skill reference | gb-cli added to gb CLI tool documentation section |

---

## Step-by-step

- [ ] 1. **RED (**sub-agent**).** Write a failing enforcement test asserting no `gb-cli` cross-reference exists in the 4 target SKILL.md files. **→ SC-18**
- [ ] 2. **GREEN (**sub-agent**).** Add `gb-cli` cross-reference entries to the Cross-References sections of `.opencode/skills/git-workflow/SKILL.md`, `.opencode/skills/issue-operations/SKILL.md`, `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`, and `.opencode/skills/release-promoter/SKILL.md`. Update the `.opencode/AGENTS.md` gb CLI tool documentation section to reference the gb-cli skill. **→ SC-18**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify each of the 4 SKILL.md files contains a `gb-cli` cross-reference entry and AGENTS.md references the gb-cli skill. **→ SC-18**
- [ ] 4. **Checkpoint commit (**inline**).** Commit the cross-reference integration.

#### Phase 4 VbC

- [ ] 5. **VbC (**clean-room**).** Verify `gb-cli` cross-references appear in all 4 target SKILL.md files and AGENTS.md. **→ SC-18**

**Cost frame:** Verifying the cross-references costs a grep of each target SKILL.md file. Skipping means the gb-cli skill is orphaned — agents never discover it from related skills, and the skill's routing surface is incomplete.

**Concern transition:** Leaving cross-reference integration → entering behavioral enforcement tests. Phase 5 depends on Phases 2-3 (skill and task cards exist to be discovered).
