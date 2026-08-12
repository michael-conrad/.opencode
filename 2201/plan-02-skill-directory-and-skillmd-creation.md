# Phase 2 — Skill Directory and SKILL.md Creation

**Concern:** Create the `gb-cli` skill directory and routing-only SKILL.md with valid YAML frontmatter.

**Files:**
- `.opencode/skills/gb-cli/SKILL.md` (new)

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: workflow applicability assessment produced
- No existing `gb-cli` skill in `.opencode/skills/` (verified ABSENT)
- Write permissions to `.opencode/skills/`

**Exit Conditions:**
- `.opencode/skills/gb-cli/SKILL.md` exists with valid YAML frontmatter (`name: gb-cli`, agent-intent description ≤ 1024 chars, `license: MIT`, `compatibility: opencode`)
- SKILL.md uses routing-only template (no procedure text, only Workflows section with dispatch contracts)
- SPDX-FileCopyrightText, Provenance, and AI co-authored byline headers present

---

## Code Path Coverage

| Code Path | Coverage |
|-----------|----------|
| `.opencode/skills/gb-cli/SKILL.md` | Created — routing-only skill card with YAML frontmatter, Overview, Mandatory Task Discipline, Workflows section, Cross-References |

## Cross-Cutting SCs

| SC | Cross-Cutting Concern |
|----|----------------------|
| SC-1, SC-2, SC-3 | File creation integrity — file exists, name matches, description ≤ 1024 chars (verification gate: pre-commit) |
| SC-4, SC-5 | SKILL.md template compliance — routing-only, agent-intent description (verification gate: pre-commit) |

## Interface Boundaries

| Boundary | Status |
|----------|--------|
| skill({name: 'gb-cli'}) | ADDED — new entry point for gb CLI workflows |
| Phase 1 applicability assessment | INPUT — determines Workflows section dispatch contracts |
| Phase 3 task cards | OUTPUT — Workflows section references task cards created in Phase 3 |
| available_skills discovery | AUTO — opencode auto-discovers skills in `.opencode/skills/` |

## State Transitions

| Entity | Before | After |
|--------|--------|-------|
| `.opencode/skills/gb-cli/` | Does not exist | Exists with SKILL.md |
| `.opencode/skills/gb-cli/SKILL.md` | Does not exist | Exists — routing-only skill card with YAML frontmatter, Workflows section, headers |

---

## Step-by-step

- [ ] 1. **RED (**sub-agent**).** Write a failing enforcement test asserting `.opencode/skills/gb-cli/SKILL.md` does not yet exist. **→ SC-1**
- [ ] 2. **GREEN (**sub-agent**).** Create `.opencode/skills/gb-cli/` directory and write `SKILL.md` using the routing-only template: YAML frontmatter (`name: gb-cli`, agent-intent description ≤ 1024 chars, `license: MIT`, `compatibility: opencode`), Overview (1-2 sentences), Mandatory Task Discipline (4 items), Workflows section with dispatch contracts determined by Phase 1, Cross-References to `git-workflow`, `issue-operations`, `gitbucket-api`. Include SPDX-FileCopyrightText, Provenance, and AI co-authored byline headers. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify frontmatter `name` matches directory name `gb-cli`, description ≤ 1024 chars, no prohibited sections (Entry Criteria, Procedure, Operating Protocol), no prohibited meta-instruction patterns (Load via skill() when, User phrases:, Dispatch when). **→ SC-2, SC-3, SC-4, SC-5**
- [ ] 4. **Checkpoint commit (**inline**).** Commit the SKILL.md creation.

#### Phase 2 VbC

- [ ] 5. **VbC (**clean-room**).** Verify `.opencode/skills/gb-cli/SKILL.md` exists, `name: gb-cli` in frontmatter, description ≤ 1024 chars, routing-only template, agent-intent description. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

**Cost frame:** Verifying the SKILL.md frontmatter and template compliance costs one grep of the file. Skipping means a structurally invalid skill card ships — the skill fails discovery or violates the routing-only template, and the defect is caught only when the behavioral discovery test fails in Phase 5.

**Concern transition:** Leaving skill directory and SKILL.md creation → entering task cards creation. Phase 3 depends on Phase 2's SKILL.md Workflows section referencing the task cards.
