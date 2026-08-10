# Phase 1 — spec-creation dispatch + task precondition fixes

**Concern:** Canonical dispatch format, remove Task Files table, analyze issue anchoring, dynamic dimension loading, create exec-summary body + forward-reference, post-push reconciliation, issues-data URL root-cause fix.

**Files:**
- `.opencode/skills/spec-creation/SKILL.md`
- `.opencode/skills/spec-creation/tasks/analyze.md`
- `.opencode/skills/spec-creation/tasks/validate.md`
- `.opencode/skills/spec-creation/tasks/create.md`
- `.opencode/skills/issue-operations-core/tasks/creation.md`

**SCs:** SC-1, SC-2, SC-17, SC-18, SC-19, SC-20, SC-21, SC-37

**Dependencies:** None

**Entry Conditions:**
- Spec #2254 is approved (`approved-for-pr` label present)
- Feature branch exists
- Structure artifact and all analytical artifacts exist

**Exit Conditions:**
- spec-creation/SKILL.md uses canonical dispatch format with zero deprecated strings and no Task Files table
- analyze BLOCKs on unbound/placeholder issue number
- validate loads 11 dimensions dynamically
- create routes canonical exec-summary body with forward-reference blockquote and post-push reconciliation
- issue-operations-core/tasks/creation.md Step 5 uses `tree/issues-data/N/` with `{{SPEC_PATH}}` = `N/`

---

## Code Path Coverage

- Path 1 (spec-creation dispatch surface): `.opencode/skills/spec-creation/SKILL.md` — canonical dispatch format, remove Task Files table
- Path 2 (spec-creation task cards): `tasks/{analyze,create,validate}.md` — issue anchoring, exec-summary body, dynamic dimensions
- Path 6 (issue-operations-core creation): `.opencode/skills/issue-operations-core/tasks/creation.md` — URL template root-cause fix

## Cross-Cutting SCs

- Canonical dispatch format (SC-1) — shared with audit (SC-5, SC-6) in Phase 2
- issues-data URL template (SC-37) — verified target for markdown-link SCs (SC-29a/29b/29c) in Phase 6

## Interface Boundaries

- spec-creation/SKILL.md Workflows → orchestrator dispatch (same tasks, corrected format — compatible)
- spec-creation/tasks/analyze.md → spec-creation sub-agent (stricter precondition, same interface)
- spec-creation/tasks/create.md → spec-creation sub-agent (additive body contract)
- spec-creation/tasks/validate.md → spec-creation sub-agent (same validation, dynamic source)
- issue-operations-core/tasks/creation.md → issue creation (bug fix, corrects broken output)

## State Transitions

- spec-creation dispatch surface: CURRENT (deprecated strings, Task Files table) → REMEDIATED (canonical format, no Task Files table)
- analyze task issue anchoring: CURRENT (accepts unbound issue number) → ANCHORED (BLOCKs on unbound/placeholder)
- create task exec-summary body: CURRENT (non-canonical body) → CANONICAL (exec-summary format + forward-reference)
- issues-data URL template: CURRENT (erroneous `.issues/N/` prefix) → FIXED (`tree/issues-data/N/`, `{{SPEC_PATH}}` = `N/`)

---

## Step-by-step

- [ ] 1. **RED (**sub-agent**).** Write failing enforcement test asserting spec-creation/SKILL.md has zero `execute .* from` strings and uses the canonical `Follow the instructions in [<skill>/tasks/<task>.md](...)` format. **→ SC-1**
- [ ] 2. **GREEN (**sub-agent**).** Convert the 6 deprecated `execute X from Y` dispatch prompts in spec-creation/SKILL.md to the canonical dispatch format. **→ SC-1**
- [ ] 3. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-1**
- [ ] 4. **verify (**clean-room**).** Verify SC-1: grep spec-creation/SKILL.md for absence of `execute .* from` and presence of canonical format. **→ SC-1**
- [ ] 5. **commit-inline (**inline**).** Stage and commit spec-creation/SKILL.md with the SC-1 test and change together.

- [ ] 6. **RED (**sub-agent**).** Write failing enforcement test asserting spec-creation/SKILL.md has no `## Task Files` table. **→ SC-2**
- [ ] 7. **GREEN (**sub-agent**).** Remove the redundant `## Task Files` table from spec-creation/SKILL.md. **→ SC-2**
- [ ] 8. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-2**
- [ ] 9. **verify (**clean-room**).** Verify SC-2: grep spec-creation/SKILL.md for absence of `## Task Files`. **→ SC-2**
- [ ] 10. **commit-inline (**inline**).** Stage and commit spec-creation/SKILL.md with the SC-2 test and change together.

- [ ] 11. **RED (**sub-agent**).** Write failing behavioral test dispatching analyze with an unbound/placeholder issue_number and asserting BLOCK. **→ SC-17**
- [ ] 12. **GREEN (**sub-agent**).** Add the analyze task BLOCK on unbound/placeholder issue number precondition. **→ SC-17**
- [ ] 13. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-17**
- [ ] 14. **verify (**clean-room**).** Verify SC-17: opencode run (with-test-home) dispatches analyze with unbound/placeholder issue_number and asserts BLOCK. **→ SC-17**
- [ ] 15. **commit-inline (**inline**).** Stage and commit spec-creation/tasks/analyze.md with the SC-17 test and change together.

