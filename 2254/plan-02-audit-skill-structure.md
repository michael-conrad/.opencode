# Phase 2 — audit skill structure + role cards

**Concern:** Single Workflows section, remove TDT/Invocation/Tasks, canonical dispatch, rewrite description, repair role-card names/headings, flatten subdirectory tasks, remove redundant evaluator.

**Files:**
- `.opencode/skills/audit/SKILL.md`
- `.opencode/skills/audit/tasks/*-role.md`
- `.opencode/skills/audit/tasks/behavioral-sc-evaluator.md` (removed)
- `.opencode/skills/audit/tasks/closure-verification/`, `coherence-extraction/`, `spec-summary/` (flattened) + stub index files (removed)

**SCs:** SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-12, SC-14

**Dependencies:** None

**Entry Conditions:**
- Spec #2254 is approved
- Feature branch exists
- Phase 1 complete (independent root phase — no same-file conflict with Phase 1)

**Exit Conditions:**
- audit/SKILL.md uses a single Workflows section with 4 DiMo steps, no TDT/Invocation/Tasks sections, canonical dispatch format, no deprecated DiMo strings, canonical agent-intent description
- All 40 role-card frontmatter `name:` fields and `# Task:` headings match filenames
- Three subdirectory audit tasks flattened to flat role files; stub index files and behavioral-sc-evaluator.md removed

---

## Code Path Coverage

- Path 3 (audit dispatch surface): `.opencode/skills/audit/SKILL.md` — single Workflows section, remove TDT/Invocation/Tasks, canonical dispatch, rewrite description
- Path 4 (audit role task cards): `.opencode/skills/audit/tasks/*-role.md`, removed behavioral-sc-evaluator.md, removed subdirectory sets + stub indexes — repair names/headings, flatten, remove redundant evaluator

## Cross-Cutting SCs

- Canonical dispatch format (SC-5, SC-6) — shared with spec-creation (SC-1) in Phase 1
- Numbered-checkbox Workflows format (SC-24) — Phase 6 converts audit Workflows to numbered-checkbox, building on this Phase 2 restructure

## Interface Boundaries

