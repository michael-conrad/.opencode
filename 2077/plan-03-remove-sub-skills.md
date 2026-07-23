# Phase 3 — Remove old sub-skill directories

**Concern:** Cleanup old sub-skills — remove 5 sub-skill directories, consolidate 32 task files into 4

**Files:**
- `.opencode/skills/spec-creation-validation/` — Remove entire directory
- `.opencode/skills/spec-creation-decomposition/` — Remove entire directory
- `.opencode/skills/spec-creation-requirements/` — Remove entire directory
- `.opencode/skills/spec-creation-change-control/` — Remove entire directory
- `.opencode/skills/spec-creation-operating-protocol/` — Remove entire directory

**SCs:** SC-10, SC-11

**Dependencies:** Phase 1, Phase 2

**Entry conditions:** New skill verified working, brainstorming handoff updated

**Exit conditions:** 5 sub-skill directories removed, `ls skills/ | grep spec-creation` shows only `spec-creation`

## Code Path Coverage

- Each sub-skill directory — verify removed
- skills/ directory — verify only spec-creation remains

## Cross-Cutting SCs

- None

## Interface Boundaries

- No remaining references to sub-skill names in any SKILL.md or task file

## State Transitions

- Sub-skill directories exist → sub-skill directories removed
- 32 task files exist → 4 task files remain

## Step-by-step

- [ ] 7. **Remove sub-skill directories (**sub-agent**).** Remove the 5 sub-skill directories:
  - `rm -rf .opencode/skills/spec-creation-validation/`
  - `rm -rf .opencode/skills/spec-creation-decomposition/`
  - `rm -rf .opencode/skills/spec-creation-requirements/`
  - `rm -rf .opencode/skills/spec-creation-change-control/`
  - `rm -rf .opencode/skills/spec-creation-operating-protocol/`
  - **→ SC-10, SC-11**

#### Phase 3 VbC

- [ ] 7a. **VbC (**clean-room**).** Verify: `ls .opencode/skills/ | grep spec-creation` shows only `spec-creation`; `ls .opencode/skills/spec-creation/tasks/` shows exactly 4 files. **→ SC-10, SC-11**

**Concern transition:** Leaving cleanup old sub-skills → entering end-to-end verification. Phase 4 depends on Phase 3 being complete.
