# Phase 3 — cross-references + taxonomy

**Concern:** Repoint cross-references to role-split files, update reference task names, consolidate taxonomy citations, missing-type hard FAIL rule.

**Files:**
- `.opencode/skills/audit/tasks/*-role.md`
- `.opencode/reference/spec-structure-standards.md`
- `.opencode/skills/spec-creation/tasks/analyze.md`
- `.opencode/reference/holistic-dimensions.yaml` (cross-reference target)

**SCs:** SC-10, SC-11, SC-15, SC-16

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: audit role-card surface restructured, role-split task cards established
- Phase 2 VbC passed

**Exit Conditions:**
- Broken cross-references repointed to role-split files, including holistic-dimensions.yaml
- Stale reference-doc task names updated to analyze/create/validate/revise
- Evidence-type taxonomy citations point at single canonical reference, loaded dynamically
- Missing evidence-type declaration is hard FAIL routed to remediation

---

## Code Path Coverage

- Path 4 (audit role task cards): `.opencode/skills/audit/tasks/*-role.md` — repoint cross-references to role-split files
- Path 5 (reference standards and taxonomy): `.opencode/reference/spec-structure-standards.md`, `holistic-dimensions.yaml` — update stale task names, consolidate taxonomy citations, missing-type hard FAIL rule

## Cross-Cutting SCs

- Evidence-type taxonomy source (SC-15) — shared with validate (SC-18) in Phase 1
- Reference task names (SC-11) — updates reference/skill-card-description-standards.md, which is also a Phase 6 format target (SC-35)

## Interface Boundaries

- audit/tasks/*-role.md → audit DiMo role sub-agents (cross-references repointed to role-split files)
- reference/spec-structure-standards.md → spec-creation validate + audit (missing-type hard FAIL rule)
- reference/holistic-dimensions.yaml → validate + audit (dynamic loading source)

## State Transitions

- audit role task cards: FLAT (from Phase 2) → REPOINTED (cross-references resolve to role-split files)
- taxonomy/dimension source: CURRENT (citations to redirect source) → CANONICAL (single canonical taxonomy reference, dynamic loading)
- reference task names: CURRENT (stale inspect/decompose/write/check/file) → UPDATED (analyze/create/validate/revise)

---

## Step-by-step

- [ ] 88. **RED (**sub-agent**).** Write failing enforcement test asserting audit/tasks and reference/holistic-dimensions.yaml have no references to the non-existent monolithic role-task files (tasks/spec-audit.md, tasks/plan-fidelity.md) and reference the role-split files instead. **→ SC-10**
- [ ] 89. **GREEN (**sub-agent**).** Repoint the broken cross-references to the actual role-split files, including in reference/holistic-dimensions.yaml. **→ SC-10**
- [ ] 90. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-10**
- [ ] 91. **verify (**clean-room**).** Verify SC-10: grep audit/tasks and reference/holistic-dimensions.yaml for absence of monolithic refs and presence of role-split refs. **→ SC-10**
- [ ] 92. **commit-inline (**inline**).** Stage and commit audit/tasks and reference/holistic-dimensions.yaml with the SC-10 test and change together.

- [ ] 93. **RED (**sub-agent**).** Write failing enforcement test asserting reference/skill-card-description-standards.md has no stale task names (inspect/decompose/write/check/file) and uses the actual task names (analyze/create/validate/revise). **→ SC-11**
- [ ] 94. **GREEN (**sub-agent**).** Update the stale reference-doc task names in reference/skill-card-description-standards.md to analyze/create/validate/revise. **→ SC-11**
- [ ] 95. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-11**
- [ ] 96. **verify (**clean-room**).** Verify SC-11: grep reference/skill-card-description-standards.md for absence of stale names and presence of actual names. **→ SC-11**
- [ ] 97. **commit-inline (**inline**).** Stage and commit reference/skill-card-description-standards.md with the SC-11 test and change together.

- [ ] 98. **RED (**sub-agent**).** Write failing enforcement test asserting evidence-type taxonomy citations in spec-creation/tasks/validate.md and audit role cards point at the single canonical reference document, loaded dynamically. **→ SC-15**
- [ ] 99. **GREEN (**sub-agent**).** Point the taxonomy citations in validate and audit role cards at the single canonical reference, loaded dynamically. **→ SC-15**
- [ ] 100. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-15**
- [ ] 101. **verify (**clean-room**).** Verify SC-15: grep spec-creation/tasks/validate.md and audit role cards for canonical reference citation. **→ SC-15**
- [ ] 102. **commit-inline (**inline**).** Stage and commit reference/, spec-creation/tasks/validate.md, and audit role cards with the SC-15 test and change together.

- [ ] 103. **RED (**sub-agent**).** Write failing semantic test: clean-room sub-agent reads reference/spec-structure-standards.md and asserts the missing evidence-type declaration rule is hard FAIL routed to remediation (not default-to-string/warn/backwards-compat). **→ SC-16**
- [ ] 104. **GREEN (**sub-agent**).** Change the missing evidence-type declaration rule in reference/spec-structure-standards.md from default-to-string to hard FAIL routed to remediation. **→ SC-16**
- [ ] 105. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-16**
- [ ] 106. **verify (**clean-room**).** Verify SC-16: sub-agent reads reference/spec-structure-standards.md and verifies the missing-type rule is hard FAIL via analytical judgment. **→ SC-16**
- [ ] 107. **commit-inline (**inline**).** Stage and commit reference/spec-structure-standards.md with the SC-16 test and change together.

#### Phase 3 VbC

- [ ] 108. **VbC (**clean-room**).** Verify all Phase 3 SCs (SC-10, SC-11, SC-15, SC-16) pass their verification methods. **→ SC-10, SC-11, SC-15, SC-16**

**Cost frame:** Verifying each cross-reference repoint, task-name update, taxonomy citation, and missing-type rule fix costs one grep search or one semantic sub-agent read. Skipping means agents resolve to non-existent monolithic task files, reference docs point at non-existent tasks, validate and audit read the taxonomy from a redirect source, and a missing evidence-type declaration silently defaults to string and masks a defect.

**Concern transition:** Leaving cross-references + taxonomy → entering completion routing. Phase 7 depends on Phase 3's cross-reference and taxonomy corrections.

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