- [ ] 16. **RED (**sub-agent**).** Write failing enforcement test asserting spec-creation/tasks/validate.md loads the 11 holistic dimensions dynamically from reference/holistic-dimensions.yaml. **→ SC-18**
- [ ] 17. **GREEN (**sub-agent**).** Make validate load the 11 holistic dimensions dynamically from reference/holistic-dimensions.yaml rather than a hardcoded divergent list. **→ SC-18**
- [ ] 18. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-18**
- [ ] 19. **verify (**clean-room**).** Verify SC-18: grep spec-creation/tasks/validate.md for dynamic load of reference/holistic-dimensions.yaml. **→ SC-18**
- [ ] 20. **commit-inline (**inline**).** Stage and commit spec-creation/tasks/validate.md with the SC-18 test and change together.

- [ ] 21. **RED (**sub-agent**).** Write failing enforcement test asserting spec-creation/tasks/create.md routes the remote issue body to the canonical exec-summary body format (Spec Reference Blockquote, Problem, Scope, Approach, Impact) per issue-operations-core/tasks/creation.md Step 5. **→ SC-19**
- [ ] 22. **GREEN (**sub-agent**).** Route create.md remote issue body to the canonical exec-summary body format defined in issue-operations-core/tasks/creation.md Step 5. **→ SC-19**
- [ ] 23. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-19**
- [ ] 24. **verify (**clean-room**).** Verify SC-19: grep spec-creation/tasks/create.md for a reference to the canonical exec-summary body format / creation.md Step 5. **→ SC-19**
- [ ] 25. **commit-inline (**inline**).** Stage and commit spec-creation/tasks/create.md with the SC-19 test and change together.

- [ ] 26. **RED (**sub-agent**).** Write failing enforcement test asserting spec-creation/tasks/create.md includes the forward-reference Spec Reference Blockquote link pointing to the issues-data branch URL. **→ SC-20**
- [ ] 27. **GREEN (**sub-agent**).** Add the forward-reference Spec Reference Blockquote link (issues-data branch URL) to the remote issue body in create.md. **→ SC-20**
- [ ] 28. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-20**
- [ ] 29. **verify (**clean-room**).** Verify SC-20: grep spec-creation/tasks/create.md for the forward-reference Spec Reference Blockquote / issues-data link. **→ SC-20**
- [ ] 30. **commit-inline (**inline**).** Stage and commit spec-creation/tasks/create.md with the SC-20 test and change together.

- [ ] 31. **RED (**sub-agent**).** Write failing enforcement test asserting the post-push reconciliation of the Spec Reference Blockquote / artifact URL is sequenced after issue-operations/platforms/local/tasks/push-artifacts.md. **→ SC-21**
- [ ] 32. **GREEN (**sub-agent**).** Sequence the post-push reconciliation of the Spec Reference Blockquote / artifact URL after issue-operations/platforms/local/tasks/push-artifacts.md in create.md. **→ SC-21**
- [ ] 33. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-21**
- [ ] 34. **verify (**clean-room**).** Verify SC-21: grep spec-creation/tasks/create.md for the post-push reconciliation sequenced after push-artifacts.md. **→ SC-21**
- [ ] 35. **commit-inline (**inline**).** Stage and commit spec-creation/tasks/create.md with the SC-21 test and change together.

- [ ] 36. **RED (**sub-agent**).** Write failing enforcement test asserting issue-operations-core/tasks/creation.md Step 5 uses the correct issues-data blockquote URL without the `.issues/` path prefix (`tree/issues-data/N/`) and `{{SPEC_PATH}}` = `N/`. **→ SC-37**
- [ ] 37. **GREEN (**sub-agent**).** Correct the issues-data blockquote URL template in creation.md Step 5 to `tree/issues-data/N/` and set `{{SPEC_PATH}}` = `N/`, dropping the erroneous `.issues/` prefix. **→ SC-37**
- [ ] 38. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-37**
- [ ] 39. **verify (**clean-room**).** Verify SC-37: grep issue-operations-core/tasks/creation.md for the corrected URL template without the `.issues/` prefix and the corrected `{{SPEC_PATH}}` value. **→ SC-37**
- [ ] 40. **commit-inline (**inline**).** Stage and commit issue-operations-core/tasks/creation.md with the SC-37 test and change together.

#### Phase 1 VbC

- [ ] 41. **VbC (**clean-room**).** Verify all Phase 1 SCs (SC-1, SC-2, SC-17, SC-18, SC-19, SC-20, SC-21, SC-37) pass their verification methods. **→ SC-1, SC-2, SC-17, SC-18, SC-19, SC-20, SC-21, SC-37**

**Cost frame:** Verifying each dispatch-format, table-removal, dynamic-loading, body-routing, and URL-template fix costs one grep search or one behavioral test run. Skipping means agents keep dispatching with deprecated formats, resolving to non-existent files, reading the taxonomy from a redirect source, and regenerating broken issues-data URLs — every downstream spec inherits the defect.

**Concern transition:** Leaving spec-creation dispatch + task precondition fixes → entering audit skill structure + role cards. Phase 5 depends on Phase 1's canonical exec-summary body format; Phase 6 depends on Phase 1's dispatch/task restructure; Phase 7 depends on Phase 1's dispatch and task fixes.

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
