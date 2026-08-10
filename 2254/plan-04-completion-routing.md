# Phase 4 — completion routing

**Concern:** Correct completion task routing, repoint dangling verify-authorization.

**Files:**
- `.opencode/skills/audit/tasks/completion.md`

**SCs:** SC-13

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: audit role-card surface restructured
- Phase 2 VbC passed

**Exit Conditions:**
- audit/tasks/completion.md routes to the actual 3-step verify-authorization workflow
- No dangling `approval-gate --task verify-authorization` reference

---

## Code Path Coverage

- Path 4 (audit role task cards): `.opencode/skills/audit/tasks/completion.md` — correct completion routing, repoint dangling verify-authorization

## Cross-Cutting SCs

- Completion routing (SC-13) — depends on the audit role-card surface restructured in Phase 2

## Interface Boundaries

- audit/tasks/completion.md → audit completion (corrected routing; repointed verify-authorization)

## State Transitions

- audit role task cards: FLAT (from Phase 2) → CORRECTED (completion routes to actual 3-step verify-authorization workflow, no dangling reference)

---

## Step-by-step

- [ ] 109. **RED (**sub-agent**).** Write failing enforcement test asserting audit/tasks/completion.md routes to the actual 3-step verify-authorization workflow and does not reference the dangling `approval-gate --task verify-authorization`. **→ SC-13**
- [ ] 110. **GREEN (**sub-agent**).** Repoint the verify-authorization reference in audit/tasks/completion.md to the actual 3-step workflow. **→ SC-13**
- [ ] 111. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-13**
- [ ] 112. **verify (**clean-room**).** Verify SC-13: grep audit/tasks/completion.md for correct routing and absence of dangling reference. **→ SC-13**
- [ ] 113. **commit-inline (**inline**).** Stage and commit audit/tasks/completion.md with the SC-13 test and change together.

#### Phase 4 VbC

- [ ] 114. **VbC (**clean-room**).** Verify Phase 4 SC-13 passes its verification method. **→ SC-13**

**Cost frame:** Verifying the completion routing fix costs one grep search. Skipping means completion routes to a dangling verify-authorization reference and the audit completion step fails to execute its authorization gate.

**Concern transition:** Leaving completion routing → entering revise exec-summary regeneration. Phase 7 depends on Phase 4's completion routing correction.

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