- audit/SKILL.md Workflows → orchestrator dispatch (⚠️ breaking — removes TDT/Invocation/Tasks surface; consumers must use new Workflows surface)
- audit/tasks/*-role.md → audit DiMo role sub-agents (⚠️ breaking — role task cards renamed/relocated; dispatch strings change)
- audit/tasks/completion.md → audit completion (fixed in Phase 4)

## State Transitions

- audit dispatch surface: CURRENT (TDT/Invocation/Tasks sections, deprecated DiMo strings, divergent description) → WORKFLOWS-ONLY (single Workflows section with 4 DiMo steps, canonical dispatch, canonical description)
- audit role task cards: CURRENT (mismatched frontmatter/headings, subdirectory task sets, redundant evaluator) → FLAT (flat role files with matching names/headings, removed redundant evaluator)

---

## Step-by-step

- [ ] 42. **RED (**sub-agent**).** Write failing enforcement test asserting audit/SKILL.md has a single Workflows section with 4 DiMo steps (Investigator, Validator, Evaluator, Arbiter). **→ SC-3**
- [ ] 43. **GREEN (**sub-agent**).** Convert the TDT + Tasks + Invocation + DiMo Role Chain in audit/SKILL.md to a single Workflows section with 4 DiMo steps. **→ SC-3**
- [ ] 44. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-3**
- [ ] 45. **verify (**clean-room**).** Verify SC-3: grep audit/SKILL.md for the Workflows section. **→ SC-3**
- [ ] 46. **commit-inline (**inline**).** Stage and commit audit/SKILL.md with the SC-3 test and change together.

- [ ] 47. **RED (**sub-agent**).** Write failing enforcement test asserting audit/SKILL.md has no Trigger Dispatch Table, Tasks, or Invocation sections. **→ SC-4**
- [ ] 48. **GREEN (**sub-agent**).** Remove the Trigger Dispatch Table, Invocation, and Tasks sections from audit/SKILL.md. **→ SC-4**
- [ ] 49. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-4**
- [ ] 50. **verify (**clean-room**).** Verify SC-4: grep audit/SKILL.md for absence of TDT/Invocation/Tasks sections. **→ SC-4**
- [ ] 51. **commit-inline (**inline**).** Stage and commit audit/SKILL.md with the SC-4 test and change together.

- [ ] 52. **RED (**sub-agent**).** Write failing enforcement test asserting audit/SKILL.md uses the canonical dispatch prompt format `Follow the instructions in [<skill>/tasks/<task>.md](...)`. **→ SC-5**
- [ ] 53. **GREEN (**sub-agent**).** Replace deprecated DiMo dispatch strings in audit/SKILL.md with the canonical dispatch format. **→ SC-5**
- [ ] 54. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-5**
- [ ] 55. **verify (**clean-room**).** Verify SC-5: grep audit/SKILL.md for presence of canonical format. **→ SC-5**
- [ ] 56. **commit-inline (**inline**).** Stage and commit audit/SKILL.md with the SC-5 test and change together.

- [ ] 57. **RED (**sub-agent**).** Write failing enforcement test asserting audit/SKILL.md has no deprecated `execute <task-name> DiMo <role> from audit` dispatch strings. **→ SC-6**
- [ ] 58. **GREEN (**sub-agent**).** Ensure no deprecated DiMo dispatch strings remain in audit/SKILL.md. **→ SC-6**
- [ ] 59. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-6**
- [ ] 60. **verify (**clean-room**).** Verify SC-6: grep audit/SKILL.md for absence of `execute .* DiMo .* from audit`. **→ SC-6**
- [ ] 61. **commit-inline (**inline**).** Stage and commit audit/SKILL.md with the SC-6 test and change together.

- [ ] 62. **RED (**sub-agent**).** Write failing semantic test: clean-room sub-agent reads audit/SKILL.md frontmatter and asserts the description is in canonical agent-intent format (no `Load via skill() when`, `Also load when`, `User phrases:` meta-instructions). **→ SC-7**
- [ ] 63. **GREEN (**sub-agent**).** Rewrite the audit description to canonical agent-intent format. **→ SC-7**
- [ ] 64. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-7**
- [ ] 65. **verify (**clean-room**).** Verify SC-7: sub-agent reads audit/SKILL.md frontmatter and verifies canonical agent-intent format via analytical judgment. **→ SC-7**
- [ ] 66. **commit-inline (**inline**).** Stage and commit audit/SKILL.md with the SC-7 test and change together.

- [ ] 67. **RED (**sub-agent**).** Write failing enforcement test asserting every audit/tasks/*-role.md frontmatter `name:` field matches its filename. **→ SC-8**
- [ ] 68. **GREEN (**sub-agent**).** Repair the 40 role-card frontmatter `name:` fields to match filenames (28 flat: 24 stale pre-rename role names + 4 empty `name` field; 12 subdirectory: all empty `name` field). **→ SC-8**
- [ ] 69. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-8**
- [ ] 70. **verify (**clean-room**).** Verify SC-8: for each audit/tasks/*-role.md, verify frontmatter name == basename. **→ SC-8**
- [ ] 71. **commit-inline (**inline**).** Stage and commit audit/tasks/*-role.md with the SC-8 test and change together.

- [ ] 72. **RED (**sub-agent**).** Write failing enforcement test asserting every audit/tasks/*-role.md `# Task:` heading matches its filename. **→ SC-9**
- [ ] 73. **GREEN (**sub-agent**).** Repair the `# Task:` headings to match filenames. **→ SC-9**
- [ ] 74. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-9**
- [ ] 75. **verify (**clean-room**).** Verify SC-9: for each audit/tasks/*-role.md, verify `# Task:` heading == basename. **→ SC-9**
- [ ] 76. **commit-inline (**inline**).** Stage and commit audit/tasks/*-role.md with the SC-9 test and change together.

- [ ] 77. **RED (**sub-agent**).** Write failing enforcement test asserting the three subdirectory audit tasks (closure-verification/, coherence-extraction/, spec-summary/) are flat role files and their stub index files are absent. **→ SC-12**
- [ ] 78. **GREEN (**sub-agent**).** Flatten the three subdirectories to flat role files and remove the stub index files (closure-verification.md, coherence-extraction.md, spec-summary.md). **→ SC-12**
- [ ] 79. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-12**
- [ ] 80. **verify (**clean-room**).** Verify SC-12: verify the three subdirectories are flat files and stub files are absent. **→ SC-12**
- [ ] 81. **commit-inline (**inline**).** Stage and commit audit/tasks with the SC-12 test and change together.

- [ ] 82. **RED (**sub-agent**).** Write failing enforcement test asserting audit/tasks/behavioral-sc-evaluator.md is absent. **→ SC-14**
- [ ] 83. **GREEN (**sub-agent**).** Remove the redundant audit/tasks/behavioral-sc-evaluator.md. **→ SC-14**
- [ ] 84. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-14**
- [ ] 85. **verify (**clean-room**).** Verify SC-14: verify audit/tasks/behavioral-sc-evaluator.md is absent. **→ SC-14**
- [ ] 86. **commit-inline (**inline**).** Stage and commit audit/tasks with the SC-14 test and change together.

#### Phase 2 VbC

- [ ] 87. **VbC (**clean-room**).** Verify all Phase 2 SCs (SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-12, SC-14) pass their verification methods. **→ SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-12, SC-14**

**Cost frame:** Verifying each audit structure, dispatch-format, description, role-card naming, flattening, and evaluator-removal fix costs one grep search, one per-file check, or one semantic sub-agent read. Skipping means audit dispatches keep routing through the deprecated TDT/Invocation/Tasks surface, roles dispatch to mismatched or missing task cards, and a redundant file with zero consumers persists.

**Concern transition:** Leaving audit skill structure + role cards → entering cross-references + taxonomy. Phase 3 depends on Phase 2's role-split task cards; Phase 4 depends on Phase 2's audit role-card surface; Phase 6 depends on Phase 2's audit restructure; Phase 7 depends on Phase 2's audit restructure.

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
